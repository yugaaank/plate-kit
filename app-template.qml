//@ pragma UseQApplication
// The starter for a new app on the kit. Copy this file, rename it, and build.
// Everything imports from this tree only: no tacit repo, no desktop shell.
//
// Run:  qs -p app-template.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

FloatingWindow {
    id: win

    title: "Kit App"
    color: "transparent"
    visible: true
    implicitWidth: 620
    implicitHeight: 560
    minimumSize: Qt.size(480, 420)

    // The palette is the generated theme if it exists, Appearance literals if not.
    Component.onCompleted: MaterialThemeLoader.reapplyTheme()

    // The body: one ground, one header hairline, sections by spacing. No card grids,
    // no borders, no shadows at rest.
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Plate.ground

        Rectangle {
            width: parent.width
            height: 1
            color: Plate.hairline
        }

        Column {
            id: page

            x: Appearance.spacing.panel
            y: Appearance.spacing.verylarge
            width: win.width - Appearance.spacing.panel * 2
            spacing: Appearance.spacing.verylarge

            Column {
                width: page.width
                spacing: Appearance.spacing.tiny

                StyledText {
                    text: "Kit App"
                    font.family: Appearance.font.family.display
                    font.pixelSize: Plate.size.headline
                    font.weight: Font.DemiBold
                    color: Plate.inkMain
                }
                StyledText {
                    text: "A one-paragraph sentence about what this app does; it reads like the store blurbs, not like a changelog."
                    font.pixelSize: Plate.size.meta
                    color: Plate.inkMeta
                    width: page.width
                }
            }

            // --- a group: heading, then rows on the panel layer -----------------
            Column {
                width: page.width
                spacing: Appearance.spacing.smallish

                StyledText {
                    text: "Setup"
                    font.family: Appearance.font.family.title
                    font.pixelSize: Plate.size.section
                    font.weight: Font.DemiBold
                    color: Plate.inkMain
                }

                Rectangle {
                    width: page.width
                    radius: Appearance.rounding.card
                    color: Appearance.colors.colLayer1
                    implicitHeight: rowsColumn.implicitHeight + Appearance.spacing.small * 2

                    Column {
                        id: rowsColumn

                        x: Appearance.spacing.small
                        y: Appearance.spacing.small
                        width: parent.width - Appearance.spacing.small * 2
                        spacing: Appearance.spacing.smallish

                        Row {
                            spacing: Appearance.spacing.normal

                            StyledText {
                                text: "Name"
                                font.pixelSize: Plate.size.row
                                color: Plate.inkMain
                            }
                            MaterialTextField {
                                width: 260
                                placeholderText: "Search paths"
                            }
                        }
                        Row {
                            spacing: Appearance.spacing.normal

                            StyledText {
                                text: "Dictation"
                                font.pixelSize: Plate.size.row
                                color: Plate.inkMain
                            }
                            StyledSwitch {
                                checked: true
                            }
                        }
                    }
                }

                // --- actions: one accent, the rest layered -----------------------
                // The kit's own idiom for a text action on RippleButton is the
                // ToolbarTabButton pattern: override contentItem with
                // `anchors.centerIn: parent` (a bare StyledText is layed out at the
                // padding corner, never centred, and Control resizes it to fit, so
                // sizing from `contentItem.implicitWidth` shrinks the pill) and size
                // from implicitContentWidth instead.
                Row {
                    spacing: Appearance.spacing.normal

                    RippleButton {
                        implicitWidth: implicitContentWidth + horizontalPadding * 2
                        horizontalPadding: Appearance.spacing.normal
                        implicitHeight: 36
                        buttonRadius: height / 2
                        contentItem: StyledText {
                            text: "Primary"
                            color: Plate.onAccent
                        }
                        toggled: true
                    }
                    RippleButton {
                        implicitWidth: implicitContentWidth + horizontalPadding * 2
                        horizontalPadding: Appearance.spacing.normal
                        implicitHeight: 36
                        buttonRadius: height / 2
                        contentItem: StyledText {
                            text: "Secondary"
                        }
                    }
                    DialogButton {
                        buttonText: "Forward"
                        colBackground: Appearance.colors.colPrimary
                        colBackgroundHover: Appearance.colors.colPrimaryHover
                        colRipple: Appearance.colors.colPrimaryActive
                        colText: Plate.onAccent
                    }
                }

                NoticeBox {
                    width: page.width
                    materialIcon: "info"
                    text: "Everything here is a token or a kit part — run the lint and it stays clean."
                }
            }
        }
    }
}
