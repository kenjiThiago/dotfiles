-- O ZR e o :restart guardam a sessão com mksession e a repõem no UIEnter da
-- instância nova, que sobe com o mesmo argv. Três atritos saem daí, e o mapa
-- deste arquivo existe para contorná-los:
--
-- 1. buffer do oil na sessão vira "enew | file oil://...", e um argv de
--    diretório (nvim .) já recriou esse nome antes de a sessão rodar: E95, e o
--    resto do arquivo de sessão não é lido, então o layout não volta;
-- 2. o buffer que o argv abre carrega em async. Quando a sessão troca a janela
--    dele por um arquivo antes de a carga terminar, o oil dispara doautocmd
--    BufReadPre/Post com o nome oil:// na janela que sobrou, e doautocmd vale
--    para o buffer atual: o arquivo herda filetype=oil e perde o treesitter;
-- 3. arquivo que a sessão abre não passa por detecção de filetype, que é
--    pulada dentro da cadeia de autocmd do UIEnter. O buffer fica sem filetype
--    e sem realce até um :e. Escapa só quem já veio carregado do argv.
--
-- A resposta é tirar o oil da sessão e reabri-lo por janela no comando que o
-- :restart roda depois de restaurar, descartar o buffer que veio do argv antes
-- de a sessão rodar (buffer inválido faz o callback do oil desistir) e refazer
-- a detecção de filetype fora da cadeia do UIEnter.

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

-- Só o :restart sem bang repõe sessão; com bang o v:startreason é "restart!" e
-- o argv é tudo que a instância nova tem.
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

    -- Buffer modificado fica de fora: são renomeações pendentes do oil, e o
    -- :restart sem bang é quem deve reclamar delas.
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
