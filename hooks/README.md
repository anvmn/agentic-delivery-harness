# Hooks: gates, not vibes

Instructions compete with everything else in the agent's context; **exit codes don't**. These hooks make the quality gates mechanical.

## What's here

- [`settings.example.json`](settings.example.json) — Claude Code hooks configuration wiring the two gates below. Copy into your repo as `.claude/settings.json` (or merge into an existing one).
- [`scripts/verify.sh`](scripts/verify.sh) — stack-detecting verification: runs the checks that exist in your repo (Elm format/tests, PHP codesniffer, JS/TS tests). `--fast` runs the cheap subset suitable for after-every-edit; the full run is for the commit gate.
- [`scripts/commit-gate.sh`](scripts/commit-gate.sh) — a `PreToolUse` hook that intercepts `git commit` and blocks it (exit 2) while `verify.sh` fails.

## The two gates

1. **Verify-after-edit** (`PostToolUse` on `Edit|Write`): after each source-file edit, the fast checks run and their failures land back in the agent's context immediately. The agent fixes a decoder mismatch in-session — not in CI twenty minutes later, not in review the next morning.

2. **Commit gate** (`PreToolUse` on `Bash`): when the agent tries to `git commit`, the full verification runs first. Red tree → the commit is refused with the failure output. The agent cannot "commit now, fix later" — because *later* is when a human is reading the PR.

## Adapting

`verify.sh` auto-detects: `elm.json` / `client/elm.json` (elm-format, elm-test), `composer.json` (phpcs if configured), `package.json` (test script). Add your stack's checks in the marked section — keep the `--fast` subset genuinely fast (< ~15s), or the after-edit loop becomes friction and you'll be tempted to turn it off. The gate you turn off protects nothing.
