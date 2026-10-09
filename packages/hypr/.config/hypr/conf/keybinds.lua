local M = require("conf.programs")

-- Lado esquerdo do teclado para o que se usa com a mão no mouse; HJKL e vizinhos
-- para navegação. SUPER foca, SUPER+SHIFT move a janela, SUPER+CTRL age no grupo.

local mainMod = "SUPER"

hl.bind(mainMod .. "+ Q", hl.dsp.exec_cmd("uwsm app -- " .. M.terminal))
hl.bind(mainMod .. "+ SHIFT + Q", hl.dsp.exec_cmd("uwsm app -- zen-browser"))
hl.bind(mainMod .. "+ C", hl.dsp.window.close())
hl.bind(mainMod .. "+ M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. "+ ESCAPE", hl.dsp.exec_cmd("loginctl lock-session"))
local FLOAT_RATIO = 0.6

-- Só o primeiro float precisa de tamanho: depois o Hyprland lembra o último.
local floatedOnce = {}

hl.bind(mainMod .. "+ V", function()
    local w = hl.get_active_window()
    if not w then
        return
    end

    -- Lido antes do dispatch: depois do toggle o resize é animado.
    local first = not w.floating and not floatedOnce[w.address]
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    if not first then
        return
    end

    floatedOnce[w.address] = true

    local m = w.monitor
    local scale = (m and m.scale) or 1
    hl.dispatch(hl.dsp.window.resize({
        x = math.floor(m.width / scale * FLOAT_RATIO),
        y = math.floor(m.height / scale * FLOAT_RATIO),
    }))
    hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mainMod .. "+ R", hl.dsp.exec_cmd("uwsm app -- rofi-script"))
hl.bind(mainMod .. "+ A", hl.dsp.exec_cmd("uwsm app -- rofi-script apps"))
-- Mesma classe do control center e do rofi, para cair na regra do rules.lua.
hl.bind(mainMod .. "+ SHIFT + A",
    hl.dsp.exec_cmd("uwsm app -- ghostty --class=com.example.wiremix --command=wiremix"))
hl.bind(mainMod .. "+ SHIFT + E", hl.dsp.exec_cmd("qs ipc call bar expand"))
hl.bind(mainMod .. "+ D", hl.dsp.exec_cmd("qs ipc call bar center"))
hl.bind(mainMod .. "+ SHIFT + D", hl.dsp.exec_cmd("qs ipc call notifications toggle"))
hl.bind(mainMod .. "+ PERIOD", hl.dsp.exec_cmd("uwsm app -- rofimoji --action copy"))
hl.bind(mainMod .. "+ SHIFT + P", hl.dsp.exec_cmd("uwsm app -- rofi-rbw"))
hl.bind(mainMod .. "+ SHIFT + C", hl.dsp.exec_cmd("copy-sensitive"))
hl.bind(mainMod .. "+ P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "+ T", hl.dsp.layout("togglesplit"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(mainMod .. "+ CTRL + A", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
-- O -l trava o teto em 100%: sem ele o wpctl passa de 1.0 e distorce.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- Pelo quickshell para ele mostrar o OSD; o brightnessctl é o recuo com o shell fora
-- do ar, com o mesmo piso do brightnessMin do SystemMonitor.
hl.bind(mainMod .. "+ SHIFT + UP",
    hl.dsp.exec_cmd("qs ipc call brightness up 2>/dev/null || brightnessctl set 5%+"),
    { locked = true, repeating = true })
hl.bind(mainMod .. "+ SHIFT + DOWN",
    hl.dsp.exec_cmd(
        "qs ipc call brightness down 2>/dev/null || brightnessctl --min-value=$(($(brightnessctl m) / 20)) set 5%-"),
    { locked = true, repeating = true })
hl.bind(mainMod .. "+ F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. "+ SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

hl.bind(mainMod .. "+ SHIFT + V", hl.dsp.exec_cmd("uwsm app -- rofi-script clipboard"))

hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd("uwsm app -- rofi-script --screenshot region"))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.exec_cmd("uwsm app -- rofi-script --screenshot fullscreen"))

hl.bind(mainMod .. "+ W", hl.dsp.group.toggle())
hl.bind(mainMod .. "+ TAB", hl.dsp.group.next())
hl.bind(mainMod .. "+ SHIFT + TAB", hl.dsp.group.prev())

-- Em função para um argumento recusado derrubar só esta tecla, não a config inteira.
hl.bind(mainMod .. "+ SHIFT + W", function()
    hl.dispatch(hl.dsp.window.move({ out_of_group = true }))
end)

hl.bind(mainMod .. "+ CTRL + H", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. "+ CTRL + L", hl.dsp.window.move({ into_or_create_group = "r" }))
hl.bind(mainMod .. "+ CTRL + K", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. "+ CTRL + J", hl.dsp.window.move({ into_or_create_group = "d" }))

-- Grupo travado não absorve a próxima janela aberta ao lado.
hl.bind(mainMod .. "+ CTRL + W", hl.dsp.group.lock_active())

hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("window-info"))

hl.bind(mainMod .. "+ X", hl.dsp.workspace.toggle_special("minimize"))

-- O estado vem da janela em foco, e não de uma variável, que se perdia com duas
-- janelas ou num reload. Mover para a special leva o foco junto, daí o toggle.
hl.bind(mainMod .. "+ SHIFT + X", function()
    local w = hl.get_active_window()
    if not w then
        return
    end

    if w.workspace and w.workspace.special then
        hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    else
        hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
        hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
    end
end)

local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
    local current = hl.get_config("cursor.zoom_factor")
    if offset ~= nil then
        current = current + offset
    elseif current ~= MIN_ZOOM then
        current = MIN_ZOOM
    else
        current = ZOOM_TOGGLE_FACTOR
    end
    current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
    hl.config({ cursor = { zoom_factor = current } })
end

hl.bind(mainMod .. "+ Z", zoom)
hl.bind(mainMod .. "+ SHIFT + EQUAL", function()
    zoom(0.5)
end)
hl.bind(mainMod .. "+ MINUS", function()
    zoom(-0.5)
end)

hl.bind(mainMod .. "+ H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. "+ L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. "+ K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. "+ J", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. "+ SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. "+ SHIFT + J", hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))

-- Sem o segundo ramo a janela só sai da special arrastada. "+0" é o workspace visível.
hl.bind(mainMod .. " + SHIFT + S", function()
    local w = hl.get_active_window()
    if not w then
        return
    end

    if w.workspace and w.workspace.special then
        hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    else
        hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
    end
end)

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("ALT + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

    hl.bind("SHIFT + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

    -- "reset" é o nome reservado que devolve ao submapa global.
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mainMod .. "+ SHIFT + T", hl.dsp.exec_cmd("uwsm app -- theme pick"))
