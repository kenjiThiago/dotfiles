pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: ccRoot

    property var hostWindow: null
    signal requestClose
    signal requestCalendar

    onVisibleChanged: {
        if (visible) {
            sysTray.isExpanded = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function (m) {
            m.accepted = true;
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // GRID: SISTEMA & ENERGIA
        Grid {
            columns: 2
            spacing: 12
            width: parent.width
            Rectangle {
                width: 240
                height: 90
                radius: 16
                color: Theme.surface
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function (mouse) {
                        mouse.accepted = true;
                        SystemMonitor.openBtop();
                        ccRoot.requestClose();
                    }
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        text: ""
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 22
                        color: Theme.foam
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        width: sysTexts.implicitWidth
                        height: sysTexts.implicitHeight
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }

                        Column {
                            id: sysTexts
                            Text {
                                text: "Sistema"
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                            Row {
                                id: internalStatsRow
                                spacing: 12

                                Row {
                                    spacing: 6
                                    Text {
                                        text: ""
                                        color: Theme.gold
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 15
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: SystemMonitor.cpuPct + "%"
                                        color: Theme.text
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 28
                                    }
                                }

                                Row {
                                    spacing: 6
                                    Text {
                                        text: ""
                                        color: Theme.iris
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 15
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: SystemMonitor.ramPct + "%"
                                        color: Theme.text
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 28
                                    }
                                }

                                Row {
                                    spacing: 6
                                    Text {
                                        text: ""
                                        color: Theme.rose
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: SystemMonitor.tempC + "°C"
                                        color: Theme.text
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 32
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: 160
                height: 90
                radius: 16
                color: Theme.surface
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function (mouse) {
                        mouse.accepted = true;
                        SystemMonitor.cycleProfile();
                    }
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    Text {
                        text: SystemMonitor.ppIcon
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 22
                        color: SystemMonitor.ppColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        width: powerTexts.implicitWidth
                        height: powerTexts.implicitHeight
                        anchors.verticalCenter: parent.verticalCenter
                        Column {
                            id: powerTexts
                            Text {
                                text: "Energia"
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                            Text {
                                text: SystemMonitor.ppLabel
                                color: Theme.muted
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }

        // SLIDERS: ÁUDIO & BRILHO
        Column {
            width: parent.width
            spacing: 16

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.overlay
            }
            RowLayout {
                width: parent.width
                spacing: 12
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Theme.surface
                    Text {
                        anchors.centerIn: parent
                        text: SystemMonitor.isMuted ? "󰝟" : "󰕾"
                        color: Theme.text
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function (m) {
                            m.accepted = true;
                            SystemMonitor.openWiremix();
                            ccRoot.requestClose();
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Theme.overlay
                    Rectangle {
                        width: parent.width * (SystemMonitor.volumePct / 100)
                        height: parent.height
                        radius: 4
                        color: SystemMonitor.isMuted ? Theme.love : Theme.foam
                    }
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: SystemMonitor.isMuted ? Theme.love : Theme.foam
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(parent.width - 14, (parent.width * (SystemMonitor.volumePct / 100)) - 7))
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        cursorShape: Qt.PointingHandCursor
                        onPressed: function (m) {
                            m.accepted = true;
                            SystemMonitor.setVolume((m.x / width) * 100);
                        }
                        onPositionChanged: function (m) {
                            if (pressed)
                                SystemMonitor.setVolume((m.x / width) * 100);
                        }
                    }
                }
                Text {
                    text: SystemMonitor.volumePct + "%"
                    color: Theme.text
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    Layout.preferredWidth: 35
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                width: parent.width
                spacing: 12
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Theme.surface
                    Text {
                        anchors.centerIn: parent
                        text: "󰃠"
                        color: Theme.text
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 16
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Theme.overlay
                    Rectangle {
                        width: parent.width * (SystemMonitor.currentBrightness / 100)
                        height: parent.height
                        radius: 4
                        color: Theme.gold
                    }
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.gold
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(parent.width - 14, (parent.width * (SystemMonitor.currentBrightness / 100)) - 7))
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10
                        cursorShape: Qt.PointingHandCursor
                        onPressed: function (m) {
                            m.accepted = true;
                            SystemMonitor.setBrightness((m.x / width) * 100);
                        }
                        onPositionChanged: function (m) {
                            if (pressed)
                                SystemMonitor.setBrightness((m.x / width) * 100);
                        }
                    }
                }
                Text {
                    text: Math.round(SystemMonitor.currentBrightness) + "%"
                    color: Theme.text
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    Layout.preferredWidth: 35
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // SYSTEM TRAY
        Column {
            width: parent.width
            spacing: 8
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.overlay
            }
            Item {
                width: parent.width
                height: 36
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 36
                    TrayWidget {
                        id: sysTray
                        hostWindow: ccRoot.hostWindow
                    }
                }
            }
        }
    }
}
