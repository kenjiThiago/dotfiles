local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ gh("tpope/vim-fugitive") })
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
