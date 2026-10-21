# PDR-FE-007: Daily execution and history

- **Status:** Today's dashboard checklist implemented; history and correction workflows planned
- **Backend source:** PDR-05 and current Daily Execution API contract
- **Depends on:** PDR-FE-006 planning and PDR-FE-005 profiles

## Outcome

Record what happened against a daily plan using backend-created snapshots.
Historical reads never reconstruct past execution from today's plan.

## Scope and implementation plan

1. Add execution/history DTOs and explicit state-transition methods.
2. Implement today's materialization, loading/reopen state, and server refresh.
3. Implement complete/uncomplete using returned execution item IDs.
4. Add paginated history and OWNER/ADMIN finalize/reopen actions.

## Acceptance criteria

- Client does not create missing historical days or future executions.
- Uncertain state commands reconcile against current execution before retry.
- Finalized snapshots remain fixed until authorized reopen; reopening does not
  silently synchronize current planning.
- Completion is never inferred from plan data; inactive members' existing
  history remains readable.
- Family-local date rules and backend authorization are respected.

## UX and open decisions

### Implementation progress — 2026-10-03

The family home reads today's execution for the selected profile and materializes
it when absent. Explicit refresh synchronizes the current day. Completion and
undo use execution item IDs and returned snapshots; failures reload authoritative
state. Cancelled items are hidden from the active checklist/count, and finalized
executions disable edits. Day rollover, resume, and profile switches invalidate
older requests. History, finalize/reopen controls, and calendar navigation remain
planned workflows.

**UX reference: pending.** Need child/adult modes, completion feedback, empty
execution, finalize confirmation, history, and correction affordances.

## Contract and exclusions

[Daily execution API](../backend-api/daily-execution.md). No manual execution
items, offline merge, scheduler, rewards, streaks, or notifications.
