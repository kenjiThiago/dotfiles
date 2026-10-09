-- Sem mason e sem nvim-lspconfig: os binários vêm do venv do projeto ou do
-- pipx, e o resto é o vim.lsp.config nativo.

local servers = require("NeoVim.lsp_servers")

vim.opt.completeopt:append({ "menuone", "noselect", "popup", "fuzzy" })

vim.lsp.config.pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
}
vim.lsp.enable("pyright")

vim.lsp.config.ruff = vim.tbl_deep_extend("force", servers.ruff_base, servers.ruff)
vim.lsp.enable("ruff")

vim.diagnostic.config({
    virtual_text = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspServer", { clear = true }),
    callback = function(e)
        local opts = { buffer = e.buf }

        -- O autotrigger respeita o vim.b.completion = false do autocmd.lua.
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, e.buf, { autotrigger = true })
        end

        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("i", "<C-e>", "<C-x><C-o>", {
            buffer = e.buf,
            noremap = true,
            silent = true,
            desc = "Acionar autocompletar nativo (Omni)",
        })
    end,
})

-- Tudo síncrono e no buffer gravado, que no :wa não é o da janela atual. O ruff
-- pode mandar a ação sem a edição, que aí vem pelo codeAction/resolve.
local function organizar_imports(client, buf)
    local params = {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        range = {
            start = { line = 0, character = 0 },
            ["end"] = { line = vim.api.nvim_buf_line_count(buf), character = 0 },
        },
        context = { only = { "source.organizeImports" }, diagnostics = {} },
    }

    local resposta = client:request_sync("textDocument/codeAction", params, 1000, buf)
    for _, acao in ipairs(resposta and resposta.result or {}) do
        if not acao.edit and client:supports_method("codeAction/resolve") then
            local resolvida = client:request_sync("codeAction/resolve", acao, 1000, buf)
            acao = resolvida and resolvida.result or acao
        end

        if acao.edit then
            vim.lsp.util.apply_workspace_edit(acao.edit, client.offset_encoding)
        end
    end
end

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("RuffLspFormat", { clear = true }),
    pattern = "*.py",
    callback = function(args)
        local client = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })[1]
        if not client then
            return
        end

        organizar_imports(client, args.buf)
        vim.lsp.buf.format({ async = false, id = client.id, bufnr = args.buf })
    end,
})
