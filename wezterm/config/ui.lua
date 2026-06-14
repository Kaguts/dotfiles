local wezterm = require "wezterm"
local U = require "utils"
local LOG, RT = U.log, U.rt
local M = {}

local function make_theme_fallback()
  return {
    foreground = "#c7c7c7",
    background = "#111216",
    cursor_bg = "#c7c7c7",
    cursor_border = "#c7c7c7",
    cursor_fg = "#111216",
    selection_bg = "#2b2f36",
    selection_fg = "#d0d0d0",
    ansi = { "#1e1f24","#e06c75","#98c379","#e5c07b","#61afef","#c678dd","#56b6c2","#abb2bf" },
    brights = { "#5c6370","#f28b92","#b3d39b","#f0d7a1","#8dc1ff","#d7aefc","#7fd3da","#e6e6e6" },
  }
end

function M.apply(config, wezterm, platform)
  local theme, err = RT.safe_require("colors.mon-theme")
  if theme then
    config.color_scheme = nil
    config.colors = theme
    LOG.info("Theme chargé: colors.mon-theme")
  else
    config.color_scheme = nil
    config.colors = make_theme_fallback()
    LOG.warn("Theme perso introuvable (%s), fallback", tostring(err))
  end

  config.font = wezterm.font_with_fallback({
    { family = "JetBrains Mono", weight = "Medium" },
    { family = "FiraCode Nerd Font" },
    { family = "Hack Nerd Font" },
    { family = "Symbols Nerd Font" },
  })
  config.font_size = platform.is_macos and 13.0 or 12.0

  -- === Fond d’écran ===
  config.window_background_image = "/home/user/images/background.jpg"
  config.window_background_opacity = 0.90   -- transparence de l’image
  
  -- Optionnels : densité et ligatures
  -- config.line_height = 1.05
  -- config.cell_width  = 1.0
  -- config.harfbuzz_features = { "calt", "clig", "liga" }

  config.window_background_opacity = 0.95
  config.macos_window_background_blur = 20
  config.window_close_confirmation = "NeverPrompt"
  config.use_fancy_tab_bar = true

  config.default_cursor_style = "BlinkingBar"
  config.cursor_blink_ease_in = "Constant"
  config.cursor_blink_ease_out = "Constant"
  config.cursor_blink_rate = 700

  config.window_padding = config.window_padding or { left = 8, right = 8, top = 6, bottom = 6 }
  config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.85 }
  config.bold_brightens_ansi_colors = false

  -- Optionnel : harmoniser l'entête de fenêtre
  -- config.window_frame = {
  --   active_titlebar_bg = config.colors and config.colors.background or "#111216",
  --   inactive_titlebar_bg = "#15161a",
  -- }
end

return M
