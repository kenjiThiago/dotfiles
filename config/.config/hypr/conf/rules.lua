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
    -- Ignore maximize requests from all apps. You'll probably like this.
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
    stay_focused = true,
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
    -- Fix some dragging issues with XWayland
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

-- workspace=1, monitor:eDP-1, persistent:true, default:true
-- workspace=2, monitor:HDMI-A-1, persistent:true, default:true
