local M = require("conf.programs")

local mainMod = "SUPER"

hl.bind(mainMod .. "+ Q", hl.dsp.exec_cmd("uwsm app -- " .. M.terminal))
hl.bind(mainMod .. "+ SHIFT + Q", hl.dsp.exec_cmd("uwsm app -- zen-browser"))
hl.bind(mainMod .. "+ C", hl.dsp.window.close())
hl.bind(mainMod .. "+ M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. "+ V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+ R", hl.dsp.exec_cmd("uwsm app -- rofi-script"))
hl.bind(mainMod .. "+ PERIOD", hl.dsp.exec_cmd("uwsm app -- rofimoji --action copy"))
hl.bind(mainMod .. "+ P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "+ T", hl.dsp.layout("togglesplit"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(mainMod .. "+ SHIFT + UP", hl.dsp.exec_cmd("swayosd-client --brightness raise"),
    { locked = true, repeating = true })
hl.bind(mainMod .. "+ SHIFT + DOWN", hl.dsp.exec_cmd("swayosd-client --brightness lower"),
    { locked = true, repeating = true })
hl.bind(mainMod .. "+ F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. "+ SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- # bind = $mainMod, Y, exec, ghostty --class=com.example.clipse --command=clipse

hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd("uwsm app -- rofi-script --screenshot region"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("uwsm app -- rofi-script --screenshot fullscreen"))

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.group.toggle())
hl.bind(mainMod .. "+ W", hl.dsp.group.next())

hl.bind(mainMod .. "+ O", hl.dsp.window.move({ into_or_create_group = "l" }))

local minimized = false
hl.bind(mainMod .. "+ X", function()
    if minimized then
        hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
        hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
        minimized = false
    else
        hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
        hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
        minimized = true
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
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch to a submap called `resize`.
hl.bind("ALT + R", hl.dsp.submap("resize"))

-- Start a submap called "resize".
hl.define_submap("resize", function()
    -- Set repeating binds for resizing the active window.
    hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

    hl.bind("SHIFT + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

    -- Use `reset` to go back to the global submap
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- bind = ALT, T, submap, themes
--
-- submap = themes
--
-- binde = , Z, exec, $reset ~/dotfiles/scripts/changeZenBrowserTheme
--
-- bind = , escape, submap, reset
--
-- submap = reset
