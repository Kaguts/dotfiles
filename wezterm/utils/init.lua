-- ~/.config/wezterm/utils/init.lua
-- Point d'entrée unique : require("utils").tbl.merge, etc. (lazy)
local M = {}

local map = {
  tbl  = "utils.tbl",
  path = "utils.path",
  log  = "utils.log",
  rt   = "utils.runtime",
}

setmetatable(M, {
  __index = function(t, k)
    local mod = map[k]
    if mod then
      local v = require(mod)
      rawset(t, k, v)
      return v
    end
  end,
})

return M
