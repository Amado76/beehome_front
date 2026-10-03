# Frontend Architecture

## Guiding approach

Organize primarily by feature and keep the architecture proportional to actual feature complexity. Do not create layers or files mechanically. A small feature may use fewer layers when responsibilities remain clear.

Apply SOLID principles where they improve separation of responsibilities,
replaceability, or testability. Keep views free of data access and business
rules, inject infrastructure dependencies at feature boundaries, and prefer
small focused interfaces. Do not create speculative extension points or
interfaces solely to satisfy SOLID mechanically.

Use this flow when the feature needs application coordination:

```text
View → ViewModel → Service → Repository → API or local storage
```

When no service is needed, use `View → ViewModel → Repository`. Keep local and
remote repositories separate; add only the repositories needed by the feature.

## Responsibilities

- **Model:** typed domain or application data, preferably immutable. Models have no UI behavior. Use value equality (for example, Equatable) when value comparison is useful.
- **View:** renders ViewModel state and forwards actions exclusively to its injected ViewModel. Keep layout, widget lifecycle, and localized text rendering here. Do not call services, controllers, repositories, API clients, or storage from a View.
- The application shell follows `BeeHomeApp → AppViewModel → AppServices/SessionService`. Inject the ViewModel into the View; keep startup, retry, and sign-out coordination in the ViewModel.
- **ViewModel:** exposes only the state and actions required by its View. Own presentation logic, initialization, retry, sign-out actions, and error-state coordination here; delegate business and data-access operations to services or repository contracts.
- **Service:** coordinates business operations or shared application state when needed, using repository contracts. It must not know about Widgets or `BuildContext`. Prefer names that describe the responsibility, such as `SessionService`, and do not introduce controllers between Views and ViewModels.
- **Data access:** local repositories access storage directly; remote repositories call the injected API client. ViewModels and application services depend on repository contracts and never access API clients or storage directly. Do not add an intermediate source layer.

## Dependency inversion and injection

Inject dependencies explicitly through constructors. Views receive ViewModels;
ViewModels and services receive the contracts they need; remote repositories
receive `ApiClient`; local repositories receive their database or storage plugin
when applicable. Consumers must not construct concrete infrastructure dependencies.

Register production implementations with GetIt in `app/dependency_injection/dependencies.dart`,
with separate core and application registration modules in `app/dependency_injection/modules/`.
Future features should add their own registration modules rather than extend
`AppServices` into a container of unrelated dependencies. Container access stays
at composition boundaries; Views, ViewModels, services, and repositories retain
constructor injection. Tests can use an isolated `GetIt.asNewInstance()` or
construct consumers directly with fakes.

Repositories and shared services use singleton or lazy-singleton registrations;
ViewModels use factories and are disposed by their owning widget. `AppServices`
is registered eagerly and owns disposal of the shared session and API client.
The root widget in `app/bootstrap.dart` disposes its ViewModel before resetting
GetIt, which disposes `AppServices`. Do not also register disposal callbacks for
resources already owned by `AppServices`.

Keep `AppServices` independent of Dio and expose API results and failures without
Dio types. Dio configuration and exception mapping belong in `DioApiClient`.
GetIt manages dependencies; state management continues to use native listenables.

## State management

Use Flutter's native `ChangeNotifier`, `ListenableBuilder`, and `ValueListenableBuilder` as the default. Do not add Provider, Riverpod, Bloc, or another state-management dependency without a concrete need that native APIs do not address adequately.

## Networking and persistence

- Use Dio for HTTP. Centralize shared configuration such as base URL, headers, authentication, timeouts, and error handling in the API client layer.
- Repositories depend on the `ApiClient` contract. Keep Dio configuration and transport error mapping in `DioApiClient`; register production dependencies in `app/dependency_injection/`. Session renewal calls the injected authentication repository operation; the transport does not own the refresh endpoint or response mapping.
- Never call Dio from a View or expose credentials in source code.
- Name repository implementations by their data access: `LocalSessionRepository`, `LocalAppPreferencesRepository`, and `RemoteAuthenticationRepository`. Local repositories directly own database, secure-storage, or preferences calls; remote repositories directly own endpoint calls and response-to-model mapping through `ApiClient`. Keep memory implementations replaceable through the same local repository contracts.
- Do not add `sources/`, data-source adapters, or wrappers that only delegate to another storage abstraction. The repository is the data-access boundary for the current architecture.
- Add local persistence only for a defined requirement. Use secure storage for sensitive values such as authentication tokens and shared preferences for small, non-sensitive settings; shared preferences are not a database.
- SQLite is an approved option if a concrete structured-storage need arises, such as offline cache, unsynchronized records, or a sync queue. It is not an initial dependency and does not imply building a complete offline architecture.
- Prefer existing project dependencies and Flutter/Dart capabilities. Every added dependency needs a concrete justification.

## Responsive composition

Prioritize tablet in landscape orientation, followed by Web and then mobile.
Choose layout from available width and the shared breakpoints, rather than
platform checks. For screens with shared composition, use named presentation
profiles selected once by a breakpoint `switch`, instead of scattering
`if/else` styling throughout components. The splash uses `SplashLayout.compact`
below 600 logical pixels and `SplashLayout.notebook` for tablet and Web;
its header, mascot, loading messages, and footer are shared.

Responsive experiences may have separate compositions, for example `MobileFamilyHome`, `TabletFamilyHome`, and `DesktopFamilyHome`. Share models, services, ViewModels, data access, design tokens, and smaller widgets where useful. The screen composition may differ; do not force every screen into a single Row-to-Column transformation or duplicate an entire feature without reason.

Keep breakpoint definitions centralized. Use the initial widths in [Product Overview](product-overview.md).

## Design System boundary

Flutter `ThemeData` and centralized design tokens are the source of application-wide visual defaults. Feature views should not define repeated application-wide styling locally. Read the [Design System](design-system.md) guidance for visual changes.

## Code organization

Use feature first, then layers, including shared features inside `core`. Do not
collect unrelated features in global `models/`, `repositories/`, or `storage/`
directories. The current foundation is organized as follows:

```text
lib/
  app/
    bootstrap.dart        # startup and root lifecycle
    dependency_injection/
      dependencies.dart   # registration entry point
      modules/            # core, application, and future feature registrations
    services/
    view_models/
    views/
  core/
    auth/
      models/
      repos/              # separate local session and remote authentication contracts
      services/
    config/
      models/
    network/
      clients/
      models/
    preferences/
      repos/
  design_system/
    components/
    theme/
  l10n/
    generated/
```

New product features use `features/<feature>/<layer>/`; shared core features use
`core/<feature>/<layer>/`. Keep local and remote repositories separate inside
the owning feature's `repos/` directory. Views depend on ViewModels, and services
depend on repository contracts. Local repositories access storage directly;
remote repositories call `ApiClient`.
Do not add `sources/` or storage adapter layers between repositories and their
existing platform dependencies.

Tests mirror feature and layer paths, for example
`test/core/auth/services/session_service_test.dart` and
`test/app/views/beehome_app_test.dart`. Keep shared app test fixtures in
`test/app/support/`. Add only directories needed by existing code.
