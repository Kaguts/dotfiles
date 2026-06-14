-- ~/.config/wezterm/config/keys.lua
local wezterm = require "wezterm"
local act = wezterm.action
local M = {}
local U = require "utils"
local LOG = U.log

function M.apply(config, _wezterm, platform)
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 }

  config.keys = {
    -- Raccourcis
    {key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    {key="e", mods="CTRL|SHIFT", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key="o", mods="CTRL|SHIFT", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key="h", mods="ALT", action=wezterm.action{ActivatePaneDirection="Left"}},
    {key="l", mods="ALT", action=wezterm.action{ActivatePaneDirection="Right"}},
    {key="k", mods="ALT", action=wezterm.action{ActivatePaneDirection="Up"}},

    -- Panes
    { key = "-",  mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "z",  mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "h",  mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j",  mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k",  mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l",  mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    -- Resize (Alt + flèches)
    { key = "LeftArrow",  mods = "ALT", action = act.AdjustPaneSize({ "Left",  3 }) },
    { key = "RightArrow", mods = "ALT", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "UpArrow",    mods = "ALT", action = act.AdjustPaneSize({ "Up",    2 }) },
    { key = "DownArrow",  mods = "ALT", action = act.AdjustPaneSize({ "Down",  2 }) },

    -- Panes/Tab mgmt
    { key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
    { key = "c", mods = "LEADER", action = act.SpawnTab("DefaultDomain") },
    { key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

    -- Recherche / Copy
    { key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
    { key = " ", mods = "LEADER",     action = act.ActivateCopyMode },
    { key = "y", mods = "LEADER",     action = act.CopyTo("Clipboard") },

    -- Font size
    { key = "=", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL",       action = act.ResetFontSize },

    -- Palette & Launcher
    { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
    { key = "l", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES|LAUNCH_MENU_ITEMS" }) },

    -- Reload + log
    { key = "r", mods = "LEADER", action = act.Multiple{
        act.ReloadConfiguration,
        act.EmitEvent("cfg-reloaded"),
    }},
  }
end

return M