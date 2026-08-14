-- lua/util/keymap-tracker.lua
--
-- Lightweight keymap usage tracker.
-- • Watches every keystroke with vim.on_key and counts sequences that match
--   your named keymaps (anything with a desc).
-- • Persists counts to ~/.local/share/nvim/keymap-stats.json on exit.
-- • Run  :KeymapStats  to see a sorted leaderboard in a floating window.
-- • Run  :KeymapStatsReset  to wipe the counts and start fresh.

local M = {}

local data_file = vim.fn.stdpath("data") .. "/keymap-stats.json"

-- ── Persistence ────────────────────────────────────────────────────────────

local function load_stats()
  local ok, text = pcall(vim.fn.readfile, data_file)
  if not ok or #text == 0 then return {} end
  local decoded = vim.json.decode(table.concat(text, "\n"))
  return decoded or {}
end

local function save_stats(stats)
  local ok, text = pcall(vim.json.encode, stats)
  if not ok then return end
  vim.fn.writefile({ text }, data_file)
end

-- ── Build a lookup of {sequence → desc} from all named keymaps ────────────

local function collect_named_keymaps()
  local lookup = {}
  for _, mode in ipairs({ "n", "v", "x", "o", "i" }) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      if km.desc and km.desc ~= "" and km.lhs then
        -- Normalise <leader> so it matches what on_key sees
        local lhs = km.lhs:gsub("<leader>", vim.g.mapleader or "\\")
        lookup[lhs] = km.desc
      end
    end
  end
  return lookup
end

-- ── Core tracking ─────────────────────────────────────────────────────────

function M.setup()
  local stats   = load_stats()
  local buf     = ""  -- accumulates keypresses to match multi-key sequences
  local lookup  = {}  -- populated after plugins load

  -- Rebuild the lookup once (plugins set their maps during VeryLazy)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once    = true,
    callback = function()
      -- Small delay so all plugin keymaps are registered
      vim.defer_fn(function()
        lookup = collect_named_keymaps()
      end, 200)
    end,
  })

  -- Watch every key
  vim.on_key(function(key)
    if vim.fn.mode() == "c" then return end  -- skip command-line mode

    -- Reset buffer on Esc or Enter
    if key == "\27" or key == "\13" then
      buf = ""
      return
    end

    buf = buf .. key

    -- Try to match the growing buffer against known sequences (longest first)
    for seq, desc in pairs(lookup) do
      if buf == seq then
        stats[desc] = (stats[desc] or 0) + 1
        buf = ""
        return
      end
    end

    -- If the buffer can't possibly start any sequence, reset it
    local maybe = false
    for seq in pairs(lookup) do
      if seq:sub(1, #buf) == buf then
        maybe = true
        break
      end
    end
    if not maybe then buf = "" end
  end)

  -- Save on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function() save_stats(stats) end,
  })

  -- ── :KeymapStats popup ───────────────────────────────────────────────────

  vim.api.nvim_create_user_command("KeymapStats", function()
    -- Sort by count descending
    local rows = {}
    for desc, count in pairs(stats) do
      table.insert(rows, { desc = desc, count = count })
    end
    table.sort(rows, function(a, b) return a.count > b.count end)

    if #rows == 0 then
      vim.notify("No keymap data yet — use some mappings first!", vim.log.levels.INFO)
      return
    end

    -- Build display lines
    local lines = { " Keymap Usage (most → least used)", "" }
    local max_count = rows[1].count
    local bar_width = 20

    for i, row in ipairs(rows) do
      local bar_len = math.floor((row.count / max_count) * bar_width)
      local bar     = string.rep("█", bar_len) .. string.rep("░", bar_width - bar_len)
      lines[#lines + 1] = string.format(
        " %3d. %-35s %s %d",
        i, row.desc, bar, row.count
      )
    end

    table.insert(lines, "")
    table.insert(lines, " :KeymapStatsReset to clear all counts")

    -- Open floating window
    local buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
    vim.api.nvim_set_option_value("filetype", "keymap-stats", { buf = buf_id })

    local width  = 70
    local height = math.min(#lines, vim.o.lines - 6)
    local row_pos = math.floor((vim.o.lines - height) / 2)
    local col_pos = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf_id, true, {
      relative = "editor",
      width    = width,
      height   = height,
      row      = row_pos,
      col      = col_pos,
      border   = "rounded",
      title    = " ⌨  Keymap Stats ",
      title_pos = "center",
      style    = "minimal",
    })

    vim.api.nvim_set_option_value("winhl", "Normal:NormalFloat", { win = win })

    -- Close with q or Esc
    for _, key in ipairs({ "q", "<Esc>" }) do
      vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf_id, silent = true })
    end
  end, { desc = "Show keymap usage leaderboard" })

  -- ── :KeymapStatsReset ────────────────────────────────────────────────────

  vim.api.nvim_create_user_command("KeymapStatsReset", function()
    for k in pairs(stats) do stats[k] = nil end
    save_stats(stats)
    vim.notify("Keymap stats reset.", vim.log.levels.INFO)
  end, { desc = "Reset all keymap usage counts" })
end

return M
