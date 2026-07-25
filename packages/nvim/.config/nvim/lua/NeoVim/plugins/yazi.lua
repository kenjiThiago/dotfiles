local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({ gh("mikavilpas/yazi.nvim") })

require("yazi").setup({
    open_for_directories = true,
    keymaps = {
        cycle_open_buffers = false,
    }
})

vim.keymap.set({ 'n', 'v' }, '<leader>pv', '<cmd>Yazi<cr>', {
    desc = 'Open yazi at the current file'
})

vim.keymap.set('n', '<leader>pw', '<cmd>Yazi cwd<cr>', {
    desc = "Open the file manager in nvim's working directory"
})

-- vim.keymap.set('n', '<c-up>', '<cmd>Yazi toggle<cr>', {
--     desc = 'Resume the last yazi session'
-- })
