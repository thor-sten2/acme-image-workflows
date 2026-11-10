# Grok Bot ↔ Cloud Agent ↔ repo wiring checklist

Partial setup is documented here. **Product UI steps cannot be finished from this agent** — the presenter completes these before the live room.

## Preconditions

- [ ] GitHub repo `thor-sten2/acme-image-workflows` exists and is pushed
- [ ] Jira ACME ticket for `preview_watermark` exists (seeded as **ACME-2**)
- [ ] Presenter has access to Grok Bot admin / Cursor Cloud Agents for the demo account

## Bot configuration (Grok Bot product UI)

- [ ] Create/open bot using identity from `grok_bot_brief.md`
- [ ] Paste allow/deny rules from the brief into Bot instructions
- [ ] Attach or link Jira project **ACME** (`thor-sten.atlassian.net`)
- [ ] Set approval detection to exact phrase `approve deploy ACME-N`

## Cloud Agent connection

- [ ] Connect Bot to Cursor Cloud Agents / Grok Build for this GitHub repo
- [ ] Default agent prompt = contents of `cloud_agent_prompt.md` (ticket key parameterized)
- [ ] Confirm agent can clone `thor-sten2/acme-image-workflows` and run `make test` / `make ci_mock`
- [ ] Confirm agent **cannot** push to protected defaults without the demo’s intended flow (use a feature branch)

## Repo / local

- [ ] `.cursor/rules` and skills present on default branch
- [ ] `make ci_mock` green on clean main
- [ ] Presenter knows `make approve_deploy` / `make deploy_mock` fallback if Bot→deploy automation is not wired

## Day-of smoke (5 min)

1. Ask Bot for status on ACME-2  
2. Confirm scope once  
3. Dry-run approval phrase parsing (do not need full implement if time is short)  
4. Have local fallback terminal ready

## Remaining after this scaffold (cannot do from coding agent alone)

1. Click-path Bot creation / instruction paste in Grok Bot UI  
2. OAuth / install Cloud Agent on the GitHub repo if not already  
3. Bind Bot “approve deploy” → optional remote action (else human runs Makefile)  
4. Optional: Slack/chat channel where the room can see Bot messages
