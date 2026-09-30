# Design System

## Visual identity

The interface should resemble a clean physical notebook or sheet of paper: predominantly white, black, and soft gray; generous whitespace; rounded edges; typewriter-inspired typography; and restrained hand-drawn details. Keep the result legible and uncluttered rather than adding decoration for its own sake.

Adults use a mostly monochrome interface. For children, a configured pastel color marks completed activities; pending activities are gray. This color conveys completion state, not decoration alone, and must be supported by another understandable state cue where needed.

## Theme first

The Design System is Flutter's `ThemeData` plus reusable Nosso Dia components. Configure native Flutter styling globally through the theme wherever Flutter provides an adequate mechanism, including typography, inputs, buttons, cards, checkboxes, navigation elements, and dividers. A native widget such as `TextField` should receive the product's default styling without repeating decoration at each use.

Keep shared visual primitives centralized. The initial theme area may include:

```text
design_system/
  theme/
    app_theme.dart
    app_colors.dart
    app_typography.dart
    app_spacing.dart
    app_radius.dart
    app_breakpoints.dart
  components/
```

Use named tokens for recurring values rather than scattering magic numbers. A one-off value is acceptable when the component has a real, specific need.

Use `ThemeExtension` for semantic concepts that Flutter's built-in theme does not represent well (for example, paper, ink, or pending-task colors). Do not recreate the full theme system with custom extensions. Keep child completion-color choices as semantic domain values (for example, a named color choice); map them to the product's pastel palette in the frontend rather than storing raw presentation hex values as domain data.

## Reusable components

First use Flutter's native widget and `ThemeData`. Create a custom component when Nosso Dia needs meaningful behavior, composition, or visual identity beyond the native theme, or when reuse makes feature views clearer. Examples that may earn a component as actual needs arise include `NotebookPage`, `TaskCard`, `DaySelector`, `DailyChecklistItem`, `EmptyState`, and `ErrorState`.

Do not wrap native widgets solely to rename them or provide a few repeated style properties. For example, an app-specific text field is appropriate when fields share product-specific labeling, validation, or composition that `InputDecorationTheme` alone cannot provide.

## Typography and themes

Set the typewriter-inspired primary font family and the text styles centrally in the theme. Prefer theme text styles in views over local font sizes and weights. Legibility takes priority over aesthetic fidelity for long text, small text, and input fields; a more readable variant may be used where needed.

Structure semantic tokens so a future light or dark theme can map concepts such as paper and ink differently, without requiring widgets to hard-code those colors. Dark mode itself is not implied as an MVP requirement.
