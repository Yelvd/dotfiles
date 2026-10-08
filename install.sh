#!/usr/bin/env bash
#
# install.sh - symlink dotfiles from this repo into your home directory.
#
# Layout: every top-level folder is a "package" whose contents mirror $HOME.
#
#   dotfiles/
#   ├── install.sh
#   ├── zsh/.zshrc                    -> ~/.zshrc
#   ├── tmux/.tmux.conf               -> ~/.tmux.conf
#   ├── vim/.vimrc                    -> ~/.vimrc
#   └── nvim/.config/nvim/init.lua    -> ~/.config/nvim/init.lua
#
# Usage:
#   ./install.sh                 link every package
#   ./install.sh zsh tmux        link only these packages
#   ./install.sh -n              dry run: show what would happen
#   ./install.sh -u [pkg...]     remove the symlinks this script created
#
# Existing files that would be overwritten are moved to
# ~/.dotfiles_backup/<timestamp>/ first, so nothing is lost.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
UNINSTALL=0
BACKED_UP=0

if [ -t 1 ]; then
  GREEN=$'\e[32m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; RED=$'\e[31m'; RESET=$'\e[0m'
else
  GREEN=""; YELLOW=""; BLUE=""; RED=""; RESET=""
fi

usage() {
  sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  ${BLUE}[dry-run]${RESET} $*"
  else
    "$@"
  fi
}

link_file() {
  local src="$1" dest="$2" rel="$3"

  # Already linked correctly
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "${GREEN}ok${RESET}      ~/$rel"
    return
  fi

  # Something else is in the way: back it up
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "${YELLOW}backup${RESET}  ~/$rel -> $BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    run mv "$dest" "$BACKUP_DIR/$rel"
    BACKED_UP=1
  fi

  echo "${GREEN}link${RESET}    ~/$rel"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

unlink_file() {
  local src="$1" dest="$2" rel="$3"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "${RED}unlink${RESET}  ~/$rel"
    run rm "$dest"
  fi
}

process_package() {
  local pkg="$1"
  local pkg_dir="$DOTFILES_DIR/$pkg"

  if [ ! -d "$pkg_dir" ]; then
    echo "${RED}error${RESET}   no package named '$pkg'" >&2
    return 1
  fi

  echo "${BLUE}==> $pkg${RESET}"
  # Link individual files (not whole directories), so apps that write
  # their own files into e.g. ~/.config/foo don't pollute the repo.
  while IFS= read -r -d '' src; do
    local rel="${src#"$pkg_dir"/}"
    local dest="$TARGET/$rel"
    if [ "$UNINSTALL" -eq 1 ]; then
      unlink_file "$src" "$dest" "$rel"
    else
      link_file "$src" "$dest" "$rel"
    fi
  done < <(find "$pkg_dir" -name .git -prune -o \( -type f -o -type l \) -print0 | sort -z)
}

# --- argument parsing ---
packages=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)   DRY_RUN=1 ;;
    -u|--uninstall) UNINSTALL=1 ;;
    -h|--help)      usage 0 ;;
    -*)             echo "unknown option: $1" >&2; usage 1 ;;
    *)              packages+=("${1%/}") ;;
  esac
  shift
done

# Default: every top-level directory (hidden dirs like .git are skipped,
# as are folders starting with "_", e.g. _scripts or _docs).
if [ ${#packages[@]} -eq 0 ]; then
  for d in "$DOTFILES_DIR"/*/; do
    name="$(basename "$d")"
    [[ "$name" == _* ]] && continue
    packages+=("$name")
  done
fi

for pkg in "${packages[@]}"; do
  process_package "$pkg"
done

if [ "$DRY_RUN" -eq 0 ] && [ "$BACKED_UP" -eq 1 ]; then
  echo
  echo "${YELLOW}Existing files were backed up to $BACKUP_DIR${RESET}"
fi
