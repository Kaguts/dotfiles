# Tips — prise en main rapide

Pense-bête condensé pour retrouver vite les raccourcis et commandes les plus
utiles. Pour le détail complet, voir [USAGE.md](USAGE.md) et les README de
chaque dossier (notamment [wezterm/README.md](wezterm/README.md)).

## ⚠️ À savoir avant de commencer

- **WezTerm et tmux utilisent le même préfixe : `Ctrl+a`** (avec un délai de
  1.5s pour WezTerm). Si tu lances tmux *dans* WezTerm, le premier `Ctrl+a`
  est intercepté par WezTerm. Deux options : utilise les raccourcis WezTerm
  pour les splits/onglets (pas besoin de tmux dans ce cas), ou n'utilise tmux
  que dans un terminal qui n'est pas WezTerm (ex: connexion SSH directe).
- **Alias serveurs perso** : copie [.shell/alias_srv.example](.shell/alias_srv.example)
  vers `~/.shell/alias_srv` (non versionné) pour tes propres alias SSH —
  ou utilise `addsrv` qui le fait pour toi.
- Après toute modif de `.shell/alias`, `starship.toml`, `sheldon/plugins.toml`...
  tape `reload` pour recharger le shell sans rouvrir un terminal.

## 🖥️ WezTerm — `LEADER` = `Ctrl+a`

| Touche | Action |
|---|---|
| `LEADER -` | Split vertical |
| `LEADER \` | Split horizontal |
| `LEADER z` | Zoom / dézoom le pane actif |
| `LEADER w` | Fermer le pane |
| `LEADER h/j/k/l` | Naviguer entre panes (vim-like) |
| `Alt + ←/→/↑/↓` | Redimensionner le pane actif |
| `LEADER c` | Nouvel onglet |
| `LEADER x` | Fermer l'onglet |
| `LEADER n` / `LEADER p` | Onglet suivant / précédent |
| `LEADER 1`...`9` | Aller à l'onglet N |
| `LEADER Espace` | Mode copie |
| `LEADER y` | Copier la sélection |
| `LEADER r` | Recharger la config WezTerm |
| `LEADER s` | Changer/créer un workspace (zoxide) |
| `LEADER Maj+s` | Revenir au workspace précédent |
| `Ctrl+Shift+T` | Nouvel onglet |
| `Ctrl+Shift+E` / `Ctrl+Shift+O` | Split horizontal / vertical |
| `Ctrl+Shift+F` | Recherche dans le scrollback |
| `Ctrl+Shift+P` | Palette de commandes |
| `Ctrl+Shift+L` | Launcher (onglets, workspaces, domaines) |
| `Ctrl+Shift+=` / `Ctrl+Shift+-` | Taille de police +/- |
| `Ctrl+0` | Réinitialiser la taille de police |

Fond d'écran (backdrops, si configuré dans `wezterm/backdrops/`) :
`LEADER ]` / `LEADER [` (suivant/précédent), `LEADER b` (on/off).

**Plugins** : seul `smart_workspace_switcher` est actif (`LEADER+s`). 6 autres
sont pré-clonés mais désactivés — voir le tableau dans
[wezterm/README.md](wezterm/README.md#-plugins) pour les activer.

## 🪟 tmux — préfixe `Ctrl+a`

| Touche | Action |
|---|---|
| `Ctrl+a \|` | Split vertical |
| `Ctrl+a -` | Split horizontal |
| `Ctrl+a r` | Recharger `~/.tmux.conf` |
| Souris | Changer de pane / redimensionner |
| `v` puis `y` (mode copie vi) | Sélectionner puis copier |

## 🐚 Shell

- **Tab** sur une complétion → menu interactif fzf (filtre en tapant, Entrée pour valider)
- **Flèche droite** sur une suggestion grisée → l'accepte
- `z <mot-clé>` → va dans un dossier déjà visité (zoxide) ; `zi` pour choisir parmi plusieurs résultats
- `reload` → recharge `~/.zshrc`

### Alias `ls` (eza)

| Alias | Équivalent |
|---|---|
| `ls` | `eza` avec icônes, groupes, dossiers d'abord |
| `ll` / `lart` | `ls -lart` (tout, tri par date, ordre inversé) |
| `la` | `ls -a` (système) |
| `lh` | `ls -lh` (système) |

### Fonctions utiles

`mkcd <dir>`, `ff <nom>`, `fstr <texte>`, `extract <archive>`, `myip`,
`topmem`, `topcpu`, `h <mot>` (recherche historique).

## 🔧 Git (`git/aliases.gitconfig`)

| Alias | Action |
|---|---|
| `git st` | status court |
| `git lg` | log graphique condensé |
| `git amend` | amend sans changer le message |
| `git unstage <f>` | retire du staging |
| `git aliases` | liste tous les alias git |

Plus dans `.shell/alias` : `gco`, `gf`, `grh`, `gstash`, `gpop`, `gplr`, `girb`...

## 🐳 Docker

`dstatus`, `dlogs`, `dexec`, `dbuild`, `dip`, `dstopa`/`dstarta` (tout
stop/start), `dcleanc`/`dcleani` (nettoyage containers/images).
Compose v2 : `dcup`, `dcdown`, `dcrestart`, `dclogs`, `dcrebuild`, `dcls`.

## 🛡️ Sécu / Pentest

```bash
rustscan -a <ip>                          # scan de ports rapide
nmap -sV -p <ports> <ip>                  # scan détaillé sur les ports trouvés
gobuster dir -u <url> -w <wordlist>       # brute-force répertoires/fichiers
nuclei -u <url> -t <templates>            # scan de vulnérabilités
lynis audit system                        # audit sécurité système (root)
```

Wordlists : `~/tools/SecLists/` (ex: `~/tools/SecLists/Discovery/Web-Content/common.txt`).

## ☁️ Infra / Conteneurs

- `lazydocker` — TUI Docker · `dive <image>` — layers d'une image · `k9s` — TUI Kubernetes
- `tenv tf use <version>` — bascule de version Terraform
- `direnv allow` — au premier `cd` dans un dossier avec `.envrc`

## 📊 Divers

- `dysk` — utilisation disque (tableau coloré), utilisé par le motd
- `gping <host>` — ping avec graphique
- `glow <fichier.md>` — Markdown formaté dans le terminal

## 🆕 Sur une nouvelle machine

```bash
git clone <url-du-repo> ~/dotfiles
cd ~/dotfiles
./install.sh --tools
```

Voir [README.md](README.md) pour la compatibilité Debian/RHEL/sans-root.
