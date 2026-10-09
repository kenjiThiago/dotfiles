-- Perfil servidor: nvim sem plugins e do gerenciador da distro, então o que é
-- recente fica atrás de teste. Abaixo do 0.11 não há vim.lsp.config.
if vim.fn.has("nvim-0.11") == 1 then
    require("NeoVim.server.lsp")
end

require("NeoVim.server.find")
require("NeoVim.server.dirs")
require("NeoVim.server.marcas")
require("NeoVim.server.align")

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/luar"))

local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { variant = "dark", colorscheme = "luar" }
end

-- O luar e o habamax não têm opção de transparência.
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

vim.g.netrw_sizestyle = "H"
vim.g.netrw_browse_split = 0
-- Sem isto o netrw vira o buffer alternado e o <M-i> volta para ele.
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

-- Embutido a partir do 0.12; antes disso o packadd erra.
if pcall(vim.cmd.packadd, "nvim.undotree") then
    vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>")
end

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

-- No desktop quem completa a cmdline é o blink.cmp. O autocompletar (noselect,
-- pumborder, wildtrigger) é do 0.12; antes dele a lista só abre no <Tab>.
local autocompletar = vim.fn.exists("*wildtrigger") == 1

vim.opt.wildoptions = "pum"
vim.opt.wildmode = autocompletar and "noselect:lastused,full" or "lastused,full"

if autocompletar then
    vim.opt.pumborder = "rounded"
end

-- O `fuzzy` só vale para o :Find (realça o que casou), não para :h, :set etc.
-- `F%a*` e não `Find` por causa da abreviação.
local function fuzzy_do_find()
    vim.o.wildoptions = vim.fn.getcmdline():match("^%s*F%a*%s") and "pum,fuzzy" or "pum"
end

-- O PmenuMatch padrão só acrescenta negrito, que quase não se distingue. O bg vem
-- do PmenuSel, definido pelo colorscheme, para os dois combinarem.
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
    -- O wildtrigger na busca grava o padrão em @/ mesmo quando a busca é cancelada
    -- ou apagada, e o n e o hlsearch usariam o padrão descartado.
    local busca_anterior
    local cmd_busca = vim.api.nvim_create_augroup("BuscaCancelada", { clear = true })

    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = cmd_busca,
        pattern = { "/", "?" },
        callback = function()
            busca_anterior = vim.fn.getreg("/")
        end,
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = cmd_busca,
        pattern = { "/", "?" },
        callback = function()
            if vim.v.event.abort or vim.fn.getcmdline() == "" then
                vim.schedule(function()
                    vim.fn.setreg("/", busca_anterior)
                end)
            end
        end,
    })

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
