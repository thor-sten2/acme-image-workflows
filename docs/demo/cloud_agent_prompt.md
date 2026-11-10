# Cloud Agent prompt (paste into Grok Build / Cursor Cloud Agent)

Use this when starting implementation for the live demo ticket.

---

You are implementing a scoped change in **acme-image-workflows** (Acme wrapper over HuggingFace Diffusers).

**Ticket:** ACME-2 — Add `preview_watermark` workflow for QA sign-off  
**Repo:** `thor-sten2/acme-image-workflows` (local sibling `diffusers/` is READ-ONLY context — do not modify)

## Skills to invoke (in order)

1. `/first-change` — implement the workflow from the ticket
2. `/self-check` — pre-PR convention checklist
3. `/boundary-guard` — fail-closed allowlist
4. `/ship-path` — stop before human approval; report how to approve

## Requirements

- Add `src/acme_image_workflows/workflows/preview_watermark.py`
- Register `preview_watermark` (and autoload in `registry._autoload()`)
- Metadata must include `workflow=preview_watermark`, `watermark=True`, `preview=True`
- Use only `DiffusersClient` from `client.py` (injectable); no direct Diffusers imports in workflows
- Add `tests/test_preview_watermark.py` with stub client — no network/GPU
- Run `make test` and `make ci_mock` until green

## Do not

- Edit `diffusers/`
- Add secrets
- Invent a different feature than `preview_watermark`
- Run `deploy_mock` without human phrase `approve deploy ACME-2`

## Done when

- Tests + `ci_mock` PASS
- Short self-check report ready for PR/Bot status
- Hand back to Grok Bot for human approval
