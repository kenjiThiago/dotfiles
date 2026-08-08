pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import "."

Row {
    id: trayRoot

    property var hostWindow

    readonly property int count: trayRepeater.count

    spacing: 10

    Repeater {
        id: trayRepeater
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem
            required property var modelData

            // Mesmo botão redondo das linhas de volume, brilho e bateria.
            width: 32
            height: 32
            radius: 16

            color: appMouseArea.containsMouse ? Theme.overlay : Theme.surface
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
