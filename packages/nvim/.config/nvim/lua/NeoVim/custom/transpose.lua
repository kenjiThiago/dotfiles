local function transpose_words()
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line_count = vim.api.nvim_buf_line_count(buf)

    row = row - 1

    local pattern = [[\k\+]]

    local function get_line(r)
        return vim.api.nvim_buf_get_lines(buf, r, r + 1, false)[1]
    end

    local function find_word(line, offset, r)
        local match = vim.fn.matchstrpos(line, pattern, offset)

        if match[2] == -1 then
            return nil
        end

        return {
            row = r,
            start_col = match[2],
            end_col = match[3],
            text = match[1],
        }
    end

    -- Palavra sob o cursor ou anterior a ele.
    local function find_left(r, c)
        for i = r, 0, -1 do
            local line = get_line(i)
            local offset = 0
            local last = nil

            while offset < #line do
                local word = find_word(line, offset, i)
                if not word then
                    break
                end

                if i == r and word.start_col > c then
                    break
                end

                last = word
                offset = word.end_col
            end

            if last then
                return last
            end
        end
    end

    -- Próxima palavra, inclusive em outras linhas.
    local function find_right(word)
        for r = word.row, line_count - 1 do
            local offset = r == word.row and word.end_col or 0
            local next_word = find_word(get_line(r), offset, r)

            if next_word then
                return next_word
            end
        end
    end

    local left = find_left(row, col)
    if not left then
        return
    end

    local right = find_right(left)

    -- Adaptação: se não existe próxima palavra,
    -- troca a atual com a anterior.
    if not right then
        right = left
        left = find_left(right.row, right.start_col - 1)

        if not left then
            return
        end
    end

    -- Substitui da direita para a esquerda.
    vim.api.nvim_buf_set_text(buf, right.row, right.start_col, right.row, right.end_col, { left.text })

    -- Agrupa as duas alterações em um único undo.
    vim.cmd("undojoin")

    vim.api.nvim_buf_set_text(buf, left.row, left.start_col, left.row, left.end_col, { right.text })

    -- Mantém o cursor sobre a palavra deslocada.
    local new_col = right.start_col + #left.text - 1

    if left.row == right.row then
        new_col = right.start_col + #right.text - 1
    end

    vim.api.nvim_win_set_cursor(0, {
        right.row + 1,
        new_col,
    })
end

vim.keymap.set("n", "<leader>tw", transpose_words, {
    desc = "Transpose words",
})
