"""Shared fixtures — always stub Diffusers; never hit network/GPU."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import pytest

from acme_image_workflows.client import DiffusersClient


@dataclass
class FakeImages:
    images: list[Any]


class StubPipeline:
    def __init__(self, image: Any = "stub-image") -> None:
        self.image = image
        self.calls: list[dict[str, Any]] = []

    def __call__(self, prompt: str, **kwargs: Any) -> FakeImages:
        self.calls.append({"prompt": prompt, **kwargs})
        return FakeImages(images=[self.image])


@pytest.fixture
def stub_pipeline() -> StubPipeline:
    return StubPipeline()


@pytest.fixture
def stub_client(stub_pipeline: StubPipeline) -> DiffusersClient:
    return DiffusersClient(pipeline=stub_pipeline)
