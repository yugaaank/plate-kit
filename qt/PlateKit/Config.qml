pragma Singleton

/**
 * The Qt port's config backstop.
 *
 * In the Quickshell kit this role is played by Config.qml (a JsonAdapter over
 * ~/.config/plate-kit/config.json). Quickshell types have no Qt equivalent, so
 * the port ships only the options tree that ported kit files actually read,
 * with the kit's compiled-in defaults. Values are frozen here on purpose:
 * a Qt app has its own settings story (QSettings, dialogs, plain properties).
 *
 * If the Appearance/Plate port grows a new Config.options.* read, add the
 * path here with the kit default. That's the whole maintenance contract.
 */
import QtQuick

pragma ComponentBehavior: Bound

QtObject {
    readonly property QtObject options: QtObject {
        readonly property bool extraBackgroundTint: true

        readonly property QtObject appearance: QtObject {
            readonly property QtObject fonts: QtObject {
                property string main: "Tacit Sans"
                property string numbers: "Tacit Sans"
                property string title: "Tacit Sans"
                property string iconNerd: "JetBrainsMono Nerd Font"
                property string monospace: "Tacit Code"
                property string reading: "Tacit Sans"
                property string expressive: "Tacit Sans"
            }
            readonly property QtObject transparency: QtObject {
                property bool enable: true
                property bool automatic: true
                property real backgroundTransparency: 0.4
                property real contentTransparency: 0.9
            }
        }

        readonly property QtObject bar: QtObject {
            property int cornerStyle: 0 // 0: Hug | 1: Float | 2: Plain rectangle
        }

        readonly property QtObject background: QtObject {
            property string wallpaperPath: ""
            property string thumbnailPath: ""
        }
    }
}
