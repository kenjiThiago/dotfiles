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
            require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/NeoVim/snippets/" })
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
                    documentation = {
                        auto_show = true,
                    }
                },
                snippets = { preset = 'luasnip' },
                sources = {
                    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                    providers = {
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            score_offset = 100,
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
                    keymap = {
                        ["<C-e>"] = false,
                    },
                    completion = { menu = { auto_show = true } },
                },
                fuzzy = { implementation = "prefer_rust_with_warning" },
            })
        end
    },
}
