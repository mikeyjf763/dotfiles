# dotfiles

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools)
- Nix user packages (ripgrep, fd, fzf, jq, lazygit, Neovim, Node.js, Hack Nerd Font)
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config: lazy.nvim, Mason-managed LSP/completion, Telescope, Obsidian integration, rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus pinned third-party Pi packages for orchestration, web access, browser automation, questions, and memory

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/mikeyjf763/dotfiles.git
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "mikefurlong"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh:5` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

**Git identity:** this config deliberately does not set your git name or email.
Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
If you'd rather manage that declaratively, add this back to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix`.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `brews` in your copy.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system-level config: macOS defaults, Homebrew.
- `home.nix` - user-level config: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place; the sections below explain the shared symlink model and Pi's narrower selective setup.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Optional Pi configuration

Pi is an opt-in CLI, not a dependency this repository vendors. Install it from its owner with the [official Pi instructions](https://pi.dev), for example:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

[Pi Launcher](https://github.com/kunchenguid/homebrew-tap) is also optional and installed from its owner, not declared by this config:

```sh
brew install --cask kunchenguid/tap/pi-launcher
```

Home Manager owns these repository-authored Pi directories: `~/.pi/agent/themes`, `~/.pi/agent/extensions`, `~/.pi/agent/agents`, and `~/.pi/agent/workflows`. It also links `models.json` and `settings.json` as individual files. The local extension directory is for public, repository-authored extensions only - third-party package code never belongs there. Run `/reload` after editing a local extension or other Pi resources. The terminal-title extension shows a spinner while Pi is working, then a completion mark with the session name or current directory. The `rose-pine-moon` theme was authored clean-room from the public [Rosé Pine Moon palette](https://rosepinetheme.com/palette) and Pi's [public theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json), not from a private or live theme file.

### Pi Workspace Enhancements

The linked global Pi settings install and pin these optional packages:

- `pi-herdr-subagents` - asynchronous subagents in sibling Herdr panes, with lifecycle tracking, interrupt/resume controls, and child-to-parent help requests through `caller_ping`.
- `pi-ask-user` - interactive single-select questions with a maximum of four agent-authored choices plus an always-present freeform `Other` choice.
- `pi-lean-portal` - Playwright-driven headless Chromium browsing, static `web-fetch`, session-scoped browser state, and the `/web` toggle.
- `pi-web-access` - provider-independent `web_search`, `fetch_content`, source checking, and GitHub-aware fetching. It does not depend on GitHub Copilot's native web tools.

Third-party packages remain outside the repository. Their exact npm versions are tracked in `home/.pi/agent/settings.json`, and Pi installs them into its unmanaged runtime directories on startup. Only the local policy, UI, and compatibility extensions are authored here. Review package source before enabling a package because Pi extensions run with full user permissions.

#### Herdr subagents

Start Pi from a Herdr-managed pane:

```sh
herdr
pi
```

The subagent extension keeps children in the same Herdr workspace, normally in separate panes or tabs, and keeps the parent session responsive while they run. Use the discovered `subagent`, `subagents_list`, `subagent_interrupt`, and `subagent_resume` tools. A child can call `caller_ping` to stop and ask the parent for a decision; the parent resumes it with the answer.

#### Headless browser

Browser tools are deliberately disabled in fresh conversations. Use `/web on` when interactive browsing is needed and `/web off` when finished. The browser uses headless Playwright Chromium by default and stores browser state for the current Pi conversation. Named profiles can be used when intentionally sharing authenticated state across conversations or subagents. Do not treat browser page content as trusted instructions.

After the first rebuild on a machine, install the Playwright browser binary once:

```sh
npx playwright install chromium
```

The browser package does not automatically reuse your normal Chrome profile. Authentication is opt-in through a Pi browser profile, which keeps it separate from your everyday browser.

#### Ask-user policy

`home/.pi/agent/extensions/ask-user-policy` enforces the question behavior locally. It trims agent-authored choices to four, reserves the fifth row for `Other`, enables freeform answers, and uses single-select by default. `/reload` picks up changes to the local policy.

#### Rose Pine header and context bar

`home/.pi/agent/extensions/rose-pine-ui` replaces the stock Pi header with a small Rose Pine-styled Pi workspace logo. It also adds a matching context bar showing context usage, Git branch, and the workspace controls (`ask-user` and `/web`). The header and footer are only active in Pi's interactive TUI mode.

#### Web search and fetch

The existing `pi-web-access` package is pinned and enabled. The direct test from this setup confirmed:

- `web_search` succeeds when called with `queries: ["..."]`.
- `fetch_content` successfully fetched `https://pi.dev`.
- GitHub Copilot's native web-search availability is not required.

The local `web-access-policy` extension also normalizes a serializer edge case where an empty optional `queries` array can hide a valid singular `query`.

#### Inspire MCP

Pi Code's MCP adapter reads user-scoped servers from `~/.pi/agent/mcp.json`. This repository links that file from `home/.pi/agent/mcp.json` and configures the local `inspire-mcp` server through the checked-out `inspire-cli`:

```json
{
  "mcpServers": {
    "inspire-mcp": {
      "type": "stdio",
      "command": "bun",
      "args": ["run", "bin/elliot.ts", "inspire-mcp"],
      "cwd": "${HOME}/dev/inspire-cli"
    }
  }
}
```

The `elliot` entry point performs the normal Elliot SSO and credential injection flow. It may open a browser for first-time authentication and caches credentials under `~/.elliot`; no tokens are stored in this repository. After authentication, restart Pi and run `/mcp` to inspect the connection. MCP tool names are exposed with the `inspire_mcp_` prefix.

The existing `/Users/mikefurlong/dev/inspire-cli/.mcp.json` is project-scoped and remains useful when working only in that repository. The global Pi entry makes the server discoverable from other projects as well. The local `mcp-provider-compat` extension removes only regex lookaround hints rejected by the GitHub Copilot Responses schema validator; the MCP server still validates its own arguments.

#### Reusable ticket workflow

The first composed workflow is available through the local `workflows` extension:

```text
/workflow ticket-implementation
```

Type `/workflow ` and press Tab to autocomplete workflow names from `home/.pi/agent/workflows/config.json`. Adding another workflow means adding its prompt file and registry entry; the command will offer it automatically. When no ticket follows the command, Pi opens a multiline editor for pasting it. The workflow then composes these global role agents in order:

1. `ticket-refiner` - verifies or infers acceptance criteria and records ambiguity.
2. `code-scout` - maps relevant files, symbols, behavior, and repository conventions.
3. `edge-case-detector` - produces a code-grounded natural-language behavior matrix.
4. Human Gate 1 - reviews the ticket, AC, edge cases, and proposed behavior cases through `ask_user`.
5. `test-strategy-scout` - identifies the repository's test framework, conventions, and runner.
6. `test-implementor` - writes only the approved executable test cases.
7. Human Gate 2 - reviews and approves the executable test contract.
8. `technical-planner` - creates the production implementation plan and surfaces high-impact decisions.
9. `implementer` - changes production code against the approved tests as a black box and runs the approved command.

Each role is an independent Herdr subagent with `spawning: false`. The parent remains the conductor and can resume or interrupt children. Workflow state and stage artifacts are kept in the local `~/.pi/agent/workflow-runs` runtime directory. The first runtime slice tracks one active composed workflow at a time; unrelated Herdr subagents can still run normally.

Model routing is centralized in `home/.pi/agent/workflows/config.json`. Set `defaultModel` to change every role, or override one role without changing the rest:

```json
{
  "defaultModel": "github-copilot/gpt-5.6-luna",
  "defaultThinking": "high",
  "roles": {
    "edge-case-detector": {
      "model": "github-copilot/gpt-5.6-luna",
      "thinking": "high"
    }
  }
}
```

After Gate 2, `workflow_state` records the exact test paths, runner command, and checksum. The local workflow guard blocks ordinary implementation agents from reading or modifying those paths. The selected hybrid policy is defense in depth: a same-user agent with unrestricted shell access is not a hard security boundary, so a future isolated test runner remains the stronger option.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. Home Manager's existing global extensions-directory link makes Pi auto-load it without another declaration. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository or Home Manager. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

Pi's package system declares these third-party sources in the linked global `settings.json`:

- `npm:pi-herdr-subagents@0.2.0` - async Herdr subagent orchestration.
- `npm:pi-ask-user@0.14.0` - interactive user decisions.
- `npm:pi-lean-portal@0.4.0` - disabled-by-default Playwright browser tools and `web-fetch`.
- `npm:pi-web-access@0.27.0` - provider-independent web search and content fetching.
- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6` - the exact public npm release from `ryan_nookpi`.
- `git:github.com/algal/pi-openai-server-compaction@c6d593087709e9481223dc6c6c2269b371b5e055` - the exact public `algal` commit for experimental OpenAI server-side compaction.

The versions and commit are immutable pins, so Pi does not move them during package updates. Deliberate updates require a new source and security audit, followed by an explicit pin change in `home/.pi/agent/settings.json`. Pi keeps downloaded npm and git package trees in its own unmanaged `~/.pi/agent/npm` and `~/.pi/agent/git` runtime directories, outside Home Manager and Git tracking.

All packages execute with your full user permissions and must be trusted like any other executable code. The compaction package is experimental, sends the relevant OpenAI compaction and continuity data to OpenAI, and upstream declares the stale peer range `>=0.80.9 <0.81.0`; this exact immutable ref was locally proven to load and perform remote compaction on Pi 0.82.0. Do not treat that proof as a guarantee for a different Pi version or a different package ref.

Home Manager deliberately does not manage `~/.pi/agent` itself, or Pi authentication, sessions, trust decisions, caches, npm/git package trees, or any other runtime state. The model overrides contain no credentials or endpoint settings, do not choose a default model, and only take effect after you authenticate Pi yourself. This remains an additive post-video layer: it does not install Pi, a launcher, or package source code into this repository.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Most of Neovim's LSP servers install themselves via Mason the first time you open a matching filetype; that also needs network access once, and requires Node.js (declared in `home.nix`).

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
