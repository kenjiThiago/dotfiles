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

    property bool opened: false
    property string view: "days"
    property int firstYear: 0

    onOpenedChanged: {
        if (opened)
            goToToday();
    }

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

    function goToToday() {
        currentMonth = today.getMonth();
        currentYear = today.getFullYear();
        view = "days";
    }

    function navigate(direction) {
        if (view === "years") {
            firstYear += direction * 12;
        } else if (view === "months") {
            currentYear += direction;
        } else {
            const month = currentMonth + direction;
            currentYear += Math.floor(month / 12);
            currentMonth = (month + 12) % 12;
        }
    }

    function showOverview() {
        if (view === "days") {
            view = "months";
        } else if (view === "months") {
            firstYear = Math.floor(currentYear / 12) * 12;
            view = "years";
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

                    onClicked: calRoot.navigate(-1)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                radius: 8
                color: titleMouse.pressed ? Theme.overlay : (titleMouse.containsMouse ? Theme.surface : "transparent")

                Text {
                    anchors.centerIn: parent
                    color: titleMouse.containsMouse ? Theme.accent : Theme.text
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    text: calRoot.view === "days" ? calRoot.monthNames[calRoot.currentMonth] + " " + calRoot.currentYear : calRoot.view === "months" ? calRoot.currentYear : calRoot.firstYear + " – " + (calRoot.firstYear + 11)
                }
                MouseArea {
                    id: titleMouse

                    anchors.fill: parent
                    enabled: calRoot.view !== "years"
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: calRoot.showOverview()
                }
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

                    onClicked: calRoot.navigate(1)
                }
            }
        }
        Column {
            spacing: 8
            width: parent.width

            Item {
                width: parent.width
                height: daysContent.implicitHeight

                Column {
                    id: daysContent
                    width: parent.width
                    spacing: 8
                    visible: calRoot.view === "days"

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
                }
                Grid {
                    anchors.fill: parent
                    columns: 3
                    columnSpacing: 6
                    rowSpacing: 6
                    visible: calRoot.view !== "days"

                    Repeater {
                        model: 12

                        delegate: Rectangle {
                            id: choiceCell
                            required property int index
                            readonly property int year: calRoot.firstYear + index
                            readonly property bool selected: calRoot.view === "months" ? index === calRoot.currentMonth : year === calRoot.currentYear

                            width: (parent.width - 12) / 3
                            height: (parent.height - 18) / 4
                            radius: 8
                            color: choiceMouse.pressed ? Theme.overlay : (choiceMouse.containsMouse ? Theme.surface : "transparent")
                            border.width: selected ? 1 : 0
                            border.color: Theme.accent

                            Text {
                                anchors.centerIn: parent
                                color: choiceCell.selected || choiceMouse.containsMouse ? Theme.accent : Theme.text
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 12
                                text: calRoot.view === "months" ? calRoot.monthNames[choiceCell.index].slice(0, 3) : choiceCell.year
                            }
                            MouseArea {
                                id: choiceMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if (calRoot.view === "years") {
                                        calRoot.currentYear = choiceCell.year;
                                        calRoot.view = "months";
                                    } else {
                                        calRoot.currentMonth = choiceCell.index;
                                        calRoot.view = "days";
                                    }
                                }
                            }
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

                        onClicked: calRoot.goToToday()
                    }
                }
            }
        }
    }
}
