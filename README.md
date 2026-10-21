# tmux-config

Raphael's tmux configuration: `tmux.conf`, the mouse-only bar (`tmux.conf.d/mouse.conf`) and the two
plugins as pinned submodules ([tmux2k](https://github.com/2KAbhishek/tmux2k) for the bar,
[tmux-menus](https://github.com/jaclu/tmux-menus) for the ☰ menu). Built for a web terminal on a phone
(ttyd) and for Claude Code: instant Esc, `extended-keys`, clickable tabs, right-click menus.

## Install

```bash
git clone --recurse-submodules https://github.com/raphaelc0elh0/tmux-config.git ~/raphael/tmux-config
~/raphael/tmux-config/install.sh          # symlinks + plugins
~/raphael/tmux-config/install.sh --tmux   # same, plus the static tmux 3.7b into ~/tools/bin (Linux x86-64)
```

`install.sh` creates symlinks (`~/.tmux.conf`, `~/.tmux.conf.d`, `~/.tmux/plugins/{tmux2k,tmux-menus}`)
pointing at the clone, keeps whatever was there as `*.bak-<date>` and loads the config in a throwaway
server to catch syntax errors. The clone can live anywhere; the symlinks follow the repo.

## Requirements

| What | Why |
|---|---|
| tmux **≥ 3.7** | real buttons on the bar (`range=control\|N`, clicks on the top border). With 3.4 the config still loads but falls into the `%else` of `mouse.conf`: an "Actions" strip on the bottom border that opens a menu |
| Nerd Font in the terminal | tmux2k icons |
| `bash`, `awk`, `/proc` | tmux2k `cpu` and `ram` plugins; `btop` optional (clicking cpu/ram opens it) |

If tmux ≥ 3.7 is not in `/usr/bin`, `tmux.conf` pins the server's `PATH` to `~/tools/bin:~/.local/bin:…`
(`%if` by version) so the plugins' `run-shell` calls talk to the right server — a detail that cost dearly under ttyd.

## Layout (tmux ≥ 3.7)

- **Top** (1 line): session (click → session list) · `☰ Menu` (tmux-menus) · ram · cpu · UTC time.
- **Bottom**: tabs on the pane's bottom border. Click switches, middle button closes, right button opens a menu,
  double click on empty space creates a window. Only windows 1–9 are clickable (tmux's limit of 10 controls).
- Right click on a pane: new window, split, zoom, even out, paste, close.
- Transparent bar background (`@tmux2k-bg-main default`).

## Keys

| Key | Does |
|---|---|
| `C-b s` / `C-b w` | sessions / sessions+windows, with preview |
| `C-b \|` / `C-b -` | split in the same directory |
| `C-b =` | equal columns |
| `Alt+arrows` | move between panes |
| `C-b N` | new session by name |
| `C-b r` | reload config |
| `C-b \` | tmux-menus |

## Sessions that survive a reboot (optional)

Wherever [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) and
[tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) are cloned under `~/.tmux/plugins/`,
`tmux.conf` loads them: saves every 15 min and restores when the server starts (`C-b C-s` / `C-b C-r` by hand).
A pane running `claude` comes back through `~/.tmux/claude-restore`, which belongs to the machine, not the repo.
Without the clones, nothing loads.

## Updating a plugin

```bash
git -C plugins/tmux2k pull origin main   # or check out a commit
git add plugins/tmux2k && git commit -m "tmux2k: <version>"
```

`mouse.conf` reuses tmux2k internals (`plugins/session.sh`, `lib/popup_handler.sh`) and swaps
`bg=#000000` for `bg=default` in the tab formats with `sed`; if upstream renames something, this is where it breaks.
