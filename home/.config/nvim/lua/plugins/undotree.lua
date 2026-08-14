-- lua/plugins/undotree.lua
-- Visual undo history tree. Far more powerful than linear undo/redo.
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle", -- lazy-load: only fetch when the command is first run
  keys = {
    { "<leader>uu", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
  },
  config = function()
    -- Focus the undo-tree panel automatically when it opens.
    vim.g.undotree_SetFocusWhenToggle = 1
    -- Show timestamps in relative format ("2 min ago") instead of absolute.
    vim.g.undotree_RelativeTimestamp = 1
    -- Compact layout: diff panel goes below the undo tree, not to the right.
    vim.g.undotree_WindowLayout = 2
  end,
}
