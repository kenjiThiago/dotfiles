pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "."

Rectangle {
    id: island

    property int islandState: 0
    property var hostWindow: null

    signal requestState(int newState)
    signal calendarRequested

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 6
    clip: true

    property bool isLoaded: false
    Component.onCompleted: Qt.callLater(function () {
        island.isLoaded = true;
    })

    readonly property var kanjiIcons: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    // ── CONTROLE DO OSD ───────────────────────────────────────────────────────
    property string activeMode: "clock"
    Timer {
        id: resetTimer
        interval: 1000
        onTriggered: {
            // Antes quem segurava o OSD aberto durante o arrasto era o
            // osdRequested que o poll do brilho disparava sem querer. Com o poll
            // calado enquanto o usuário mexe, o segurar tem que ser explícito.
            if (osdArea.pressed) {
                resetTimer.restart();
                return;
            }
            island.activeMode = "clock";
        }
    }

    Connections {
        target: SystemMonitor
        function onOsdRequested(newVal) {
            if (island.islandState !== 2) {
                island.activeMode = "brightness";
                resetTimer.restart();
            }
        }
    }

    // ── MATEMÁTICA DA UI E ESTADOS ────────────────────────────────────────────
    Text {
        id: measureS0
        text: Time.timeString
        font.family: "Hack Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
        visible: false
    }
    Text {
        id: measureS1Clock
        text: Time.timeString
        font.family: "Hack Nerd Font"
        font.pixelSize: 24
        font.weight: Font.Bold
        visible: false
    }
    Text {
        id: measureS1Date
        text: Time.dateString
        font.family: "Hack Nerd Font"
        font.pixelSize: 11
        visible: false
    }

    property real wsBaseW: wsRow.implicitWidth
    property real wsW: wsBaseW + 28

    property real statusW: statusItems.implicitWidth + 34
    property real clockS0W: measureS0.implicitWidth + 28
    property real clockS1W: Math.max(measureS1Clock.implicitWidth, measureS1Date.implicitWidth) + 42

    property real alertW: state0Alerts.width
    property real state0Width: island.clockS0W + 34 + island.wsW + island.alertW
    property real state1Width: 64 + island.wsW + island.clockS1W + island.statusW

    implicitWidth: {
        if (island.activeMode === "brightness")
            return 260;
        if (island.islandState === 0)
            return island.state0Width;
        if (island.islandState === 1)
            return island.state1Width;
        return 450;
    }

    implicitHeight: {
        if (island.activeMode === "brightness")
            return 36;
        if (island.islandState === 0)
            return 36;
        if (island.islandState === 1)
            return 64;
        return 352;
    }

    radius: {
        if (island.islandState === 0)
            return 19;
        if (island.islandState === 1)
            return 32;
        return 24;
    }

    color: Theme.base
    border.color: Theme.overlay
    border.width: 1

    Behavior on implicitWidth {
        enabled: island.isLoaded
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    Behavior on implicitHeight {
        enabled: island.isLoaded
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    Behavior on radius {
        enabled: island.isLoaded
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: function (mouse) {
            if (island.activeMode !== "brightness") {
                if (island.islandState === 0)
                    island.requestState(1);
                else
                    island.requestState(0);
            }
        }
    }

    // ==========================================================================
    // ── CAMADA 1: A PÍLULA (ESTADOS 0 E 1) ────────────────────────────────────
    // ==========================================================================
    Item {
        anchors.fill: parent
        opacity: (island.islandState < 2 && island.activeMode === "clock") ? 1 : 0
        visible: opacity > 0
        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: 250
        //     }
        // }

        Row {
            anchors.centerIn: parent
            height: parent.height
            spacing: island.islandState === 1 ? 16 : 0

            Behavior on spacing {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            // ESQUERDA: WORKSPACES
            Item {
                width: island.wsW
                height: parent.height
                clip: true
                opacity: 1
                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 6
                    Repeater {
                        model: Hyprland.workspaces
                        delegate: Rectangle {
                            id: wsDelegate
                            required property var modelData
                            readonly property bool isActive: modelData.focused
                            width: isActive ? 36 : 24
                            height: 24
                            radius: 12
                            color: isActive ? Theme.cyan : "transparent"
                            Behavior on width {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                color: wsDelegate.isActive ? Theme.base : Theme.muted
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                text: {
                                    if (wsDelegate.modelData.name.startsWith("special") || wsDelegate.modelData.id < 0) {
                                        return "";
                                    }
                                    const idx = wsDelegate.modelData.id - 1;
                                    return (idx >= 0 && idx < island.kanjiIcons.length) ? island.kanjiIcons[idx] : wsDelegate.modelData.name;
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function (m) {
                                    m.accepted = true;
                                    wsDelegate.modelData.activate();
                                }
                            }
                        }
                    }
                }
            }

            // CENTRO: RELÓGIO (BOTÃO)
            Rectangle {
                id: clockBtn
                width: island.islandState === 1 ? island.clockS1W : island.clockS0W
                height: island.islandState === 1 ? 46 : 32
                anchors.verticalCenter: parent.verticalCenter
                radius: height / 2
                color: clockMouse.pressed ? Theme.overlay : (clockMouse.containsMouse && island.islandState === 1 ? Theme.surface : "transparent")

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    Text {
                        anchors.centerIn: parent
                        text: Time.timeString
                        color: Theme.cyan
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        opacity: island.islandState === 0 ? 1 : 0
                        visible: opacity > 0
                        // Behavior on opacity {
                        //     NumberAnimation {
                        //         duration: 200
                        //     }
                        // }
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        opacity: island.islandState === 1 ? 1 : 0
                        visible: opacity > 0
                        // Behavior on opacity {
                        //     NumberAnimation {
                        //         duration: 200
                        //     }
                        // }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Time.timeString
                            color: Theme.cyan
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Time.dateString
                            color: Theme.text
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 11
                        }
                    }
                }
                MouseArea {
                    id: clockMouse
                    anchors.fill: parent
                    hoverEnabled: island.islandState === 1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function (m) {
                        m.accepted = true;
                        if (island.islandState === 0)
                            island.requestState(1);
                        else
                            island.calendarRequested();
                    }
                }
            }

            Item {
                id: state0Alerts

                width: island.islandState === 0 && alertRow.implicitWidth > 0 ? alertRow.implicitWidth + 28 : 0
                height: parent.height
                clip: true
                opacity: island.islandState === 0 ? 1 : 0
                visible: opacity > 0

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    id: alertRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰈸"
                        color: Theme.accent
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 15

                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.verticalCenterOffset: -1

                        visible: SystemMonitor.tempC >= 80
                    }

                    Text {
                        text: "󰂃"
                        color: Theme.accent
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 15

                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -1

                        visible: SystemMonitor.pct <= 20 && !SystemMonitor.isCharging
                    }
                }
            }

            // DIREITA: STATUS E ALERTAS
            Item {
                width: island.islandState === 1 ? island.statusW : 0
                height: parent.height
                clip: true
                opacity: island.islandState === 1 ? 1 : 0
                visible: opacity > 0
                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    id: statusBtn
                    anchors.centerIn: parent
                    width: island.statusW
                    height: 38
                    radius: 19
                    color: statusMouse.pressed ? Theme.overlay : (statusMouse.containsMouse ? Theme.surface : "transparent")
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Row {
                        id: statusItems
                        anchors.centerIn: parent
                        spacing: 12

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: SystemMonitor.isMuted ? "󰝟" : "󰕾"
                                color: Theme.blue
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 16
                            }
                            Text {
                                text: SystemMonitor.volumePct + "%"
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: SystemMonitor.battIcon
                                color: SystemMonitor.isCharging ? Theme.success : Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 15
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: SystemMonitor.pct + "%"
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    MouseArea {
                        id: statusMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function (m) {
                            m.accepted = true;
                            island.requestState(2);
                        }
                    }
                }
            }
        }
    }

    // ==========================================================================
    // ── CAMADA OSD: BRILHO ────────────────────────────────────────────────────
    // ==========================================================================
    RowLayout {
        anchors.centerIn: parent
        spacing: 12
        opacity: island.activeMode === "brightness" ? 1 : 0
        visible: opacity > 0
        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: 200
        //     }
        // }

        Text {
            text: "󰃠"
            color: Theme.text
            font.family: "Hack Nerd Font"
            font.pixelSize: 16
        }
        Rectangle {
            id: osdTrack
            Layout.preferredWidth: 160
            Layout.preferredHeight: 6
            radius: 3
            color: Theme.surface
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 3
                color: Theme.yellow
                width: parent.width * (SystemMonitor.currentBrightness / 100)
                // Durante o arrasto a barra tem que grudar no cursor. A animação
                // é para quando o brilho muda por fora, pelo teclado.
                Behavior on width {
                    enabled: !osdArea.pressed
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.yellow
                    anchors.horizontalCenter: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                id: osdArea
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                // As margens negativas engordam a área de clique, então m.x não
                // é a posição na trilha: sem o mapToItem a ponta esquerda dá 8px
                // em vez de 0.
                function applyAt(m) {
                    SystemMonitor.setBrightness(100 * mapToItem(osdTrack, m.x, 0).x / osdTrack.width);
                    resetTimer.restart();
                }
                onPressed: function (m) {
                    applyAt(m);
                }
                onPositionChanged: function (m) {
                    if (pressed)
                        applyAt(m);
                }
            }
        }
    }

    // ==========================================================================
    // ── CAMADA 2: INJETA O CONTROLE CENTRAL MODULAR ───────────────────────────
    // ==========================================================================
    ControlCenter {
        width: parent.width
        y: 0

        hostWindow: island.hostWindow
        opacity: island.islandState === 2 ? 1 : 0
        visible: opacity > 0
        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: 300
        //         easing.type: Easing.OutCubic
        //     }
        // }

        onRequestClose: island.requestState(0)
        onRequestCalendar: island.calendarRequested()
    }
}
