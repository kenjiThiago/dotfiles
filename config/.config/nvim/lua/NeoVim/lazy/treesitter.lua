return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        local ts = require("nvim-treesitter")
        local tsc = require("nvim-treesitter.config")
        local disable = function(lang, buf)
            if lang == "csv" then
                return true
            end

            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end

        local disabled_languages = {
            "latex",
            "csv",
        }

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(event)
                local lang = vim.treesitter.language.get_lang(event.match)
                local buf = event.buf
                local i = 0

                if vim.tbl_contains(disabled_languages, lang) or disable(lang, buf) then
                    return
                end

                if not lang or vim.tbl_contains(tsc.get_installed(), lang) or not vim.tbl_contains(ts.get_available(), lang) then
                    pcall(vim.treesitter.start)
                    return
                end

                local timer = vim.uv.new_timer()
                if not timer then
                    return
                end
                ts.install { lang }
                timer:start(0, 1000, vim.schedule_wrap(function()
                    i = i + 1
                    if i > 60 or not vim.api.nvim_buf_is_valid(buf) then
                        timer:close()
                        return
                    end
                    if vim.list_contains(ts.get_installed(), vim.treesitter.language.get_lang(lang)) then
                        timer:close()
                        vim.treesitter.start(buf)
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        vim.wo.foldmethod = "expr"
                        vim.wo.foldlevel = 99
                    end
                end))
            end,
            desc = "Enable nvim-treesitter and install parser if not installed"
        })
    end
}
