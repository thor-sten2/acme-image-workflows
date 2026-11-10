"""Unit tests for the text_preview sample workflow."""

from __future__ import annotations

import pytest

from acme_image_workflows.client import DiffusersClient
from acme_image_workflows.registry import get_workflow, list_workflows
from acme_image_workflows.workflows.text_preview import run_text_preview


def test_text_preview_registered() -> None:
    assert "text_preview" in list_workflows()
    assert get_workflow("text_preview") is run_text_preview


def test_text_preview_returns_stub_image(stub_client: DiffusersClient) -> None:
    result = run_text_preview("a red bicycle", client=stub_client)
    assert result.prompt == "a red bicycle"
    assert result.image == "stub-image"
    assert result.metadata["workflow"] == "text_preview"
    assert result.metadata["preview"] is True
    assert result.metadata["backend"] == "diffusers"


def test_text_preview_rejects_empty_prompt(stub_client: DiffusersClient) -> None:
    with pytest.raises(ValueError, match="prompt"):
        run_text_preview("   ", client=stub_client)


def test_client_requires_pipeline() -> None:
    client = DiffusersClient()
    with pytest.raises(RuntimeError, match="no pipeline"):
        client.run_text_to_image("anything")
