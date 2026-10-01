# PDR-FE-006: Routines and daily planning

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-04 and current Planning API contract
- **Depends on:** PDR-FE-004 family workspace and PDR-FE-005 profiles

## Outcome

Let authorized adults configure recurring routines and date-specific content;
let family members view the resolved plan for a selected member and date.
Planning describes intent and has no completion state.

## Scope and implementation plan

1. Add typed models/API methods for routine pages/details and resolved days.
2. Implement routine, weekday, date-bound, item assignment, active state, and
   complete-set reorder management.
3. Implement per-member/per-date notes and daily item management.
4. Implement resolved day display and refresh after mutations, separate from
   execution state.

## Acceptance criteria

- Resolved plan includes only applicable active sources in documented order.
- Reads do not create plans; requests always use an explicit date.
- Family IANA timezone governs “today”; `YYYY-MM-DD` and family-local `HH:mm`
  are not treated as UTC instants.
- Reorders include the complete item set as required; uncertain writes reload
  before retry.
- No completion status is displayed or persisted by planning UI.

## UX and open decisions

**UX reference: pending.** Need calendar/date navigation, routine editor,
assignment, ordering controls, time entry, and visual distinction between
planned and completed activities.

## Contract and exclusions

[Planning API](../backend-api/planning.md). No future-plan generation, RRULE,
holiday logic, reminders, execution, or history.
