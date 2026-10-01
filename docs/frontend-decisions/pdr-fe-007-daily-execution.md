# PDR-FE-007: Daily execution and history

- **Status:** Planned; UX reference pending
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

**UX reference: pending.** Need child/adult modes, completion feedback, empty
execution, finalize confirmation, history, and correction affordances.

## Contract and exclusions

[Daily execution API](../backend-api/daily-execution.md). No manual execution
items, offline merge, scheduler, rewards, streaks, or notifications.
