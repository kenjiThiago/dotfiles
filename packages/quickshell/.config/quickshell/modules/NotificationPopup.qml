pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: card

    required property var notification

    readonly property int urgency: notification ? notification.urgency : NotificationUrgency.Normal
    readonly property bool isCritical: card.urgency === NotificationUrgency.Critical

    // Em milissegundos, com -1 pedindo o padrão do servidor e 0 pedindo que não expire.
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

    // A entrada é daqui e não da Transition da Column: um positionador cancela a
    // transição para refazer o layout, e a opacidade congela onde estiver.
    opacity: 0

    readonly property color urgencyColor: Notifications.urgencyColor(card.notification)

    border.color: card.urgencyColor.a > 0 ? card.urgencyColor : Theme.highlightMed
    border.width: 1

    // O Timer do QML não pausa: religá-lo recomeça o intervalo inteiro, então o
    // restante é guardado à mão para o hover segurar o card.
    property double remainingMs: card.timeoutMs
    property double startedAt: 0
    property bool expiring: false

    Timer {
        id: expireTimer
        running: false
        onTriggered: card.beginExpire()
    }

    function startCountdown(): void {
        if (card.timeoutMs <= 0 || card.expiring || cardHover.hovered)
            return;

        expireTimer.interval = Math.max(card.remainingMs, 1);
        card.startedAt = Date.now();
        expireTimer.restart();
    }

    // O conteúdo trocou: o prazo recomeça, e continua parado se o ponteiro estiver em cima.
    function refreshCountdown(): void {
        if (card.expiring)
            return;

        expireTimer.stop();
        card.remainingMs = card.timeoutMs;
        if (!cardHover.hovered)
            card.startCountdown();
    }

    Connections {
        target: Notifications

        function onPopupRefreshed(n) {
            if (n === card.notification)
                card.refreshCountdown();
        }
    }

    function pauseCountdown(): void {
        if (!expireTimer.running)
            return;

        expireTimer.stop();
        // O piso evita o card sumir no mesmo quadro em que o ponteiro sai dele.
        card.remainingMs = Math.max(expireTimer.interval - (Date.now() - card.startedAt), 300);
    }

    Component.onCompleted: {
        enterAnim.start();
        card.startCountdown();
    }

    NumberAnimation {
        id: enterAnim
        target: card
        property: "opacity"
        to: 1
        duration: 200
    }

    // Um positionador não tem `remove:`, mas opacity e scale são do card. Só
    // vale para a expiração: saída por clique some na hora.
    ParallelAnimation {
        id: expireAnim

        NumberAnimation {
            target: card
            property: "opacity"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: card
            property: "scale"
            to: 0.94
            duration: 200
            easing.type: Easing.OutCubic
        }

        onFinished: Notifications.expirePopup(card.notification)
    }

    function beginExpire(): void {
        if (card.expiring)
            return;

        card.expiring = true;
        // As duas disputariam a opacidade se o card expirar antes de entrar.
        enterAnim.stop();
        expireAnim.start();
    }

    HoverHandler {
        id: cardHover
        onHoveredChanged: {
            if (hovered)
                card.pauseCountdown();
            else
                card.startCountdown();
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: function (m) {
            m.accepted = true;
            Notifications.invokeDefault(card.notification);
        }
    }

    Row {
        id: layout

        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        NotificationIcon {
            anchors.verticalCenter: parent.verticalCenter
            notification: card.notification
            size: 36
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            width: parent.width - 48

            Row {
                spacing: 8
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.subtle
                    elide: Text.ElideRight
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 10
                    text: card.notification && card.notification.appName !== "" ? card.notification.appName : "Notificação"
                    width: parent.width - closeButton.width - parent.spacing
                }
                Rectangle {
                    id: closeButton

                    color: closeMouse.containsMouse ? Theme.overlay : "transparent"
                    height: 24
                    radius: 6
                    width: 24

                    Text {
                        anchors.centerIn: parent
                        color: closeMouse.containsMouse ? Theme.error : Theme.subtle
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        text: "󰅖"
                    }
                    MouseArea {
                        id: closeMouse

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: function (m) {
                            m.accepted = true;
                            if (card.notification)
                                card.notification.dismiss();
                        }
                    }
                }
            }
            Text {
                color: card.isCritical ? Theme.error : Theme.text
                elide: Text.ElideRight
                font.family: "Hack Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
                maximumLineCount: cardHover.hovered ? 5 : 1
                text: card.notification ? card.notification.summary : ""
                width: parent.width
                // Título numa linha até o mouse entrar; o hover já segura o timeout.
                wrapMode: Text.WordWrap
            }
            Text {
                color: Theme.subtle
                elide: Text.ElideRight
                font.family: "Hack Nerd Font"
                font.pixelSize: 12
                maximumLineCount: 3
                text: Notifications.bodyText(card.notification)
                textFormat: Text.StyledText
                visible: text !== ""
                width: parent.width
                wrapMode: Text.WordWrap
            }
            Flow {
                id: actions

                spacing: 8
                visible: actionRepeater.count > 0
                width: parent.width

                Repeater {
                    id: actionRepeater

                    model: Notifications.buttonActions(card.notification)

                    delegate: Rectangle {
                        id: actionBtn

                        required property var modelData

                        border.color: actionMouse.containsMouse ? Theme.accent : Theme.overlay
                        border.width: 1
                        color: actionMouse.pressed ? Theme.overlay : Theme.surface
                        height: 28
                        radius: 8
                        width: Math.min(actionLabel.implicitWidth + 20, actions.width)

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            id: actionLabel

                            anchors.centerIn: parent
                            color: actionMouse.containsMouse ? Theme.accent : Theme.text
                            elide: Text.ElideRight
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            text: actionBtn.modelData.text
                            width: parent.width - 20
                        }
                        MouseArea {
                            id: actionMouse

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: function (m) {
                                m.accepted = true;
                                Notifications.invokeAction(card.notification, actionBtn.modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
