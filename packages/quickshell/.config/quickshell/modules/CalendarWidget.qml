pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: calRoot
    width: 304
    height: calendarContent.implicitHeight + 32
    radius: 16
    color: Theme.base
    border.color: Theme.highlightMed
    border.width: 1

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

    Column {
        id: calendarContent

        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            width: parent.width

            Rectangle {
                color: previousMouse.pressed ? Theme.overlay : (previousMouse.containsMouse ? Theme.surface : "transparent")
                implicitHeight: 32
                implicitWidth: 32
                radius: 8

                Text {
                    anchors.centerIn: parent
                    color: previousMouse.containsMouse ? Theme.accent : Theme.subtle
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    text: ""
                }
                MouseArea {
                    id: previousMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: calRoot.prevMonth()
                }
            }
            Text {
                Layout.fillWidth: true
                color: Theme.text
                font.family: "Hack Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                text: calRoot.monthNames[calRoot.currentMonth] + " " + calRoot.currentYear
            }
            Rectangle {
                color: nextMouse.pressed ? Theme.overlay : (nextMouse.containsMouse ? Theme.surface : "transparent")
                implicitHeight: 32
                implicitWidth: 32
                radius: 8

                Text {
                    anchors.centerIn: parent
                    color: nextMouse.containsMouse ? Theme.accent : Theme.subtle
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    text: ""
                }
                MouseArea {
                    id: nextMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: calRoot.nextMonth()
                }
            }
        }
        Column {
            spacing: 8
            width: parent.width

            Row {
                spacing: 0
                width: parent.width

                Repeater {
                    model: calRoot.dayNames

                    delegate: Text {
                        required property string modelData

                        color: Theme.subtle
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        width: parent.width / 7
                    }
                }
            }
            Grid {
                columnSpacing: 0
                columns: 7
                rowSpacing: 4
                width: parent.width

                Repeater {
                    model: calRoot.gridDays

                    delegate: Rectangle {
                        id: dayCell

                        readonly property bool isToday: modelData.isCurrentMonth && modelData.day === calRoot.today.getDate() && calRoot.currentMonth === calRoot.today.getMonth() && calRoot.currentYear === calRoot.today.getFullYear()
                        required property var modelData

                        color: dayCell.isToday ? Theme.accent : "transparent"
                        height: 30
                        radius: 8
                        width: parent.width / 7

                        Text {
                            anchors.centerIn: parent
                            color: dayCell.isToday ? Theme.base : (dayCell.modelData.isCurrentMonth ? Theme.text : Theme.muted)
                            font.family: "Hack Nerd Font"
                            font.pixelSize: 13
                            font.weight: dayCell.isToday ? Font.Bold : Font.Normal
                            text: dayCell.modelData.day
                        }
                    }
                }
            }
            Column {
                spacing: 8
                width: parent.width

                Rectangle {
                    color: Theme.overlay
                    height: 1
                    width: parent.width
                }
                Rectangle {
                    color: todayMouse.pressed ? Theme.overlay : (todayMouse.containsMouse ? Theme.surface : "transparent")
                    height: 32
                    radius: 8
                    width: parent.width

                    Text {
                        anchors.centerIn: parent
                        color: todayMouse.containsMouse ? Theme.accent : Theme.subtle
                        font.family: "Hack Nerd Font"
                        font.pixelSize: 12
                        text: "Ir para hoje"
                    }
                    MouseArea {
                        id: todayMouse

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            calRoot.currentMonth = calRoot.today.getMonth();
                            calRoot.currentYear = calRoot.today.getFullYear();
                        }
                    }
                }
            }
        }
    }
}
