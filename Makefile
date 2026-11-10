.PHONY: help install test ci_mock deploy_mock approve_deploy clean

TICKET ?=
APPROVE ?=

help:
	@echo "Acme image workflows"
	@echo "  make install          Create .venv and install package + pytest"
	@echo "  make test             Run unit tests"
	@echo "  make ci_mock          Boundary allowlist + static checks + tests"
	@echo "  make approve_deploy TICKET=ACME-N   Write local approval file"
	@echo "  make deploy_mock TICKET=ACME-N [APPROVE='approve deploy ACME-N']"
	@echo "  make clean            Remove venv caches and demo markers"

install:
	python3 -m venv .venv
	.venv/bin/pip install -U pip
	.venv/bin/pip install -e ".[dev]"

test:
	@if [ -x .venv/bin/pytest ]; then .venv/bin/pytest -q; else python3 -m pytest -q; fi

ci_mock:
	bash scripts/ci_mock.sh

approve_deploy:
	@if [ -z "$(TICKET)" ]; then echo "Set TICKET=ACME-N"; exit 1; fi
	@echo "approve deploy $(TICKET)" > .demo_deploy_approved
	@echo "Wrote .demo_deploy_approved for $(TICKET)"

deploy_mock:
	@if [ -z "$(TICKET)" ]; then echo "Set TICKET=ACME-N"; exit 1; fi
	@if [ -n "$(APPROVE)" ]; then \
		bash scripts/deploy_mock.sh --ticket "$(TICKET)" --approve "$(APPROVE)"; \
	else \
		bash scripts/deploy_mock.sh --ticket "$(TICKET)"; \
	fi

clean:
	rm -rf .venv .pytest_cache src/*.egg-info *.egg-info
	rm -f .demo_deploy_approved .demo_deploy_status
	find . -type d -name __pycache__ -not -path './diffusers/*' -prune -exec rm -rf {} +
