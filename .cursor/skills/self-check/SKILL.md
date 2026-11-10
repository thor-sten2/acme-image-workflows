---
name: self-check
description: Pre-PR self-check against Acme conventions, banned Diffusers patterns, and test stubs.
---

# /self-check

Run before opening or updating a PR.

## Checklist

- [ ] Only allowed paths changed (see `allowlist.txt`); no `diffusers/` edits
- [ ] New workflow has matching `tests/test_<name>.py` and registry entry
- [ ] No direct `diffusers` imports under `workflows/`
- [ ] No private/`_` Diffusers imports
- [ ] No banned deprecated calls (e.g. `enable_xformers_memory_efficient_attention`)
- [ ] Tests stub `DiffusersClient`; no network/GPU
- [ ] `make test` passes locally

## Report

Summarize: files touched, checklist results, residual risks. Keep it short enough for a PR description.
