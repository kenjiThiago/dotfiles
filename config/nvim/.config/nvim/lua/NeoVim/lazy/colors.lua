return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = true,
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
    },
    {
        "craftzdog/solarized-osaka.nvim",
        lazy = true,
        priority = 1000,
        config = function()
            require("solarized-osaka").setup({
                styles = {
                    floats = "transparent"
                },
                on_highlights = function(hl, c)
                    hl.TelescopeTitle = { fg = c.cyan300 }
                    hl.TelescopePromptTitle = { fg = c.magenta300 }
                    hl.TelescopePreviewTitle = { fg = c.orange300 }
                end,
            })
            vim.cmd.colorscheme("solarized-osaka")
        end
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    floats = "transparent",
                },
            })
            vim.cmd.colorscheme("tokyonight-night")
        end
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                transparent = true,
                colors = {
                    theme = {
                        all = {
                            ui = {
                                bg_gutter = "none",
                            }
                        }
                    }
                },
            })
            vim.cmd.colorscheme("kanagawa")
            vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", fg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = "none" })
            vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "none" })
            vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
        end
    }
}
