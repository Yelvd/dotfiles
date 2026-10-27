# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git tmux fzf zsh-autosuggestions zsh-syntax-highlighting zsh-ssh)


## TMUX
ZSH_TMUX_AUTOSTART=true


source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
alias vim="nvim"
alias ra='ranger'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=$(cat $HOME/.rangerdir); cd "$LASTDIR"'
alias lg='lazygit'
alias open='xdg-open'

MNT_DIR=/home/jelle/mnt

mn() {
  remote=$(awk -F ":" '{print $1}' <<< "$1")
  dir=$(awk -F ":" '{print $2}' <<< "$1")
  des="$MNT_DIR/$remote"

  mkdir -p $des
  sshfs $1 $des
  if [ $? -eq 0 ]; then
    echo "Sucsefully mounted $1 -> $des"
  fi
}

um() {
  fusermount -u $MNT_DIR/$1
  if [ $? -eq 0 ]; then
    echo "Sucsefully unmounted $MNT_DIR/$1"
  fi
}

# ssh inside tmux: tint the pane, show a red label with the host, rename the window
# ssh inside tmux: tint the pane, show a red label with the host, rename the window
       # set -p -t $pane window-style 'bg=#181926' \; \
       # set -p -t $pane window-active-style 'bg=#181926' \; \
ssh() {
  if [[ -z $TMUX ]]; then command ssh "$@"; return; fi
  local host pane=$TMUX_PANE
  host=$(command ssh -G "$@" 2>/dev/null | awk '/^host /{print $2; exit}')
  tmux set -p -t $pane @ssh_host "${host:-ssh}" \; \
       set -w -t $pane pane-border-status bottom \; \
       set -w -t $pane pane-border-format '#{?@ssh_host,#[fg=#181926#,bg=#ed8796#,bold] 󰣀 #{@ssh_host} #[default],}' \; \
       rename-window -t $pane "󰣀 ${host:-ssh}"
  {
    TERM=xterm-256color command ssh "$@"
  } always {
    # runs however ssh ends: normal exit, failed login or Ctrl-C
    tmux set -pu -t $pane @ssh_host \; \
         set -pu -t $pane window-style \; \
         set -pu -t $pane window-active-style
    # remove the label line only if no other pane in this window is still on ssh
    if [[ -z $(tmux list-panes -t $pane -F '#{@ssh_host}') ]]; then
      tmux set -wu -t $pane pane-border-status \; \
           set -wu -t $pane pane-border-format \; \
           set -w -t $pane automatic-rename on
    fi
  }
}

# Setup starship prompt
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}
eval "$(starship init zsh)"
[ -f ~/.config/zsh/catppuccin.zsh ] && source ~/.config/zsh/catppuccin.zsh

export EDITOR=nvim
export VISUAL=nvim

# VMs in usesr space
export LIBVIRT_DEFAULT_URI=qemu:///session

# Source default python env
source ~/.venvs/default/bin/activate
eval "$(uv generate-shell-completion zsh)"
