return {
    {
        'stevearc/oil.nvim',

        config = function()
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

                            if #config.columns == 0 then
                                oil.set_columns({
                                    { "permissions", highlight = "DiagnosticError" },
                                    { "size",        highlight = "Special" },
                                    { "mtime",       highlight = "WarningMsg" },
                                })
                            else
                                oil.set_columns({})
                            end
                        end
                    }
                },
                view_options = {
                    show_hidden = true,
                },
                win_options = {
                    -- number = false,
                    -- relativenumber = false,
                },
                columns = {
                    { "permissions", highlight = "DiagnosticError" },
                    { "size",        highlight = "Special" },
                    { "mtime",       highlight = "WarningMsg" },
                },
                skip_confirm_for_simple_edits = true,
            })
        end
    }
}
