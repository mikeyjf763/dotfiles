-- lua/plugins/bufferline.lua
-- Compact, always-visible list of buffers at the top of the editor.
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local bufferline = require("bufferline")

    bufferline.setup({
      options = {
        mode = "buffers",
        style_preset = bufferline.style_preset.minimal,
        numbers = "none",
        indicator = { style = "none" },
        separator_style = "thin",
        tab_size = 1,
        max_name_length = 24,
        max_prefix_length = 10,
        truncate_names = true,
        diagnostics = false,
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = false,
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    })

    local map = vim.keymap.set
    map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
    map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
  end,
}
