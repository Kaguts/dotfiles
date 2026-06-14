-- ~/.config/wezterm/utils/runtime.lua
local M = {}

function M.safe_require(modname)
  local ok, mod = pcall(require, modname)
  if ok then return mod, nil end
  return nil, mod
end

local _once_cache = {}
function M.once(key, fn)
  if _once_cache[key] ~= nil then return _once_cache[key] end
  local ok, res = pcall(fn)
  if ok then _once_cache[key] = res; return res end
  _once_cache[key] = nil
  return nil, res
end

function M.clear_once(key) _once_cache[key] = nil end  -- optionnel

function M.try(fn, ...)
  local args = { ... }
  return pcall(function() return fn(table.unpack(args)) end)
end

return M