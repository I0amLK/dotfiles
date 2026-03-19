-- ~/.config/nvim/lua/plugins/copilot.lua
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter", -- 建议改为 InsertEnter，比 BufReadPost 更节省资源
    opts = {
      suggestion = {
        enabled = true, -- 🔴 强制开启 Ghost Text
        auto_trigger = true,
        keymap = {
          -- 🔴 恢复 Tab 键接受建议（因为你 LuaSnip 用 fj，所以这里用 Tab 没问题）
          accept = "<Tab>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        tex = true,
      },
    },
  },
}
