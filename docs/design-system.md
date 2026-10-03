# Design System

## Visual identity

The interface should feel warm, playful, and family-oriented. Use soft pastel colors, rounded shapes, restrained shadows, and hand-drawn illustrative details while keeping the result legible and uncluttered. The bee mascot and illustrations are assets in this visual language, not structural UI dependencies.

Use semantic color roles consistently across adult and child experiences. A child's configured pastel completion color marks completed activities; pending activities are gray. Completion color conveys state, not decoration alone, and must be supported by another understandable state cue where needed.

## Theme first

The Design System is Flutter's `ThemeData` plus reusable Nosso Dia components. Configure native Flutter styling globally through the theme wherever Flutter provides an adequate mechanism, including typography, inputs, buttons, cards, checkboxes, navigation elements, and dividers. A native widget such as `TextField` should receive the product's default styling without repeating decoration at each use.

Keep shared visual primitives centralized. Define semantic tokens for color,
typography, spacing, radius, elevation, and recurring layout constraints. The
initial theme area may include:

```text
design_system/
  theme/
    app_theme.dart
    app_colors.dart
    app_typography.dart
    app_spacing.dart
    app_radius.dart
    app_elevation.dart
    app_breakpoints.dart
  components/
```

Use named tokens for recurring values rather than scattering magic numbers. A one-off value is acceptable when the component has a real, specific need.

Use `ThemeExtension` for semantic concepts that Flutter's built-in theme does not represent well (for example, paper, ink, or pending-task colors). Do not recreate the full theme system with custom extensions. Keep child completion-color choices as semantic domain values (for example, a named color choice); map them to the product's pastel palette in the frontend rather than storing raw presentation hex values as domain data.

## Reusable components

First use Flutter's native widget and `ThemeData`. Create a custom component when Nosso Dia needs meaningful behavior, composition, or visual identity beyond the native theme, or when reuse makes feature views clearer. Examples that may earn a component as actual needs arise include `NotebookPage`, `TaskCard`, `DaySelector`, `DailyChecklistItem`, `EmptyState`, and `ErrorState`.

Do not wrap native widgets solely to rename them or provide a few repeated style properties. For example, an app-specific text field is appropriate when fields share product-specific labeling, validation, or composition that `InputDecorationTheme` alone cannot provide.

## Typography and themes

Set the primary font family and text styles centrally in the theme. Prefer theme text styles in views over local font sizes and weights. Legibility takes priority over aesthetic fidelity for long text, small text, and input fields; a more readable variant may be used where needed.

Structure semantic tokens so a future light or dark theme can map concepts such as paper and ink differently, without requiring widgets to hard-code those colors. Dark mode itself is not implied as an MVP requirement.

## Responsive layout

Tablet landscape is the primary UX target. Centralize breakpoints and recurring
layout constraints in the design system. Mobile, tablet, and desktop/Web may use
purpose-built compositions where that produces a clearer experience; do not
mechanically convert every horizontal layout into a vertical one.

## Splash identity

Use the supplied Stitch reference for the startup splash: honey accents (`#F7C948`, `#F5B72E`,
`#DE9B15`), and charcoal ink (`#1F1A17`, muted `#433A36`). Keep theme
roles accessible by using dark honey ink (`#684507`) on filled honey controls.
Bundle Plus Jakarta Sans for UI, Courier Prime for notebook captions, and
Fredoka for the brand; include their font licenses under `assets/fonts/`.

The splash background is plain white until a background image is supplied.
Do not render the paper dots or background glows procedurally. `BeeHomeApp`
accepts an optional `splashBackgroundImage` (`ImageProvider`), passed to
`SplashView.backgroundImage`; use an `AssetImage` when the PNG is available
and register that asset in `pubspec.yaml`. Missing or failed images fall back
to white. The rest of the app retains its paper theme color.

Reuse `assets/mascote.png`. The splash shows a gently floating mascot, a
pulsing header dot, an animated dotted flight trail, and an indeterminate honey
loading bar. Respect the device's reduced-motion preference. Do not delay
startup solely to display the splash or imply measured loading percentages.
The ViewModel randomly changes among five localized phrases every 1.8 seconds
while loading, without immediately repeating a phrase, and stops the timer
when loading ends or the ViewModel is disposed. Render all phrases in
Portuguese, English, Spanish, and Estonian using generated ARB localizations.
The footer describes the brand without claiming unsupported offline behavior.

Tablet landscape is the primary splash reference; Web shares its bounded,
rounded notebook canvas. `SplashLayout` selects the compact or notebook
presentation once from the available width. The notebook profile uses a wider
420-pixel loading module, larger Plus Jakarta Sans brand typography, Space Mono
captions, and a green version-status dot. Mobile retains the compact Fredoka
and Courier Prime composition. Keep animations, translations, and version data
shared. The canvas still uses white as its background-image fallback.

## Authentication notebook

Authentication follows the supplied mobile and tablet references with warm
paper, subtle dots, a folded corner, lined inputs, and the existing local bee
mascot. Use the centralized notebook/paper/pencil color tokens, Courier Prime
for labels, Plus Jakarta Sans for the tablet brand, and Fredoka for the welcome
accent. All fonts and artwork remain bundled locally.

`AuthLayout` chooses compact mobile below 600 logical pixels and a two-column
notebook above that breakpoint. Tablet uses the rounded notebook frame; mobile
and Web fill the available window with rounded paper corners. Mobile uses a
minimal 6-pixel margin, omits the notebook date/time header, and keeps controls
in the safe area. A rounded, shadowed paper fold sits at the sheet's top right;
the adjacent settings button opens language settings. The form remains
bounded for readability, while the page and welcome panel fill the window.
Use at least 48-pixel tap targets and allow scrolling with keyboard insets or
large text. The bee animation respects reduced motion. Authentication screens
share these visuals, localized feedback, password visibility, and form styling.
