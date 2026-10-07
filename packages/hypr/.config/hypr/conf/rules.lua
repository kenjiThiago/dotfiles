hl.window_rule({
    name = "pavucontrol_window",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },

    float = true,
    size = { 1000, 650 },
    center = true
})

hl.window_rule({
    name = "nm-connection-editor_window",
    match = { class = "^(nm-connection-editor)$" },

    float = true,
    size = { 900, 500 },
    center = true,
})

hl.window_rule({
    name = "biblioteca_window",
    match = { title = "^Biblioteca$" },

    float = true,
    size = { 1000, 650 },
    center = true,
})

hl.window_rule({
    name = "figure_window",
    match = { title = "^Figure [0-9]" },

    float = true,
    size = { 1000, 800 },
    center = true,
})

local suppressMaximizeRule = hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name = "clipse_window",
    match = { class = "(com.example.clipse)" },

    float = true,
    size = { 800, 500 },
    stay_focused = true,
    center = true,
})

hl.window_rule({
    name = "wiremix_window",
    match = { class = "(com.example.wiremix)" },

    float = true,
    size = { 800, 500 },
    stay_focused = true,
    center = true,
})

hl.window_rule({
    name = "btop_window",
    match = { class = "(com.example.btop)" },

    float = true,
    size = { 1200, 750 },
    center = true,
})

hl.window_rule({
    name = "gimp_window",
    match = { class = "(gimp)" },

    float = true,
    size = { 1280, 720 },
    center = true,
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "satty_window",
    match = { class = "^(com\\.gabm\\.satty)$" },

    float = true,
    size = { 1200, 800 },
    center = true,
    stay_focused = true,
})

-- Jogos do Steam (XWayland). O immediate depende do allow_tearing do appearance.lua,
-- que só está ligado por causa dele; para desistir do tearing, tire essa linha.
hl.window_rule({
    name  = "steam_game_window",
    match = { class = "^steam_app_[0-9]+$" },

    no_blur   = true,
    no_anim   = true,
    immediate = true,

    -- O gamepad não conta como atividade para o Wayland: sem isto o hypridle tranca a
    -- sessão no meio da partida. focus, e não always, para não impedir o sleep.
    idle_inhibit = "focus",
})
