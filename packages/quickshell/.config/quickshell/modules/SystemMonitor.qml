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
            return Theme.accent;
        case PowerProfile.PowerSaver:
            return Theme.green;
        default:
            return Theme.blue;
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

    property real prevCpuTotal: -1
    property real prevCpuIdle: 0

    FileView {
        id: statFile
        path: "/proc/stat"
        blockLoading: true
    }
    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
    }
    FileView {
        id: tempFile
        path: "/sys/class/thermal/thermal_zone0/temp"
        blockLoading: true
    }

    function meminfoKb(text, key) {
        const m = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"));
        return m ? parseInt(m[1]) : 0;
    }

    function refreshHardware() {
        statFile.reload();
        memFile.reload();
        tempFile.reload();

        const cpu = statFile.text().split("\n")[0].trim().split(/\s+/);
        if (cpu.length >= 9) {
            let total = 0;
            for (let i = 1; i <= 8; i++)
                total += parseInt(cpu[i]);
            const idle = parseInt(cpu[4]) + parseInt(cpu[5]);
            const dTotal = total - sys.prevCpuTotal;
            const dIdle = idle - sys.prevCpuIdle;
            if (sys.prevCpuTotal >= 0 && dTotal > 0)
                sys.cpuPct = Math.floor(100 * (dTotal - dIdle) / dTotal);
            sys.prevCpuTotal = total;
            sys.prevCpuIdle = idle;
        }

        const mem = memFile.text();
        const memTotal = sys.meminfoKb(mem, "MemTotal");
        if (memTotal > 0) {
            const used = memTotal - sys.meminfoKb(mem, "MemAvailable");
            sys.ramPct = Math.floor(100 * used / memTotal);
        }

        const t = parseInt(tempFile.text());
        if (!isNaN(t))
            sys.tempC = Math.floor(t / 1000);
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: sys.refreshHardware()
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
    property string brightnessPath: ""
    property int brightnessMax: 0
    signal osdRequested(real newVal)

    function applyBrightness(newVal) {
        if (isNaN(newVal))
            return;
        if (sys.currentBrightness === -1) {
            sys.currentBrightness = newVal;
        } else if (newVal !== sys.currentBrightness) {
            sys.currentBrightness = newVal;
            sys.osdRequested(newVal);
        }
    }

    Process {
        id: detectBacklight
        command: ["brightnessctl", "-m"]
        running: true
        stdout: SplitParser {
            onRead: function (line) {
                const f = line.trim().split(",");
                if (f.length < 5)
                    return;
                const max = parseInt(f[4]);
                if (isNaN(max) || max <= 0)
                    return;
                sys.brightnessMax = max;
                sys.brightnessPath = (f[1] === "backlight" ? "/sys/class/backlight/" : "/sys/class/leds/") + f[0] + "/brightness";
            }
        }
    }

    FileView {
        id: brightnessFile
        path: sys.brightnessPath
        blockLoading: true
    }

    Process {
        id: brightnessCmd
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                sys.applyBrightness(parseInt(line.trim()));
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
        onTriggered: {
            if (sys.brightnessPath === "") {
                brightnessCmd.running = true;
                return;
            }
            brightnessFile.reload();
            sys.applyBrightness(Math.round(100 * parseInt(brightnessFile.text()) / sys.brightnessMax));
        }
    }
}
