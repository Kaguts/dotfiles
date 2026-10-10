# Dotfiles

![Version](https://img.shields.io/badge/version-1.0-blue)

Configuration personnelle pour le shell, l'éditeur et le terminal.
Pensée pour être appliquée rapidement sur une nouvelle machine via `install.sh`,
sur Debian/Ubuntu, RHEL-like (RHEL, Rocky, Alma, Fedora) et Windows via WSL.

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

- **Debian/Ubuntu** (`apt`) : installation via les paquets officiels. Les
  paquets absents d'une version donnée (`eza`, `lazygit`, `gping`, `glow` sur
  Debian 12 ou Ubuntu 22.04) sont signalés puis installés en binaire.
- **RHEL-like** (RHEL, Rocky, Alma, CentOS, Fedora — `dnf`/`yum`) : active EPEL
  (via le RPM du projet Fedora sur RHEL) et CRB, puis installe
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

- **Architecture** : x86_64 et arm64.

Dans tous les cas, un récapitulatif final liste les outils encore absents, et
aucune étape en échec n'arrête le script. `zsh` est installé mais le shell de
connexion n'est pas changé d'office : le script rappelle la commande `chsh`.

### Windows (WSL)

Tout se passe dans la distribution WSL (Debian, Ubuntu, Rocky...) : clone le
dépôt dans le système de fichiers Linux (`~/dotfiles`, pas `/mnt/c`) et lance
`install.sh` comme sur une machine Linux.

WezTerm tourne côté Windows et ne peut pas suivre un lien symbolique créé dans
WSL. Pour y copier la config :

```bash
./install.sh --wezterm-windows
```

La config arrive dans `%USERPROFILE%\.config\wezterm` (l'ancienne est renommée
en `.bak-<date>`). C'est une copie : relance la commande après chaque
modification. WezTerm ouvre alors la distribution WSL par défaut (voir
[wezterm/config/domains.lua](wezterm/config/domains.lua)).

Prévoir côté Windows une police Nerd Font (JetBrains Mono, FiraCode Nerd Font)
pour les icônes d'`eza` et de Starship.

## Fichiers locaux non versionnés

Certains alias référencent des fichiers spécifiques à une machine, **non
inclus dans ce repo** (secrets, IPs internes...) :

- `~/.shell/alias_srv` — alias de connexion SSH vers tes serveurs (modèle : [.shell/alias_srv.example](.shell/alias_srv.example))
- `~/.shell/remote_files.sh` — script utilisé par l'alias `remotefile`
- `~/.zshrc.local` — réglages Zsh propres à la machine, sourcé en fin de `.zshrc`
- `wezterm/background.jpg` (ou `.png`) — fond d'écran WezTerm ; un lien
  symbolique vers ton image suffit. Sans ce fichier, fond uni du thème.

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
Debian/RHEL), ainsi que Starship et Sheldon, sont installés en binaire depuis
leur release GitHub (x86_64 ou arm64) dans `~/.local/bin` — ça ne nécessite pas
de droits root et fonctionne aussi bien sur Debian que RHEL-like.

### Versions figées et sommes de contrôle

`install.sh` n'installe jamais « la dernière version » :

- [tools.list](tools.list) dit **quoi** installer (dépôt GitHub, motif de l'archive) ;
- [tools.lock](tools.lock) fige **quelle version** : l'URL exacte de l'archive et
  sa somme SHA-256, pour chaque architecture.

Chaque archive téléchargée est comparée à sa somme avant extraction ; en cas
d'écart, elle est rejetée et rien n'est installé. Deux machines installées à
six mois d'intervalle obtiennent donc exactement les mêmes binaires.

Pour monter de version :

```bash
./update-tools.sh            # tous les outils
./update-tools.sh eza delta  # seulement ceux-là
git diff tools.lock          # relire avant de valider
```

Les sommes sont calculées au moment de la mise à jour, à partir de ce que
GitHub sert ce jour-là : elles garantissent que l'archive ne change pas
ensuite, pas qu'elle était saine au départ.

## Intégration continue

À chaque push, [.github/workflows/lint.yml](.github/workflows/lint.yml) lance
ShellCheck sur les scripts, vérifie la syntaxe Zsh de `.zshrc` et des alias, et
contrôle que chaque outil de `tools.list` a bien une version figée par
architecture dans `tools.lock`.

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
