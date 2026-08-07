-- Definições de LSP que os dois perfis dividem, para que não divirjam sem
-- ninguém notar. O desktop só precisa do que sobrescreve o nvim-lspconfig; o
-- servidor não tem lspconfig, então junta a sobrescrita com o básico.
--
-- Sobrescrever por vim.lsp.config, e não por um arquivo em lsp/, é de
-- propósito: entre dois lsp/<nome>.lua no runtimepath quem vence é o
-- encontrado por último, e o do nvim-lspconfig vem depois deste repositório.

local M = {}

-- lint desligado: quem aponta erro é o pyright, o ruff aqui só formata e
-- organiza import.
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
