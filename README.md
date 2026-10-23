# plate-kit

A standalone design system for Quickshell QML apps. Tokens (`Appearance.qml`),
the kit layer (`Plate.qml`), the widget library (`modules/common/widgets`), the
fonts, and a palette loader — nothing here belongs to or imports from any other
tree. Apps built on the kit run as their own Quickshell processes.

Provenance: this library was ejected from the Tacit desktop shell's UI modules.
The design (tokens, curves, radii, type ladder) is a faithful copy; the shell
itself (its services, launchers, scripts, config) is not part of this tree.

## Layout

```
modules/common/          tokens + kit + functions + widgets (the design system)
services/                the pieces widgets import: Fonts, DateTime, MaterialThemeLoader
assets/fonts/            KitSymbols, Material Symbols Rounded (FontLoader'd)
Kit.qml                  root singleton — load-bearing, see below
shell.qml                registers the root as a Quickshell config
app-template.qml         starter for a new app — copy it and build
kit-specimen.qml         the design system as a specimen sheet
scripts/lint-design-system.mjs   the enforcement layer (rules DS1–DS8)
qt/                      the kit as a plain Qt app module (no Quickshell) — see qt/README.md
```

## The root-singleton rule

Quickshell synthesizes a directory's `module qs…` from the **uppercase-named**
QML files it finds; a root directory whose synthesized module has no entries
resolves as `module "qs" is not installed` and every import chain dies. That is
what `Kit.qml` is for — keep at least one uppercase root file. App-wide session
state (a shared flag, an app id) belongs on `Kit.qml`; tokens never go there.

## Run an app

```
qs -p app-template.qml     # starter
qs -p kit-specimen.qml     # the design system as a specimen sheet
```

Quickshell aliases the root (this directory) as `qs`, so imports read
`import qs.modules.common` wherever the tree lives.

## Write a new app

Copy `app-template.qml` next to it and edit. The rules of the system:

- **Colour**: only `Appearance.colors.*` / `Plate.*` tokens — never hex (the
  `?? "#…"` fallback idiom inside a widget library file is the one exception).
- **Type**: sizes and faces from `Plate.size.*` / `Appearance.font.family.*`.
- **Rounding**: `Appearance.rounding.*` / `Plate.radius.*` — a ladder, not choices.
- **Motion**: durations from `Appearance.animation.*` presets (enter ≈ 400 ms
  emphasized-decel, exit ≈ 200 ms emphasized-accel). Never a bare `duration:`.
- **Text ink**: `Plate.inkMain/Sec/Meta/Faint`. Never dim text with opacity.
- **Surfaces**: hover/active step up a layer-mix ladder (`colLayer1Hover`, …);
  nothing rests on a drop shadow; the one forward action is the accent.

## Button idiom (the one easy mistake)

`RippleButton`'s built-in `contentItem` is a bare text item: Control lays it out
at the padding corner (never centred) and resizes it to fit, so sizing the
pill from `contentItem.implicitWidth` shrinks it under its own label. For a
text action, use the library's own `ToolbarTabButton` idiom:

```qml
RippleButton {
    implicitWidth: implicitContentWidth + horizontalPadding * 2
    horizontalPadding: Appearance.spacing.normal
    implicitHeight: 36
    buttonRadius: height / 2
    contentItem: StyledText { text: "Primary"; color: Plate.onAccent }
    toggled: true
}
```

`DialogButton` self-sizes and centres, so it needs nothing of this. Swap ink on
the accent state (`Plate.onAccent` toggled, `Plate.inkMain` at rest).

## Check it

```
node scripts/lint-design-system.mjs                # the tree under modules/
node scripts/lint-design-system.mjs your-app.qml   # a root app file
node scripts/lint-design-system.mjs --list-rules   # DS1–DS8
```

The de facto canon of durations/radii is derived from the tree at run time, so
existing values pass and a *new* literal value flags. Apps and edits must add
**0** findings.

## Config and palette

- Apps persist settings in the kit's **own** config:
  `~/.config/plate-kit/config.json` (see `Config.qml` / `Directories.qml`).
  Nothing writes into any other app's config. Defaults live in Config's
  `JsonAdapter`, so a fresh machine boots a complete, correct-looking app.
- The palette is the generated Material theme at
  `~/.local/state/user/generated/colors.json` (matugen output) when a system
  color pipeline produced it; otherwise `Appearance.qml`'s built-in literal
  defaults stand and the theme loader says so. Call
  `MaterialThemeLoader.reapplyTheme()` on startup — singletons load lazily.

## Fonts

- `KitSymbols` and `Material Symbols Rounded` are FontLoader'd from
  `assets/fonts` and always travel with the kit.
- The text faces (`Tacit Sans`, `Tacit Sans Display/Compact/Condensed`,
  `Tacit Code`) are system-installed and identified by their internal family
  names. On a machine without them, fontconfig substitutes; ship them or
  re-point `Appearance.font.family.*` at faces you own.
