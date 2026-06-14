local wezterm = require "wezterm"

-- meilleur DX: donne un config pré-initialisé et des erreurs plus lisibles
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Base
require("config.options").apply(config, wezterm)

-- Plateforme
local platform = require("config.platform").detect()
require("config.platform").apply(config, wezterm, platform)

-- GPU / WebGPU
require("config.gpu").apply(config, wezterm)

-- UI, domaines, launchers, keymaps
require("config.ui").apply(config, wezterm, platform)
require("config.domains").apply(config, wezterm, platform)
require("config.launch").apply(config, wezterm, platform)
require("config.keys").apply(config, wezterm, platform)

-- (facultatif) Events si tu les utilises
local RT = require("utils").rt
local ev_status = RT.safe_require("events.status"); if ev_status then ev_status.register(config, wezterm, platform) end
local ev_back   = RT.safe_require("events.backdrop"); if ev_back   then ev_back.register(config, wezterm, platform) end

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)

-- Plugins additionnels : pré-clonés en local par wezterm/plugins.sh (utile
-- derrière un proxy, voir wezterm/README.md). `safe_plugin` évite de casser
-- toute la config si un plugin est absent/inaccessible.
local function safe_plugin(url)
  local ok, plugin = pcall(wezterm.plugin.require, url)
  if ok then return plugin end
  require("utils").log.warn("Plugin WezTerm indisponible : " .. url)
  return nil
end

-- Changeur de workspace (LEADER+s, LEADER+Maj+s pour le précédent)
local workspace_switcher = safe_plugin("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
if workspace_switcher then
  table.insert(config.keys, { key = "s", mods = "LEADER",       action = workspace_switcher.switch_workspace() })
  table.insert(config.keys, { key = "s", mods = "LEADER|SHIFT", action = workspace_switcher.switch_to_prev_workspace() })
end

-- Autres plugins pré-clonés mais non activés (décommente pour les essayer ;
-- plusieurs sont des alternatives à smart_workspace_switcher ci-dessus) :
--   wezterm-cmd-sender        : envoie une commande à un pane distant
--   quick_domains.wezterm     : lanceur rapide pour les domaines SSH/WSL
--   workspace-picker.wezterm  : alternative à smart_workspace_switcher
--   sessionizer.wezterm       : alternative façon tmux-sessionizer
--   workspacesionizer.wezterm : alternative à smart_workspace_switcher
--   wezterm-sessions          : sauvegarde/restauration de sessions (panes/tabs/cwd)
-- local cmd_sender        = safe_plugin("https://github.com/aureolebigben/wezterm-cmd-sender")
-- local quick_domains     = safe_plugin("https://github.com/DavidRR-F/quick_domains.wezterm")
-- local workspace_picker  = safe_plugin("https://github.com/isseii10/workspace-picker.wezterm")
-- local sessionizer       = safe_plugin("https://github.com/mikkasendke/sessionizer.wezterm")
-- local workspacesionizer = safe_plugin("https://github.com/vieitesss/workspacesionizer.wezterm")
-- local wezterm_sessions  = safe_plugin("https://github.com/abidibo/wezterm-sessions")

-- log au reload
wezterm.on("cfg-reloaded", function() require("utils").log.info("Configuration rechargée") end)

return config