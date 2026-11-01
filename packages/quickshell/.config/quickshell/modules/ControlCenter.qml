pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: ccRoot

    property var hostWindow: null

    signal requestCalendar
    signal requestClose

    onVisibleChanged: {
        if (!visible)
            return;

        Notifications.markRead();
        // O brilho não é mais lido em poll, e o hypridle mexe nele por fora.
        SystemMonitor.refreshBrightness();
    }

    MouseArea {
        anchors.fill: parent

        onClicked: function (m) {
            m.accepted = true;
        }
    }
    Column {
        id: ccColumn

        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Grid {
            id: statsGrid

            columns: 2
            spacing: 12
            width: parent.width

            Rectangle {
                id: systemCard

                border.color: systemMouse.containsMouse ? Theme.accent : Theme.overlay
                border.width: 1
                color: systemMouse.pressed ? Theme.overlay : Theme.surface
                height: 88
                radius: 10
                width: Math.round((statsGrid.width - statsGrid.spacing) * 0.58)

                MouseArea {
                    id: systemMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: function (mouse) {
                        mouse.accepted = true;
                        SystemMonitor.openBtop();
                        ccRoot.requestClose();
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    width: parent.width - 32

                    Text {
                        color: Theme.subtle
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        text: "Sistema"
                    }
                    Row {
                        spacing: 10

                        Repeater {
                            model: ["", "", ""]

                            delegate: Row {
                                id: stat

                                required property int index
                                required property string modelData

                                spacing: 4

                                Text {
                                    color: Theme.subtle
                                    font.family: "Hack Nerd Font"
                                    font.pixelSize: 14
                                    text: stat.modelData
                                    width: 14
                                }
                                Text {
                                    color: Theme.text
                                    font.family: "Hack Nerd Font"
                                    font.pixelSize: 12
                                    text: stat.index === 0 ? SystemMonitor.cpuPct + "%" : (stat.index === 1 ? SystemMonitor.ramPct + "%" : SystemMonitor.tempC + "°C")
                                    width: stat.index === 2 ? 38 : 32
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                border.color: powerMouse.containsMouse ? Theme.accent : Theme.overlay
                border.width: 1
                color: powerMouse.pressed ? Theme.overlay : Theme.surface
                height: 88
                radius: 10
                width: statsGrid.width - systemCard.width - statsGrid.spacing

                MouseArea {
                    id: powerMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: function (mouse) {
                        mouse.accepted = true;
                        SystemMonitor.cycleProfile();
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    width: parent.width - 32

                    Text {
                        color: Theme.subtle
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        text: "Energia"
                    }
                    Row {
                        spacing: 8

                        Text {
                            color: SystemMonitor.ppColor
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 15
                            text: SystemMonitor.ppIcon
                        }
                        Text {
                            color: Theme.text
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 12
                            text: SystemMonitor.ppLabel
                        }
                    }
                }
            }
        }
        Column {
            id: slidersSection

            spacing: 12
            width: parent.width

            Rectangle {
                color: Theme.overlay
                height: 1
                width: parent.width
            }
            LevelControl {
                adjustable: true
                available: SystemMonitor.sink !== null && SystemMonitor.sink.audio !== null
                icon: SystemMonitor.isMuted ? "󰝟" : "󰕾"
                iconInteractive: true
                indicator: SystemMonitor.isMuted ? Theme.error : Theme.accent
                label: "Volume"
                value: SystemMonitor.volumePct

                onAdjust: value => SystemMonitor.setVolume(value)
                onIconActivated: button => {
                    if (button === Qt.RightButton) {
                        SystemMonitor.openWiremix();
                        ccRoot.requestClose();
                    } else {
                        SystemMonitor.toggleMute();
                    }
                }
            }
            LevelControl {
                adjustable: true
                available: value >= 0
                icon: "󰃠"
                label: "Brilho"
                value: SystemMonitor.currentBrightness

                onAdjust: value => SystemMonitor.setBrightness(value)
            }
            LevelControl {
                icon: SystemMonitor.battIcon
                indicator: SystemMonitor.isCharging ? Theme.success : (value <= 20 ? Theme.error : Theme.accent)
                label: SystemMonitor.isCharging ? "Bateria · carregando" : "Bateria"
                value: SystemMonitor.pct
                visible: SystemMonitor.isValid
            }
        }
        Column {
            id: traySection

            spacing: 8
            visible: sysTray.count > 0
            width: parent.width

            Rectangle {
                color: Theme.overlay
                height: 1
                width: parent.width
            }
            Item {
                height: 36
                width: parent.width

                TrayWidget {
                    id: sysTray

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    hostWindow: ccRoot.hostWindow
                }
            }
        }
        NotificationList {
            id: notifList

            // O teto vem da altura fixa da central, não da altura da própria lista.
            maxListHeight: {
                const sections = statsGrid.height + slidersSection.height + 2 * ccColumn.spacing;
                const tray = traySection.visible ? traySection.height + ccColumn.spacing : 0;
                return Math.max(0, ccColumn.height - sections - tray - notifList.headerHeight);
            }
            width: parent.width
        }
    }

    component LevelControl: Column {
        id: control

        property bool adjustable: false
        property bool available: true
        required property string icon
        property bool iconInteractive: false
        property color indicator: Theme.accent
        required property string label
        required property real value

        signal adjust(real value)
        signal iconActivated(int button)

        spacing: 8
        width: parent.width

        RowLayout {
            spacing: 10
            width: parent.width

            Rectangle {
                border.color: iconMouse.containsMouse ? Theme.accent : Theme.overlay
                border.width: 1
                color: iconMouse.pressed ? Theme.overlay : Theme.surface
                implicitHeight: 28
                implicitWidth: 28
                radius: 8

                Text {
                    anchors.centerIn: parent
                    color: control.available ? control.indicator : Theme.muted
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 15
                    text: control.icon
                }
                MouseArea {
                    id: iconMouse

                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: control.iconInteractive && control.available
                    hoverEnabled: true

                    onClicked: function (m) {
                        m.accepted = true;
                        control.iconActivated(m.button);
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                color: Theme.subtle
                font.family: "Hack Nerd Font"
                font.pixelSize: 12
                text: control.label
            }
            Text {
                color: Theme.text
                font.family: "Hack Nerd Font"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: control.available ? Math.round(control.value) + "%" : "—"
            }
        }
        Rectangle {
            id: track

            color: Theme.overlay
            height: 6
            opacity: control.available ? 1 : 0.4
            radius: 3
            width: parent.width

            Rectangle {
                color: control.indicator
                height: parent.height
                radius: 3
                width: control.available ? parent.width * Math.max(0, Math.min(1, control.value / 100)) : 0
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: control.indicator
                height: 12
                radius: 6
                visible: control.adjustable && control.available && (trackMouse.containsMouse || trackMouse.pressed)
                width: 12
                x: Math.max(0, Math.min(track.width - width, track.width * control.value / 100 - width / 2))
            }
            WheelHandler {
                enabled: control.adjustable && control.available

                onWheel: function (e) {
                    control.adjust(control.value + (e.angleDelta.y > 0 ? 5 : -5));
                }
            }
            MouseArea {
                id: trackMouse

                // A margem amplia o alvo; a posição precisa ser relativa à trilha.
                function applyAt(m) {
                    control.adjust(100 * mapToItem(track, m.x, 0).x / track.width);
                }

                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                enabled: control.adjustable && control.available
                hoverEnabled: true

                onPositionChanged: function (m) {
                    if (pressed)
                        applyAt(m);
                }
                onPressed: function (m) {
                    m.accepted = true;
                    applyAt(m);
                }
            }
        }
    }
}
