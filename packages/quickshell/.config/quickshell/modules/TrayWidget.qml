pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import Quickshell.Services.SystemTray

Rectangle {
    id: trayRoot

    property bool isExpanded: false
    property var hostWindow

    visible: trayRepeater.count > 0

    implicitWidth: isExpanded ? (contentRow.implicitWidth + 24) : 36
    implicitHeight: 36
    radius: height / 2
    color: Theme.base

    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutQuart
        }
    }

    Row {
        id: contentRow
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Row {
            id: iconsRow
            spacing: 8
            opacity: trayRoot.isExpanded ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Repeater {
                id: trayRepeater
                model: SystemTray.items

                delegate: Rectangle {
                    id: trayItem
                    required property var modelData

                    width: 28
                    height: 28
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter

                    color: appMouseArea.containsMouse ? Theme.surface : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: trayItem.modelData.icon
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        opacity: trayItem.modelData.status === Status.Passive ? 0.6 : 1.0
                    }

                    MouseArea {
                        id: appMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                        onClicked: function (mouse) {
                            if (mouse.button === Qt.LeftButton) {
                                trayItem.modelData.activate();
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItem.modelData.secondaryActivate();
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayRoot.hostWindow && trayRoot.hostWindow.expectMenu) {
                                    trayRoot.hostWindow.expectMenu();
                                }
                                let pos = trayItem.mapToItem(null, mouse.x, mouse.y);
                                trayItem.modelData.display(trayRoot.hostWindow, pos.x, pos.y);
                            }
                        }
                    }
                }
            }
        }

        Text {
            text: ""
            color: trayRoot.isExpanded ? Theme.yellow : Theme.subtle
            font.family: "Hack Nerd Font"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            rotation: trayRoot.isExpanded ? 180 : 0
            Behavior on rotation {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutBack
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                cursorShape: Qt.PointingHandCursor
                onClicked: trayRoot.isExpanded = !trayRoot.isExpanded
            }
        }
    }
}
