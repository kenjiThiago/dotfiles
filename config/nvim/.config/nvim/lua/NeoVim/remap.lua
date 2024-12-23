-- Old keymaps (o verdadeiro)
-- vim.keymap.set("", "j", "k")
-- vim.keymap.set("", "k", "j")

vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set("i", "jk", "<ESC>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--ClipBorde
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

--Indentação
vim.keymap.set("n", "<TAB>", ">>")
vim.keymap.set("n", "<S-TAB>", "<<")

--Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>")
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>")
vim.keymap.set("n", "<leader>tn", ":tabn<CR>")
vim.keymap.set("n", "<leader>tp", ":tabp<CR>")
vim.keymap.set("n", "<leader>tt", ":tabnew | term<CR>")

--Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

--Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

--Highlight
vim.keymap.set("n", "<leader>nh", vim.cmd.nohlsearch)

--Plus
vim.keymap.set("n", "<leader>gc", ":w<CR> :!gcc % -o %<")
