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
        precision: SystemClock.Minutes
    }
}
