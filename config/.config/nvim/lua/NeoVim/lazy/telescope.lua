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
                    theme = "dropdown",
                    path_display = function(opts, path)
                        local tail = require("telescope.utils").path_tail(path)
                        return string.format("%s   %s", tail, path), { { { 1, #tail }, "Constant" } }
                    end,
                },
                grep_string = {
                    theme = "ivy",
                    file_ignore_patterns = { "go.sum" },
                },
                git_files = {
                    theme = "dropdown",
                    path_display = function(opts, path)
                        local tail = require("telescope.utils").path_tail(path)
                        return string.format("%s   %s", tail, path), { { { 1, #tail }, "Constant" } }
                    end,
                },
                help_tags = {
                    theme = "ivy",
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
        vim.keymap.set("n", "<leader>ph", builtin.help_tags, {})

        vim.keymap.set("n", "<leader>pe", function()
            builtin.find_files({
                cwd = "~/dotfiles/config/nvim/.config/nvim"
            })
        end)

        vim.keymap.set("n", "<leader>pp", function()
            builtin.find_files({
                cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
            })
        end)

        vim.keymap.set("n", "<leader>pa", function()
            builtin.find_files({
                cwd = "~/projetos"
            })
        end)

        require("NeoVim.telescope.multigrep").setup()
    end
}
