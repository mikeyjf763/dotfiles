-- lua/plugins/obsidian.lua
-- Deep Neovim integration for an Obsidian vault.
-- Prerequisites: you need Obsidian installed and at least one vault on disk.
-- Update the `dir` (or `workspaces`) below to match your vault path.
return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended: use latest release rather than HEAD
  lazy = true,
  -- Only activate when you're inside your vault directory.
  -- Adjust the path to wherever your vault actually lives.
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/obsidian-vault/**.md",
    "BufNewFile "  .. vim.fn.expand("~") .. "/obsidian-vault/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim", -- used for search pickers
    "nvim-treesitter/nvim-treesitter", -- used for better markdown highlighting
  },
  opts = {
    -- ── Vault location ───────────────────────────────────────────────────
    -- Single vault (simplest setup). Replace the path below.
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian-vault",
      },
      -- Add more vaults here if needed:
      -- { name = "work", path = "~/work-vault" },
    },

    -- ── Daily notes ──────────────────────────────────────────────────────
    daily_notes = {
      folder = "daily",          -- sub-folder inside the vault
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = nil,            -- set to a template filename if you use one
    },

    -- ── Completion ───────────────────────────────────────────────────────
    completion = {
      nvim_cmp = true,           -- hook into nvim-cmp for [[wikilink]] completions
      min_chars = 2,
    },

    -- ── Note ID / naming ─────────────────────────────────────────────────
    -- Use the human-readable title as the filename (no random IDs).
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,

    -- ── UI ───────────────────────────────────────────────────────────────
    ui = {
      enable = true,
      update_debounce = 200,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      },
      external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      reference_text = { hl_group = "ObsidianRefText" },
      highlight_text = { hl_group = "ObsidianHighlightText" },
      tags_text = { hl_group = "ObsidianTag" },
    },

    -- ── Attachments ──────────────────────────────────────────────────────
    attachments = {
      img_folder = "assets/imgs",
    },
  },

  config = function(_, opts)
    require("obsidian").setup(opts)

    local map = vim.keymap.set

    -- Open today's daily note (creates it if it doesn't exist yet).
    map("n", "<leader>od", "<cmd>ObsidianToday<CR>",       { desc = "Daily note (today)" })
    -- Yesterday / tomorrow daily notes.
    map("n", "<leader>oy", "<cmd>ObsidianYesterday<CR>",   { desc = "Daily note (yesterday)" })
    map("n", "<leader>om", "<cmd>ObsidianTomorrow<CR>",    { desc = "Daily note (tomorrow)" })
    -- Full-text search across the vault via Telescope.
    map("n", "<leader>os", "<cmd>ObsidianSearch<CR>",      { desc = "Search vault" })
    -- Fuzzy-find a note by filename.
    map("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick switch note" })
    -- Create a new note (prompts for a title).
    map("n", "<leader>on", "<cmd>ObsidianNew<CR>",         { desc = "New note" })
    -- Follow a [[wikilink]] or URL under the cursor.
    map("n", "<leader>oo", "<cmd>ObsidianFollowLink<CR>",  { desc = "Follow link" })
    -- Back-links: show all notes that link to the current note.
    map("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>",   { desc = "Backlinks" })
    -- Insert a link to another note at the cursor.
    map("n", "<leader>ol", "<cmd>ObsidianLink<CR>",        { desc = "Insert link" })
    -- Toggle the checkbox state on the current line.
    map("n", "<leader>oc", "<cmd>ObsidianToggleCheckbox<CR>", { desc = "Toggle checkbox" })
    -- Open in the Obsidian app (if installed).
    map("n", "<leader>oO", "<cmd>ObsidianOpen<CR>",        { desc = "Open in Obsidian app" })
    -- Rename the current note and update all links to it.
    map("n", "<leader>or", "<cmd>ObsidianRename<CR>",      { desc = "Rename note" })
  end,
}
