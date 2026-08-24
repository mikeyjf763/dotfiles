-- lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    -- disable netrw (recommended by nvim-tree)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup({
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        -- Load all the defaults first
        api.config.mappings.default_on_attach(bufnr)
        local opts = function(desc)
          return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- Override v → vertical split, s → horizontal split
        vim.keymap.set("n", "v", api.node.open.vertical,   opts("Open in vertical split"))
        vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open in horizontal split"))
      end,
    })

    -- Show only the basename in a small floating window when the cursor rests
    -- on a file. This keeps the tree narrow while making clipped names easy
    -- to identify. CursorHold also works when the host mouse is disabled.
    local hover_win
    local hover_group = vim.api.nvim_create_augroup("NvimTreeFileHover", { clear = true })
    local function close_file_hover()
      if hover_win and vim.api.nvim_win_is_valid(hover_win) then
        vim.api.nvim_win_close(hover_win, true)
      end
      hover_win = nil
    end

    vim.api.nvim_create_autocmd("CursorHold", {
      group = hover_group,
      pattern = "*",
      callback = function()
        if vim.bo.filetype ~= "NvimTree" then
          close_file_hover()
          return
        end

        local node = require("nvim-tree.api").tree.get_node_under_cursor()
        if not node or (node.type ~= "file" and node.type ~= "link") then
          close_file_hover()
          return
        end

        close_file_hover()
        local max_width = math.max(1, math.min(vim.fn.strdisplaywidth(node.name), vim.o.columns - 4))
        local _, win = vim.lsp.util.open_floating_preview({ node.name }, "plaintext", {
          border = "rounded",
          focusable = false,
          relative = "cursor",
          row = 1,
          col = 0,
          max_width = max_width,
          max_height = 1,
        })
        hover_win = win
      end,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "WinScrolled" }, {
      group = hover_group,
      pattern = "*",
      callback = close_file_hover,
    })

    local map = vim.keymap.set
    map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "Find current file in tree" })
  end,
}
