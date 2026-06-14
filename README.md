# Dotfiles

![Version](https://img.shields.io/badge/version-1.0-blue)

Configuration personnelle (Debian 13) pour le shell, l'éditeur et le terminal.
Pensée pour être appliquée rapidement sur une nouvelle machine via `install.sh`.

👉 Pour l'utilisation au quotidien (alias, raccourcis, prompt...), voir [USAGE.md](USAGE.md).
👉 Pour un pense-bête condensé (raccourcis WezTerm/tmux, alias...), voir [TIPS.md](TIPS.md).

## Structure

- [.zshrc](.zshrc) — config Zsh, plugins gérés par [Sheldon](https://github.com/rossmacarthur/sheldon)
- [.vimrc](.vimrc) — config Vim (éditeur par défaut du shell ; le développement se fait dans VSCode)
- [.tmux.conf](.tmux.conf) — config tmux (préfixe Ctrl+a, souris, mode vi)
- [.shell/](.shell/) — alias, fonctions et scripts shell perso
  - `alias` — alias et fonctions (eza, docker, git, outils CLI modernes...)
  - `alias_srv.example` — modèle pour tes alias SSH perso (non versionnés)
  - `motd` — message d'accueil du shell
  - `man_alias_*.sh` — mini "manuels" pour les alias
  - `add_srv.sh` — script d'ajout de serveur
- [sheldon/](sheldon/) — gestionnaire de plugins Zsh (voir [sheldon/README.md](sheldon/README.md))
- [starship.toml](starship.toml) — prompt Starship orienté DevOps/sécu (git, Docker, k8s, AWS, Terraform, Python venv)
- [wezterm/](wezterm/) — config WezTerm modulaire + plugins (voir [wezterm/README.md](wezterm/README.md))
- [git/aliases.gitconfig](git/aliases.gitconfig) — alias git complémentaires, inclus depuis `~/.gitconfig`
- [install.sh](install.sh) — bootstrap : crée les liens symboliques et installe les outils

## Installation sur une nouvelle machine

```bash
git clone https://github.com/Kaguts/dotefiles.git ~/dotfiles
cd ~/dotfiles

# Liens symboliques uniquement
./install.sh

# Liens symboliques + installation des outils CLI (apt, starship, sheldon)
./install.sh --tools
```

### Mettre à jour les liens (dépôt déplacé/renommé)

Si tu déplaces ou renommes le dossier du repo, les liens symboliques et
l'`include.path` git pointent encore vers l'ancien emplacement. Relance
simplement :

```bash
./install.sh --update
```

Cela recrée tous les liens symboliques vers le nouvel emplacement et nettoie
les anciennes références `include.path` obsolètes dans `~/.gitconfig`.

Le script sauvegarde les fichiers existants dans `~/.dotfiles_backup/<date>/`
avant de créer les liens.

### Compatibilité distro / droits root

`--tools` détecte automatiquement l'environnement :

- **Debian/Ubuntu** (`apt`) : installation complète via les paquets officiels.
- **RHEL-like** (Rocky, Alma, CentOS — `dnf`/`yum`) : active EPEL et installe
  ce qui est packagé (`ripgrep`, `fzf`, `bat`, `fd-find`, `tmux`, `btop`,
  `nmap`, `lynis`, `httpie`, `direnv`, `ansible`, `vim-enhanced`, `xclip`...).
  Les outils non packagés sur RHEL-like (`eza`, `zoxide`, `lazygit`,
  `gobuster`, `gping`, `delta`, `glow`, `lazydocker`, `k9s`, `dive`, `tenv`,
  `rustscan`) sont installés en binaire dans `~/.local/bin` (voir ci-dessous).
- **Sans droits root/sudo** : l'étape des paquets système est ignorée (avec
  la liste à transmettre à un admin), mais tous les outils installables en
  binaire dans `~/.local/bin` (Starship, Sheldon, et la liste ci-dessus +
  nuclei + SecLists) sont quand même installés, car ils ne nécessitent pas
  de droits root.

Dans tous les cas, un récapitulatif final liste les outils encore absents.

## Fichiers locaux non versionnés

Certains alias référencent des fichiers spécifiques à une machine, **non
inclus dans ce repo** (secrets, IPs internes...) :

- `~/.shell/alias_srv` — alias de connexion SSH vers tes serveurs (modèle : [.shell/alias_srv.example](.shell/alias_srv.example))
- `~/.shell/remote_files.sh` — script utilisé par l'alias `remotefile`

## Stack CLI

| Classique | Moderne |
|---|---|
| `ls` | `eza` |
| `cat` | `bat` |
| `find` | `fd` |
| `grep` | `ripgrep` |
| `cd` | `zoxide` |
| `top` | `btop` |

Plus : `lazygit`, `lynis`, `nmap`, `tmux`, `fzf`, `starship`, `sheldon`,
`git diff` → `delta`.

## Outils additionnels (`--tools`)

| Outil | Catégorie | Rôle |
|---|---|---|
| `direnv` | Dev | Charge des variables d'env par dossier (`.envrc`) |
| `ansible` | Infra | Automatisation/configuration |
| `tenv` | Infra | Version manager Terraform/OpenTofu/Terragrunt |
| `lazydocker` | Conteneurs | TUI Docker |
| `dive` | Conteneurs | Analyse des layers d'image Docker |
| `k9s` | Kubernetes | TUI pour cluster k8s |
| `rustscan` | Sécu | Scanner de ports rapide |
| `nuclei` | Sécu | Scanner de vulnérabilités basé templates |
| `gobuster` | Sécu | Brute-force répertoires/fichiers web |
| `SecLists` | Sécu | Wordlists de référence (cloné dans `~/tools/SecLists`) |
| `gping` | CLI | `ping` avec graphique |
| `glow` | CLI | Affichage Markdown dans le terminal |
| `dysk` | CLI | Utilisation disque (tableau coloré, alternative à `df`) — utilisé par le motd |

Tous les outils de ce tableau (sauf `ansible` et `direnv`, packagés sur
Debian/RHEL) sont installés en binaire depuis la dernière release GitHub
(amd64) dans `~/.local/bin` — ça ne nécessite pas de droits root et
fonctionne aussi bien sur Debian que RHEL-like. Si l'archive attendue n'est
pas trouvée (changement de format de release), le script l'indique pour une
installation manuelle.

## Applis de référence

* [eza](https://github.com/eza-community/eza)
* [Lazygit](https://github.com/jesseduffield/lazygit)
* [WezTerm](https://wezterm.org/)
* [Superfile](https://github.com/yorukot/superfile)
* [Nvitop](https://github.com/XuehaiPan/nvitop?tab=readme-ov-file#installation)
* [Yazi](https://github.com/sxyazi/yazi)
* [GGH](https://laravel-news.com/ggh-is-a-lightweight-cli-to-recall-your-ssh-sessions)

## Licence

[MIT](LICENSE)
