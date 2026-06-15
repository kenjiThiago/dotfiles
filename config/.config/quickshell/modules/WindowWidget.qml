pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell.Io

Rectangle {
    id: windowRoot

    property bool isHardwareExpanded: hwHover.containsMouse
    property int cpuPct: 0
    property int ramPct: 0
    property int tempC: 0

    // ── Execução do btop via Ghostty ──────────────────────────────────────────
    Process {
        id: btopCmd
        command: ["uwsm", "app", "--", "ghostty", "--class=com.example.btop", "--command=btop"]
        running: false
    }

    // ── Motor Nativo de Leitura ───────────────────────────────────────────────
    Process {
        id: hwMonitor
        command: ["bash", "-c", "while true; do read -r _ u1 n1 s1 i1 io1 ir1 si1 st1 _ < /proc/stat; sleep 2; read -r _ u2 n2 s2 i2 io2 ir2 si2 st2 _ < /proc/stat; t1=$((u1+n1+s1+i1+io1+ir1+si1+st1)); t2=$((u2+n2+s2+i2+io2+ir2+si2+st2)); id1=$((i1+io1)); id2=$((i2+io2)); diff_t=$((t2-t1)); diff_id=$((id2-id1)); if [ $diff_t -eq 0 ]; then cpu=0; else cpu=$(( 100 * (diff_t - diff_id) / diff_t )); fi; ram=$(free -m | awk 'NR==2{printf \"%d\", $3*100/$2}'); temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'); echo \"$cpu,$ram,${temp:-0}\"; done"]
        running: true

        stdout: SplitParser {
            onRead: function (data) {
                let parts = data.split(",");
                if (parts.length >= 3) {
                    windowRoot.cpuPct = parseInt(parts[0]);
                    windowRoot.ramPct = parseInt(parts[1]);
                    windowRoot.tempC = parseInt(parts[2]);
                }
            }
        }
    }

    // ── Integração com Hyprland ───────────────────────────────────────────────
    property var activeWorkspace: Hyprland.focusedWorkspace
    property var activeWin: Hyprland.activeToplevel
    property string winTitle: (activeWin && activeWin.workspace.id === activeWorkspace.id) ? activeWin.title : "Arch Linux"

    // ── O Fundo Reativo ───────────────────────────────────────────────────────
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 36
    radius: height / 2
    color: Theme.base

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        spacing: 12

        // ── Grupo de Hardware (Ícone + Status) ────────────────────────────────
        Item {
            id: hwGroup
            width: hardwareLayout.width
            height: 36
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: hwHover
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    btopCmd.running = false;
                    btopCmd.running = true;
                }
            }

            Row {
                id: hardwareLayout
                spacing: 12
                anchors.verticalCenter: parent.verticalCenter

                // ── Botão do Drawer (Engrenagem) ──────────────────────────────────
                Text {
                    id: hardwareIcon
                    text: ""
                    color: windowRoot.isHardwareExpanded ? Theme.love : Theme.foam
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    rotation: windowRoot.isHardwareExpanded ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.OutBack
                        }
                    }
                }

                // ── Status de Hardware (CPU, RAM, Temp) ───────────────────────────
                Item {
                    id: hardwareContainer
                    width: windowRoot.isHardwareExpanded ? internalStatsRow.implicitWidth : 0
                    height: 36
                    opacity: windowRoot.isHardwareExpanded ? 1 : 0
                    clip: true

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

                    Row {
                        id: internalStatsRow
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter

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
                                text: windowRoot.cpuPct + "%"
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
                                text: windowRoot.ramPct + "%"
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
                                text: windowRoot.tempC + "°C"
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                                width: 32
                            }
                        }

                        // ── Divisor Estético ──────────────────────────────────────
                        Rectangle {
                            width: 1
                            height: 16
                            color: Theme.overlay
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        // ── Título da Janela com ToolTip ──────────────────────────────────────
        Text {
            id: titleText
            text: windowRoot.winTitle
            color: Theme.subtle
            font.family: "Hack Nerd Font"
            font.pixelSize: 13
            font.weight: Font.Bold

            height: 36
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter

            width: Math.min(implicitWidth, 400)
            elide: Text.ElideRight
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                id: titleHoverArea
                anchors.fill: parent
                hoverEnabled: true
            }

            ToolTip {
                visible: titleHoverArea.containsMouse && titleText.truncated
                delay: 400

                y: 46
                x: (titleText.width - width) / 2

                leftPadding: 16
                rightPadding: 16
                topPadding: 10
                bottomPadding: 10

                enter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 200
                    }
                    NumberAnimation {
                        property: "y"
                        from: 36
                        to: 46
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                exit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 150
                    }
                }

                contentItem: Text {
                    text: windowRoot.winTitle
                    color: Theme.text
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }
                background: Rectangle {
                    color: Theme.surface
                    radius: 8
                    border.color: Theme.overlay
                    border.width: 1
                }
            }
        }
    }
}
