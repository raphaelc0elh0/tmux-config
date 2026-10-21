#!/bin/bash
# Installs this tmux configuration on the current machine.
#   ./install.sh            symlinks + plugins
#   ./install.sh --tmux     same, plus the static tmux 3.7b into ~/tools/bin (Linux x86-64)
# Idempotent. Whatever already exists at ~/.tmux.conf, ~/.tmux.conf.d and ~/.tmux/plugins/<plugin>
# and is not a symlink is moved to *.bak-YYYYMMDD-HHMMSS.
set -euo pipefail
REPO=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)

link() {  # link <target in repo> <path under $HOME>
  local target=$1 dest=$2
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$target")" ]; then
    echo "ok     $dest"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$STAMP"; echo "backup $dest.bak-$STAMP"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$target" "$dest"; echo "link   $dest -> $target"
}

echo "== plugins (pinned submodules)"
git -C "$REPO" submodule update --init --recursive
for p in tmux2k tmux-menus; do
  [ -f "$REPO/plugins/$p/README.md" ] || { echo "submodule $p is empty"; exit 1; }
done

echo "== symlinks"
link "$REPO/tmux.conf"            "$HOME/.tmux.conf"
link "$REPO/tmux.conf.d"          "$HOME/.tmux.conf.d"
link "$REPO/plugins/tmux2k"       "$HOME/.tmux/plugins/tmux2k"
link "$REPO/plugins/tmux-menus"   "$HOME/.tmux/plugins/tmux-menus"

if [ "${1:-}" = "--tmux" ]; then
  echo "== static tmux 3.7b (mjakob-gh/build-static-tmux)"
  URL=https://github.com/mjakob-gh/build-static-tmux/releases/download/v3.7b/tmux.linux-amd64.stripped.gz
  SHA=20b9aa6a74db19981005cbe46e40880a3b906cc16773c5f054348145b00f3e50
  mkdir -p "$HOME/tools/bin" "$HOME/.local/bin"
  TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
  curl -fsSL "$URL" | gunzip > "$TMP"
  echo "$SHA  $TMP" | sha256sum -c - >/dev/null
  install -m 755 "$TMP" "$HOME/tools/bin/tmux"
  ln -sfn "$HOME/tools/bin/tmux" "$HOME/.local/bin/tmux"
  echo "ok     $("$HOME/tools/bin/tmux" -V) at ~/tools/bin/tmux (symlink at ~/.local/bin/tmux)"
fi

echo "== load test (throwaway server)"
tmux -L tmux-config-test -f "$HOME/.tmux.conf" new-session -d -s test -x 120 -y 30
sleep 1
tmux -L tmux-config-test show -gv status-format | head -c 120; echo
tmux -L tmux-config-test kill-server 2>/dev/null || true
echo "done. Server already running: reload with prefix+r (or 'tmux source-file ~/.tmux.conf');"
echo "no server: the next session starts with the new config."
