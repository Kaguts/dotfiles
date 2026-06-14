-- ~/.config/wezterm/config/gpu.lua
local wezterm = require "wezterm"
local M = {}
local U = require "utils"
local LOG = U.log

-- 1) NVIDIA > 2) Discrete > 3) Integrated > 4) Premier
local function pick_adapter()
  if not wezterm.gui then return nil end
  local gpus = wezterm.gui.enumerate_gpus() or {}
  if #gpus == 0 then return nil end

  local nvidia, discrete, integrated
  for _, gpu in ipairs(gpus) do
    local name = (gpu.name or ""):lower()
    if name:find("nvidia") then
      nvidia = gpu
    elseif gpu.device_type == "DiscreteGpu" then
      discrete = discrete or gpu
    elseif gpu.device_type == "IntegratedGpu" then
      integrated = integrated or gpu
    end
  end
  return nvidia or discrete or integrated or gpus[1]
end

function M.apply(config, _wezterm)
  -- On privilégie WebGPU via options.lua (front_end = "WebGpu")

  local adapter = pick_adapter()
  if adapter then
    config.webgpu_preferred_adapter = adapter
    config.webgpu_power_preference = "HighPerformance"
    LOG.info("GPU sélectionné: %s (%s)", adapter.name or "?", adapter.backend or "?")
  else
    LOG.warn("Aucun GPU WebGPU explicite détecté; utilisation des paramètres par défaut")
  end

  -- Tweaks Windows
  if (wezterm.target_triple or ""):find("windows") then
    -- Effet de flou (Windows 11+)
    config.win32_system_backdrop = "Acrylic"
  end
end

return M