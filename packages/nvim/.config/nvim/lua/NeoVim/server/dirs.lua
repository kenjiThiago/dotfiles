-- Contraparte do server/find.lua para diretórios, com a lista em cache.

local LIMITE = 50

local lista = nil
local avisou = false

local EXCLUSOES = {
    ".git", ".cache", "node_modules", ".venv",
    ".zen", ".mozilla", ".rustup", ".cargo", ".wine",
    "go/pkg", ".local/share/Steam", ".local/share/nvim*",
}

-- find como último recurso: no servidor o fd pode faltar ou se chamar `fdfind`.
local function comando_find()
    local home = vim.env.HOME
    local cmd = { "find", home, "(" }

    for i, padrao in ipairs(EXCLUSOES) do
        if i > 1 then
            cmd[#cmd + 1] = "-o"
        end

        if padrao:find("/", 1, true) then
            vim.list_extend(cmd, { "-path", vim.fs.joinpath(home, padrao) })
        else
            vim.list_extend(cmd, { "-name", padrao })
        end
    end

    vim.list_extend(cmd, { ")", "-prune", "-o", "-type", "d", "-print" })
    return cmd
end

local function comando()
    local home = vim.env.HOME

    for _, nome in ipairs({ "fd", "fdfind" }) do
        if vim.fn.executable(nome) == 1 then
            local cmd = { nome, "--type", "d", "--hidden", "--color", "never" }

            for _, padrao in ipairs(EXCLUSOES) do
                vim.list_extend(cmd, { "--exclude", padrao })
            end

            vim.list_extend(cmd, { ".", home })
            return cmd
        end
    end

    return comando_find()
end

local function candidatos()
    if lista then
        return lista
    end

    local saida = vim.fn.systemlist(comando())

    if vim.v.shell_error ~= 0 then
        if not avisou then
            vim.notify("Dir: a varredura falhou, lista de diretórios vazia", vim.log.levels.WARN)
            avisou = true
        end
        return {}
    end

    lista = {}
    for _, caminho in ipairs(saida) do
        local curto = vim.fn.fnamemodify((caminho:gsub("/$", "")), ":~")
        lista[#lista + 1] = { caminho = curto, nome = vim.fs.basename(curto) }
    end

    return lista
end

-- ';' separa termos: a completação recebe só a última palavra da cmdline.
local function completar(arg)
    local itens = candidatos()
    local consulta = vim.trim((arg:gsub(";", " ")))

    if consulta == "" then
        return vim.tbl_map(function(item)
            return item.caminho
        end, itens)
    end

    -- Duas passadas: quem casa no nome vem antes de quem casa no caminho.
    local vistos, saida = {}, {}

    for _, chave in ipairs({ "nome", "caminho" }) do
        for _, item in ipairs(vim.fn.matchfuzzy(itens, consulta, { key = chave, limit = LIMITE })) do
            if not vistos[item.caminho] then
                vistos[item.caminho] = true
                saida[#saida + 1] = item.caminho
            end
        end
    end

    return saida
end

vim.api.nvim_create_user_command("Dir", function(opts)
    local alvo = vim.fn.expand(opts.args)

    if vim.fn.isdirectory(alvo) == 0 then
        vim.notify("Dir: não é um diretório: " .. opts.args, vim.log.levels.ERROR)
        return
    end

    vim.cmd.lcd(vim.fn.fnameescape(alvo))
    vim.cmd.edit(vim.fn.fnameescape(alvo))
end, {
    nargs = 1,
    complete = completar,
    desc = "Ir para um diretório (';' separa termos)",
})

vim.api.nvim_create_user_command("DirRefresh", function()
    lista = nil
    vim.notify("Dir: cache de diretórios limpo")
end, { desc = "Reler a lista de diretórios do :Dir" })

vim.keymap.set("n", "<leader>pd", ":Dir ", { desc = "Ir para um diretório (';' separa termos)" })
