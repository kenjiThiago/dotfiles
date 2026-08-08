pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: root

    // Apps descartados por completo, sem popup e sem histórico.
    readonly property var blockedApps: ["Spotify"]

    readonly property var list: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    property int unreadCount: 0

    // Não perturbe: segue guardando no histórico, só não mostra popup.
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

    function removePopup(n: var): void {
        root.popups = root.popups.filter(p => p !== n);
    }

    // Chamada quando o card expira na tela, e não quando a notificação fecha:
    // fechar já passa pelo removePopup, e dispensar dali entraria em recursão.
    function expirePopup(n: var): void {
        root.removePopup(n);

        // Pela spec, transiente é o que não deve ser guardado: vale como popup e
        // acaba junto com ele, sem entrar no histórico.
        if (n && n.transient)
            n.dismiss();
    }

    function dismissAll(): void {
        for (const n of root.list.values.slice())
            n.dismiss();
    }

    // O `tick` não é usado: existe para o binding de quem chama reavaliar a cada
    // segundo do Time.now.
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

            // Em não perturbe a transiente não teria popup para expirar, e é
            // justamente o que não se guarda: ficaria presa no histórico.
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
