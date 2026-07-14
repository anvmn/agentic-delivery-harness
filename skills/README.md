# Skills: runbooks that run

Operational knowledge — how you release, how you write E2E tests for a new module, how you rotate a credential — usually lives in a wiki that rots or a veteran's head that goes on vacation. **Skills** put it in versioned markdown files next to the code, where agents (and humans) execute it step by step.

A skill is a directory under `.claude/skills/<name>/` with a `SKILL.md` (frontmatter: `name`, `description` with explicit *trigger phrases*) and optionally a `references/` folder for stable deep knowledge.

## The conventions that make skills work

1. **One concern per skill.** A skill that needs a sibling links to it (`deploy-release` → shared `_deploy-common/reference.md`) rather than absorbing it. Absorption is how runbooks become unreadable.

2. **Execution model up front — the 🟢/🔴 split.** The first section states who runs what:
   - 🟢 **Agent runs**: safe, reversible, non-interactive steps (preflight, builds, auth *checks*, changelog generation).
   - 🔴 **Human runs**: production-affecting or judgment-requiring steps (the actual deploy, the promote-to-live).
   The agent drives the whole flow, pauses at red steps, and hands the human an exact command **tee'd to a log file** — then reads the log to learn the outcome, instead of asking for a paste.

3. **One target per run.** A release skill releases one site/environment per invocation. Bounded blast radius, auditable transcript.

4. **The canonical-template rule.** When a skill produces new code, it names one existing file as the template to copy (*"follow `e2e/helpers/ncd.ts`"*) instead of describing the pattern in prose. Prose drifts; a named file doesn't.

5. **Read-source-first for test-writing skills.** The skill lists the exact source files that define the behavior under test, and requires reading them *before* writing test code. Tests should assert on the source of truth, not on whatever the DOM looked like today.

6. **References for depth.** Stable domain knowledge (account tables, infrastructure quirks, troubleshooting) goes in `references/*.md`, linked from the runbook. The runbook stays scannable; the depth stays available on demand.

## The examples

Both examples in [`examples/`](examples/) are sanitized versions of live, git-tracked runbooks from a production digital-health project:

- [`e2e-test.SKILL.md`](examples/e2e-test.SKILL.md) — test authoring with the read-source-first rule and the all-artifacts coverage principle.
- [`deploy-release.SKILL.md`](examples/deploy-release.SKILL.md) — a production release with the 🟢/🔴 privilege split and tee-to-log pattern.

Adapt the *structure* even if your stack shares nothing with theirs — the structure is the point.
