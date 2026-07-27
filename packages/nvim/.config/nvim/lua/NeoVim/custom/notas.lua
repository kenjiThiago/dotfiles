local ROOT     = vim.fn.expand("~/notas")
local TEMPLATE = ROOT .. "/_templates/template-aula.md"

local ACENTOS  = {
    ["á"] = "a",
    ["à"] = "a",
    ["ã"] = "a",
    ["â"] = "a",
    ["é"] = "e",
    ["ê"] = "e",
    ["í"] = "i",
    ["ó"] = "o",
    ["ô"] = "o",
    ["õ"] = "o",
    ["ú"] = "u",
    ["ç"] = "c",
}

local function slugify(s)
    s = s:lower()
    for k, v in pairs(ACENTOS) do s = s:gsub(k, v) end
    return (s:gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
end

local function nova_aula(disciplina, numero, titulo)
    if vim.fn.filereadable(TEMPLATE) == 0 then
        return vim.notify("template não encontrado: " .. TEMPLATE, vim.log.levels.ERROR)
    end

    local dir = ROOT .. "/" .. disciplina
    vim.fn.mkdir(dir, "p")
    local path = string.format("%s/aula-%02d-%s.md", dir, numero, slugify(titulo))

    if vim.fn.filereadable(path) == 1 then
        return vim.cmd.edit(vim.fn.fnameescape(path))
    end

    local subs = {
        ["^disciplina:$"] = "disciplina: " .. disciplina,
        ["^aula:$"]       = string.format("aula: %02d", numero),
        ["^titulo:$"]     = "titulo: " .. titulo,
        ["^data:$"]       = "data: " .. os.date("%Y-%m-%d"),
        ["{{aula}}"]      = string.format("%02d", numero),
        ["{{titulo}}"]    = titulo,
    }

    local linhas = vim.fn.readfile(TEMPLATE)
    for i, l in ipairs(linhas) do
        for pat, rep in pairs(subs) do
            l = l:gsub(pat, function() return rep end)
        end
        linhas[i] = l
    end

    vim.fn.writefile(linhas, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
end

vim.api.nvim_create_user_command("NovaAula", function(opts)
    local args       = vim.split(opts.args, "%s+", { trimempty = true })
    local disciplina = table.remove(args, 1)
    local numero     = tonumber(table.remove(args, 1))
    if not disciplina or not numero or #args == 0 then
        return vim.notify("uso: :NovaAula <disciplina> <numero> <titulo>", vim.log.levels.ERROR)
    end
    nova_aula(disciplina, numero, table.concat(args, " "))
end, { nargs = "+" })

vim.api.nvim_create_user_command("Marcadores", function(opts)
    local ok = pcall(vim.cmd, "vimgrep /" .. vim.fn.escape(opts.args, "/\\") .. "/j %")
    if not ok or vim.tbl_isempty(vim.fn.getqflist()) then
        return vim.notify("nenhum marcador `" .. opts.args .. "`", vim.log.levels.INFO)
    end
    vim.cmd("copen")
end, {
    nargs = 1,
    complete = function() return { "!!", "??", "vs" } end,
})
vim.cmd([[
  digraphs sq 8849   " ⊑ subsunção
  digraphs sn 8851   " ⊓ conjunção (DL)
  digraphs sj 8852   " ⊔ disjunção (DL)
  digraphs tp 8868   " ⊤ topo
  digraphs bt 8869   " ⊥ fundo
  digraphs md 8872   " ⊨ consequência semântica
]])

vim.api.nvim_create_autocmd("FileType", {
    pattern  = "markdown",
    group    = vim.api.nvim_create_augroup("custom_notas", { clear = true }),
    callback = function(ev)
        if vim.api.nvim_buf_get_name(ev.buf):find(ROOT, 1, true) ~= 1 then return end

        vim.opt_local.wrap      = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell     = true
        vim.opt_local.spelllang = "pt_br"

        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:remove("t")

        if pcall(vim.treesitter.get_parser, ev.buf, "markdown") then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.foldlevel  = 1
        end

        vim.opt_local.suffixesadd:prepend(".md")
        vim.opt_local.path:append(ROOT .. "/**")
    end,
})

vim.keymap.set("n", "<leader>nn", ":NovaAula ", { desc = "nova aula" })
vim.keymap.set("n", "<leader>nm", ":Marcadores ", { desc = "colher marcadores" })
