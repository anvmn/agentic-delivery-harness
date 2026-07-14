#!/usr/bin/env bash
# verify.sh — stack-detecting verification gate.
#   --fast : cheap subset (format + compile-level checks) for after-edit hooks
#   (none) : full run (adds test suites) for the commit gate / CI parity
# Exit non-zero if any detected check fails. Silent-skip checks whose tools
# or configs are absent: the script adapts to the repo it lands in.

set -u

FAST=0
[ "${1:-}" = "--fast" ] && FAST=1

FAILED=0
run() {
  local label="$1"; shift
  echo "verify: ${label}"
  if ! "$@"; then
    echo "verify: FAIL — ${label}" >&2
    FAILED=1
  fi
}

# --- Elm ---------------------------------------------------------------
ELM_DIR=""
[ -f elm.json ] && ELM_DIR="."
[ -f client/elm.json ] && ELM_DIR="client"
if [ -n "$ELM_DIR" ]; then
  if command -v elm-format >/dev/null 2>&1; then
    run "elm-format --validate" elm-format --validate "$ELM_DIR/src/"
  fi
  if [ "$FAST" -eq 0 ] && command -v elm-test >/dev/null 2>&1; then
    ( cd "$ELM_DIR" && elm-test ) || { echo "verify: FAIL — elm-test" >&2; FAILED=1; }
  fi
fi

# --- PHP ---------------------------------------------------------------
if [ -f composer.json ] && [ -x vendor/bin/phpcs ]; then
  run "phpcs" vendor/bin/phpcs
fi

# --- JS / TS -----------------------------------------------------------
if [ -f package.json ] && [ "$FAST" -eq 0 ]; then
  if grep -q '"test"[[:space:]]*:' package.json; then
    run "npm test" npm test --silent
  fi
fi

# --- Your stack --------------------------------------------------------
# Add project-specific checks here. Keep --fast genuinely fast (<15s):
# [ "$FAST" -eq 1 ] && run "quick lint" your-fast-linter
# [ "$FAST" -eq 0 ] && run "integration tests" your-test-runner

if [ "$FAILED" -ne 0 ]; then
  echo "verify: RED — fix the failures above before committing." >&2
  exit 1
fi
echo "verify: green"
