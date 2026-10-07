-- Completação `custom`, e não `customlist`, para a filtragem ser do nvim: só assim
-- o PmenuMatch realça o que casou. Cache por cwd porque ela roda a cada tecla.

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
                vim.notify("Find: rg falhou, lista de arquivos vazia", vim.log.levels.WARN)
                avisou = true
            end
            return ""
        end

        cache[cwd] = table.concat(arquivos, "\n")
    end

    return cache[cwd]
end

_G.ServerFindCandidatos = candidatos

-- nargs `+` para caminho com espaço chegar inteiro em opts.args.
vim.api.nvim_create_user_command("Find", function(opts)
    vim.cmd.edit(vim.fn.fnameescape(opts.args))
end, {
    nargs = "+",
    complete = "custom,v:lua.ServerFindCandidatos",
    desc = "Abrir arquivo do projeto",
})

vim.api.nvim_create_user_command("FindRefresh", function()
    cache = {}
    vim.notify("Find: cache de arquivos limpo")
end, { desc = "Reler a lista de arquivos do :Find" })

-- Invalida ao entrar na cmdline: no máximo um rg por :Find, e pega também arquivos
-- criados fora do nvim.
vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = vim.api.nvim_create_augroup("FindCache", { clear = true }),
    pattern = ":",
    callback = function()
        cache[vim.uv.cwd() or "."] = nil
    end,
})

vim.keymap.set("n", "<leader>pf", ":Find ", { desc = "Achar arquivo" })
