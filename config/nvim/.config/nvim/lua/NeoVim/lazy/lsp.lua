return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local border = {
            { '╭', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╮', 'FloatBorder' },
            { '│', 'FloatBorder' },
            { '╯', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╰', 'FloatBorder' },
            { '│', 'FloatBorder' },
        }

        require("mason").setup({
            ui = {
                border = "double",
            }
        })

        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", },
            handlers = {
                function(server_name)
                    vim.lsp.enable(server_name)
                end,

                vim.lsp.config("lua_ls", {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                        },
                    },
                })
            },
        })

        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        vim.diagnostic.config({
            virtual_text = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
            },
            float = {
                border = "rounded"
            },
        })
    end
}
