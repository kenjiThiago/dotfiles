-- Substituto do harpoon no servidor: as marcas globais H, J, K e L, que persistem
-- pelo shada. Ao sair do buffer a marca vai para a posição do cursor.

local MARCAS = { "H", "J", "K", "L" }

local M = {}

local function alvo(marca)
    for _, item in ipairs(vim.fn.getmarklist()) do
        if item.mark == "'" .. marca then
            return item
        end
    end
end

local function caminho(item)
    return vim.fn.fnamemodify(item.file or "", ":~:.")
end

local function absoluto(item)
    return vim.fn.fnamemodify(item.file or "", ":p")
end

-- Um BufLeave global, e não preso ao buffer: autocmd não volta do shada no restart
-- nem sobrevive a um :bdelete.
local function rastrear()
    local arquivo = vim.api.nvim_buf_get_name(0)
    if arquivo == "" then
        return
    end

    for _, marca in ipairs(MARCAS) do
        local item = alvo(marca)
        if item and absoluto(item) == arquivo then
            vim.cmd("normal! m" .. marca)
        end
    end
end

vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
    group = vim.api.nvim_create_augroup("Marcas", { clear = true }),
    callback = rastrear,
})

function M.marcar(marca)
    local arquivo = vim.api.nvim_buf_get_name(0)

    if arquivo == "" then
        vim.notify("marcas: buffer sem arquivo", vim.log.levels.WARN)
        return
    end

    vim.cmd("normal! m" .. marca)
    vim.notify("marca " .. marca .. ": " .. vim.fn.fnamemodify(arquivo, ":~:."))
end

function M.pular(marca)
    if not alvo(marca) then
        vim.notify("marca " .. marca .. " vazia", vim.log.levels.WARN)
        return
    end

    -- Sem o pcall o E20 de arquivo apagado vem como erro de Lua.
    if not pcall(vim.cmd, "normal! `" .. marca .. "zz") then
        vim.notify("marca " .. marca .. " aponta para um arquivo que sumiu", vim.log.levels.WARN)
    end
end

function M.adicionar()
    local atual = vim.api.nvim_buf_get_name(0)

    for _, marca in ipairs(MARCAS) do
        local item = alvo(marca)
        if item and absoluto(item) == atual then
            vim.notify("já está na marca " .. marca)
            return
        end
    end

    for _, marca in ipairs(MARCAS) do
        if not alvo(marca) then
            M.marcar(marca)
            return
        end
    end

    vim.notify("as quatro marcas estão ocupadas", vim.log.levels.WARN)
end

-- O menu é um buffer editável, como o do harpoon: vale o texto ao fechar.
local janela
local contador = 0
local LETRAS = vim.api.nvim_create_namespace("MarcasLetras")

local function texto_de(item)
    return item and string.format("%s:%d", caminho(item), item.pos[2]) or ""
end

local function analisar(texto)
    texto = vim.trim(texto or "")
    if texto == "" then
        return nil
    end

    local arquivo, numero = texto:match("^(.*):(%d+)$")
    return vim.fn.fnamemodify(arquivo or texto, ":p"), tonumber(numero) or 1
end

-- Linha em branco some e as de baixo sobem: a marca sai da posição na lista.
local function aplicar(linhas)
    local lista = {}
    for _, linha in ipairs(linhas) do
        if vim.trim(linha or "") ~= "" then
            lista[#lista + 1] = linha
        end
    end

    if #lista > #MARCAS then
        vim.notify(string.format("marcas: só as %d primeiras linhas valem", #MARCAS),
            vim.log.levels.WARN)
    end

    vim.cmd("delmarks " .. table.concat(MARCAS))

    for i, marca in ipairs(MARCAS) do
        local arquivo, numero = analisar(lista[i])
        if arquivo and vim.fn.filereadable(arquivo) == 0 then
            vim.notify("marcas: " .. arquivo .. " não existe", vim.log.levels.WARN)
        elseif arquivo then
            -- Sem eventignore: é o BufReadPost que detecta o filetype, e o buffer ficaria
            -- sem syntax pelo resto da sessão.
            local buf = vim.fn.bufadd(arquivo)
            vim.fn.bufload(buf)
            vim.bo[buf].buflisted = true

            local total = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_buf_set_mark(buf, marca, math.min(numero, total), 0, {})
        end
    end
end

function M.menu()
    if janela and vim.api.nvim_win_is_valid(janela) then
        vim.api.nvim_win_close(janela, true)
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    -- acwrite para o :w cair no BufWriteCmd (nofile erra com E382); o nome evita o
    -- E32 e é único porque o menu anterior pode não ter sido varrido ainda.
    vim.bo[buf].buftype = "acwrite"
    contador = contador + 1
    vim.api.nvim_buf_set_name(buf, "__marcas__" .. contador)

    local conteudo = {}
    local largura = 40
    for _, marca in ipairs(MARCAS) do
        local texto = texto_de(alvo(marca))
        if texto ~= "" then
            conteudo[#conteudo + 1] = texto
            largura = math.max(largura, vim.fn.strdisplaywidth(texto) + 6)
        end
    end
    largura = math.min(largura, vim.o.columns - 4)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, conteudo)

    -- A letra vem da posição entre as linhas preenchidas, não do número da linha.
    local function letras()
        vim.api.nvim_buf_clear_namespace(buf, LETRAS, 0, -1)

        local slot = 0
        for i, linha in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if vim.trim(linha) ~= "" then
                slot = slot + 1
                if slot > #MARCAS then
                    break
                end

                vim.api.nvim_buf_set_extmark(buf, LETRAS, i - 1, 0, {
                    virt_text = { { " " .. MARCAS[slot] .. " ", "Title" } },
                    virt_text_pos = "right_align",
                })
            end
        end
    end

    letras()

    janela = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = largura,
        height = #MARCAS,
        row = math.floor((vim.o.lines - #MARCAS) / 2) - 1,
        col = math.floor((vim.o.columns - largura) / 2),
        style = "minimal",
        border = "rounded",
        title = " Marcas ",
    })

    vim.wo[janela].cursorline = true

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = buf,
        callback = letras,
    })

    local function fechar()
        if janela and vim.api.nvim_win_is_valid(janela) then
            vim.api.nvim_win_close(janela, true)
        end
        janela = nil
    end

    -- No fechamento da janela o textlock barraria o bufload, daí o schedule. A guarda
    -- é porque o :w grava, fecha e dispara o BufWinLeave.
    local gravado = false
    local function gravar()
        if gravado then
            return
        end
        gravado = true

        local linhas = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.schedule(function()
            aplicar(linhas)
        end)
    end

    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        once = true,
        callback = function()
            janela = nil
            gravar()
        end,
    })

    -- Dentro do BufWriteCmd o BufWinLeave não roda, então grava antes de fechar.
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            vim.bo[buf].modified = false
            gravar()
            fechar()
        end,
    })

    -- O pulo vai para a fila atrás do aplicar, senão leria a marca antiga.
    vim.keymap.set("n", "<CR>", function()
        local slot = 0
        for _, linha in ipairs(vim.api.nvim_buf_get_lines(buf, 0, vim.fn.line("."), false)) do
            if vim.trim(linha) ~= "" then
                slot = slot + 1
            end
        end

        local marca = MARCAS[slot]
        fechar()
        if marca then
            vim.schedule(function()
                M.pular(marca)
            end)
        end
    end, { buffer = buf })

    for _, tecla in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", tecla, fechar, { buffer = buf })
    end
end

for _, marca in ipairs(MARCAS) do
    local tecla = marca:lower()

    vim.keymap.set("n", "<leader><C-" .. tecla .. ">", function()
        M.marcar(marca)
    end, { desc = "Associar à marca " .. marca })

    vim.keymap.set("n", "<C-" .. tecla .. ">", function()
        M.pular(marca)
    end, { desc = "Ir para a marca " .. marca })
end

vim.keymap.set("n", "<leader>a", M.adicionar, { desc = "Associar à primeira marca livre" })
vim.keymap.set("n", "<C-e>", M.menu, { desc = "Menu das marcas" })

return M
