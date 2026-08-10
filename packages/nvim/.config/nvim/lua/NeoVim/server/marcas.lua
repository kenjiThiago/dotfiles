-- Substituto do harpoon no perfil servidor: as marcas H, J, K e L guardam um
-- arquivo cada, e um autocmd por marca a reposiciona na última posição do
-- cursor ao sair do buffer.
--
-- Marca maiúscula é global e vai para o shada, então a lista sobrevive ao
-- restart de graça. O preço é que ela é uma só para a máquina inteira: ao
-- contrário do harpoon, não há lista por diretório.

local MARCAS = { "H", "J", "K", "L" }

local M = {}

local function grupo(marca)
    return "MarcaAuto" .. marca
end

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

function M.marcar(marca)
    local buffer = vim.api.nvim_get_current_buf()
    local arquivo = vim.api.nvim_buf_get_name(buffer)

    if arquivo == "" then
        vim.notify("marcas: buffer sem arquivo", vim.log.levels.WARN)
        return
    end

    vim.cmd("normal! m" .. marca)

    -- Um augroup por marca, recriado com clear: sem isso o autocmd do buffer
    -- anterior segue vivo e devolve a marca para ele no BufLeave seguinte.
    local id = vim.api.nvim_create_augroup(grupo(marca), { clear = true })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = id,
        buffer = buffer,
        callback = function()
            vim.cmd("normal! m" .. marca)
        end,
    })

    -- O BufLeave não roda quando o nvim fecha com o buffer em foco, e é nesse
    -- momento que o shada grava a marca.
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = id,
        callback = function()
            if vim.api.nvim_get_current_buf() == buffer then
                vim.cmd("normal! m" .. marca)
            end
        end,
    })

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
    vim.api.nvim_create_augroup(grupo(marca), { clear = true })
    vim.cmd("delmarks " .. marca)
end

-- Equivalente do `harpoon:list():add()`: cai na primeira marca livre, sem
-- repetir um arquivo que já está em outra.
function M.adicionar()
    local atual = vim.api.nvim_buf_get_name(0)

    for _, marca in ipairs(MARCAS) do
        local item = alvo(marca)
        if item and vim.fn.fnamemodify(item.file or "", ":p") == atual then
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

function M.menu()
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

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = largura,
        height = #MARCAS,
        row = math.floor((vim.o.lines - #MARCAS) / 2) - 1,
        col = math.floor((vim.o.columns - largura) / 2),
        style = "minimal",
        border = "rounded",
        title = " Marcas ",
    })

    vim.wo[win].cursorline = true

    local function fechar()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
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
