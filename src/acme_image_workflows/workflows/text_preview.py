"""Sample workflow: stub-friendly text-to-image preview."""

from __future__ import annotations

from typing import Any

from acme_image_workflows.client import DiffusersClient, PreviewResult
from acme_image_workflows.registry import register_workflow


def run_text_preview(
    prompt: str,
    *,
    client: DiffusersClient | None = None,
    **kwargs: Any,
) -> PreviewResult:
    """Run a low-step text preview for QA / design review."""
    if not prompt or not prompt.strip():
        raise ValueError("prompt must be a non-empty string")
    active = client or DiffusersClient()
    result = active.run_text_to_image(prompt.strip(), num_inference_steps=4, **kwargs)
    result.metadata.setdefault("workflow", "text_preview")
    result.metadata.setdefault("preview", True)
    return result


register_workflow("text_preview", run_text_preview)
