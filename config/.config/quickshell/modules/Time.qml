pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string timeString: {
        Qt.formatDateTime(clock.date, "dd hh:mm");
    }

    readonly property string dateString: {
        Qt.formatDateTime(clock.date, "d MMMM dddd");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
