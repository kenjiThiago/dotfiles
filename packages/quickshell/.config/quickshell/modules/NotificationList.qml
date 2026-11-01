pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "."

Column {
    id: listRoot

    // Teto, não altura fixa: a lista encolhe até o conteúdo.
    property int maxListHeight: 150

    // O que a lista gasta acima da área rolável, para quem calcula o teto.
    readonly property int headerHeight: 1 + listRoot.spacing + 32 + listRoot.spacing

    spacing: 8

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.overlay
    }

    Item {
        width: parent.width
        height: 32

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Notificações" + (Notifications.count > 0 ? " (" + Notifications.count + ")" : "")
            color: Theme.text
            font.family: "Hack Nerd Font"
            font.pixelSize: 13
            font.weight: Font.Bold
        }

        Text {
            id: dndBtn
            anchors.right: clearBtn.visible ? clearBtn.left : parent.right
            anchors.rightMargin: clearBtn.visible ? 12 : 0
            anchors.verticalCenter: parent.verticalCenter
            text: Notifications.dnd ? "󰂛" : "󰂚"
            color: Notifications.dnd ? Theme.accent : (dndMouse.containsMouse ? Theme.text : Theme.subtle)
            font.family: "Hack Nerd Font"
            font.pixelSize: 14

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            MouseArea {
                id: dndMouse
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: function (m) {
                    m.accepted = true;
                    Notifications.dnd = !Notifications.dnd;
                }
            }
        }

        Text {
            id: clearBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "Limpar tudo"
            color: clearMouse.containsMouse ? Theme.accent : Theme.subtle
            font.family: "Hack Nerd Font"
            font.pixelSize: 11
            visible: Notifications.count > 0

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: function (m) {
                    m.accepted = true;
                    Notifications.dismissAll();
                }
            }
        }
    }

    Item {
        width: parent.width
        height: Math.min(Notifications.count === 0 ? 72 : view.contentHeight, listRoot.maxListHeight)

        // A contentHeight se mede pela largura do delegate, não por esta altura,
        // então não há laço de binding aqui.
        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6
            visible: Notifications.count === 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Notifications.dnd ? Theme.accent : Theme.subtle
                font.family: "Hack Nerd Font"
                font.pixelSize: 18
                text: Notifications.dnd ? "󰂛" : "󰂚"
            }
            Text {
                color: Theme.subtle
                font.family: "Hack Nerd Font"
                font.pixelSize: 12
                text: Notifications.dnd ? "Não perturbe ativado" : "Nenhuma notificação"
            }
        }

        ListView {
            id: view
            anchors.fill: parent
            clip: true
            spacing: 8
            model: Notifications.list
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                width: 3
                padding: 0
                policy: view.contentHeight > view.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                background: null
                contentItem: Rectangle {
                    implicitWidth: 3
                    radius: 1.5
                    color: Theme.highlightHigh
                }
            }

            delegate: Rectangle {
                id: entry
                required property var modelData

                width: view.width - 8
                implicitHeight: entryLayout.implicitHeight + 24
                radius: 10
                color: entryMouse.containsMouse ? Theme.overlay : Theme.surface

                readonly property color urgencyColor: Notifications.urgencyColor(entry.modelData)
                border.color: entry.urgencyColor.a > 0 ? entry.urgencyColor : (entryMouse.containsMouse ? Theme.highlightMed : Theme.overlay)
                border.width: 1

                readonly property var defaultAction: Notifications.defaultAction(entry.modelData)

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                MouseArea {
                    id: entryMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: entry.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: function (m) {
                        m.accepted = true;
                        if (entry.defaultAction)
                            Notifications.invokeAction(entry.modelData, entry.defaultAction);
                    }
                }

                Row {
                    id: entryLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    NotificationIcon {
                        notification: entry.modelData
                        size: 28
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        // 28 do ícone mais o spacing da Row de fora.
                        width: parent.width - 38
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            color: Theme.subtle
                            elide: Text.ElideRight
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 10
                            text: entry.modelData.appName
                            visible: text !== ""
                            width: parent.width
                        }

                        Row {
                            width: parent.width
                            spacing: 6

                            Text {
                                width: parent.width - timeLabel.width - dismissBtn.width - 2 * parent.spacing
                                text: entry.modelData.summary
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                wrapMode: Text.WordWrap
                                maximumLineCount: entryMouse.containsMouse ? 5 : 1
                                elide: Text.ElideRight
                            }

                            Text {
                                id: timeLabel
                                text: Notifications.relativeTime(entry.modelData, Time.now)
                                color: Theme.subtle
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 10
                                anchors.top: parent.top
                            }

                            // Ancorado no topo da linha do título, não no centro: o título cresce no hover e
                            // o 󰅖 escorregaria de sob o cursor.
                            Text {
                                id: dismissBtn
                                text: "󰅖"
                                color: dismissMouse.containsMouse ? Theme.error : Theme.subtle
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                anchors.top: parent.top

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }

                                MouseArea {
                                    id: dismissMouse
                                    anchors.fill: parent
                                    // -6 encosta no horário sem cobri-lo, já que o
                                    // spacing da Row também é 6.
                                    anchors.margins: -6
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function (m) {
                                        m.accepted = true;
                                        entry.modelData.dismiss();
                                    }
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: Notifications.bodyText(entry.modelData)
                            color: Theme.subtle
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 11
                            textFormat: Text.StyledText
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }

                        // Sem ações: o cliente que espera por elas já saiu quando a notificação chega aqui.
                    }
                }
            }
        }
    }
}
