-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 安全映射函数：避免覆盖 Lazy 插件系统中已声明的懒加载快捷键
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- 如果 Lazy 已为该快捷键注册了处理函数，则跳过（防止冲突）
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false -- 默认静默执行（不显示命令回显）
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- =============================================================================
-- 🧭 光标移动优化（让 H/L 更符合直觉）
-- =============================================================================
-- 在普通/可视/操作符等待模式下：
--   H → 跳到行首非空白字符（原生 ^）
--   L → 跳到行尾（原生 $）
map({ "n", "v", "o" }, "H", "^", { desc = "Use 'H' as '^' (first non-blank)" })
map({ "n", "v", "o" }, "L", "$", { desc = "Use 'L' as '$' (end of line)" })

-- =============================================================================
-- 🔤 缩进操作（Normal 模式下直接按 < 或 > 即可缩进当前行）
-- =============================================================================
-- 原理：v 选中当前行，<g/>g 执行缩进并返回普通模式
map("n", "<", "v<g", { desc = "Indent current line left" })
map("n", ">", "v>g", { desc = "Indent current line right" })

-- =============================================================================
-- 📑 Buffer（标签页）管理
-- =============================================================================
-- 切换上一个/下一个 buffer（支持 Alt + h/l，插入模式也可用）
map({ "n", "i" }, "<M-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<leader>k", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map({ "n", "i" }, "<M-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<leader>j", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- 关闭窗口 vs 关闭 buffer
map("n", "<leader>D", "<C-W>c", { desc = "Delete current window" }) -- 仅关闭窗口
map("n", "<leader>d", function()
  Snacks.bufdelete() -- LazyVim 封装的智能删除：保留窗口布局，仅关 buffer
end, { desc = "Delete current buffer" })

-- =============================================================================
-- 🪟 窗口大小调整（用方向键直观调整）
-- =============================================================================
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- =============================================================================
-- 📂 快速跳转到常用配置文件（<leader>g = "go to"）
-- =============================================================================
map("n", "<leader>go", "<cmd>e ~/.config/nvim/lua/config/options.lua<cr>", { desc = "Go to Neovim options config" })
map("n", "<leader>gk", "<cmd>e ~/.config/nvim/lua/config/keymaps.lua<cr>", { desc = "Go to keymaps config" })
map("n", "<leader>ga", "<cmd>e ~/.config/nvim/lua/config/autocmds.lua<cr>", { desc = "Go to autocmds config" })
map("n", "<leader>gl", "<cmd>e ~/Documents/Latex/preamble.tex<cr>", { desc = "Go to LaTeX preamble" })
map("n", "<leader>gt", "<cmd>e ~/Documents/Latex/note_template.tex<cr>", { desc = "Go to LaTeX note template" })
map("n", "<leader>gi", "<cmd>e ~/Documents/Latex/latexindent.yaml<cr>", { desc = "Go to latexindent config" })

-- 快速编辑 Luasnip 代码片段
map("n", "<leader>gs", function()
  require("luasnip.loaders").edit_snippet_files({})
end, { desc = "Edit Luasnip snippet files" })

-- =============================================================================
-- 🔍 场景化文件搜索（基于特定目录）
-- 使用 LazyVim 的 Snacks.picker（Telescope 封装）
-- =============================================================================
-- 搜索 ~/.dotfiles 中的文件（含隐藏文件）
map({ "n", "t" }, "<leader>fd", function()
  Snacks.picker.files({ cwd = vim.fn.expand("~/.dotfiles"), hidden = true })
end, { desc = "Find files in ~/.dotfiles" })

-- 搜索家目录
map({ "n", "t" }, "<leader>fh", function()
  Snacks.picker.files({ cwd = vim.fn.expand("~"), hidden = true })
end, { desc = "Find files in home directory" })

-- 搜索插件配置
map({ "n" }, "<leader>fp", function()
  Snacks.picker.files({ cwd = vim.fn.expand("~/.config/nvim/lua/plugins"), hidden = true })
end, { desc = "Find plugin config files" })

-- 搜索自定义工具脚本
map({ "n" }, "<leader>fu", function()
  Snacks.picker.files({ cwd = vim.fn.expand("~/.dotfiles/nvim/.config/nvim/lua/util"), hidden = true })
end, { desc = "Find util config files" })

-- 用 mini.files 打开特定目录（浮动文件管理器）
map("n", "<leader>gL", function()
  require("mini.files").open(vim.fn.expand("~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/"), true)
end, { desc = "Open LazyVim source code" })

map("n", "<leader>gn", function()
  require("mini.files").open(vim.fn.expand("~/Documents/Obsidian-Vault/"), true)
end, { desc = "Open Obsidian Vault" })

-- =============================================================================
-- ✍️ 拼写检查（适用于英文写作、commit message 等）
-- =============================================================================
-- 插入模式下按 Ctrl+d：修正上一个拼写错误
map("i", "<C-d>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix previous spelling error" })

-- 普通模式下按 <Space>h：进入修正流程
map("n", "<leader>h", "a<C-g>u<Esc>[s1z=`]a<C-g>u<Esc>", { desc = "Check and fix spelling" })

-- 普通模式下按 <Space>H：将当前单词加入个人词典（不再报错）
map("n", "<leader>H", "a<C-g>u<Esc>[szg`]a<C-g>u<Esc>", { desc = "Add word to spell dictionary" })

-- =============================================================================
-- ⚙️ 其他实用功能
-- =============================================================================
-- 打开 Lazy 插件管理器
map("n", "<leader>L", "<cmd>:Lazy<cr>", { desc = "Open Lazy plugin manager" })

-- 保存文件（兼容 VS Code 用户习惯）
if vim.g.vscode then
  map("n", "<space>w", "<cmd>w<cr>", { desc = "Save file (VSCode)" })
else
  map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
end

-- 切换终端（依赖 toggleterm.nvim）
map({ "n", "v", "t" }, "<leader>;", "<cmd>ToggleTerm<cr>", { desc = "Toggle floating terminal" })

-- 全选（ggVG = 跳到开头 → 选到结尾）
map({ "n", "v" }, "<leader>a", "ggVG", { desc = "Select all text" })

-- 对光标下的数字加减（如 10 → 11）
map("n", "<leader>+", "<C-a>", { desc = "Increment number under cursor" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number under cursor" })

-- =============================================================================
-- 📝 笔记系统集成（根据文件类型自动分发命令）
-- 支持 LaTeX (.tex) 和 Obsidian Markdown (.md)
-- =============================================================================
-- 根前缀（无实际功能，仅用于菜单分组）
map("n", "<leader>n", "", { desc = "+Note / Obsidian" })

-- 新建笔记
map("n", "<leader>nn", function()
  local ft = vim.bo.filetype
  if ft == "tex" then
    require("util.note").add_note()
  elseif ft == "markdown" then
    require("util.obsidian").add_note_picker()
  else
    return nil
  end
end, { desc = "Add new note" })

-- 查找笔记
map("n", "<leader>nf", function()
  local ft = vim.bo.filetype
  if ft == "tex" then
    require("util.note").find_note()
  elseif ft == "markdown" then
    vim.cmd("ObsidianQuickSwitch")
  end
end, { desc = "Find existing note" })

-- 添加章节（LaTeX）或全文搜索（Obsidian）
map("n", "<leader>ns", function()
  local ft = vim.bo.filetype
  if ft == "tex" then
    require("util.note").add_section()
  elseif ft == "markdown" then
    vim.cmd("ObsidianSearch")
  else
    return nil
  end
end, { desc = "Add section or search notes" })

-- 打开 Markdown frontmatter 中引用的源文件
map("n", "<leader>nO", function()
  local ft = vim.bo.filetype
  if ft == "markdown" then
    require("util.obsidian").open_sources_from_frontmatter()
  else
    vim.notify("Not a markdown file!", vim.log.levels.ERROR)
    return nil
  end
end, { desc = "Open sources from frontmatter" })

-- 将 Markdown 转为知乎格式（自定义转换）
map("n", "<leader>nz", function()
  local ft = vim.bo.filetype
  if ft == "markdown" then
    require("util.zhihu").convert()
  else
    vim.notify("Not a markdown file!", vim.log.levels.ERROR)
    return nil
  end
end, { desc = "Convert Markdown to Zhihu format" })

-- Git: 提交并推送 Obsidian 库
map("n", "<leader>nc", function()
  local ft = vim.bo.filetype
  if ft == "markdown" then
    require("util.obsidian").vault_commit_push()
  else
    vim.notify("Not a markdown file!", vim.log.levels.ERROR)
    return nil
  end
end, { desc = "Commit & push Obsidian vault" })

-- =============================================================================
-- 🔔 通知历史查看
-- =============================================================================
map("n", "<leader>N", function()
  Snacks.notifier.show_history()
end, { desc = "Show notification history" })

-- =============================================================================
-- 💬 可视模式：批量切换 Markdown Callout（引用块）
-- 选中多行后按 <Space>e，每行前加/删 ">"
-- =============================================================================
function _G.toggle_callout()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  for lnum = start_line, end_line do
    local row = lnum - 1
    local lines = vim.api.nvim_buf_get_lines(0, row, row + 1, false)
    if #lines == 0 then
      goto continue
    end
    local line = lines[1]

    local new_line
    if line:sub(1, 1) == ">" then
      new_line = line:sub(2) -- 移除 >
    else
      new_line = ">" .. line -- 添加 >
    end

    vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
    ::continue::
  end
end

map("x", "<leader>e", ":<C-U>lua _G.toggle_callout()<CR><esc>", { desc = "Toggle Markdown callout (>)" })

-- =============================================================================
-- 🚫 禁用 LazyVim 默认快捷键（避免冗余或冲突）
-- =============================================================================
local del = vim.keymap.del
del("n", "<leader>bb") -- 原为打开 buffer 列表
del("n", "<leader>wd") -- 原为关闭其他窗口
del("n", "<leader>l") -- 原为打开 LSP 日志
del("n", "<leader>ft") -- 原为按文件类型搜索
del("n", "<leader>fT") -- 原为按内容搜索（带预览）

-- =============================================================================
-- ✅ 【重要补充】

vim.keymap.set("i", "kj", "<Esc>")
