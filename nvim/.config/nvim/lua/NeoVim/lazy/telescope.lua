return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
        require('telescope').setup({
            pickers = {
                find_files = {
                    theme = "dropdown",
                    previewer = false,
                }
            },
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" },
                mappings = {
                    n = {
                        ["j"] = "move_selection_previous",
                        ["k"] = "move_selection_next",
                    }
                }
            }
        })
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string( { search = vim.fn.input('Grep > ') })
        end)
        vim.keymap.set("n", "<leader>pg", builtin.git_files, {})
    end
}
