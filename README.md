# beehome

A new Flutter project.

## Local checks

Enable the repository's commit checks in this clone:

```sh
./scripts/install-git-hooks.sh
```

The pre-commit hook runs `dart format --output=none --set-exit-if-changed .`,
`flutter analyze --fatal-infos --fatal-warnings`, and `flutter test`. It does not
modify files or the Git stage. Formatting, analyzer, or test failures stop the
commit. Format files and stage the intended changes before retrying.

## App foundation (PDR-FE-001)

The bootstrap constructs one Dio client, a session controller, platform session
storage and a preferences adapter. Features receive these dependencies explicitly.
The shell renders loading, signed-out, signed-in and recoverable storage failures.
A stored token pair indicates a local session; remote user validation and full
login/register/recovery flows belong to PDR-FE-003. Family selection belongs to 004.
The initial shell uses generated translations; the full localization workflow and
regional formatting belong to PDR-FE-002.

### Run locally

```sh
flutter pub get
flutter run --dart-define=API_ORIGIN=http://localhost:8080
```

`API_ORIGIN` must be an origin without a path, query, fragment or credentials.
Debug/profile builds default to `http://localhost:8080`. Release builds require
an explicit HTTPS origin; invalid configuration displays a diagnostic screen.
Never pass tokens, passwords or deployment secrets through `--dart-define`.

Use `http://10.0.2.2:8080` for the Android emulator, `http://localhost:8080`
for the iOS simulator, or the development computer's reachable LAN IP for a
physical device. Android debug builds allow development HTTP. iOS device HTTP
may require a scoped local App Transport Security exception in the development
configuration; prefer a reachable HTTPS endpoint. Release builds use HTTPS.

Web sessions are memory-only and end on reload. Deploy the frontend and API on
the same origin (reverse proxy `/api` to the backend), or configure backend CORS
explicitly. For a same-origin release, pass the frontend's HTTPS origin as
`API_ORIGIN`. Native request success does not establish browser CORS support.

### Infrastructure behavior

- Call `services.api.request('/api/...')`; protected calls are the default.
  Known public auth/health routes always omit Bearer credentials. Use
  `protected: false` for other contract-defined public calls.
- Safe GET/HEAD calls renew once after 401, sharing refresh across concurrent
  calls, and retry once. A second 401 or failed renewal clears the session.
  POST/PUT/PATCH/DELETE calls and 403 responses are never automatically retried.
- `ApiError` exposes status, stable code, safe problem detail, field errors,
  `Retry-After`, and whether a mutation's outcome is uncertain. Reconcile
  uncertain mutations using the feature's contract. No request logging is enabled.
- `session.replace` clears account-scoped family selection; refresh preserves it.
  `session.clear` clears local credentials and selection. Local sign-out does
  not claim server revocation. Password reset/change features must clear the
  session after success. Revalidate saved family IDs in the family feature.
- iOS/Android store the token pair as one secure value. Android backup is
  disabled, and the iOS runner has Keychain entitlements. Simple preferences
  expose only locale override and selected family ID.
- Button, input and card patterns come from `AppTheme`. Responsive layout uses
  centralized mobile (<600), tablet (600–1199), and desktop (>=1200) breakpoints.

### Foundation checks

```sh
flutter test
flutter analyze --fatal-infos --fatal-warnings
```
