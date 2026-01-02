local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
local tex = require("util.latex")
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, t(parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local snippets = {
  s(
    { trig = "i-", snippetType = "autosnippet" },
    fmta(
      [[
      \(<>\)
      ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "d-", snippetType = "autosnippet" },
    fmta(
      [[
      \[
        <>
      \]
      ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "bff", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{proof}
        <>
      \end{proof}
      ]],
      {
        i(0),
      }
    ),
    { condition = line_begin * tex.in_text }
  ),
  s(
    { trig = "beg", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{<>}[<>]
        <>
      \end{<>}
      ]],
      {
        i(1),
        i(2),
        i(0),
        rep(1),
      }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = "ben", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{enumerate}[<>]
        \item <>
      \end{enumerate}
      ]],
      {
        i(1, "(a)"),
        i(0),
      }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = "case", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{cases}
        <>
      \end{cases}
      ]],
      {
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bal", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{aligned}
        <>
      \end{aligned}
      ]],
      {
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bal", snippetType = "autosnippet", priority = 2000 },
    fmta(
      [[
      \begin{aligned}
        <>
      \end{aligned}
      ]],
      {
        d(1, get_visual),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bit", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{itemize}
        \item <>
      \end{itemize}
      ]],
      {
        i(0),
      }
    ),
    { condition = line_begin }
  ),
  s({ trig = "im", snippetType = "autosnippet" }, {
    t("\\item"),
  }, { condition = tex.in_item * line_begin }),
  s(
    { trig = "\\item(%d)", regTrig = true, trigEngine = "pattern", snippetType = "autosnippet" },
    fmta([[\item<<<>->>]], {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_item * line_begin }
  ),
  s(
    { trig = "bcr", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{center}
        <>
      \end{center}
      ]],
      {
        i(0),
      }
    ),
    { condition = line_begin }
  ),
}

-- If your LuaSnip config only loads this file (env.lua),
-- automatically merge in all sibling snippet files so everything works.
local function extend_with_siblings()
  local this = debug.getinfo(1, "S").source
  if type(this) ~= "string" or this:sub(1, 1) ~= "@" then
    return
  end

  local this_path = this:sub(2)
  local dir = vim.fn.fnamemodify(this_path, ":h")
  local files = vim.fn.globpath(dir, "*.lua", false, true)

  for _, file in ipairs(files) do
    if file ~= this_path then
      local ok, mod = pcall(dofile, file)
      if ok and type(mod) == "table" then
        vim.list_extend(snippets, mod)
      end
    end
  end
end

extend_with_siblings()

return snippets
