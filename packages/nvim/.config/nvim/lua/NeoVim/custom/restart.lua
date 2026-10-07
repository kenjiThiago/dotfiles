-- O :restart repõe a sessão no UIEnter da instância nova, com o mesmo argv. O oil
-- sai da sessão e é reaberto por janela depois (senão dá E95 com `nvim .` e o
-- arquivo herda filetype=oil), e a detecção de filetype é refeita fora do UIEnter.

local M = {}

local function url_do_oil(buf)
    return vim.api.nvim_buf_get_name(buf):match("^oil[%w-]*://")
end

function M.restaurar(janelas)
    for _, janela in ipairs(janelas) do
        local win = vim.fn.win_getid(janela.win, janela.tab)
        if win ~= 0 then
            vim.api.nvim_win_call(win, function()
                require("oil").open(janela.dir)
            end)
        end
    end

    vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "" then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("filetype detect")
                end)
            end
        end
    end)
end

-- Com bang (v:startreason "restart!") não há sessão para repor.
if vim.v.startreason == "restart" then
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if url_do_oil(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end
        end,
        desc = "Descartar o oil do argv antes de a sessão do :restart voltar"
    })
end

vim.keymap.set("n", "ZR", function()
    local count = vim.v.count
    if count > 0 then
        vim.cmd(count == 9 and "restart! +qall!" or "restart! +qall")
        return
    end

    -- Buffer modificado fica de fora: o :restart sem bang é quem reclama dele.
    local janelas = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if url_do_oil(buf) and not vim.bo[buf].modified then
            local dir = require("oil").get_current_dir(buf)
            if dir then
                janelas[#janelas + 1] = ("{tab=%d,win=%d,dir=%q}"):format(
                    vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(win)),
                    vim.api.nvim_win_get_number(win),
                    dir)
            end
            vim.api.nvim_win_call(win, vim.cmd.enew)
        end
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and url_do_oil(buf) and not vim.bo[buf].modified then
            vim.api.nvim_buf_delete(buf, {})
        end
    end

    vim.cmd(("restart lua require('NeoVim.custom.restart').restaurar({%s})")
        :format(table.concat(janelas, ",")))
end, { desc = "Reiniciar o NeoVim" })

return M
