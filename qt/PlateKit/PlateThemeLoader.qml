pragma Singleton

/**
 * The Qt port of the kit's MaterialThemeLoader.
 *
 * In the Quickshell kit this is a FileView over
 * ~/.local/state/user/generated/colors.json. Qt Quick has no FileView, so the
 * C++ app entry (src/main.cpp) reads the same file once and injects it here as
 * the `PlateThemeJson` context property; this singleton maps it into
 * Appearance's m3colors exactly the way the kit does (snake_case roles become
 * m3CamelCase properties). Call reapplyTheme() once at app startup.
 *
 * No file (or an empty one) is not an error state: Appearance falls back to its
 * built-in literal palette, the same contract as the Quickshell kit.
 */
import QtQuick

pragma ComponentBehavior: Bound

QtObject {
    id: root

    function reapplyTheme() {
        const json = (typeof PlateThemeJson !== "undefined") ? PlateThemeJson : null
        if (!json || Object.keys(json).length === 0) {
            console.warn("[PlateThemeLoader] no colors.json was loaded (PlateThemeJson is empty). " +
                         "Using Appearance.qml's built-in default palette.")
            return
        }
        for (const key in json) {
            if (!json.hasOwnProperty(key))
                continue
            // Convert snake_case to CamelCase — m3Background, m3OnSurface, …
            const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
            const m3Key = `m3${camelCaseKey}`
            Appearance.m3colors[m3Key] = json[key]
        }
        Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5)
    }
}
