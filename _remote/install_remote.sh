#!/usr/bin/env bash
# Usage: ./remote-setup.sh user@host
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: $0 user@host"; exit 1; }
REMOTE="$1"
SSH_OPTS=""

# Reuse one SSH connection for everything (only one password/key prompt)
# CTRL="/tmp/ssh-ctrl-%r@%h:%p"
# SSH_OPTS=(-o ControlMaster=auto -o ControlPath="$CTRL" -o ControlPersist=60)
# trap 'ssh "${SSH_OPTS[@]}" -O exit "$REMOTE" 2>/dev/null || true' EXIT

# --- 1. Commands to run on the server (edit freely) -------------------------
ssh "$REMOTE" 'bash -s' <<'EOF'
set -e
mkdir -p ~/.local/bin ~/.config
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
grep -q 'starship init bash' ~/.bashrc || {
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(starship init bash)"' >> ~/.bashrc
}
EOF

# --- 2. Files to copy: "local_path:remote_path" (remote path relative to ~) --
FILES=(
  "$HOME/dotfiles/_remote/vimrc:.vimrc"
)

for f in "${FILES[@]}"; do
  src="${f%%:*}"; dst="${f#*:}"
  echo ">> $src -> $REMOTE:$dst"
  scp -r "$src" "$REMOTE:$dst"
done

echo "Done."
