# PDR-FE-012: Calendar, history, and reports

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-09 and current Calendar/History/Reports API contract
- **Depends on:** source features PDR-FE-007–011; tags in PDR-FE-013 classify only

## Outcome

Provide a read-only view of a child's activity across supported domains using
lightweight calendar flags, daily detail, period totals, and on-demand PDF
export. This is a live aggregate, not a second write model.

## Scope and implementation plan

1. Add typed calendar/day/history/report DTOs and binary PDF download support.
2. Implement month calendar and paginated date history.
3. Implement selected-day detail for execution, study, extracurricular,
   reading, and photo metadata.
4. Implement inclusive period selection, report totals, and PDF download with
   bounded error handling.

## Acceptance criteria

- Empty days/months/pages are successful states, not missing-resource errors.
- Normal calendar/history reads do not download media bytes.
- Period dates are explicit and inclusive; family-date semantics are preserved.
- Official totals use subject/activity IDs; tags do not define totals and
  overlapping tag buckets are never summed as unique totals.
- PDF uses the authorized backend response; no screenshot, WebView, or
  client-rendered report is used.
- Busy/too-large PDF responses do not trigger rapid automatic retry.

## UX and open decisions

**UX reference: pending.** Need calendar navigation, date/detail composition,
period picker, source grouping, report hierarchy, and PDF entry point.

## Contract

[Calendar, history, and reports API](../backend-api/calendar-history-reports.md).
Source modules remain owners of records and domain rules.
