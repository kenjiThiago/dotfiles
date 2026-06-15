pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root
    property bool islandExpanded: false
    property bool calendarExpanded: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mainBarWindow

            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"

            implicitHeight: 120
            exclusiveZone: 54

            mask: Region {
                item: barVisuals
            }

            Item {
                id: barVisuals
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 54

                // ── Bloco Esquerdo ────────────────────────────────────────────────
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 12

                    WindowWidget {}
                }

                // ── Bloco Direito ─────────────────────────────────────────────────
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    spacing: 8

                    TrayWidget {
                        hostWindow: mainBarWindow
                    }

                    AudioWidget {}

                    BatteryContextWidget {}
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: islandWindow
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: 300

            mask: Region {
                item: island
            }

            HyprlandFocusGrab {
                id: focusGrab
                windows: [islandWindow]
                active: root.islandExpanded && !root.calendarExpanded
                onCleared: {
                    if (!root.calendarExpanded) {
                        root.islandExpanded = false;
                    }
                }
            }

            ClockWidget {
                id: island
                expanded: root.islandExpanded
                onToggleRequested: root.islandExpanded = !root.islandExpanded
                onCalendarRequested: root.calendarExpanded = !root.calendarExpanded
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: calendarWindow
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: 96
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: 400

            Item {
                id: emptyRegion
                width: 0
                height: 0
            }

            mask: Region {
                item: root.calendarExpanded ? calWidget : emptyRegion
            }

            HyprlandFocusGrab {
                windows: [calendarWindow]
                active: root.calendarExpanded
                onCleared: {
                    root.calendarExpanded = false;
                    root.islandExpanded = false;
                }
            }

            CalendarWidget {
                id: calWidget
                anchors.horizontalCenter: parent.horizontalCenter

                opacity: root.calendarExpanded ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
