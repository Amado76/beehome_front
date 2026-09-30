# Nosso Dia Frontend Constitution

This document contains the principles that apply to every change in the Nosso Dia frontend. Detailed guidance lives in focused documents and should be read when relevant to a task.

## Project-wide principles

- Prefer clarity, simplicity, testability, reuse, and then extensibility, in that order.
- Choose the simplest implementation that solves the current requirement, is testable, and leaves the code easier to understand.
- Do not add abstractions, dependencies, or files without a concrete current need.
- Keep responsibilities clear and dependencies injectable. UI code must not own business rules or data access.
- Write all source code, identifiers, filenames, folders, tests, and comments in English. Keep comments concise and explain why, not what.
- Use sound null safety, explicit types, `final` by default, and `const` where applicable. Do not use `var`; avoid `dynamic`.
- Treat accessibility, understandable failure states, and maintainability as part of implementation quality.

## Focused guidance

- Product scope, target platforms, and user experience: [Product Overview](docs/product-overview.md)
- Layers, state management, data access, responsive composition, and project structure: [Frontend Architecture](docs/architecture.md)
- Visual identity, Flutter theme, tokens, and reusable UI components: [Design System](docs/design-system.md)
- Test-driven development, test coverage, and completion criteria: [Testing and Definition of Done](docs/testing.md)
- Any feature that uses the BeeHome backend: [Backend integration guide index](docs/backend-api/docs/frontend/README.md). Follow its feature index and related guides; verify implementation behavior when a contract is unclear. Treat the guides as the source for supported API behavior. Never invent routes, fields, permissions, or flows. Report an API gap when required behavior is missing or undocumented.

Read the relevant document before making decisions in its area. For example, consult the Design System for visual work and Frontend Architecture when changing application structure or data flow. If guidance conflicts, follow this constitution's project-wide principles and keep the implementation simple; update the focused document when an agreed product decision changes.
