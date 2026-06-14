# Guide d'utilisation

Aide-mémoire pour le quotidien avec cette config.

## Shell (Zsh + Sheldon)

- `reload` — recharge `~/.zshrc` après une modif
- Flèche **droite** sur une suggestion grisée → l'accepte (zsh-autosuggestions)
- **Tab** sur une complétion → menu interactif fzf (fzf-tab) : tape pour filtrer,
  Entrée pour valider
- `z <mot-clé>` — va dans un dossier déjà visité (zoxide), plus besoin de chemin complet
  - `zi <mot-clé>` — pareil mais avec sélection interactive si plusieurs résultats

### Gérer les plugins

```bash
# Ajouter un plugin : édite ~/.config/sheldon/plugins.toml puis
sheldon lock --update
reload
```

Voir [sheldon/README.md](sheldon/README.md) pour le détail des plugins installés.

## Prompt (Starship)

Le prompt affiche automatiquement, quand pertinent :

- répertoire courant
- branche + statut git
- contexte Docker (si `Dockerfile`/`docker-compose.yml` dans le dossier)
- contexte/namespace Kubernetes (`☸ context (namespace)`)
- profil/région AWS (`AWS_PROFILE`, `AWS_REGION`)
- workspace Terraform
- venv Python actif
- durée de la dernière commande si > 2s

Pour personnaliser, édite [starship.toml](starship.toml) (chaque section est commentée),
puis `reload`. Référence complète : https://starship.rs/config/

## Alias et fonctions (`.shell/alias`)

### Outils modernes (remplacent les commandes classiques)

| Alias | Outil | Équivalent |
|---|---|---|
| `ls`, `lart` | `eza` | `ls` avec icônes/git |
| `cat` | `bat` | `cat` avec coloration syntaxique |
| `top` | `btop` | `top` |
| `fd` | `fdfind` (Debian) | `find` |
| `bat` | `batcat` (Debian) | — |

`rg` (ripgrep) et `fzf` s'utilisent directement sans alias.

### Fonctions utiles

- `mkcd <dir>` — crée un dossier et s'y déplace
- `ff <nom>` — recherche un fichier par nom (`find . -name`)
- `fstr <texte>` — recherche un texte dans tous les fichiers (`grep -rnw`)
- `extract <archive>` — décompresse selon l'extension (zip, tar.gz, 7z...)
- `myip` — affiche l'IP locale
- `topmem` / `topcpu` — top 10 process par mémoire / CPU
- `h <mot>` — recherche dans l'historique

### Connexions serveurs

Pour tes alias SSH perso, copie [.shell/alias_srv.example](.shell/alias_srv.example)
vers `~/.shell/alias_srv` et adapte-le (non versionné, voir
[README.md](README.md#fichiers-locaux-non-versionnés)), ou utilise `addsrv`
qui s'en occupe pour toi.

## tmux

Préfixe : `Ctrl+a` (au lieu de `Ctrl+b`).

- `Ctrl+a |` / `Ctrl+a -` — split vertical / horizontal (dans le dossier courant)
- `Ctrl+a r` — recharge `~/.tmux.conf`
- Souris activée : clic pour changer de pane, glisser pour redimensionner
- Mode vi en copie : `v` pour sélectionner, `y` pour copier

## Git

En plus des alias de `.shell/alias` (`gco`, `gf`, `grh`, `gplr`...), des alias
supplémentaires sont disponibles via [git/aliases.gitconfig](git/aliases.gitconfig)
(inclus automatiquement par `install.sh`) :

- `git st` — status court
- `git lg` — log graphique condensé
- `git amend` — amend sans changer le message
- `git unstage <fichier>` — retire du staging
- `git aliases` — liste tous les alias git configurés

## Sécurité & audit

- `lynis audit system` — audit de sécurité du système (à lancer en root, `/usr/sbin/lynis`)
- `nmap` — scan réseau
- `rustscan -a <ip>` — scan de ports rapide (souvent en amont d'un `nmap -sV` plus poussé)
- `nuclei -u <url> -t <templates>` — scan de vulnérabilités web par templates
- `gobuster dir -u <url> -w <wordlist>` — brute-force de répertoires/fichiers
- Wordlists : `~/tools/SecLists/` (ex: `~/tools/SecLists/Discovery/Web-Content/common.txt`)
- `man_alias` (`agit`, `adocker`, `asys`, `asysf`) — mini manuels pour
  retrouver rapidement les alias disponibles par thème

## Conteneurs & Kubernetes

- `lazydocker` — TUI pour gérer containers/images/volumes Docker
- `dive <image>` — explore les layers d'une image Docker (taille, fichiers ajoutés/modifiés)
- `k9s` — TUI pour naviguer/gérer un cluster Kubernetes (utilise le contexte `kubectl` courant,
  affiché dans le prompt Starship)

## Infra as Code

- `direnv` — au premier `cd` dans un dossier avec un `.envrc`, tape `direnv allow`
  pour charger automatiquement ses variables d'env (utile pour switcher entre
  projets/clients sans polluer le shell global)
- `tenv` — version manager Terraform/OpenTofu/Terragrunt :
  ```bash
  tenv tf install latest   # installe une version de Terraform
  tenv tf use 1.8.0        # bascule sur cette version
  ```
- `ansible` — automatisation/configuration

## Productivité

- `gping <host>` — ping avec graphique en temps réel
- `glow <fichier.md>` — affiche un Markdown formaté dans le terminal (`glow .` pour parcourir un dossier)
- `dysk` — utilisation disque sous forme de tableau coloré (alternative à `df`).
  Le motd l'utilise automatiquement s'il est installé ; sinon il affiche un
  tableau équivalent (point de montage, taille, barre de remplissage) généré
  à partir de `df`.

## Installer / mettre à jour sur une autre machine

```bash
git clone <url-du-repo> ~/dotfiles
cd ~/dotfiles
./install.sh --tools
```

Voir [README.md](README.md) pour le détail de ce que fait le script.
