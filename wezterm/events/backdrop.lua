local wezterm = require "wezterm"
local U = require "utils"
local P, LOG, RT = U.path, U.log, U.rt

local M = {}

-- Dossier des images (modifiable)
local BACKDROP_DIR = "~/.config/wezterm/backdrops"
-- extensions supportées (en minuscules)
local exts = { "png", "jpg", "jpeg", "webp" }

local function list_images()
  local dir = P.expand_home(BACKDROP_DIR)
  -- Vérifie que le dossier existe (sinon on évite les globs inutiles)
  if not P.exists(dir) then
    LOG.warn("Le dossier des backdrops n'existe pas: %s", dir)
    return {}
  end

  local images = {}
  -- On parcourt par extension, et on acceptera aussi .JPG majuscules via un test plus bas
  for _, ext in ipairs(exts) do
    for _, p in ipairs(P.glob(dir .. "/**/*." .. ext)) do
      images[#images + 1] = p
    end
    for _, p in ipairs(P.glob(dir .. "/**/*." .. ext:upper())) do
      images[#images + 1] = p
    end
  end

  table.sort(images)
  return images
end

-- On mémorise le dernier fond actif pour pouvoir “toggle” vers off/on
local function set_backdrop(window, path)
  local overrides = window:get_config_overrides() or {}
  overrides.window_background_image = path
  overrides.window_background_opacity = overrides.window_background_opacity or 0.9
  overrides.macos_window_background_blur = overrides.macos_window_background_blur or 20
  window:set_config_overrides(overrides)

  window.__last_backdrop_path = path -- mémo local au window handle
  LOG.info("Backdrop set to %s", path)
end

local function clear_backdrop(window)
  local overrides = window:get_config_overrides() or {}
  overrides.window_background_image = nil
  window:set_config_overrides(overrides)
  LOG.info("Backdrop cleared")
end

local function cycle(window, step)
  local imgs = list_images()
  if #imgs == 0 then
    LOG.warn("Aucune image trouvée dans %s", BACKDROP_DIR)
    return
  end

  local overrides = window:get_config_overrides() or {}
  local cur = overrides.window_background_image
  local idx = 0
  for i, p in ipairs(imgs) do
    if p == cur then idx = i; break end
  end
  idx = ((idx - 1 + step) % #imgs) + 1
  set_backdrop(window, imgs[idx])
end

function M.register(config, wezterm, platform)
  -- Empêche l'empilement des handlers après des reloads successifs
  RT.once("events/backdrop/register", function()
    wezterm.on("backdrop-next",  function(window, pane) cycle(window,  1) end)
    wezterm.on("backdrop-prev",  function(window, pane) cycle(window, -1) end)
    wezterm.on("backdrop-toggle", function(window, pane)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_image then
        clear_backdrop(window)
      else
        -- si on a un dernier fond connu, on le remet; sinon on cycle
        if window.__last_backdrop_path then
          set_backdrop(window, window.__last_backdrop_path)
        else
          cycle(window, 1)
        end
      end
    end)
  end)
end

return M
