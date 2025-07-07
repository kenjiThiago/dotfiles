return {
    {
        'stevearc/conform.nvim',
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "black" },
                },
            })

            vim.keymap.set("", "<leader>f", function()
                require("conform").format({ async = true, lsp_format = "fallback" }, function(err)
                    if not err then
                        local mode = vim.api.nvim_get_mode().mode
                        if vim.startswith(string.lower(mode), "v") then
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
                        end
                    end
                end)
            end, { desc = "Format code" })
        end
    },
}
