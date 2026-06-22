local M = {}
local features = {}
local modal_name
local modal_stop

function M.get(name)
  if features[name] == nil then
    features[name] = {}
  end
  return features[name]
end

function M.reset(name)
  features[name] = {}
  return features[name]
end

function M.activate(name, stop)
  if modal_name and modal_name ~= name then
    local previous_stop = modal_stop
    modal_name = nil
    modal_stop = nil
    previous_stop()
  end
  modal_name = name
  modal_stop = stop
end

function M.deactivate(name)
  if modal_name == name then
    modal_name = nil
    modal_stop = nil
  end
end

return M
