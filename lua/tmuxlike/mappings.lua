local M = {}
local managed = {}
local managed_prefix

local actions = {
  help = "<Cmd>help tmuxlike<CR>",
  zoom = "<Cmd>lua require('tmuxlike.zoom').toggle()<CR>",
  new_horizontal = "<Cmd>new<CR>",
  split_horizontal = "<Cmd>split<CR>",
  new_vertical = "<Cmd>vnew<CR>",
  split_vertical = "<Cmd>vsplit<CR>",
  new_tab = "<Cmd>$tabnew<CR>",
  previous_tab = "<Cmd>tabprevious<CR>",
  next_tab = "<Cmd>tabnext<CR>",
  close_window = "<Cmd>call tmuxlike#CloseCurrentWin()<CR>",
  close_tab = "<Cmd>call tmuxlike#CloseCurrentTab()<CR>",
  messages = "<Cmd>lua require('tmuxlike.messages').open()<CR>",
  break_pane = "<Cmd>call tmuxlike#TabSplitAndCloseCurrentBuf()<CR>",
  suspend = "<Cmd>suspend<CR>",
  redraw = "<Cmd>redraw<CR>",
  time = '<Cmd>echom strftime("%c")<CR>',
  paste = '"+p',
  previous_window = "<C-w>p",
  window_left = "<C-w>h",
  window_down = "<C-w>j",
  window_up = "<C-w>k",
  window_right = "<C-w>l",
  resize_left = "<Cmd>lua require('tmuxlike.resize').start('H')<CR>",
  resize_down = "<Cmd>lua require('tmuxlike.resize').start('J')<CR>",
  resize_up = "<Cmd>lua require('tmuxlike.resize').start('K')<CR>",
  resize_right = "<Cmd>lua require('tmuxlike.resize').start('L')<CR>",
  choose_window = "<Cmd>lua require('tmuxlike.chooser').start()<CR>",
  next_layout = "<Cmd>lua require('tmuxlike.layout').cycle()<CR>",
  swap_pane_previous = "<Cmd>lua require('tmuxlike.pane').swap(-1)<CR>",
  swap_pane_next = "<Cmd>lua require('tmuxlike.pane').swap(1)<CR>",
}

local function keys(value)
  if value == false or value == nil then
    return {}
  end
  return type(value) == "table" and value or { value }
end

local function clear()
  for _, lhs in ipairs(managed) do
    pcall(vim.keymap.del, "n", lhs)
  end
  managed = {}
end

function M.setup(config, initial)
  clear()
  for name, rhs in pairs(actions) do
    for _, key in ipairs(keys(config.mappings[name])) do
      local lhs = "<Plug>(tmuxlike-prefix)" .. key
      vim.keymap.set("n", lhs, rhs, { silent = true })
      table.insert(managed, lhs)
    end
  end

  if not initial and managed_prefix then
    pcall(vim.keymap.del, "n", managed_prefix)
    managed_prefix = nil
  end

  local existing = vim.fn.hasmapto("<Plug>(tmuxlike-prefix)", "n") == 1
  if config.prefix and (not initial or not existing) then
    if config.prefix ~= "<C-a>" then
      local current = vim.fn.maparg("<C-a>", "n")
      if current == "<Plug>(tmuxlike-prefix)" then
        pcall(vim.keymap.del, "n", "<C-a>")
      end
    end
    vim.keymap.set("n", config.prefix, "<Plug>(tmuxlike-prefix)", { silent = true })
    managed_prefix = config.prefix
  end
end

function M._managed()
  return managed
end

return M
