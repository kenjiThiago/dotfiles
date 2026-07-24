pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: calRoot
    width: 280
    height: 320
    radius: 20
    color: Theme.base
    border.color: Theme.overlay
    border.width: 1

    // ── Lógica de Datas ───────────────────────────────────────────────────────
    readonly property var today: Time.now
    property int currentMonth: today.getMonth()
    property int currentYear: today.getFullYear()

    readonly property var monthNames: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    readonly property var dayNames: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]

    property var gridDays: {
        let days = [];
        let firstDay = new Date(currentYear, currentMonth, 1).getDay();
        let daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
        let daysInPrevMonth = new Date(currentYear, currentMonth, 0).getDate();

        for (let i = firstDay - 1; i >= 0; i--) {
            days.push({
                day: daysInPrevMonth - i,
                isCurrentMonth: false
            });
        }
        for (let i = 1; i <= daysInMonth; i++) {
            days.push({
                day: i,
                isCurrentMonth: true
            });
        }
        let remaining = 42 - days.length;
        for (let i = 1; i <= remaining; i++) {
            days.push({
                day: i,
                isCurrentMonth: false
            });
        }
        return days;
    }

    function prevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
    }

    // ── UI Principal ──────────────────────────────────────────────────────────
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        RowLayout {
            width: parent.width

            Text {
                text: ""
                font.family: "Hack Nerd Font"
                font.pixelSize: 14
                color: Theme.subtle
                TapHandler {
                    onTapped: calRoot.prevMonth()
                }
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: calRoot.monthNames[calRoot.currentMonth] + " " + calRoot.currentYear
                color: Theme.text
                font.family: "Hack Nerd Font"
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            Text {
                text: ""
                font.family: "Hack Nerd Font"
                font.pixelSize: 14
                color: Theme.subtle
                TapHandler {
                    onTapped: calRoot.nextMonth()
                }
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Column {
            spacing: 12
            width: parent.width

            Row {
                spacing: 0
                Repeater {
                    model: calRoot.dayNames
                    delegate: Text {
                        required property string modelData
                        width: 35
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.love
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }
                }
            }

            GridLayout {
                columns: 7
                columnSpacing: 0
                rowSpacing: 4

                Repeater {
                    model: calRoot.gridDays
                    delegate: Rectangle {
                        id: dayCell
                        required property var modelData
                        readonly property bool isToday: modelData.isCurrentMonth && modelData.day === calRoot.today.getDate() && calRoot.currentMonth === calRoot.today.getMonth() && calRoot.currentYear === calRoot.today.getFullYear()

                        width: 35
                        height: 30
                        radius: 8
                        color: dayCell.isToday ? Theme.love : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: dayCell.modelData.day

                            color: dayCell.isToday ? Theme.surface : (dayCell.modelData.isCurrentMonth ? Theme.text : Theme.muted)

                            font.family: "Hack Nerd Font"
                            font.pixelSize: 13
                            font.weight: dayCell.isToday ? Font.Bold : Font.Normal
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.overlay
                }

                Text {
                    id: todayBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ir para Hoje"

                    color: btnHover.hovered ? Theme.text : Theme.subtle

                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    font.weight: Font.Bold

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    TapHandler {
                        onTapped: {
                            calRoot.currentMonth = calRoot.today.getMonth();
                            calRoot.currentYear = calRoot.today.getFullYear();
                        }
                    }

                    HoverHandler {
                        id: btnHover
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
