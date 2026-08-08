pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications
import "."

Item {
    id: root

    readonly property var blockedApps: ["Spotify"]

    // O histórico vive em memória, e cada notificação segura a própria imagem.
    readonly property int historyLimit: 50

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
    //
    // ListModel e não array: um Repeater com model de array reseta o modelo
    // inteiro a cada reatribuição, recriando todos os cards e seus timers.
    ListModel {
        id: popupQueue
        dynamicRoles: true
    }

    readonly property alias popups: popupQueue
    readonly property int popupCount: popupQueue.count

    // A API não carrega horário de chegada. A chave é o objeto e não o id
    // porque o replaces_id reaproveita o número.
    property var arrivalTimes: new Map()

    // Conjunto e não contador: markRead zera tudo de uma vez, e um contador
    // solto dessincronizaria com o decremento de cada fechamento.
    property var unreadIds: new Set()

    function markRead(): void {
        root.unreadIds.clear();
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

    // Só o popup desenha estas: o --wait que o notify-send embute no -A é
    // limitado pelo expire_timeout, então o cliente já saiu quando a
    // notificação chega ao histórico.
    function buttonActions(n: var): var {
        return n ? n.actions.filter(a => a.identifier !== "default") : [];
    }

    // O StyledText descarta a linha inteira diante de marcação inválida.
    function bodyText(n: var): string {
        if (!n)
            return "";

        let s = n.body;
        if (s === "")
            return "";

        // O card elide em poucas linhas, mas o layout paga pelo texto inteiro.
        if (s.length > 2000)
            s = s.slice(0, 2000) + "…";

        s = s.replace(/&(?![a-zA-Z][a-zA-Z0-9]*;|#[0-9]+;|#[xX][0-9a-fA-F]+;)/g, "&amp;");

        // Link e imagem ficam fora das capabilities que anunciamos.
        s = s.replace(/<img\b[^>]*>/gi, "");
        s = s.replace(/<\/?a\b[^>]*>/gi, "");

        // Sobra o subconjunto freedesktop; qualquer outra tag vira texto.
        return s.replace(/<(?!\/?[biu]>|br\s*\/?>)/gi, "&lt;");
    }

    // ── Ciclo de vida ─────────────────────────────────────────────────────────

    function popupIndex(n: var): int {
        for (let i = 0; i < popupQueue.count; i++)
            if (popupQueue.get(i).notification === n)
                return i;
        return -1;
    }

    function removePopup(n: var): void {
        const i = root.popupIndex(n);
        if (i >= 0)
            popupQueue.remove(i);
    }

    // Só para o card expirando na tela: chamar isto no closed daria recursão.
    function expirePopup(n: var): void {
        root.removePopup(n);

        // Transiente não se guarda: acaba junto com o popup.
        if (n && n.transient && n.tracked)
            n.dismiss();
    }

    // O invoke() já dispensa a notificação quando ela não é resident. Sendo,
    // ela continua de pé e o popup precisa sair na mão.
    function invokeAction(n: var, action: var): void {
        if (!n || !action)
            return;

        action.invoke();

        if (n.resident)
            root.removePopup(n);
    }

    function invokeDefault(n: var): void {
        if (!n)
            return;

        const def = root.defaultAction(n);
        if (def) {
            root.invokeAction(n, def);
            return;
        }

        if (n.tracked)
            n.dismiss();
    }

    function dismissAll(): void {
        for (const n of root.list.values.slice())
            n.dismiss();
    }

    // As críticas são poupadas do corte: só saem por decisão de quem lê.
    function trimHistory(): void {
        let excess = root.list.values.length - root.historyLimit;
        if (excess <= 0)
            return;

        // Cópia antes de dispensar: a coleção muda a cada dismiss.
        for (const n of root.list.values.slice()) {
            if (excess === 0)
                break;
            if (n.urgency === NotificationUrgency.Critical)
                continue;
            n.dismiss();
            excess--;
        }
    }

    function forget(n: var): void {
        root.arrivalTimes.delete(n);
        if (root.unreadIds.delete(n))
            root.unreadCount = root.unreadIds.size;
        root.removePopup(n);
    }

    // O `tick` não é usado: força o binding de quem chama a reavaliar.
    function relativeTime(n: var, tick: var): string {
        const at = root.arrivalTimes.get(n);
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

    // O keepOnReload devolve as notificações, mas não as repassa pelo
    // onNotification, então elas voltariam sem horário de chegada.
    Component.onCompleted: {
        const now = Date.now();
        for (const n of root.list.values)
            if (!root.arrivalTimes.has(n))
                root.arrivalTimes.set(n, now);
    }

    NotificationServer {
        id: server

        keepOnReload: true

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        // O NotificationAction expõe só identifier e text. Anunciar a capability
        // ainda transformaria o identifier em nome de ícone, quebrando a
        // detecção da ação "default".
        actionIconsSupported: false

        onNotification: function (n) {
            if (root.blockedApps.includes(n.appName))
                return;

            // Sem popup não há o que expirar, e ela ficaria presa no histórico.
            if (root.dnd && n.transient)
                return;

            // Sem isto a notificação é destruída assim que o sinal retorna.
            n.tracked = true;

            root.arrivalTimes.set(n, Date.now());
            root.unreadIds.add(n);
            root.unreadCount = root.unreadIds.size;

            // O replaces_id pode reaproveitar o mesmo objeto, que renderia dois
            // cards para uma notificação só.
            if (!root.dnd && root.popupIndex(n) < 0)
                popupQueue.append({
                    notification: n
                });

            root.trimHistory();
        }
    }

    // Um ponto de limpeza só, no lugar de um handler de closed por notificação:
    // alcança também o que sobreviveu ao hot reload, que nunca passa pelo
    // onNotification.
    Connections {
        target: server.trackedNotifications

        function onObjectRemovedPost(object, index) {
            root.forget(object);
        }
    }
}
