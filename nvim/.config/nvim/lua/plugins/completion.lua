return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {
          -- Accept the completion menu before considering Copilot ghost text.
          "select_and_accept",
          function()
            if vim.fn.mode() ~= "i" then
              return
            end
            local ok, suggestion = pcall(require, "copilot.suggestion")
            if ok and suggestion.is_visible() then
              suggestion.accept()
              return true
            end
          end,
          function()
            local ft = vim.bo.filetype
            if vim.fn.mode() == "i" and (ft == "tex" or ft == "latex") and require("util.latex").in_matrix() then
              return " & "
            end
          end,
          "snippet_forward",
          "fallback",
        },
      },
    },
  },
}
