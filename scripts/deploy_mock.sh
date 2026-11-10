#!/usr/bin/env bash
# Mock deploy: requires human approval phrase. No real production deploy.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RED=$'\033[0;31m'
GRN=$'\033[0;32m'
YLW=$'\033[0;33m'
NC=$'\033[0m'

fail() { echo "${RED}deploy_mock FAIL:${NC} $*" >&2; exit 1; }
ok()   { echo "${GRN}deploy_mock OK:${NC} $*"; }
info() { echo "${YLW}deploy_mock:${NC} $*"; }

APPROVAL_FILE="${APPROVAL_FILE:-$ROOT/.demo_deploy_approved}"
STATUS_FILE="${STATUS_FILE:-$ROOT/.demo_deploy_status}"
TICKET=""
APPROVE_ARG=""
SKIP_CI=0

usage() {
  cat <<'EOF'
Usage:
  scripts/deploy_mock.sh ACME-N
  scripts/deploy_mock.sh --ticket ACME-N [--approve "approve deploy ACME-N"]

Fail-closed: requires exact human approval phrase "approve deploy ACME-N"
(via --approve or .demo_deploy_approved). Re-runs ci_mock unless --skip-ci.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ticket)
      TICKET="${2:-}"; shift 2 ;;
    --approve)
      APPROVE_ARG="${2:-}"; shift 2 ;;
    --approval-file)
      APPROVAL_FILE="${2:-}"; shift 2 ;;
    --skip-ci)
      SKIP_CI=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    ACME-*)
      TICKET="$1"; shift ;;
    *)
      fail "Unknown arg: $1 (see --help)" ;;
  esac
done

[[ -n "$TICKET" ]] || fail "ticket required (e.g. ACME-1). See --help"
[[ "$TICKET" =~ ^ACME-[0-9]+$ ]] || fail "ticket must look like ACME-N, got: $TICKET"

expected_phrase="approve deploy ${TICKET}"
approved=0

if [[ -n "$APPROVE_ARG" ]]; then
  if [[ "$APPROVE_ARG" == "$expected_phrase" ]]; then
    approved=1
    info "approval phrase matched"
  else
    fail "approval phrase mismatch (expected: $expected_phrase)"
  fi
elif [[ -f "$APPROVAL_FILE" ]]; then
  # Accept exact phrase line, or legacy "approved:ACME-N" from earlier drafts.
  if grep -Fxq "$expected_phrase" "$APPROVAL_FILE" \
    || grep -Fxq "approved:${TICKET}" "$APPROVAL_FILE"; then
    approved=1
    info "approval file matched: $APPROVAL_FILE"
  else
    fail "$APPROVAL_FILE missing phrase: $expected_phrase"
  fi
fi

[[ "$approved" -eq 1 ]] || fail "human approval required. Run: make approve_deploy TICKET=$TICKET"

if [[ "$SKIP_CI" -eq 0 ]]; then
  info "re-running ci_mock before deploy"
  bash "$ROOT/scripts/ci_mock.sh" || fail "ci_mock must pass before deploy"
fi

[[ -d "$ROOT/src/acme_image_workflows" ]] || fail "package missing; refusing deploy"

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
{
  echo "status=mock_deployed"
  echo "ticket=$TICKET"
  echo "deployed_at=$ts"
  echo "note=No real production deploy; local demo marker only."
} > "$STATUS_FILE"

ok "mock-deployed $TICKET at $ts"
ok "status written to $STATUS_FILE"
cat "$STATUS_FILE"
exit 0
