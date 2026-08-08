local gh = function(x) return "https://github.com/" .. x end

-- lua/theme.lua é gerado por `theme set`; sem ele, cai num padrão razoável.
local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { name = "none", variant = "dark", colorscheme = "habamax", colors = {} }
end

-- Vem do opacity no theme.sh, via lua/theme.lua.
local transparent = theme.transparent == true

-- Evita erro caso um tema não defina alguma cor.
local c = setmetatable(theme.colors, { __index = function() return "NONE" end })

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/gruber-darker"))

vim.pack.add({ gh("EdenEast/nightfox.nvim") })

require("nightfox").setup({
    options = {
        transparent = transparent,
    },
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
        transparency = transparent,
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

-- O gruber-darker não tem opção de transparência, então os fundos são limpos
-- depois que o colorscheme carrega, para os três se comportarem igual.
if transparent then
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "FoldColumn" }) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    })
end

-- O colorscheme é escolhido pelo tema ativo (nvim_colorscheme em theme.sh).
vim.o.background = theme.variant

if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    vim.notify(
        ("colorscheme '%s' (tema '%s') não está instalado"):format(theme.colorscheme, theme.name),
        vim.log.levels.WARN
    )
    pcall(vim.cmd.colorscheme, "habamax")
end
