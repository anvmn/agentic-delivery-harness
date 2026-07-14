---
name: e2e-test
description: Create end-to-end tests for a feature module. Trigger when the user asks to write, create, or add e2e / integration / Playwright tests for any feature module, or to add test coverage for a new module.
---

<!-- Sanitized example from a production Elm SPA + CMS-backend health app.
     Adapt module names, paths, and the helper template to your codebase.
     The structure — read-source-first, all-artifacts coverage, canonical
     template, branch discipline — is the transferable part. -->

# E2E Test Skill

Guides the creation of correct end-to-end tests for `{app}`. The app has non-obvious behaviors (conditional UI, role differences, offline sync) that cause plausible-looking tests to fail — or worse, to pass while covering nothing.

## Step 1: Mandatory pre-work — read the source

Before writing ANY test code, read the source files that define the module's behavior (replace `{Module}` with the target):

1. `src/{Module}/logic` — which steps/activities exist, and for which variant of the flow
2. `src/{Module}/view` — form structures, selectors, conditional rendering
3. `src/{Module}/rules` — validation, conditional fields, what unlocks what
4. `src/backend/{Module}/model` — the backend record types this module creates

Also check **role differences**: search for the role-branching predicate (ours is `isChw`) to learn which roles can access the flow — it determines login, navigation, and copy.

Tests assert on what the source defines — not on what the DOM happened to show today.

## Step 2: Analyze before writing

Determine, in writing, before any code:

- Which **roles** can run this flow?
- What **steps/activities** exist, and which are **conditional** (age, gender, prior data, abnormal values)?
- What **backend records** does each step create?

### The all-artifacts rule

List **every** backend record type the module defines. Design one test whose inputs trigger the creation of **all of them** (choose form values that activate the conditional paths), and after the full round-trip — including offline→online sync if the app has it — assert that **each record exists**. A test that verifies one record out of nine "passes" while sync silently loses the other eight.

**Caveat:** before declaring a coverage gap, check whether the record's trigger is *permanently disabled* in the source (a condition that returns `false` unconditionally — deprecated features do this). Those are excluded from coverage analysis, with a comment saying why.

## Step 3: Branch discipline

One test module = one feature branch:

```bash
git checkout -b e2e-tests-{module} {base-branch}
```

Ask which base branch before creating it.

## Step 4: Helper file from the canonical template

Create `e2e/helpers/{module}.ts` by **copying the structure of the canonical template** (`e2e/helpers/ncd.ts` in our repo — pick your own best existing helper and name it here). Section order: imports → private form helpers (copied, not imported across modules) → entity creation → one exported function per step → navigation → sync helper → backend verification query.

Key rules:

- **Copy, don't import** form helpers across modules — cross-module imports couple unrelated tests and break in bulk.
- The **sync helper** waits for the app's real sync signal, not a timeout.
- The **backend verification** queries the backend directly (we use a drush/CLI bridge) — the UI saying "saved" is not evidence.

## Step 5: Run it the way CI runs it

```bash
npx playwright test              # headless — must pass before the PR
RECORD=1 npx playwright test     # headed + video — attach to the PR for reviewers
```

Deep reference (accounts, device lifecycle, selector quirks, troubleshooting): `references/e2e-knowledge-base.md` — keep such depth there, not here.
