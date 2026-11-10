---
name: first-change
description: Land a convention-correct first change for an Acme ACME ticket (new workflow + tests + registry).
---

# /first-change

Implement one scoped Acme workflow change from a Jira ACME ticket.

## Preconditions

- Ticket id (e.g. `ACME-1`) and short acceptance criteria
- Confirm scope: edit only `src/acme_image_workflows/` + matching tests; never `diffusers/`

## Steps

1. Read `src/acme_image_workflows/workflows/text_preview.py` as the template.
2. Add `workflows/<name>.py` that:
   - Accepts a `DiffusersClient` (injectable)
   - Uses only the `client.py` facade
   - Calls `register_workflow("<name>", fn)`
3. Autoload the module from `registry._autoload()` if it is a built-in.
4. Add `tests/test_<name>.py` using fixtures from `tests/conftest.py` (stub client; no network/GPU).
5. Run `make test`. Fix until green.
6. Hand off to `/self-check` then `/ship-path`.

## Demo ticket shape (`preview_watermark`)

- Stubbed preview via client
- Metadata flag `watermark=True` (and `workflow=preview_watermark`) for QA sign-off
- Do not invent a different use case
