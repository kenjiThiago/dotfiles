vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", {}),
    callback = function()
        vim.highlight.on_yank({
            timeout = 50
        })
    end
})

vim.api.nvim_create_autocmd("BufLeave", {
    group = vim.api.nvim_create_augroup("OilRelPathFix", {}),
    pattern = "oil:///*",
    callback = function()
        vim.cmd("tcd .")
    end
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("Lsp", {}),
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.html", "*.tsx", "*.js", "*.json", "*.ts", "*.css" },
    callback = function()
        vim.cmd("setlocal sw=2")
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.tex",
    callback = function()
        vim.cmd("setlocal spell spelllang=pt_br,en_us")
        vim.cmd("setlocal wrap")
        vim.cmd("setlocal linebreak")
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.csv",
    callback = function()
        vim.b.completion = false
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        local diagnostic_groups = {
            "DiagnosticUnderlineError",
            "DiagnosticUnderlineWarn",
            "DiagnosticUnderlineInfo",
            "DiagnosticUnderlineHint"
        }

        for _, group in ipairs(diagnostic_groups) do
            local current_hl = vim.api.nvim_get_hl(0, { name = group })

            current_hl.undercurl = nil
            current_hl.underline = true

            vim.api.nvim_set_hl(0, group, current_hl)
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "undotree",
    callback = function()
        vim.opt_local.cursorline = true
        vim.opt_local.cursorlineopt = "line"
    end,
})
