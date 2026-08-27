local FALLBACK = {
    bg      = 0x181818,
    fg      = 0xe4e4ef,
    yellow  = 0xffdd33,
    red     = 0xf43841,
    green   = 0x73d936,
    quartz  = 0x95a99f,
    niagara = 0x96a6c8,
    brown   = 0xcc8c3c,
}

local ICONS = {
    error = "󰅚",
    warn  = "󰀪",
    info  = "󰋽",
    hint  = "󰌵",
}

local function get_hl(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.reverse then return { fg = hl.bg, bg = hl.fg } end
    return { fg = hl.fg, bg = hl.bg }
end

local function setup_colors()
    local normal  = get_hl("Normal")
    local sl      = get_hl("StatusLine")
    local slnc    = get_hl("StatusLineNC")

    local func    = get_hl("Function")
    local str     = get_hl("String")
    local warn    = get_hl("DiagnosticWarn")
    local err     = get_hl("DiagnosticError")
    local info    = get_hl("DiagnosticInfo")
    local hint    = get_hl("DiagnosticHint")

    local bg_body = sl.bg or normal.bg or FALLBACK.bg
    local fg_body = sl.fg or normal.fg or FALLBACK.fg
    local bg_info = get_hl("CursorLine").bg or bg_body
    local fg_info = sl.fg or normal.fg or FALLBACK.fg
    local fg_mode = normal.bg or bg_body

    local set     = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

    set("StatusLineModeN", { bg = func.fg or FALLBACK.yellow, fg = fg_mode, bold = true })
    set("StatusLineModeI", { bg = str.fg or FALLBACK.green, fg = fg_mode, bold = true })
    set("StatusLineModeV", { bg = warn.fg or FALLBACK.brown, fg = fg_mode, bold = true })
    set("StatusLineModeR", { bg = err.fg or FALLBACK.red, fg = fg_mode, bold = true })
    set("StatusLineModeC", { bg = info.fg or FALLBACK.niagara, fg = fg_mode, bold = true })
    set("StatusLineMode", { bg = func.fg or FALLBACK.yellow, fg = fg_mode, bold = true })

    set("StatusLineInfo", { bg = bg_info, fg = fg_info })
    set("StatusLineBody", { bg = bg_body, fg = fg_body })

    set("StatusLineErr", { bg = bg_body, fg = err.fg or FALLBACK.red })
    set("StatusLineWarn", { bg = bg_body, fg = warn.fg or FALLBACK.brown })
    set("StatusLineInf", { bg = bg_body, fg = info.fg or FALLBACK.niagara })
    set("StatusLineHnt", { bg = bg_body, fg = hint.fg or FALLBACK.quartz })

    set("StatusLineNCBody", {
        bg = slnc.bg or bg_body,
        fg = slnc.fg or FALLBACK.quartz,
    })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group    = vim.api.nvim_create_augroup("custom_statusline", { clear = true }),
    pattern  = "*",
    callback = setup_colors,
})
setup_colors()

local MODES = {
    ["n"]   = { " NORMAL ", "N" },
    ["no"]  = { " PENDING ", "N" },
    ["i"]   = { " INSERT ", "I" },
    ["v"]   = { " VISUAL ", "V" },
    ["V"]   = { " V-LINE ", "V" },
    ["\22"] = { " V-BLOCK ", "V" },
    ["s"]   = { " SELECT ", "V" },
    ["S"]   = { " S-LINE ", "V" },
    ["\19"] = { " S-BLOCK ", "V" },
    ["R"]   = { " REPLACE ", "R" },
    ["Rv"]  = { " V-REPLACE ", "R" },
    ["c"]   = { " COMMAND ", "C" },
    ["r"]   = { " PROMPT ", "C" },
    ["!"]   = { " SHELL ", "C" },
    ["t"]   = { " TERMINAL ", "C" },
}

local function mode_parts()
    local m = vim.api.nvim_get_mode().mode
    local entry = MODES[m] or MODES[m:sub(1, 1)]
    if not entry then return " " .. m .. " ", "%#StatusLineMode#" end
    return entry[1], "%#StatusLineMode" .. entry[2] .. "#"
end

local SEVERITIES = {
    { vim.diagnostic.severity.ERROR, "%#StatusLineErr#",  ICONS.error },
    { vim.diagnostic.severity.WARN,  "%#StatusLineWarn#", ICONS.warn },
    { vim.diagnostic.severity.INFO,  "%#StatusLineInf#",  ICONS.info },
    { vim.diagnostic.severity.HINT,  "%#StatusLineHnt#",  ICONS.hint },
}

local function diagnostics(bufnr)
    local counts = vim.diagnostic.count(bufnr)
    local out = {}
    for _, sev in ipairs(SEVERITIES) do
        local n = counts[sev[1]]
        if n and n > 0 then
            out[#out + 1] = sev[2] .. " " .. sev[3] .. " " .. n .. " "
        end
    end
    return table.concat(out)
end

_G.BuildStatusLine = function()
    -- statusline_winid é a janela sendo desenhada, não necessariamente a ativa
    local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)

    if winid ~= vim.api.nvim_get_current_win() then
        return table.concat({
            "%#StatusLineNCBody#",
            " %<%f %m%r",
            "%=",
            " %3p%% ",
        })
    end

    local mode_name, mode_hl = mode_parts()

    return table.concat({
        mode_hl, mode_name,
        "%#StatusLineInfo# %<%f %m %r ",
        "%=",
        diagnostics(bufnr),
        "%#StatusLineBody# %y ",
        "%#StatusLineInfo# %3p%% ",
        mode_hl, " %3l:%-2c ",
    })
end

vim.opt.statusline = "%!v:lua.BuildStatusLine()"
