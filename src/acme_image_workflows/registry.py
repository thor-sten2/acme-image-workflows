"""Workflow registry — new capability = module + test + registry entry."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any

WorkflowFn = Callable[..., Any]

_REGISTRY: dict[str, WorkflowFn] = {}


def register_workflow(name: str, fn: WorkflowFn) -> WorkflowFn:
    if not name or not name.replace("_", "").isalnum():
        raise ValueError(f"Invalid workflow name: {name!r}")
    if name in _REGISTRY:
        raise ValueError(f"Workflow already registered: {name}")
    _REGISTRY[name] = fn
    return fn


def get_workflow(name: str) -> WorkflowFn:
    try:
        return _REGISTRY[name]
    except KeyError as exc:
        known = ", ".join(sorted(_REGISTRY)) or "(none)"
        raise KeyError(f"Unknown workflow {name!r}. Known: {known}") from exc


def list_workflows() -> list[str]:
    return sorted(_REGISTRY)


def clear_registry() -> None:
    """Test helper — clears all registrations."""
    _REGISTRY.clear()


def _autoload() -> None:
    """Import built-in workflows so they self-register."""
    # Local imports avoid circular deps at package import time.
    from acme_image_workflows.workflows import text_preview as _text_preview  # noqa: F401


_autoload()
