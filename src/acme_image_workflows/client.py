"""Public Diffusers facade.

All Diffusers usage in Acme workflows must go through this module.
Unit tests stub `DiffusersClient` — no network or GPU required.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Protocol


class PipelineLike(Protocol):
    def __call__(self, prompt: str, **kwargs: Any) -> Any: ...


@dataclass
class PreviewResult:
    """Normalized preview payload returned to callers and QA."""

    prompt: str
    image: Any
    metadata: dict[str, Any] = field(default_factory=dict)


class DiffusersClient:
    """Facade over HuggingFace Diffusers public APIs.

    Production code may construct a real pipeline; demos and unit tests
    inject a stub via ``pipeline``.
    """

    def __init__(self, pipeline: PipelineLike | None = None) -> None:
        self._pipeline = pipeline

    @property
    def pipeline(self) -> PipelineLike | None:
        return self._pipeline

    def run_text_to_image(
        self,
        prompt: str,
        *,
        num_inference_steps: int = 4,
        guidance_scale: float = 1.0,
        **kwargs: Any,
    ) -> PreviewResult:
        if self._pipeline is None:
            raise RuntimeError(
                "DiffusersClient has no pipeline. Pass a stub in tests "
                "or load a public Diffusers pipeline before calling."
            )
        raw = self._pipeline(
            prompt,
            num_inference_steps=num_inference_steps,
            guidance_scale=guidance_scale,
            **kwargs,
        )
        image = getattr(raw, "images", None)
        if image is not None:
            image = image[0] if image else None
        else:
            image = raw
        return PreviewResult(
            prompt=prompt,
            image=image,
            metadata={
                "num_inference_steps": num_inference_steps,
                "guidance_scale": guidance_scale,
                "backend": "diffusers",
            },
        )
