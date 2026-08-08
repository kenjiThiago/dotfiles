pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int islandState: 0
    property bool calendarExpanded: false
    property bool grabAlive: true

    // Abrir um menu da bandeja exige derrubar o grab, para o menu receber foco.
    // Isso devolve o foco ao toplevel de baixo e move o ponteiro para fora do
    // menu que ainda não apareceu, e os dois eventos caem em cima de grabAlive
    // já falso, que é a condição de fechar a ilha. Enquanto o menu está a
    // caminho, nenhum dos dois conta.
    property bool expectingMenu: false

    function expectMenu(): void {
        root.grabAlive = false;
        root.expectingMenu = true;
        menuGrace.restart();
    }

    Timer {
        id: menuGrace
        interval: 1000
        onTriggered: root.expectingMenu = false
    }

    IpcHandler {
        target: "bar"

        function cycle(): void {
            if (root.islandState === 0)
                root.islandState = 1;
            else if (root.islandState === 1)
                root.islandState = 2;
            else
                root.islandState = 0;
            root.calendarExpanded = false;
            root.grabAlive = true;
        }

        // Atalho direto para o state 2, sem passar pelo ciclo.
        function center(): void {
            root.islandState = root.islandState === 2 ? 0 : 2;
            root.calendarExpanded = false;
            root.grabAlive = true;
        }
    }

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            if (root.expectingMenu)
                return;
            if (root.islandState > 0 && !root.grabAlive) {
                root.islandState = 0;
                root.calendarExpanded = false;
                root.grabAlive = true;
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            color: "transparent"
            implicitHeight: 40
            exclusiveZone: 40
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope
            required property var modelData

            // ── O ESCUDO FORMATO "U" (Cobre todos os lados, exceto a Ilha) ────────
            PanelWindow {
                id: shieldWindow
                screen: screenScope.modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                // Sempre mapeada. Alternar o visible de uma layer surface a
                // desmapeia e remapeia, e o remapeamento a joga para o topo da
                // camada, acima da ilha e do menu da bandeja. Ela é declarada
                // antes da ilha justamente para ficar embaixo, então quem liga e
                // desliga é a máscara.
                visible: true

                readonly property bool catching: root.islandState > 0 && !root.grabAlive

                function closeAll() {
                    root.calendarExpanded = false;
                    root.islandState = 0;
                    root.grabAlive = true;
                }

                Item {
                    id: noBarrier
                    width: 0
                    height: 0
                }

                mask: Region {
                    Region {
                        item: shieldWindow.catching ? barrierLeft : noBarrier
                    }
                    Region {
                        item: shieldWindow.catching ? barrierRight : noBarrier
                    }
                    Region {
                        item: shieldWindow.catching ? barrierBottom : noBarrier
                    }
                }

                // Barreira esquerda
                MouseArea {
                    id: barrierLeft
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: (parent.width - island.width) / 2
                    onPressed: function (m) {
                        m.accepted = true;
                        shieldWindow.closeAll();
                    }
                }

                // Barreira direita
                MouseArea {
                    id: barrierRight
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: (parent.width - island.width) / 2
                    onPressed: function (m) {
                        m.accepted = true;
                        shieldWindow.closeAll();
                    }
                }

                // Barreira de baixo: começa onde a ilha termina.
                MouseArea {
                    id: barrierBottom
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: parent.height - (island.height + 12)
                    onPressed: function (m) {
                        m.accepted = true;
                        shieldWindow.closeAll();
                    }
                }
            }

            // ── A JANELA DA ILHA ──────────────────────────────────────────────
            PanelWindow {
                id: islandWindow
                screen: screenScope.modelData
                anchors {
                    top: true
                    left: true
                    right: true
                }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                implicitHeight: 640

                function expectMenu() {
                    root.expectMenu();
                }

                // ── SENSOR DE FOCO CORRIGIDO (O fim do bug do duplo clique) ──
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton // <- Essa linha impede o roubo de cliques direitos!
                    function rearm() {
                        if (root.expectingMenu)
                            return;
                        if (root.islandState > 0 && !root.grabAlive) {
                            root.grabAlive = true;
                        }
                    }
                    onEntered: rearm()
                    onPositionChanged: rearm()
                }

                mask: Region {
                    item: island
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [islandWindow, calendarWindow]

                    active: root.islandState > 0 && root.grabAlive

                    onCleared: {
                        if (!root.grabAlive)
                            return;

                        root.calendarExpanded = false;
                        root.islandState = 0;
                    }
                }

                ClockWidget {
                    id: island
                    islandState: root.islandState
                    hostWindow: islandWindow

                    onRequestState: function (newState) {
                        root.islandState = newState;
                        if (newState !== 1)
                            root.calendarExpanded = false;
                    }

                    onCalendarRequested: {
                        if (root.islandState === 2) {
                            root.islandState = 1;
                            root.calendarExpanded = true;
                        } else {
                            root.calendarExpanded = !root.calendarExpanded;
                        }
                    }
                }
            }

            // ── A JANELA DO CALENDÁRIO ────────────────────────────────────────
            PanelWindow {
                id: calendarWindow
                screen: screenScope.modelData
                anchors {
                    top: true
                    left: true
                    right: true
                }
                margins {
                    top: 96
                }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                implicitHeight: 400

                Item {
                    id: emptyRegion
                    width: 0
                    height: 0
                }

                mask: Region {
                    item: root.calendarExpanded ? calWidget : emptyRegion
                }

                CalendarWidget {
                    id: calWidget
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: root.calendarExpanded ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }

            // ── A JANELA DOS POPUPS ───────────────────────────────────────────
            PanelWindow {
                id: notifyWindow
                screen: screenScope.modelData
                anchors {
                    top: true
                    right: true
                }
                // Mesma margem do topo da ilha, para os popups nascerem no nível
                // dela. A faixa da barra é transparente e vazia, e a ilha fica
                // centralizada, então não há o que desviar aqui.
                margins {
                    top: 6
                    right: 12
                }
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore

                visible: Notifications.popups.length > 0

                implicitWidth: 400
                implicitHeight: Math.max(1, popupColumn.implicitHeight)

                mask: Region {
                    item: popupColumn
                }

                Column {
                    id: popupColumn
                    anchors.right: parent.right
                    spacing: 10

                    // A entrada precisa vir daqui: a Column controla o x e o y
                    // dos filhos, então animar isso no card não teria efeito.
                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 200
                        }
                        NumberAnimation {
                            property: "x"
                            from: 40
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    move: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Repeater {
                        model: Notifications.popups

                        delegate: NotificationPopup {
                            required property var modelData
                            notification: modelData
                        }
                    }
                }
            }
        }
    }
}
