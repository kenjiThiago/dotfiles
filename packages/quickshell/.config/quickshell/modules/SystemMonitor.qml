pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "."

Item {
    id: sys

    property var device: UPower.displayDevice

    property bool isValid: device !== null && device.ready

    // O percentage do UPower vem de 0.0 a 1.0, apesar do nome.
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
            return "Desempenho";
        case PowerProfile.PowerSaver:
            return "Economia";
        default:
            return "Equilibrado";
        }
    }
    property color ppColor: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance:
            return Theme.yellow;
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

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
    property var sink: Pipewire.defaultAudioSink
    property int volumePct: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0
    property bool isMuted: (sink && sink.audio) ? sink.audio.muted : true

    property var sourceSink: Pipewire.defaultAudioSource
    property bool sourceIsMuted: (sourceSink && sourceSink.audio) ? sourceSink.audio.muted : true

    // Sem o tracker o state dos grupos fica parado em Unlinked.
    PwObjectTracker {
        objects: Pipewire.linkGroups.values
    }
    readonly property var activeLinkGroups: Pipewire.linkGroups.values.filter(g => g.state === PwLinkState.Active && g.source && g.target)

    // O rnnoise e os medidores de nível ficam ligados ao microfone o tempo todo,
    // e não são um app gravando.
    readonly property bool micInUse: activeLinkGroups.some(g => g.source.type === PwNodeType.AudioSource && g.target.type === PwNodeType.AudioInStream && !g.target.properties["node.link-group"] && !g.target.properties["stream.monitor"])
    readonly property bool cameraInUse: activeLinkGroups.some(g => g.source.type === PwNodeType.VideoSource && g.source.properties["device.api"] !== undefined)

    // Pelo Hyprland e não pelo Pipewire: pega também quem usa o screencopy direto,
    // como o grim, sem passar pelo portal.
    property bool screenCaptured: false

    function setVolume(pct) {
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0.0, Math.min(1.0, pct / 100.0));
    }

    function toggleMute() {
        if (sink && sink.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    // O volume é escrito pelo wpctl (keybinds.lua); aqui só se observa o Pipewire.
    signal volumeOsdRequested

    // O sink do Pipewire liga depois do shell, e ligar já mexe no volumePct e no
    // isMuted. Sem essa janela o OSD apareceria sozinho no login.
    property bool volumeSettled: false
    Timer {
        id: volumeSettle
        interval: 500
        running: true
        onTriggered: sys.volumeSettled = true
    }
    onSinkChanged: {
        sys.volumeSettled = false;
        volumeSettle.restart();
    }
    onVolumePctChanged: {
        if (sys.volumeSettled)
            sys.volumeOsdRequested();
    }
    onIsMutedChanged: {
        if (sys.volumeSettled)
            sys.volumeOsdRequested();
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

    property int cpuPct: 0
    property int ramPct: 0
    property int tempC: 0

    property int cpuAlert: 0
    property int ramAlert: 0
    property int tempAlert: 0

    onCpuPctChanged: cpuAlert = alertLevel(cpuPct, cpuAlert, 80, 95)
    onRamPctChanged: ramAlert = alertLevel(ramPct, ramAlert, 80, 95)
    onTempCChanged: tempAlert = alertLevel(tempC, tempAlert, 80, 90)

    function alertLevel(value, previous, warning, critical) {
        if (value >= critical || (previous === 2 && value >= critical - 5))
            return 2;
        if (value >= warning || (previous >= 1 && value >= warning - 5))
            return 1;
        return 0;
    }

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

    property real currentBrightness: -1
    property string brightnessPath: ""
    property int brightnessMax: 0
    property int pendingBrightness: -1
    signal brightnessOsdRequested

    // Piso do que este shell escreve: em 0 o backlight apaga de vez. O que vem de
    // fora, como o hypridle, não é clampeado.
    readonly property int brightnessMin: 5

    // Sem poll do sysfs: a 10Hz ele custava quatro quintos do CPU em repouso.
    IpcHandler {
        target: "brightness"

        function up(): void {
            sys.stepBrightness(5);
        }

        function down(): void {
            sys.stepBrightness(-5);
        }
    }

    function stepBrightness(delta: int): void {
        if (sys.currentBrightness < 0)
            return;

        sys.setBrightness(sys.currentBrightness + delta);
        // Aqui porque o setBrightness não passa pelo applyBrightness, e nos extremos o
        // valor não muda mas o OSD ainda tem que aparecer.
        sys.brightnessOsdRequested();
    }

    // Para o que muda o brilho por fora, como o hypridle; chamado ao abrir o control center.
    function refreshBrightness(): void {
        if (sys.brightnessBusy)
            return;

        if (sys.brightnessPath === "")
            brightnessCmd.running = true;
        else
            brightnessFile.reload();
    }

    // Durante a interação o sysfs ainda devolve o valor anterior: o brightnessctl
    // leva alguns quadros para assentar.
    readonly property bool brightnessBusy: brightnessSettle.running || writeBrightnessCmd.running || sys.pendingBrightness >= 0

    function applyBrightness(newVal) {
        if (isNaN(newVal) || sys.brightnessBusy)
            return;
        if (sys.currentBrightness === -1) {
            sys.currentBrightness = newVal;
        } else if (newVal !== sys.currentBrightness) {
            sys.currentBrightness = newVal;
            sys.brightnessOsdRequested();
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

        // O reload() é assíncrono e o blockLoading só cobre a carga inicial: ler
        // no mesmo quadro devolve o conteúdo em cache.
        onLoaded: sys.applyBrightness(Math.round(100 * parseInt(brightnessFile.text()) / sys.brightnessMax))
    }

    // Recuo para quando o detectBacklight não resolve um caminho de sysfs.
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
        onExited: sys.flushBrightness()
    }
    Timer {
        id: brightnessSettle
        interval: 400
    }

    // Um processo de cada vez: com o anterior vivo, running = true não faz nada.
    function flushBrightness() {
        if (sys.pendingBrightness < 0)
            return;
        writeBrightnessCmd.command = ["brightnessctl", "set", sys.pendingBrightness + "%"];
        sys.pendingBrightness = -1;
        writeBrightnessCmd.running = false;
        writeBrightnessCmd.running = true;
    }

    function setBrightness(percent) {
        let safePct = Math.max(sys.brightnessMin, Math.min(100, Math.round(percent)));
        brightnessSettle.restart();
        if (safePct === sys.currentBrightness)
            return;
        sys.currentBrightness = safePct;
        sys.pendingBrightness = safePct;
        if (!writeBrightnessCmd.running)
            sys.flushBrightness();
    }

    property string keyboardLayout: ""
    property bool keyboardIsDefault: true

    // O activelayout traz o nome longo ("Greek"); o código vem da lista do kb_layout.
    Process {
        id: keyboardCmd
        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const kb = JSON.parse(this.text).keyboards.find(k => k.main);
                if (!kb)
                    return;
                const layouts = kb.layout.split(",").map(l => l.trim());
                sys.keyboardLayout = (layouts[kb.active_layout_index] || "").toUpperCase();
                sys.keyboardIsDefault = kb.active_layout_index === 0;
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout" || event.name === "configreloaded")
                keyboardSettle.restart();
            else if (event.name === "screencast")
                sys.screenCaptured = event.data.startsWith("1");
        }
    }

    // O activelayout chega uma vez por teclado, em rajada; reiniciar o hyprctl a
    // cada um mata a saída no meio e o JSON.parse recebe um pedaço.
    Timer {
        id: keyboardSettle
        interval: 100
        onTriggered: {
            keyboardCmd.running = false;
            keyboardCmd.running = true;
        }
    }

    property bool vpnActive: false

    Process {
        id: vpnCmd
        command: ["nmcli", "-t", "-f", "TYPE", "connection", "show", "--active"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: sys.vpnActive = this.text.split("\n").includes("vpn")
        }
    }

    // O monitor só avisa que algo mudou, e em várias linhas por mudança.
    Process {
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: vpnSettle.restart()
        }
    }

    Timer {
        id: vpnSettle
        interval: 300
        onTriggered: {
            vpnCmd.running = false;
            vpnCmd.running = true;
        }
    }
}
