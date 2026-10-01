# PDR-FE-005: Family member profiles

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-03 and current Family Members API contract
- **Depends on:** PDR-FE-004 family workspace

## Outcome

Represent adults and children as family profiles independent of login accounts.
Keep profile IDs stable for routines, study, reading, photos, and history.

## Scope and implementation plan

1. Add typed profile/page models and API methods, preserving PATCH
   omitted-versus-null semantics.
2. Implement paginated list/filter, detail, and role-aware controls.
3. Implement create/edit for name, type, birth date, color, and supported
   preferences such as `completedTaskColor`.
4. Implement reversible deactivate/reactivate and self-link/unlink flows with
   conflict reconciliation.

## Acceptance criteria

- Adults/children can exist without linked accounts; account linking does not
  grant family access.
- Dates remain date-only; completion colors map to semantic UI colors and never
  become the only state cue.
- Inactive profiles remain available for historical reads; there is no
  hard-delete action.
- PATCH omission preserves fields; explicit null is sent only for documented
  nullable values.
- Cross-family IDs, role failures, link conflicts, and pagination follow the API
  contract.

## UX and open decisions

**UX reference: pending.** Need list/detail, adult/child distinction, color
selection, inactive management, and account-linking flows. Avatar is read-only
and null in the current contract; do not add upload UI yet.

## Contract and exclusions

[Family members API](../backend-api/family-members.md). No child login,
invitations, arbitrary other-user linking, family relationships, or hard delete.
