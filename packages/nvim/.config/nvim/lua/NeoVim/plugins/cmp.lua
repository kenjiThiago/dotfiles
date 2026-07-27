local gh = function(x) return "https://github.com/" .. x end

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "LuaSnip" and (kind == "install" or kind == "update") then
            vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
        end

        if name == "blink.cmp" and (kind == "install" or kind == "update") then
            vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
        end
    end
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufNewFile" }, {
    once = true,
    callback = function()
        vim.pack.add({
            gh("rafamadriz/friendly-snippets"),
            gh("L3MON4D3/LuaSnip"),
            { src = gh("saghen/blink.cmp"), version = "v1" },
        })

        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/NeoVim/snippets/" })

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
                    lsp = { fallbacks = {}, },
                    buffer = {
                        opts = {
                            get_bufnrs = vim.api.nvim_list_bufs,
                        },
                    },
                },
            },
            keymap = {
                ["<C-e>"] = { "show", "hide" },
                ["<C-k>"] = {
                    function()
                        local ls = require("luasnip")
                        if ls.expandable() then
                            vim.schedule(function()
                                ls.expand()
                            end)
                            return true
                        end
                    end,
                    "fallback",
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
})
