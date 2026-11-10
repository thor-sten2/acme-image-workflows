# 20-minute Acme Diffusers ramp walkthrough

**Impact line:** Same-day first clean change for a scoped ticket; fewer review rounds via pre-PR self-check + boundary CI; PM/QA/DevOps visibility and approval without living in the IDE.

## Cast

| Role | Tool |
| --- | --- |
| Outer loop (PM/QA/DevOps front door) | Grok Bot |
| Ticket of record | Jira ACME (e.g. ACME-2) |
| Inner loop (implementation) | Grok Build / Cursor Cloud Agent or local agent |
| Gates | `make ci_mock` + human `approve deploy ACME-N` + `make deploy_mock` |

## Timeline (~20 min)

1. **Land (2 min)** — Show repo layout: Acme package owns changes; `diffusers/` is read-only context. Point at `.cursor/rules` + skills.
2. **Ticket (2 min)** — Open ACME-2 (`preview_watermark`). Bot confirms scope with human.
3. **First change (8 min)** — Bot kicks Cloud Agent (or local) with `/first-change`. Agent adds workflow + tests + registry; runs `/self-check`.
4. **CI gate (3 min)** — `make ci_mock` (allowlist, public-API check, pytest). Show a fail-closed story if someone touches `diffusers/`.
5. **Approve + mock deploy (3 min)** — Human: `approve deploy ACME-2`. Run `make deploy_mock TICKET=ACME-2`. Transition Jira Done.
6. **Close (2 min)** — Live vs mocked table; Platform owns rules/skills/Bot brief as Diffusers evolves.

## Live vs mocked

| Live | Mocked |
| --- | --- |
| Repo, rules/skills, scaffold, unit tests, PR | GPU inference / model download in CI |
| Jira ACME ticket + transitions | Multi-env promotion |
| Grok Bot start/steer/status/approve | Real production deploy |
| Cloud Agent wiring (finish pre-demo) | Full Diffusers upstream CI |

## Local dry-run (no Bot)

```bash
make install
make test
# implement preview_watermark via /first-change
make ci_mock
make approve_deploy TICKET=ACME-2
make deploy_mock TICKET=ACME-2
```
