return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },
    config = function()
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
            },
        })

        vim.diagnostic.config({
            -- virtual_text = {
            --     current_line = true,
            -- },
            virtual_text = false,
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
        })
        vim.api.nvim_set_hl(0, "@lsp.type.comment.c", {})
        vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", {})
    end
}
