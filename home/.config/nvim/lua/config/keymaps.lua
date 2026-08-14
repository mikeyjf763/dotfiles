-- lua/config/keymaps.lua
-- Global, plugin-independent keymaps. Plugin-specific maps live alongside
-- their plugin spec in lua/plugins/.

local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between splits with Ctrl+hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })

-- Disable arrow keys to force hjkl (normal, insert, visual)
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "i", "v" }, key, "<Nop>", { desc = "Disabled (use hjkl)" })
end

-- Half-page scroll, centered on screen so the cursor never drifts to
-- the edge of the viewport. Bound to c/n instead of the default d/u.
map("n", "<C-c>", "<C-u>zz", { desc = "Half-page up, centered" })
map("n", "<C-n>", "<C-d>zz", { desc = "Half-page down, centered" })
