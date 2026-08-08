pragma ComponentBehavior: Bound

import QtQuick
import "."

Column {
    id: listRoot

    property int listHeight: 150

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
        height: listRoot.listHeight

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

                // Mesma marca do popup: a urgência precisa sobreviver até aqui,
                // que é onde se consulta com calma.
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
                            entry.defaultAction.invoke();
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
                        width: parent.width - 38 - dismissBtn.width - parent.spacing
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            width: parent.width
                            spacing: 6

                            Text {
                                width: parent.width - timeLabel.width - parent.spacing
                                text: entry.modelData.summary
                                color: Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                id: timeLabel
                                text: Notifications.relativeTime(entry.modelData.id, Time.now)
                                color: Theme.muted
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: entry.modelData.body
                            color: Theme.subtle
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 11
                            textFormat: Text.StyledText
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }

                        Row {
                            spacing: 6
                            visible: entryActions.count > 0

                            Repeater {
                                id: entryActions
                                model: Notifications.buttonActions(entry.modelData)

                                delegate: Rectangle {
                                    id: entryAction
                                    required property var modelData

                                    width: entryActionLabel.implicitWidth + 16
                                    height: 20
                                    radius: 10
                                    color: entryActionMouse.containsMouse ? Theme.highlightMed : Theme.overlay

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        id: entryActionLabel
                                        anchors.centerIn: parent
                                        text: entryAction.modelData.text
                                        color: Theme.cyan
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: entryActionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: function (m) {
                                            m.accepted = true;
                                            entryAction.modelData.invoke();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        id: dismissBtn
                        text: ""
                        color: dismissMouse.containsMouse ? Theme.error : Theme.muted
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        MouseArea {
                            id: dismissMouse
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function (m) {
                                m.accepted = true;
                                entry.modelData.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }
}
