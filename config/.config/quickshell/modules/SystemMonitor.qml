pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "."

Item {
    id: sys

    // ── BATERIA E ENERGIA (Bug Matemático Resolvido) ──────────────────────────
    property var device: UPower.displayDevice

    // O dispositivo só é válido se não for nulo E o UPower já tiver carregado os dados (ready)
    property bool isValid: device !== null && device.ready

    // O Segredo: multiplicar o valor (que é de 0.0 a 1.0) por 100 antes de arredondar
    property int pct: isValid ? Math.round(device.percentage * 100) : 0

    property int batteryState: isValid ? device.state : UPowerDeviceState.Unknown
    property bool isCharging: batteryState === UPowerDeviceState.Charging || batteryState === UPowerDeviceState.FullyCharged

    property string battIcon: {
        if (isCharging)
            return "󰂄";
        if (pct <= 10)
            return "󰁺";
        if (pct <= 30)
            return "󰁼";
        if (pct <= 50)
            return "󰁾";
        if (pct <= 80)
            return "󰂀";
        return "󰁹";
    }

    property string ppIcon: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return "󱐋";
        case PowerProfile.PowerSaver:
            return "󰌪";
        default:
            return "󰈐";
        }
    }
    property string ppLabel: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return "Performance";
        case PowerProfile.PowerSaver:
            return "Power Saver";
        default:
            return "Balanced";
        }
    }
    property color ppColor: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return Theme.love;
        case PowerProfile.PowerSaver:
            return Theme.pine;
        default:
            return Theme.foam;
        }
    }
    function cycleProfile() {
        switch (PowerProfiles.profile) {
        case PowerProfile.Balanced:
            PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        case PowerProfile.PowerSaver:
            PowerProfiles.profile = PowerProfile.Performance;
            break;
        default:
            PowerProfiles.profile = PowerProfile.Balanced;
            break;
        }
    }

    // ── ÁUDIO E WIREMIX ───────────────────────────────────────────────────────
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    property var sink: Pipewire.defaultAudioSink
    property int volumePct: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0
    property bool isMuted: (sink && sink.audio) ? sink.audio.muted : true

    function setVolume(pct) {
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0.0, Math.min(1.0, pct / 100.0));
    }

    function toggleMute() {
        if (sink && sink.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    Process {
        id: wiremixCmd
        command: ["uwsm", "app", "--", "ghostty", "--class=com.example.wiremix", "--command=wiremix"]
        running: false
    }
    function openWiremix() {
        wiremixCmd.running = false;
        wiremixCmd.running = true;
    }

    // ── HARDWARE (CPU/RAM/TEMP) ───────────────────────────────────────────────
    property int cpuPct: 0
    property int ramPct: 0
    property int tempC: 0
    Process {
        id: hwMonitor
        command: ["bash", "-c", "while true; do read -r _ u1 n1 s1 i1 io1 ir1 si1 st1 _ < /proc/stat; sleep 2; read -r _ u2 n2 s2 i2 io2 ir2 si2 st2 _ < /proc/stat; t1=$((u1+n1+s1+i1+io1+ir1+si1+st1)); t2=$((u2+n2+s2+i2+io2+ir2+si2+st2)); id1=$((i1+io1)); id2=$((i2+io2)); diff_t=$((t2-t1)); diff_id=$((id2-id1)); if [ $diff_t -eq 0 ]; then cpu=0; else cpu=$(( 100 * (diff_t - diff_id) / diff_t )); fi; ram=$(free -m | awk 'NR==2{printf \"%d\", $3*100/$2}'); temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'); echo \"$cpu,$ram,${temp:-0}\"; done"]
        running: true
        stdout: SplitParser {
            onRead: function (data) {
                let parts = data.split(",");
                if (parts.length >= 3) {
                    sys.cpuPct = parseInt(parts[0]);
                    sys.ramPct = parseInt(parts[1]);
                    sys.tempC = parseInt(parts[2]);
                }
            }
        }
    }

    Process {
        id: btopCmd
        command: ["uwsm", "app", "--", "ghostty", "--class=com.example.btop", "--command=btop"]
        running: false
    }
    function openBtop() {
        btopCmd.running = false;
        btopCmd.running = true;
    }

    // ── BRILHO E OSD ──────────────────────────────────────────────────────────
    property real currentBrightness: -1
    signal osdRequested(real newVal)

    Process {
        id: brightnessCmd
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                const newVal = parseInt(line.trim());
                if (isNaN(newVal))
                    return;
                if (sys.currentBrightness === -1) {
                    sys.currentBrightness = newVal;
                } else if (newVal !== sys.currentBrightness) {
                    sys.currentBrightness = newVal;
                    sys.osdRequested(newVal);
                }
            }
        }
    }
    Process {
        id: writeBrightnessCmd
        running: false
    }
    function setBrightness(percent) {
        let safePct = Math.max(0, Math.min(100, Math.round(percent)));
        currentBrightness = safePct;
        writeBrightnessCmd.command = ["brightnessctl", "set", safePct + "%"];
        writeBrightnessCmd.running = true;
    }
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: brightnessCmd.running = true
    }
}
