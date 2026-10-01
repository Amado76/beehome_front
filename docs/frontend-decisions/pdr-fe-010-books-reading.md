# PDR-FE-010: Books and reading

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-08
- **Depends on:** PDR-FE-004/005; optional PDR-FE-009 covers; PDR-FE-013 tags

## Outcome

Provide a reusable family book catalog, an independent reading journey for each
child, and dated reading records. Reuse creates a new journey, not a duplicate
catalog entry.

## Scope and implementation plan

1. Add typed book, journey, session, page, and summary models/services.
2. Implement family catalog search/reuse/create and optional cover references.
3. Implement child journey lifecycle and API-derived progress.
4. Implement reading session entry/history, editing, and summary.

## Acceptance criteria

- Catalog search is family-scoped and includes books not yet assigned to the
  target child.
- Reusing a book creates a separate child journey and retains one family Book.
- Journey status and completion dates are explicit; sessions do not infer them.
- Progress appears only when returned by the API; page totals follow backend
  reread/overlap semantics.
- Uncertain creates reconcile through lists; uncertain edits reload current
  data before retrying.

## UX and open decisions

**UX reference: pending.** Need catalog search/no-results, reuse-versus-create,
journey lifecycle, reading entry form, covers, and progress presentation. No
external catalog or ISBN lookup is included.

## Contract

[Books and reading API](../backend-api/books-reading.md).
