pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "."

Row {
    id: trayRoot

    property var hostWindow

    readonly property int count: trayRepeater.count

    property bool entryChosen: false

    spacing: 10

    // O display() não avisa quando o menu fecha; o anchor sim.
    QsMenuAnchor {
        id: menuAnchor
        anchor.window: trayRoot.hostWindow
        onOpened: {
            closeDebounce.stop();
            trayRoot.entryChosen = false;
        }
        onClosed: closeDebounce.restart()
    }

    MenuWatcher {
        menu: menuAnchor.menu
        onTriggered: {
            trayRoot.entryChosen = true;
            if (trayRoot.hostWindow)
                trayRoot.hostWindow.menuEntryTriggered();
        }
    }

    // Um menu que se reconstrói (a lista de redes do nm-applet) pode fechar e
    // reabrir em seguida. A espera também cobre o Qt, que fecha o menu antes de
    // emitir o triggered da entrada escolhida.
    Timer {
        id: closeDebounce
        interval: 200
        onTriggered: {
            if (trayRoot.hostWindow) {
                if (trayRoot.entryChosen)
                    trayRoot.hostWindow.menuEntryChosen();
                else
                    trayRoot.hostWindow.menuFinished();
            }
            // Segurar o menu de um item que saiu do tray (o "Sair" do app) derruba o quickshell.
            menuAnchor.menu = null;
        }
    }

    Repeater {
        id: trayRepeater
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem
            required property var modelData

            width: 32
            height: 32
            radius: 8

            color: appMouseArea.pressed ? Theme.overlay : Theme.surface
            border.width: 1
            border.color: appMouseArea.containsMouse ? Theme.accent : Theme.overlay
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

                // Com sourceSize o SVG é rasterizado já em 18px, sem a reamostragem que borra.
                sourceSize.width: 18
                sourceSize.height: 18
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
                        menuAnchor.menu = trayItem.modelData.menu;
                        menuAnchor.anchor.rect.x = pos.x;
                        menuAnchor.anchor.rect.y = pos.y;
                        menuAnchor.open();
                    }
                }
            }
        }
    }
}
