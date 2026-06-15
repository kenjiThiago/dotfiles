pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.UPower
import "."

Rectangle {
    id: island
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 12
    clip: true

    // ── A MÁGICA CONTRA O BUG DE INICIALIZAÇÃO ────────────────────────────────
    property bool isLoaded: false
    Component.onCompleted: Qt.callLater(() => isLoaded = true)

    // ── Estado ────────────────────────────────────────────────────────────────
    property bool expanded: false
    property string activeMode: "clock"
    property real currentBrightness: -1

    signal toggleRequested
    signal calendarRequested

    readonly property var kanjiIcons: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    // ── Bateria ───────────────────────────────────────────────────────────────
    property var device: UPower.displayDevice
    property bool isValid: device !== null

    property int pct: isValid ? Math.round(device.percentage) * 100 : 0
    property int battery_state: isValid ? device.state : UPowerDeviceState.Unknown

    property bool isCharging: battery_state === UPowerDeviceState.Charging || battery_state === UPowerDeviceState.FullyCharged
    property bool isCritical: pct <= 20
    property bool isLow: pct <= 30

    property string battIcon: {
        if (isCharging)
            return "󰂄";
        if (pct <= 10)
            return "󰁺";
        if (pct <= 30)
            return "󰁼";
        if (pct <= 50)
            return "󰁾";
        if (pct <= 80)
            return "󰂀";
        return "󰁹";
    }

    property color battColor: {
        if (isCharging)
            return Theme.pine;
        if (isCritical)
            return Theme.love;
        if (isLow)
            return Theme.gold;
        return Theme.pine;
    }

    // ── Perfil de energia ─────────────────────────────────────────────────────
    readonly property string ppIcon: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return "󱐋";
        case PowerProfile.PowerSaver:
            return "󰌪";
        default:
            return "󰈐";
        }
    }

    readonly property color ppColor: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return Theme.love;
        case PowerProfile.PowerSaver:
            return Theme.pine;
        default:
            return Theme.foam;
        }
    }

    readonly property string ppLabel: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return "Performance";
        case PowerProfile.PowerSaver:
            return "Power Saver";
        default:
            return "Balanced";
        }
    }

    function cycleProfile() {
        switch (PowerProfiles.profile) {
        case PowerProfile.Balanced:
            PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        case PowerProfile.PowerSaver:
            PowerProfiles.profile = PowerProfile.Performance;
            break;
        default:
            PowerProfiles.profile = PowerProfile.Balanced;
            break;
        }
    }

    // ── Brilho ────────────────────────────────────────────────────────────────
    Timer {
        id: resetTimer
        interval: 1500
        onTriggered: island.activeMode = "clock"
    }

    function showBrightness(val) {
        currentBrightness = val;
        activeMode = "brightness";
        resetTimer.restart();
    }

    Process {
        id: brightnessCmd
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                const newVal = parseInt(line.trim());
                if (isNaN(newVal))
                    return;

                if (island.currentBrightness === -1) {
                    island.currentBrightness = newVal;
                } else if (newVal !== island.currentBrightness) {
                    if (island.expanded && island.activeMode === "clock") {
                        island.currentBrightness = newVal;
                    } else {
                        island.showBrightness(newVal);
                    }
                }
            }
        }
    }

    Process {
        id: writeBrightnessCmd
        running: false
    }

    function setHardwareBrightness(percent) {
        let safePct = Math.max(0, Math.min(100, Math.round(percent)));
        writeBrightnessCmd.command = ["sh", "-c", "brightnessctl set " + safePct + "%"];
        writeBrightnessCmd.running = true;
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: brightnessCmd.running = true
    }

    // ── Dimensões e animações da Raiz (Dynamic Island Clássico) ───────────────
    implicitWidth: {
        if (activeMode === "brightness")
            return 260;
        let currentContent = expanded ? expandedView.implicitWidth : collapsedView.implicitWidth;
        return wsRow.implicitWidth + currentContent + 70;
    }
    implicitHeight: expanded ? 72 : 36
    radius: expanded ? 20 : Math.min(height / 2, 26)
    color: Theme.base

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

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        id: islandMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (island.activeMode !== "brightness")
                island.toggleRequested();
        }
    }

    // ── Dashboard Principal ───────────────────────────────────────────────────
    Row {
        anchors.centerIn: parent
        spacing: 16
        opacity: island.activeMode !== "brightness" ? 1 : 0
        visible: opacity > 0

        // ── Workspaces ────────────────────────────────────────────────────────────
        Row {
            id: wsRow
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    id: wsDelegate
                    required property HyprlandWorkspace modelData
                    readonly property bool isActive: wsDelegate.modelData.focused
                    readonly property string kanjiIcon: {
                        const idx = wsDelegate.modelData.id - 1;
                        return (idx >= 0 && idx < island.kanjiIcons.length) ? island.kanjiIcons[idx] : wsDelegate.modelData.name;
                    }

                    width: isActive ? 50 : 27
                    height: 26
                    Behavior on width {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 13
                        color: wsDelegate.isActive ? Theme.rose : Theme.surface
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: wsDelegate.kanjiIcon
                            color: wsDelegate.isActive ? Theme.base : Theme.muted
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }

                    TapHandler {
                        onTapped: function (eventPoint) {
                            eventPoint.accepted = true;
                            wsDelegate.modelData.activate();
                        }
                    }
                }
            }
        }

        // ── Divisor Estético ──────────────────────────────────────────────────────
        Rectangle {
            width: 1
            height: island.expanded ? 40 : 18
            color: Theme.overlay
            anchors.verticalCenter: parent.verticalCenter
            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ── Área do Relógio / Painel Expandido ────────────────────────────────────
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: island.expanded ? expandedView.implicitWidth : collapsedView.implicitWidth
            height: island.expanded ? expandedView.implicitHeight : collapsedView.implicitHeight

            // 1. Visão Colapsada (Apenas Relógio)
            Text {
                id: collapsedView
                anchors.centerIn: parent
                opacity: !island.expanded ? 1 : 0
                visible: opacity > 0
                text: Time.timeString
                color: Theme.rose
                font.family: "Hack Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            // 2. Visão Expandida
            Row {
                id: expandedView
                anchors.centerIn: parent
                spacing: 16
                opacity: island.expanded ? 1 : 0
                visible: opacity > 0

                // Relógio e Data Expandidos
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.timeString
                        color: Theme.rose
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 26
                        font.weight: Font.Bold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Time.dateString
                        color: Theme.text
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 11
                    }
                    TapHandler {
                        onTapped: function (e) {
                            e.accepted = true;
                            island.calendarRequested();
                        }
                    }
                }

                // Divisor Interno da Visão Expandida
                Rectangle {
                    width: 1
                    height: 40
                    color: Theme.overlay
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Controles Rápidos (Bateria, Perfil, Brilho)
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Row {
                        spacing: 12

                        // Status da Bateria
                        Row {
                            spacing: 5
                            Text {
                                text: island.battIcon
                                color: island.battColor
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: island.pct + "%"
                                color: island.battColor
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Divisor Menor
                        Rectangle {
                            width: 1
                            height: 12
                            color: Theme.overlay
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Perfil de Energia
                        Row {
                            spacing: 5
                            Text {
                                text: island.ppIcon
                                color: island.ppColor
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: island.ppLabel
                                color: island.ppColor
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TapHandler {
                                onTapped: function (e) {
                                    e.accepted = true;
                                    island.cycleProfile();
                                }
                            }
                        }
                    }

                    // Slider de Brilho Interno
                    Row {
                        spacing: 6
                        Text {
                            text: "󰃠"
                            color: Theme.text
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            width: 140
                            height: 4
                            radius: 2
                            color: Theme.surface
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                radius: 2
                                color: Theme.gold
                                width: parent.width * (island.currentBrightness / 100)
                                Behavior on width {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }
                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: Theme.gold
                                    anchors.horizontalCenter: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                cursorShape: Qt.PointingHandCursor
                                onPressed: function (mouse) {
                                    island.setHardwareBrightness((mouse.x / parent.width) * 100);
                                }
                                onPositionChanged: function (mouse) {
                                    if (pressed)
                                        island.setHardwareBrightness((mouse.x / parent.width) * 100);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── OSD de brilho ─────────────────────────────────────────────────────────
    RowLayout {
        anchors.centerIn: parent
        spacing: 12
        opacity: island.activeMode === "brightness" ? 1 : 0
        visible: opacity > 0

        Text {
            text: "󰃠"
            color: Theme.text
            font.family: "Hack Nerd Font"
            font.pixelSize: 16
        }

        Rectangle {
            Layout.preferredWidth: 160
            Layout.preferredHeight: 6
            radius: 3
            color: Theme.surface
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 3
                color: Theme.gold
                width: parent.width * (island.currentBrightness / 100)
                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.gold
                    anchors.horizontalCenter: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onPressed: function (mouse) {
                    island.setHardwareBrightness((mouse.x / parent.width) * 100);
                }
                onPositionChanged: function (mouse) {
                    if (pressed)
                        island.setHardwareBrightness((mouse.x / parent.width) * 100);
                }
            }
        }
    }
}
