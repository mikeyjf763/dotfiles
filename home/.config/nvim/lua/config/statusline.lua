-- lua/config/statusline.lua
-- Custom statusline: left side shows file info, right side shows open
-- terminals via the terminal-manager util. Requires laststatus=3
-- (set in config/options.lua).

require("util.terminal-manager").setup()

vim.opt.statusline = table.concat({
  " %f",       -- relative file path
  " %m%r",     -- [+] modified / [RO] read-only flags
  "%=",        -- push everything after this to the right
  "%{%v:lua.require('util.terminal-manager').statusline()%}",
  " %l:%c  ",  -- line:col + a little right padding
})

-- Redraw the statusline every second so the terminal snippet stays fresh
-- without you having to move the cursor.
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("TermStatusRefresh", { clear = true }),
  callback = function() vim.cmd("redrawstatus") end,
})
