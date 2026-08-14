-- O findfunc é chamado a cada tecla digitada no :find, então a lista de
-- arquivos vem de um cache por cwd: um rg por diretório, não um por tecla.

-- Teto por passada do matchfuzzy. Sem ele a busca varre a lista inteira para
-- ordenar milhares de resultados que a pum nunca mostra.
local LIMITE = 50

local cache = {}
local avisou = false

local function candidatos()
    local cwd = vim.uv.cwd() or "."

    if not cache[cwd] then
        local arquivos = vim.fn.systemlist({
            "rg", "--files", "--hidden", "--glob", "!.git",
        })

        if vim.v.shell_error ~= 0 then
            if not avisou then
                vim.notify("findfunc: rg falhou, lista de arquivos vazia", vim.log.levels.WARN)
                avisou = true
            end
            return {}
        end

        -- O nome sai do caminho aqui e não a cada tecla, porque o matchfuzzy
        -- roda duas vezes sobre esta mesma lista, uma por chave.
        local lista = {}
        for _, caminho in ipairs(arquivos) do
            lista[#lista + 1] = { caminho = caminho, nome = vim.fs.basename(caminho) }
        end

        cache[cwd] = lista
    end

    return cache[cwd]
end

_G.ServerFindFiles = function(cmdarg, _)
    local lista = candidatos()

    -- O ';' separa termos, como o espaço no fzf: 'server;find' exige os dois no
    -- caminho, em qualquer ordem de posição. O matchfuzzy já faz isso com
    -- espaço, mas espaço não serve aqui: na completação o nvim passa para o
    -- findfunc só a última palavra da cmdline, e aceitar um item do wildmenu
    -- substitui só ela, deixando as anteriores para trás.
    local consulta = vim.trim((cmdarg:gsub(";", " ")))

    if consulta == "" then
        return vim.tbl_map(function(item)
            return item.caminho
        end, lista)
    end

    -- Duas passadas: quem casa no nome do arquivo vem antes de quem só casa em
    -- algum diretório do caminho. Com uma passada só, o score do matchfuzzy
    -- sobre o caminho inteiro põe 'set' em wallpapers/1-sunset-lake.png na
    -- frente de set.lua, e é isso que obriga a digitar quase o nome exato.
    local vistos, saida = {}, {}

    for _, chave in ipairs({ "nome", "caminho" }) do
        for _, item in ipairs(vim.fn.matchfuzzy(lista, consulta, { key = chave, limit = LIMITE })) do
            if not vistos[item.caminho] then
                vistos[item.caminho] = true
                saida[#saida + 1] = item.caminho
            end
        end
    end

    return saida
end

-- Do 0.11 em diante. Sem ele o :find e o <leader>pf continuam de pé, caindo no
-- 'path' do nvim em vez da lista do rg.
if vim.fn.exists("+findfunc") == 1 then
    vim.o.findfunc = "v:lua.ServerFindFiles"
end

vim.api.nvim_create_user_command("FindRefresh", function()
    cache = {}
    vim.notify("findfunc: cache de arquivos limpo")
end, { desc = "Reler a lista de arquivos do :find" })

-- Arquivo criado dentro do nvim não está no cache do rg. A marca vem do
-- BufNewFile porque no BufWritePost o arquivo já existe em disco e não há mais
-- como distinguir criação de salvamento.
local grupo = vim.api.nvim_create_augroup("FindCache", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
    group = grupo,
    callback = function(args)
        vim.b[args.buf].find_novo = true
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = grupo,
    callback = function(args)
        if vim.b[args.buf].find_novo then
            vim.b[args.buf].find_novo = nil
            cache[vim.uv.cwd() or "."] = nil
        end
    end,
})

vim.keymap.set("n", "<leader>pf", ":find ", { desc = "Achar arquivo (';' separa termos)" })
