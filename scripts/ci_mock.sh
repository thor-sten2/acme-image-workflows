#!/usr/bin/env bash
# Mock CI gate: boundary allowlist + unit tests. Fail-closed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ALLOWLIST_FILE="${ALLOWLIST_FILE:-$ROOT/allowlist.txt}"
BASE_REF="${BASE_REF:-}"

echo "==> ci_mock: Acme image workflows"
echo "    root: $ROOT"

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "ERROR: allowlist missing: $ALLOWLIST_FILE" >&2
  exit 1
fi

# Bash 3.2 compatible (macOS /bin/bash): build ALLOWED array without mapfile.
ALLOWED=()
while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    ''|\#*) continue ;;
  esac
  # trim trailing whitespace
  line="${line%"${line##*[![:space:]]}"}"
  [[ -n "$line" ]] && ALLOWED+=("$line")
done < "$ALLOWLIST_FILE"

if [[ ${#ALLOWED[@]} -eq 0 ]]; then
  echo "ERROR: allowlist is empty (fail-closed)" >&2
  exit 1
fi

collect_changed() {
  if [[ -n "$BASE_REF" ]] && git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    git diff --name-only "$BASE_REF"...HEAD
    return
  fi
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    {
      git diff --name-only HEAD
      git diff --name-only --cached
      git ls-files --others --exclude-standard
    } | sort -u
  else
    find . -type f \
      ! -path './.git/*' \
      ! -path './.venv/*' \
      ! -path './diffusers/*' \
      ! -path './.pytest_cache/*' \
      ! -path '*/__pycache__/*' \
      ! -path '*.egg-info/*' \
      ! -path './.demo_*' \
      ! -name '.DS_Store' \
      | sed 's|^\./||' | sort -u
  fi
}

# Ignore local tooling / build noise even if present as untracked.
is_ignored_noise() {
  local path="$1"
  case "$path" in
    .venv|.venv/*) return 0 ;;
    .pytest_cache|.pytest_cache/*) return 0 ;;
    *__pycache__*|*.pyc) return 0 ;;
    *.egg-info|*.egg-info/*|*/*.egg-info/*) return 0 ;;
    .demo_deploy_approved|.demo_deploy_status) return 0 ;;
    .DS_Store) return 0 ;;
  esac
  # egg-info directories anywhere
  if [[ "$path" == *".egg-info/"* || "$path" == *".egg-info" ]]; then
    return 0
  fi
  return 1
}

is_allowed() {
  local path="$1"
  local prefix
  for prefix in "${ALLOWED[@]}"; do
    if [[ "$path" == "$prefix" || "$path" == "$prefix"* ]]; then
      return 0
    fi
  done
  return 1
}

CHANGED="$(collect_changed || true)"
VIOLATIONS=()

if [[ -z "${CHANGED}" ]]; then
  echo "    no changed files detected (ok)"
else
  echo "    checking changed paths against allowlist..."
  while IFS= read -r path || [[ -n "$path" ]]; do
    [[ -z "$path" ]] && continue
    if is_ignored_noise "$path"; then
      continue
    fi
    if [[ "$path" == diffusers || "$path" == diffusers/* ]]; then
      VIOLATIONS+=("$path")
      continue
    fi
    if ! is_allowed "$path"; then
      VIOLATIONS+=("$path")
    fi
  done <<< "$CHANGED"
fi

if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  echo "ERROR: boundary violations (fail-closed):" >&2
  for v in "${VIOLATIONS[@]}"; do
    echo "  - $v" >&2
  done
  echo "Allowed prefixes are listed in allowlist.txt" >&2
  exit 1
fi
echo "    boundary: OK"

echo "    static self-check: Diffusers public API only..."
PRIVATE_HITS="$(grep -RInE \
  --include='*.py' \
  -e 'from[[:space:]]+diffusers\.[A-Za-z0-9_.]*import[[:space:]]+_' \
  -e 'import[[:space:]]+diffusers\.[A-Za-z0-9_.]*\._' \
  -e 'diffusers\.utils\.dummy' \
  src/acme_image_workflows 2>/dev/null || true)"
if [[ -n "$PRIVATE_HITS" ]]; then
  echo "$PRIVATE_HITS" >&2
  echo "ERROR: private/deprecated Diffusers import pattern found" >&2
  exit 1
fi

DIRECT_HITS="$(grep -RInE \
  --include='*.py' \
  -e '^\s*(from|import)[[:space:]]+diffusers' \
  src/acme_image_workflows/workflows 2>/dev/null || true)"
if [[ -n "$DIRECT_HITS" ]]; then
  echo "$DIRECT_HITS" >&2
  echo "ERROR: workflows must use client.py, not import diffusers directly" >&2
  exit 1
fi
echo "    static self-check: OK"

echo "    running unit tests..."
if [[ -x "$ROOT/.venv/bin/pytest" ]]; then
  "$ROOT/.venv/bin/pytest" -q
elif command -v pytest >/dev/null 2>&1; then
  pytest -q
else
  python3 -m pytest -q
fi

echo "==> ci_mock: PASS"
exit 0
