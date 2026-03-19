local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local tex = require("util.latex")

local function prev_char(line_to_cursor, trigger_len)
  local idx = #line_to_cursor - trigger_len
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

local GREEK_COMMAND_SET = {
  alpha = true,
  beta = true,
  chi = true,
  delta = true,
  epsilon = true,
  varepsilon = true,
  phi = true,
  varphi = true,
  gamma = true,
  eta = true,
  iota = true,
  kappa = true,
  varkappa = true,
  lambda = true,
  mu = true,
  nu = true,
  omicron = true,
  pi = true,
  varpi = true,
  theta = true,
  vartheta = true,
  rho = true,
  sigma = true,
  varsigma = true,
  tau = true,
  upsilon = true,
  omega = true,
  xi = true,
  psi = true,
  zeta = true,

  Alpha = true,
  Beta = true,
  Chi = true,
  Delta = true,
  Epsilon = true,
  Phi = true,
  Gamma = true,
  Eta = true,
  Iota = true,
  Kappa = true,
  Lambda = true,
  Mu = true,
  Nu = true,
  Omicron = true,
  Pi = true,
  Theta = true,
  Rho = true,
  Sigma = true,
  Tau = true,
  Upsilon = true,
  Omega = true,
  Xi = true,
  Psi = true,
  Zeta = true,
}

local function greek_numeric_condition(line_to_cursor, matched_trigger, captures)
  if not tex.in_mathzone(line_to_cursor, matched_trigger, captures) then
    return false
  end
  if not captures or not captures[1] then
    return false
  end
  local cmd = captures[1]:sub(2) -- remove leading backslash
  return GREEK_COMMAND_SET[cmd] == true
end

local snippets = {}

-- 1. Full names: alpha -> \alpha
for _, name in ipairs(FULL_NAMES) do
  table.insert(
    snippets,
    s(
      {
        trig = name,
        snippetType = "autosnippet",
        wordTrig = true,
      },
      t("\\" .. name),
      {
        condition = function(line_to_cursor, ...)
          return tex.in_mathzone(...) and prev_char(line_to_cursor, #name) ~= "\\"
        end,
      }
    )
  )
end

-- 2. Semicolon shortcuts: a; -> \alpha
for key, value in pairs(GREEK_LETTERS) do
  table.insert(
    snippets,
    s(
      {
        trig = key .. ";",
        snippetType = "autosnippet",
        wordTrig = false,
      },
      t(value),
      {
        condition = function(line_to_cursor, ...)
          if not tex.in_mathzone(...) then
            return false
          end
          local pc = prev_char(line_to_cursor, #key + 1)
          return pc == "" or not pc:match("[%a\\]")
        end,
      }
    )
  )
end

-- 3. Variant helpers
for base, replacement in pairs(VARIANT_MAP) do
  table.insert(
    snippets,
    s({
      trig = "\\" .. base .. "var",
      snippetType = "autosnippet",
      wordTrig = false,
    }, t(replacement), { condition = tex.in_mathzone })
  )

  table.insert(
    snippets,
    s({
      trig = "\\" .. base .. " var",
      snippetType = "autosnippet",
      wordTrig = false,
    }, t(replacement), { condition = tex.in_mathzone })
  )
end

-- 4. \alpha1 -> \alpha_1
table.insert(
  snippets,
  s(
    {
      trig = [[(\%a+)(%d)]],
      regTrig = true,
      trigEngine = "pattern",
      wordTrig = false,
      snippetType = "autosnippet",
      priority = 200,
    },
    f(function(_, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end),
    { condition = greek_numeric_condition }
  )
)

-- 5. \alpha_12 -> \alpha_{12}
table.insert(
  snippets,
  s(
    {
      trig = [[(\%a+)_(%d%d+)]],
      regTrig = true,
      trigEngine = "pattern",
      wordTrig = false,
      snippetType = "autosnippet",
      priority = 210,
    },
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
    { condition = greek_numeric_condition }
  )
)

return snippets
