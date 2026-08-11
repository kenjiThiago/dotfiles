-- Substituto do harpoon no perfil servidor: as marcas H, J, K e L guardam um
-- arquivo cada, e a marca é reposicionada na última posição do cursor ao sair
-- do buffer, para o pulo cair onde a leitura parou e não onde ela começou.
--
-- Marca maiúscula é global e vai para o shada, então a lista sobrevive ao
-- restart de graça. O preço é que ela é uma só para a máquina inteira: ao
-- contrário do harpoon, não há lista por diretório.

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

-- A marca volta do shada no restart, mas autocmd nenhum volta com ela. Por
-- isso o rastreio é um BufLeave só, global, que decide na hora se o buffer que
-- está saindo é o de alguma marca: preso ao buffer no momento da associação,
-- ele morria a cada restart e a cada :bdelete, e a marca congelava na posição
-- em que foi criada.
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

    -- O ` cru erra com E20 quando o arquivo saiu do disco; a mensagem curta
    -- basta, e sem o pcall ela vem como erro de Lua.
    if not pcall(vim.cmd, "normal! `" .. marca .. "zz") then
        vim.notify("marca " .. marca .. " aponta para um arquivo que sumiu", vim.log.levels.WARN)
    end
end

-- Equivalente do `harpoon:list():add()`: cai na primeira marca livre, sem
-- repetir um arquivo que já está em outra.
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

-- ── Menu ──────────────────────────────────────────────────────────────────────
-- O menu é um buffer editável, como o do harpoon: o que vale é o texto na hora
-- de fechar. Apagar a linha esvazia o slot, mover a linha troca a marca do
-- arquivo, e o `:linha` no fim é o que preserva a posição no reordenamento.
--
-- A janela fica aqui porque o <C-e> é global e vale dentro do flutuante também:
-- sem isto o segundo toque abriria outra janela em cima da primeira.
local janela
local LETRAS = vim.api.nvim_create_namespace("MarcasLetras")

local function texto_de(item)
    return item and string.format("%s:%d", caminho(item), item.pos[2]) or ""
end

-- Lido da direita para a esquerda: dois-pontos em nome de arquivo é raro, mas o
-- sufixo numérico, quando existe, é sempre o último.
local function analisar(texto)
    texto = vim.trim(texto or "")
    if texto == "" then
        return nil
    end

    local arquivo, numero = texto:match("^(.*):(%d+)$")
    return vim.fn.fnamemodify(arquivo or texto, ":p"), tonumber(numero) or 1
end

-- A linha 1 é sempre o H, a 2 o J, e assim por diante: reordenar é consequência
-- do índice, não precisa de lógica própria.
local function aplicar(linhas)
    if #linhas > #MARCAS then
        vim.notify(string.format("marcas: só as %d primeiras linhas valem", #MARCAS),
            vim.log.levels.WARN)
    end

    vim.cmd("delmarks " .. table.concat(MARCAS))

    for i, marca in ipairs(MARCAS) do
        local arquivo, numero = analisar(linhas[i])
        if arquivo and vim.fn.filereadable(arquivo) == 0 then
            vim.notify("marcas: " .. arquivo .. " não existe", vim.log.levels.WARN)
        elseif arquivo then
            -- Sem eventignore em volta do bufload, por mais tentador que seja
            -- para não acordar o LSP: é o BufReadPost que detecta o filetype, e
            -- o arquivo carregado sem ele fica sem syntax pelo resto da sessão,
            -- já que o pulo depois encontra o buffer pronto e não relê nada.
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

    local conteudo = {}
    local largura = 40
    for i, marca in ipairs(MARCAS) do
        conteudo[i] = texto_de(alvo(marca))
        largura = math.max(largura, vim.fn.strdisplaywidth(conteudo[i]) + 6)
    end
    largura = math.min(largura, vim.o.columns - 4)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, conteudo)

    -- A letra é do slot, não do texto: apagar uma linha sobe o conteúdo, e o
    -- extmark subiria junto se não fosse refeito a cada edição.
    local function letras()
        vim.api.nvim_buf_clear_namespace(buf, LETRAS, 0, -1)
        local total = vim.api.nvim_buf_line_count(buf)

        for i, marca in ipairs(MARCAS) do
            if i <= total then
                vim.api.nvim_buf_set_extmark(buf, LETRAS, i - 1, 0, {
                    virt_text = { { " " .. marca .. " ", "Title" } },
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

    -- Um ponto só para todas as saídas: o q, o <Esc>, o segundo <C-e> e o :q.
    -- As linhas são lidas aqui, que ainda é seguro, e a escrita vai para o
    -- schedule porque durante o fechamento da janela o textlock barraria o
    -- bufload.
    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        once = true,
        callback = function()
            local linhas = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            janela = nil
            vim.schedule(function()
                aplicar(linhas)
            end)
        end,
    })

    local function fechar()
        if janela and vim.api.nvim_win_is_valid(janela) then
            vim.api.nvim_win_close(janela, true)
        end
    end

    -- O pulo também entra na fila, atrás do aplicar: sem isso ele leria a marca
    -- antiga quando a linha tivesse acabado de mudar de lugar.
    vim.keymap.set("n", "<CR>", function()
        local marca = MARCAS[vim.fn.line(".")]
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
