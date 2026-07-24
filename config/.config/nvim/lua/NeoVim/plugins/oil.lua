local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ gh("stevearc/oil.nvim") })

require("oil").setup({
    keymaps = {
        ["<C-h>"] = false,
        ["<C-b>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
        ["<C-l>"] = false,
        ["<C-s>"] = "actions.refresh",
        ["<leader>i"] = {
            desc = "Toggle detail view",
            callback = function()
                local oil = require("oil")
                local config = require("oil.config")

                if #config.columns == 1 then
                    oil.set_columns({
                        { "permissions", highlight = "Keyword" },
                        { "size",        highlight = "Boolean" },
                        { "mtime",       highlight = "Define" },
                        { "icon" },
                    })
                else
                    oil.set_columns({
                        { "icon" },
                    })
                end
            end
        },
        ["gh"] = {
            callback = function()
                require("oil").open("~/")
            end,
            desc = "Ir para o diretório Home (~/)"
        },
        ["gd"] = {
            callback = function()
                require("oil").open("~/Downloads")
            end,
            desc = "Ir para o diretório Downloads (~/Downloads)"
        },
    },
    view_options = {
        show_hidden = true,
    },
    win_options = {
        -- number = false,
        -- relativenumber = false,
    },
    columns = {
        { "permissions", highlight = "Keyword" },
        { "size",        highlight = "Define" },
        { "mtime",       highlight = "Boolean" },
        { "icon" },
    },
    skip_confirm_for_simple_edits = true,
})
