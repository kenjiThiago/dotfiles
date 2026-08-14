pragma ComponentBehavior: Bound

import QtQuick
import "."

Column {
    id: listRoot

    // Teto, não altura fixa: a lista encolhe até o conteúdo.
    property int maxListHeight: 150

    // O que a lista gasta acima da área rolável, para quem calcula o teto.
    readonly property int headerHeight: 1 + listRoot.spacing + 20 + listRoot.spacing

    spacing: 8

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.overlay
    }

    Item {
        width: parent.width
        height: 20

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
            color: Notifications.dnd ? Theme.accent : (dndMouse.containsMouse ? Theme.text : Theme.muted)
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
            color: clearMouse.containsMouse ? Theme.accent : Theme.muted
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
        height: Notifications.count === 0 ? 32 : Math.min(view.contentHeight, listRoot.maxListHeight)

        // A contentHeight se mede pela largura do delegate, não por esta altura,
        // então não há laço de binding aqui.
        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Nada por aqui"
            color: Theme.muted
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            visible: Notifications.count === 0
        }

        ListView {
            id: view
            anchors.fill: parent
            clip: true
            spacing: 6
            model: Notifications.list
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: entry
                required property var modelData

                width: view.width
                implicitHeight: entryLayout.implicitHeight + 16
                radius: 12
                color: entryMouse.containsMouse ? Theme.overlay : Theme.surface

                readonly property color urgencyColor: Notifications.urgencyColor(entry.modelData)
                border.color: entry.urgencyColor
                border.width: entry.urgencyColor.a > 0 ? 1 : 0

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
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
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
                                // Igual ao popup: uma linha até o mouse entrar,
                                // inteiro no hover.
                                wrapMode: Text.WordWrap
                                maximumLineCount: entryMouse.containsMouse ? 5 : 1
                                elide: Text.ElideRight
                            }

                            Text {
                                id: timeLabel
                                text: Notifications.relativeTime(entry.modelData, Time.now)
                                color: Theme.muted
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 10
                                anchors.top: parent.top
                            }

                            // Na linha do título para não descer conforme o corpo
                            // e os botões fazem o item crescer. Ancorados no topo
                            // e não no centro porque o título cresce no hover: no
                            // centro, o 󰅖 escorregava de sob o cursor e piscava
                            // entre as duas cores do Behavior.
                            Text {
                                id: dismissBtn
                                text: "󰅖"
                                color: dismissMouse.containsMouse ? Theme.error : Theme.muted
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

                        // Sem botões de ação aqui: o cliente que espera por elas
                        // já saiu quando a notificação chega ao histórico.
                    }
                }
            }
        }
    }
}
