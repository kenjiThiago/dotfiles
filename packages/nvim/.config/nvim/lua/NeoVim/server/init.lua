-- Tudo que só vale no perfil servidor: nvim sem plugin nenhum, então o que no
-- desktop vem do oil, do telescope, do harpoon e do undotree.nvim aqui sai do
-- que o próprio nvim traz.

require("NeoVim.server.lsp")
require("NeoVim.server.find")

-- ── Cores ─────────────────────────────────────────────────────────────────────
-- O plugins/colors.lua é quem faz isto no desktop, e ele depende do vim.pack.
-- O gruber-darker não: vem versionado no pacote nvim-plugins do stow.
vim.opt.runtimepath:append(vim.fn.expand("~/plugins/gruber-darker"))

local loaded, theme = pcall(require, "theme")
if not loaded then
    theme = { variant = "dark", colorscheme = "gruber-darker" }
end

vim.o.background = theme.variant
if not pcall(vim.cmd.colorscheme, theme.colorscheme) then
    pcall(vim.cmd.colorscheme, "habamax")
end

-- ── netrw ─────────────────────────────────────────────────────────────────────
-- No desktop o init.lua desliga o netrw, porque quem navega é o oil.
vim.g.netrw_sizestyle = "H"
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
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
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>")

-- ── Achar arquivo ─────────────────────────────────────────────────────────────
-- O <leader>pf está no server/find.lua, com o findfunc nativo.

-- ── Grep e diagnósticos ───────────────────────────────────────────────────────
-- O lugar do telescope e do trouble. O grepprg com rg já vem do set.lua, que é
-- compartilhado; as teclas são as mesmas do desktop de propósito.
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
-- brigariam pelas mesmas teclas (ver plugins/cmp.lua).
vim.opt.wildmode = "noselect:lastused,full"
vim.opt.wildoptions = "pum"
vim.opt.pumborder = "rounded"

vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = vim.api.nvim_create_augroup("CmdlineAutocomplete", { clear = true }),
    pattern = { ":", "/", "?" },
    command = "call wildtrigger()",
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

-- ── Marcas ────────────────────────────────────────────────────────────────────
-- O harpoon do pobre: associa o buffer a uma marca que se atualiza sozinha ao
-- sair dele, e <c-h/j/k/l> pula de volta.
local function bind_mark_auto(mark_char)
    local buffer = vim.api.nvim_get_current_buf()

    vim.cmd("normal! m" .. mark_char)
    vim.notify("arquivo associado à marca " .. mark_char)

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buffer,
        callback = function()
            vim.cmd("normal! m" .. mark_char)
        end,
    })
end

for _, mark in ipairs({ "H", "J", "K", "L" }) do
    local key = mark:lower()
    vim.keymap.set("n", "<leader><c-" .. key .. ">", function()
        bind_mark_auto(mark)
    end, { desc = "Associar à marca " .. mark })
    vim.keymap.set("n", "<c-" .. key .. ">", "`" .. mark)
end
