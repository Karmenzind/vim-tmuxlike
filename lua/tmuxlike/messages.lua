local api = vim.api

local M = {}
local state = require("tmuxlike.state").get("messages")
local float = require("tmuxlike.float")

local function history()
  local output = vim.fn.execute("messages")
  if output == "" then
    return {}
  end
  return vim.split(output, "\n", { plain = true, trimempty = true })
end

local function scratch(lines)
  vim.cmd("new [Messages]")
  local buf = api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "messages"
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  return true
end

function M.close()
  if state.closed_autocmd then
    pcall(api.nvim_del_autocmd, state.closed_autocmd)
    state.closed_autocmd = nil
  end
  float.close(state.buf, state.win)
  state.buf = nil
  state.win = nil
end

function M.show(opts)
  opts = opts or {}
  M.close()

  local lines = opts.lines or history()
  if #lines == 0 then
    vim.notify("No message history.", vim.log.levels.INFO)
    return false
  end

  local max_width = math.max(20, math.floor(vim.o.columns * 0.8))
  local max_height = math.max(3, math.floor(vim.o.lines * 0.7))
  state.buf, state.win = float.open(lines, {
    title = " Messages ",
    enter = true,
    max_width = max_width,
    max_height = max_height,
    wrap = false,
    cursorline = false,
  })
  vim.bo[state.buf].filetype = "messages"
  state.closed_autocmd = api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(state.win),
    once = true,
    callback = function()
      state.buf = nil
      state.win = nil
      state.closed_autocmd = nil
    end,
  })

  local close = function()
    M.close()
  end
  vim.keymap.set("n", "q", close, { buffer = state.buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = state.buf, silent = true })
  vim.keymap.set("n", "<CR>", close, { buffer = state.buf, silent = true })
  api.nvim_win_set_cursor(state.win, { math.min(#lines, max_height), 0 })
  return true
end

function M.open()
  local lines = history()
  if #lines == 0 then
    vim.notify("No message history.", vim.log.levels.INFO)
    return false
  end

  local container = require("tmuxlike.config").get().messages
  if container == "float" then
    return M.show({ lines = lines })
  elseif container == "scratch" then
    return scratch(lines)
  end
  vim.cmd("messages")
  return true
end

function M._state()
  return state
end

return M
