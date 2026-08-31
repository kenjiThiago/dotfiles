local ROOT      = vim.fn.expand("~/notas")
local TEMPLATES = ROOT .. "/_templates"

local TIPOS     = {
    conceito = "conceitos",
    projeto  = "projetos",
}

local ACENTOS   = {
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

local function hoje() return os.date("%Y-%m-%d") end

local function render(tipo, path, vars)
    local tpl = TEMPLATES .. "/" .. tipo .. ".md"
    if vim.fn.filereadable(tpl) == 0 then
        vim.notify("template não encontrado: " .. tpl, vim.log.levels.ERROR)
        return false
    end

    local linhas = vim.fn.readfile(tpl)
    for i, l in ipairs(linhas) do
        l = l:gsub("{{(%w+)}}", function(k) return vars[k] or "" end)
        for k, v in pairs(vars) do
            l = l:gsub("^" .. k .. ":$", function() return k .. ": " .. v end)
        end
        linhas[i] = l
    end

    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.fn.writefile(linhas, path)
    return true
end

local function abrir(path) vim.cmd.edit(vim.fn.fnameescape(path)) end

-- ── Aula ─────────────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("NovaAula", function(opts)
    local args       = vim.split(opts.args, "%s+", { trimempty = true })
    local disciplina = table.remove(args, 1)
    local numero     = tonumber(table.remove(args, 1))
    if not disciplina or not numero or #args == 0 then
        return vim.notify("uso: :NovaAula <disciplina> <numero> <titulo>", vim.log.levels.ERROR)
    end

    local titulo = table.concat(args, " ")
    local path = string.format("%s/%s/aula-%02d-%s.md", ROOT, disciplina, numero, slugify(titulo))

    if vim.fn.filereadable(path) == 1 then return abrir(path) end
    if render("aula", path, {
            disciplina = disciplina,
            aula       = string.format("%02d", numero),
            titulo     = titulo,
            data       = hoje(),
        }) then
        abrir(path)
    end
end, { nargs = "+" })

-- ── Conceito e projeto ───────────────────────────────────────────────────────

vim.api.nvim_create_user_command("Nota", function(opts)
    local args = vim.split(opts.args, "%s+", { trimempty = true })
    local tipo = table.remove(args, 1)
    local dir  = TIPOS[tipo]
    if not dir or #args == 0 then
        return vim.notify("uso: :Nota <conceito|projeto> <titulo>", vim.log.levels.ERROR)
    end

    local titulo = table.concat(args, " ")
    local slug   = slugify(titulo)
    local path   = string.format("%s/%s/%s.md", ROOT, dir, slug)

    if vim.fn.filereadable(path) == 1 then return abrir(path) end
    if render(tipo, path, { titulo = titulo, slug = slug, data = hoje() }) then
        abrir(path)
    end
end, {
    nargs = "+",
    complete = function(lead, line)
        if #vim.split(line, "%s+", { trimempty = true }) > 2 then return {} end
        return vim.tbl_filter(function(t) return t:find(lead, 1, true) == 1 end,
            vim.tbl_keys(TIPOS))
    end,
})

-- ── Diário e captura ─────────────────────────────────────────────────────────

local function diario()
    local path = string.format("%s/diario/%s.md", ROOT, hoje())
    if vim.fn.filereadable(path) == 0 then
        if not render("diario", path, { data = hoje() }) then return nil end
    end
    abrir(path)
    return path
end

vim.api.nvim_create_user_command("Diario", function()
    if diario() then vim.cmd("normal! G") end
end, {})

vim.api.nvim_create_user_command("Captura", function(opts)
    if not diario() then return end

    local head = "## " .. os.date("%H:%M")
    if opts.args ~= "" then head = head .. " — " .. opts.args end

    vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", head, "" })
    vim.cmd("normal! G")
    vim.cmd("startinsert")
end, { nargs = "*" })

-- ── Promoção: seleção do diário vira nota de conceito ou projeto ─────────────

vim.api.nvim_create_user_command("Promover", function(opts)
    local args = vim.split(opts.args, "%s+", { trimempty = true })
    local tipo = table.remove(args, 1)
    local dir  = TIPOS[tipo]
    if not dir or #args == 0 then
        return vim.notify("uso: :'<,'>Promover <conceito|projeto> <titulo>", vim.log.levels.ERROR)
    end

    local bruto  = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    local origem = vim.fn.expand("%:t:r")
    local titulo = table.concat(args, " ")
    local slug   = slugify(titulo)
    local path   = string.format("%s/%s/%s.md", ROOT, dir, slug)

    if vim.fn.filereadable(path) == 1 then
        return vim.notify("já existe: " .. path, vim.log.levels.ERROR)
    end
    if not render(tipo, path, { titulo = titulo, slug = slug, data = hoje() }) then return end

    local linhas = vim.fn.readfile(path)
    vim.list_extend(linhas, { "", "## Bruto", "", "Origem: [[" .. origem .. "]]", "" })
    vim.list_extend(linhas, bruto)
    vim.fn.writefile(linhas, path)

    abrir(path)
end, { nargs = "+", range = true })

-- ── Marcadores ───────────────────────────────────────────────────────────────

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

-- ── Dígrafos ─────────────────────────────────────────────────────────────────

vim.cmd([[
  digraphs sq 8849
  digraphs sn 8851
  digraphs sj 8852
  digraphs tp 8868
  digraphs bt 8869
  digraphs md 8872
]])

-- ── Buffer ───────────────────────────────────────────────────────────────────

vim.api.nvim_create_autocmd("FileType", {
    pattern  = "markdown",
    group    = vim.api.nvim_create_augroup("custom_notas", { clear = true }),
    callback = function(ev)
        if vim.api.nvim_buf_get_name(ev.buf):find(ROOT, 1, true) ~= 1 then return end

        vim.opt_local.wrap      = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell     = true
        vim.opt_local.spelllang = "en,pt_br"

        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:remove({ "t", "c" })

        if pcall(vim.treesitter.get_parser, ev.buf, "markdown") then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.foldlevel  = 1
        end

        vim.opt_local.suffixesadd:prepend(".md")
        vim.opt_local.path:append(ROOT .. "/**")
    end,
})

-- ── Atalhos ──────────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>nd", "<cmd>Diario<cr>", { desc = "diário de hoje" })
vim.keymap.set("n", "<leader>nc", ":Captura ", { desc = "captura rápida" })
vim.keymap.set("n", "<leader>nn", ":Nota ", { desc = "nova nota" })
vim.keymap.set("n", "<leader>na", ":NovaAula ", { desc = "nova aula" })
vim.keymap.set("n", "<leader>nm", ":Marcadores ", { desc = "colher marcadores" })
vim.keymap.set("v", "<leader>np", ":Promover ", { desc = "promover seleção" })
