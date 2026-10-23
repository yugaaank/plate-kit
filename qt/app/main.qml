import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PlateKit

// The starter for a plain-Qt Plate app. Copy this file when starting a real app.
// The window is a plain ApplicationWindow: its chrome, corners and shadow come
// from the platform (KWin on Plasma), not from the compositor-look the shell's
// own windows had.
ApplicationWindow {
    id: root

    width: 620
    height: 460
    visible: true
    title: "Plate — plain Qt"
    color: Plate.ground

    Component.onCompleted: PlateThemeLoader.reapplyTheme()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Appearance.spacing.panel

        Row {
            spacing: Appearance.spacing.normal
            Layout.alignment: Qt.AlignHCenter

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                iconSize: 26
                text: "palette"
                color: Plate.accent
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Plate on plain Qt"
                font.pixelSize: Plate.size.headline
                font.family: Appearance.font.family.title
                color: Plate.inkMain
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 500
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: "Same tokens, same widgets, same inks — running as an ordinary Qt binary with no Quickshell. The one-accent rule and the ink ladder are unchanged."
            font.pixelSize: Plate.size.meta
            color: Plate.inkSec
        }

        // --- the kit's text-action idiom (ToolbarTabButton pattern) ----------
        Row {
            spacing: Appearance.spacing.normal
            Layout.alignment: Qt.AlignHCenter

            ToolbarTabButton {
                materialSymbol: "done"
                current: true
                implicitHeight: 36
            }
            DialogButton {
                buttonText: "Forward"
            }
            DialogButton {
                buttonText: "Out"
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                colRipple: Appearance.colors.colInkFaint
            }
        }

        // --- a toggle row ----------------------------------------------------
        Row {
            spacing: Appearance.spacing.normal
            Layout.alignment: Qt.AlignHCenter

            StyledSwitch {
                id: wavyToggle
                checked: true
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Wavy progress"
                font.pixelSize: Plate.size.row
                color: Plate.inkMain
            }
        }

        StyledProgressBar {
            Layout.alignment: Qt.AlignHCenter
            valueBarWidth: 260
            value: progressAnim.progress
            wavy: wavyToggle.checked

            SequentialAnimation on value {
                id: progressAnim
                property real progress: 0
                NumberAnimation { from: 0; to: 1; duration: 3600; easing.type: Easing.Linear }
            }
        }

        // --- a notice with actions -------------------------------------------
        NoticeBox {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 420
            materialIcon: "info"
            text: "kit-owned config, wallpaper palette, Basic style — nothing shared with the desktop shell."

            DialogButton {
                buttonText: "Got it"
                height: 30
            }
        }
    }
}
