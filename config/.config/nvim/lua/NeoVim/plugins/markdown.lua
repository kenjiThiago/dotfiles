local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({
    gh("lervag/vimtex"),
})

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "generic"

vim.api.nvim_create_autocmd("FileType", {
    once = true,
    pattern = { "markdown", "norg", "rmd", "org" },
    callback = function()
        vim.pack.add({
            gh("MeanderingProgrammer/render-markdown.nvim"),
        })

        require("render-markdown").setup({
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
        })
    end
})
