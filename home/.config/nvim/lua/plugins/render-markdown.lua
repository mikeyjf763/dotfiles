-- lua/plugins/render-markdown.lua
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  opts = {
    heading = {
      -- Render each heading level with a distinct background highlight
      sign = false,
    },
    code = {
      -- Subtle left border + background on fenced code blocks
      style = "full",
    },
    bullet = {
      -- Replace - / * bullets with nicer icons
      icons = { "●", "○", "◆", "◇" },
    },
  },
}
