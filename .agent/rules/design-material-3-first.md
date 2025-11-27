---
trigger: always_on
---

# Workspace Rule - Flutter Material 3-first (Antigravity)

You are an Antigravity workspace agent working on a Flutter app.

* Treat **Material Design 3 (M3)** as the default design system.
* Use **Flutter Material 3 widgets and theming** by default.
* Use **Material 2 (M2)** only as a fallback when there is no stable M3 equivalent or when blocked by a dependency.
* When you keep an M2 widget, **style it to match M3** and add a short `// TODO: migrate to M3 when available` comment.

Follow:

* Flutter "Migrate to Material 3" docs.
* Material Design 3 guidelines for color, type, components, layout, motion and accessibility.

Keep answers and code **concise** to save tokens.

---

## 1. App-wide theme configuration

When creating or updating the app shell:

1. In `MaterialApp` (or `MaterialApp.router`):

   * Set `useMaterial3: true` in the theme.
   * Define a `ColorScheme` (prefer `ColorScheme.fromSeed` or a central color util).
   * Do **not** use `primarySwatch` or rely on random `Colors.*` constants at app level.

2. Make theme changes at the **theme level**, not per widget:

   * Use `colorScheme`, `textTheme`, and component themes (`appBarTheme`, `navigationBarTheme`, `segmentedButtonTheme`, etc.).
   * Avoid heavy inline styling on each widget.

3. Keep Material 3 elevation and `surfaceTint` behaviour unless there is a clear design reason to override.

---

## 2. Component selection - always M3-first

When choosing widgets, prefer M3 equivalents.

### Navigation

* Use:

  * `NavigationBar` instead of `BottomNavigationBar`.
  * `NavigationDrawer` instead of `Drawer` where appropriate.
  * `NavigationRail` for medium/large screens.
  * `SliverAppBar.medium` / `SliverAppBar.large` for medium/large title patterns.

* Keep M2 navigation widgets only when:

  * Required by a third-party library, or
  * Migration is clearly blocked.

In those cases, theme them with `Theme.of(context).colorScheme` and add a short comment explaining why they stay.

### Buttons and toggles

* Use M3 button family:

  * `FilledButton`, `FilledButton.tonal`, `OutlinedButton`, `TextButton`, `IconButton`.
* Prefer `SegmentedButton<T>` instead of `ToggleButtons`.
* Avoid adding new code with legacy M2-only button styles. If you must keep an `ElevatedButton` or similar, treat it as compatibility code and style via `Theme.of(context)`.

### App bars and surfaces

* Use M3 app bar behaviour:

  * `AppBar` with scroll under behaviour where needed.
  * `SliverAppBar.medium` and `.large` for richer top bars.
* Avoid manual shadows; rely on M3 elevation and tint first.

### Inputs and surfaces

* Use `TextField` / `TextFormField` styled via the theme, not hard-coded colors.
* Let dialogs, bottom sheets, cards and FABs use M3 default shapes and elevation unless the product design requires overrides.

---

## 3. Migration rules for existing Material 2 code

When editing a screen that still uses M2:

1. Look for M2 widgets and migrate when there is an M3 equivalent:

   * `BottomNavigationBar` → `NavigationBar`.
   * `Drawer` → `NavigationDrawer` (when that pattern fits).
   * `ToggleButtons` → `SegmentedButton`.
   * Custom mixed app bars → `SliverAppBar.medium` / `.large`.

2. If no M3 equivalent exists yet:

   * Keep the M2 widget.
   * Style it using `colorScheme`, `textTheme`, and M3-like shape and elevation.
   * Add a short TODO comment to migrate later.

3. Avoid per-widget color hacks:

   * Prefer fixing theme-level tokens (`ColorScheme`, component themes).

---

## 4. Color, typography, shape, motion, accessibility

For each UI task:

### Color

* Base all key colors on `ColorScheme` or central design tokens.
* Avoid new hard-coded `Colors.*` values in UI code, unless for non-critical decorative details.

### Typography

* Use M3 type roles (`display*`, `headline*`, `title*`, `body*`, `label*`).
* Map product text hierarchy to these roles and keep it consistent.
* Avoid M2 names like `bodyText1`, `subtitle1` in new code.

### Shape and elevation

* Prefer M3 shape defaults (more rounded corners on cards, sheets, dialogs, FAB, chips).
* Use M3 elevation and surface tint instead of custom shadow colours.

### Motion

* Use Flutter's default M3 animations and durations where possible.
* Keep motion subtle and purposeful.

### Accessibility

* Maintain contrast ratios for text and important UI elements.
* Respect text scaling and layout responsiveness.
* Ensure touch targets meet Material guidance for size.

---

## 5. Antigravity agent behaviour

When you work as an Antigravity agent on Flutter UI:

1. Before coding:

   * Write a very short plan (1-3 bullet points) stating:

     * What screen or flow you are touching.
     * Which M3 components you will use.
     * Any M2 fallback you expect to keep and why.

2. Scope work small:

   * Prefer migrating or implementing **one screen or flow at a time**.

3. Self-check after edits:

   * Ensure `useMaterial3` is enabled in the active theme.
   * Check that there are no new hard-coded `Colors.*` where `colorScheme` should be used.
   * Check for M2 widgets where an M3 equivalent exists; migrate or add a TODO if you cannot migrate.

4. When user asks for legacy or non-M3 look:

   * Briefly warn about the conflict with this rule.
   * Suggest the closest M3-compliant solution.
   * If you still implement the request, keep it as contained as possible and document the tradeoff with a short comment.

Keep all outputs focused, with minimal explanation text and no unnecessary logs or long commentary.
