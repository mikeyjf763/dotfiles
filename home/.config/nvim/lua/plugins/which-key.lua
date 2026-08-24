-- lua/plugins/which-key.lua
-- Shows a popup of available keybindings as you type a prefix.
-- Only mappings with a `desc` appear — everything else stays hidden,
-- so the popup only shows what you've intentionally decided to learn.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      delay = 300,
      icons = { mappings = false },
      win = {
        border = "rounded",
        padding = { 1, 2 },
      },
      layout = {
        spacing = 3,
      },
      show_help = true,
      -- ✦ The key setting: hide anything without a description.
      -- Add `desc = "..."` to a mapping to make it appear here.
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
    })

    wk.add({

      -- ── Top-level groups ────────────────────────────────────────────
      { "<leader>e", group = "  explorer" },
      { "<leader>f", group = "  find" },
      { "<leader>g", group = "  git" },
      { "<leader>l", group = "  lsp" },
      { "<leader>u", group = "  undo" },
      { "<leader>o", group = "  obsidian" },

      -- ── General ─────────────────────────────────────────────────────
      { "<leader>w", desc = "Save file" },
      { "<leader>q", desc = "Quit" },
      { "<leader>h", desc = "Clear search highlight" },

      -- ── Navigation (splits) ──────────────────────────────────────────
      { "<C-h>", desc = "Go to left split" },
      { "<C-j>", desc = "Go to lower split" },
      { "<C-k>", desc = "Go to upper split" },
      { "<C-l>", desc = "Go to right split" },
      { "<C-c>", desc = "Half-page up, centered" },
      { "<C-n>", desc = "Half-page down, centered" },

      -- ── File Explorer (nvim-tree) ────────────────────────────────────
      { "<leader>e",  desc = "Toggle file tree" },
      { "<leader>ef", desc = "Find current file in tree" },
      -- (inside the tree — v/s are buffer-local to NvimTree)
      { "v",          desc = "Open in vertical split",   ft = "NvimTree" },
      { "s",          desc = "Open in horizontal split", ft = "NvimTree" },

      -- ── Telescope ───────────────────────────────────────────────────
      { "<leader>ff", desc = "Find files" },
      { "<leader>fg", desc = "Live grep" },
      { "<leader>fb", desc = "Find buffers" },
      { "<leader>fh", desc = "Help tags" },

      -- ── LSP (active when a server is attached) ───────────────────────
      { "<leader>ld", desc = "Go to definition" },
      { "<leader>lD", desc = "Go to declaration" },
      { "<leader>lr", desc = "References" },
      { "<leader>li", desc = "Go to implementation" },
      { "<leader>lt", desc = "Type definition" },
      { "<leader>ln", desc = "Rename symbol" },
      { "<leader>la", desc = "Code action" },
      { "<leader>lf", desc = "Format buffer" },
      { "<leader>ls", desc = "Signature help" },
      { "<leader>le", desc = "Show diagnostic" },
      { "<leader>lq", desc = "Diagnostics to loclist" },
      -- Vanilla LSP motions (no leader — good ones to drill)
      { "K",          desc = "Hover docs" },
      { "[d",         desc = "Prev diagnostic" },
      { "]d",         desc = "Next diagnostic" },

      -- ── Git (gitsigns — active in git repos) ─────────────────────────
      { "]c",         desc = "Next git hunk (all changes)" },
      { "[c",         desc = "Prev git hunk (all changes)" },
      { "<leader>gs", desc = "Stage hunk" },
      { "<leader>gr", desc = "Reset hunk" },
      { "<leader>gS", desc = "Stage entire buffer" },
      { "<leader>gR", desc = "Reset entire buffer" },
      { "<leader>gu", desc = "Undo stage hunk" },
      { "<leader>gp", desc = "Preview hunk diff" },
      { "<leader>gb", desc = "Blame line" },
      { "<leader>go", desc = "Inline diff (against HEAD)" },
      { "[b",         desc = "Previous buffer" },
      { "]b",         desc = "Next buffer" },
      { "<leader>bp", desc = "Pick buffer" },

      -- ── Undo tree ────────────────────────────────────────────────────
      { "<leader>uu", desc = "Toggle undo tree" },

    })
  end,
}
