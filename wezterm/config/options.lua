local M = {}

function M.apply(config, wezterm)
  -- UI de base
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = true

  -- Signal sonore
  config.audible_bell = "Disabled"

  -- Historique / perf
  config.scrollback_lines = 10000
  config.max_fps = 120
  config.animation_fps = 60

  -- Taille fenêtre quand on change la police
  config.adjust_window_size_when_changing_font_size = false

  -- Décorations
  config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"

  -- Frontend GPU
  config.front_end = "WebGpu"

  -- Curseur & sélection
  config.force_reverse_video_cursor = true
  config.selection_word_boundary = " \t\n{}[]()'\"`.,;:!?"

  -- Messages quand un process se termine
  config.exit_behavior_messaging = "Terse"
  -- config.exit_behavior = "Hold" -- décommente si tu veux garder la fenêtre ouverte

  -- (Optionnels – laisse commentés si tu n’en as pas besoin)
  -- config.check_for_updates = false
  -- config.warn_about_missing_glyphs = false
  -- config.term = "xterm-256color" -- ou "wezterm"
end

return M
