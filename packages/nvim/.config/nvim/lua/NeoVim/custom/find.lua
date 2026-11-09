local function diretorio_atual()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir() or vim.fn.getcwd(0)
    end
    if vim.bo.filetype == "directory" then
        return vim.api.nvim_buf_get_name(0)
    end
    if vim.bo.filetype == "netrw" then
        return vim.b.netrw_curdir or vim.fn.getcwd(0)
    end

    local nome = vim.api.nvim_buf_get_name(0)
    return nome ~= "" and vim.fn.fnamemodify(nome, ":h") or vim.fn.getcwd(0)
end

local function editar_no_diretorio()
    local dir = diretorio_atual()
    if dir:sub(-1) ~= "/" then
        dir = dir .. "/"
    end
    vim.api.nvim_feedkeys(":edit " .. vim.fn.fnameescape(dir), "n", false)
end

vim.keymap.set("n", "<leader>pw", editar_no_diretorio, { desc = "Editar arquivo no diretório atual" })

if require("NeoVim.profile").minimal then
    vim.keymap.set("n", "<leader>fe", editar_no_diretorio, { desc = "Editar arquivo no diretório atual" })
end
