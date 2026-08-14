# Neovim Cheatsheet

Config: `~/.config/nvim/init.lua`
Leader key: `<space>`

Search this file with `Cmd+F` — every keymap has its own line with a plain-English description so text search finds it.

## Table of Contents

- [General](#general)
- [Basic Movement & Editing (built-in)](#basic-movement--editing-built-in)
- [Window / Split Navigation](#window--split-navigation)
- [Telescope (fuzzy finder)](#telescope-fuzzy-finder)
- [Git — Diffview (change list / diff review)](#git--diffview-change-list--diff-review)
- [Git — Gitsigns (inline hunks)](#git--gitsigns-inline-hunks)
- [Git — mini.diff (unified overlay)](#git--minidiff-unified-overlay)
- [Terminal (toggleterm + lazygit)](#terminal-toggleterm--lazygit)
- [LSP (language server)](#lsp-language-server)
- [Completion (nvim-cmp + LuaSnip)](#completion-nvim-cmp--luasnip)
- [Comment.nvim](#commentnvim)
- [Undo Tree](#undo-tree)
- [Obsidian Notes](#obsidian-notes)
- [Treesitter](#treesitter)
- [Plugin Manager (lazy.nvim)](#plugin-manager-lazynvim)
- [Useful Built-in Commands](#useful-built-in-commands)
- [Installed Plugins](#installed-plugins)

---

## General

| Keymap | Mode | Action |
|---|---|---|
| `jk` | insert | Exit insert mode (instead of `Esc`) |
| `<space>w` | normal | Save file (`:write`) |
| `<space>q` | normal | Quit (`:quit`) |
| `<space>h` | normal | Clear search highlight |

## Basic Movement & Editing (built-in)

Arrow keys are **disabled** in your config (normal/insert/visual) — use `hjkl` instead.


Your config has `relativenumber` on — every line shows its distance from your cursor (your actual line shows its real number). The number displayed *is* the count to type before `j`/`k` to jump straight to it.




**Movement:**

| Keymap | Action |
|---|---|
| `h` / `j` / `k` / `l` | Left / down / up / right |
| `{number}j` | Jump down that many lines, e.g. `5j` |
| `{number}k` | Jump up that many lines, e.g. `5k` |
| `w` | Jump forward to start of next word |
| `b` | Jump backward to start of word |
| `e` | Jump forward to end of word |
| `0` | Jump to start of line |
| `^` | Jump to first non-blank character of line |
i| `$` | Jump to end of line |
| `gg` | Jump to top of file |
| `G` | Jump to bottom of file |
| `{number}G` or `:{number}` | Jump to line number, e.g. `42G` |
| `Ctrl+c` | Scroll half-page up, centered (your custom mapping) |
| `Ctrl+n` | Scroll half-page down, centered (your custom mapping) |
| `Ctrl+f` / `Ctrl+b` | Scroll full page down / up |
| `%` | Jump to matching bracket/paren |
| `f{char}` | Jump forward to next `{char}` on the line |
| `t{char}` | Jump forward to just before next `{char}` |

**Modes:**

| Keymap | Action |
|---|---|
| `i` | Insert mode before cursor |
| `a` | Insert mode after cursor |
| `o` / `O` | New line below / above, enter insert mode |
| `v` | Visual mode (character select) |
| `V` | Visual line mode (whole lines) |
| `jk` | Exit insert mode back to normal (your custom mapping) |

**Editing:**

| Keymap | Action |
|---|---|
| `x` | Delete character under cursor |
| `dd` | Delete (cut) current line |
| `dw` | Delete word |
| `yy` | Yank (copy) current line |
| `p` / `P` | Paste after / before cursor |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `.` | Repeat last change |
| `cc` | Change (delete + insert) current line |
| `ciw` | Change word under cursor |

**Search:**

| Keymap | Action |
|---|---|
| `/text` | Search forward for "text" |
| `?text` | Search backward for "text" |
| `n` / `N` | Repeat search forward / backward |
| `<space>h` | Clear search highlight (your custom mapping) |

## Window / Split Navigation

| Keymap | Mode | Action |
|---|---|---|
| `Ctrl+h` | normal | Move to left split |
| `Ctrl+j` | normal | Move to lower split |
| `Ctrl+k` | normal | Move to upper split |
| `Ctrl+l` | normal | Move to right split |

## Telescope (fuzzy finder)

| Keymap | Mode | Action |
|---|---|---|
| `<space>ff` | normal | Find files in current directory |
| `<space>fg` | normal | Live grep — search text across all files |
| `<space>fb` | normal | List open buffers |
| `<space>fh` | normal | Search Neovim help tags |

**Inside a Telescope picker:**

| Keymap | Action |
|---|---|
| type text | Fuzzy filter results |
| `Ctrl+n` / `Ctrl+p` or `↓`/`↑` | Move selection |
| `Enter` | Open selection |
| `Ctrl+x` | Open in horizontal split |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+t` | Open in new tab |
| `Esc` or `Ctrl+c` | Close picker |

## Git — Diffview (change list / diff review)

Use this to review a batch of changes (e.g. everything an AI just edited) — it's the closest thing to VSCode's Source Control panel.

| Keymap | Mode | Action |
|---|---|---|
| `<space>gd` | normal | Open Diffview — file-tree panel of all changed files + diff pane |
| `<space>gh` | normal | File history for the current file |
| `<space>gq` | normal | Close Diffview |

**Inside the Diffview file panel:**

| Keymap | Action |
|---|---|
| `j` / `k` | Move between files in the list |
| `Enter` | Open that file's diff |
| `-` | Stage / unstage the file under cursor |
| `X` | Restore file to HEAD (discard changes) |
| `Tab` / `Shift+Tab` | Cycle through changed files |
| `R` | Refresh the file list |

## Git — Gitsigns (inline hunks)

Use this while editing a single file — shows `+`/`~`/`-` in the sign column and lets you act on individual hunks (a "hunk" = one contiguous block of changed lines).

| Keymap | Mode | Action |
|---|---|---|
| `]c` | normal | Jump to next changed hunk |
| `[c` | normal | Jump to previous changed hunk |
| `<space>gp` | normal | Preview hunk diff in a popup |
| `<space>gs` | normal | Stage hunk under cursor |
| `<space>gr` | normal | Reset (discard) hunk under cursor |
| `<space>gu` | normal | Undo last staged hunk |
| `<space>gS` | normal | Stage entire buffer |
| `<space>gR` | normal | Reset entire buffer |
| `<space>gb` | normal | Show git blame for current line |

**Typical AI-review flow:**
1. `<space>gd` to see every file the AI touched, review each diff.
2. Stage good files/hunks with `-` (Diffview) or `<space>gs` (Gitsigns).
3. Drop into a specific file, use `]c` / `[c` + `<space>gp` for line-by-line review.

## Git — mini.diff (unified overlay)

Diffview's file-tree + side-by-side diff needs real width — cramped when nvim is a narrow
split (e.g. next to an agent pane). This shows the diff inline in a single column instead:
removed lines appear as virtual text right where they were, added lines highlight in place.
No extra gutter column either — it recolors the existing line-number column, not the sign
column gitsigns already uses.

| Keymap | Mode | Action |
|---|---|---|
| `<space>go` | normal | Toggle the inline diff overlay for the current buffer |

## Terminal (toggleterm + lazygit)

A terminal *inside* Neovim — no need to switch to Ghostty for quick commands or git.

| Keymap | Mode | Action |
|---|---|---|
| `Ctrl+\` | normal/terminal | Toggle a general-purpose floating terminal (any shell command) |
| `<space>gg` | normal | Toggle a dedicated floating terminal running `lazygit` |

**Inside any terminal buffer:**

| Keymap | Action |
|---|---|
| `i` (or just start typing) | Enter terminal insert mode to type commands |
| `Ctrl+\` then `Ctrl+n` | Exit terminal mode back to normal mode (without closing it) |
| Same toggle keymap again (`Ctrl+\` or `<space>gg`) | Hide the terminal (it keeps running in the background) |

**Inside lazygit** (opened via `<space>gg`):

| Keymap | Action |
|---|---|
| `↑`/`↓` or `j`/`k` | Move between files/commits |
| `Space` | Stage / unstage file under cursor |
| `c` | Commit staged changes |
| `P` | Push |
| `p` | Pull |
| `q` | Quit lazygit (returns you to the floating terminal, which then closes) |

## LSP (language server)

These keymaps are only active in buffers where a language server has attached.
Servers auto-installed via Mason: `lua_ls`, `ts_ls`, `pyright`, `bashls`, `jsonls`, `cssls`, `html`.

| Keymap | Mode | Action |
|---|---|---|
| `K` | normal | Hover documentation |
| `<space>ld` | normal | Go to definition |
| `<space>lD` | normal | Go to declaration |
| `<space>lr` | normal | Show all references |
| `<space>li` | normal | Go to implementation |
| `<space>lt` | normal | Go to type definition |
| `<space>ln` | normal | Rename symbol |
| `<space>la` | normal | Code action (fixes, refactors) |
| `<space>lf` | normal | Format buffer |
| `<space>ls` | normal | Signature help |
| `<space>le` | normal | Show diagnostic float for current line |
| `[d` | normal | Jump to previous diagnostic |
| `]d` | normal | Jump to next diagnostic |
| `<space>lq` | normal | Send diagnostics to location list |

**Mason commands:**

| Command | Action |
|---|---|
| `:Mason` | Open Mason UI — install/uninstall/update servers |
| `:MasonUpdate` | Update Mason's registry |
| `:LspInfo` | Show which servers are attached to the current buffer |
| `:LspRestart` | Restart all LSP clients for the current buffer |

## Completion (nvim-cmp + LuaSnip)

Active in insert mode. Completion menu appears automatically via LSP, bufrer words, paths, and snippets.

| Keymap | Mode | Action |
|---|---|---|
| `Ctrl+Space` | insert | Manually trigger completion menu |
| `Tab` | insert | Select next item / expand or jump through snippet |
| `Shift+Tab` | insert | Select previous item / jump backward through snippet |
| `Enter` | insert | Confirm selected item (only if explicitly selected) |
| `Ctrl+e` | insert | Abort / close completion menu |
| `Ctrl+b` | insert | Scroll documentation popup up |
| `Ctrl+f` | insert | Scroll documentation popup down |
| `Alt+e` | insert | Autopairs fast-wrap — wraps next word/expression in a pair |

## Comment.nvim

Smart commenting using the correct token for the current language (works in JSX, Vue, etc.).

| Keymap | Mode | Action |
|---|---|---|
| `gcc` | normal | Toggle line comment on current line |
| `gbc` | normal | Toggle block comment on current line |
| `gc` | visual | Toggle line comment on selection |
| `gb` | visual | Toggle block comment on selection |
| `gcap` | normal | Toggle comment on a paragraph (text object) |

## Undo Tree

Visual undo history — Vim's undo is a tree, not a line; this lets you navigate it.
Requires `undofile = true` (already set in your options).

| Keymap | Mode | Action |
|---|---|---|
| `<space>uu` | normal | Toggle the undo tree panel |

**Inside the undo tree panel:**

| Keymap | Action |
|---|---|
| `j` / `k` | Move between undo states |
| `Enter` | Restore the selected undo state |
| `p` | Preview the diff at the selected state |
| `q` | Close the panel |

## Obsidian Notes

Only active inside your vault directory (`~/obsidian-vault/**/*.md` by default).
Update the vault path in `lua/plugins/obsidian.lua` to match where your vault actually lives.

| Keymap | Mode | Action |
|---|---|---|
| `<space>od` | normal | Open today's daily note (creates it if missing) |
| `<space>oy` | normal | Open yesterday's daily note |
| `<space>om` | normal | Open tomorrow's daily note |
| `<space>os` | normal | Full-text search across the vault (Telescope) |
| `<space>of` | normal | Quick switch — fuzzy-find a note by filename |
| `<space>on` | normal | Create a new note (prompts for title) |
| `<space>oo` | normal | Follow `[[wikilink]]` or URL under cursor |
| `<space>ob` | normal | Show backlinks — all notes that link to this one |
| `<space>ol` | normal | Insert a link to another note at cursor |
| `<space>oc` | normal | Toggle checkbox state on current line |
| `<space>or` | normal | Rename note and update all links to it |
| `<space>oO` | normal | Open current note in the Obsidian app |

**Wikilink completion:** inside `[[` in insert mode, the completion menu will suggest note titles automatically.


## Treesitter

Mostly automatic (syntax highlighting + indentation) — no keymaps needed for basic use.

| Command | Action |
|---|---|
| `:TSInstall <language>` | Manually install a parser, e.g. `:TSInstall python` |
| `:TSUpdate` | Update all installed parsers |
| `:checkhealth nvim-treesitter` | Verify treesitter is working correctly |

## Plugin Manager (lazy.nvim)

| Command | Action |
|---|---|
| `:Lazy` | Open the plugin manager UI (install/update/status) |
| `:Lazy update` | Update all plugins |
| `:Lazy sync` | Install missing plugins, remove unused ones, update the rest |

## Useful Built-in Commands

| Command | Action |
|---|---|
| `:checkhealth` | Run diagnostics — flags missing dependencies (git, ripgrep, compilers, etc.) |
| `:Lazy` | See installed plugin versions/status |
| `Cmd+F` (in this file) | Search this cheatsheet |

## Installed Plugins

| Plugin | Purpose |
|---|---|
| [rose-pine/neovim](https://github.com/rose-pine/neovim) | Colorscheme (moon variant, matches WezTerm) |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder for files/text/buffers/help |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Better syntax highlighting & indentation |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Inline git change indicators & hunk actions |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | VSCode-style diff/change review panel |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal + dedicated lazygit terminal |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Rendered markdown preview in buffer |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer tree |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap popup — shows available keys after a prefix |
| [undotree](https://github.com/mbbill/undotree) | Visual undo history tree |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets, quotes, etc. |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Smart line & block commenting |
| [nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) | Highlight colour literals in-buffer |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP / formatter / linter installer |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server configuration |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Obsidian vault integration |
| [mini.diff](https://github.com/echasnovski/mini.diff) | Unified inline diff overlay (narrow-pane-friendly alternative to Diffview) |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Notifier only - floating toast notifications instead of plain vim.notify |
