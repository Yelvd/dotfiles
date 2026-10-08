# ~/.config/zsh/catppuccin.zsh
# Catppuccin Macchiato look for zsh + fzf + starship.
# Source this from the END of your ~/.zshrc (after oh-my-zsh is loaded):
#   [ -f ~/.config/zsh/catppuccin.zsh ] && source ~/.config/zsh/catppuccin.zsh

# --- autosuggestions: subtle grey that fits the theme ------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6e738d"

# --- fzf: Catppuccin Macchiato colors + nicer layout -----------------------------
export FZF_DEFAULT_OPTS=" \
  --height=40% --layout=reverse --border=rounded --info=inline \
  --prompt='❯ ' --pointer='▶' --marker='✓' \
  --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
  --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
  --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
  --color=selected-bg:#494d64,border:#5b6078,label:#cad3f5"

# Use fd (faster, respects .gitignore) when it is installed
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# File preview in Ctrl-T when bat is installed (Debian/Ubuntu call it batcat)
if command -v bat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
elif command -v batcat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:300 {}'"
fi

# Key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd
# (needs fzf 0.48+; on older versions source /usr/share/doc/fzf/examples/key-bindings.zsh)
command -v fzf >/dev/null && source <(fzf --zsh)

# --- prompt ------------------------------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"

# --- prompt markers (OSC 133) so tmux can jump between commands --------------
_osc133_prompt() { print -n '\e]133;A\e\\' }
_osc133_output() { print -n '\e]133;C\e\\' }
precmd_functions+=(_osc133_prompt)
preexec_functions+=(_osc133_output)
