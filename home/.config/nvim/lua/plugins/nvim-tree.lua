-- lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    -- disable netrw (recommended by nvim-tree)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup({
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        -- Load all the defaults first
        api.config.mappings.default_on_attach(bufnr)
        local opts = function(desc)
          return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- Override v → vertical split, s → horizontal split
        vim.keymap.set("n", "v", api.node.open.vertical,   opts("Open in vertical split"))
        vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open in horizontal split"))
      end,
    })

    local map = vim.keymap.set
    map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Find current file in tree" })
  end,
}
