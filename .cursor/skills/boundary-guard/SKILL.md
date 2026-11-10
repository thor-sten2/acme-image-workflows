---
name: boundary-guard
description: Enforce fail-closed path allowlist and Diffusers read-only boundary before CI/PR.
---

# /boundary-guard

## Rules (fail-closed)

1. Reject any change under `diffusers/`.
2. Reject paths not covered by `allowlist.txt`.
3. Reject secrets (`.env`, credentials, tokens) in the diff.
4. Reject direct Diffusers usage outside `client.py`.

## How to verify

```bash
make ci_mock
```

`scripts/ci_mock.sh` re-checks allowlist + banned patterns + pytest.

If anything fails, fix or narrow scope — do not widen the allowlist unless Platform owns the change.
