-- Alinhamento por delimitador, no lugar do mini.align do desktop. As teclas
-- repetem as de lá: `ga` sobre um movimento ou sobre uma seleção, o que custa o
-- `ga` nativo (código do caractere sob o cursor).
--
--   ga=  ip           alinha o parágrafo pelo primeiro "="
--   :'<,'>Align :     alinha a seleção pelo primeiro ":"
--   :'<,'>Align! ,    alinha por todas as vírgulas, coluna a coluna

local M = {}

-- Delimitadores que colam no campo da esquerda: o padding vai depois deles, e
-- não antes.
local COLADOS = { [","] = true, [";"] = true, [":"] = true }

-- Alinhando por "=", o corte pega o operador inteiro. Sem isso o "=" de `~=` e
-- `==` cai numa coluna e o de `=` noutra.
local COMPOSTO = "[~!<>%+%-%*/%%%.:|&%^]"

local function achar(linha, delim, inicio)
    local i, f = linha:find(delim, inicio, true)
    if not i then
        return nil
    end

    if delim == "=" then
        if i > 1 and linha:sub(i - 1, i - 1):match(COMPOSTO) then
            i = i - 1
        end
        while linha:sub(f + 1, f + 1) == "=" do
            f = f + 1
        end
    end

    return i, f
end

local function cortar(linha, delim, limite)
    local campos, seps = {}, {}
    local i = 1

    while #seps < limite do
        local ini, fim = achar(linha, delim, i)
        if not ini then
            break
        end

        campos[#campos + 1] = linha:sub(i, ini - 1)
        seps[#seps + 1] = linha:sub(ini, fim)
        i = fim + 1
    end

    if #seps == 0 then
        return nil
    end

    campos[#campos + 1] = linha:sub(i)
    return campos, seps
end

-- O pedaço que precisa caber na coluna: o campo mais o delimitador, quando ele
-- é dos que colam à esquerda.
local function pedaco(campo, sep)
    return COLADOS[sep] and campo .. sep or campo
end

function M.alinhar(inicio, fim, delim, todas)
    local limite = todas and math.huge or 1
    local linhas = vim.api.nvim_buf_get_lines(0, inicio - 1, fim, false)

    local partidas, larguras = {}, {}

    for indice, linha in ipairs(linhas) do
        local campos, seps = cortar(linha, delim, limite)

        -- Linha sem o delimitador fica intacta, inclusive fora da conta das
        -- larguras.
        if campos then
            local recuo = linha:match("^%s*")
            for i = 1, #campos do
                campos[i] = vim.trim(campos[i])
            end
            campos[1] = recuo .. campos[1]

            partidas[indice] = { campos = campos, seps = seps }

            for i = 1, #seps do
                local largura = vim.fn.strdisplaywidth(pedaco(campos[i], seps[i]))
                larguras[i] = math.max(larguras[i] or 0, largura)
            end
        end
    end

    local mudou = false

    for indice, linha in ipairs(linhas) do
        local partida = partidas[indice]
        if partida then
            local saida = {}

            for i = 1, #partida.seps do
                local sep = partida.seps[i]
                local texto = pedaco(partida.campos[i], sep)
                local padding = string.rep(" ", larguras[i] - vim.fn.strdisplaywidth(texto))

                saida[#saida + 1] = COLADOS[sep] and (texto .. padding .. " ")
                    or (texto .. padding .. " " .. sep .. " ")
            end

            saida[#saida + 1] = partida.campos[#partida.campos]

            local nova = (table.concat(saida):gsub("%s+$", ""))
            if nova ~= linha then
                linhas[indice] = nova
                mudou = true
            end
        end
    end

    if mudou then
        vim.api.nvim_buf_set_lines(0, inicio - 1, fim, false, linhas)
    end
end

local todas_pendente = false

_G.AlinharOperador = function()
    local inicio = vim.api.nvim_buf_get_mark(0, "[")[1]
    local fim = vim.api.nvim_buf_get_mark(0, "]")[1]
    local todas = todas_pendente

    vim.ui.input({ prompt = "Alinhar por > " }, function(delim)
        if delim and delim ~= "" then
            M.alinhar(inicio, fim, delim, todas)
        end
    end)
end

local function operador(todas)
    return function()
        todas_pendente = todas
        vim.o.operatorfunc = "v:lua.AlinharOperador"
        return "g@"
    end
end

vim.api.nvim_create_user_command("Align", function(opts)
    M.alinhar(opts.line1, opts.line2, opts.args ~= "" and opts.args or "=", opts.bang)
end, {
    range = true,
    nargs = "?",
    bang = true,
    desc = "Alinhar por um delimitador (com ! em todas as ocorrências)",
})

vim.keymap.set("n", "ga", operador(false), { expr = true, desc = "Alinhar pelo primeiro delimitador" })
vim.keymap.set("n", "gA", operador(true), { expr = true, desc = "Alinhar por todos os delimitadores" })

vim.keymap.set("x", "ga", ":Align ", { desc = "Alinhar a seleção" })
vim.keymap.set("x", "gA", ":Align! ", { desc = "Alinhar a seleção em todas as ocorrências" })

return M
