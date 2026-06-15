pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower

Rectangle {
    id: battRoot

    // ── Referência ao UPower ──────────────────────────────────────────────────
    property var device: UPower.displayDevice

    property bool isValid: device !== null

    property int pct: isValid ? Math.round(device.percentage) * 100 : 0
    property int battery_state: isValid ? device.state : UPowerDeviceState.Unknown

    // ── Lógica Contextual ─────────────────────────────────────────────────────
    property bool isCharging: battery_state === UPowerDeviceState.Charging || battery_state === UPowerDeviceState.FullyCharged
    property bool isCritical: pct <= 20
    property bool isLow: pct <= 30

    property bool shouldShow: isCharging || isLow

    // ── Estilo Dinâmico ───────────────────────────────────────────────────────
    property color battColor: {
        if (isCharging)
            return Theme.pine;
        if (isCritical)
            return Theme.love;
        if (isLow)
            return Theme.gold;
        return Theme.pine;
    }

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

    // ── Dimensões e Animação de Surgimento ────────────────────────────────────
    implicitWidth: shouldShow ? (contentRow.implicitWidth + 24) : 0
    implicitHeight: 36
    radius: height / 2
    color: Theme.base

    clip: true
    opacity: shouldShow ? 1 : 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuart
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: battRoot.battIcon
            color: battRoot.battColor
            font.family: "Hack Nerd Font"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Text {
            text: battRoot.pct + "%"
            color: battRoot.battColor
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }
}
