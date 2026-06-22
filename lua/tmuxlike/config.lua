local M = {}
local excluded_chooser_characters = {
  C = true,
  D = true,
  G = true,
  Q = true,
}

local function validate_chooser(config)
  for character in config.characters:upper():gmatch(".") do
    if excluded_chooser_characters[character] then
      error("vim-tmuxlike: chooser character " .. character .. " is reserved and cannot be configured")
    end
  end
end

local vertical_split_key = vim.g.tmuxlike_key_vsplit or "|"
if vertical_split_key == "\\|" then
  vertical_split_key = "|"
end

local defaults = {
  prefix = "<C-a>",
  resize_step = 3,
  messages = vim.g.tmuxlike_messages_container or "scratch",
  chooser = {
    scope = vim.g.tmuxlike_chooser_scope or "current",
    characters = vim.g.tmuxlike_chooser_characters or "ABEFHIJKLMNOPRSTUVWXYZ",
    font = vim.g.tmuxlike_chooser_font or "smblock",
    marker_width = 4,
  },
  mappings = {
    help = "?",
    zoom = "z",
    new_horizontal = '"',
    split_horizontal = vim.g.tmuxlike_key_hsplit or "_",
    new_vertical = "%",
    split_vertical = vertical_split_key,
    new_tab = "c",
    previous_tab = { "<C-h>", "<C-p>" },
    next_tab = { "<C-l>", "<C-n>" },
    close_window = "x",
    close_tab = "&",
    messages = "~",
    break_pane = "!",
    suspend = "d",
    redraw = "r",
    time = "t",
    paste = "]",
    previous_window = ";",
    window_left = { "h", "<Left>" },
    window_down = { "j", "<Down>" },
    window_up = { "k", "<Up>" },
    window_right = { "l", "<Right>" },
    resize_left = "H",
    resize_down = "J",
    resize_up = "K",
    resize_right = "L",
    choose_window = { "q", "s", "=" },
    next_layout = "<Space>",
    swap_pane_previous = "{",
    swap_pane_next = "}",
  },
}

local options = vim.deepcopy(defaults)

function M.setup(opts)
  local candidate = vim.tbl_deep_extend("force", options, opts or {})
  validate_chooser(candidate.chooser)
  options = candidate
  return options
end

function M.get()
  return options
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
