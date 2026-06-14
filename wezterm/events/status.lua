local wezterm = require "wezterm"
local U = require "utils"
local RT = U.rt

local M = {}

-- --- Glyphes (remplace par tes préférés si nécessaire) -----------------------
local function glyphs()
  return {
    clock   = "󰥔 ",  -- ou "🕒 "
    host    = "󰒋 ",
    folder  = " ",
    battery = "󰁹 ",
    plug    = " ",
    zoom    = "󰁌 ",
    wspace  = "󰙱 ",
    linux   = " ", windows = " ", mac = " ", wsl = " ",
    sep     = " | ",
  }
end

-- --- Couleur : prend celle du thème si dispo, sinon fallback -----------------
local function pick_fg(window)
  local eff = window:effective_config() or {}
  local pal = eff.resolved_palette or {}
  local tab = (pal.tab_bar or {}).active_tab or {}
  return tab.fg_color or pal.foreground or "#c0caf5"
end

-- Largeur approximative (compat si column_width n’existe pas)
local function width_of(s)
  if type(wezterm.column_width) == "function" then
    return wezterm.column_width(s or "")
  end
  return #(s or "")
end

-- --- Segments ----------------------------------------------------------------
local function seg_platform(platform)
  local g = glyphs()
  local icon = platform.is_wsl and g.wsl
    or (platform.is_macos and g.mac
      or (platform.is_windows and g.windows or g.linux))
  local label = platform.label
    or (platform.is_wsl and "WSL"
      or platform.is_windows and "Windows"
      or platform.is_macos and "macOS" or "Linux")
  return { long = icon .. label, medium = icon, short = icon, prio = 5 }
end

local function seg_workspace()
  local g = glyphs()
  local ws = wezterm.mux.get_active_workspace() or "default"
  return { long = g.wspace .. ws, medium = ws, short = ws:sub(1,3), prio = 4 }
end

local function seg_cwd(pane)
  local g = glyphs()
  local url = pane:get_current_working_dir()
  local p = url and url.file_path or nil
  if not p or p == "" then return { long="", medium="", short="", prio=-1 } end
  p = p:gsub("^" .. (wezterm.home_dir or ""), "~")
  local base = p:match("([^/\\]+)$") or p
  return { long = g.folder .. p, medium = g.folder .. base, short = base:sub(1, 12), prio = 3 }
end

local function seg_zoom(window)
  if not window:active_pane():is_zoomed() then return { long="", medium="", short="", prio=-1 } end
  local g = glyphs()
  return { long = g.zoom .. "ZOOM", medium = g.zoom .. "Z", short = "Z", prio = 2 }
end

local function seg_battery()
  local g = glyphs()
  local bi = wezterm.battery_info()
  if not bi or not bi[1] then return { long="", medium="", short="", prio=-1 } end
  local b = bi[1]
  local pct = math.floor((b.state_of_charge or 0) * 100 + 0.5)
  local icon = (b.state == "Charging") and g.plug or g.battery
  return { long = string.format("%s%d%%", icon, pct), medium = string.format("%d%%", pct), short = tostring(pct), prio = 1 }
end

local function seg_hostname()
  local g = glyphs()
  local h = wezterm.hostname() or "host"
  return { long = g.host .. h, medium = h:gsub("%..*$",""), short = h:sub(1,3), prio = 6 }
end

local function seg_clock()
  local g = glyphs()
  return {
    long   = g.clock .. wezterm.strftime("%a %d %b %H:%M"),
    medium = g.clock .. wezterm.strftime("%H:%M"),
    short  = wezterm.strftime("%H:%M"),
    prio   = 7,  -- on garde l'heure autant que possible
  }
end

-- --- Sélection des versions selon la largeur ---------------------------------
local function choose_versions(segments, max_cols)
  table.sort(segments, function(a,b) return (a.prio or 0) > (b.prio or 0) end)
  local sep, chosen, used = glyphs().sep, {}, 0
  local sep_w = width_of(sep)

  for _, seg in ipairs(segments) do
    if (seg.prio or 0) >= 0 then
      local candidate, w = seg.long, width_of(seg.long)
      if used + w > max_cols then
        candidate, w = seg.medium, width_of(seg.medium)
      end
      if used + w > max_cols then
        candidate, w = seg.short, width_of(seg.short)
      end
      if candidate and candidate ~= "" and used + w <= max_cols then
        table.insert(chosen, candidate)
        used = used + w + (used > 0 and sep_w or 0)
      end
    end
  end
  return chosen
end

-- --- Enregistrement de l’event (protégé contre les doubles) ------------------
function M.register(_, _wz, platform)
  RT.once("events/status/responsive", function()
    wezterm.on("update-right-status", function(window, pane)
      local dims = window:get_dimensions() or {}
      local cols = dims.cols or 120

      local segs = {
        seg_platform(platform),
        seg_workspace(),
        seg_cwd(pane),
        seg_zoom(window),
        seg_battery(),
        seg_hostname(),
        seg_clock(),
      }

      local chosen = choose_versions(segs, math.max(10, cols - 2))
      local text = table.concat(chosen, glyphs().sep)
      local fg = pick_fg(window)

      window:set_right_status(wezterm.format({
        { Foreground = { Color = fg } },
        { Text = " " .. text .. " " },
      }))
    end)
  end)
end

return M
