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
        end
    },

    {
        "saghen/blink.cmp",
        build = "cargo build --release",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        config = function()
            require("blink.cmp").setup({
                signature = {
                    enabled = true,
                },
                completion = {
                    documentation = {
                        auto_show = true,
                    },
                    ghost_text = {
                        enabled = true,
                    },
                    menu = {
                        direction_priority = function()
                            local ctx = require("blink.cmp").get_context()
                            local item = require("blink.cmp").get_selected_item()
                            if ctx == nil or item == nil then return { "s", "n" } end

                            local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or
                            item.label
                            local is_multi_line = item_text:find("\n") ~= nil

                            -- after showing the menu upwards, we want to maintain that direction
                            -- until we re-open the menu, so store the context id in a global variable
                            if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                                vim.g.blink_cmp_upwards_ctx_id = ctx.id
                                return { "n", "s" }
                            end
                            return { "s", "n" }
                        end,
                    },
                },
                snippets = { preset = "luasnip" },
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
                    ["<C-k>"] = {
                        function()
                            local ls = require("luasnip")
                            if ls.expandable() then
                                ls.expand()
                                return true
                            end
                        end,
                    },
                    ["<C-l>"] = { "snippet_forward", "fallback" },
                    ["<C-j>"] = { "snippet_backward", "fallback" },
                },
                cmdline = {
                    completion = { menu = { auto_show = true } },
                },
                fuzzy = { implementation = "prefer_rust_with_warning" },
            })
        end
    },
}
