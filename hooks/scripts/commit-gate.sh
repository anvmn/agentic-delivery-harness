#!/usr/bin/env bash
# commit-gate.sh — PreToolUse hook for the Bash tool.
# Reads the tool-call JSON on stdin; when the command is a `git commit`,
# runs the full verification and blocks the commit (exit 2) if it fails.
# Exit 0  -> allow the tool call
# Exit 2  -> block the tool call; stderr is shown to the agent

set -u

INPUT="$(cat)"

# Extract the shell command from the hook payload (jq if available).
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  CMD="$(printf '%s' "$INPUT" | grep -o '"command"[^,}]*' | head -1)"
fi

case "$CMD" in
  *"git commit"*) ;;
  *) exit 0 ;;   # not a commit — allow
esac

DIR="$(cd "$(dirname "$0")" && pwd)"
if ! "$DIR/verify.sh"; then
  echo "commit blocked: verification is red. Fix the failures, then commit." >&2
  exit 2
fi
exit 0
