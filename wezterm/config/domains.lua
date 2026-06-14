-- ~/.config/wezterm/config/domains.lua
local wezterm = require "wezterm"
local M = {}

local function has_wsl_distro(name)
  for _, d in ipairs(wezterm.default_wsl_domains()) do
    if d.name == ("WSL:" .. name) then
      return true
    end
  end
  return false
end

function M.apply(config, _wezterm, platform)
  config.ssh_domains = config.ssh_domains or {}
  config.wsl_domains = config.wsl_domains or {}

  if platform.is_windows and not platform.is_wsl then
    -- Expose toutes les distros
    local wsl = wezterm.default_wsl_domains()
    for _, d in ipairs(wsl) do
      d.default_cwd = d.default_cwd or "~"
      table.insert(config.wsl_domains, d)
    end

    -- Choix du domaine par défaut (avec fallback)
    if has_wsl_distro("kali-linux") then
      config.default_domain = "WSL:kali-linux"
    elseif has_wsl_distro("Ubuntu-22.04") then
      config.default_domain = "WSL:Ubuntu-22.04"
    else
      -- Pas de WSL connu : laisse le domaine par défaut de Windows
      -- (tu peux aussi mettre powershell.exe via launch.lua)
    end
  end
end

return M
