import QtQuick
import Quickshell

// Avisa quando qualquer entrada do menu, inclusive de submenus, é escolhida.
QtObject {
    id: watcher

    property var menu: null

    signal triggered

    property QsMenuOpener opener: QsMenuOpener {
        menu: watcher.menu
    }

    property Instantiator entries: Instantiator {
        model: watcher.opener.children

        delegate: QtObject {
            id: entry

            required property QsMenuEntry modelData

            property Connections triggers: Connections {
                target: entry.modelData

                function onTriggered() {
                    watcher.triggered();
                }
            }

            // Recursivo por createObject: um arquivo QML não pode se declarar.
            property var submenu: entry.modelData.hasChildren ? Qt.createComponent("MenuWatcher.qml").createObject(entry, {
                menu: entry.modelData
            }) : null

            property Connections subTriggers: Connections {
                target: entry.submenu
                ignoreUnknownSignals: true

                function onTriggered() {
                    watcher.triggered();
                }
            }
        }
    }
}
