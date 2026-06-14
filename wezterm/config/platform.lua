local wezterm = require "wezterm"
local M = {}

local function is_wsl()
  if os.getenv("WSL_DISTRO_NAME") then return true end
  local f = io.open("/proc/version", "r")
  if f then
    local s = f:read("*a") or ""; f:close()
    if s:match("[Mm]icrosoft") then return true end
  end
  return false
end

local function is_windows()
  local triple = wezterm.target_triple
  return triple and triple:find("windows") ~= nil
end

function M.detect()
  local platform = {
    is_wsl = is_wsl(),
    is_windows = is_windows(),
    triple = wezterm.target_triple,
    home = os.getenv("HOME") or os.getenv("USERPROFILE") or "~",
  }
  platform.is_linux = (platform.triple or ""):find("linux") ~= nil and not platform.is_wsl
  platform.is_macos = (platform.triple or ""):find("darwin") ~= nil or (platform.triple or ""):find("apple") ~= nil

  platform.family =
    (platform.is_wsl     and "wsl")
    or (platform.is_windows and "windows")
    or (platform.is_macos and "macos")
    or "linux"

  platform.label =
    (platform.is_wsl     and "WSL")
    or (platform.is_windows and "Windows")
    or (platform.is_macos and "macOS")
    or "Linux"

  return platform
end

function M.apply(config, wezterm, platform)
  if platform.is_windows and not platform.is_wsl then
    config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
  else
    config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
  end

  if platform.is_wsl then
    config.enable_wayland = false
  end
end

return M
