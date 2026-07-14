# Agentic Delivery Harness

**A production-grade harness for shipping real software through AI agents — extracted from a year of doing exactly that.**

I'm a tech lead at a small agency. Since February 2026, essentially all production code I ship is written by agents (Claude Code) under my direction: **~600 Claude-co-authored commits and 112 agent-built pull requests merged in five months** to a production digital-health platform used in rural Rwanda and Burundi — a registered [Digital Public Good](https://www.digitalpublicgoods.net/) — at roughly **4× my pre-agentic output**. The commit history is public: [github.com/anvmn](https://github.com/anvmn).

That throughput is not the interesting part. The interesting part is that the quality bar didn't move: same review standards, same E2E coverage, same production incident rate as before. This repo is the *how* — the harness of specs, gates, conventions, and runbooks that makes agent output safe to merge.

None of this is a framework. It's a set of files you copy into your repo and adapt. The agent doesn't get smarter; your project gets **more legible and more defended**, which turns out to be most of the game.

## What's inside

| Path | What it is |
|---|---|
| [`docs/principles.md`](docs/principles.md) | The seven principles the harness is built on — with the reasoning |
| [`docs/session-anatomy.md`](docs/session-anatomy.md) | One feature, end to end: spec → decomposition → agent sessions → gates → merge |
| [`claude-md/CLAUDE.md.annotated`](claude-md/CLAUDE.md.annotated) | An annotated `CLAUDE.md` template — what each section is *for*, with a real public example linked |
| [`templates/spec.md`](templates/spec.md) | The feature spec template agents implement from |
| [`templates/review-checklist.md`](templates/review-checklist.md) | The pre-merge review gates (correctness, security, performance, conventions) |
| [`templates/pr-body.md`](templates/pr-body.md) | PR description convention — including *how it was verified*, not just what changed |
| [`hooks/`](hooks/) | Claude Code hooks that enforce the gates mechanically (verify-after-edit, commit gate) |
| [`skills/`](skills/) | Skills-as-runbooks: executable operational knowledge, with a privilege split between what the agent runs and what a human runs |

## The short version

1. **Spec before agent.** A page of acceptance criteria beats a thousand tokens of clarification. The spec template forces the two questions that prevent most rework: *what does done look like* and *what is out of scope*.
2. **The repo teaches the agent.** `CLAUDE.md` is an onboarding document: commands first, an architecture map, and the conventions that bite. Everything the agent re-discovers per session is money and drift.
3. **Gates, not vibes.** Agent output is untrusted input until it passes compilation, tests, lint, and E2E. Hooks make the gates mechanical, not aspirational.
4. **Privilege separation.** The agent runs everything safe (build, test, preflight, release notes); a human runs the two commands that touch production. The runbook marks each step 🟢 or 🔴 and the agent reads outcomes from logs instead of asking for pastes.
5. **Verify behavior, not diffs.** A green diff that breaks sync is red. E2E tests must exercise *every* artifact the feature creates — the test-design rule in the example skill exists because a test that checks one node type out of nine "passes" while sync silently loses the other eight.
6. **Leave the audit trail on.** Keep `Co-Authored-By` trailers and generation notes in PR bodies. Six months later I could measure my own workflow — commit by commit, model by model — because the receipts were in the history.
7. **Skills are runbooks that run.** Deployment and test-writing knowledge lives in versioned skill files next to the code, not in a wiki that rots and not in one veteran's head.

Full reasoning in [`docs/principles.md`](docs/principles.md).

## Adopting this in your repo (30 minutes)

1. Copy `claude-md/CLAUDE.md.annotated` to your repo root as `CLAUDE.md`, delete the annotations, fill in the real commands and the three conventions that most often bite reviewers in *your* codebase.
2. Copy `templates/` somewhere visible (`docs/templates/` works). Write your first spec with it — for the smallest real feature on your backlog, not a toy.
3. Copy `hooks/settings.example.json` to `.claude/settings.json` and `hooks/scripts/verify.sh` to `scripts/`; adjust `verify.sh` to your stack (it auto-detects Elm / PHP / Node out of the box).
4. Run one feature through the whole pipeline before customizing anything else. The pipeline teaches you what your project actually needs.

## Origin

Extracted from the workflow behind [TIP-Global-Health/eheza-app](https://github.com/TIP-Global-Health/eheza-app) (Elm offline-first EMR, Drupal backend, Playwright E2E) and other production work at [Gizra](https://www.gizra.com/). The example skills in `skills/examples/` are sanitized versions of the real, git-tracked runbooks from that project.

This repo is itself built the way it preaches: through Claude Code, with the trailers on. Check the history.

## License

[MIT](LICENSE) — © Anatoly Vaitsman
