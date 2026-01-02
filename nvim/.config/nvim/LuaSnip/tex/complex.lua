local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta

local tex = require("util.latex")

local PREFIX_WRAPPERS = {
  bar = { "\\overline{", "}" },
  fn = { "\\overset{\\frown}{", "}" },
  td = { "\\widetilde{", "}" },
  rm = { "\\mathrm{", "}" },
  hat = { "\\hat{", "}" },
  cr = { "\\mathscr{", "}" },
  bav = { "\\hat{\\boldsymbol{", "}}" },
  vec = { "\\vec{", "}" },
  bm = { "\\boldsymbol{", "}" },
  bf = { "\\mathbf{", "}" },
  cal = { "\\mathcal{", "}" },
  mtb = { "\\mathbb{", "}" },
  op = { "\\operatorname{", "}" },
  fk = { "\\mathfrak{", "}" },
}

return {

  -- Text-mode helper: promote lone letter to inline math (mirrors hypersnips). Frontiers ensure single-letter word.
  s(
    {
      trig = [[([^'])%f[%a]([A-Za-z])%f[%A]([%s%.,])]],
      regTrig = true,
      trigEngine = "pattern",
      wordTrig = false,
      snippetType = "autosnippet",
      priority = 100,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\(" .. snip.captures[2] .. "\\)" .. snip.captures[3]
    end),
    {
      condition = function(_, _, caps)
        return tex.in_text() and not caps[2]:match("^[aAI]$")
      end,
    }
  ),

  -- Math-mode: auto subscript helpers

  -- Debug: manual expansion to inspect captures of prefix regex (vim regex, no condition)
  s(
    {
      trig = [[\%(^\|[^_^\\]\)\zs\(\d*\%\(\a\+\|\\\a\+\)\)\s*\(bar\|fn\|td\|rm\|hat\|cr\|bav\|vec\|bm\|bf\|cal\|mtb\|fk\|op\)]],
      regTrig = true,
      trigEngine = "vim",
      wordTrig = false,
      snippetType = "snippet",
      priority = 149,
      name = "prefix-regex-debug",
      dscr = "Show captures for prefix wrapper regex",
    },
    f(function(_, snip)
      return string.format("[prev+base:%s|key:%s]", snip.captures[1] or "", snip.captures[2] or "")
    end)
  ),

  -- Debug: function wrapper test without regex (no condition to simplify testing)
  s(
    { trig = [[([A-Za-z])(%d)]], regTrig = true, trigEngine = "pattern", snippetType = "autosnippet" },
    f(function(_, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = [[([A-Za-z])_(%d%d)]], regTrig = true, trigEngine = "pattern", snippetType = "autosnippet", priority = 100 },
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
    { condition = tex.in_mathzone }
  ),

  s(
    {
      trig = [[\%('^'\|[^\\]\)\zs\([A-Za-z}]\)\([A-Za-z]\)\2]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
    },
    f(function(_, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end),
    { condition = tex.in_mathzone }
  ),

  s(
    {
      trig = [[\%('^'\|[^\\]\)\zs\([A-Za-z]\)\(_[A-Za-z]\{2,}\)]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
      priority = 10000,
    },
    f(function(_, snip)
      local letters = snip.captures[2]
      return snip.captures[1] .. "_{" .. letters:sub(2) .. "}"
    end),
    { condition = tex.in_mathzone }
  ),

  -- Math-mode: power/subscript blocks
  s(
    {
      trig = [[\%((math\|\\)\)\@<!pw]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
    },
    { t("^{"), i(1), t("}"), i(0) },
    { condition = tex.in_mathzone }
  ),

  s(
    {
      trig = [[\%((math\|\\)\)\@<!sc]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
    },
    { t("_{"), i(1), t("}"), i(0) },
    { condition = tex.in_mathzone }
  ),

  -- Math-mode: smart fraction (captures numerator before / and wraps in \frac)
  s(
    {
      trig = [[\%(^\|[^\\]\)\zs\(\%\(\d\+\|\d*[A-Za-z\\][A-Za-z]*\)\%\(\%([\^_]\)\%({\w\+}\|\w\)\|'\)*\)/]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
      priority = 10,
    },
    {
      f(function(_, snip)
        return "\\frac{" .. snip.captures[1] .. "}{"
      end),
      i(1),
      t("}"),
    },
    { condition = tex.in_mathzone }
  ),

  -- Math-mode: prefix wrappers (xbar -> \overline{x}, etc.)
  s(
    {
      trig = [[\%([^_^]\|^\)\zs\(\d\+\|\d*\%([A-Za-z]\+\|\\\%(alpha\|beta\|chi\|delta\|epsilon\|varepsilon\|phi\|varphi\|gamma\|eta\|iota\|kappa\|varkappa\|lambda\|mu\|nu\|omicron\|pi\|varpi\|theta\|vartheta\|rho\|sigma\|varsigma\|tau\|upsilon\|omega\|xi\|psi\|zeta\|Alpha\|Beta\|Chi\|Delta\|Epsilon\|Phi\|Gamma\|Eta\|Iota\|Kappa\|Lambda\|Mu\|Nu\|Omicron\|Pi\|Theta\|Rho\|Sigma\|Tau\|Upsilon\|Omega\|Xi\|Psi\|Zeta\)[ ]\?\)\)\%(\\\)\@<!\(bar\|fn\|td\|rm\|hat\|cr\|bav\|vec\|bm\|bf\|cal\|mtb\|fk\|op\)]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
    },
    f(function(_, snip)
      local base = snip.captures[1]
      local key = snip.captures[2]
      local wrap = PREFIX_WRAPPERS[key]
      if wrap then
        return wrap[1] .. base .. wrap[2]
      end
      return base .. key
    end),
    { condition = tex.in_mathzone }
  ),

  -- Math-mode: roman operators (Hom, End, Aut, etc.)
  s(
    {
      trig = [[\(Hom\|End\|Aut\|Gal\|Spec\|Sch\|Proj\|GL\|SL\|PGL\|PSL\|Sp\|Tr\)]],
      regTrig = true,
      trigEngine = "vim",
      snippetType = "autosnippet",
    },
    f(function(_, snip)
      return "\\operatorname{" .. snip.captures[1] .. "}"
    end),
    { condition = tex.in_mathzone }
  ),
}
