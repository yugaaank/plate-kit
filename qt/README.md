# qt/ — the kit as a plain Qt app

A scaffold for **plain Qt Quick apps** built from the Plate design system — no
Quickshell anywhere. Same tokens (`Appearance.qml`), same kit layer
(`Plate.qml`), the core widget set, wallpaper-derived palette, `Basic` style.

## Build & run

```
cd qt
qmake6 plateapp.pro && make -j$(nproc)
./plateapp     # a plain Qt window (KWin chrome, Basic style)
```

Requires `qt6-base`, `qt6-declarative`, `qt6-quickcontrols2` (qmake6 comes with
the base). No cmake needed for this scaffold; when a real app grows, migrate to
CMake + `qt_add_qml_module` for the shipping story (see notes below).

## Layout

```
plateapp.pro            qmake project (app + compiled-in resources)
src/main.cpp            the whole C++ side (≈ 90 lines, commented)
src/app.qrc             the kit + app compiled into the binary
app/main.qml            the starter app — copy this when starting a real one
PlateKit/               the design system as a proper QML module
  qmldir                declares `module PlateKit` (+ singletons & types)
  Appearance.qml        token layer — untouched from the kit, two stubs (below)
  Plate.qml             kit layer — untouched from the kit
  Config.qml            NEW: a light Config backstop (see below)
  Fonts.qml             ported: qrc font URLs instead of shell paths
  PlateThemeLoader.qml  NEW: applies the injected colors.json (kit's
                        MaterialThemeLoader minus FileView)
  ColorUtils/…qml        the pure function singletons, as-is
  <widgets>             StyledText, Anim, MaterialSymbol, RippleButton,
                        DialogButton, GroupButton, StyledSwitch, NoticeBox,
                        ToolbarTabButton, Pill, StyledProgressBar, StateLayer,
                        PointingHandInteraction, RippleButtonWithIcon, WavyLine
```

`app.qml` says `import PlateKit` and gets the whole system.

## What the port replaced (and what it did not)

The design and the widget code are **byte-faithful ports** of the kit; only the
harness differs:

| Quickshell concept | Qt port |
|---|---|
| root synthesized as module `qs` from uppercase root files | explicit `qmldir` — note the module dir must be named exactly like the module (`PlateKit/`), or resolution fails as "module not installed" |
| `Quickshell`'s `Singleton` base | `QtObject` (or `Item` when the singleton owns Timers/FontLoaders — `QtObject` has no default property) |
| `Quickshell.shellPath("assets/fonts")` | `qrc:/PlateKit/fonts/*.ttf` (FontLoader, unchanged type) |
| `FileView` + `JsonAdapter` for colors.json | `main.cpp` reads the file once, injects `PlateThemeJson`; `PlateThemeLoader.reapplyTheme()` maps snake_case roles onto `Appearance.m3colors` exactly as the kit's loader does |
| `MaterialThemeLoader` FileView watching | one-shot read at startup (re-invoke through your own file watcher if you need live re-tint) |
| `Config.qml` JsonAdapter over disk | `Config.qml` here is a frozen defaults backstop covering only the paths ported files read |
| `ColorQuantizer` (wallpaper vibrancy analysis) | frozen `wallpaperVibrancy: 0.0` — a Qt app can't see wallpapers; `backgroundTransparency` keeps its formula |
| `RadialGradient` (Qt5Compat ripple) | a plain rounded `Rectangle` ripple |
| `OpacityMask` (Qt5Compat, ripple clip) | `MultiEffect` mask (stock `QtQuick.Effects`) |
| `qs.services` imports | dropped; `Fonts` is a module singleton | 

## Adding a new QML file (the registration checklist)

A new kit type named `MyCard.qml`, usable as `MyCard { … }` from any app:

1. Put the file in `PlateKit/` (that directory — its name must equal the module name).
2. Add to `PlateKit/qmldir` at the bottom list:
   `MyCard 1.0 MyCard.qml` (order doesn't matter; `X 1.0 X.qml` for types,
   `singleton X 1.0 X.qml` — declared at the top — for singletons).
3. Add `<file>PlateKit/MyCard.qml</file>` to `src/../app.qrc` (make re-runs rcc
   on change automatically — no re-qmake needed).
4. Use `import PlateKit` in the app file. No C++ registration — types come
   through the qmldir alone.
5. `make` once (optional while developing: QML loads from disk, so plain edits
   to an existing file need no rebuild; a *new* file does, because rcc re-runs).

For a NEW SINGLETON: `pragma Singleton` at the top of the file, base type
`QtObject` (or `Item` when it owns Timers/FontLoaders — `QtObject` admits no
children), and the `singleton X 1.0 X.qml` qmldir line. If `Appearance` starts
reading a new `Config.options.*` path, extend `PlateKit/Config.qml` with the kit
default — that is the file's whole maintenance contract.

## Running without a display (CI / agents)

```
QT_QPA_PLATFORM=offscreen ./plateapp           # software rasterization, no compositor
QT_LOGGING_RULES="qt.qml**=true" ./plateapp    # see QML warnings on stderr
```

## How loading works (so you don't fight it)

- Dev mode (what this scaffold does): the engine reads `app/main.qml` and the
  `PlateKit` module **from disk, next to the binary** (`main.cpp` sets the
  binary's own directory as an import path). Editing QML needs no rebuild;
  the binary breaks if you move `plateapp` away from `app/` and `PlateKit/`.
- Shipping mode: register the module from compiled resources instead —
  convert to CMake (`qt_add_qml_module`) when you package. `plateapp.pro`
  carries the qrc mainly for the fonts, which must be embedded either way.

Fonts: text faces (`Tacit Sans`, `Tacit Code`, …) are **system-installed**, not
in the qrc — on a machine without them, fontconfig substitutes silently and
the layout drifts. The icon fonts (`qrc:/PlateKit/fonts/*.ttf`) always travel
with the binary.

## Deviations to keep in mind

- **Module resolution**: `import PlateKit` resolves from
  `QCoreApplication::applicationDirPath()` (the kit folder sits next to the
  binary in dev mode). For a packaged app, move to CMake:
  `qt_add_qml_module(URI PlateKit VERSION 1.0 QML_FILES …)` — that registers the
  module from resources exactly like this scaffold does from disk.
- **Config is frozen defaults**, not the kit's read/write config. A Qt app has
  its own settings story: add `QSettings`, expose what you need.
- **Window chrome** now comes from KWin (rounded corners, title bar) instead of
  the compositor look the shell's windows had; frost/blur needs the KDE blur
  protocol if a window wants it.
- **Text rendering** gets the system Qt (on this machine that is the
  linear-light-blended build, so the shell's type rendering applies to plain Qt
  apps too).
- **(The ports of the spec's pieces)** Ripples cut radially softer in the kit
  (Qt5Compat) — the port's ripple is a flat soft circle.

## Rules of the kit still apply here

The same design bar as the Quickshell kit (tokens only, ink ladder, one accent,
no off-ladder durations) holds in Qt apps — and the *lint script travels*:
`node ../scripts/lint-design-system.mjs` is path-independent.
