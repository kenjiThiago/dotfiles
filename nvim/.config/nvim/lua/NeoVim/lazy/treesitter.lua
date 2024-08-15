return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    event = { "VeryLazy" },
    config = function()
        require('nvim-treesitter.configs').setup ({
            ensure_installed = { "vimdoc", "javascript", "typescript", "c", "lua", "rust" },

            sync_install = false,

            auto_install = true,

            highlight = {
                enable = true,

                additional_vim_regex_highlighting = false,
            },

            indent = {
                enable = true,
                disable = { "css", "java", "go" }
            }
        })
    end
}
