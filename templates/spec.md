# Spec: {feature name}

<!-- One spec = one branch = one PR. If this doesn't fit on ~a page, split it. -->

## Goal

{One or two sentences: the user-visible outcome, not the implementation.}

## Context

{Why now; links to the issue/conversation; any prior art in the codebase the
implementation should follow (name specific files — "like X.elm does" beats a
paragraph of description).}

## Constraints

{Hard boundaries: performance budgets, backwards compatibility, offline
behavior, roles/permissions, regulatory. Only real ones — an empty section is
honest.}

## Acceptance criteria

<!-- Observable statements a reviewer can check. "Works correctly" is not a
     criterion. Include the negative cases (what must NOT happen). -->

- [ ] {criterion}
- [ ] {criterion}
- [ ] {negative criterion — the thing that must not change/happen}

## Verification plan

<!-- How each criterion gets checked: which unit tests, which E2E journey,
     what gets recorded. The all-artifacts rule: if the feature creates N
     backend records/side effects, the E2E must assert all N. -->

- {unit tests: what logic}
- {E2E: which journey, which artifacts asserted after full round-trip}
- {manual/recorded check, if any}

## Out of scope

<!-- The fence. The single best defense against scope creep — the agent's and
     yours. Be explicit about tempting adjacencies. -->

- {explicitly not doing X}
- {not touching Y}

## Rollback

{How this is turned off/reverted if it misbehaves in production: feature flag,
revert commit, data cleanup — one line each.}
