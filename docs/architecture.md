# Frontend Architecture

## Guiding approach

Organize primarily by feature and keep the architecture proportional to actual feature complexity. Do not create layers or files mechanically. A small feature may use fewer layers when responsibilities remain clear.

Use this flow when the feature needs it:

```text
View → ViewModel → Controller → Repository/Service → API or local storage
```

## Responsibilities

- **Model:** typed domain or application data, preferably immutable. Models have no UI behavior. Use value equality (for example, Equatable) when value comparison is useful.
- **View:** renders ViewModel state and forwards user intent. It does not make HTTP calls, access SQLite, or own business rules.
- **ViewModel:** exposes only the state and actions required by its view and coordinates presentation behavior.
- **Controller:** coordinates application operations between ViewModels and data access. It must not know about Widgets or `BuildContext`.
- **Data access:** isolate remote and local sources from UI code. Introduce repository/source boundaries where they solve a real complexity or testing need.

## State management

Use Flutter's native `ChangeNotifier`, `ListenableBuilder`, and `ValueListenableBuilder` as the default. Do not add Provider, Riverpod, Bloc, or another state-management dependency without a concrete need that native APIs do not address adequately.

## Networking and persistence

- Use Dio for HTTP. Centralize shared configuration such as base URL, headers, authentication, timeouts, and error handling in the API client layer.
- Never call Dio from a View or expose credentials in source code.
- Add local persistence only for a defined requirement. Use secure storage for sensitive values such as authentication tokens and shared preferences for small, non-sensitive settings; shared preferences are not a database.
- SQLite is an approved option if a concrete structured-storage need arises, such as offline cache, unsynchronized records, or a sync queue. It is not an initial dependency and does not imply building a complete offline architecture.
- Prefer existing project dependencies and Flutter/Dart capabilities. Every added dependency needs a concrete justification.

## Responsive composition

Responsive experiences may have separate compositions, for example `MobileFamilyHome`, `TabletFamilyHome`, and `DesktopFamilyHome`. Share models, controllers, ViewModels, data access, design tokens, and smaller widgets where useful. The screen composition may differ; do not force every screen into a single Row-to-Column transformation or duplicate an entire feature without reason.

Keep breakpoint definitions centralized. Use the initial widths in [Product Overview](product-overview.md).

## Design System boundary

Flutter `ThemeData` and centralized design tokens are the source of application-wide visual defaults. Feature views should not define repeated application-wide styling locally. Read the [Design System](design-system.md) guidance for visual changes.

## Suggested organization

Organize code by feature, with shared platform concerns and design primitives outside features. A possible shape is:

```text
lib/
  core/                 # API, storage, routing, utilities
  design_system/        # theme and reusable product components
  features/
    family/
    routines/
    studies/
    photos/
    books/
    reports/
```

Within a feature, add only the directories needed, such as models, controllers, view models, views, components, repositories, and tests. Do not create empty directories or speculative files.
