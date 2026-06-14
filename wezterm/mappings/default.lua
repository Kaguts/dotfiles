-- ~/.config/wezterm/mappings/default.lua
return {
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 },

  keys = {
    -- Panes
    ["-"]  = { mods = "LEADER", action = "SplitVertical" },
    ["\\"] = { mods = "LEADER", action = "SplitHorizontal" },
    ["|"]  = { mods = "LEADER|SHIFT", action = "SplitHorizontal" }, -- alternative AZERTY
    ["z"]  = { mods = "LEADER", action = "TogglePaneZoom" },
    ["w"]  = { mods = "LEADER", action = "ClosePane" },

    -- Tabs
    ["c"] = { mods = "LEADER", action = "NewTab" },
    ["x"] = { mods = "LEADER", action = "CloseTab" },
    ["n"] = { mods = "LEADER", action = "NextTab" },
    ["p"] = { mods = "LEADER", action = "PrevTab" },

    -- Aller aux onglets 1..9
    ["1"] = { mods = "LEADER", action = { "GotoTab", 0 } },
    ["2"] = { mods = "LEADER", action = { "GotoTab", 1 } },
    ["3"] = { mods = "LEADER", action = { "GotoTab", 2 } },
    ["4"] = { mods = "LEADER", action = { "GotoTab", 3 } },
    ["5"] = { mods = "LEADER", action = { "GotoTab", 4 } },
    ["6"] = { mods = "LEADER", action = { "GotoTab", 5 } },
    ["7"] = { mods = "LEADER", action = { "GotoTab", 6 } },
    ["8"] = { mods = "LEADER", action = { "GotoTab", 7 } },
    ["9"] = { mods = "LEADER", action = { "GotoTab", 8 } },

    -- Command Palette
    ["p"] = { mods = "CTRL|SHIFT", action = "CommandPalette" },

    -- (optionnel) Reload rapide
    -- ["r"] = { mods = "LEADER", action = { "Multiple",
    --   { "ReloadConfiguration" }, { "Emit", "cfg-reloaded" } } },
  },
}
