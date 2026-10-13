# Guide d'utilisation

Aide-mémoire pour le quotidien avec cette config.

## Shell (Zsh + Sheldon, ou Bash sur les serveurs)

- `reload` — recharge `~/.zshrc` (ou `~/.bashrc`) après une modif
- Flèche **droite** sur une suggestion grisée → l'accepte (zsh-autosuggestions)
- **Tab** sur une complétion → menu interactif fzf (fzf-tab) : tape pour filtrer,
  Entrée pour valider
- `cd <mot-clé>` — `cd` est zoxide : en plus des chemins habituels, il saute
  vers un dossier déjà visité dont le nom contient le mot-clé
  - `cdi <mot-clé>` — pareil mais avec sélection interactive si plusieurs résultats
- Un nom de dossier seul suffit pour s'y rendre : `..`, `/etc`, `projets`
- **Ctrl-R** — recherche dans l'historique avec fzf ; **Ctrl-T** — insère un
  fichier choisi avec fzf ; **Alt-C** — va dans un dossier choisi avec fzf
- L'historique garde 100 000 commandes, avec leur date (`history -i` en zsh,
  `history` en bash)

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
| `ls`, `ll` | `eza` | `ls` avec icônes/git |
| `cat` | `bat` | `cat` avec coloration syntaxique |
| `top` | `btop` | `top` |
| `fd` | `fdfind` (Debian) | `find` |
| `bat` | `batcat` (Debian) | — |

`rg` (ripgrep) et `fzf` s'utilisent directement sans alias.

### Fonctions utiles

- `mkcd <dir>` — crée un dossier et s'y déplace
- `ff <motif>` — recherche un fichier par nom, ex. `ff '*.yml'` (`fd`, sinon `find`)
- `fstr <mot>` — recherche un mot dans tous les fichiers (`rg`, sinon `grep -rnw`)
- `ap <playbook> [options]` — `ansible-playbook --check --diff` : simulation
- `apgo <playbook> [options]` — `ansible-playbook --diff` : application réelle
- `extract <archive>` — décompresse selon l'extension (zip, tar.gz, 7z...)
- `myip` — affiche l'IP locale
- `topcpu` — top 10 process par CPU

### Connexions serveurs

`~/.ssh/config` est la seule liste des serveurs : chaque `Host` devient un
alias (`monserveur` équivaut à `ssh monserveur`), et `ssh`, `scp`, `rsync` et
Ansible utilisent les mêmes réglages. `addsrv` ajoute une entrée pour toi.

Pour ce qui ne passe pas par SSH (RDP...) ou une connexion particulière,
copie [.shell/alias_srv.example](.shell/alias_srv.example) vers
`~/.shell/alias_srv` (non versionné, voir
[README.md](README.md#fichiers-locaux-non-versionnés)) : ces alias-là sont
prioritaires.

## tmux

Préfixe : `Ctrl+a` (au lieu de `Ctrl+b`).

- `Ctrl+a |` / `Ctrl+a -` — split vertical / horizontal (dans le dossier courant)
- `Ctrl+a r` — recharge `~/.tmux.conf`
- Souris activée : clic pour changer de pane, glisser pour redimensionner
- Mode vi en copie : `v` pour sélectionner, `y` pour copier

## Git

En plus des alias de `.shell/alias` (`gf`, `gstash`, `gpop`, `girb`), des alias
supplémentaires sont disponibles via [git/aliases.gitconfig](git/aliases.gitconfig)
(inclus automatiquement par `install.sh`) :

- `git st` — status court
- `git lg` — log graphique condensé
- `git amend` — amend sans changer le message
- `git unstage <fichier>` — retire du staging
- `git aliases` — liste tous les alias git configurés

## Sécurité & audit (groupe `secu`)

- `lynis audit system` — audit de sécurité du système (à lancer en root, `/usr/sbin/lynis`)
- `nmap` — scan réseau
- `rustscan -a <ip>` — scan de ports rapide (souvent en amont d'un `nmap -sV` plus poussé)
- `nuclei -u <url> -t <templates>` — scan de vulnérabilités web par templates
- `gobuster dir -u <url> -w <wordlist>` — brute-force de répertoires/fichiers
- Wordlists : `~/tools/SecLists/` (ex: `~/tools/SecLists/Discovery/Web-Content/common.txt`)

## Conteneurs & Kubernetes (groupes `docker`, `k8s`)

- `lazydocker` — TUI pour gérer containers/images/volumes Docker
- `dive <image>` — explore les layers d'une image Docker (taille, fichiers ajoutés/modifiés)
- `k9s` — TUI pour naviguer/gérer un cluster Kubernetes (utilise le contexte `kubectl` courant,
  affiché dans le prompt Starship)

## Infra as Code (groupe `iac`)

- `tenv` — version manager Terraform/OpenTofu/Terragrunt :
  ```bash
  tenv tf install latest   # installe une version de Terraform
  tenv tf use 1.8.0        # bascule sur cette version
  ```
- `ansible` — automatisation/configuration (`ap` pour simuler, `apgo` pour appliquer)

## Productivité

- `gping <host>` — ping avec graphique en temps réel (groupe `extra`)
- `glow <fichier.md>` — affiche un Markdown formaté dans le terminal (`glow .` pour parcourir un dossier ; groupe `extra`)
- `dysk` — utilisation disque sous forme de tableau coloré (alternative à `df`).
- `~/.shell/motd` — message d'accueil affiché à l'ouverture du shell : charge,
  mémoire, disques, réseau, unités systemd en échec, mises à jour en attente.
  Bash seul, sans droit root ; ce qui n'est pas disponible sur la machine est
  omis. `~/.shell/motd --demo` montre les seuils orange et rouge avec des
  données fictives, `--no-color` (ou `NO_COLOR=1`) coupe les couleurs.

## Installer / mettre à jour sur une autre machine

```bash
git clone <url-du-repo> ~/dotfiles
cd ~/dotfiles
./install.sh --tools                 # poste de travail, groupe "base"
./install.sh --with docker,iac       # avec des groupes en plus
./install.sh --no-root --bash --tools --bin-dir /data/outils/bin   # serveur sans root
./install.sh --check                 # contrôler sans rien modifier
dotup                                # installer la dernière version (voir README)
```

Voir [README.md](README.md) pour le détail de ce que fait le script.
