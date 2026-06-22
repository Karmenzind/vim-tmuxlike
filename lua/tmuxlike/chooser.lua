local api = vim.api

local M = {}
local namespace = api.nvim_create_namespace("vim-tmuxlike-chooser")
local state_manager = require("tmuxlike.state")
local state = state_manager.get("chooser")
local float = require("tmuxlike.float")

-- Generated with: toilet -f smblock <A-Z>
local large_glyphs = {
  smblock = {
    A = { "▞▀▖", "▙▄▌", "▌ ▌", "▘ ▘" },
    B = { "▛▀▖", "▙▄▘", "▌ ▌", "▀▀ " },
    C = { "▞▀▖", "▌  ", "▌ ▖", "▝▀ " },
    D = { "▛▀▖", "▌ ▌", "▌ ▌", "▀▀ " },
    E = { "▛▀▘", "▙▄ ", "▌  ", "▀▀▘" },
    F = { "▛▀▘", "▙▄ ", "▌  ", "▘  " },
    G = { "▞▀▖", "▌▄▖", "▌ ▌", "▝▀ " },
    H = { "▌ ▌", "▙▄▌", "▌ ▌", "▘ ▘" },
    I = { "▜▘", "▐ ", "▐ ", "▀▘" },
    J = { " ▜▘", " ▐ ", "▌▐ ", "▝▘ " },
    K = { "▌ ▌", "▙▞ ", "▌▝▖", "▘ ▘" },
    L = { "▌  ", "▌  ", "▌  ", "▀▀▘" },
    M = { "▙▗▌", "▌▘▌", "▌ ▌", "▘ ▘" },
    N = { "▙ ▌", "▌▌▌", "▌▝▌", "▘ ▘" },
    O = { "▞▀▖", "▌ ▌", "▌ ▌", "▝▀ " },
    P = { "▛▀▖", "▙▄▘", "▌  ", "▘  " },
    Q = { "▞▀▖", "▌ ▌", "▌▚▘", "▝▘▘" },
    R = { "▛▀▖", "▙▄▘", "▌▚ ", "▘ ▘" },
    S = { "▞▀▖", "▚▄ ", "▖ ▌", "▝▀ " },
    T = { "▀▛▘", " ▌ ", " ▌ ", " ▘ " },
    U = { "▌ ▌", "▌ ▌", "▌ ▌", "▝▀ " },
    V = { "▌ ▌", "▚▗▘", "▝▞ ", " ▘ " },
    W = { "▌ ▌", "▌▖▌", "▙▚▌", "▘ ▘" },
    X = { "▌ ▌", "▝▞ ", "▞▝▖", "▘ ▘" },
    Y = { "▌ ▌", "▝▞ ", " ▌ ", " ▘ " },
    Z = { "▀▀▌", " ▞ ", "▞  ", "▀▀▘" },
  },
  -- Generated with: toilet -f pagga <A-Z>
  pagga = {
    A = { "░█▀█", "░█▀█", "░▀░▀" },
    B = { "░█▀▄", "░█▀▄", "░▀▀░" },
    C = { "░█▀▀", "░█░░", "░▀▀▀" },
    D = { "░█▀▄", "░█░█", "░▀▀░" },
    E = { "░█▀▀", "░█▀▀", "░▀▀▀" },
    F = { "░█▀▀", "░█▀▀", "░▀░░" },
    G = { "░█▀▀", "░█░█", "░▀▀▀" },
    H = { "░█░█", "░█▀█", "░▀░▀" },
    I = { "░▀█▀", "░░█░", "░▀▀▀" },
    J = { "░▀▀█", "░░░█", "░▀▀░" },
    K = { "░█░█", "░█▀▄", "░▀░▀" },
    L = { "░█░░", "░█░░", "░▀▀▀" },
    M = { "░█▄█", "░█░█", "░▀░▀" },
    N = { "░█▀█", "░█░█", "░▀░▀" },
    O = { "░█▀█", "░█░█", "░▀▀▀" },
    P = { "░█▀█", "░█▀▀", "░▀░░" },
    Q = { "░▄▀▄", "░█\\█", "░░▀\\" },
    R = { "░█▀▄", "░█▀▄", "░▀░▀" },
    S = { "░█▀▀", "░▀▀█", "░▀▀▀" },
    T = { "░▀█▀", "░░█░", "░░▀░" },
    U = { "░█░█", "░█░█", "░▀▀▀" },
    V = { "░█░█", "░▀▄▀", "░░▀░" },
    W = { "░█░█", "░█▄█", "░▀░▀" },
    X = { "░█░█", "░▄▀▄", "░▀░▀" },
    Y = { "░█░█", "░░█░", "░░▀░" },
    Z = { "░▀▀█", "░▄▀░", "░▀▀▀" },
  },
}

local function glyph_set()
    local font = require("tmuxlike.config").get().chooser.font
    return large_glyphs[font] or large_glyphs.smblock
end

local function valid_win(win)
    return win ~= nil and api.nvim_win_is_valid(win)
end

local function targets(scope)
    local result = {}
    local tabs = scope == "all" and api.nvim_list_tabpages() or { api.nvim_get_current_tabpage() }
    for tab_index, tab in ipairs(tabs) do
        for win_index, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
            local config = api.nvim_win_get_config(win)
            if config.relative == "" then
                table.insert(result, {
                    tab = tab,
                    tab_index = tab_index,
                    win = win,
                    win_index = win_index,
                    buf = api.nvim_win_get_buf(win),
                })
            end
        end
    end
    return result
end

local function usable_glyphs()
    local result = {}
    local chooser_config = require("tmuxlike.config").get().chooser
    local glyphs = glyph_set()
    local characters = chooser_config.characters
    for character in characters:gmatch(".") do
        local glyph = glyphs[character]
        if glyph then
            result[#result + 1] = {
                label = character:lower(),
                glyph = glyph,
            }
        end
    end
    return result
end

local function marker_glyph(label)
    return glyph_set()[label:upper()]
end

local function centered_glyph(glyph, width)
    local lines = {}
    for _, line in ipairs(glyph) do
        local remaining = width - vim.fn.strdisplaywidth(line)
        local left = math.floor(remaining / 2)
        local right = remaining - left
        lines[#lines + 1] = string.rep(" ", left) .. line .. string.rep(" ", right)
    end
    return lines
end

local function select_target(target)
    if not target or not valid_win(target.win) then
        M.stop()
        return
    end
    M.stop()
    api.nvim_set_current_tabpage(target.tab)
    api.nvim_set_current_win(target.win)
    api.nvim__redraw({ cursor = true, flush = true })
end

local function select_tab(tab)
    if not tab or not api.nvim_tabpage_is_valid(tab) then
        M.stop()
        return
    end
    M.stop()
    api.nvim_set_current_tabpage(tab)
    api.nvim__redraw({ cursor = true, flush = true })
end

local function handle_key(key, typed)
    if not state.active then
        return key
    end

    local input = (typed ~= "" and typed or key):lower()
    if input == "q" or input == vim.keycode("<Esc>") then
        M.stop()
    elseif state.by_tab_number and state.by_tab_number[input] then
        select_tab(state.by_tab_number[input])
    else
        local target = state.by_label and state.by_label[input]
        if target then
            select_target(target)
        end
    end
    return ""
end

local function marker(target, entry)
    local chooser_config = require("tmuxlike.config").get().chooser
    local width = chooser_config.marker_width
    for _, candidate in ipairs(usable_glyphs()) do
        for _, line in ipairs(candidate.glyph) do
            width = math.max(width, vim.fn.strdisplaywidth(line))
        end
    end
    local glyph = centered_glyph(entry.glyph, width)
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, false, glyph)
    vim.bo[buf].modifiable = false
    local height = #glyph
    local col = math.max(0, math.floor((api.nvim_win_get_width(target.win) - width) / 2))
    local row = math.max(0, math.floor((api.nvim_win_get_height(target.win) - height) / 2))
    local win = api.nvim_open_win(buf, false, {
        relative = "win",
        win = target.win,
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        focusable = false,
        zindex = 310,
    })
    vim.wo[win].winhighlight = "Normal:IncSearch,FloatBorder:IncSearch"
    table.insert(state.markers, { buf = buf, win = win })
end

local function tab_name(tab, index)
    local win = api.nvim_tabpage_get_win(tab)
    local name = api.nvim_buf_get_name(api.nvim_win_get_buf(win))
    if name == "" then
        return "Tab " .. index
    end
    return vim.fn.fnamemodify(name, ":t")
end

local function show_tab_selector()
    local tabs = api.nvim_list_tabpages()
    if #tabs <= 1 then
        return
    end

    local parts = {}
    state.by_tab_number = {}
    for index, tab in ipairs(tabs) do
        if index > 9 then
            break
        end
        local number = tostring(index)
        state.by_tab_number[number] = tab
        parts[#parts + 1] = string.format("%s:%s", number, tab_name(tab, index))
    end

    state.tabs_buf, state.tabs_win = float.open({ table.concat(parts, "  ") }, {
        title = " Tabs ",
        row = 1,
        max_width = math.max(20, vim.o.columns - 4),
        height = 1,
        focusable = false,
        zindex = 320,
    })
end

local function list(target_list, glyphs)
    local lines = {}
    for index, target in ipairs(target_list) do
        local name = api.nvim_buf_get_name(target.buf)
        if name == "" then
            name = "[No Name]"
        else
            name = vim.fn.fnamemodify(name, ":~:.")
        end
        table.insert(
            lines,
            string.format(
                " %s  tab %d, window %d  %s",
                glyphs[index].label,
                target.tab_index,
                target.win_index,
                name
            )
        )
    end
    state.list_buf, state.list_win = float.open(lines, {
        title = " Select Window ",
        max_width = math.max(30, math.floor(vim.o.columns * 0.8)),
        max_height = math.max(3, math.floor(vim.o.lines * 0.7)),
        focusable = false,
    })
end

function M.stop()
    state.active = false
    state_manager.deactivate("chooser")
    vim.on_key(nil, namespace)
    if state.closed_autocmd then
        pcall(api.nvim_del_autocmd, state.closed_autocmd)
        state.closed_autocmd = nil
    end
    for _, item in ipairs(state.markers or {}) do
        float.close(item.buf, item.win)
    end
    float.close(state.list_buf, state.list_win)
    float.close(state.tabs_buf, state.tabs_win)
    state.markers = {}
    state.list_buf = nil
    state.list_win = nil
    state.tabs_buf = nil
    state.tabs_win = nil
    state.by_label = nil
    state.by_tab_number = nil
end

function M.select(label)
    select_target(state.by_label and state.by_label[label])
end

function M.start(opts)
    opts = opts or {}
    M.stop()

    local config = require("tmuxlike.config").get().chooser
    local scope = opts.scope or config.scope
    local glyphs = usable_glyphs()
    local target_list = targets(scope)
    if #target_list == 0 then
        return false
    end
    if #target_list > #glyphs then
        vim.notify("You've opened too many windows. Are you here to cause trouble?", vim.log.levels.WARN)
        return false
    end

    state_manager.activate("chooser", M.stop)
    state.active = true
    state.markers = {}
    state.by_label = {}
    for index, target in ipairs(target_list) do
        local entry = glyphs[index]
        state.by_label[entry.label] = target
        if scope == "current" then
            marker(target, entry)
        end
    end
    if scope == "all" then
        list(target_list, glyphs)
    end
    show_tab_selector()
    state.closed_autocmd = api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            local closed = tonumber(args.match)
            for _, target in pairs(state.by_label or {}) do
                if target.win == closed then
                    M.stop()
                    return
                end
            end
        end,
    })
    vim.on_key(handle_key, namespace)
    return true
end

function M._state()
    return state
end

function M._marker_glyph(label)
    return marker_glyph(label)
end

function M._centered_marker_glyph(label)
    local width = require("tmuxlike.config").get().chooser.marker_width
    for _, candidate in ipairs(usable_glyphs()) do
        for _, line in ipairs(candidate.glyph) do
            width = math.max(width, vim.fn.strdisplaywidth(line))
        end
    end
    return centered_glyph(marker_glyph(label), width)
end

return M
