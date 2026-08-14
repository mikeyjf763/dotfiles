-- lua/config/options.lua
-- Editor options. No plugin config here.

-- Leader keys must be set before any keymaps (and before lazy loads plugins).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true          -- show line numbers
opt.relativenumber = true  -- relative line numbers (great for motions)
opt.mouse = ""              -- no mouse in nvim; lets Herdr keep host mouse capture off so Escape isn't swallowed
opt.clipboard = "unnamedplus" -- use system clipboard
opt.ignorecase = true       -- case-insensitive search...
opt.smartcase = true        -- ...unless the search has capitals
opt.wrap = false            -- don't soft-wrap long lines
opt.signcolumn = "yes"      -- always show sign column (avoids text shifting)
opt.termguicolors = true    -- true color support
opt.scrolloff = 8           -- keep 8 lines visible above/below cursor
opt.updatetime = 250        -- faster completion / CursorHold events

-- Diffing: highlight the actual changed words/chars within a line
-- (not just the whole line) so diffs are easier to scan.
opt.diffopt:append({ "algorithm:histogram", "indent-heuristic", "linematch:60" })

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Persistent undo
opt.undofile = true

-- Global statusline (spans full width even with splits). Used by the
-- custom statusline in config/statusline.lua.
opt.laststatus = 3
