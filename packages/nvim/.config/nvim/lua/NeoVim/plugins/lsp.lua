local gh = function(x) return "https://github.com/" .. x end

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function()
        vim.pack.add({
            gh("mason-org/mason.nvim"),
            gh("mason-org/mason-lspconfig.nvim"),
            gh("folke/lazydev.nvim"),
            gh("neovim/nvim-lspconfig"),
        })

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

        require("lazydev").setup({
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        })

        vim.lsp.config.ruff = {
            init_options = {
                settings = {
                    lint = { enable = false },
                }
            },
        }

        vim.lsp.config.qmlls = {
            cmd = {
                "qmlls",
                "-I", "/usr/lib/qt6/qml",
                "-I", "/usr/lib/quickshell/qml",
                "--build-dir", "."
            }
        }

        vim.diagnostic.config({
            virtual_text = {
                current_line = true,
            },
            -- virtual_text = false,
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
})
