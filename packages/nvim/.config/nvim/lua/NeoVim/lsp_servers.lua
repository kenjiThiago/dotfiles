-- Definições que os dois perfis dividem. O ruff_base existe porque o servidor
-- não tem lspconfig para preencher o básico.
--
-- A sobrescrita vai por vim.lsp.config, e não por um lsp/ruff.lua: entre dois
-- arquivos de mesmo nome no runtimepath vence o encontrado por último, e o do
-- nvim-lspconfig vem depois deste repositório.

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
