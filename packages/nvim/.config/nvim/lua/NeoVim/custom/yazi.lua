local float = require("NeoVim.custom.float")

local M = {}

local open_cmd = {
    edit = "edit",
    vsplit = "vsplit",
    split = "split",
    tab = "tabedit",
}

local function read_file(path)
    if vim.fn.filereadable(path) == 0 then
        return {}
    end
    return vim.fn.readfile(path)
end

-- Com `--chooser-file` o `open` do yazi para de consultar os openers dele e
-- devolve tudo para cá, então imagem e PDF caíam como binário num buffer. A
-- lista é de tipos que só têm sentido fora do nvim: qualquer outro segue para o
-- buffer, que é o caso recuperável.
local function opens_externally(path)
    if vim.fn.executable("xdg-open") == 0 then
        return false
    end

    local mime = vim.trim(vim.fn.system({ "file", "-Lb", "--mime-type", "--", path }))
    if mime == "image/svg+xml" then
        return false
    end

    return mime:match("^image/") ~= nil
        or mime:match("^video/") ~= nil
        or mime:match("^audio/") ~= nil
        or mime == "application/pdf"
        or mime == "application/epub+zip"
end

-- Buffers sem arquivo real no disco (oil, terminal, fugitive) têm nomes como
-- `oil:///caminho/`, que o yazi não sabe abrir.
local function resolve_target(path)
    if path and path ~= "" then
        return path
    end

    if vim.bo.filetype == "oil" then
        local ok, oil = pcall(require, "oil")
        if ok then
            local dir = oil.get_current_dir()
            if dir then
                return dir
            end
        end
    end

    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" and vim.uv.fs_stat(name) then
        return name
    end

    return vim.uv.cwd()
end

function M.open(path)
    local target = resolve_target(path)
    local start_dir = vim.fn.isdirectory(target) == 1 and target or vim.fs.dirname(target)
    local chooser = vim.fn.tempname()
    local mode_file = vim.fn.tempname()

    local buf, win = float.open()

    vim.fn.jobstart({ "yazi", target, "--chooser-file", chooser }, {
        term = true,
        env = {
            YAZI_START_DIR = start_dir,
            YAZI_MODE_FILE = mode_file,
        },
        on_exit = function()
            float.close(buf, win)

            local files = read_file(chooser)
            local mode = vim.trim(table.concat(read_file(mode_file), ""))
            local cmd = open_cmd[mode] or open_cmd.edit

            vim.fn.delete(chooser)
            vim.fn.delete(mode_file)

            for _, file in ipairs(files) do
                if file ~= "" then
                    if opens_externally(file) then
                        vim.fn.jobstart({ "xdg-open", file }, { detach = true })
                    else
                        vim.cmd(cmd .. " " .. vim.fn.fnameescape(file))
                    end
                end
            end
        end,
    })

    vim.cmd.startinsert()
end

return M
