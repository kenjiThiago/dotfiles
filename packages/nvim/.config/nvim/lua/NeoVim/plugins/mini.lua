local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ { src = gh("nvim-mini/mini.align"), version = "main" }, { src = gh("echasnovski/mini.icons"), version = "main" } })

require("mini.icons").setup()

require("mini.align").setup()
