# PDR-FE-005: Family member profiles

- **Status:** Dashboard list/create/edit slice implemented; remaining management planned
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

### Implementation progress — 2026-10-03

The family home now lists active profiles with pagination and shared selection
between avatars and task filters. OWNER/ADMIN can create/edit name, member type,
birth date, and profile color. Editing also supports the independent
`completedTaskColor` preference; creation does not send unsupported preferences.
Avatars use local Flutter placeholders because the API supplies no avatar asset.
Inactive-profile management and self-link/unlink remain planned workflows.
See the [family home plan](pdr-fe-004-family-workspace.md).

**UX reference: pending.** Need list/detail, adult/child distinction, color
selection, inactive management, and account-linking flows. Avatar is read-only
and null in the current contract; do not add upload UI yet.

## Contract and exclusions

[Family members API](../backend-api/family-members.md). No child login,
invitations, arbitrary other-user linking, family relationships, or hard delete.
