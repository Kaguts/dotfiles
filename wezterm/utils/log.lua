-- ~/.config/wezterm/utils/log.lua
local wezterm = require "wezterm"
local M = {}

local LEVELS = { DEBUG = 10, INFO = 20, WARN = 30, ERROR = 40 }
local current = LEVELS.INFO

function M.set_level(lvl)
  current = LEVELS[(lvl or "INFO"):upper()] or current
end

local function prefix(level, msg)
  return string.format("[utils/%s] %s", level, msg)
end

local function fmt(msg, ...)
  if select("#", ...) > 0 then return string.format(msg, ...) end
  return msg
end

function M.debug(msg, ...)
  if current <= LEVELS.DEBUG then
    wezterm.log_info(prefix("DEBUG", fmt(msg, ...)))
  end
end

function M.info(msg, ...)
  if current <= LEVELS.INFO then
    wezterm.log_info(prefix("INFO", fmt(msg, ...)))
  end
end

function M.warn(msg, ...)
  if current <= LEVELS.WARN then
    wezterm.log_warn(prefix("WARN", fmt(msg, ...)))
  end
end

function M.err(msg, ...)
  if current <= LEVELS.ERROR then
    wezterm.log_error(prefix("ERR", fmt(msg, ...)))
  end
end

M.error = M.err -- alias

-- Chronomètre pour profiler des blocs
function M.time(label)
  local t0 = wezterm.time_now()
  return function()
    local dt = (wezterm.time_now() - t0) * 1000.0
    M.info("%s took %.2f ms", label or "timed-block", dt)
  end
end

-- Sous-logger préfixé: local log = M.with("gpu"); log.info("...")
function M.with(tag)
  local P = {}
  local function pf(lvl, msg, ...) return string.format("[%s] %s", tag, fmt(msg, ...)) end
  function P.debug(...) M.debug(pf("DEBUG", ...)) end
  function P.info(...)  M.info(pf("INFO",  ...)) end
  function P.warn(...)  M.warn(pf("WARN",  ...)) end
  function P.err(...)   M.err (pf("ERR",   ...)) end
  return P
end

return M
