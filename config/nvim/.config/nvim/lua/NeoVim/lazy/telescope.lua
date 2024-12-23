return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    priority = 999,

    config = function()
        require('telescope').setup({
            pickers = {
                find_files = {
                    theme = "ivy",
                    previewer = false,
                },
                grep_string = {
                    theme = "ivy",
                    file_ignore_patterns = { "go.sum" },
                }
            },
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" },
                -- mappings = {
                --     n = {
                --         ["j"] = "move_selection_previous",
                --         ["k"] = "move_selection_next",
                --     }
                -- }
            },
            extensions = {
                fzf = {}
            }
        })

        require('telescope').load_extension('fzf')

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string( { search = vim.fn.input('Grep > ') })
        end)
        vim.keymap.set("n", "<leader>pg", builtin.git_files, {})

        require("NeoVim.telescope.multigrep").setup()
    end
}
