return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = false,
        dependencies = { "echasnovski/mini.icons" },
        opts = {
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
                backgrounds = {},
            },
        },
        ft = { "markdown", "norg", "rmd", "org" },
        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    }
}
