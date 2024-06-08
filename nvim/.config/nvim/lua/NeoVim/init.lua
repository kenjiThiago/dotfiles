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
