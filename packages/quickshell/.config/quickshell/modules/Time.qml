pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property date now: clock.date

    readonly property string timeString: Qt.formatDateTime(clock.date, "hh:mm")

    readonly property string dateString: clock.date.toLocaleDateString(Qt.locale("pt_BR"), "d MMMM dddd")

    SystemClock {
        id: clock
        // O timer do Qt corre sobre CLOCK_MONOTONIC, que não conta tempo suspenso:
        // com precisão de minutos o horário fica defasado ao voltar do suspend.
        precision: SystemClock.Seconds
    }
}
