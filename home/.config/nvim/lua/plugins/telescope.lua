-- lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        sorting_strategy = "ascending",  -- best results at the TOP
        layout_config = {
          prompt_position = "top",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = false,  -- respect .gitignore (no more node_modules)
        },
      },
    })

    require("telescope").load_extension("fzf")

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
  end,
}
