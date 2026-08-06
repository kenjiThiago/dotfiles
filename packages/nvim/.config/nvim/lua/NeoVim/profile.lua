-- Perfil da máquina: "desktop" (Arch + Hyprland, com plugins) ou "server"
-- (nvim pelado). O marcador é escrito pelo `install.sh --profile <nome>` e
-- fica em ~/.local/state/dotfiles/, ao lado do current-theme do `theme`.
--
-- Na falta do arquivo o padrão é desktop, de propósito: uma máquina que nunca
-- rodou o install novo continua se comportando como sempre.

local M = {}

local function state_dir()
    local xdg = vim.env.XDG_STATE_HOME
    if xdg and xdg ~= "" then return xdg end
    return vim.env.HOME .. "/.local/state"
end

local function detect()
    local env = vim.env.DOTFILES_PROFILE
    if env and env ~= "" then return env end

    local file = io.open(state_dir() .. "/dotfiles/profile", "r")
    if not file then return "desktop" end

    local line = file:read("l")
    file:close()

    line = line and vim.trim(line) or ""
    return line ~= "" and line or "desktop"
end

M.name = detect()
M.server = M.name == "server"
M.desktop = not M.server

return M
