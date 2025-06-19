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
                -- disable = { "csv" },
                disable = function(lang, buf)
                    if lang == "csv" then
                        return true
                    end

                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },

            indent = {
                enable = true,
                disable = { "css", "java", "go", "js" }
            }
        })
    end
}
