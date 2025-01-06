return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = false,
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                styles = {
                    italic = false,
                    transparency = true,
                },
                highlight_groups = {
                    TelescopeSelection = { fg = "text", bg = "highlight_med" },
                    TelescopeSelectionCaret = { fg = "love", bg = "love" },

                    TelescopeTitle = { fg = "rose" },
                    TelescopePromptTitle = { fg = "iris", bold = true },
                    TelescopePreviewTitle = { fg = "gold", bold = true },

                    StatusLine = { fg = "text", bg = "surface" },
                    StatusLineNC = { fg = "muted", bg = "surface" },
                },
            })
            vim.cmd.colorscheme("rose-pine-moon")
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true
            })
            vim.cmd.colorscheme("catppuccin-macchiato")
        end
    }
}
