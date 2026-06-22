local api = vim.api

local M = {}
local state = require("tmuxlike.state").get("zoom")
state.tabs = state.tabs or {}

local ignored_filetypes = {
  nerdtree = true,
  qf = true,
  tagbar = true,
}

local group = api.nvim_create_augroup("vim-tmuxlike-zoom", { clear = true })
api.nvim_create_autocmd({ "WinClosed", "TabClosed" }, {
  group = group,
  callback = function()
    for tab, win in pairs(state.tabs) do
      if not api.nvim_tabpage_is_valid(tab) or not api.nvim_win_is_valid(win) then
        state.tabs[tab] = nil
      end
    end
  end,
})

local function normal_windows(tab)
  local result = {}
  for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
    if api.nvim_win_get_config(win).relative == "" then
      table.insert(result, win)
    end
  end
  return result
end

function M.reset(tab)
  tab = tab or api.nvim_get_current_tabpage()
  state.tabs[tab] = nil
end

function M.equalize()
  vim.cmd("wincmd =")
  M.reset()
end

function M.toggle()
  local tab = api.nvim_get_current_tabpage()
  local win = api.nvim_get_current_win()
  if #normal_windows(tab) <= 1 then
    M.reset(tab)
    return false
  end

  if state.tabs[tab] == win then
    M.equalize()
    return false
  end

  local filetype = vim.bo[api.nvim_win_get_buf(win)].filetype:lower()
  if ignored_filetypes[filetype] then
    vim.notify("Ignored filetype: " .. filetype, vim.log.levels.INFO)
    return false
  end

  for _, command in ipairs({ "NERDTreeClose", "TagbarClose", "cclose" }) do
    pcall(vim.cmd, command)
  end
  api.nvim_win_call(win, function()
    vim.cmd("resize")
    vim.cmd("vertical resize")
  end)
  state.tabs[tab] = win
  return true
end

function M._state()
  return state
end

return M
