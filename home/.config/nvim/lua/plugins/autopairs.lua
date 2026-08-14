-- lua/plugins/autopairs.lua
-- Automatically inserts closing brackets, quotes, etc. and plays nicely
-- with nvim-cmp completions.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- only active while editing
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true,           -- use Treesitter to detect context (e.g. don't pair inside strings)
      ts_config = {
        lua = { "string" },      -- don't add pairs in lua string nodes
        javascript = { "template_string" },
      },
      fast_wrap = {
        map = "<M-e>",           -- Alt-e wraps the next word/expression in a pair
      },
    })

    -- Hook into nvim-cmp so that selecting a completion item that inserts
    -- a pair (e.g. a function call) still triggers autopairs logic.
    local ok, cmp = pcall(require, "cmp")
    if ok then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}
