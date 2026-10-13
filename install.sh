#!/usr/bin/env bash
#
# install.sh - link dotfiles into your home folder.
#
# Every top-level folder is a package that mirrors $HOME:
#   nvim/.config/nvim     -> ~/.config/nvim     (whole folder)
#   zsh/.zshrc            -> ~/.zshrc
#   tmux/.tmux.conf       -> ~/.tmux.conf
#
# Usage:
#   ./install.sh              link all packages
#   ./install.sh nvim zsh     link only these packages
#
# Whatever is already at a target path is REPLACED (no backups).

set -euo pipefail
shopt -s dotglob nullglob

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Shared folders: link the things inside them, never the folder itself.
SHARED=" .config .local .local/share .local/bin .ssh "

link() { # $1 = source in the repo, $2 = path relative to $HOME
  local src="$1" rel="$2" dest="$HOME/$2"

  if [ -d "$src" ] && [[ "$SHARED" == *" $rel "* ]]; then
    mkdir -p "$dest"
    for child in "$src"/*; do
      link "$child" "$rel/$(basename "$child")"
    done
  elif [ "$(readlink "$dest" || true)" = "$src" ]; then
    echo "ok    ~/$rel"
  else
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "link  ~/$rel"
  fi
}

packages=("$@")
if [ ${#packages[@]} -eq 0 ]; then
  for dir in "$DOTFILES"/*/; do
    name="$(basename "$dir")"
    [[ "$name" == .* || "$name" == _* ]] && continue # skip .git, _notes, ...
    packages+=("$name")
  done
fi

for pkg in "${packages[@]}"; do
  pkg="${pkg%/}"
  echo "==> $pkg"
  for item in "$DOTFILES/$pkg"/*; do
    case "$(basename "$item")" in .git | .gitignore | README*) continue ;; esac
    link "$item" "$(basename "$item")"
  done
done
