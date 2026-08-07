-- O findfunc é chamado a cada tecla digitada no :find, então a lista de
-- arquivos vem de um cache por cwd: um rg por diretório, não um por tecla.

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

        cache[cwd] = arquivos
    end

    return cache[cwd]
end

_G.ServerFindFiles = function(cmdarg, _)
    local arquivos = candidatos()

    if cmdarg == "" then
        return arquivos
    end

    return vim.fn.matchfuzzy(arquivos, cmdarg)
end

vim.o.findfunc = "v:lua.ServerFindFiles"

vim.api.nvim_create_user_command("FindRefresh", function()
    cache = {}
    vim.notify("findfunc: cache de arquivos limpo")
end, { desc = "Reler a lista de arquivos do :find" })

vim.keymap.set("n", "<leader>pf", ":find ", { desc = "Achar arquivo" })
