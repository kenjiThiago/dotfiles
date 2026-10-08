vim.opt.guicursor = ""

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 38
vim.opt.fillchars = { eob = " " }
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.showmode = false

vim.opt.pumheight = 10

-- Carrega nos dois perfis: opção desconhecida derrubaria a config. winborder é do 0.11.
if vim.fn.exists("+winborder") == 1 then
    vim.opt.winborder = "rounded"
end

vim.opt.colorcolumn = ""

vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")

vim.filetype.add({
    pattern = {
        [".*/%.config/git/config%.local"] = "gitconfig",
    },
})

vim.opt.list = false

vim.opt.listchars = {
    tab = "» ",
    space = "·",
    trail = "•",
    extends = "›",
    precedes = "‹",
    nbsp = "␣",
    eol = "↲",
}
