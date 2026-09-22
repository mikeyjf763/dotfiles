-- lua/plugins/colorscheme.lua
-- One Light, matching WezTerm's theme so editor and terminal look like one
-- surface instead of two clashing color schemes.
return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- load before other plugins
  config = function()
    vim.opt.background = "light"
    require("onedarkpro").setup({
      options = {
        transparency = false,
      },
    })

    vim.cmd.colorscheme("onelight")
  end,
}
