-- conf.colors é gerado por `theme set`; sem ele, cinza neutro para o
-- Hyprland subir mesmo assim.
local loaded, M = pcall(require, "conf.colors")
if not loaded then
    M = setmetatable({}, { __index = function() return "0xff808080" end })
end

local selectionRule = hl.layer_rule({
    name    = "no-anim-for-selection",
    match   = { namespace = "selection" },
    no_anim = true,
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
            active_border = { colors = { M.accent, M.accentAlt }, angle = 115 },
            inactive_border = M.muted,
        },

        resize_on_border = false,

        -- Habilita o tearing, não o aplica: rasga só quem tiver a regra
        -- immediate, que hoje é o steam_game_window do conf/rules.lua. Com esta
        -- linha em false aquela regra vira letra morta.
        -- https://wiki.hyprland.org/Configuring/Tearing/
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

            -- Sem estas duas o travado cai no oliva e no laranja fixos do
            -- Hyprland. Ele se distingue pela forma, e não pelo matiz: sólido
            -- onde os outros estados são gradiente, porque accent e accent_alt
            -- reciclam cores nomeadas e colidiriam com o foco em algum tema.
            border_locked_active = M.red,
            -- A 40%, como o padrão do Hyprland: legível sem competir com o foco.
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

        -- O que aparece quando não há wallpaper (ver autostart.lua): sem estas
        -- linhas seriam o cinza-azulado fixo do Hyprland, fora da paleta, e o
        -- "Read the wiki." que ele desenha por cima do fundo.
        background_color = M.base,
        disable_splash_rendering = true,
    },

    animations = {
        enabled = true,
    },
})

hl.curve("fluent_decel", { type = "bezier", points = { { 0, 0.2 }, { 0.4, 1 } } })
hl.curve("easeinoutsine", { type = "bezier", points = { { 0.37, 0 }, { 0.63, 1 } } })
hl.curve("snappyReturn", { type = "bezier", points = { { 0.4, 0.9 }, { 0.6, 1.0 } } })
hl.curve("bounce", { type = "bezier", points = { { 0.4, 0.9 }, { 0.6, 1.0 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "snappyReturn", style = "slidevert right" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "snappyReturn", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "bounce", style = "slide" })

hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "fluent_decel" })
hl.animation({ leaf = "fadeSwitch", enabled = false })

hl.animation({ leaf = "fadeLayersIn", enabled = false })
hl.animation({ leaf = "border", enabled = false })

hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeinoutsine", style = "popin" })

-- hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "fluent_decel", style = "slidefade 30%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "fluent_decel", style = "slidefadevert -30%" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "fluent_decel", style = "slidefade 10%" })
