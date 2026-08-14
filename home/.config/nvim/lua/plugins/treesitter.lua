-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- classic API (`main` is a rewrite w/ a different setup style)
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "markdown" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
