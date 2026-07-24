local gh = function(x) return "https://github.com/" .. x end

vim.opt.runtimepath:append(vim.fn.expand("~/plugins/present"))

require("present").setup()
vim.keymap.set("n", "<leader>mp", "<cmd>PresentStart<CR>")
