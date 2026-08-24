-- lua/plugins/mini-diff.lua
-- Unified inline diff overlay: shows removed lines as virtual text right
-- where they were and highlights added lines in place, in a single column.
-- Built for exactly the case Diffview doesn't fit: a narrow nvim pane
-- (e.g. split beside an agent pane) with no room for a side-by-side diff.
return {
  "echasnovski/mini.diff",
  version = "*",
  config = function()
    local diff = require("mini.diff")

    -- mini.diff's built-in Git source compares against the index. That is
    -- useful for staging, but it hides changes that have already been staged.
    -- This source compares the current buffer with HEAD so the overlay shows
    -- the complete file diff, regardless of staging state.
    local function git_head_source()
      local function head_text(buf_id)
        local path = vim.loop.fs_realpath(vim.api.nvim_buf_get_name(buf_id))
        if not path or path == "" then return nil, false end

        local root_result = vim.system({
          "git", "-C", vim.fn.fnamemodify(path, ":h"), "rev-parse", "--show-toplevel",
        }, { text = true }):wait()
        if root_result.code ~= 0 then return nil, false end

        local root = vim.trim(root_result.stdout)
        local relative = vim.fs.relpath(root, path)
        if not relative then return nil, false end

        local file_result = vim.system({
          "git", "-C", root, "show", "HEAD:" .. relative,
        }, { text = true }):wait()
        if file_result.code ~= 0 then
          -- A file in a Git repo with no HEAD entry is untracked. Compare it
          -- with an empty reference so its contents still appear as added.
          return "", true
        end
        return file_result.stdout, true
      end

      return {
        name = "git-head",
        attach = function(buf_id)
          local text, in_repo = head_text(buf_id)
          if not in_repo then return false end
          diff.set_ref_text(buf_id, text)
        end,
      }
    end

    diff.setup({
      source = git_head_source(),
      -- Staging is handled by Gitsigns. This source is intentionally
      -- read-only because its reference is HEAD, not the Git index.
      mappings = { apply = "", reset = "" },
      -- Recolor the existing line-number column instead of adding a sign
      -- column, so this costs zero extra width - gitsigns already owns the
      -- sign column for its own hunk markers.
      view = { style = "number" },
    })

    vim.keymap.set("n", "<leader>go", function()
      local data = diff.get_buf_data(0)
      if not data then
        vim.notify("No Git diff available for this buffer", vim.log.levels.INFO)
        return
      end
      diff.toggle_overlay(0)
    end, { desc = "Toggle inline diff overlay (against HEAD)" })
  end,
}
