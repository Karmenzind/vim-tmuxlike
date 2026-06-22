local api = vim.api

local M = {}
local state = require("tmuxlike.state").get("layout")
state.tabs = state.tabs or {}

local layouts = {
  "even-horizontal",
  "even-vertical",
  "main-horizontal",
  "main-vertical",
}

local function windows(tab)
  local result = {}
  for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
    if api.nvim_win_get_config(win).relative == "" then
      result[#result + 1] = win
    end
  end
  return result
end

local function linearize(wins, command, current)
  for index = 2, #wins do
    if api.nvim_win_is_valid(wins[index]) then
      api.nvim_set_current_win(wins[index])
      vim.cmd("wincmd " .. command)
    end
  end
  if api.nvim_win_is_valid(current) then
    api.nvim_set_current_win(current)
  end
end

local function apply(name, wins, current)
  if name == "even-horizontal" then
    linearize(wins, "L", current)
  elseif name == "even-vertical" then
    linearize(wins, "J", current)
  elseif name == "main-horizontal" then
    linearize(wins, "L", current)
    vim.cmd("wincmd K")
  elseif name == "main-vertical" then
    linearize(wins, "J", current)
    vim.cmd("wincmd H")
  end
  vim.cmd("wincmd =")
  api.nvim_set_current_win(current)
end

function M.cycle()
  local tab = api.nvim_get_current_tabpage()
  local wins = windows(tab)
  if #wins < 2 then
    return false
  end

  local current = api.nvim_get_current_win()
  local index = (state.tabs[tab] or 0) % #layouts + 1
  apply(layouts[index], wins, current)
  state.tabs[tab] = index
  return layouts[index]
end

function M._state()
  return state
end

return M
