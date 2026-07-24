local gh = function(x) return "https://github.com/" .. x end

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/gruber-darker"))

vim.pack.add({ gh("EdenEast/nightfox.nvim") })

require("nightfox").setup({
    -- options = {
    --     transparent = true,
    -- },
    groups = {
        all = {
            NormalFloat = { bg = "none", fg = "none" },
            TelescopeSelectionCaret = { fg = "#d84f76", bg = "#d84f76" },
        },
    }
})

vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { link = "Boolean" })

vim.pack.add({ { src = gh("rose-pine/neovim"), name = "rose-pine" } })

require("rose-pine").setup({
    styles = {
        italic = false,
        -- transparency = true,
    },
    highlight_groups = {
        TelescopeSelection = { fg = "text", bg = "highlight_med" },
        TelescopeSelectionCaret = { fg = "love", bg = "love" },

        TelescopeTitle = { fg = "rose" },
        TelescopePromptTitle = { fg = "iris", bold = true },
        TelescopePreviewTitle = { fg = "gold", bold = true },

        StatusLine = { fg = "text", bg = "surface" },
        StatusLineNC = { fg = "muted", bg = "surface" },

        RenderMarkdownCode = { bg = "surface" },
        CursorLineNr = { fg = "gold" },
    },
})

-- vim.cmd.colorscheme("duskfox")
-- vim.cmd.colorscheme("rose-pine-moon")
vim.cmd.colorscheme("gruber-darker")

-- vim.opt.runtimepath:append(vim.fn.expand("~/plugins/change_color"))
--
-- require("change_color").setup({
--     themes = {
--         ["tokyonight"] = "tokyonight.nvim",
--         ["tokyonight-night"] = "tokyonight.nvim",
--         ["tokyonight-storm"] = "tokyonight.nvim",
--         ["catppuccin-mocha"] = "catppuccin",
--         ["kanagawa"] = "kanagawa",
--         ["onedark"] = "onedark.nvim",
--         ["solarized-osaka"] = "solarized-osaka",
--         ["rose-pine"] = "rose-pine",
--         ["rose-pine-moon"] = "rose-pine",
--         ["duskfox"] = "nightfox.nvim",
--     },
--     default_theme = "onedark",
-- })
