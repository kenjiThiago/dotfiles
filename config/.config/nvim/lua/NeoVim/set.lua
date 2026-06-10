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

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 38
-- vim.opt.signcolumn = "no"
vim.opt.fillchars = { eob = " " }
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.showmode = false

vim.opt.pumheight = 10
vim.opt.winborder = "rounded"
-- vim.opt.cmdheight = 0

vim.opt.colorcolumn = "80"
-- vim.opt.statuscolumn = "%s%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum) : ''} %#LineNr#│ "

vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")
