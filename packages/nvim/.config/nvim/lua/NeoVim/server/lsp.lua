-- LSP sem mason e sem nvim-lspconfig: no servidor os binários vêm do venv do
-- projeto ou do pipx, e o resto é o vim.lsp.config nativo.

vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

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

-- lint desligado: quem aponta erro é o pyright, o ruff aqui só formata e
-- organiza import.
vim.lsp.config.ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    init_options = {
        settings = {
            lint = { enable = false },
        },
    },
}
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
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("i", "<C-e>", "<C-x><C-o>", {
            buffer = e.buf,
            noremap = true,
            silent = true,
            desc = "Acionar autocompletar nativo (Omni)",
        })
    end,
})

-- O lugar do conform.nvim. O organize-imports precisa vir antes do format, e
-- o format precisa ser síncrono, senão o BufWritePre grava o buffer velho.
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
