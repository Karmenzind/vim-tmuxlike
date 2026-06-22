local api = vim.api

local M = {}
local namespace = api.nvim_create_namespace("vim-tmuxlike-resize")
local state_manager = require("tmuxlike.state")
local state = state_manager.get("resize")

local function initialize()
  state.active = false
  state.target_win = nil
  state.float_win = nil
  state.float_buf = nil
  state.target_closed_autocmd = nil
end

initialize()

local function valid_win(win)
  return win ~= nil and api.nvim_win_is_valid(win)
end

local function resize(direction)
  if not valid_win(state.target_win) then
    M.stop()
    return
  end

  local ok, err = pcall(function()
    local step = require("tmuxlike.config").get().resize_step
    if direction == "H" then
      api.nvim_win_set_width(state.target_win, api.nvim_win_get_width(state.target_win) + step)
    elseif direction == "L" then
      api.nvim_win_set_width(state.target_win, math.max(1, api.nvim_win_get_width(state.target_win) - step))
    elseif direction == "J" then
      api.nvim_win_set_height(state.target_win, api.nvim_win_get_height(state.target_win) + step)
    elseif direction == "K" then
      api.nvim_win_set_height(state.target_win, math.max(1, api.nvim_win_get_height(state.target_win) - step))
    end
  end)

  if not ok then
    M.stop()
    vim.schedule(function()
      vim.notify("vim-tmuxlike resize mode: " .. tostring(err), vim.log.levels.ERROR)
    end)
  end
end

local function is_exit_key(key)
  return key == "q"
    or key == "\r"
    or key == "\n"
    or key == vim.keycode("<Esc>")
    or key == vim.keycode("<CR>")
end

local function handle_key(key, typed)
  if not state.active then
    return key
  end

  local input = typed ~= "" and typed or key
  if is_exit_key(input) then
    vim.schedule(M.stop)
  elseif input == "H" or input == "J" or input == "K" or input == "L" then
    vim.schedule(function()
      if state.active then
        resize(input)
      end
    end)
  end

  return ""
end

local function open_hint()
  local lines = {
    "Resizing...",
    "Press H/J/K/L to resize, ESC/ENTER/q to quit",
  }
  local width = 1
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  state.float_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(state.float_buf, 0, -1, false, lines)
  vim.bo[state.float_buf].bufhidden = "wipe"
  vim.bo[state.float_buf].modifiable = false

  state.float_win = api.nvim_open_win(state.float_buf, false, {
    relative = "editor",
    anchor = "NE",
    row = 2,
    col = vim.o.columns - 1,
    width = width,
    height = #lines,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 300,
  })
  vim.wo[state.float_win].winhighlight = "Normal:Normal,FloatBorder:MoreMsg"
end

function M.stop()
  state.active = false
  state_manager.deactivate("resize")
  vim.on_key(nil, namespace)

  if state.target_closed_autocmd ~= nil then
    pcall(api.nvim_del_autocmd, state.target_closed_autocmd)
    state.target_closed_autocmd = nil
  end

  if valid_win(state.float_win) then
    pcall(api.nvim_win_close, state.float_win, true)
  end
  if state.float_buf ~= nil and api.nvim_buf_is_valid(state.float_buf) then
    pcall(api.nvim_buf_delete, state.float_buf, { force = true })
  end

  state.target_win = nil
  state.float_win = nil
  state.float_buf = nil
end

function M.apply(direction)
  resize(direction)
end

function M.start(direction)
  if vim.fn.has("nvim-0.11") ~= 1 then
    error("vim-tmuxlike resize mode requires Neovim 0.11 or newer")
  end

  M.stop()
  state_manager.activate("resize", M.stop)
  state.active = true
  state.target_win = api.nvim_get_current_win()

  local ok, err = pcall(function()
    open_hint()
    state.target_closed_autocmd = api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(state.target_win),
      once = true,
      callback = function()
        M.stop()
      end,
    })
    vim.on_key(handle_key, namespace)
    M.apply(direction)
  end)

  if not ok then
    M.stop()
    error(err)
  end

  return true
end

function M._state()
  return state
end

return M
