# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "zap"` in `configuration.nix` is intentional. It forces the good habit of declaring every Homebrew package in the Nix config instead of installing things ad-hoc, which keeps the machine reproducible. Do not soften it to `uninstall` or `none`. Users are warned about its effect in README.md; this note is for anyone tempted to change the setting itself.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- `nvim-treesitter` in `home/.config/nvim/lua/plugins/treesitter.lua` is pinned to the `main` branch, not `master`. Upstream's `master` is a legacy branch locked for Neovim <=0.11 compatibility only; `main` is the rewritten plugin required for Neovim 0.12+ and uses a different setup API (`require("nvim-treesitter").install{...}` instead of `nvim-treesitter.configs`). Do not revert to `master`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
