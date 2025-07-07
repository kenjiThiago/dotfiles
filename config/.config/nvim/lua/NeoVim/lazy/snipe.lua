return {
    {
        "leath-dub/snipe.nvim",
        keys = {
            {"gb", function () require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu"}
        },
        opts = {
            ui = {
                position = "center",
                text_align = "file-first",
            },
            navigate = {
                cancel_snipe = "q"
            }
        }
    }
}
