-- O wallpaper pode estar desligado pelo `rofi-script wallpaper`. Sem hyprpaper
-- o fundo é o misc:background_color (conf/appearance.lua), que é o ponto: o
-- hyprpaper 0.8 não tem IPC de unload, então "sem wallpaper" é ele não rodar.
-- O marcador fica em ~/.local/state/dotfiles/, ao lado do current-theme.
local function wallpaper_ligado()
    local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local marker = io.open(state .. "/dotfiles/no-wallpaper", "r")
    if not marker then return true end
    marker:close()
    return false
end

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- quickshell")
    if wallpaper_ligado() then
        hl.exec_cmd("uwsm app -- hyprpaper")
    end
    hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("uwsm app -- hyprsunset")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
