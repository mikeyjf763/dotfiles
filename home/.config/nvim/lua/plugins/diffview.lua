-- lua/plugins/diffview.lua
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local map = vim.keymap.set

    -- Diffview commands throw a raw Lua traceback (not a vim.notify call)
    -- when run outside a git repo. Wrap each one so that shows as a clean
    -- one-line notification instead.
    local function safe_cmd(cmd)
      local ok, err = pcall(vim.cmd, cmd)
      if not ok then
        vim.notify(err:match(":%s*(.+)$") or err, vim.log.levels.ERROR, { title = "Diffview" })
      end
    end

    local function toggle_diffview()
      local lib = require("diffview.lib")
      if lib.get_current_view() then
        safe_cmd("DiffviewClose")
      else
        safe_cmd("DiffviewOpen")
      end
    end

    map("n", "<leader>gd", toggle_diffview, { desc = "Toggle diff view (all changes)" })
    map("n", "<leader>gh", function() safe_cmd("DiffviewFileHistory %") end, { desc = "File history (current file)" })
    map("n", "<leader>gq", function() safe_cmd("DiffviewClose") end, { desc = "Close diff view" })
  end,
}
