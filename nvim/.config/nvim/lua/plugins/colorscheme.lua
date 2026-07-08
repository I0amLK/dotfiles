return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized8",
    },
  },

  {
    "lifepillar/vim-solarized8",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = "light"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "solarized_light"

      -- 关键：圆角外观在这里配
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }
    end,
  },
}
