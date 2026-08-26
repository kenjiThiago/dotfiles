-- A completação do :Find é `custom` e não `customlist` de propósito: quem
-- desenha o realce do trecho que casou (PmenuMatch) é o nvim, e ele só marca
-- posição espalhada pelo item quando a filtragem é dele. Lista já filtrada por
-- nós chega na pum sem realce nenhum. O preço é que a ordem também passa a ser
-- a dele. Quem liga o fuzzy dessa filtragem é o wildoptions, alternado no
-- server/init.lua só enquanto a cmdline é do :Find.
--
-- A função é chamada a cada tecla digitada, então a lista de arquivos vem de um
-- cache por cwd: um rg por invocação, não um por tecla.

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

        -- A completação `custom` devolve os candidatos numa string só, um por
        -- linha, então o join já entra no cache.
        cache[cwd] = table.concat(arquivos, "\n")
    end

    return cache[cwd]
end

_G.ServerFindCandidatos = candidatos

-- O nargs `+` é o que entrega o caminho com espaço inteiro em opts.args; com
-- `1` ele seria dois argumentos e o comando erraria.
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

-- Arquivo criado depois da varredura não está no cache. Invalidar ao entrar na
-- cmdline é o intervalo certo: o rg roda no máximo uma vez por :Find, e nunca
-- durante a digitação, onde o cache é justamente o que segura o custo. O gatilho
-- é a cmdline e não a escrita do buffer porque assim vale também para o que
-- aparece por fora do nvim, como um git pull ou um arquivo criado no shell.
vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = vim.api.nvim_create_augroup("FindCache", { clear = true }),
    pattern = ":",
    callback = function()
        cache[vim.uv.cwd() or "."] = nil
    end,
})

vim.keymap.set("n", "<leader>pf", ":Find ", { desc = "Achar arquivo" })
