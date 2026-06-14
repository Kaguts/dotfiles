-- ~/.config/wezterm/utils/path.lua
local wezterm = require "wezterm"
local M = {}

function M.expand_home(p)
  if type(p) ~= "string" then return p end
  return p:gsub("^~", wezterm.home_dir)
end

function M.join(...)
  local parts = { ... }
  local out = {}
  for _, seg in ipairs(parts) do
    if seg and seg ~= "" then
      seg = tostring(seg):gsub("[/\\]+$", ""):gsub("^[/\\]+", "")
      table.insert(out, seg)
    end
  end
  local sep = package.config:sub(1,1) -- / ou \
  local joined = table.concat(out, sep)
  local first = parts[1]
  if type(first) == "string" and (first:match("^/") or first:match("^%a:[/\\]") or first:match("^[/\\][/\\]")) then
    if not joined:match("^" .. sep) and not joined:match("^%a:[/\\]") and not joined:match("^[/\\][/\\]") then
      joined = sep .. joined
    end
  end
  return joined
end

local function stat(path)
  local f = io.open(path, "rb")
  if f then f:close(); return "file" end
  local g = wezterm.glob(path .. "/*") or {}
  if #g > 0 then return "dir" end
  return nil
end

function M.exists(path) return stat(M.expand_home(path)) ~= nil end
function M.is_file(path) return stat(M.expand_home(path)) == "file" end
function M.is_dir(path)  return stat(M.expand_home(path)) == "dir"  end

function M.glob(pattern)
  pattern = M.expand_home(pattern)
  return wezterm.glob(pattern) or {}
end

return M
