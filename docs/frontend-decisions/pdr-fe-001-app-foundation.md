# PDR-FE-001: App foundation

- **Status:** Accepted for initial implementation
- **Date:** 2026-09-30
- **Scope:** Flutter app shell and shared platform infrastructure

## Context

The app targets iOS, Android, and Web. The backend uses JSON APIs, explicit
Bearer tokens, RFC 9457-style problem responses, and no cookie session. The
backend API guides require bounded token renewal, localized backend messages,
and careful reconciliation after uncertain mutations. The current Flutter
project has only the starter `main.dart` and no runtime dependencies.

## Decisions

### Application structure

Use feature-first code organization with shared app/platform concerns outside
features. Start with only the concrete foundation directories below; create
feature subdirectories as a feature needs them.

```text
lib/
  app/
    bootstrap.dart        # startup and root lifecycle
    dependency_injection/ # GetIt registrations, grouped by module
    services/
    view_models/
    views/
  core/
    auth/
      models/
      repos/              # local session and remote authentication repositories
      services/
    config/
      models/
    network/
      clients/
      models/
    preferences/
      repos/
  design_system/          # theme, tokens, shared product components
  l10n/                   # ARB translation resources and generated localizations
  features/
    auth/
    family/

assets/
  images/
  illustrations/
  mascots/
  icons/
```

Keep the existing feature flow proportional to complexity:
`View → ViewModel → Service → Repository → API or local storage`.
Within both `core/` and `features/`, group by feature before layer. Repositories
for local and remote data stay separate within their feature's `repos/` directory.
Tests mirror the feature and layer structure.
Use `ChangeNotifier` and Flutter listenable builders by default. Use GetIt to register shared dependencies and ViewModel factories in `app/dependency_injection/`.
Keep constructor injection in consumers and container access at composition
boundaries. The app root disposes its ViewModel before resetting the container;
`AppServices` owns the shared session and API client disposal. Do not add a router,
database, or state management package until a concrete feature need justifies it.

Apply SOLID to keep responsibilities focused and dependencies replaceable,
without adding abstractions or layers mechanically.

### Design system and visual foundation

- Keep shared visual foundations under `lib/design_system/`; product features
  must not define independent visual languages.
- Centralize semantic tokens for color, typography, spacing, radius, elevation,
  and recurring layout constraints. Prefer semantic tokens over raw palette
  values in feature code.
- Use Flutter `ThemeData` for application-wide styling. Product-specific
  components that cannot be represented appropriately through theme
  configuration belong in `design_system/components/`.
- Add shared buttons, text fields, cards/surfaces, dialogs, selectors, and
  navigation elements incrementally as concrete screens require them. Do not
  create a speculative component library upfront.
- Use a warm, playful, family-oriented visual language with soft pastel colors,
  rounded shapes, restrained shadows, and hand-drawn illustrative elements.
  The bee mascot and illustrations are assets, not structural UI dependencies.
- Treat tablet landscape as the primary UX target. Mobile, tablet, and
  desktop/Web may use purpose-built compositions where appropriate; do not
  assume responsive behavior comes from mechanically converting rows to
  columns.
- Organize image assets under `assets/images/`, hand-drawn artwork under
  `assets/illustrations/`, mascots under `assets/mascots/`, and standalone icons
  under `assets/icons/`. Register only needed asset paths in `pubspec.yaml`.

### HTTP and API behavior

- Use one configured `Dio` instance behind an injectable API client. Configure
  the origin at startup; do not hardcode deployment secrets or assume one
  `localhost` address works on simulators and physical devices.
- Keep the API origin configurable per build/deployment. Do not put credentials
  in `--dart-define`; it is configuration, not secret storage.
- Centralize JSON `Accept`/`Content-Type`, timeouts, `Accept-Language`, Bearer
  attachment, problem-response parsing, and transport error mapping.
- Attach the access token only to protected calls. Public login, register,
  forgot/reset password, health, and especially refresh requests must not inherit
  a stale Bearer header. Do not use cookies.
- Model API errors using HTTP status and stable `code`; treat translated
  `detail` as display text only. Support responses with no body, including 204,
  and framework/proxy failures without an application code.
- Coordinate one refresh operation per session. Replace access and refresh
  tokens as one stored pair, retry a protected request no more than once, and
  prevent an in-flight refresh from restoring a logged-out session. Never
  refresh on 403. Do not automatically retry non-idempotent or uncertain
  mutations; reconcile with the relevant GET flow described by each contract.
- Keep logging free of tokens, passwords, reset secrets, and private response
  content.

The backend origin must be same-origin for Web at first, or use an explicitly
configured backend CORS policy. The API contract says browser cross-origin access
is not configured; successful native/curl requests do not prove browser access.

### Credentials and storage

Introduce small interfaces (`SessionRepository` and `AppPreferencesRepository`) so feature
code does not depend directly on a platform plugin.

- On iOS and Android, store the access/refresh token pair using
  `flutter_secure_storage`. Clear both on sign-out, password reset/change, or
  failed renewal. Serialize the pair as one secure-storage value so refresh
  rotation replaces both credentials in one write.
- On Web, keep credentials in memory for the initial release. Do not treat
  browser local/session storage or the current secure-storage plugin's Web
  implementation as equivalent to Keychain/Keystore. Revisit persistent Web
  sessions after a deployment security review (HTTPS, same-origin/CORS,
  browser threat model, and session lifetime).
- Use `SharedPreferencesAsync` directly in `LocalAppPreferencesRepository` for small,
  non-sensitive settings such as selected interface locale and selected family
  ID. Treat the family ID as navigation convenience only: revalidate it against
  accessible families and clear it on account switch/sign-out.
- Do not put credentials, profile data, API caches, drawings, or offline queues
  in shared preferences. Add structured/local offline storage only when a
  feature has an accepted offline/sync requirement.

### Runtime environment

Read the backend origin from an explicit build/deployment configuration with a
safe development default matching the backend guide (`http://localhost:8080`).
Document simulator/device-specific overrides when wiring the first API call.
Require HTTPS outside local development. If no valid origin is configured, show
a diagnosable configuration failure rather than silently calling production.

## Consequences

This yields a small, testable foundation without introducing speculative
layers. Native apps can retain sessions securely. Web sessions end when the
page process is discarded until persistent browser authentication is reviewed.
Backend CORS/deployment setup is a prerequisite for cross-origin Web hosting.

The backend supports sensitive operations that revoke every session after
password reset/change; the client must clear local credentials and return to
login even if the operation's success message is localized.

## Initial implementation acceptance criteria

- GetIt registers one configured Dio client behind `ApiClient`; `AppServices` owns its disposal.
- API error parsing handles `application/problem+json`, absent bodies, 204, and
  non-JSON failures without leaking server internals to the UI.
- Protected requests receive the current Bearer token; public requests do not.
- Session storage has platform-specific implementations behind an interface;
  Web storage is memory-only.
- Simple preferences contain only non-sensitive settings and clear account-
  scoped selection when the session changes.
- The app shell has explicit loading, signed-out, and signed-in routing states;
  detailed feature flows belong in later decisions/features.
- App colors, typography, spacing, and shape decisions are available through
  centralized design-system/theme APIs; foundation screens contain no
  arbitrary visual constants.
- Initial shared button, text-field, and surface/card patterns used by
  authentication and app-shell screens are provided by the design system.
- App-shell layouts establish explicit responsive breakpoints/strategies, with
  tablet landscape treated as the primary design target.
- Foundation behavior has focused unit tests and relevant auth/network widget
  tests as part of implementation work, following `docs/testing.md`.

## References

- [Frontend architecture](../architecture.md)
- [Authentication contract](../backend-api/authentication.md)
- [Frontend integration index](../backend-api/README.md)
- [`flutter_secure_storage` package documentation](https://pub.dev/packages/flutter_secure_storage)
- [`shared_preferences` package documentation](https://pub.dev/packages/shared_preferences)
