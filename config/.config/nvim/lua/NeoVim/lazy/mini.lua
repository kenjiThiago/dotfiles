local hl_table = {}

return {
    {
        "nvim-mini/mini.align",
        version = false,
        config = function()
            require("mini.align").setup()
        end
    },

    {
        "nvim-mini/mini.pairs",
        enabled = false,
        version = false,
        config = function()
            require("mini.pairs").setup()
        end
    },
    {
        "echasnovski/mini.hipatterns",
        enabled = false,
        version = false,
        config = function()
            -- reset hl groups when colorscheme changes
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    hl_table = {}
                end,
            })

            require("mini.hipatterns").setup({
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                    shorthand = {
                        pattern = "()#%x%x%x()%f[^%x%w]",
                        group = function(_, _, data)
                            ---@type string
                            local match = data.full_match
                            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                            local hex_color = "#" .. r .. r .. g .. g .. b .. b

                            return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
                        end,
                        extmark_opts = { priority = 2000 },
                    },
                    tailwind = {
                        pattern = function()
                            return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
                        end,
                        group = function(_, _, m)
                            ---@type string
                            local match = m.full_match
                            ---@type string, number
                            local color, shade = match:match("[%w-]+%-([a-z%-]+)%-(%d+)")
                            shade = tonumber(shade)
                            local bg = vim.tbl_get(_G.colors, color, shade)
                            if bg then
                                local hl = "MiniHipatternsTailwind" .. color .. shade
                                if not hl_table[hl] then
                                    hl_table[hl] = true
                                    local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                                    local fg = vim.tbl_get(colors, color, bg_shade)
                                    vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
                                end
                                return hl
                            end
                        end,
                        extmark_opts = { priority = 2000 },
                    }
                }
            })
        end
    },
}
