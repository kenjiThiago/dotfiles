local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ gh("stevearc/oil.nvim") })

local colunas_completas = {
    { "permissions", highlight = "LineNr" },
    { "size",        highlight = "LineNr" },
    { "mtime",       highlight = "LineNr" },
    { "icon" },
}

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
                    oil.set_columns(colunas_completas)
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
    columns = colunas_completas,
    skip_confirm_for_simple_edits = true,
})
