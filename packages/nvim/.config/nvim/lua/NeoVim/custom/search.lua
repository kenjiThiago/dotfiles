local grupo = vim.api.nvim_create_augroup("BuscaIncremental", { clear = true })
local namespace = vim.api.nvim_create_namespace("BuscaIncremental")
local busca

local function realcar(padrao)
    -- O matchadd ignora ignorecase, smartcase e magic.
    local tem_maiuscula = vim.fn.match(padrao:gsub("\\.", ""), [[\u]]) >= 0
    local ignorar = vim.o.ignorecase and not (vim.o.smartcase and tem_maiuscula)
    local caixa = padrao:gsub("\\\\", ""):find("\\[cC]") and "" or (ignorar and [[\c]] or [[\C]])
    local opcoes = (vim.o.magic and [[\m]] or [[\M]]) .. caixa
    return vim.fn.matchadd("Search", opcoes .. padrao)
end

local function limpar()
    if not busca then
        return
    end
    if vim.api.nvim_buf_is_valid(busca.buf) then
        vim.api.nvim_buf_clear_namespace(busca.buf, namespace, 0, -1)
    end
    if busca.match and vim.api.nvim_win_is_valid(busca.win) then
        vim.fn.matchdelete(busca.match, busca.win)
        busca.match = nil
    end
end

vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = grupo,
    pattern = { "/", "\\?" },
    callback = function()
        if vim.fn.getcmdwintype() ~= "" or not vim.o.incsearch then
            return
        end
        busca = {
            win = vim.api.nvim_get_current_win(),
            buf = vim.api.nvim_get_current_buf(),
            tipo = vim.fn.getcmdtype(),
            view = vim.fn.winsaveview(),
            origem = vim.fn.winsaveview(),
            hlsearch = vim.o.hlsearch,
            destaque = vim.v.hlsearch,
        }
        vim.o.incsearch = false
        vim.o.hlsearch = false
    end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = grupo,
    pattern = { "/", "\\?" },
    callback = function()
        local atual = busca
        local padrao = vim.fn.getcmdline()
        if not atual then
            return
        end
        local escapado = false
        for i = 1, #padrao do
            local char = padrao:sub(i, i)
            if char == atual.tipo and not escapado then
                padrao = padrao:sub(1, i - 1)
                break
            end
            escapado = char == "\\" and not escapado
        end
        local linha = vim.fn.getcmdline()
        vim.schedule(function()
            if
                not atual
                or busca ~= atual
                or vim.fn.getcmdtype() ~= atual.tipo
                or vim.fn.getcmdline() ~= linha
                or not vim.api.nvim_win_is_valid(atual.win)
            then
                return
            end
            limpar()
            if padrao == "" then
                atual.padrao = nil
                vim.fn.winrestview(atual.origem)
                atual.view = atual.origem
                return
            end
            vim.api.nvim_win_call(atual.win, function()
                vim.fn.winrestview(atual.origem)
                local ok, pos = pcall(vim.fn.searchpos, padrao, atual.tipo == "?" and "b" or "", 0, 100)
                if ok and pos[1] > 0 then
                    atual.padrao = padrao
                    atual.view = vim.fn.winsaveview()
                    atual.match = realcar(padrao)
                    return
                end
                vim.fn.winrestview(atual.view)
                local trecho = padrao
                if atual.padrao then
                    atual.match = realcar(atual.padrao)
                    if padrao:sub(1, #atual.padrao) == atual.padrao then
                        trecho = padrao:sub(#atual.padrao + 1)
                    end
                end
                vim.api.nvim_buf_set_extmark(atual.buf, namespace, atual.view.lnum - 1, 0, {
                    virt_text = { { "  Sem correspondência: " .. trecho, "ErrorMsg" } },
                    virt_text_pos = "eol",
                })
            end)
            vim.cmd.redraw()
        end)
    end,
})

vim.api.nvim_create_autocmd({ "CmdlineLeave", "CmdwinEnter" }, {
    group = grupo,
    pattern = { "/", "\\?" },
    callback = function()
        limpar()
        if busca then
            if vim.api.nvim_win_is_valid(busca.win) then
                vim.api.nvim_win_call(busca.win, function()
                    vim.fn.winrestview(busca.origem)
                end)
            end
            vim.o.incsearch = true
            vim.o.hlsearch = busca.hlsearch
            if vim.v.event.abort then
                local destaque = busca.destaque
                vim.schedule(function()
                    vim.v.hlsearch = destaque
                end)
            end
        end
        busca = nil
    end,
})
