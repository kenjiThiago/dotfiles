local function abrir_lista(loclist)
    local items = loclist and vim.fn.getloclist(0) or vim.fn.getqflist()
    for _, item in ipairs(items) do
        if item.valid == 1 then
            vim.cmd(loclist and "botright lopen" or "botright copen")
            return
        end
    end
    vim.cmd(loclist and "lclose" or "cclose")
    vim.notify("Nenhum resultado válido na lista.", vim.log.levels.INFO)
end

local function fim_da_classe(args, start)
    local i = start + 1
    if args:sub(i, i) == "^" then
        i = i + 1
    end
    if args:sub(i, i) == "]" then
        i = i + 1
    end
    while i <= #args do
        local pair = args:sub(i, i + 1)
        if args:sub(i, i) == "]" then
            return i + 1
        elseif pair == "[:" or pair == "[." or pair == "[=" then
            local ending = args:find(pair:sub(2) .. "]", i + 2, true)
            i = ending and ending + 2 or i + 1
        else
            i = i + (args:sub(i, i) == "\\" and 2 or 1)
        end
    end
    return start + 1
end

local function sem_salto(args)
    if vim.fn.match(args, [[^\i]]) == 0 then
        local pattern, files = args:match("^(%S+)(%s+.*)$")
        if not pattern then
            return args
        end
        local delimiter = pattern:find("/", 1, true) and "\001" or "/"
        return delimiter .. pattern .. delimiter .. "j" .. files
    end

    local delimiter = args:sub(1, 1)
    local i = 2
    while i <= #args do
        local char = args:sub(i, i)
        if char == "\\" then
            i = i + 2
        elseif char == delimiter then
            return args:sub(1, i) .. "j" .. args:sub(i + 1)
        elseif char == "[" then
            i = fim_da_classe(args, i)
        else
            i = i + 1
        end
    end
    return args
end

local commands = {
    grep = "Grep",
    lgrep = "Lgrep",
    make = "Make",
    lmake = "Lmake",
    vimgrep = "Vimgrep",
    lvimgrep = "Lvimgrep",
}

for native, name in pairs(commands) do
    local internal = native:find("vimgrep", 1, true) ~= nil

    vim.api.nvim_create_user_command(name, function(opts)
        local args = internal and sem_salto(opts.args) or opts.args
        local bang = not internal or opts.bang
        local count = internal and opts.count > 0 and tostring(opts.count) or ""
        local ok, err =
            pcall(vim.cmd, opts.mods .. " silent " .. count .. native .. (bang and "!" or "") .. " " .. args)
        if not ok and not err:match("E480:") then
            error(err, 0)
        end
        abrir_lista(native:sub(1, 1) == "l")
    end, {
        nargs = native:find("make", 1, true) and "*" or "+",
        bang = true,
        count = internal and 0 or nil,
        -- complete=file expande % e # antes de o comando nativo interpretar o padrão.
        complete = function(lead)
            return vim.fn.getcompletion(lead, "file")
        end,
    })
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = vim.api.nvim_create_augroup("ListasDeResultados", { clear = true }),
    pattern = ":",
    callback = function()
        if vim.v.event.abort then
            return
        end
        local line = vim.fn.getcmdline()
        local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
        if not ok or not commands[parsed.cmd] then
            return
        end
        for start, word, finish in line:gmatch("()(%a+)()") do
            if parsed.cmd:sub(1, #word) == word then
                local valid, prefix = pcall(vim.api.nvim_parse_cmd, line:sub(1, finish - 1), {})
                if valid and prefix.cmd == parsed.cmd and #prefix.args == 0 then
                    vim.fn.setcmdline(line:sub(1, start - 1) .. commands[parsed.cmd] .. line:sub(finish))
                    return
                end
            end
        end
    end,
})
