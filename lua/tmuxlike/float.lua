local api = vim.api

local M = {}

local function dimensions(lines, opts)
  local width = opts.width or 1
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width, opts.max_width or math.max(1, vim.o.columns - 4))

  local height = opts.height or #lines
  height = math.min(height, opts.max_height or math.max(1, vim.o.lines - 4))
  return width, math.max(1, height)
end

function M.open(lines, opts)
  opts = opts or {}
  local width, height = dimensions(lines, opts)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local config = {
    relative = "editor",
    row = opts.row or math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = opts.col or math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = height,
    style = "minimal",
    border = opts.border or "rounded",
    focusable = opts.focusable ~= false,
    zindex = opts.zindex or 250,
    title = opts.title,
    title_pos = opts.title and "center" or nil,
  }

  local win = api.nvim_open_win(buf, opts.enter == true, config)
  vim.wo[win].wrap = opts.wrap == true
  vim.wo[win].cursorline = opts.cursorline == true
  vim.wo[win].winhighlight = opts.winhighlight or "Normal:NormalFloat,FloatBorder:FloatBorder"
  return buf, win
end

function M.close(buf, win)
  if win and api.nvim_win_is_valid(win) then
    pcall(api.nvim_win_close, win, true)
  end
  if buf and api.nvim_buf_is_valid(buf) then
    pcall(api.nvim_buf_delete, buf, { force = true })
  end
end

return M
