{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    jq        # json on the command line
    lazygit
    neovim
    nodejs    # needed by nvim's Mason to install most LSP servers (ts_ls, pyright, bashls, jsonls, cssls, html)
    tree-sitter # CLI required by nvim-treesitter's `main` branch to compile parsers (e.g. python)
    go        # also what Claude Code's gopls-lsp plugin shells out to
    eza       # ls/ll replacement
    zoxide    # smart cd
    # the font everything renders in
    nerd-fonts.fira-code
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  # claude installs itself here; home-manager owns .zshenv/.zshrc so this must
  # be declared, not hand-added, or it's lost on the next switch.
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/go/bin"
  ];
  # nodejs comes from the Nix store, which is read-only, so npm's default
  # global prefix (next to the node binary) can't be written to. Point
  # global installs (e.g. `npm install -g`) at a writable dir instead.
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;  # key bindings + fuzzy completion
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept

      # nvm is installed by its own upstream installer (not nix-managed, same
      # reasoning as claude in ~/.local/bin), so just source it if present.
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # bun is installed by its own upstream installer, same reasoning as nvm.
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # Corporate work proxy, kept out of ~/.claude so it never touches
      # personal Claude credentials/history. Explicit versioned model IDs are
      # required: the proxy 400s on the "sonnet"/"opus" shorthand aliases.
      function claude-work() {
        CLAUDE_CONFIG_DIR="$HOME/.claude-work" \
        ANTHROPIC_BASE_URL=http://localhost:4141 \
        NODE_EXTRA_CA_CERTS="$HOME/.zscaler-ca-full.pem" \
        claude --model claude-sonnet-4.6 "$@"
      }

      function claude-work-opus() {
        CLAUDE_CONFIG_DIR="$HOME/.claude-work" \
        ANTHROPIC_BASE_URL=http://localhost:4141 \
        NODE_EXTRA_CA_CERTS="$HOME/.zscaler-ca-full.pem" \
        claude --model claude-opus-4.8 "$@"
      }

      # Machine-local secrets/overrides that must never enter this public
      # repo (e.g. MBDP_GITLAB_DEPLOY_TOKEN). Populate by hand per machine.
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      cat = "bat";
      # DeepSeek Harness (dsh) web profile needs --expose-internals for its
      # HMR plugin to boot, even though it's configured disabled - rc.2 bug.
      # --import fix-undici-timeout.mjs works around undici's global fetch
      # dispatcher defaulting to a 5-minute headers/body timeout, which was
      # silently killing long local-model responses that had actually
      # succeeded (confirmed in ollama's own server.log: 200 OK responses
      # followed immediately by "Request terminated: context canceled").
      dsh-web = "node --expose-internals --import /Users/mikefurlong/.dsh/fix-undici-timeout.mjs /Users/mikefurlong/.npm-global/lib/node_modules/@deepseek-ai/dsh/lib/bin.js web";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Mike Furlong";
      email = "mikey4long@gmail.com";
    };
    settings.credential.helper = "!/opt/homebrew/bin/gh auth git-credential";
    # GitLab: route gitlab.com auth through glab's credential helper.
    settings.credential."https://gitlab.com".helper = "!/opt/homebrew/bin/glab auth git-credential";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
