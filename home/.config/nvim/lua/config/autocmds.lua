-- lua/config/autocmds.lua
-- Global autocommands not tied to a specific plugin.

-- Autosave --------------------------------------------------------------
-- Silently writes the buffer when you leave insert mode, stop typing,
-- or switch away (e.g. to another app) — skips buffers with no file
-- (like Telescope/terminal windows) and unmodified buffers.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("Autosave", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.modifiable and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" and vim.bo.modified then
      local ok, err = pcall(vim.cmd.write)
      if not ok then
        vim.notify("Autosave failed: " .. err, vim.log.levels.WARN)
      end
    end
  end,
})

-- Diff scroll sync ------------------------------------------------------
-- Vim's diff mode normally binds scroll/cursor across diff windows
-- automatically, but make it explicit so scrolling one Diffview pane
-- always scrolls the other in lockstep and line numbers stay aligned.
vim.api.nvim_create_autocmd({ "OptionSet", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("DiffScrollSync", { clear = true }),
  callback = function()
    if vim.wo.diff then
      vim.wo.scrollbind = true
      vim.wo.cursorbind = true
    end
  end,
})
