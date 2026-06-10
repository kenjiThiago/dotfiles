local M = require("conf.rose-pine")

local selectionRule = hl.layer_rule({
    name    = "no-anim-for-selection",
    match   = { namespace = "selection" },
    no_anim = true,
})

hl.config({
    cursor = {
        sync_gsettings_theme = true,
    },

    general = {
        gaps_in = 5,
        gaps_out = 12,

        border_size = 2,

        -- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        col = {
            active_border = { colors = { M.love, M.iris }, angle = 115 },
            inactive_border = M.muted,
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 8,

        -- Change transparency of focused and unfocused windows
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
            border_active = { colors = { M.pine, M.gold }, angle = 115 },
            border_inactive = M.muted
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
    },

    animations = {
        enabled = true,
    },
})

hl.curve("fluent_decel", { type = "bezier", points = { { 0, 0.2 }, { 0.4, 1 } } })
hl.curve("easeinoutsine", { type = "bezier", points = { { 0.37, 0 }, { 0.63, 1 } } })
hl.curve("snappyReturn", { type = "bezier", points = { { 0.4, 0.9 }, { 0.6, 1.0 } } })
hl.curve("bounce", { type = "bezier", points = { { 0.4, 0.9 }, { 0.6, 1.0 } } })

-- Windows
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "snappyReturn", style = "slidevert right" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "snappyReturn", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "bounce", style = "slide" })

-- Fading
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "fluent_decel" })

-- Elementos Desabilitados (0 -> enabled = false)
hl.animation({ leaf = "fadeLayersIn", enabled = false })
hl.animation({ leaf = "border", enabled = false })

-- Layers
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeinoutsine", style = "popin" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "fluent_decel", style = "slidefade 30%" })
-- hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3,   bezier = "fluent_decel",  style = "slidefadevert 30%" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "fluent_decel", style = "slidefade 10%" })
