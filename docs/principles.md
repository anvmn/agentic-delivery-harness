# The Seven Principles

The harness exists to answer one question: **how do you let agents write nearly all of your production code without lowering the quality bar?** After a year and ~600 merged agent-co-authored commits on a system where correctness matters (offline-first health data in rural clinics), these are the principles that survived contact with reality.

---

## 1. Spec before agent

Nothing goes to an agent without a written spec — even a small one. The spec template ([`templates/spec.md`](../templates/spec.md)) has seven sections, but two do most of the work:

- **Acceptance criteria** — observable statements a reviewer can check. "Works correctly" is not a criterion; "a CHW sees the referral step when the muac value is red-flagged" is.
- **Out of scope** — the single best defense against an eager agent "improving" adjacent code. Rework drops sharply when the fence is explicit.

A spec is also the unit of decomposition: if it doesn't fit on roughly a page, it's two specs. One spec → one branch → one PR keeps agent sessions short-lived and reviewable.

## 2. The repo teaches the agent

`CLAUDE.md` is an onboarding document for a competent stranger who forgets everything between sessions. Ours follows a strict priority order (see [`claude-md/CLAUDE.md.annotated`](../claude-md/CLAUDE.md.annotated)):

1. **Commands first** — build, test, lint, deploy. The agent uses these dozens of times per session; they must be copy-paste correct, including the container prefix (`ddev …`).
2. **Architecture map** — where things live and which module owns what, so the agent reads the right five files instead of grepping the world.
3. **Conventions that bite** — only the rules a reviewer would actually flag. Ours include: union type variants and case branches in alphabetical order; translation fields fall back to English at runtime so identical translations stay `Nothing`; no `Debug.log` in commits; which generated files must never be committed.

The test for every line in `CLAUDE.md`: *has its absence ever caused a bad diff?* If not, cut it. Bloated context files get skimmed — by humans and agents alike.

## 3. Gates, not vibes

Agent output is **untrusted input** until it clears the gates. The gates are mechanical (hooks and CI), not aspirational (a paragraph asking the agent to "always test"):

- **Verify-after-edit** — a hook runs the fast checks (compile, format, focused tests) after source edits, so the agent gets feedback in-session instead of at PR time.
- **Commit gate** — a hook blocks `git commit` while the working tree fails verification.
- **CI is the same gates, remotely** — nothing merges on green-local alone.

The point of hooks over instructions: instructions compete with everything else in context; exit codes don't. See [`hooks/`](../hooks/).

## 4. Privilege separation

The release runbook marks every step:

- 🟢 **Agent runs** — git preflight, builds, auth checks, tag math, changelog generation, creating the GitHub release. Safe, reversible, non-interactive.
- 🔴 **Human runs** — the two commands that move code toward production (deploy to Dev, promote Test → Live). A human reviews the change-set and confirms.

Two supporting patterns make this work in practice:

- **Tee-to-log**: the human runs the red command piped through `tee /tmp/deploy.log`, and the agent *reads the log* to learn the outcome — no "can you paste the output" round-trips, no misremembered error messages.
- **One target per run**: a release run touches exactly one site/environment. Multi-target releases are separate runs. Blast radius stays bounded and the transcript stays auditable.

## 5. Verify behavior, not diffs

Code review catches bad code; it does not catch *plausible code that doesn't do the thing*. The behavioral gate is end-to-end tests (Playwright, in our case), and the test-design rule matters more than the framework:

> **Cover every artifact the feature creates.** List every backend content type / record / side effect the module defines, then design one test whose inputs trigger all of them, and verify each exists after the full round-trip (including sync). A test that checks one artifact out of nine "passes" while the other eight silently break.

Two corollaries from production scars: check whether an apparently-missing artifact is *permanently disabled* in the source before calling it a coverage gap; and when writing tests for a module, **read the source first** — the example skill mandates reading five specific source files before writing a line of test code, because the UI's behavior (conditional activities, role differences) is defined there, not in the DOM you happen to see.

Recorded test runs (`RECORD=1` → video) double as review artifacts for humans.

## 6. Leave the audit trail on

Keep the `Co-Authored-By: Claude <model>` trailers. Keep the "Generated with Claude Code" notes in PR bodies. Resist the urge to launder the history.

Three reasons:

- **Honesty scales.** Reviewers know what they're reviewing; future maintainers know what they're maintaining.
- **You can measure yourself.** Because the trailers were on, I could later audit my own year — exactly which commits were agent-authored, per month, per model, and what happened to throughput (~4×) when the workflow changed. Claims with receipts beat claims.
- **It's the professional default.** The industry is converging on disclosure; being ahead of it costs nothing today and buys trust tomorrow.

## 7. Skills are runbooks that run

Operational knowledge (how we release, how we write E2E tests for a new module) lives in **skill files** — versioned markdown runbooks in `.claude/skills/`, tracked in git next to the code they operate:

- One concern per skill; a skill that needs a sibling links to it rather than absorbing it.
- A skill states its **execution model** up front (the 🟢/🔴 split from principle 4).
- Stable domain knowledge that would bloat the runbook goes in a linked `references/` file — the runbook stays scannable.
- The **canonical-template rule**: when a skill produces new code (test helpers, modules), it names one existing file as the canonical template to copy from, instead of describing the pattern in prose. Prose drifts; a named file doesn't.

The alternative — wikis and veterans' heads — rots, and agents can't read either one.

---

*These principles are extracted from real usage on [eheza-app](https://github.com/TIP-Global-Health/eheza-app) and sibling projects; the example skills in this repo are sanitized versions of that project's live runbooks.*
