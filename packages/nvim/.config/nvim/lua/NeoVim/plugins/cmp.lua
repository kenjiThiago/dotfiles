local gh = function(x)
	return "https://github.com/" .. x
end

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "LuaSnip" and (kind == "install" or kind == "update") then
			vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
		end

		if name == "blink.cmp" and (kind == "install" or kind == "update") then
			vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
		end
	end,
})

-- Guarda os servidores desligados para religar os mesmos, inclusive os do mason.
local servidores_desligados

vim.keymap.set("n", "<leader>c", function()
	if servidores_desligados then
		vim.lsp.enable(servidores_desligados)
		servidores_desligados = nil
	else
		servidores_desligados = vim.iter(vim.lsp.get_configs({ enabled = true }))
			:map(function(config)
				return config.name
			end)
			:totable()
		vim.lsp.enable(servidores_desligados, false)
	end
	vim.notify(servidores_desligados and "LSP e blink desligados" or "LSP e blink ligados")
end, { desc = "Alternar o LSP e o blink" })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufNewFile" }, {
	once = true,
	callback = function()
		vim.pack.add({
			gh("rafamadriz/friendly-snippets"),
			gh("L3MON4D3/LuaSnip"),
			{ src = gh("saghen/blink.cmp"), version = "v1" },
		})

		require("luasnip.loaders.from_vscode").lazy_load()

		require("blink.cmp").setup({
			enabled = function()
				return servidores_desligados == nil
			end,
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
						if ctx == nil or item == nil then
							return { "s", "n" }
						end

						local item_text = item.textEdit ~= nil and item.textEdit.newText
							or item.insertText
							or item.label
						local is_multi_line = item_text:find("\n") ~= nil

						-- Aberto para cima, o menu mantém a direção até ser reaberto.
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
					-- O blink consulta o cmdline sem a palavra digitada, e o :Man não completa sem prefixo.
					cmdline = {
						override = {
							get_completions = function(self, context, callback)
								return self:get_completions(context, function(resposta)
									if resposta and #resposta.items == 0 then
										local linha = context.line:sub(1, context.cursor[2])
										for _, c in ipairs(vim.fn.getcompletion(linha, "cmdline")) do
											table.insert(resposta.items, { label = c })
										end
										resposta.is_incomplete_forward = true
									end
									callback(resposta)
								end)
							end,
						},
					},
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
	end,
})
