# Frontend product and architecture decisions

These decisions define the initial Flutter implementation. They complement the
project constitution, product overview, architecture, design system, testing
guidance, and the implemented contracts in [BeeHome API integration](../backend-api/README.md).

## Initial decisions

- [PDR-FE-001: App foundation](pdr-fe-001-app-foundation.md) — application
  structure, HTTP client, session credentials, preferences, and API error flow.
- [PDR-FE-002: Localization and regional formatting](pdr-fe-002-localization.md)
  — supported interface locales, locale selection, backend messages, and dates.
- [PDR-FE-003: Authentication and session lifecycle](pdr-fe-003-authentication-session.md)
  — register/login/recovery flows, startup restoration, refresh, and sign-out.
- [PDR-FE-004: Family workspace](pdr-fe-004-family-workspace.md)
- [PDR-FE-005: Family member profiles](pdr-fe-005-family-member-profiles.md)
- [PDR-FE-006: Routines and daily planning](pdr-fe-006-planning.md)
- [PDR-FE-007: Daily execution and history](pdr-fe-007-daily-execution.md)
- [PDR-FE-008: Study tracking](pdr-fe-008-study-tracking.md)
- [PDR-FE-009: Photos and private media](pdr-fe-009-photos-media.md)
- [PDR-FE-010: Books and reading](pdr-fe-010-books-reading.md)
- [PDR-FE-011: Extracurricular activities](pdr-fe-011-extracurricular-activities.md)
- [PDR-FE-012: Calendar, history, and reports](pdr-fe-012-calendar-reports.md)
- [PDR-FE-013: Global family tags](pdr-fe-013-global-tags.md)
- [PDR-FE-014: Profile scratchpad](pdr-fe-014-profile-scratchpad.md)

## Suggested implementation sequence

1. Build the app shell and foundation from PDR-FE-001 and PDR-FE-002.
2. Build authentication and current-user loading from PDR-FE-003 and
   [the authentication contract](../backend-api/authentication.md).
3. Build family selection/settings and member profiles (PDR-FE-004/005).
4. Deliver one complete daily flow: configure and resolve a plan, record its
   execution, and read its history (PDR-FE-006/007).
5. Plan and implement the remaining features as separate vertical slices in
   dependency order: studies (008), photos/media (009), books/reading (010),
   extracurricular activities (011), shared tags (013), reports (012), and
   scratchpad (014). Their release order depends on product priority and UX.

This sequence is a dependency order, not a claim that every listed feature must
ship in the first release. Product scope and acceptance criteria should be
recorded before committing to a release milestone.
