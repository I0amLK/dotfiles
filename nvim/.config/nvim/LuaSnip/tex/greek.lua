local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local tex = require("util.latex")

local function ends_with(str, suffix)
  return #str >= #suffix and str:sub(-#suffix) == suffix
end

local function prev_char(line_to_cursor, suffix_len)
  local idx = #line_to_cursor - suffix_len
  if idx <= 0 then
    return ""
  end
  return line_to_cursor:sub(idx, idx)
end

local GREEK_LETTERS = {
  a = "\\alpha",
  b = "\\beta",
  c = "\\chi",
  d = "\\delta",
  e = "\\epsilon",
  ve = "\\varepsilon",
  f = "\\phi",
  vf = "\\varphi",
  g = "\\gamma",
  h = "\\eta",
  i = "\\iota",
  j = "\\varphi",
  k = "\\kappa",
  vk = "\\varkappa",
  l = "\\lambda",
  m = "\\mu",
  n = "\\nu",
  o = "\\omicron",
  p = "\\pi",
  vp = "\\varpi",
  q = "\\theta",
  vq = "\\vartheta",
  r = "\\rho",
  s = "\\sigma",
  vs = "\\varsigma",
  t = "\\tau",
  u = "\\upsilon",
  v = "\\varpi",
  w = "\\omega",
  x = "\\xi",
  y = "\\psi",
  z = "\\zeta",
  A = "\\Alpha",
  B = "\\Beta",
  C = "\\Chi",
  D = "\\Delta",
  E = "\\Epsilon",
  F = "\\Phi",
  G = "\\Gamma",
  H = "\\Eta",
  I = "\\Iota",
  K = "\\Kappa",
  L = "\\Lambda",
  M = "\\Mu",
  N = "\\Nu",
  O = "\\Omicron",
  P = "\\Pi",
  Q = "\\Theta",
  R = "\\Rho",
  S = "\\Sigma",
  T = "\\Tau",
  U = "\\Upsilon",
  W = "\\Omega",
  X = "\\Xi",
  Y = "\\Psi",
  Z = "\\Zeta",
}

local FULL_NAMES = {
  "alpha",
  "beta",
  "chi",
  "delta",
  "epsilon",
  "varepsilon",
  "phi",
  "varphi",
  "gamma",
  "eta",
  "iota",
  "kappa",
  "varkappa",
  "lambda",
  "mu",
  "nu",
  "omicron",
  "pi",
  "varpi",
  "theta",
  "vartheta",
  "rho",
  "sigma",
  "varsigma",
  "tau",
  "upsilon",
  "omega",
  "xi",
  "psi",
  "zeta",
  "Alpha",
  "Beta",
  "Chi",
  "Delta",
  "Epsilon",
  "Phi",
  "Gamma",
  "Eta",
  "Iota",
  "Kappa",
  "Lambda",
  "Mu",
  "Nu",
  "Omicron",
  "Pi",
  "Theta",
  "Rho",
  "Sigma",
  "Tau",
  "Upsilon",
  "Omega",
  "Xi",
  "Psi",
  "Zeta",
  "ket",
  "bra",
  "perp",
}

local VARIANT_MAP = {
  epsilon = "\\varepsilon",
  phi = "\\varphi",
  pi = "\\varpi",
  sigma = "\\varsigma",
  theta = "\\vartheta",
  kappa = "\\varkappa",
}

local snippets = {}

-- 3.1 Full names (alpha -> \alpha). Only triggers when you *didn't* already type a backslash.
for _, name in ipairs(FULL_NAMES) do
  table.insert(
    snippets,
    s({ trig = name, snippetType = "autosnippet", wordTrig = false }, t("\\" .. name), {
      condition = function(line_to_cursor, ...)
        if not tex.in_mathzone(...) then
          return false
        end
        if ends_with(line_to_cursor, "\\\\" .. name) then
          return false
        end
        return prev_char(line_to_cursor, #name) ~= "\\\\"
      end,
    })
  )
end

-- 3.2 Semicolon shortcuts (a; -> \alpha, ve; -> \varepsilon, ...)
for key, value in pairs(GREEK_LETTERS) do
  table.insert(
    snippets,
    s({ trig = key .. ";", snippetType = "autosnippet", wordTrig = false }, t(value), {
      condition = function(line_to_cursor, ...)
        if not tex.in_mathzone(...) then
          return false
        end
        if not ends_with(line_to_cursor, key .. ";") then
          return false
        end
        local pc = prev_char(line_to_cursor, #key + 1)
        return not pc:match("%a")
      end,
    })
  )
end

-- 3.3 Variant helper: \epsilonvar / \epsilon var -> \varepsilon (etc.)
for base, replacement in pairs(VARIANT_MAP) do
  table.insert(snippets, s({ trig = "\\\\" .. base .. "var", snippetType = "autosnippet", wordTrig = false }, t(replacement), { condition = tex.in_mathzone }))
  table.insert(snippets, s({ trig = "\\\\" .. base .. " var", snippetType = "autosnippet", wordTrig = false }, t(replacement), { condition = tex.in_mathzone }))
end

return snippets
