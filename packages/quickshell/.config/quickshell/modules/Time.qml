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
        // Com precisão de minutos o timer do Qt corre sobre CLOCK_MONOTONIC, que
        // não conta o tempo suspenso, e o horário fica defasado por até um minuto
        // ao voltar do suspend.
        precision: SystemClock.Seconds
    }
}
