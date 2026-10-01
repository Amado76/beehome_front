# PDR-FE-004: Family workspace

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-02 and current Families API contract
- **Depends on:** PDR-FE-003 authentication/session

## Outcome

Let an authenticated user create and access one or more family workspaces. The
user sees only accessible families, selects one as active context, and can edit
its name/timezone when their role allows it.

## Scope and implementation plan

1. Add typed family and page models plus API methods for list/create/read/PATCH.
2. Implement family selection, pagination, loading, empty, and error states.
3. Implement create/edit forms with role-aware controls and an IANA timezone
   selector. Never infer timezone from the device, IP, or account.
4. Persist selected family ID only as navigation preference; revalidate on
   session restoration and clear it on sign-out/account switch.

## Acceptance criteria

- Empty, single-family, and multiple-family accounts can enter a valid family.
- Stale/inaccessible selection is cleared safely; family ID is not treated as
  authorization.
- Creation sends a valid IANA timezone; migrated UTC is presented as a value to
  confirm, not a location inference.
- Only OWNER/ADMIN see edit affordances; backend 403/404 remains authoritative.
- Uncertain create/edit outcomes reload family state before another write.

## UX and open decisions

**UX reference: pending.** Need chooser, empty state, creation, timezone
selection, and settings references. Family creation quota remains a backend
rollout decision; do not invent a client quota.

## Contract and exclusions

[Families API](../backend-api/families.md). No invites, join-by-code,
membership/role management, ownership transfer, leave, deletion, or archival.
