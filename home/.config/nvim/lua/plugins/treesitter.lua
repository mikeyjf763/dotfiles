-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- required for Neovim 0.12+; `master` is locked to Nvim <=0.11
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "bash", "markdown" })

    -- main branch dropped `configs.setup({ highlight, indent, ensure_installed, auto_install })`;
    -- replicate that behavior by installing + starting treesitter for any filetype with a parser.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match) or args.match
        if not vim.tbl_contains(require("nvim-treesitter.config").get_available(), lang) then
          return
        end
        if not vim.tbl_contains(require("nvim-treesitter.config").get_installed(), lang) then
          require("nvim-treesitter").install(lang):wait(120000)
        end
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
