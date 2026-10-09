vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", {}),
    callback = function()
        vim.hl.on_yank({
            higroup = "YankHighlight",
            timeout = 50
        })
    end
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("RestaurarCursor", { clear = true }),
    callback = function(args)
        -- O filetype ainda não foi detectado no BufReadPost.
        local ft = vim.filetype.match({ buf = args.buf })
        if ft == "gitcommit" or ft == "gitrebase" then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] < 1 or mark[1] > vim.api.nvim_buf_line_count(args.buf) then
            return
        end

        if not pcall(vim.api.nvim_win_set_cursor, 0, mark) then
            return
        end

        vim.schedule(function()
            vim.cmd("normal! zz")
        end)
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

local filetypes = vim.api.nvim_create_augroup("FileTypeOpcoes", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = filetypes,
    pattern = { "html", "typescriptreact", "javascript", "json", "jsonc", "typescript", "css" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
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

vim.api.nvim_create_autocmd("FileType", {
    group = filetypes,
    pattern = "csv",
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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    callback = function()
        vim.opt_local.spell     = true
        vim.opt_local.spelllang = "en,pt_br"
    end,
})

local downloads_dir = vim.fn.expand("~/Downloads")
local imagens_dir = vim.fn.expand("~/Imagens")

local function is_in_dir(path, target)
    return path == target or vim.startswith(path, target .. "/")
end

vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("oil_custom_sort", { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "oil" then return end

        local oil = require("oil")
        local current_dir = oil.get_current_dir(ev.buf)

        if not current_dir then return end

        current_dir = current_dir:gsub("[/\\]$", "")

        local sort
        if is_in_dir(current_dir, downloads_dir) or is_in_dir(current_dir, imagens_dir) then
            sort = { { "birthtime", "desc" } }
        else
            sort = { { "type", "asc" }, { "name", "asc" } }
        end

        -- O set_sort é global: relê todos os buffers do oil e recusa, com aviso,
        -- se qualquer um deles estiver modificado.
        if vim.deep_equal(require("oil.config").view_options.sort, sort) then return end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].filetype == "oil" and vim.bo[buf].modified then return end
        end

        oil.set_sort(sort)
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
    group = vim.api.nvim_create_augroup("rbw_secrets", { clear = true }),
    pattern = "*/.tmp*/rbw",
    callback = function(args)
        vim.opt_local.swapfile = false
        vim.opt_local.undofile = false
        vim.opt_local.backup = false
        vim.opt_local.writebackup = false
        vim.o.shada = ""
        -- O "+y não marca a cópia como sensível, e o cliphist guardaria a senha.
        vim.keymap.set({ "n", "v" }, "<leader>y", "y", { buffer = args.buf })
    end,
})
