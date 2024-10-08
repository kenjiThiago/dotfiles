return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = true,
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                disable_float_background = true,
                styles = {
                    italic = false
                }
            })
            vim.cmd.colorscheme("rose-pine-moon")
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true
            })
            vim.cmd.colorscheme("catppuccin-macchiato")
        end
    }
}
