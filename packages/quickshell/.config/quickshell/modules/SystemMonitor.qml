pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "."

Item {
    id: sys

    // ── BATERIA E ENERGIA ─────────────────────────────────────────────────────
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

    // Quem escreve o volume é o wpctl, pelos atalhos do keybinds.lua, então aqui
    // só se observa o Pipewire. Sai o mesmo sinal para o atalho e para o slider
    // do control center, já que os dois terminam numa mudança do sink.
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
    property int pendingBrightness: -1
    signal brightnessOsdRequested

    // Piso do que este shell escreve: em 0 o backlight apaga de vez, e voltar de
    // lá é acertar o atalho às cegas. Vale para o slider e para a roda também,
    // que passam pelo mesmo setBrightness. O que vem de fora não é clampeado: o
    // hypridle escurece de propósito e o applyBrightness tem que dizer a verdade.
    readonly property int brightnessMin: 5

    // Quem mexe no brilho é este shell, pelos atalhos do keybinds.lua. Antes um
    // Timer relia o sysfs a 10Hz para descobrir a mudança, e isso sozinho era
    // quatro quintos do CPU em repouso do processo.
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
        // Fora do applyBrightness porque o setBrightness não passa por lá, e
        // porque nos extremos o valor não muda mas o OSD ainda tem que aparecer.
        sys.brightnessOsdRequested();
    }

    // Para o que muda o brilho por fora, como o hypridle. Sem poll, quem chama é
    // o control center ao abrir.
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

    // Um brightnessctl de cada vez: com o processo anterior ainda vivo, atribuir
    // running = true de novo não faz nada e a escrita se perde.
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
}
