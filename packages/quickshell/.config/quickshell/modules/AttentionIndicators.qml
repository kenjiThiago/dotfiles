pragma ComponentBehavior: Bound

import QtQuick
import "."

Row {
    id: root

    readonly property var indicators: [
        {
            icon: "󰹑",
            active: SystemMonitor.screenCaptured,
            color: Theme.warning
        },
        {
            icon: "󰍬",
            active: SystemMonitor.micInUse,
            color: Theme.warning
        },
        {
            icon: "󰄀",
            active: SystemMonitor.cameraInUse,
            color: Theme.warning
        },
        {
            icon: "󰈸",
            active: SystemMonitor.tempAlert > 0,
            color: SystemMonitor.tempAlert === 2 ? Theme.error : Theme.warning
        },
        {
            icon: "󰂃",
            active: SystemMonitor.isValid && SystemMonitor.pct <= 20 && !SystemMonitor.isCharging,
            color: Theme.error
        }
    ]
    readonly property int count: indicators.filter(item => item.active).length

    spacing: 8
    width: count > 0 ? count * 18 + (count - 1) * spacing : 0
    height: 18

    Repeater {
        model: root.indicators

        delegate: Text {
            required property var modelData

            text: modelData.icon
            color: modelData.color
            visible: modelData.active
            width: 18
            height: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Hack Nerd Font"
            font.pixelSize: 15
        }
    }
}
