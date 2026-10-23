pragma Singleton
import QtQuick
import Quickshell

// The kit's root singleton. It is load-bearing for import resolution: Quickshell
// synthesizes the root's qmldir from the uppercase-named files in the root, and a
// root module with no entries resolves as "module qs is not installed". Keep at
// least one file here. Toolkit-wide app state (a shared flag, an app-host session
// id) belongs on this object — never tokens; tokens live in Appearance.qml.
Singleton {
    id: root

    property string name: "plate-kit"
}
