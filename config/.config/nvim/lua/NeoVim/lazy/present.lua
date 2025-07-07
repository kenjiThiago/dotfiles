return {
    {
        dir = "~/plugins/present",
        config = function()
            require("present").setup()
            vim.keymap.set("n", "<leader>mp", "<cmd>PresentStart<CR>")
        end
    }
}
