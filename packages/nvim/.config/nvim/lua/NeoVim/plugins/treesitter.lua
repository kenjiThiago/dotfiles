local gh = function(x)
    return "https://github.com/" .. x
end

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
})

vim.pack.add({ gh("nvim-treesitter/nvim-treesitter") })

-- Global para valer também no buffer que o harpoon carrega sem janela. Onde o
-- highlight foi desligado o fold também sai: o foldexpr roda em toda linha.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(event)
        if vim.b[event.buf].sem_fold then
            vim.opt_local.foldmethod = "manual"
        end
    end,
})

local ts = require("nvim-treesitter")
local tsc = require("nvim-treesitter.config")
local disable = function(lang, buf)
    if lang == "csv" then
        return true
    end

    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
end

local disabled_languages = {
    "latex",
    "csv",
    "qmljs",
    "html",
    "javascript",
    "typescript",
    "tsx",
    "tmux",
    "devicetree",
}

vim.api.nvim_create_autocmd("FileType", {
    callback = function(event)
        local lang = vim.treesitter.language.get_lang(event.match)
        local buf = event.buf

        if not lang or vim.tbl_contains(disabled_languages, lang) or disable(lang, buf) then
            vim.b[buf].sem_fold = true
            return
        end

        if vim.tbl_contains(tsc.get_installed(), lang) or not vim.tbl_contains(ts.get_available(), lang) then
            pcall(vim.treesitter.start, buf, lang)
            return
        end

        -- O fold guardou o buffer sem parser: o filetype limpa esse cache e o zx recalcula
        -- as janelas. Só se instalou, senão o FileType tentaria instalar de novo.
        ts.install({ lang }):await(vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(buf) and vim.tbl_contains(tsc.get_installed(), lang) then
                vim.bo[buf].filetype = vim.bo[buf].filetype
                for _, win in ipairs(vim.fn.win_findbuf(buf)) do
                    vim.api.nvim_win_call(win, function()
                        vim.cmd("normal! zx")
                    end)
                end
            end
        end))
    end,
    desc = "Enable nvim-treesitter and install parser if not installed",
})
