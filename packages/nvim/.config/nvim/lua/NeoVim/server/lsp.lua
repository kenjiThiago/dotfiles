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

-- O organize-imports precisa vir antes do format, e o format precisa ser
-- síncrono, senão o BufWritePre grava o buffer velho.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("RuffLspFormat", { clear = true }),
    pattern = "*.py",
    callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })
        if #clients == 0 then
            return
        end

        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
        })

        vim.wait(100)
        vim.lsp.buf.format({ async = false, id = clients[1].id })
    end,
})
