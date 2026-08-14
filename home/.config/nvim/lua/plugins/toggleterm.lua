
-- lua/plugins/toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<leader>tt]],
      direction = "float",
      shade_terminals = true,
    })

    local map = vim.keymap.set

    -- Vim-style controls inside terminal buffers: Esc drops you into
    -- Normal mode for scrolling/search/yank; i/a goes back to the shell.
    -- (No "jk" chord here on purpose: TUI programs like lazygit use j/k
    -- for their own navigation, and fast j-then-k scrolling would get
    -- misread as the escape chord, desyncing the buffer from the live UI.)
    local function set_terminal_keymaps()
      local opts = { buffer = 0 }
      map("t", "<esc>", [[<C-\><C-n>]], opts)
      map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = set_terminal_keymaps,
    })

    -- Dedicated floating terminal that always runs lazygit
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      on_open = function(term)
        -- lazygit uses <esc> as its own cancel/back key for menus and
        -- popups. The global terminal-mode <esc> -> Normal mode mapping
        -- (set above) would swallow that keypress before lazygit ever
        -- sees it, stranding you in the buffer's scrollback with no way
        -- to navigate. Send <esc> straight through for this buffer only.
        map("t", "<esc>", "<esc>", { buffer = term.bufnr })
      end,
    })

    map("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "Toggle lazygit" })
  end,
}
