-- lua/plugins/neogit.lua
-- Magit-style git status panel: a single buffer showing staged/unstaged
-- changes. Use <leader>gt to toggle it. Press Enter on a file to open it
-- in the right pane without closing the status panel. Press ? for help.
return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local neogit = require("neogit")

    neogit.setup({
      integrations = { diffview = true },
      -- Open as a left-side split so the rest of the editor stays on the right.
      kind = "split_above_all",
      graph_style = "unicode",
      status = {
        -- Single-character mode labels save width in the narrow left pane.
        mode_padding = 1,
        mode_text = {
          M  = "M",
          N  = "N",
          A  = "A",
          D  = "D",
          C  = "C",
          U  = "U",
          R  = "R",
          T  = "T",
          DD = "!",
          AU = "!",
          UD = "!",
          UA = "!",
          DU = "!",
          AA = "!",
          UU = "!",
          ["?"] = "?",
        },
      },
      mappings = {
        status = {
          -- Remap Enter to open file in the right pane, keeping neogit open.
          -- The default GoToFile closes neogit; we handle this ourselves below.
          ["<cr>"] = false,
        },
      },
    })

    -- Find the editor pane's Neovim socket. The right pane must have been
    -- started with `nvim-editor` (a shell function that writes its Herdr pane
    -- ID to /tmp/nvim-herdr-editor-pane). Returns nil if not available.
    local function editor_socket()
      local f = io.open("/tmp/nvim-herdr-editor-pane", "r")
      if not f then return nil end
      local pane_id = vim.trim(f:read("*a"))
      f:close()
      if pane_id == "" then return nil end
      return "/tmp/nvim-herdr-" .. pane_id:gsub(":", "_") .. ".sock"
    end

    -- Open path in the right pane's Neovim via RPC if available, otherwise
    -- fall back to opening a vsplit in the current tab.
    local function open_in_right_pane(path)
      if not path or path == "" then return end

      local sock = editor_socket()
      if sock and vim.fn.filereadable(sock) == 1 then
        -- Send an edit command to the remote Neovim instance.
        vim.fn.jobstart({
          "nvim", "--server", sock, "--remote-silent", path,
        }, { detach = true })
      else
        -- Fallback: find the rightmost non-neogit window in this tab.
        local target_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype ~= "NeogitStatus" then
            local col = vim.api.nvim_win_get_position(win)[2]
            if not target_win or col > target_win.col then
              target_win = { win = win, col = col }
            end
          end
        end
        if target_win then
          vim.api.nvim_set_current_win(target_win.win)
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        else
          vim.cmd("vsplit " .. vim.fn.fnameescape(path))
        end
      end
    end

    -- Wire the custom Enter mapping after neogit opens its buffer.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(ev)
        vim.keymap.set("n", "<cr>", function()
          local status_buf = require("neogit.buffers.status")
          local instance = status_buf.instance(vim.fn.getcwd())
          if not instance then return end

          local item = instance.buffer.ui:get_item_under_cursor()
          if item and item.absolute_path then
            open_in_right_pane(item.absolute_path)
          end
        end, { buffer = ev.buf, desc = "Open file in right pane (keep neogit open)" })
      end,
    })

    local function toggle_status()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "NeogitStatus" then
          vim.api.nvim_win_close(win, false)
          return
        end
      end
      neogit.open()
    end

    vim.keymap.set("n", "<leader>gt", toggle_status, { desc = "Toggle git status panel (Neogit)" })
  end,
}
