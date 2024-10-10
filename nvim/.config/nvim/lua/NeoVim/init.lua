require("NeoVim.remap")
require("NeoVim.set")
require("NeoVim.lazyInit")

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('HighlightYank', {}),
    callback = function()
        vim.highlight.on_yank({
            timeout = 100
        })
    end
})

vim.api.nvim_create_autocmd('BufLeave', {
    group = vim.api.nvim_create_augroup('OilRelPathFix', {}),
    pattern = "oil:///*",
    callback = function()
        vim.cmd("cd .")
    end
})

vim.g.netrw_banner = 0
