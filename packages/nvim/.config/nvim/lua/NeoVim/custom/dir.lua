local grupo = vim.api.nvim_create_augroup("NavegadorDir", { clear = true })
local ns = vim.api.nvim_create_namespace("NeoVim.dir")
local ns_colunas = vim.api.nvim_create_namespace("NeoVim.dir.colunas")
local EXECUCAO = tonumber("111", 8)
local POR_DATA = { vim.fn.expand("~/Downloads"), vim.fn.expand("~/Imagens") }
local TIPOS = { directory = "d", file = "-", link = "l", socket = "s", fifo = "p", char = "c", block = "b" }
local detalhes = true
local ultimo_dir

local function caminho(dir, nome)
    return vim.fs.joinpath(dir, (nome:gsub("/$", ""):gsub("%z", "\n")))
end

local function entrada()
    local nome = vim.api.nvim_get_current_line()
    if nome ~= "" then
        return caminho(vim.api.nvim_buf_get_name(0), nome)
    end
end

local function destacar_permissoes(texto)
    local trechos = {}
    for i = 1, #texto do
        local c = texto:sub(i, i)
        trechos[#trechos + 1] = { c, c == "-" and "LineNr" or "Comment" }
    end
    return trechos
end

local function permissoes(mode)
    local texto = {}
    for i = 8, 0, -1 do
        local letra = ("rwx"):sub(3 - i % 3, 3 - i % 3)
        texto[#texto + 1] = bit.band(mode, bit.lshift(1, i)) ~= 0 and letra or "-"
    end
    return table.concat(texto)
end

local function tamanho(bytes)
    local unidades = { "", "K", "M", "G", "T" }
    local i = 1
    while bytes >= 1024 and i < #unidades do
        bytes = bytes / 1024
        i = i + 1
    end
    if i == 1 then
        return tostring(bytes)
    end
    return bytes < 10 and string.format("%.1f%s", bytes, unidades[i]) or math.floor(bytes) .. unidades[i]
end

local function por_data(dir)
    return vim.iter(POR_DATA):any(function(alvo)
        return dir == alvo or vim.startswith(dir, alvo .. "/")
    end)
end

local function data_entrada(stat, ordenar_por_data)
    local criacao = stat.birthtime and stat.birthtime.sec or 0
    return ordenar_por_data and criacao > 0 and criacao or stat.mtime.sec
end

local function decorar(buf, stats)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(buf, ns_colunas, 0, -1)
    local dir = vim.api.nvim_buf_get_name(buf)
    local ordenar_por_data = por_data(dir)
    for row, nome in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, true)) do
        local path = nome ~= "" and caminho(dir, nome)
        local stat = path and (stats and stats[nome] or vim.uv.fs_lstat(path))
        if stat then
            if stat.type == "link" then
                vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
                    virt_text = { { "-> " .. (vim.uv.fs_readlink(path) or "?"), "Comment" } },
                    virt_text_pos = "eol",
                })
            elseif stat.type == "file" and bit.band(stat.mode, EXECUCAO) ~= 0 then
                vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, { end_col = #nome, hl_group = "DiagnosticOk" })
            end
            if detalhes then
                local virt = destacar_permissoes(TIPOS[stat.type] or "?")
                virt[#virt + 1] = { " " }
                vim.list_extend(virt, destacar_permissoes(permissoes(stat.mode)))
                local data = os.date("%b %d %H:%M", data_entrada(stat, ordenar_por_data))
                virt[#virt + 1] = { string.format(" %5s %s ", tamanho(stat.size), data), "LineNr" }
                vim.api.nvim_buf_set_extmark(
                    buf,
                    ns_colunas,
                    row - 1,
                    0,
                    { virt_text = virt, virt_text_pos = "inline" }
                )
            end
        end
    end
end

local function recarregar(buf)
    vim.api.nvim_buf_call(buf, function()
        vim.cmd.edit()
    end)
end

local function destino(input, dir)
    if input == "~" or input:sub(1, 2) == "~/" then
        input = vim.env.HOME .. input:sub(2)
    end
    local path = vim.fs.normalize(input, { plain = true })
    return path:sub(1, 1) == "/" and path or vim.fs.normalize(vim.fs.joinpath(dir, path), { plain = true })
end

local function renomear(mover)
    local origem = entrada()
    if not origem then
        return
    end
    local buf = vim.api.nvim_get_current_buf()
    local dir = vim.api.nvim_buf_get_name(buf)
    local nome = vim.fs.basename(origem)
    vim.ui.input({
        prompt = mover and ("Mover " .. nome .. " para a pasta: ") or "Novo nome: ",
        default = mover and (dir:sub(-1) == "/" and dir or dir .. "/") or nome,
        completion = mover and "dir" or nil,
    }, function(input)
        if not input or input == "" then
            return
        end
        local alvo
        if mover then
            local pasta = destino(input, dir)
            if vim.fn.isdirectory(pasta) == 0 then
                vim.notify("A pasta de destino não existe: " .. pasta, vim.log.levels.ERROR)
                return
            end
            alvo = vim.fs.joinpath(pasta, nome)
        else
            if input == "." or input == ".." or input:find("/", 1, true) then
                vim.notify("Informe apenas o nome; use M para mover", vim.log.levels.WARN)
                return
            end
            alvo = vim.fs.joinpath(dir, input)
        end
        if alvo == origem then
            return
        end
        if vim.uv.fs_lstat(alvo) then
            vim.notify("O destino já existe: " .. alvo, vim.log.levels.ERROR)
            return
        end

        local buffers, nomes = {}, {}
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            nomes[vim.api.nvim_buf_get_name(b)] = b
        end
        for nome, b in pairs(nomes) do
            if nome == origem or vim.startswith(nome, origem .. "/") then
                local novo = alvo .. nome:sub(#origem + 1)
                if nomes[novo] then
                    vim.notify("O destino já tem um buffer aberto: " .. novo, vim.log.levels.ERROR)
                    return
                end
                buffers[b] = novo
            end
        end
        local ok, err = vim.uv.fs_rename(origem, alvo)
        if not ok then
            vim.notify("Erro ao renomear: " .. err, vim.log.levels.ERROR)
            return
        end
        for b, nome in pairs(buffers) do
            vim.api.nvim_buf_set_name(b, nome)
        end
        recarregar(buf)
    end)
end

-- Com uma pasta o imv ordena por nome; com arquivos explícitos, mantém a ordem da listagem.
local function abrir_no_imv()
    local atual = entrada()
    if not atual or vim.fn.isdirectory(atual) == 1 then
        return
    end
    if vim.fn.executable("imv") == 0 then
        vim.notify("imv não está disponível", vim.log.levels.WARN)
        return
    end
    local dir, arquivos = vim.api.nvim_buf_get_name(0), {}
    for _, nome in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
        local arquivo = caminho(dir, nome)
        local stat = vim.uv.fs_stat(arquivo)
        if stat and stat.type == "file" then
            arquivos[#arquivos + 1] = arquivo
        end
    end
    vim.system({ "imv", "-n", atual, unpack(arquivos) }, { detach = true })
end

function _G.DirWinbar()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid or vim.api.nvim_get_current_win())
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~"):gsub("%%", "%%%%")
    if path:sub(-1) ~= "/" then
        path = path .. "/"
    end
    local pai, atual = path:match("^(.-)([^/]+/)$")
    return "%#DirWinbar# %#DirWinbarPai#" .. (pai or "") .. "%#DirWinbarAtual#" .. (atual or path) .. "%#DirWinbar#%="
end

local function realces()
    vim.api.nvim_set_hl(0, "DirWinbar", { link = "Normal", default = true })
    vim.api.nvim_set_hl(0, "DirWinbarPai", { link = "LineNr", default = true })
    vim.api.nvim_set_hl(0, "DirWinbarAtual", { link = "Directory", default = true })
end
realces()
vim.api.nvim_create_autocmd("ColorScheme", { group = grupo, callback = realces })
vim.keymap.set("n", "<leader>pv", "<Plug>(nvim-dir-up)", { desc = "Abrir o diretório do arquivo" })
vim.keymap.set("n", "<leader>pr", function()
    if ultimo_dir and vim.api.nvim_buf_is_valid(ultimo_dir) and vim.bo[ultimo_dir].filetype == "directory" then
        vim.cmd.buffer(ultimo_dir)
    else
        vim.cmd.edit(vim.fn.fnameescape(vim.fn.getcwd(0)))
    end
end, { desc = "Voltar ao navegador de diretórios" })

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    group = grupo,
    callback = function(args)
        if vim.bo[args.buf].filetype == "directory" then
            ultimo_dir = args.buf
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = grupo,
    pattern = "directory",
    callback = function(args)
        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc, silent = true })
        end
        -- O nvim.dir omite "-" quando outro atalho já aponta para o mesmo <Plug>.
        map("-", "<Plug>(nvim-dir-up)", "Abrir o diretório pai")
        map("<C-b>", "<Plug>(nvim-dir-split)", "Abrir em split horizontal")
        map("<C-s>", "<Plug>(nvim-dir-reload)", "Recarregar a listagem")
        map("gi", abrir_no_imv, "Abrir imagens no imv na ordem da listagem")
        map("<leader>i", function()
            detalhes = not detalhes
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "directory" then
                    decorar(buf)
                end
            end
        end, "Alternar as colunas de detalhe")
        map("gh", function()
            vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand("~")))
        end, "Ir para Home")
        map("gd", function()
            vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand("~/Downloads")))
        end, "Ir para Downloads")
        map("_", function()
            local raiz = vim.fs.root(args.buf, ".git") or vim.fn.getcwd(-1, -1)
            vim.cmd.edit(vim.fn.fnameescape(raiz))
        end, "Ir para a raiz do projeto")
        map("+", function()
            local dir = vim.api.nvim_buf_get_name(args.buf)
            vim.ui.input({
                prompt = "Criar diretório: ",
                default = dir:sub(-1) == "/" and dir or dir .. "/",
                completion = "dir",
            }, function(input)
                if input and input ~= "" then
                    local ok, err = pcall(vim.fn.mkdir, destino(input, dir), "p")
                    if ok then
                        recarregar(args.buf)
                    else
                        vim.notify("Erro ao criar diretório: " .. err, vim.log.levels.ERROR)
                    end
                end
            end)
        end, "Criar diretório")
        map("R", function()
            renomear(false)
        end, "Renomear")
        map("M", function()
            renomear(true)
        end, "Mover")
        map("d", function()
            local path = entrada()
            local stat = path and vim.uv.fs_lstat(path)
            if not stat or vim.fn.confirm("Apagar?\n" .. path, "&Sim\n&Não", 2) ~= 1 then
                return
            end
            if vim.fn.delete(path, stat.type == "directory" and "rf" or "") == 0 then
                recarregar(args.buf)
            else
                vim.notify("Erro ao apagar: " .. path, vim.log.levels.ERROR)
            end
        end, "Apagar arquivo ou diretório")
        vim.wo.winbar = "%!v:lua.DirWinbar()"
    end,
})

vim.api.nvim_create_autocmd("User", {
    group = grupo,
    pattern = "DirReadPost",
    callback = function(args)
        local dir = vim.api.nvim_buf_get_name(args.buf)
        local nomes = vim.api.nvim_buf_get_lines(args.buf, 0, -1, true)
        local stats
        if por_data(dir) then
            stats = {}
            local datas = {}
            for _, nome in ipairs(nomes) do
                local stat = vim.uv.fs_lstat(caminho(dir, nome))
                stats[nome] = stat
                datas[nome] = stat and data_entrada(stat, true) or 0
            end
            table.sort(nomes, function(a, b)
                return datas[a] == datas[b] and a < b or datas[a] > datas[b]
            end)
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, true, nomes)
        end
        decorar(args.buf, stats)
    end,
})
