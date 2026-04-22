return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "echasnovski/mini.icons",
            version = false,
            config = function()
                require("mini.icons").setup()
            end
        },
        opts = {
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
        },
        ft = { "markdown", "norg", "rmd", "org" },
        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    },
    {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno task --quiet build:fast",
        config = function()
            require("peek").setup({
                app = { "qutebrowser", "--target=window" }
            })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    },
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "zathura"
        end
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        -- ft = "markdown",
        event = {
            "BufReadPre /home/thiagoK/vaults/**/*.md",
            "BufNewFile /home/thiagoK/vaults/**/*.md",
        },
        config = function()
            require("obsidian").setup({
                workspaces = {
                    {
                        name = "anotacoes",
                        path = "~/vaults/anotacoes",
                    },
                },
                ui = {
                    enable = false,
                },
            })
        end
    },
}
