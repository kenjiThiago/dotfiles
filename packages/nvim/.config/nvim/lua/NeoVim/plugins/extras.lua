local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ gh("folke/zen-mode.nvim") })

vim.keymap.set("n", "<leader>zz", function()
    require("zen-mode").setup {
        plugins = {
            options = {
                winborder = "none",
            },
        },
        window = {
            width = 90,
            options = {}
        },
    }
    require("zen-mode").toggle()
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
end)


vim.keymap.set("n", "<leader>zZ", function()
    require("zen-mode").setup {
        plugins = {
            options = {
                winborder = "none",
                colorcolumn = "0"
            },
        },
        window = {
            -- width = 80,
            options = {
                number = false,
                relativenumber = false,
            }
        },
    }
    require("zen-mode").toggle()
end)
