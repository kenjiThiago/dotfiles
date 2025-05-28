vim.opt.guicursor = ""

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "no"
vim.opt.fillchars = { eob = " " }
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.pumheight = 10

--vim.opt.colorcolumn = "80"

vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")
