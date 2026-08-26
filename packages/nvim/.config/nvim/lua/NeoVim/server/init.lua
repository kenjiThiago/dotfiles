-- Perfil servidor: nvim sem plugin nenhum, então o que no desktop vem do oil,
-- do telescope, do harpoon, do mini.align e do undotree.nvim aqui sai do que o
-- nvim traz.

-- O nvim daqui vem do gerenciador da distro, que costuma estar bem atrás do
-- Arch, então cada coisa recente vem atrás de um teste. O piso é o 0.11, de
-- onde saem o vim.lsp.config e o `fuzzy` do completeopt; abaixo disso o
-- servidor fica sem LSP em vez de errar a cada arquivo aberto.
if vim.fn.has("nvim-0.11") == 1 then
    require("NeoVim.server.lsp")
end

require("NeoVim.server.find")
require("NeoVim.server.dirs")
require("NeoVim.server.marcas")
require("NeoVim.server.align")

-- ── Cores ─────────────────────────────────────────────────────────────────────
-- O plugins/colors.lua não serve aqui porque depende do vim.pack; o
-- luar vem versionado no pacote nvim-plugins do stow.
vim.opt.runtimepath:append(vim.fn.expand("~/plugins/luar"))

local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { variant = "dark", colorscheme = "luar" }
end

-- Vem do opacity no theme.sh, via lua/theme.lua, e vale para a opacidade do
-- terminal de onde saiu o ssh: aqui não há alacritty nem ghostty para receber
-- o valor, só o fundo a limpar para o do terminal aparecer. Nenhum colorscheme
-- deste perfil tem opção de transparência (o luar é local e o
-- fallback é o habamax), então os fundos são apagados depois que o colorscheme
-- carrega, como no plugins/colors.lua.
if theme.transparent == true then
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "FoldColumn" }) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    })
end

vim.o.background = theme.variant
if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    pcall(vim.cmd.colorscheme, "habamax")
end

-- ── netrw ─────────────────────────────────────────────────────────────────────
vim.g.netrw_sizestyle = "H"
vim.g.netrw_browse_split = 0
-- Sem isto o netrw vira o buffer alternado e o <M-i> do remap.lua volta para
-- ele, e não para o arquivo anterior.
vim.g.netrw_altfile = 1

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Abrir o diretório do arquivo" })
vim.keymap.set("n", "<leader>pr", vim.cmd.Rex, { desc = "Voltar do netrw" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "netrw", "nvim-undotree" },
    callback = function()
        vim.opt_local.cursorline = true
        vim.opt_local.cursorlineopt = "line"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.opt_local.statuscolumn = ""
    end,
})

-- ── Undotree ──────────────────────────────────────────────────────────────────
-- Plugin embutido a partir do 0.12. O packadd de um pacote que não existe é
-- erro, e sem ele o keymap só chamaria um comando inexistente.
if pcall(vim.cmd.packadd, "nvim.undotree") then
    vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>")
end

-- ── Grep e diagnósticos ───────────────────────────────────────────────────────
-- O grepprg com rg vem do set.lua, compartilhado. As teclas repetem as do
-- desktop de propósito.
vim.keymap.set("n", "<leader>ps", function()
    vim.ui.input({ prompt = "Grep > " }, function(padrao)
        if not padrao or padrao == "" then
            return
        end

        vim.cmd("silent grep! " .. vim.fn.fnameescape(padrao))
        vim.cmd("copen")
    end)
end, { desc = "Grep no projeto" })

vim.keymap.set("n", "<leader>ee", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end, { desc = "Diagnósticos na quickfix" })

-- ── Wildmenu ──────────────────────────────────────────────────────────────────
-- Só aqui: no desktop quem completa a cmdline é o blink.cmp, e os dois
-- disputariam as mesmas teclas (ver plugins/cmp.lua).
--
-- O `pum` no wildoptions é antigo e vale em qualquer versão. O resto é o
-- autocompletar da cmdline do 0.12: o `noselect` no wildmode, o pumborder e o
-- wildtrigger() erram cada um por conta própria antes disso. Sem eles a lista
-- continua existindo, só que a partir do <Tab>.
local autocompletar = vim.fn.exists("*wildtrigger") == 1

vim.opt.wildoptions = "pum"
vim.opt.wildmode = autocompletar and "noselect:lastused,full" or "lastused,full"

if autocompletar then
    vim.opt.pumborder = "rounded"
end

-- O `fuzzy` entra e sai a cada tecla porque só vale para o :Find: é ele que faz
-- o nvim filtrar a lista do server/find.lua e, com isso, realçar os trechos que
-- casaram. Ligado o tempo todo mudaria também o :h, o :set e a completação de
-- comando, que aqui interessam prefixadas. O padrão é `F%a*` e não `Find` por
-- causa da abreviação: `:F ` já resolve para o comando.
local function fuzzy_do_find()
    vim.o.wildoptions = vim.fn.getcmdline():match("^%s*F%a*%s") and "pum,fuzzy" or "pum"
end

-- O PmenuMatch é o trecho que casou com o que foi digitado. O padrão herda o
-- Pmenu e só acrescenta negrito, que na lista do :Find quase não se distingue.
-- O bg do item selecionado é lido do PmenuSel em vez de sair da paleta, porque
-- quem define o PmenuSel é o colorscheme, e os dois precisam combinar.
local function realcar_match()
    local cores = theme.colors
    if not cores then
        return
    end

    local sel = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })

    vim.api.nvim_set_hl(0, "PmenuMatch", { fg = cores.warning, bold = true })
    vim.api.nvim_set_hl(0, "PmenuMatchSel", { fg = cores.warning, bg = sel.bg, bold = true })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = realcar_match })
realcar_match()

vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = vim.api.nvim_create_augroup("CmdlineAutocomplete", { clear = true }),
    pattern = { ":", "/", "?" },
    callback = function()
        fuzzy_do_find()

        if autocompletar then
            vim.fn.wildtrigger()
        end
    end,
})

if autocompletar then
    vim.keymap.set("c", "<Up>", function()
        return vim.fn.wildmenumode() == 1 and "<C-E><Up>" or "<Up>"
    end, { expr = true, replace_keycodes = true })

    vim.keymap.set("c", "<Down>", function()
        return vim.fn.wildmenumode() == 1 and "<C-E><Down>" or "<Down>"
    end, { expr = true, replace_keycodes = true })

    vim.keymap.set("c", "<C-y>", function()
        return vim.fn.wildmenumode() == 1 and "<C-y><C-z>" or "<C-y>"
    end, { expr = true, replace_keycodes = true })
end
