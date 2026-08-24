-- lua/plugins/gitsigns.lua
return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigate both unstaged and staged hunks. Gitsigns normally targets
        -- only the working-tree/index diff, which makes staged changes appear
        -- to have no hunks even though Diffview can still show them.
        bmap("n", "]c", function()
          gs.nav_hunk("next", { target = "all" })
        end, "Next git hunk (all changes)")
        bmap("n", "[c", function()
          gs.nav_hunk("prev", { target = "all" })
        end, "Prev git hunk (all changes)")

        -- Stage / reset
        bmap("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        bmap("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        bmap("n", "<leader>gS", gs.stage_buffer, "Stage entire buffer")
        bmap("n", "<leader>gR", gs.reset_buffer, "Reset entire buffer")
        bmap("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")

        -- Preview / blame
        bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk diff")
        bmap("n", "<leader>gb", gs.blame_line, "Blame line")
      end,
    })
  end,
}
