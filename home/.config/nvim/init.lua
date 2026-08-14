-- ~/.config/nvim/init.lua
-- Entry point. Keep this thin: it just loads the config modules in order.
-- All real configuration lives under lua/config/ and lua/plugins/.

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy") -- bootstraps lazy.nvim and imports lua/plugins/*
require("config.statusline")
require("util.keymap-tracker").setup() -- keymap usage tracker → :KeymapStats
