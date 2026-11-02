-- Compartilhado pelos dois perfis; o ruff_base supre a falta do lspconfig no servidor.
-- Sobrescrito via vim.lsp.config, e não lsp/ruff.lua, porque o arquivo do
-- nvim-lspconfig viria depois no runtimepath e venceria.

local M = {}

-- Quem aponta erro é o pyright; o ruff só formata e organiza import.
M.ruff = {
    init_options = {
        settings = {
            lint = { enable = false },
        },
    },
}

M.ruff_base = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
}

return M
