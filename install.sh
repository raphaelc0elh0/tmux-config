#!/bin/bash
# Instala esta configuração do tmux na máquina atual.
#   ./install.sh            links + plugins
#   ./install.sh --tmux     idem, e baixa o tmux 3.7b estático para ~/tools/bin (Linux x86-64)
# Idempotente. O que já existir em ~/.tmux.conf, ~/.tmux.conf.d e ~/.tmux/plugins/<plugin>
# e não for link vai para *.bak-AAAAMMDD-HHMMSS.
set -euo pipefail
REPO=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)

link() {  # link <alvo no repo> <caminho em $HOME>
  local alvo=$1 dest=$2
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$alvo")" ]; then
    echo "ok     $dest"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$STAMP"; echo "backup $dest.bak-$STAMP"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$alvo" "$dest"; echo "link   $dest -> $alvo"
}

echo "== plugins (submódulos pinados)"
git -C "$REPO" submodule update --init --recursive
for p in tmux2k tmux-menus; do
  [ -f "$REPO/plugins/$p/README.md" ] || { echo "submódulo $p vazio"; exit 1; }
done

echo "== links"
link "$REPO/tmux.conf"            "$HOME/.tmux.conf"
link "$REPO/tmux.conf.d"          "$HOME/.tmux.conf.d"
link "$REPO/plugins/tmux2k"       "$HOME/.tmux/plugins/tmux2k"
link "$REPO/plugins/tmux-menus"   "$HOME/.tmux/plugins/tmux-menus"

if [ "${1:-}" = "--tmux" ]; then
  echo "== tmux estático 3.7b (mjakob-gh/build-static-tmux)"
  URL=https://github.com/mjakob-gh/build-static-tmux/releases/download/v3.7b/tmux.linux-amd64.stripped.gz
  SHA=20b9aa6a74db19981005cbe46e40880a3b906cc16773c5f054348145b00f3e50
  mkdir -p "$HOME/tools/bin" "$HOME/.local/bin"
  TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
  curl -fsSL "$URL" | gunzip > "$TMP"
  echo "$SHA  $TMP" | sha256sum -c - >/dev/null
  install -m 755 "$TMP" "$HOME/tools/bin/tmux"
  ln -sfn "$HOME/tools/bin/tmux" "$HOME/.local/bin/tmux"
  echo "ok     $("$HOME/tools/bin/tmux" -V) em ~/tools/bin/tmux (link em ~/.local/bin/tmux)"
fi

echo "== teste de carga (servidor descartável)"
tmux -L tmux-config-test -f "$HOME/.tmux.conf" new-session -d -s teste -x 120 -y 30
sleep 1
tmux -L tmux-config-test show -gv status-format | head -c 120; echo
tmux -L tmux-config-test kill-server 2>/dev/null || true
echo "pronto. Servidor em uso: recarregue com prefix+r (ou 'tmux source-file ~/.tmux.conf');"
echo "sem servidor: a próxima sessão já sobe com a config nova."
