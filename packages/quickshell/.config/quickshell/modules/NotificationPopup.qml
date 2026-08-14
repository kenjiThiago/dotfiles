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

    border.color: card.urgencyColor.a > 0 ? card.urgencyColor : Theme.overlay
    border.width: 1

    // ── Contagem para a expiração ─────────────────────────────────────────────

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
        if (card.timeoutMs <= 0 || card.expiring)
            return;

        expireTimer.interval = Math.max(card.remainingMs, 1);
        card.startedAt = Date.now();
        expireTimer.restart();
    }

    // O conteúdo trocou embaixo do card: o prazo recomeça do zero, e continua
    // parado se o ponteiro estiver em cima.
    function refreshCountdown(): void {
        if (card.expiring)
            return;

        expireTimer.stop();
        card.remainingMs = card.timeoutMs;
        if (!hoverArea.containsMouse)
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

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onContainsMouseChanged: {
            if (hoverArea.containsMouse)
                card.pauseCountdown();
            else
                card.startCountdown();
        }

        onClicked: function (m) {
            m.accepted = true;
            Notifications.invokeDefault(card.notification);
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
                // Título longo fica numa linha só até o mouse entrar, e aí abre
                // inteiro. O hover já segura a contagem do timeout, então o
                // card não some no meio da leitura.
                wrapMode: Text.WordWrap
                maximumLineCount: hoverArea.containsMouse ? 5 : 1
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: Notifications.bodyText(card.notification)
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
                                Notifications.invokeAction(card.notification, actionBtn.modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
