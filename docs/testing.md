# Testing and Definition of Done

## Test-driven development

Follow Red → Green → Refactor for relevant behavior:

1. Write a failing test that describes expected behavior.
2. Implement the minimum code needed to pass.
3. Refactor while keeping the test passing.

Represent important business rules in tests before implementing them. Inject dependencies so small fakes can be used; prefer fakes over adding a mocking framework when they are sufficient.

## Test selection

- **Unit tests:** models, ViewModels, controllers, repositories, business rules, transformations, and validation.
- **Widget tests:** meaningful UI behavior, including task completion appearance, empty/error states and retry, profile information, and responsive composition selection.
- **Integration tests:** critical end-to-end flows where persistence or cross-layer behavior needs verification. Do not turn every test into an integration test.

For relevant behavior, cover the expected path and meaningful failure cases. For example, when task completion fails, the UI must not claim that the change was persisted and the child must be able to retry.

## Asynchronous UI and errors

Data-driven screens should explicitly handle applicable states: initial, loading, success, empty, error, and where relevant refreshing or saving. A failed request must not leave a blank unexplained screen. Present a useful user-facing message and recovery action instead of exposing technical details such as raw Dio exceptions. Preserve technical detail only in an appropriate diagnostic/logging layer.

## Definition of Done

A frontend feature is complete when it:

- Meets its product acceptance criteria and implements relevant success and failure behavior.
- Has corresponding tests, and those tests pass when run as part of the requested implementation workflow.
- Handles applicable loading, empty, error, refreshing, and saving states.
- Works with the defined responsive compositions and centralized breakpoints.
- Keeps API and persistence access out of Views and contains no embedded secrets.
- Follows null safety, avoids `var` and unnecessary `dynamic`, and uses `const` where appropriate.
- Uses clear names, avoids unjustified duplication, and includes only useful comments.
- Follows the [Design System](design-system.md) and this project's architecture guidance.
- Introduces no relevant warnings.
