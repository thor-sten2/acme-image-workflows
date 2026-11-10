# Jira ACME status & approval mapping

Live demo ticket: **[ACME-1](https://thor-sten.atlassian.net/browse/ACME-1)** — `preview_watermark` (Acme wrapper only).

## Status mapping

| Jira status | Demo meaning | Who moves it |
| --- | --- | --- |
| To Do | Scope confirmed; ready for first change | PM / Grok Bot after confirm |
| In Progress | Agent implementing `/first-change` | Grok Bot / engineer |
| In Review | PR open; self-check + `ci_mock` green | Bot after CI report |
| Done | Human approved deploy + `deploy_mock` PASS | Human + Bot |

If the ACME board uses different names, map to the closest equivalent and say the mapping out loud in the room.

## Approval phrase (fail-closed)

Exact phrase required before mock deploy:

```text
approve deploy ACME-N
```

Examples:

- Bot asks: “CI is green on ACME-12. Reply `approve deploy ACME-12` to mock-deploy.”
- Local: `make approve_deploy TICKET=ACME-12` then `make deploy_mock TICKET=ACME-12`

## What is not approval

- Emoji reactions, “LGTM”, or “ship it” without the exact phrase
- Green unit tests alone
- Opening a PR

## After deploy_mock

Local marker `.demo_deploy_status` records `status=mock_deployed` for the ticket. Transition Jira to **Done** and note that this is a **mock** deploy (no real prod).
