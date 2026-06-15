pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Io

Rectangle {
    id: audioRoot

    // ── Execução do Wiremix via Ghostty ───────────────────────────────────────
    Process {
        id: wiremixCmd
        command: ["uwsm", "app", "--", "ghostty", "--class=com.example.wiremix", "--command=wiremix"]
        running: false
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink

    property int volumePct: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0
    property bool isMuted: (sink && sink.audio) ? sink.audio.muted : true

    property string volIcon: {
        if (isMuted || volumePct === 0)
            return "󰝟";
        if (volumePct < 30)
            return "󰕿";
        if (volumePct < 70)
            return "󰖀";
        return "󰕾";
    }

    property color volColor: isMuted ? Theme.love : Theme.foam

    // ── Dimensões e Estilo ────────────────────────────────────────────────────
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 36
    radius: height / 2
    color: Theme.base

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: audioRoot.volIcon
            color: audioRoot.volColor
            font.family: "Hack Nerd Font"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Text {
            text: audioRoot.volumePct + "%"
            color: audioRoot.volColor
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    // ── Interação (Clique e Scroll) ───────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                wiremixCmd.running = false;
                wiremixCmd.running = true;
            } else if (mouse.button === Qt.RightButton) {
                if (audioRoot.sink && audioRoot.sink.audio) {
                    audioRoot.sink.audio.muted = !audioRoot.sink.audio.muted;
                }
            }
        }

        onWheel: function (wheel) {
            if (!audioRoot.sink || !audioRoot.sink.audio)
                return;

            let currentVol = audioRoot.sink.audio.volume;
            let step = 0.05;

            if (wheel.angleDelta.y > 0) {
                audioRoot.sink.audio.volume = Math.min(1.0, currentVol + step);
            } else if (wheel.angleDelta.y < 0) {
                audioRoot.sink.audio.volume = Math.max(0.0, currentVol - step);
            }
        }
    }
}
