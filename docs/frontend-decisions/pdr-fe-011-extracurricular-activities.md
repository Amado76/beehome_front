# PDR-FE-011: Extracurricular activities

- **Status:** Planned; UX reference pending
- **Backend source:** Extracurricular Activities API and activity portion of PDR-09
- **Depends on:** PDR-FE-004/005; PDR-FE-013 tags; contributes to PDR-FE-012 reports

## Outcome

Let a family maintain an official activity catalog and record dated
extracurricular occurrences for a child. Official activity identity is an ID;
a free-form tag with the same name is a separate concept.

## Scope and implementation plan

1. Add catalog/occurrence models and API services.
2. Implement catalog management and active activity selection.
3. Implement occurrence create/edit/delete with supported detail fields.
4. Implement date-range history and refresh the daily/report views after writes.

## Acceptance criteria

- New occurrences reference an active official activity by ID.
- Inactive catalog entries remain available for historical display but cannot be
  selected for new occurrences.
- Catalog permissions and occurrence permissions follow their distinct API
  rules.
- Uncertain creates reconcile through dated history; updates/deletes reload
  after concurrency or ambiguous outcomes.
- Official totals group by activity ID; tags never change those totals.

## UX and open decisions

**UX reference: pending.** Need catalog management, occurrence entry, detail
fields, and visual distinction between official activities and tags.

## Contract

[Extracurricular activities API](../backend-api/extracurricular-activities.md).
