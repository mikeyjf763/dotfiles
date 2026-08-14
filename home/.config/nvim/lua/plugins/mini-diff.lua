-- lua/plugins/mini-diff.lua
-- Unified inline diff overlay: shows removed lines as virtual text right
-- where they were and highlights added lines in place, in a single column.
-- Built for exactly the case Diffview doesn't fit: a narrow nvim pane
-- (e.g. split beside an agent pane) with no room for a side-by-side diff.
return {
  "echasnovski/mini.diff",
  version = "*",
  config = function()
    require("mini.diff").setup({
      -- Recolor the existing line-number column instead of adding a sign
      -- column, so this costs zero extra width - gitsigns already owns the
      -- sign column for its own hunk markers.
      view = { style = "number" },
    })

    vim.keymap.set("n", "<leader>go", function()
      require("mini.diff").toggle_overlay(0)
    end, { desc = "Toggle inline diff overlay (unified, single column)" })
  end,
}
