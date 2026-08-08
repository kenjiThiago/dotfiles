pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications
import "."

Item {
    id: root

    readonly property var blockedApps: ["Spotify"]

    readonly property var list: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    property int unreadCount: 0

    property bool dnd: false

    IpcHandler {
        target: "notifications"

        function toggle(): void {
            root.dnd = !root.dnd;
        }
    }

    // Fila dos cards ainda na tela. Separada do histórico de propósito: sair
    // daqui só tira o popup, não fecha a notificação.
    property var popups: []

    // A API não carrega horário de chegada, então guardamos por id.
    property var arrivalTimes: ({})

    function markRead(): void {
        root.unreadCount = 0;
    }

    // ── Apresentação, compartilhada pelo popup e pelo histórico ───────────────

    // A urgência normal não recebe marca: é a maioria, e pintar todas viraria ruído.
    function urgencyColor(n: var): color {
        if (!n)
            return "transparent";
        if (n.urgency === NotificationUrgency.Critical)
            return Theme.error;
        if (n.urgency === NotificationUrgency.Low)
            return Theme.cyan;
        return "transparent";
    }

    // Pela spec, a ação "default" não é botão: é o clique no corpo.
    function defaultAction(n: var): var {
        if (!n)
            return null;
        for (const a of n.actions)
            if (a.identifier === "default")
                return a;
        return null;
    }

    function buttonActions(n: var): var {
        return n ? n.actions.filter(a => a.identifier !== "default") : [];
    }

    function removePopup(n: var): void {
        root.popups = root.popups.filter(p => p !== n);
    }

    // Só para o card expirando na tela: chamar isto no closed daria recursão.
    function expirePopup(n: var): void {
        root.removePopup(n);

        // Transiente não se guarda: acaba junto com o popup.
        if (n && n.transient)
            n.dismiss();
    }

    function dismissAll(): void {
        for (const n of root.list.values.slice())
            n.dismiss();
    }

    // O `tick` não é usado: força o binding de quem chama a reavaliar.
    function relativeTime(id: int, tick: var): string {
        const at = root.arrivalTimes[id];
        if (at === undefined)
            return "";

        const mins = Math.floor((Date.now() - at) / 60000);
        if (mins < 1)
            return "agora";
        if (mins < 60)
            return mins + " min";

        const hours = Math.floor(mins / 60);
        if (hours < 24)
            return hours + " h";
        return Math.floor(hours / 24) + " d";
    }

    NotificationServer {
        id: server

        keepOnReload: true

        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: function (n) {
            if (root.blockedApps.includes(n.appName))
                return;

            // Sem popup não há o que expirar, e ela ficaria presa no histórico.
            if (root.dnd && n.transient)
                return;

            // Sem isto a notificação é destruída assim que o sinal retorna.
            n.tracked = true;

            root.arrivalTimes[n.id] = Date.now();
            root.unreadCount++;

            if (!root.dnd)
                root.popups = root.popups.concat([n]);

            n.closed.connect(function () {
                delete root.arrivalTimes[n.id];
                root.removePopup(n);

                if (root.unreadCount > 0)
                    root.unreadCount--;
            });
        }
    }
}
