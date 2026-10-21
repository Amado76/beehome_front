# PDR-FE-006: Routines and daily planning

- **Status:** Daily and recurring task creation implemented; full routine management planned
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

### Implementation progress — 2026-10-03

The family home lets OWNER/ADMIN create a daily planning item for the selected
profile and family-local date. Before creation, the repository reads all daily
items, including inactive items, to choose the next sort order. Creation is
followed by explicit execution synchronization; completion remains owned by
execution snapshots. Ambiguous creation requires reconciliation and user
review before another write. Routine configuration, planning notes, item
editing/state changes/reordering, and resolved-plan/calendar screens remain
planned workflows.

### Task creation update — 2026-10-20

The task form supports multiple active profiles, with the current profile selected
initially, and an optional “Repeat daily” checkbox. One-off tasks create a daily
item per selected profile. Repeating tasks create one routine covering all seven
weekdays, starting on the current local date without an end date, and one routine
item per profile. Additional profile pages can be loaded from the form.
Saving synchronizes today's execution for every selected profile before closing
the form and updates the currently displayed execution from the sync response.

Assignments are separate API writes. The open form keeps successful assignments
and the routine ID so retrying a confirmed failure resumes remaining writes.
Inputs stay fixed during this retry. Ambiguous writes block resubmission and
synchronize all selected profiles for review; confirming review closes the form.
The user must check the profiles before separately creating missing assignments.

**UX reference: pending.** Need calendar/date navigation, routine editor,
assignment, ordering controls, time entry, and visual distinction between
planned and completed activities.

## Contract and exclusions

[Planning API](../backend-api/planning.md). No future-plan generation, RRULE,
holiday logic, reminders, execution, or history.
