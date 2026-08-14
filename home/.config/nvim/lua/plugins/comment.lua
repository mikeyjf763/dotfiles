-- lua/plugins/comment.lua
-- Smart line and block commenting. Works with every Treesitter grammar so
-- it uses the correct comment token in embedded languages (e.g. JSX, Vue).
return {
  "numToStr/Comment.nvim",
  dependencies = {
    -- Needed for JSX/TSX and other mixed-language files.
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Tell ts-context-commentstring not to set up its own autocmd;
    -- Comment.nvim will call it at the right time instead.
    require("ts_context_commentstring").setup({ enable_autocmd = false })

    require("Comment").setup({
      -- Feed the correct commentstring from Treesitter before each operation.
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
    -- Default keymaps added by Comment.nvim:
    --   gcc  → toggle line comment
    --   gbc  → toggle block comment
    --   gc   (visual) → toggle line comment on selection
    --   gb   (visual) → toggle block comment on selection
  end,
}
