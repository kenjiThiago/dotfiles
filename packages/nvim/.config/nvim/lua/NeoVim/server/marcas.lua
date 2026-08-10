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

function M.limpar(marca)
    vim.cmd("delmarks " .. marca)
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

-- A janela do menu, quando aberta. O <C-e> é global e vale dentro do
-- flutuante também, então sem isto o segundo toque abriria outra janela em
-- cima da primeira em vez de fechar.
local janela

function M.menu()
    if janela and vim.api.nvim_win_is_valid(janela) then
        vim.api.nvim_win_close(janela, true)
        janela = nil
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"

    local function desenhar()
        local conteudo = {}
        for i, marca in ipairs(MARCAS) do
            local item = alvo(marca)
            conteudo[i] = item
                and string.format(" %d  %s  %s:%d", i, marca, caminho(item), item.pos[2])
                or string.format(" %d  %s  (vazia)", i, marca)
        end

        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, conteudo)
        vim.bo[buf].modifiable = false

        return conteudo
    end

    local largura = 40
    for _, linha in ipairs(desenhar()) do
        largura = math.max(largura, vim.fn.strdisplaywidth(linha) + 2)
    end
    largura = math.min(largura, vim.o.columns - 4)

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

    local function fechar()
        if janela and vim.api.nvim_win_is_valid(janela) then
            vim.api.nvim_win_close(janela, true)
        end
        janela = nil
    end

    local function ir(indice)
        fechar()
        M.pular(MARCAS[indice])
    end

    vim.keymap.set("n", "<CR>", function()
        ir(vim.fn.line("."))
    end, { buffer = buf })

    vim.keymap.set("n", "d", function()
        M.limpar(MARCAS[vim.fn.line(".")])
        desenhar()
    end, { buffer = buf })

    for i = 1, #MARCAS do
        vim.keymap.set("n", tostring(i), function()
            ir(i)
        end, { buffer = buf })
    end

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
