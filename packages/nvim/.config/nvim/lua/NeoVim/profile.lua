-- "desktop" ou "server", do marcador escrito pelo `install.sh --profile`. Sem ele,
-- desktop.

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
