local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("lervag/vimtex"),
})

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "generic"

vim.api.nvim_create_autocmd("FileType", {
	once = true,
	pattern = { "markdown", "norg", "rmd", "org" },
	callback = function()
		-- O plugin se anexa ao buffer atual assim que carrega, com o que estiver
		-- aqui; um setup() depois do pack.add só valeria do segundo buffer em diante.
		vim.g.render_markdown_config = {
			enabled = false,
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				sign = false,
				icons = {},
			},
			html = { comment = { conceal = false } },
		}

		vim.pack.add({
			gh("MeanderingProgrammer/render-markdown.nvim"),
		})
	end,
})
