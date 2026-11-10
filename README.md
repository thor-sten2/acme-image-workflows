# Acme Image Workflows

Acme wrapper over HuggingFace Diffusers for a **20-minute SA ramp demo**: convention-correct first change, durable Cursor rules/skills, mock CI/deploy gates, Jira ACME status, and a Grok Bot outer loop.

Sibling `diffusers/` (if present locally) is **read-only context** — demo PRs never land there.

## Problem

New engineers and agents burn review rounds by editing the wrong tree, calling private Diffusers APIs, or shipping without a visible PM/QA approval. This package owns the change surface; Diffusers stays convention context.

## How to run

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
make test
make ci_mock
```

Optional real Diffusers runtime (not needed for unit tests):

```bash
pip install -e ".[diffusers]"
```

### Mock ship path

```bash
make approve_deploy TICKET=ACME-2
make deploy_mock TICKET=ACME-2
```

Approval phrase (exact): `approve deploy ACME-N`

## Layout

```text
src/acme_image_workflows/   # owned package
  client.py                 # Diffusers facade (stub in tests)
  registry.py
  workflows/text_preview.py # sample workflow
tests/
scripts/ci_mock.sh
scripts/deploy_mock.sh
.cursor/rules|skills/
docs/demo/                  # Bot pack + walkthrough
```

New capability: `workflows/<name>.py` + `tests/test_<name>.py` + registry entry.

## Live vs mocked

| Live | Mocked |
| --- | --- |
| Repo, rules/skills, scaffold, unit tests, PR | GPU inference / model download in CI |
| Jira ACME ticket + transitions | Multi-env promotion |
| Grok Bot start/steer/status/approve | Real production deploy (`deploy_mock` prints + tags status) |
| Cloud Agent wiring (see checklist) | Full Diffusers upstream CI |

## Demo docs

- [Walkthrough](docs/demo/walkthrough.md)
- [Grok Bot brief](docs/demo/grok_bot_brief.md)
- [Cloud Agent prompt](docs/demo/cloud_agent_prompt.md)
- [Wiring checklist](docs/demo/wiring_checklist.md)
- [Jira status mapping](docs/demo/jira_status_mapping.md)

Live ticket: **ACME-2** — add `preview_watermark` (not on `main` until the live first-change).
<!-- cloud-agent wiring check -->
