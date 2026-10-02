# Nosso Dia Frontend Constitution

This document contains the principles that apply to every change in the Nosso Dia frontend. Detailed guidance lives in focused documents and should be read when relevant to a task.

## Project-wide principles

- Prefer clarity, simplicity, testability, reuse, and then extensibility, in that order.
- Choose the simplest implementation that solves the current requirement, is testable, and leaves the code easier to understand.
- Apply SOLID principles pragmatically to keep responsibilities focused,
  dependencies replaceable, and contracts easy to test. Do not add abstractions
  solely to satisfy a principle mechanically.
- Do not add abstractions, dependencies, or files without a concrete current need.
- Keep responsibilities clear and dependencies injectable. UI code must not own business rules or data access.
- Write all source code, identifiers, filenames, folders, tests, and comments in English. Keep comments concise and explain why, not what.
- Use sound null safety, explicit types, `final` by default, and `const` where applicable. Do not use `var`; avoid `dynamic`.
- Treat accessibility, understandable failure states, and maintainability as part of implementation quality.

## Architecture decisions

- Prioritize tablet (landscape), then Web, then mobile. Select responsive compositions by available space and shared breakpoints, keeping layout choices in Views and reusable presentation profiles.

- Organize by feature, then layer: `features/<feature>/<layer>/` for product features and `core/<feature>/<layer>/` for shared features. Keep repositories in the owning feature's `repos/` directory, never in a global directory containing every feature's repositories. Tests mirror this organization.
- Views render state and forward actions exclusively to an injected ViewModel. Keep presentation logic, startup, retry, and error-state coordination in ViewModels. Views must not call application services, controllers, repositories, API clients, or storage directly. Layout and localized text rendering remain in Views.
- Use application services only when needed to coordinate business operations or shared state. Name them by responsibility, such as `SessionService`; do not introduce controllers between Views and ViewModels.
- Keep local and remote repositories separate. Local repositories access databases, secure storage, preferences, or memory directly. Remote repositories call an injected `ApiClient`. ViewModels and services depend on repository contracts.
- Keep this architecture simple: do not add `sources`, data-source adapters, or delegating repository wrappers between a repository and its API client or storage dependency.
- Apply dependency inversion and explicit dependency injection. Consumers depend on small contracts rather than concrete infrastructure implementations. Register concrete repositories, storage plugins, and `DioApiClient` with GetIt in `app/di/`; coordinate startup in `app/bootstrap.dart`. Keep container access at composition boundaries and Dio types out of application services and shared API/error contracts. Continue injecting dependencies through constructors.

## Focused guidance

- Product scope, target platforms, and user experience: [Product Overview](docs/product-overview.md)
- Layers, state management, data access, responsive composition, and project structure: [Frontend Architecture](docs/architecture.md)
- Visual identity, Flutter theme, tokens, and reusable UI components: [Design System](docs/design-system.md)
- Test-driven development, test coverage, and completion criteria: [Testing and Definition of Done](docs/testing.md)
- Any feature that uses the BeeHome backend: [Backend integration guide index](docs/backend-api/README.md). Follow its feature index and related guides; verify implementation behavior when a contract is unclear. Treat the guides as the source for supported API behavior. Never invent routes, fields, permissions, or flows. Report an API gap when required behavior is missing or undocumented.
- Initial frontend architecture and localization decisions: [Frontend decisions](docs/frontend-decisions/README.md).

Read the relevant document before making decisions in its area. For example, consult the Design System for visual work and Frontend Architecture when changing application structure or data flow. If guidance conflicts, follow this constitution's project-wide principles and keep the implementation simple; update the focused document when an agreed product decision changes.
