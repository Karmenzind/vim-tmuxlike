local M = {}

function M.setup(opts)
  local config = require("tmuxlike.config").setup(opts)
  require("tmuxlike.mappings").setup(config, opts == nil)
  return config
end

function M.config()
  return require("tmuxlike.config").get()
end

return M
