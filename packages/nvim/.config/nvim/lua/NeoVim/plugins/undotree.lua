local gh = function(x) return "https://github.com/" .. x end

vim.keymap.set("n", "<leader>u", function ()
    vim.pack.add({ gh("mbbill/undotree") })
    vim.cmd("UndotreeToggle")
end)
