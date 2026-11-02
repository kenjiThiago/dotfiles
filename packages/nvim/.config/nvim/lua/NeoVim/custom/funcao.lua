-- [f volta à assinatura da função que contém o cursor; repetido, sobe para a de fora.

-- Cada parser dá um nome ao nó de função, e as chamadas também levam "function"
-- no nome; por isso a busca é por pedaço do nome, com exclusões.
local function eh_funcao(tipo)
    if tipo:find("call") or tipo:find("invocation") or tipo:find("type") then
        return false
    end
    return tipo:find("function") or tipo:find("method") or tipo == "func_literal" or tipo == "closure_expression"
end

local function funcao_acima(node, linha)
    while node do
        if eh_funcao(node:type()) and node:start() < linha then
            return node
        end
        node = node:parent()
    end
end

-- O nvim do servidor vem da distro: get_node é do 0.9, e antes do 0.11 o
-- get_parser erra em vez de devolver nil quando não há parser.
if not vim.treesitter.get_node then
    return
end

vim.keymap.set("n", "[f", function()
    local ok, parser = pcall(vim.treesitter.get_parser, 0)
    if not ok or not parser then
        return
    end

    -- O realce só analisa o trecho visível; sem isto o get_node pode vir vazio.
    local linha = vim.api.nvim_win_get_cursor(0)[1] - 1
    parser:parse({ linha, linha + 1 })
    local node = vim.treesitter.get_node()
    if not node then
        return
    end

    for _ = 1, vim.v.count1 do
        local funcao = funcao_acima(node, linha)
        if not funcao then
            break
        end
        node = funcao
        linha = funcao:start()
    end

    if linha ~= vim.api.nvim_win_get_cursor(0)[1] - 1 then
        vim.cmd("normal! m'")
        vim.api.nvim_win_set_cursor(0, { linha + 1, 0 })
        vim.cmd("normal! ^")
    end
end, { desc = "Assinatura da função" })
