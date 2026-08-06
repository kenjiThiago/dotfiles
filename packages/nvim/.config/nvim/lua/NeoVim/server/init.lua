-- Tudo que só vale no perfil servidor: nvim sem plugin nenhum, então o que no
-- desktop vem do oil, do telescope, do harpoon e do undotree.nvim aqui sai do
-- que o próprio nvim traz.

require("NeoVim.server.lsp")

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
-- O lugar do telescope. O nvim-open-file acha por fzf e manda o :e de volta
-- para este pane, então precisa saber qual é.
vim.keymap.set("n", "<leader>pf", function()
    local window_id = vim.trim(vim.fn.system("tmux display-message -p '#{window_id}'"))

    if vim.v.shell_error ~= 0 or window_id == "" then
        vim.notify("fora do tmux: sem janela para onde mandar o arquivo", vim.log.levels.WARN)
        return
    end

    vim.cmd("silent !nvim-open-file " .. window_id)
end, { desc = "Achar arquivo (fzf)" })

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
