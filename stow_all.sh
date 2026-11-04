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

ARGS="-v"

PACKAGES=( "nvim" "zsh" "ranger" "ssh" "starship" "tmux" "tridactyl" )

print_usage() {
  printf "Usage: stow_all.sh [-n] => stow [-n] ${PACKAGES[@]}"  
}

while getopts 'n' flag; do
  case "${flag}" in
    n) echo "Running a dry-run"; ARGS="-nv" ;;
    *) print_usage
       exit 1 ;;
  esac
done


# for pkg in "${PACKAGES[@]}"; do
echo "==> ${PACKAGES[@]}"
stow $ARGS ${PACKAGES[@]}
# done
