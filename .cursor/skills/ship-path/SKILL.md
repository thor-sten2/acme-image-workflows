---
name: ship-path
description: Run the Acme ship path from green tests through ci_mock, human approve, and deploy_mock.
---

# /ship-path

End-to-end local ship path for an ACME ticket (mocked CI/deploy).

## Steps

1. Confirm `/self-check` and `/boundary-guard` are clean.
2. Run `make ci_mock` — must PASS (allowlist + static checks + pytest).
3. Ask a human for explicit approval using the exact phrase:
   `approve deploy ACME-N`
   Or write it via: `make approve_deploy TICKET=ACME-N`
4. Run: `make deploy_mock TICKET=ACME-N`
   Optional inline: `make deploy_mock TICKET=ACME-N APPROVE='approve deploy ACME-N'`
5. Confirm `.demo_deploy_status` shows `status=mock_deployed` for that ticket.
6. Report ticket id, CI result, approval, and mock deploy timestamp. Do **not** claim a real production deploy.

## Fail-closed

- Never skip human approval.
- Never edit `diffusers/` to make CI pass.
- Never widen `allowlist.txt` without Platform ownership.
