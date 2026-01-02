local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta

local tex = require("util.latex")

local function not_in_align(...)
  if type(tex.in_align) == "function" then
    return not tex.in_align(...)
  end
  if type(tex.in_align_math) == "function" then
    return not tex.in_align_math(...)
  end
  return true
end

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

local ARROWS = {
  r = "right",
  R = "Right",
  l = "left",
  L = "Left",
  lr = "leftright",
  Lr = "Leftright",
  u = "up",
  U = "Up",
  d = "down",
  D = "Down",
  ud = "updown",
  Ud = "Updown",
  rr = "longright",
  ll = "longleft",
  RR = "Longright",
  LL = "Longleft",
  se = "se",
  sw = "sw",
  ne = "ne",
  nw = "nw",
}

return {
  -- 2.1 Ellipses
  s({ trig = "...", snippetType = "autosnippet", wordTrig = false }, t("\\cdots "), { condition = tex.in_mathzone }),
  s({ trig = ",,,", snippetType = "autosnippet", wordTrig = false }, t("\\vdots "), { condition = tex.in_mathzone }),
  s({ trig = ":::", snippetType = "autosnippet", wordTrig = false }, t("\\ddots "), { condition = tex.in_mathzone }),

  -- 2.2 limits

  s({ trig = "limd", snippetType = "autosnippet", wordTrig = false }, { t("lim_{"), i(1), t(" \\to "), i(2), t("}"), i(0) }, { condition = tex.in_mathzone }),
  s({ trig = "limsupd", snippetType = "autosnippet", wordTrig = false }, { t("limsup_{"), i(1), t(" \\to "), i(2), t("}"), i(0) }, { condition = tex.in_mathzone }),
  s({ trig = "liminfd", snippetType = "autosnippet", wordTrig = false }, { t("liminf_{"), i(1), t(" \\to "), i(2), t("}"), i(0) }, { condition = tex.in_mathzone }),

  -- 2.3 Calculus helpers
  s({ trig = "oo", snippetType = "autosnippet", wordTrig = false }, t("\\infty"), { condition = tex.in_mathzone }),

  -- 2.4 Arrows

  s({ trig = "iA;", snippetType = "autosnippet", wordTrig = false }, t("\\implies "), { condition = tex.in_mathzone }),
  s({ trig = "fa;", snippetType = "autosnippet", wordTrig = false }, t("\\iff "), { condition = tex.in_mathzone }),
  s({ trig = "to;", snippetType = "autosnippet", wordTrig = false }, t("\\to "), { condition = tex.in_mathzone }),
  s({ trig = "la;", snippetType = "autosnippet", wordTrig = false }, t("\\leftarrow "), { condition = tex.in_mathzone }),
  s({ trig = "da;", snippetType = "autosnippet", wordTrig = false }, t("\\downarrow "), { condition = tex.in_mathzone }),
  s({ trig = "ua;", snippetType = "autosnippet", wordTrig = false }, t("\\uparrow "), { condition = tex.in_mathzone }),
  s({ trig = "lr;", snippetType = "autosnippet", wordTrig = false }, t("\\leftrightarrow "), { condition = tex.in_mathzone }),

  -- 2.5 Relations & comparisons
  s({ trig = ">=", snippetType = "autosnippet", wordTrig = false }, t("\\geq "), { condition = tex.in_mathzone }),
  s({ trig = "<=", snippetType = "autosnippet", wordTrig = false }, t("\\leq "), { condition = tex.in_mathzone }),
  s({ trig = "<<", snippetType = "autosnippet", wordTrig = false }, t("\\ll "), { condition = tex.in_mathzone }),
  s({ trig = ">>", snippetType = "autosnippet", wordTrig = false }, t("\\gg "), { condition = tex.in_mathzone }),
  s({ trig = "<~", snippetType = "autosnippet", wordTrig = false }, t("\\lesssim "), { condition = tex.in_mathzone }),
  s({ trig = ">~", snippetType = "autosnippet", wordTrig = false }, t("\\gtrsim "), { condition = tex.in_mathzone }),

  -- 2.6 Binary operators
  s({ trig = "==", snippetType = "autosnippet", wordTrig = false }, t("\\equiv "), {
    condition = function(...)
      return tex.in_mathzone(...) and not_in_align(...)
    end,
  }),
  s({ trig = "OO", snippetType = "autosnippet", wordTrig = false }, t("\\cdot "), { condition = tex.in_mathzone }),
  s({ trig = "~~", snippetType = "autosnippet", wordTrig = false }, t("\\sim "), { condition = tex.in_mathzone }),
  s({ trig = "NN", snippetType = "autosnippet", wordTrig = false }, t("\\cap "), { condition = tex.in_mathzone }),
  s({ trig = "UU", snippetType = "autosnippet", wordTrig = false }, t("\\cup "), { condition = tex.in_mathzone }),
  s({ trig = "II", snippetType = "autosnippet", wordTrig = false }, t("\\in "), { condition = tex.in_mathzone }),
  s({ trig = "XX", snippetType = "autosnippet", wordTrig = false }, t("\\times "), { condition = tex.in_mathzone }),
  s({ trig = "OP", snippetType = "autosnippet", wordTrig = false }, t("\\oplus "), { condition = tex.in_mathzone }),
  s({ trig = "omo", snippetType = "autosnippet", wordTrig = false }, t("\\ominus "), { condition = tex.in_mathzone }),
  s({ trig = "oco", snippetType = "autosnippet", wordTrig = false }, t("\\propto "), { condition = tex.in_mathzone }),
  s({ trig = "OX", snippetType = "autosnippet", wordTrig = false }, t("\\otimes "), { condition = tex.in_mathzone }),

  -- 2.7 Miscellaneous operators & delimiters
  s({ trig = "sq", snippetType = "autosnippet", wordTrig = false }, fmta("\\sqrt{<>}<>", { i(1), i(0) }), { condition = tex.in_mathzone }),
  s({ trig = "AA", snippetType = "autosnippet", wordTrig = false }, t("\\forall "), { condition = tex.in_mathzone }),
  s({ trig = "EE", snippetType = "autosnippet", wordTrig = false }, t("\\exists "), { condition = tex.in_mathzone }),

  s({ trig = "abs", snippetType = "autosnippet", wordTrig = false }, fmta("\\left|<>\\right|<>", { i(1), i(0) }), { condition = tex.in_mathzone }),
  s({ trig = "||", snippetType = "autosnippet", wordTrig = false }, fmta("\\left|<>\\right|<>", { i(1), i(0) }), { condition = tex.in_mathzone }),

  s({ trig = "!=", snippetType = "autosnippet", wordTrig = false }, t("\\not ="), { condition = tex.in_mathzone }),

  s({ trig = "<>", snippetType = "autosnippet", wordTrig = false }, fmta("\\langle <> \\rangle<>", { i(1), i(0) }), { condition = tex.in_mathzone }),
}
