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

-- O rose-pine tem paleta própria por variante e ignora o lua/theme.lua, então
-- sem isto o editor desenha num Dawn/Main e o resto da tela noutro. Dá para ver
-- no dawn: o `text` do plugin é #464261 e o daqui não, e a mesma palavra sai em
-- dois tons entre o buffer e a barra do tmux. A tabela é mesclada por cima da
-- paleta do plugin (variants[nome] = tbl_extend), então basta o que muda.
--
-- Os nomes à esquerda são slots do plugin, não semântica: `pine` é só o que o
-- colorscheme pinta de pine. Por isso o mapa segue os papéis da paleta e não os
-- nomes originais, que no dawn foram remexidos de propósito (ver theme.sh).
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
        -- O fg vale para a linha inteira e apagaria o TelescopeMatching assim
        -- que o item fosse selecionado. Precisa ser "none" explícito: o
        -- highlight_groups do rose-pine mescla com o padrão dele, e omitir a
        -- chave deixaria o fg original de pé.
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

-- O luar não tem opção de transparência, então os fundos são limpos
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
