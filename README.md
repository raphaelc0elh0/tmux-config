# tmux-config

Configuração do tmux do Raphael: `tmux.conf`, a barra só-mouse (`tmux.conf.d/mouse.conf`) e os dois
plugins como submódulos pinados ([tmux2k](https://github.com/2KAbhishek/tmux2k) para a barra,
[tmux-menus](https://github.com/jaclu/tmux-menus) para o menu ☰). Pensada para terminal web em celular
(ttyd) e para o Claude Code: Esc imediato, `extended-keys`, abas clicáveis, menus de botão direito em português.

## Instalar

```bash
git clone --recurse-submodules https://github.com/raphaelc0elh0/tmux-config.git ~/raphael/tmux-config
~/raphael/tmux-config/install.sh          # links + plugins
~/raphael/tmux-config/install.sh --tmux   # idem + tmux 3.7b estático em ~/tools/bin (Linux x86-64)
```

O `install.sh` cria links (`~/.tmux.conf`, `~/.tmux.conf.d`, `~/.tmux/plugins/{tmux2k,tmux-menus}`)
apontando para o clone, guarda o que já existia em `*.bak-<data>` e carrega a config num servidor
descartável para pegar erro de sintaxe. A pasta do clone pode ser outra; os links seguem o repo.

## Requisitos

| O quê | Por quê |
|---|---|
| tmux **≥ 3.7** | botões de verdade na barra (`range=control\|N`, clique na borda superior). Com 3.4 a config carrega igual, mas cai no `%else` do `mouse.conf`: faixa "Ações" na borda inferior que abre um menu |
| Nerd Font no terminal | ícones do tmux2k |
| `bash`, `awk`, `/proc` | plugins `cpu` e `ram` do tmux2k; `btop` opcional (clique em cpu/ram abre) |

Se o tmux ≥ 3.7 não está no `/usr/bin`, o `tmux.conf` fixa o `PATH` do servidor em `~/tools/bin:~/.local/bin:…`
(`%if` por versão) para que os `run-shell` dos plugins falem com o servidor certo — detalhe que custou caro no ttyd.

## Layout (tmux ≥ 3.7)

- **Topo** (1 linha): sessão (clique → lista de sessões) · `☰ Menu` (tmux-menus) · ram · cpu · hora UTC.
- **Rodapé**: abas na borda inferior do painel. Clique troca, botão do meio fecha, botão direito abre menu,
  duplo clique no vazio cria janela. Só as janelas 1–9 são clicáveis (limite de 10 controles do tmux).
- Botão direito no painel: nova janela, dividir, zoom, igualar, colar, fechar.
- Fundo da barra transparente (`@tmux2k-bg-main default`).

## Teclas

| Tecla | Faz |
|---|---|
| `C-b s` / `C-b w` | sessões / sessões+janelas, com preview |
| `C-b \|` / `C-b -` | dividir na mesma pasta |
| `C-b =` | colunas iguais |
| `Alt+setas` | mover entre painéis |
| `C-b N` | nova sessão pelo nome |
| `C-b r` | recarregar config |
| `C-b \` | tmux-menus |

## Atualizar um plugin

```bash
git -C plugins/tmux2k pull origin main   # ou checkout de um commit
git add plugins/tmux2k && git commit -m "tmux2k: <versão>"
```

O `mouse.conf` reaproveita peças internas do tmux2k (`plugins/session.sh`, `lib/popup_handler.sh`) e troca
`bg=#000000` por `bg=default` nos formatos de aba por `sed`; se o upstream renomear algo, é aqui que quebra.
