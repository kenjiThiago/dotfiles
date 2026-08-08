pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: card

    required property var notification

    readonly property int urgency: notification ? notification.urgency : NotificationUrgency.Normal
    readonly property bool isCritical: card.urgency === NotificationUrgency.Critical

    // O expireTimeout vem em milissegundos, com -1 pedindo o padrão do servidor
    // e 0 pedindo que não expire. Os padrões daqui são os que o mako usava.
    readonly property int timeoutMs: {
        if (card.isCritical)
            return 0;
        const asked = card.notification ? card.notification.expireTimeout : -1;
        if (asked === 0)
            return 0;
        if (asked > 0)
            return asked;
        return card.urgency === NotificationUrgency.Low ? 3000 : 5000;
    }

    width: 380
    implicitHeight: layout.implicitHeight + 28
    radius: 16
    color: Theme.base

    readonly property color urgencyColor: Notifications.urgencyColor(card.notification)

    // Sem marca de urgência sobra a borda neutra dos cards da ilha.
    border.color: card.urgencyColor.a > 0 ? card.urgencyColor : Theme.overlay
    border.width: 1

    Timer {
        interval: card.timeoutMs
        running: card.timeoutMs > 0 && !hoverArea.containsMouse
        onTriggered: Notifications.expirePopup(card.notification)
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function (m) {
            m.accepted = true;

            const n = card.notification;
            const def = Notifications.defaultAction(n);
            if (!def) {
                n.dismiss();
                return;
            }

            // Só o popup sai: acionar não é motivo para apagar do histórico, e
            // dispensar aqui esbarraria no fechamento que o próprio invoke pode
            // disparar.
            def.invoke();
            Notifications.removePopup(n);
        }
    }

    Row {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        NotificationIcon {
            notification: card.notification
            size: 36
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 48
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: card.notification ? card.notification.summary : ""
                color: card.isCritical ? Theme.error : Theme.text
                font.family: "Hack Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: card.notification ? card.notification.body : ""
                color: Theme.subtle
                font.family: "Hack Nerd Font"
                font.pixelSize: 12
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: text !== ""
            }

            Row {
                spacing: 8
                visible: actionRepeater.count > 0

                Repeater {
                    id: actionRepeater
                    model: Notifications.buttonActions(card.notification)

                    delegate: Rectangle {
                        id: actionBtn
                        required property var modelData

                        width: actionLabel.implicitWidth + 20
                        height: 24
                        radius: 12
                        color: actionMouse.containsMouse ? Theme.overlay : Theme.surface

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: actionBtn.modelData.text
                            color: Theme.cyan
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function (m) {
                                m.accepted = true;
                                actionBtn.modelData.invoke();
                            }
                        }
                    }
                }
            }
        }
    }
}
