-- lua/plugins/colorscheme.lua
-- rose-pine moon, matching WezTerm's theme so editor and terminal look like
-- one surface instead of two clashing color schemes.
return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000, -- load before other plugins
  config = function()
    require("rose-pine").setup({
      dark_variant = "moon",
      dim_inactive_windows = false,
      extend_background_behind_borders = false,
      styles = {
        italic = false,
        transparency = vim.uv.os_uname().sysname == "Darwin"
          or string.find(vim.uv.os_uname().sysname, "Windows") ~= nil
          or string.find(vim.uv.os_uname().release, "WSL") ~= nil,
      },
    })

    vim.cmd.colorscheme("rose-pine")
  end,
}
