local api = vim.api

local M = {}

local function windows()
  local result = {}
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_config(win).relative == "" then
      result[#result + 1] = win
    end
  end
  return result
end

function M.swap(direction)
  local wins = windows()
  if #wins < 2 then
    return false
  end

  local current = api.nvim_get_current_win()
  local current_index
  for index, win in ipairs(wins) do
    if win == current then
      current_index = index
      break
    end
  end
  if not current_index then
    return false
  end

  local target_index = ((current_index - 1 + direction) % #wins) + 1
  local target = wins[target_index]
  local current_buf = api.nvim_win_get_buf(current)
  local target_buf = api.nvim_win_get_buf(target)

  api.nvim_win_set_buf(current, target_buf)
  api.nvim_win_set_buf(target, current_buf)
  api.nvim_set_current_win(target)
  return true
end

return M
