vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gitsigns = require("gitsigns")

gitsigns.setup({
    signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    signs_staged_enable = false,
    numhl = false,
    linehl = false,
    word_diff = false,
    current_line_blame = false,
    on_attach = function(buf)
        vim.keymap.set("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next")
            end
        end, { buffer = buf, desc = "Próxima alteração" })

        vim.keymap.set("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end, { buffer = buf, desc = "Alteração anterior" })

        vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, {
            buffer = buf,
            desc = "Visualizar alteração",
        })
    end,
})
