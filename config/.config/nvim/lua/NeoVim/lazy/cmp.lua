return {
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            local ls = require("luasnip")
            vim.keymap.set({"i"}, "<C-k>", function() ls.expand() end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-l>", function() ls.jump( 1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-j>", function() ls.jump(-1) end, {silent = true})
        end
    },

    {
        "saghen/blink.cmp",
        build = "cargo build --release",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        config = function()
            require("blink.cmp").setup({
                completion = {
                    menu = { border = "single" },
                    documentation = {
                        auto_show = true,
                        window = { border = "single" }
                    }
                },
                signature = { window = { border = "single" } },
                sources = {
                    default = { "lsp", "path", "snippets", "buffer" },
                    providers = {
                        buffer = {
                            opts = {
                                get_bufnrs = vim.api.nvim_list_bufs,
                            }
                        },
                        lsp = { fallbacks = {} },
                    }
                },
                keymap = {
                    ["<C-e>"] = { "show", "hide" },
                    ["<C-l>"] = { "snippet_forward", "fallback" },
                    ["<C-j>"] = { "snippet_backward", "fallback" },
                },
                cmdline = {
                    keymap = { preset = "inherit" },
                    completion = { menu = { auto_show = true } },
                },
                fuzzy = { implementation = "prefer_rust_with_warning" },
            })
        end
    },
}
