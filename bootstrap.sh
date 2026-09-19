#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not with sudo - it calls sudo itself"
  echo "only for the steps that need root. Running the whole script as root"
  echo "makes whoami/\$HOME resolve to root, which breaks the username"
  echo "detection in Step 3 and the git ownership fix in Step 4."
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 4: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"
# The flake is fetched as a git+file input, and libgit2 enforces git's
# safe.directory ownership check even under sudo - root doesn't own a repo
# that lives under your home dir, so it refuses to open it without this.
# -H forces HOME to root's actual home (from the password db) so this lands
# in root's own gitconfig - this machine's sudo doesn't reset $HOME on its
# own, and a plain `sudo git config --global` would silently write into
# your own gitconfig instead of root's, leaving root's check still failing.
if ! sudo -H git config --global --get-all safe.directory | grep -qxF "$DIR"; then
  sudo -H git config --global --add safe.directory "$DIR"
fi
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Step 5: Claude Code (best effort)"
# Claude Code is installed via Anthropic's official installer, not Homebrew:
# it self-updates and lives in ~/.local/bin, so managing it as a cask just
# adds a second copy. The download can fail behind a corporate proxy/VPN
# (e.g. Zscaler TLS interception), so this step is allowed to fail without
# aborting the whole bootstrap - re-run it later on an unrestricted network.
if command -v claude >/dev/null 2>&1; then
  echo "    claude already installed, skipping"
elif curl --proto '=https' --tlsv1.2 -fsSL https://claude.ai/install.sh | bash; then
  echo "    claude installed"
else
  echo "    WARNING: claude install failed (likely a VPN/proxy blocking the download)."
  echo "    Everything else is set up. Re-run this to retry:"
  echo "      curl -fsSL https://claude.ai/install.sh | bash"
fi

echo "==> Step 6: pi coding agent (best effort)"
# pi is installed via npm, not Homebrew or Nix, so it can pull its own updates
# the same way Claude Code does. This step is allowed to fail without aborting
# the whole bootstrap - re-run it later if npm/the registry isn't reachable.
if command -v pi >/dev/null 2>&1; then
  echo "    pi already installed, skipping"
elif npm install -g @earendil-works/pi-coding-agent; then
  echo "    pi installed"
else
  echo "    WARNING: pi install failed."
  echo "    Everything else is set up. Re-run this to retry:"
  echo "      npm install -g @earendil-works/pi-coding-agent"
fi

echo "==> Step 7: Herdr Plus plugin (best effort)"
# Pin third-party executable code to an audited commit. Herdr stores the cloned
# runtime under ~/.config/herdr/plugins, which is intentionally gitignored.
HERDR_PLUS_REF="f38df3570bea8f7ca71dc1ba11bce3b123d14402"
if ! command -v herdr >/dev/null 2>&1; then
  echo "    WARNING: herdr is unavailable; run ./rebuild.sh, then retry this step."
elif herdr plugin action list --plugin cloudmanic.herdr-plus >/dev/null 2>&1; then
  echo "    Herdr Plus already installed, skipping"
elif herdr plugin install cloudmanic/herdr-plus --ref "$HERDR_PLUS_REF" -y; then
  echo "    Herdr Plus installed"
else
  echo "    WARNING: Herdr Plus install failed."
  echo "    Everything else is set up. Re-run this command later:"
  echo "      herdr plugin install cloudmanic/herdr-plus --ref $HERDR_PLUS_REF -y"
fi

echo "==> Step 8: Matt Pocock's Claude Code skills (best effort)"
# Installed via the skills.sh CLI (npx skills), not tracked by home-manager:
# it writes plain copied files under ~/.claude/skills/<name>, so re-running
# this step is how you pick up new/updated skills on a fresh machine. The
# list below deliberately excludes migrate-to-shoehorn and scaffold-exercises
# (tied to Matt Pocock's own course/shoehorn tooling, not general use) and
# their code-review skill is kept - it replaces Anthropic's official
# code-review plugin, which is disabled in home/.claude/settings.json.
MATT_POCOCK_SKILLS=(
  ask-matt code-review codebase-design diagnosing-bugs domain-modeling
  grill-with-docs implement improve-codebase-architecture prototype research
  resolving-merge-conflicts setup-matt-pocock-skills tdd to-spec to-tickets
  triage wayfinder wizard grill-me grilling handoff teach to-questionnaire
  wait-what writing-for-agents claude-handoff implement-spec loop-me retro
  setup-ts-deep-modules writing-beats writing-fragments writing-shape
  git-guardrails-claude-code setup-pre-commit
)
SKILL_ARGS=()
for skill in "${MATT_POCOCK_SKILLS[@]}"; do
  SKILL_ARGS+=(-s "$skill")
done
if npx --yes skills@latest add mattpocock/skills -g --agent claude-code -y "${SKILL_ARGS[@]}"; then
  echo "    skills installed"
else
  echo "    WARNING: skills install failed."
  echo "    Everything else is set up. Re-run this step later once npm/the registry is reachable."
fi

echo "==> Step 9: unslop writing skill (best effort)"
# From cursor/plugins' pstack bundle (https://github.com/cursor/plugins), which
# has ~80 skills total - only unslop is pulled in, not the rest of pstack.
# --full-depth is required: pstack nests each skill under
# <plugin>/skills/<name>/SKILL.md instead of a root-level SKILL.md.
if npx --yes skills@latest add cursor/plugins -g --agent claude-code -y --full-depth -s unslop; then
  echo "    unslop installed"
else
  echo "    WARNING: unslop install failed."
  echo "    Everything else is set up. Re-run this step later once npm/the registry is reachable."
fi

echo "==> Done. Use ./rebuild.sh for future changes."
