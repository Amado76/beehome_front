# PDR-FE-003: Authentication and session lifecycle

- **Status:** Accepted for initial implementation
- **Date:** 2026-09-30
- **Scope:** Client flows backed by BeeHome authentication APIs

## Context

The backend supports registration, email/password login, access/refresh token
rotation, logout of one session, current-user retrieval, password recovery,
password reset, and authenticated password change. Registration does not log in
automatically. Password reset/change revoke every session for the account and
issue no replacement credentials.

## Decisions

- Model app session state explicitly as `restoring`, `signedOut`, and
  `signedIn(user, tokens)`. App bootstrap attempts `/api/users/me` only when a
  stored session exists. A successful refresh can precede that call when the
  access token is expired. Do not treat cached user data or a family selection
  as proof of authentication.
- Use email/password forms for the initial release. Do not expose Google/Apple
  sign-in, account linking, verification, profile editing, or logout-all until
  those flows exist in the backend contract.
- Registration success leads to the login screen with the entered email
  prefilled; it does not imply the account is signed in. Login shows one generic
  credential error for `INVALID_CREDENTIALS`, including accounts without a
  local password.
- Preserve passwords exactly as entered; never trim or normalize them. Show
  backend field validation and provide equivalent client-side feedback for the
  documented 8–128 character, uppercase, digit, and special-character policy.
  The backend remains authoritative.
- Forgot-password always shows the same confirmation for every valid email.
  Do not claim an account exists or that mail was delivered. Respect `429` and
  `Retry-After` without rapid resubmission.
- The reset page reads the one-time token from the query string, removes it from
  the visible URL/history immediately, never logs it or sends it to analytics,
  and submits it only to the reset endpoint. Set a no-referrer policy for this
  page in Web hosting. On success, show confirmation and direct the user to log
  in; clear any local session.
- On password change, clear local credentials after success and return to
  signed-out state because the backend revokes all sessions. Handle an
  ambiguous timeout without automatic retry; explain that the user should try
  logging in with the new password or use recovery.
- Logout clears local credentials even when the network prevents server
  revocation, but the UI must distinguish “signed out on this device” from
  confirmed server logout if the request failed. The API revokes only the
  submitted session.
- Use the bounded, single-flight refresh behavior defined in PDR-FE-001. A
  refresh failure clears the stored pair and returns to signed-out state. A
  403 is an authorization result and must not trigger refresh. Do not retry
  uncertain auth mutations automatically.
- On Web, the initial memory-only token policy means reloading a tab signs out.
  If persistent Web sessions are approved later, add cross-tab refresh
  coordination before enabling them; refresh tokens are single-use and cannot
  be refreshed concurrently with the same value.

## Consequences

The signed-in app always has a server-confirmed current user. Authentication
screens can be implemented without assuming provider login, automatic
registration login, email delivery, or session-wide logout behavior that the
backend does not provide. Web has a shorter session lifetime by design until
browser persistence has a separate security decision.

## Initial implementation acceptance criteria

- Registration, login, current-user load, refresh, logout, forgot-password,
  reset-password, and change-password use only documented routes and fields.
- All API errors branch on status/stable `code`; UI copy follows PDR-FE-002 and
  localized backend field messages are shown when present.
- Session restoration cannot race with logout or replace a newer session.
- Secrets never appear in logs, analytics, URLs after reset-page initialization,
  or shared preferences.
- Loading, invalid credentials, validation, rate limit, network failure, and
  signed-out states are understandable and recoverable.

## References

- [Authentication API contract](../backend-api/authentication.md)
- [App foundation decision](pdr-fe-001-app-foundation.md)
- [Localization decision](pdr-fe-002-localization.md)
