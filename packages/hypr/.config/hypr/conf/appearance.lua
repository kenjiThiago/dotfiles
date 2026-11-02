-- conf.colors é gerado por `theme set`; sem ele, cinza neutro.
local loaded, M = pcall(require, "conf.colors")
if not loaded then
    M = setmetatable({}, { __index = function() return "0xff808080" end })
end

local selectionRule = hl.layer_rule({
    name    = "no-anim-for-selection",
    match   = { namespace = "selection" },
    no_anim = true,
})

-- O Quickshell anima o conteúdo; animar a superfície duplicaria o efeito.
hl.layer_rule({
    name = "quickshell-native-animation",
    match = { namespace = "^quickshell$" },
    no_anim = true,
})

hl.layer_rule({
    name = "rofi-subtle-animation",
    match = { namespace = "^rofi$" },
    animation = "popin 98%",
})

hl.config({
    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = false,
    },

    general = {
        gaps_in = 5,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border = { colors = { M.brand, M.brandAlt }, angle = 115 },
            inactive_border = M.muted,
        },

        resize_on_border = false,

        -- Só habilita: rasga apenas quem tem a regra immediate (conf/rules.lua).
        allow_tearing = true,

        layout = "dwindle",
    },

    decoration = {
        rounding = 4,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "0xee1a1a1a",
        },

        blur = {
            enabled = true,
            size = 8,
            passes = 3,

            vibrancy = 0.1696,
        }
    },

    dwindle = {
        preserve_split = true,
    },

    group = {
        col = {
            border_active = { colors = { M.green, M.yellow }, angle = 115 },
            border_inactive = M.muted,

            -- O travado se distingue pela forma (sólido em vez de gradiente), e não pelo
            -- matiz, que colidiria com o foco em algum tema.
            border_locked_active = M.red,
            border_locked_inactive = (M.red:gsub("^0x%x%x", "0x66")),
        },

        groupbar = {
            enabled = false,
        }
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,

        -- Fundo quando não há wallpaper (ver autostart.lua).
        background_color = M.base,
        disable_splash_rendering = true,
    },

    animations = {
        enabled = true,
    },
})

hl.curve("fluent_decel", { type = "bezier", points = { { 0, 0.2 }, { 0.4, 1 } } })
hl.curve("snappyReturn", { type = "bezier", points = { { 0.4, 0.9 }, { 0.6, 1.0 } } })
hl.curve("accel", { type = "bezier", points = { { 0.4, 0 }, { 1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "fluent_decel" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.2, bezier = "snappyReturn", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.3, bezier = "accel", style = "popin 96%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "snappyReturn" })

hl.animation({ leaf = "fade", enabled = true, speed = 1.8, bezier = "fluent_decel" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.2, bezier = "fluent_decel" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.2, bezier = "accel" })
hl.animation({ leaf = "fadeSwitch", enabled = false })

hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.6, bezier = "fluent_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "accel" })
hl.animation({ leaf = "border", enabled = false })

hl.animation({ leaf = "layersIn", enabled = true, speed = 1.6, bezier = "fluent_decel", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "accel", style = "fade" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 2.4, bezier = "fluent_decel", style = "slidefadevert -30%" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "fluent_decel", style = "slidefade 10%" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 1.2, bezier = "fluent_decel" })
