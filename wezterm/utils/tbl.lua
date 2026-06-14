-- Utilitaires de table : clone, merge, defaults, etc.
local M = {}

-- Détecte si une table est une liste (indices 1..n sans trous)
function M.is_list(t)
  if type(t) ~= "table" then return false end
  local n = #t
  local c = 0
  for k, _ in pairs(t) do
    if type(k) == "number" and k >= 1 and k <= n and math.floor(k) == k then
      c = c + 1
    else
      return false
    end
  end
  return c == n
end

-- Copie profonde (protégée contre les cycles)
local function _clone(t, seen)
  if type(t) ~= "table" then return t end
  if seen[t] then return seen[t] end
  local out = {}
  seen[t] = out
  for k, v in pairs(t) do
    out[_clone(k, seen)] = _clone(v, seen)
  end
  -- On ne copie pas les metatables par défaut (plus sûr pour config)
  return out
end

function M.clone(t)
  return _clone(t, {})
end

-- Concatène deux listes (copie)
local function concat_lists(a, b)
  local out = {}
  for i = 1, #a do out[#out + 1] = a[i] end
  for i = 1, #b do out[#out + 1] = b[i] end
  return out
end

-- Merge profonde (right-bias) : b écrase a
-- Règle : si a et b sont **listes**, on concatène (au lieu d'écraser)
function M.merge(a, b)
  if type(a) ~= "table" then a = {} end
  if type(b) ~= "table" then return M.clone(a) end

  if M.is_list(a) and M.is_list(b) then
    return concat_lists(a, b)
  end

  local out = M.clone(a)
  for k, v in pairs(b) do
    if type(v) == "table" and type(out[k]) == "table" and not (M.is_list(out[k]) or M.is_list(v)) then
      out[k] = M.merge(out[k], v)
    else
      out[k] = M.clone(v)
    end
  end
  return out
end

-- Merge de plusieurs tables (right-bias de gauche à droite)
function M.merge_all(...)
  local args = { ... }
  local out = {}
  for i = 1, #args do
    out = M.merge(out, args[i])
  end
  return out
end

-- Assigne des valeurs par défaut (left-bias) : a garde ses valeurs
function M.defaults(a, defaults)
  if type(a) ~= "table" then a = {} end
  if type(defaults) ~= "table" then return a end
  for k, v in pairs(defaults) do
    if a[k] == nil then
      a[k] = M.clone(v)
    elseif type(a[k]) == "table" and type(v) == "table" and not (M.is_list(a[k]) or M.is_list(v)) then
      M.defaults(a[k], v)
    end
  end
  return a
end

-- Vérifie la présence d'une clé (non-nil)
function M.has(tbl, key)
  return type(tbl) == "table" and tbl[key] ~= nil
end

-- Map / Filter / Reduce
function M.map(list, fn)
  local out = {}
  for i, v in ipairs(list or {}) do out[i] = fn(v, i) end
  return out
end

function M.filter(list, fn)
  local out = {}
  for _, v in ipairs(list or {}) do if fn(v) then out[#out + 1] = v end end
  return out
end

function M.reduce(list, fn, init)
  local acc = init
  for i, v in ipairs(list or {}) do
    if i == 1 and acc == nil then acc = v else acc = fn(acc, v, i) end
  end
  return acc
end

-- Raccourcis utilitaires
function M.keys(t)
  local out = {}
  for k, _ in pairs(t or {}) do out[#out + 1] = k end
  return out
end

function M.values(t)
  local out = {}
  for _, v in pairs(t or {}) do out[#out + 1] = v end
  return out
end

return M
