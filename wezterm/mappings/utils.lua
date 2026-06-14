-- ~/.config/wezterm/mappings/utils.lua
local wezterm = require "wezterm"
local act = wezterm.action

local M = {}

-- helpers
local function is_array(t) return type(t) == "table" and (#t > 0 or next(t) == nil) end

-- Traduit une entrée simple en action WezTerm
local function to_action(entry)
  local a = entry.action

  -- Chaînes simples
  if type(a) == "string" then
    if a == "SplitVertical"      then return act.SplitVertical({ domain = "CurrentPaneDomain" }) end
    if a == "SplitHorizontal"    then return act.SplitHorizontal({ domain = "CurrentPaneDomain" }) end
    if a == "TogglePaneZoom"     then return act.TogglePaneZoomState end
    if a == "ClosePane"          then return act.CloseCurrentPane({ confirm = false }) end
    if a == "NewTab"             then return act.SpawnTab("DefaultDomain") end
    if a == "CloseTab"           then return act.CloseCurrentTab({ confirm = false }) end
    if a == "NextTab"            then return act.ActivateTabRelative(1) end
    if a == "PrevTab"            then return act.ActivateTabRelative(-1) end
    if a == "CommandPalette"     then return act.ActivateCommandPalette end
    if a == "PaneLeft"           then return act.ActivatePaneDirection("Left") end
    if a == "PaneRight"          then return act.ActivatePaneDirection("Right") end
    if a == "PaneUp"             then return act.ActivatePaneDirection("Up") end
    if a == "PaneDown"           then return act.ActivatePaneDirection("Down") end
    if a == "CopyMode"           then return act.ActivateCopyMode end
    if a == "Copy"               then return act.CopyTo("Clipboard") end
    if a == "Search"             then return act.Search({ CaseInSensitiveString = "" }) end
    if a == "FontBigger"         then return act.IncreaseFontSize end
    if a == "FontSmaller"        then return act.DecreaseFontSize end
    if a == "FontReset"          then return act.ResetFontSize end
  end

  -- Table structurée
  if is_array(a) then
    local tag = a[1]

    -- Resize: { "Resize", "Left", 3 }
    if tag == "Resize" then
      return act.AdjustPaneSize({ a[2], a[3] })

    -- GotoTab: { "GotoTab", 0..8 }
    elseif tag == "GotoTab" then
      return act.ActivateTab(tonumber(a[2]) or 0)

    -- Multiple: { "Multiple", { "ReloadConfiguration" }, { "Emit","cfg-reloaded" } }
    elseif tag == "Multiple" then
      local list = {}
      for i = 2, #a do
        local sub = to_action({ action = a[i] })
        if sub then table.insert(list, sub) end
      end
      return act.Multiple(list)

    -- Emit: { "Emit", "backdrop-next" }
    elseif tag == "Emit" then
      return act.EmitEvent(a[2])
    end
  end

  -- fallback: nil (sera filtré)
  return nil
end

-- Fusionne plusieurs tables de mappings
local function merge_tables(list)
  local out = {}
  for _, tbl in ipairs(list) do
    for k, v in pairs(tbl.keys or {}) do
      local action = to_action(v)
      if action then
        out[#out + 1] = { key = k, mods = v.mods, action = action }
      end
    end
  end
  return out
end

local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if ok then return m end
  return nil
end

function M.load()
  local default = require("mappings.default")
  local nav     = require("mappings.navigation")
  local edit    = require("mappings.editing")  -- suppose que tu as bien ce fichier

  -- (optionnel) overrides personnels si présents
  local localmap = safe_require("mappings.local")

  local keys = merge_tables(localmap and { default, nav, edit, localmap } or { default, nav, edit })
  return default.leader, keys
end

return M
