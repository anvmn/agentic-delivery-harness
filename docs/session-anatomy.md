# Anatomy of a Feature

A composite walkthrough of one real-shaped feature moving through the harness — from request to merged PR. Details are generalized from a digital-health app (Elm SPA + CMS backend + Playwright E2E), but every step is the actual workflow.

**The request:** *"Add a follow-up question to the nutrition encounter: if the child's MUAC measurement is in the red zone, the health worker must record a referral decision. The referral must reach the backend."*

---

## 1. Spec (10 minutes, human)

Written with [`templates/spec.md`](../templates/spec.md). The load-bearing parts:

```markdown
## Acceptance criteria
- [ ] In a nutrition encounter, entering a MUAC value in the red zone reveals a
      "Referral decision" step; green/yellow values do not.
- [ ] The step blocks encounter completion until answered.
- [ ] Completing the encounter creates a `nutrition_referral` record on the
      backend, linked to the encounter, surviving a full offline→online sync.
- [ ] Works for both roles (nurse, CHW); CHW copy uses the simplified wording.

## Out of scope
- Reporting/statistics on referrals (separate spec).
- Backfilling historical encounters.
- Any change to the MUAC zone thresholds themselves.

## Verification plan
- elm-test for the zone→step visibility logic.
- One Playwright E2E: red-zone path, completes encounter, asserts the
  `nutrition_referral` node exists after sync (all-artifacts rule).
- RECORD=1 run attached to the PR.
```

Why it matters: the agent never has to guess what "done" means, and the out-of-scope fence pre-empts the classic failure mode ("while I was there, I also refactored the thresholds").

## 2. Decomposition (5 minutes, human + agent)

One spec → one branch → one PR. Inside the session, the work splits into agent-sized tasks:

1. Model + decoder/encoder changes (`Backend/NutritionActivity/`)
2. Activity step UI + completion logic (`Pages/Nutrition/Activity/`)
3. Backend content type + REST plugin
4. Translations (en + local languages, honoring the fallback rule)
5. E2E test via the `e2e-test` skill

Each task ends with the fast gates green before the next starts.

## 3. Agent sessions (the bulk of wall-clock, mostly unattended)

What the harness contributes while the agent works:

- **`CLAUDE.md` answers the repeatable questions** — the exact test commands, the alphabetical-ordering convention (this feature touches a union type; unordered variants would bounce in review), the translation fallback rule (identical translations stay `Nothing`).
- **The verify-after-edit hook** runs compile + focused tests after each source edit. The agent finds out about a decoder mismatch in-session, not in CI 20 minutes later.
- **The e2e-test skill** forces the read-source-first rule: before writing the Playwright test, the agent reads the five source files that define which activities exist, when the step is conditional, and what the backend content type is called. The test asserts on reality, not on the DOM it happened to see.

## 4. Gates

- Fast gates (hook): format check, compile, focused unit tests — every edit.
- Commit gate (hook): `git commit` refuses while verification fails.
- Full E2E locally: the new test runs the complete red-zone journey including sync, and asserts the backend record exists — because the sync layer is exactly where a "green diff" can still lose data.
- CI: the same checks, remotely, on the PR.

## 5. Human review (15 minutes)

Against [`templates/review-checklist.md`](../templates/review-checklist.md) — correctness first (does the conditional logic match the spec? are the zone boundaries off-by-one?), then security (role checks on the REST plugin), performance (no full-table scans in the new query), conventions (ordering, translations, no `Debug.log`).

The recorded E2E video makes the behavioral review a 90-second watch instead of a local checkout.

## 6. Merge — with the trail on

The PR body follows [`templates/pr-body.md`](../templates/pr-body.md): what/why, **how it was verified** (commands + outcomes, video attached), risk & rollback. Commits keep their `Co-Authored-By: Claude <model>` trailers.

Total human time: ~30 minutes. Total elapsed: an afternoon, most of it unattended. Quality bar: unchanged — that's the whole point of the harness.
