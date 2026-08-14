{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    dock.minimize-to-application = true;  # minimized windows fold into the app's dock icon instead of their own thumbnail
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click

    # AltTab: only the plain preference toggles are declared here. The
    # keyboard shortcut binding (Hold -> Cmd) is stored as an opaque
    # NSKeyedArchiver blob, not a plain value, so it can't be expressed
    # through CustomUserPreferences - rebind it by hand once per machine via
    # AltTab's menu bar icon -> Preferences -> Shortcut -> Hold -> Cmd.
    # Accessibility and Screen Recording permissions also require a manual
    # grant in System Settings; macOS doesn't allow those to be pre-approved.
    CustomUserPreferences."com.lwouis.alt-tab-macos" = {
      previewFocusedWindow = true;
      appearanceStyle = 1;
      appearanceSize = 1;
    };
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;  # take over the existing /opt/homebrew install instead of erroring
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "gh"
      "glab"       # GitLab CLI
      "azure-cli"
      "bat"
    ];
    # Claude Code is intentionally NOT a cask - it's installed by bootstrap.sh
    # via Anthropic's self-updating installer into ~/.local/bin. Managing it
    # here fought that copy and broke the switch behind a corporate VPN.
    casks = [
      "alt-tab"
      "wezterm"
      "obsidian"
    ];
  };
}
