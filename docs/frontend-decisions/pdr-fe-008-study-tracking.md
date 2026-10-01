# PDR-FE-008: Study tracking

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-06 and study portion of PDR-09
- **Depends on:** PDR-FE-004/005; optional link to PDR-FE-007

## Outcome

Record study activities for adults or children independently of daily task
completion. Families manage official study subjects; sessions may be timed or
entered as completed manual records.

## Scope and implementation plan

1. Add subject/session/summary models and API methods.
2. Implement subject catalog, role-aware management, and subject selection.
3. Implement timer restoration via `/current` and start/pause/resume/finish.
4. Implement manual entry, history filters, authorized correction/void, and
   summary display.

## Acceptance criteria

- Backend remains authoritative for timer transitions, duration, and the
  family-local session date; client sends no timer ticks.
- Finishing a session never completes a daily execution item.
- Running/paused/completed/voided behavior and summary inclusion follow the API.
- Timer conflicts reload current/session state before another command.
- Optional execution links must refer to the same family and member; login is
  not required for the studied profile.

## UX and open decisions

**UX reference: pending.** Need timer/manual prominence, timer availability
during navigation, default fields, subjectless history, and summary presentation.
No curriculum or grading experience is implied.

## Contract and exclusions

[Study tracking API](../backend-api/study-tracking.md). No automatic task
completion, gradebook, curriculum, scoring, or abandoned-timer closure.
