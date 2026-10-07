local gh = function(x) return "https://github.com/" .. x end

-- lua/theme.lua é gerado por `theme set`.
local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { name = "none", variant = "dark", colorscheme = "habamax", colors = {} }
end

local transparent = theme.transparent == true

local c = setmetatable(theme.colors, { __index = function() return "NONE" end })

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/luar"))

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

-- O rose-pine ignora o lua/theme.lua e usa paleta própria; isto a sobrepõe para o
-- editor combinar com o resto da tela. As chaves são slots do plugin, não papéis.
local rose_pine_palette = {}
if theme.colorscheme:match("^rose%-pine") then
    local variant = theme.colorscheme:match("^rose%-pine%-(.+)$") or "main"
    rose_pine_palette[variant] = {
        base = c.base,
        surface = c.surface,
        overlay = c.overlay,
        highlight_low = c.highlight_low,
        highlight_med = c.highlight_med,
        highlight_high = c.highlight_high,
        muted = c.muted,
        subtle = c.subtle,
        text = c.text,
        love = c.accent,
        gold = c.warning,
        rose = c.cyan,
        pine = c.success,
        foam = c.info,
        iris = c.accent_alt,
        leaf = c.green,
    }
end

require("rose-pine").setup({
    palette = rose_pine_palette,
    styles = {
        italic = false,
        transparency = transparent,
    },
    highlight_groups = {
        -- "none" explícito: o rose-pine mescla com o padrão, e o fg original apagaria o
        -- TelescopeMatching no item selecionado.
        TelescopeSelection = { fg = "none", bg = "highlight_med" },
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

-- O luar não tem opção de transparência.
if transparent then
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "FoldColumn" }) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    })
end

vim.o.background = theme.variant

if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    vim.notify(
        ("colorscheme '%s' (tema '%s') não está instalado"):format(theme.colorscheme, theme.name),
        vim.log.levels.WARN
    )
    pcall(vim.cmd.colorscheme, "habamax")
end
