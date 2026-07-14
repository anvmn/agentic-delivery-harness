# Pre-merge review checklist

<!-- The human gate. Order matters: correctness first — it's the review's job;
     style last — it's the linter's job. Adapt the specifics; keep the order. -->

## Correctness (against the spec, not the diff)

- [ ] Every acceptance criterion demonstrably met — walked through, not assumed
- [ ] Negative criteria hold (what must not happen, doesn't)
- [ ] Edge cases of the domain logic: boundaries, empty states, both roles/variants
- [ ] Conditional logic matches the source of truth (the spec / the referenced
      module), not a plausible reading of it
- [ ] Concurrency/offline paths: what happens mid-sync, on retry, on stale data

## Security

- [ ] New endpoints/queries enforce the same access checks as their siblings
- [ ] No secrets, tokens, or internal hostnames in code, config, or tests
- [ ] User input reaching queries/markup is sanitized the way the codebase does it

## Performance

- [ ] No unbounded queries/loops over production-sized data
- [ ] Payload/bundle impact acceptable (check the build report if the diff is big)
- [ ] Hot paths unchanged unless the spec said otherwise

## Conventions & hygiene

- [ ] Project conventions hold (the CLAUDE.md list — ordering, translations, etc.)
- [ ] No debug artifacts (`Debug.log`, `console.log`, commented-out code)
- [ ] No generated/local files in the diff
- [ ] Tests assert behavior, not implementation details; E2E covers all
      artifacts the feature creates (the all-artifacts rule)

## The trail

- [ ] PR body says how it was verified (commands + outcomes), with recording if UI
- [ ] Co-author trailers intact
- [ ] Risk & rollback section filled in
