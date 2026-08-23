-- lua/luar/palette.lua
local M = {}

M.colors = {
    none = "NONE",
    fg = "#e0def4", -- Text (Branco/Lilás padrão)
    ["fg+1"] = "#e0def4",
    ["fg+2"] = "#ffffff",
    black = "#000000",

    -- Fundos (Exatamente os mesmos do Terminal Rosé Pine Moon)
    ["bg-1"] = "#232136", -- Base (Fundo principal do Moon)
    bg = "#232136",       -- Base
    ["bg+1"] = "#2a273f", -- Surface (Para menus, statusline e flutuantes)
    ["bg+2"] = "#393552", -- Overlay (Seleções e divisões)
    ["bg+3"] = "#44415a", -- Highlight Med
    ["bg+4"] = "#56526e", -- Highlight High

    -- Papéis herdados do gruber-darker, com as tintas do Moon
    crimson = "#eb6f92",    -- (Love) Vermelho para as Keywords
    dusty_rose = "#ea9a97", -- (Rose variante Moon) Textos e Strings
    terracotta = "#f6c177", -- (Gold) Dourado para Declaração de Funções
    burgundy = "#817c9c",   -- (Muted variante Moon) Comentários mais pálidos/acinzentados
    plum = "#c4a7e7",       -- (Iris) Roxo para Números e Constantes

    -- Cores de Suporte
    red_error = "#eb6f92",   -- (Love)
    yellow_warn = "#f6c177", -- (Gold)
    green_ok = "#3e8fb0",    -- (Pine variante Moon - um azul/verde mais suave)
}

return M
