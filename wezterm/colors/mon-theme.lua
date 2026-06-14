return {
  foreground = "#d0d0d0",
  background = "#1a1b26",

  cursor_bg = "#c0caf5",
  cursor_fg = "#1a1b26",
  cursor_border = "#c0caf5",

  selection_fg = "#1a1b26",
  selection_bg = "#c0caf5",

  -- Couleurs utilitaires
  scrollbar_thumb = "#414868",
  split = "#2e3440",

  -- Clignotement visuel (si activé)
  visual_bell = "#334155", -- bleu/gris doux

  ansi = {
    "#1a1b26", -- black
    "#f7768e", -- red
    "#9ece6a", -- green
    "#e0af68", -- yellow
    "#7aa2f7", -- blue
    "#bb9af7", -- magenta
    "#7dcfff", -- cyan
    "#a9b1d6", -- white
  },

  brights = {
    "#414868", -- bright black
    "#f7768e", -- bright red
    "#9ece6a", -- bright green
    "#e0af68", -- bright yellow
    "#7aa2f7", -- bright blue
    "#bb9af7", -- bright magenta
    "#7dcfff", -- bright cyan
    "#c0caf5", -- bright white
  },

  -- (Optionnel) palette indexée additionnelle
  -- indexed = { [16] = "#ff9e64", [17] = "#db4b4b" },

  tab_bar = {
    background = "#1a1b26",

    active_tab = {
      bg_color = "#7aa2f7",
      fg_color = "#1a1b26",
      intensity = "Bold",
      -- underline = "None",
      -- italic = false,
      -- strikethrough = false,
    },

    inactive_tab = {
      bg_color = "#1a1b26",
      fg_color = "#a9b1d6",
    },

    inactive_tab_hover = {
      bg_color = "#2e3440",
      fg_color = "#c0caf5",
      italic = true,
    },

    new_tab = {
      bg_color = "#1a1b26",
      fg_color = "#7aa2f7",
    },

    new_tab_hover = {
      bg_color = "#2e3440",
      fg_color = "#c0caf5",
      italic = true,
    },

    -- Séparateur (utile quand bg inactif = bg fenêtre)
    inactive_tab_edge = "#2e3440",
  },

  -- Copy mode / Quick Select (optionnel mais agréable)
  copy_mode_active_highlight_bg = { Color = "#283449" },
  copy_mode_active_highlight_fg = { Color = "#c0caf5" },
  copy_mode_inactive_highlight_bg = { Color = "#1f2533" },
  copy_mode_inactive_highlight_fg = { Color = "#a9b1d6" },

  quick_select_label_bg = { Color = "#7aa2f7" },
  quick_select_label_fg = { Color = "#1a1b26" },
  quick_select_match_bg = { Color = "#2e3440" },
  quick_select_match_fg = { Color = "#c0caf5" },
}
