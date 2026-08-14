-- lua/plugins/notifier.lua
-- Replaces the default vim.notify (which dumps errors as raw command-line
-- tracebacks) with Snacks' floating toast notifications.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    notifier = { enabled = true },
  },
}
