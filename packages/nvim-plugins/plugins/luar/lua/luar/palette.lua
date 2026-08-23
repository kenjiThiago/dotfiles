-- lua/luar/palette.lua
--
-- As cores vêm do lua/theme.lua gerado por `theme set`, o mesmo arquivo que o
-- resto da config consome. As camadas de fundo e o texto saem da paleta
-- semântica; as tintas de sintaxe saem dos papéis `syn_*`, porque a
-- distribuição do luar não é a padrão e cada tema precisa declarar a sua.
--
-- O fallback é o Rosé Pine Moon, para o colorscheme continuar carregando fora
-- do sistema de temas (nvim -u NONE, servidor sem `theme set` rodado).

local M = {}

local fallback = {
    base = "#232136",
    surface = "#2a273f",
    overlay = "#393552",
    highlight_med = "#44415a",
    highlight_high = "#56526e",
    text = "#e0def4",

    comment = "#817c9c",
    type = "#817c9c",
    string = "#ea9a97",
    escape = "#c4a7e7",
    constant = "#c4a7e7",
    keyword = "#eb6f92",
    tag = "#eb6f92",
    func = "#f6c177",
    attribute = "#f6c177",
    operator = "#e0def4",
    variable = "#e0def4",
    parameter = "#e0def4",

    error = "#eb6f92",
    warning = "#f6c177",
    success = "#3e8fb0",
}

local fallback_style = { comment = "", keyword = "bold", parameter = "", attribute = "" }

local loaded, theme = pcall(require, "theme")
if not loaded then theme = {} end

local pal = theme.colors or {}
local syn = theme.syn or {}
local syn_style = theme.syn_style or fallback_style

local function pick(from, key)
    local v = from[key]
    if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then return v end
    return fallback[key]
end

M.colors = {
    none = "NONE",
    black = "#000000",

    base = pick(pal, "base"),
    surface = pick(pal, "surface"),
    overlay = pick(pal, "overlay"),
    highlight_med = pick(pal, "highlight_med"),
    highlight_high = pick(pal, "highlight_high"),
    text = pick(pal, "text"),

    comment = pick(syn, "comment"),
    type = pick(syn, "type"),
    string = pick(syn, "string"),
    escape = pick(syn, "escape"),
    constant = pick(syn, "constant"),
    keyword = pick(syn, "keyword"),
    tag = pick(syn, "tag"),
    func = pick(syn, "func"),
    attribute = pick(syn, "attribute"),
    operator = pick(syn, "operator"),
    variable = pick(syn, "variable"),
    parameter = pick(syn, "parameter"),

    error = pick(pal, "error"),
    warning = pick(pal, "warning"),
    success = pick(pal, "success"),
}

-- `syn_*_style` chega como a string do theme.sh ("bold", "italic", "" para
-- nenhum). Vira a tabela de atributos que o nvim_set_hl espera.
function M.style(role)
    local out = {}
    local spec = syn_style[role] or fallback_style[role] or ""
    for attr in spec:gmatch("[%a_]+") do out[attr] = true end
    return out
end

return M
