return {
    -- {
    --     "mistweaverco/kulala.nvim",
    --     keys = {
    --         { "<leader>Rs", desc = "Send request" },
    --         { "<leader>Ra", desc = "Send all requests" },
    --         { "<leader>Rb", desc = "Open scratchpad" },
    --     },
    --     ft = {"http", "rest"},
    --     opts = {
    --         global_keymaps = true,
    --         global_keymaps_prefix = "<leader>R",
    --         kulala_keymaps_prefix = "",
    --     },
    -- },
    {
        "leath-dub/snipe.nvim",
        keys = {
            { "gb", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" }
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
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "" },
                    topdelete = { text = "" },
                    changedelete = { text = "▎" },
                    untracked = { text = "▎" },
                },
                signs_staged = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "" },
                    topdelete = { text = "" },
                    changedelete = { text = "▎" },
                },
                on_attach = function(buffer)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                    end

                    -- stylua: ignore start
                    map("n", "]h", function()
                        if vim.wo.diff then
                            vim.cmd.normal({ "]c", bang = true })
                        else
                            gs.nav_hunk("next")
                        end
                    end, "Next Hunk")
                    map("n", "[h", function()
                        if vim.wo.diff then
                            vim.cmd.normal({ "[c", bang = true })
                        else
                            gs.nav_hunk("prev")
                        end
                    end, "Prev Hunk")
                    map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
                    map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
                    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                    map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                    map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
                    map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                    map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
                    map("n", "<leader>ghd", gs.diffthis, "Diff This")
                    map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
                end,

            })
        end
    },
    {
        "folke/zen-mode.nvim",
        -- enabled = false,
        config = function()
            vim.keymap.set("n", "<leader>zz", function()
                require("zen-mode").setup {
                    plugins = {
                        options = {
                            winborder = "none",
                        },
                    },
                    window = {
                        width = 90,
                        options = {}
                    },
                }
                require("zen-mode").toggle()
                vim.wo.wrap = false
                vim.wo.number = true
                vim.wo.rnu = true
            end)


            vim.keymap.set("n", "<leader>zZ", function()
                require("zen-mode").setup {
                    plugins = {
                        options = {
                            winborder = "none",
                            colorcolumn = "0"
                        },
                    },
                    window = {
                        -- width = 80,
                        options = {
                            number = false,
                            relativenumber = false,
                        }
                    },
                }
                require("zen-mode").toggle()
            end)
        end
    },
    -- {
    --     "ThePrimeagen/vim-be-good",
    --     enabled = false,
    -- },
    -- {
    --     "nvzone/typr",
    --     enabled = false,
    --     dependencies = "nvzone/volt",
    --     opts = {},
    --     cmd = { "Typr", "TyprStats" },
    -- },
    -- {
    --     "m4xshen/hardtime.nvim",
    --     lazy = false,
    --     dependencies = { "MunifTanjim/nui.nvim" },
    --     config = function()
    --         require("hardtime").setup()
    --     end
    -- },
}
