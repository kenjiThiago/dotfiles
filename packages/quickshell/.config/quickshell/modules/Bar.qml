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

    // Derrubar o grab para o menu receber foco devolve o foco ao toplevel de
    // baixo e tira o ponteiro do menu, e os dois fechariam a ilha.
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

                // Alternar o visible remapeia a layer surface e a joga para o topo
                // da camada, acima da ilha e do menu. Quem alterna é a máscara.
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
        }
    }

    // ── A JANELA DOS POPUPS ───────────────────────────────────────────────────
    // Fora do Variants por tela de propósito: a fila de popups é global, então
    // uma janela por monitor mostrava a mesma notificação repetida, cada cópia
    // com o seu próprio timer. Uma janela só, na tela que estiver em foco.
    PanelWindow {
        id: notifyWindow

        // O HyprlandMonitor não expõe a ShellScreen, só o nome. O recuo cobre o
        // intervalo entre subir o shell e o IPC do Hyprland responder.
        screen: {
            const m = Hyprland.focusedMonitor;
            if (m)
                for (const s of Quickshell.screens)
                    if (s.name === m.name)
                        return s;
            return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
        }

        // Ancorada embaixo para a altura vir das âncoras e não do conteúdo: cada
        // redimensionamento da superfície passa pelo configure do Wayland, e o
        // compositor exibe o buffer antigo enquanto isso. Transparente e com o
        // mask limitando o clique aos cards, ocupar a coluna toda não custa nada.
        anchors {
            top: true
            right: true
            bottom: true
        }
        // Mesma margem do topo da ilha, para nascerem no nível dela.
        margins {
            top: 6
            right: 12
        }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        visible: Notifications.popupCount > 0

        implicitWidth: 400

        mask: Region {
            item: popupColumn
        }

        Column {
            id: popupColumn
            anchors.right: parent.right
            spacing: 10

            // Um positionador em janela desmapeada não refaz o layout, e é a
            // geometria desta Column que define o mask: sem o forceLayout a área
            // clicável volta com o tamanho da fila anterior.
            Connections {
                target: Notifications
                function onPopupCountChanged() {
                    popupColumn.forceLayout();
                }
            }

            // Só o x. A opacidade fica com o card porque uma transição cancelada
            // no meio congela a propriedade, e a Column reescreve x no layout
            // seguinte mas não a opacidade.
            add: Transition {
                NumberAnimation {
                    property: "x"
                    from: 40
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            // Depende da altura fixa da janela: se ela voltar a sair do conteúdo,
            // estes 250ms deixam a superfície e o desenho em desacordo.
            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: Notifications.popups

                // O role `notification` do ListModel entra direto no required
                // property de mesmo nome do card.
                delegate: NotificationPopup {}
            }
        }
    }
}
