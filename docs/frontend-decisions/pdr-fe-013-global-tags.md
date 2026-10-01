# PDR-FE-013: Global family tags

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-11 and current Global Tags API contract
- **Depends on:** PDR-FE-004 and each adopting feature

## Outcome

Provide reusable family labels that classify supported records without
replacing domain identity, status, time, or ownership. Tags are free-form; study
subjects and extracurricular activities remain separate catalogs.

## Scope and implementation plan

1. Add tag model/service and family-scoped paginated catalog.
2. Implement OWNER/ADMIN catalog create/rename/recolor/delete.
3. Add tag selection to each adopting feature using its documented request
   semantics for omitted and empty arrays.
4. Add filters only to collections that document tag filtering; multiple tags
   use AND semantics where supported.

## Acceptance criteria

- Tags and tag assignments are always scoped to the selected family.
- Resource permissions govern assignment; tag-management role rules govern the
  shared catalog.
- Rename preserves links; delete removes associations but preserves records.
- Invalid/cross-family tag sets fail atomically; client reloads after uncertain
  writes.
- Tags never alter official totals; no unsupported global search is exposed.

## UX and open decisions

**UX reference: pending.** Need catalog entry point, inline-create vs select,
starter suggestions, color, chip/list presentation, and explanation of AND
filtering.

## Contract

[Global family tags API](../backend-api/global-tags.md). Each feature owns its
association and mutation semantics; there is no global tag search.
