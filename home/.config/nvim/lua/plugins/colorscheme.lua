-- lua/plugins/colorscheme.lua
-- One Light, matching WezTerm's theme so editor and terminal look like one
-- surface instead of two clashing color schemes.
return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- load before other plugins
  config = function()
    require("onedarkpro").setup({
      options = {
        transparency = vim.uv.os_uname().sysname == "Darwin"
          or string.find(vim.uv.os_uname().sysname, "Windows") ~= nil
          or string.find(vim.uv.os_uname().release, "WSL") ~= nil,
      },
    })

    vim.cmd.colorscheme("onelight")
  end,
}
