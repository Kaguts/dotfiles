local M = {}

-- cache simple pour éviter plusieurs 'where' lents
local _has_exe_cache = {}
local function has_exe_windows(exe)
  if _has_exe_cache[exe] ~= nil then return _has_exe_cache[exe] end
  local p = io.popen('where ' .. exe .. ' 2> NUL')
  if not p then _has_exe_cache[exe] = false; return false end
  local out = p:read('*a') or ''
  p:close()
  local ok = out:match('[^\r\n]+') ~= nil
  _has_exe_cache[exe] = ok
  return ok
end

local function default_prog_for(platform)
  if platform.is_wsl then
    local shell = os.getenv("SHELL") or "/bin/bash"
    return { shell, "-l" }
  elseif platform.is_windows then
    if has_exe_windows("pwsh.exe") then
      return { "pwsh.exe", "-NoLogo" }
    else
      return { "powershell.exe", "-NoLogo" }
    end
  else
    local shell = os.getenv("SHELL") or "/bin/zsh"
    return { shell, "-l" }
  end
end

function M.apply(config, wezterm, platform)
  config.default_prog = default_prog_for(platform)

  config.launch_menu = {
    { label = "Shell (login)", args = config.default_prog },
    { label = "htop",          args = { "htop" } },
    { label = "btop",          args = { "btop" } },
  }

  if platform.is_windows and not platform.is_wsl then
    table.insert(config.launch_menu, { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } })
    table.insert(config.launch_menu, { label = "cmd.exe",     args = { "cmd.exe" } })
    -- profite de ton default_domain WSL:
    table.insert(config.launch_menu, { label = "WSL: kali-linux", domain = { DomainName = "WSL:kali-linux" } })
  end

  config.default_cwd = "~"
end

return M