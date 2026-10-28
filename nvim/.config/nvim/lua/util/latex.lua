local M = {}

local NODE_CONTEXTS = {
  displayed_equation = "math",
  inline_formula = "math",
  math_environment = "math",
  math = "math", -- Typst
  text_mode = "text",
  line_comment = "literal",
  block_comment = "literal",
  comment_environment = "literal",
  verbatim_environment = "literal",
  source_code = "literal",
  code_span = "literal",
  fenced_code_block = "literal",
  indented_code_block = "literal",
  curly_group_label = "literal",
  curly_group_label_list = "literal",
  curly_group_uri = "literal",
  curly_group_path = "literal",
  curly_group_path_list = "literal",
}

local function node_at_cursor(pos, ignore_injections)
  local ok, node = pcall(function()
    local ft = vim.bo.filetype
    local lang = (ft == "tex" or ft == "plaintex" or ft == "latex") and "latex" or nil
    local parser = vim.treesitter.get_parser(0, lang)
    if not parser then
      return nil
    end
    -- Also refresh Markdown's injected LaTeX trees, without requiring highlighting.
    local row = pos and pos[1] or (vim.api.nvim_win_get_cursor(0)[1] - 1)
    parser:parse({ row, row + 1 })
    return vim.treesitter.get_node({ pos = pos, lang = lang, ignore_injections = ignore_injections or false })
  end)
  if ok then
    return node
  end
  return nil
end

-- Literal arguments are neither prose nor math. In particular, do not run
-- the prose snippet that wraps single letters in inline math inside names.
local SYNTAX_CONTEXTS = {
  literal = {
    "^texOpnameArg",
    "^texDeclmathoperArg",
    "^texRef.*Arg",
    "^texBibitemArg",
    "^texComment",
    "^texVerbZone",
    "^texLstZone",
    "^texMintedZone",
    "^texUrlArg",
    "^texHrefArgLink",
    "^texHyperrefLink",
    "^texFiles?Arg",
    "^texFiles?Opt",
    "^texEnvArgName",
    "^texMathEnvArgName",
  },
  text = {
    "^texMathText",
    "^texMathTag",
    "^texRef.*Opt",
    "^texStyle",
    "^texHrefArgText",
    "^texHyperrefText",
    "^texFootnoteArg",
  },
  math = { "^texMathZone" },
}

local function vimtex_context()
  if not vim.b.vimtex_syntax or vim.b.current_syntax ~= "tex" then
    return nil
  end
  local ok, stack = pcall(vim.fn["vimtex#syntax#stack"])
  if not ok then
    return nil
  end
  local context
  for i = #stack, 1, -1 do
    for kind, patterns in pairs(SYNTAX_CONTEXTS) do
      for _, pattern in ipairs(patterns) do
        if stack[i]:match(pattern) then
          -- Literal content stays literal even inside nested formatting.
          if kind == "literal" then
            return kind
          end
          -- Otherwise the innermost text/math boundary wins: e.g. \text{$x$}.
          context = context or kind
          break
        end
      end
    end
  end
  -- Respect extra exclusions registered by VimTeX packages or user macros.
  if context == "math" and vim.fn["vimtex#syntax#in_mathzone"]() == 0 then
    return "literal"
  end
  return context or "text"
end

-- Tree-sitter fallback for Markdown/Typst or TeX without VimTeX syntax.
local ARG_CONTEXTS = {}
for kind, commands in pairs({
  math = "ensuremath",
  literal = "operatorname",
  text = "text textnormal textrm textup texttt textsf textsc textbf textit textmd textsl mbox hbox fbox intertext shortintertext footnote footnotetext tag",
}) do
  for command in commands:gmatch("%S+") do
    ARG_CONTEXTS["\\" .. command] = kind
  end
end

-- The LaTeX parser does not give \verb a verbatim node. Recognize its
-- same-line delimiter explicitly, but only at parsed LaTeX command nodes.
local function in_inline_verb(row, col)
  local line = vim.api.nvim_get_current_line()
  local offset = 1
  while offset <= col do
    local first, last = line:find("\\verb%*?", offset)
    if not first or first > col then
      break
    end
    local delimiter = line:sub(last + 1, last + 1)
    local command = node_at_cursor({ row, first })
    if
      command
      and command:type() == "command_name"
      and vim.treesitter.get_node_text(command, 0):match("^\\verb%*?$")
      and delimiter ~= ""
      and not delimiter:match("[%a%s]")
    then
      local close = line:find(delimiter, last + 2, true)
      if col >= last + 1 and (not close or col < close) then
        return true
      end
      offset = close and (close + 1) or (#line + 1)
    else
      offset = last + 1
    end
  end
  return false
end

local function treesitter_context()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local pos = { row, math.max(col - 1, 0) }
  if vim.bo.filetype == "markdown" then
    local outer = node_at_cursor(pos, true)
    while outer do
      -- An injected language inside a code fence is still literal content.
      if NODE_CONTEXTS[outer:type()] == "literal" then
        return "literal"
      end
      outer = outer:parent()
    end
  end
  local node = node_at_cursor(pos)
  if not node then
    -- Unknown syntax must not enable either prose or math autosnippets.
    return "literal"
  end
  if vim.bo.filetype ~= "typst" and in_inline_verb(row, col) then
    return "literal"
  end
  local context
  while node do
    local kind = NODE_CONTEXTS[node:type()]
    local parent = node:parent()
    if
      parent
      and node:type() == "curly_group"
      and parent:type() == "generic_command"
      and parent:field("arg")[1] == node
    then
      local command = parent:field("command")[1]
      local name = command and vim.treesitter.get_node_text(command, 0):gsub("%*$", "")
      kind = ARG_CONTEXTS[name]
    elseif parent and parent:type() == "hyperlink" and parent:field("label")[1] == node then
      kind = "text"
    elseif parent and node:type() == "curly_group_text_list" and parent:type() == "citation" then
      kind = "literal"
    end
    local _, _, end_row, end_col = node:range()
    -- At an insertion point after a closing delimiter, that region has ended.
    if node:type() ~= "line_comment" and (end_row < row or (end_row == row and end_col <= col)) then
      kind = nil
    end
    if kind == "literal" then
      return kind
    end
    context = context or kind
    if node:type() == "ERROR" then
      -- Without syntax support, avoid expanding on an ambiguous, unfinished parse.
      return context or "literal"
    end
    node = parent
  end
  return context or "text"
end

local function vimtex_env_is_inside(env)
  if vim.fn.exists("*vimtex#env#is_inside") == 1 then
    local ok, pos = pcall(vim.fn["vimtex#env#is_inside"], env)
    if ok and type(pos) == "table" then
      return (pos[1] ~= 0) or (pos[2] ~= 0)
    end
  end
  return false
end

M.in_env_md = function(env)
  local node = node_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  while node do
    if node:type() == "generic_environment" then
      local begin = node:child(0)
      if begin then
        local name = begin:field("name")
        if name and name[1] then
          local text = vim.treesitter.get_node_text(name[1], bufnr)
          if text == "{" .. env .. "}" then
            return true
          end
        end
      end
    end
    node = node:parent()
  end
  return false
end

M.in_env = function(env)
  return vimtex_env_is_inside(env)
end

M.in_mathzone_md = function()
  return treesitter_context() == "math"
end

M.in_text_md = function()
  return treesitter_context() == "text"
end

M.in_mathzone_typ = function()
  return treesitter_context() == "math"
end

M.context = function()
  local ft = vim.bo.filetype
  if ft == "tex" or ft == "plaintex" or ft == "latex" then
    return vimtex_context() or treesitter_context()
  elseif ft == "markdown" or ft == "typst" then
    return treesitter_context()
  end
  return "text"
end

M.in_mathzone = function()
  return M.context() == "math"
end

M.in_text = function()
  return M.context() == "text"
end

M.in_item = function()
  return M.in_env("itemize") or M.in_env("enumerate")
end
M.in_bib = function()
  return M.in_env("thebibliography")
end
M.in_tikz = function()
  return M.in_env("tikzpicture")
end
M.in_quantikz = function()
  return M.in_env("quantikz")
end
M.in_algo = function()
  return M.in_env("algorithmic")
end

M.in_matrix = function()
  return M.in_env("matrix")
    or M.in_env("pmatrix")
    or M.in_env("bmatrix")
    or M.in_env("Bmatrix")
    or M.in_env("vmatrix")
    or M.in_env("Vmatrix")
    or M.in_env("smallmatrix")
end

-- M.clean = function()
--   local current_dir = vim.fn.expand("%:p:h")
--   local file_types = { "aux", "log", "out", "fls", "fdb_latexmk", "bcf", "run.xml", "toc", "DS_Store", "bak*", "dvi" }
--   for _, file_type in ipairs(file_types) do
--     local command = "rm " .. current_dir .. "/*." .. file_type
--     vim.api.nvim_call_function("system", { command })
--   end
-- end
--
-- M.format = function()
--   local current_file = vim.fn.expand("%:p")
--   local latexindent = "latexindent -g /dev/null " .. current_file .. " -wd -l ~/Documents/Latex/latexindent.yaml"
--   local build = "pdflatex " .. current_file
--   vim.api.nvim_call_function("system", { build })
--   vim.cmd("w")
--   M.clean()
--   vim.api.nvim_call_function("system", { latexindent })
--   vim.cmd("e")
--   vim.cmd("normal! zz")
--   -- vim.cmd("TexlabForward")
-- end
--
-- M.sympy_calc = function()
--   local selected_text = vim.fn.getreg("v")
--   print(selected_text)
--   vim.api.nvim_out_write(selected_text)
-- end

return M
