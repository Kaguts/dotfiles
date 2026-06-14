return {
  keys = {
    -- Naviguer entre les panes
    h = { mods = "LEADER", action = "PaneLeft" },
    j = { mods = "LEADER", action = "PaneDown" },
    k = { mods = "LEADER", action = "PaneUp" },
    l = { mods = "LEADER", action = "PaneRight" },

    -- Redimensionner les panes (Alt + flèches)
    LeftArrow  = { mods = "ALT", action = { "Resize", "Left", 3 } },
    RightArrow = { mods = "ALT", action = { "Resize", "Right", 3 } },
    UpArrow    = { mods = "ALT", action = { "Resize", "Up", 2 } },
    DownArrow  = { mods = "ALT", action = { "Resize", "Down", 2 } },
  },
}
