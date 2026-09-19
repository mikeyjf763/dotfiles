#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not with sudo - it calls sudo itself"
  echo "only for the darwin-rebuild step."
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# See bootstrap.sh: libgit2 enforces git's safe.directory ownership check
# even under sudo, so root needs this to fetch the git+file flake input.
# -H forces HOME to root's actual home so this lands in root's own
# gitconfig rather than yours (this machine's sudo doesn't reset $HOME).
if ! sudo -H git config --global --get-all safe.directory | grep -qxF "$DIR"; then
  sudo -H git config --global --add safe.directory "$DIR"
fi
exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
