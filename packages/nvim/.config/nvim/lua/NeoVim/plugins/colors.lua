local gh = function(x) return "https://github.com/" .. x end

-- lua/theme.lua é gerado por `theme set` (themes/templates/nvim-theme.lua.in).
-- Se ainda não existir (repositório recém-clonado), cai num padrão razoável.
local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { name = "none", variant = "dark", colorscheme = "habamax", colors = {} }
end

-- Evita erro caso um tema não defina alguma cor.
local c = setmetatable(theme.colors, { __index = function() return "NONE" end })

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/gruber-darker"))

vim.pack.add({ gh("EdenEast/nightfox.nvim") })

require("nightfox").setup({
    -- options = {
    --     transparent = true,
    -- },
    groups = {
        all = {
            NormalFloat = { bg = "none", fg = "none" },
            TelescopeSelectionCaret = { fg = c.accent, bg = c.accent },
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

-- O colorscheme é escolhido pelo tema ativo (nvim_colorscheme em theme.sh).
vim.o.background = theme.variant

if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    vim.notify(
        ("colorscheme '%s' (tema '%s') não está instalado"):format(theme.colorscheme, theme.name),
        vim.log.levels.WARN
    )
    pcall(vim.cmd.colorscheme, "habamax")
end
