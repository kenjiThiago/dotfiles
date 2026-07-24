local gh = function(x) return "https://github.com/" .. x end

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
            vim.system({ "make" }, { cwd = ev.data.path }):wait()
        end
    end
})

vim.pack.add({
    gh("nvim-lua/plenary.nvim"),
    gh("nvim-telescope/telescope-fzf-native.nvim"),
    { src = gh("nvim-telescope/telescope.nvim"), version = "v0.2.2" },
})

require("telescope").setup({
    pickers = {
        find_files = {
            theme = "dropdown",
            path_display = { "filename_first" },
            hidden = true,
        },
        grep_string = {
            theme = "ivy",
            file_ignore_patterns = { "go.sum" },
        },
        git_files = {
            theme = "dropdown",
            path_display = { "filename_first" },
        },
        help_tags = {
            theme = "ivy",
        }
    },
    defaults = {
        file_ignore_patterns = { "node_modules", "%.git", ".venv" },
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

require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<leader>ps", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>pg", builtin.git_files, {})
vim.keymap.set("n", "<leader>ph", builtin.help_tags, {})

vim.keymap.set("n", "<leader>pe", function()
    builtin.find_files({
        cwd = "~/dotfiles/config/.config/nvim"
    })
end)

vim.keymap.set("n", "<leader>pp", function()
    builtin.find_files({
        cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
    })
end)

vim.keymap.set("n", "<leader>pa", function()
    builtin.find_files({
        cwd = "~/projetos"
    })
end)

require("NeoVim.telescope.multigrep").setup()
