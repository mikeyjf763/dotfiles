-- terminal-manager.lua
-- Statusline helper that reads from toggleterm's terminal registry.
-- Keymaps are wired in init.lua via M.setup().

local M = {}

-- Strip ANSI escape codes so pattern matching doesn't choke on garbage
local function strip_ansi(s)
  return s
    :gsub("\27%[[%d;]*[A-Za-z]", "")
    :gsub("\27%[%?%d+[hl]", "")
    :gsub("\r", "")
end

-- Claude Code's status line only shows "esc to interrupt" while it's
-- actively generating (e.g. "✳ Pondering… (4s · esc to interrupt)").
-- When idle it shows the input box + "? for shortcuts" instead, so this
-- string is a reliable, low-noise signal that a prompt is running.
-- Returns a lowercase verb like "pondering", or nil if not running.
local function claude_activity(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return nil end
  local count = vim.api.nvim_buf_line_count(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, count - 20), count, false)
  for i = #lines, 1, -1 do
    local l = strip_ansi(lines[i])
    if l:find("esc to interrupt", 1, true) then
      local word = l:gsub("^%s*[^%a]*", ""):match("^(%a+)")
      return word and word:lower() or "running"
    end
  end
  return nil
end

-- Highlight groups for the state dot + label. Re-applied on colorscheme
-- change since `nvim_set_hl` values don't survive a `:colorscheme` reload.
local function set_highlights()
  vim.api.nvim_set_hl(0, "TermRunning", { fg = "#fe8019", bold = true }) -- gruvbox orange
  vim.api.nvim_set_hl(0, "TermIdle", { fg = "#b8bb26" })                 -- gruvbox green
  vim.api.nvim_set_hl(0, "TermClosed", { fg = "#7c6f64" })               -- gruvbox gray (dim)
  vim.api.nvim_set_hl(0, "TermLabel", { fg = "#a89984" })                -- gruvbox fg4 (muted)
end

-- Build the terminal section string for the statusline.
-- Closed/idle terminals collapse to just a colored dot + number; only a
-- terminal actively running a Claude Code prompt shows a label, e.g.:
--   ●1 claude: pondering…  │  ○2  │  ○3
function M.statusline()
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then return "" end

  local terminals = toggleterm.get_all(true) -- true = include hidden/closed ones
  if not terminals or #terminals == 0 then return "" end

  local parts = {}
  for _, term in ipairs(terminals) do
    local is_open = term:is_open()
    local icon = is_open and "●" or "○"
    local hl, label = "%#TermClosed#", ""

    if is_open then
      local activity = claude_activity(term.bufnr)
      if activity then
        hl = "%#TermRunning#"
        label = " claude: " .. activity .. "…"
      else
        hl = "%#TermIdle#"
      end
    end

    table.insert(parts, string.format("%s%s%%#TermLabel#%d%s", hl, icon, term.id, label))
  end

  return "  " .. table.concat(parts, "  │  ") .. "  %#StatusLine#"
end

-- Wire up explicit <leader>t1 … <leader>t9 shortcuts.
-- The default open_mapping with a count prefix (2<leader>tt) also works,
-- but these give you a direct single-chord alternative.
function M.setup()
  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("TermManagerHighlights", { clear = true }),
    callback = set_highlights,
  })

  local map = vim.keymap.set
  for i = 1, 9 do
    map("n", "<leader>t" .. i, function()
      -- toggleterm exposes a toggle_command helper
      vim.cmd(i .. "ToggleTerm")
    end, { desc = "Toggle terminal " .. i })
  end
end

return M
