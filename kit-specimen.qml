//@ pragma UseQApplication
// Design-system specimen: a standalone window drawn entirely from the kit —
// Appearance tokens, Plate inks, the widget library. No hex, no off-token durations,
// no hardcoded type: scripts/lint-design-system.mjs on this file stays clean.
// Run from the kit root:  qs -p kit-specimen.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

FloatingWindow {
    id: win

    title: "Specimen"
    color: "transparent"
    visible: true
    implicitWidth: 920
    implicitHeight: 780
    minimumSize: Qt.size(760, 640)

    // The palette comes from the generated theme the shell uses; if that file is
    // absent, Appearance's fallback literals stand.
    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme();
        // A headless check scrolls to a given band first: SPECIMEN_SCROLL in px.
        const from = Number(Quickshell.env("SPECIMEN_SCROLL") || 0);
        if (from > 0) scroll.contentY = from;
    }

    // The body. Real app windows paint termBase at Plate.windowSeeThrough over the
    // compositor's blur; the specimen has no blur rule of its own, so it stands
    // opaque on the ground the panels stand on.
    Rectangle {
        id: body

        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Plate.ground

        // The one hairline the shell keeps under a window's header, edge to edge.
        Rectangle {
            width: parent.width
            height: 1
            color: Plate.hairline
        }

        Flickable {
            id: scroll

            anchors.fill: parent
            anchors.topMargin: 1
            contentWidth: width
            contentHeight: page.implicitHeight + Appearance.spacing.verylarge * 2
            clip: true

            Column {
                id: page

                x: Appearance.spacing.panel
                y: Appearance.spacing.verylarge
                width: scroll.width - Appearance.spacing.panel * 2
                spacing: Appearance.spacing.verylarge

                // ------------------------------------------------------- title
                Column {
                    width: page.width
                    spacing: Appearance.spacing.tiny

                    StyledText {
                        text: "Specimen"
                        font.family: Appearance.font.family.display
                        font.pixelSize: Plate.size.headline
                        font.weight: Font.DemiBold
                        color: Plate.inkMain
                    }
                    StyledText {
                        text: "Plate's design system, drawn from your wallpaper's palette: the inks, the type, the rounds, the parts."
                        font.pixelSize: Plate.size.meta
                        color: Plate.inkMeta
                        width: page.width
                    }
                }

                // -------------------------------------------------------- inks
                SpecimenSection {
                    width: page.width
                    headline: "Ink"
                    note: "Text is ink at a fixed APCA contrast on this ground, never opacity. Each level is solved, so the ladder holds whatever the palette."

                    Column {
                        width: parent.width
                        spacing: Appearance.spacing.small

                        InkLadderRow {
                            width: parent.width
                            ink: Plate.inkMain
                            label: "main · Lc 92"
                            sentence: "Text is ink at a fixed contrast, never opacity."
                        }
                        InkLadderRow {
                            width: parent.width
                            ink: Plate.inkSec
                            label: "secondary · Lc 85"
                            sentence: "Secondary carries the explanation, not the decision."
                        }
                        InkLadderRow {
                            width: parent.width
                            ink: Plate.inkMeta
                            label: "meta · Lc 75"
                            sentence: "Times and counts sit at the floor for 13 px."
                        }
                        InkLadderRow {
                            width: parent.width
                            ink: Plate.inkFaint
                            label: "faint · Lc 60"
                            sentence: "Faint waits under the fold: placeholders, folds."
                        }
                    }
                }

                // -------------------------------------------------------- type
                SpecimenSection {
                    width: page.width
                    headline: "Type"
                    note: "Six sizes, hierarchy by size and weight; the cuts divide the work. Digits keep tabular figures in the numbers face."

                    Column {
                        width: parent.width
                        spacing: Appearance.spacing.smallish

                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.alarm
                            face: Appearance.font.family.display
                            weight: Font.ExtraBold
                            sample: "Rest, peek, open, pin."
                        }
                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.headline
                            face: Appearance.font.family.title
                            weight: Font.DemiBold
                            sample: "The quiet notch."
                        }
                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.section
                            face: Appearance.font.family.title
                            weight: Font.DemiBold
                            sample: "Everything else is reached from the palette."
                        }
                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.body
                            face: Appearance.font.family.main
                            weight: Font.Normal
                            sample: "When something finishes, it says so in one line, then goes quiet."
                        }
                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.row
                            face: Appearance.font.family.compact
                            weight: Font.Normal
                            sample: "Wallpaper, colours, type and how much shows through."
                        }
                        TypeLadderRow {
                            width: parent.width
                            size: Plate.size.meta
                            face: Appearance.font.family.compact
                            weight: Font.Normal
                            sample: "4 AM session wants to know when to plug in."
                        }
                        StyledText {
                            text: "2m 41s"
                            font.family: Appearance.font.family.numbers
                            font.pixelSize: Plate.size.section
                            color: Plate.inkMain
                        }
                    }
                }

                // ------------------------------------------------------- rounds
                SpecimenSection {
                    width: page.width
                    headline: "Rounds"
                    note: "Radii are a ladder, not choices: every surface takes its corner from here."

                    Row {
                        spacing: Appearance.spacing.smallish

                        RoundTile { token: Appearance.rounding.unsharpenmore }
                        RoundTile { token: Appearance.rounding.verysmall }
                        RoundTile { token: Appearance.rounding.chip }
                        RoundTile { token: Appearance.rounding.small }
                        RoundTile { token: Appearance.rounding.card }
                        RoundTile { token: Appearance.rounding.normal }
                        RoundTile { token: Appearance.rounding.large }
                        RoundTile { token: Appearance.rounding.verylarge }
                    }
                }

                // ------------------------------------------------------ colour
                SpecimenSection {
                    width: page.width
                    headline: "Colour"
                    note: "Layers make the ground; sand is the one forward action; clay carries a failure said without alarm."

                    Row {
                        spacing: Appearance.spacing.smallish

                        ColourTile { name: "layer1"; swatch: Appearance.colors.colLayer1 }
                        ColourTile { name: "layer2"; swatch: Appearance.colors.colLayer2 }
                        ColourTile { name: "layer3"; swatch: Appearance.colors.colLayer3 }
                        ColourTile { name: "layer4"; swatch: Appearance.colors.colLayer4 }
                        ColourTile { name: "accent"; swatch: Appearance.colors.colPrimary }
                        ColourTile { name: "risk"; swatch: Appearance.colors.colError }
                        ColourTile { name: "clay"; swatch: Appearance.colors.colClay }
                    }
                }

                // ------------------------------------------------------ actions
                SpecimenSection {
                    width: page.width
                    headline: "Actions"
                    note: "Hover and press come from the layer ladder; the accent is the one forward action; a pill is for dialogs. Nothing rests on a shadow."

                    Column {
                        width: parent.width
                        spacing: Appearance.spacing.normal

                        Row {
                            spacing: Appearance.spacing.normal

                            RippleButton {
                                implicitWidth: implicitContentWidth + horizontalPadding * 2
                                horizontalPadding: Appearance.spacing.normal
                                implicitHeight: 36
                                buttonRadius: height / 2
                                contentItem: StyledText {
                                    text: "Ripple"
                                    color: Plate.inkMain
                                }
                            }
                            RippleButton {
                                implicitWidth: implicitContentWidth + horizontalPadding * 2
                                horizontalPadding: Appearance.spacing.normal
                                implicitHeight: 36
                                buttonRadius: height / 2
                                contentItem: StyledText {
                                    text: "Accent"
                                    color: Plate.onAccent
                                }
                                toggled: true
                            }
                            DialogButton {
                                buttonText: "Forward"
                                colBackground: Appearance.colors.colPrimary
                                colBackgroundHover: Appearance.colors.colPrimaryHover
                                colRipple: Appearance.colors.colPrimaryActive
                                colText: Plate.onAccent
                            }
                        }
                        GroupVerbRow {}
                    }
                }

                // ------------------------------------------------------- inputs
                SpecimenSection {
                    width: page.width
                    headline: "Inputs"
                    note: "A quiet field on a pill; the whole row is the switch's target; sliders keep thin tracks and a percent tooltip."

                    Column {
                        width: parent.width
                        spacing: Appearance.spacing.normal

                        MaterialTextField {
                            width: 360
                            placeholderText: "Search paths"
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
                            StyledText {
                                text: "off"
                                font.pixelSize: Plate.size.meta
                                color: Plate.inkMeta
                            }
                            StyledSwitch {}
                        }
                        Row {
                            spacing: Appearance.spacing.verylarge

                            StyledSlider {
                                width: 260
                                value: 0.42
                                configuration: StyledSlider.Configuration.M
                            }
                            StyledSlider {
                                width: 260
                                value: 0.68
                                configuration: StyledSlider.Configuration.Wavy
                            }
                        }
                        StyledProgressBar {
                            width: 260
                            value: 0.68
                            wavy: true
                        }
                    }
                }

                // ------------------------------------------------------- motion
                SpecimenSection {
                    width: page.width
                    headline: "Motion"
                    note: "One curve vocabulary. Out comes in at emphasized decel, 400 ms; back out at emphasized accel, 200 ms."

                    MotionDemo {}
                }

                // ---------------------------------------------------- feedback
                SpecimenSection {
                    width: page.width
                    headline: "Feedback"
                    note: "The loading disc morphs through the M3 shape set: SoftBurst, Cookie9, Pentagon, Pill, Sunny, Cookie4, Oval."

                    Row {
                        spacing: Appearance.spacing.verylarge

                        MaterialLoadingIndicator {}
                        Column {
                            width: page.width - MaterialLoadingIndicator.implicitWidth - Appearance.spacing.verylarge * 2
                            spacing: Appearance.spacing.tiny
                            y: Appearance.spacing.smallish

                            NoticeBox {
                                width: parent.width
                                materialIcon: "widgets"
                                text: "Everything here is a token or a kit part. Run scripts/lint-design-system.mjs on this file and it stays clean."
                            }
                        }
                    }
                }
            }
        }
    }

    // --------------------------------------------------------------- section part
    component SpecimenSection: Column {
        id: section

        default property alias sectionBody: sectionBody.data
        property string headline
        property string note

    spacing: Appearance.spacing.smallish

    StyledText {
        text: section.headline
        font.family: Appearance.font.family.title
        font.pixelSize: Plate.size.section
        font.weight: Font.DemiBold
        color: Plate.inkMain
    }
    StyledText {
        text: section.note
        font.pixelSize: Plate.size.meta
        color: Plate.inkMeta
        width: section.width
    }
    Column {
        id: sectionBody

        width: section.width
        spacing: Appearance.spacing.normal
    }
}

component InkLadderRow: Row {
    id: inkRow

    required property color ink
    required property string label
    required property string sentence

    spacing: Appearance.spacing.normal

    StyledText {
        text: inkRow.label
        font.family: Appearance.font.family.compact
        font.pixelSize: Plate.size.meta
        color: Plate.inkMeta
        width: 180
    }
    StyledText {
        text: inkRow.sentence
        font.pixelSize: Plate.size.row
        color: inkRow.ink
        width: parent.width - 180 - parent.spacing
    }
}

component TypeLadderRow: Row {
    id: typeRow

    required property int size
    required property string face
    required property int weight
    required property string sample

    spacing: Appearance.spacing.normal

    StyledText {
        text: typeRow.sample
        font.family: typeRow.face
        font.pixelSize: typeRow.size
        font.weight: typeRow.weight
        color: Plate.inkMain
        elide: Text.ElideRight
        width: parent.width - 64 - parent.spacing
    }
    StyledText {
        text: `${typeRow.size} px`
        font.family: Appearance.font.family.numbers
        font.pixelSize: Plate.size.meta
        color: Plate.inkMeta
        width: 64
    }
}

component RoundTile: Column {
    id: roundTile

    required property int token

    spacing: Appearance.spacing.tiny

    Rectangle {
        width: 56
        height: 40
        radius: roundTile.token
        color: Plate.raised
    }
    StyledText {
        text: `${roundTile.token}`
        font.family: Appearance.font.family.numbers
        font.pixelSize: Plate.size.meta
        color: Plate.inkMeta
        width: 56
        horizontalAlignment: Text.AlignHCenter
    }
}

component ColourTile: Column {
    id: colourTile

    required property string name
    required property color swatch

    spacing: Appearance.spacing.tiny

    Rectangle {
        width: 76
        height: 48
        radius: Appearance.rounding.small
        color: colourTile.swatch
    }
    StyledText {
        text: colourTile.name
        font.family: Appearance.font.family.compact
        font.pixelSize: Plate.size.meta
        color: Plate.inkMeta
        width: 76
        horizontalAlignment: Text.AlignHCenter
    }
}

component GroupVerbRow: Row {
    id: verbRow

    property int choice: 0

    spacing: Appearance.spacing.small

    Repeater {
        model: ["Rest", "Peek", "Open", "Pin"]

        GroupButton {
            id: verbButton
            required property string modelData
            required property int index

            buttonText: modelData
            padding: Appearance.spacing.normal
            toggled: verbRow.choice === index
            onClicked: verbRow.choice = index
        }
    }
}

component MotionDemo: Column {
    id: motionDemo

    property bool out: false

    spacing: Appearance.spacing.normal

    Rectangle {
        id: lane

        width: parent.width
        height: 48
        radius: Appearance.rounding.small
        color: Plate.raised

        Rectangle {
            id: knob

            x: 0
            y: Appearance.spacing.small
            width: 120
            height: 32
            radius: Appearance.rounding.small
            color: Appearance.colors.colPrimary

            states: State {
                name: "out"
                when: motionDemo.out
                PropertyChanges {
                    target: knob
                    x: lane.width - knob.width
                }
            }
            transitions: [
                Transition {
                    from: ""
                    to: "out"
                    NumberAnimation {
                        duration: Appearance.animation.elementMoveEnter.duration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animation.elementMoveEnter.bezierCurve
                    }
                },
                Transition {
                    from: "out"
                    to: ""
                    NumberAnimation {
                        duration: Appearance.animation.elementMoveExit.duration
                        easing.type: Appearance.animation.elementMoveExit.type
                        easing.bezierCurve: Appearance.animation.elementMoveExit.bezierCurve
                    }
                }
            ]
        }
    }
    RippleButton {
        implicitWidth: implicitContentWidth + horizontalPadding * 2
        horizontalPadding: Appearance.spacing.normal
        implicitHeight: 36
        buttonRadius: height / 2
        contentItem: StyledText {
            text: motionDemo.out ? "Back with the exit curve" : "Run the enter curve"
            color: motionDemo.out ? Plate.onAccent : Plate.inkMain
        }
        toggled: motionDemo.out
        onReleased: motionDemo.out = !motionDemo.out
    }
}
}
