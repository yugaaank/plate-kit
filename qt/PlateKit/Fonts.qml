pragma Singleton


import QtQuick
import "kit_symbols.js" as KitSymbolNames

Item {
    id: root
    // A failed FontLoader leaves an empty family name, and `??` in MaterialSymbol only catches
    // undefined - Qt then resolved "" to the default sans and every glyph in the shell rendered
    // as its ligature name. Fall back on emptiness, not on nullishness.
    property string iconMaterialFamily: (materialSymbolsLoader.status === FontLoader.Ready && materialSymbolsLoader.name.length > 0)
        ? materialSymbolsLoader.name
        : "Material Symbols Rounded"

    // Plate's own symbols (~/dev/tacit-icons): two fonts typed by name like Material Symbols, one of lines and
    // one of filled forms. They cover the names listed in kit_symbols.js; any other name, and every name while
    // either font has not loaded, keeps Material's glyph.
    readonly property bool customSymbolsReady: customLineLoader.status === FontLoader.Ready && customLineLoader.name.length > 0
        && customFillLoader.status === FontLoader.Ready && customFillLoader.name.length > 0

    function isCustomSymbol(name) {
        return root.customSymbolsReady && KitSymbolNames.names[name] === 1;
    }

    function symbolFamily(name, filled) {
        if (root.isCustomSymbol(name))
            return filled ? customFillLoader.name : customLineLoader.name;
        return root.iconMaterialFamily;
    }

    FontLoader {
        id: customLineLoader
        source: Qt.resolvedUrl("qrc:/PlateKit/fonts/KitSymbols.ttf")
    }

    FontLoader {
        id: customFillLoader
        source: Qt.resolvedUrl("qrc:/PlateKit/fonts/KitSymbolsFill.ttf")
    }

    FontLoader {
        id: materialSymbolsLoader
        source: Qt.resolvedUrl("qrc:/PlateKit/fonts/MaterialSymbolsRounded.ttf")
        onStatusChanged: {
            if (materialSymbolsLoader.status === FontLoader.Error)
                console.error("[Fonts] Could not load assets/fonts/MaterialSymbolsRounded.ttf - icons will not render.")
        }
    }
}
