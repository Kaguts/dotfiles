#!/usr/bin/env bash
#
# Bootstrap des dotfiles : crée des liens symboliques depuis ce repo
# vers leur emplacement attendu dans $HOME, et installe les outils CLI
# de la stack.
#
# Compatible :
#   - Debian/Ubuntu (apt)
#   - RHEL-like : RHEL/Rocky/Alma/CentOS (dnf ou yum, via EPEL) et Fedora
#   - WSL (Windows) : même fonctionnement que la distro installée dans WSL ;
#     la config WezTerm est en plus copiable côté Windows (--wezterm-windows)
#   - x86_64 et arm64
#   - Sans droits root/sudo : les paquets système sont ignorés (avec un
#     message indiquant ce qu'il faudra installer via un admin), mais les
#     outils installables en binaire le sont quand même, dans ~/.local/bin
#     ou dans le dossier donné par --bin-dir.
#
# Usage :
#   ./install.sh            # liens symboliques, puis liste des outils absents
#                            # (starship, sheldon...) et propose de les
#                            # installer si le terminal est interactif
#   ./install.sh --update   # recrée les liens symboliques (utile après avoir
#                            # déplacé/renommé le dossier du repo) et nettoie
#                            # les anciennes références dans ~/.gitconfig
#   ./install.sh --tools    # liens + outils du groupe "base" (shell, prompt,
#                            # eza, bat, fd, ripgrep, fzf, zoxide, delta...)
#   ./install.sh --with GROUPES
#                            # comme --tools, avec en plus les groupes cités,
#                            # séparés par des virgules : extra (lazygit,
#                            # gping, glow), docker (lazydocker, dive),
#                            # k8s (k9s), iac (ansible, tenv), secu (nmap,
#                            # lynis, gobuster, rustscan, nuclei, SecLists),
#                            # ou "all" pour tout
#   ./install.sh --sysadmin # --update + --with extra,docker,k8s,iac
#   ./install.sh --bash     # met aussi en place ~/.bashrc (serveurs sans zsh)
#   ./install.sh --bin-dir DOSSIER
#                            # installe les binaires dans DOSSIER au lieu de
#                            # ~/.local/bin ; le choix est mémorisé et le
#                            # dossier ajouté au PATH du shell
#   ./install.sh --no-root  # n'essaie pas sudo : aucun paquet système, tout
#                            # ce qui peut l'être est installé en binaire
#   ./install.sh --upgrade  # récupère la dernière version du dépôt (git pull),
#                            # refait les liens et met les binaires déjà
#                            # installés aux versions de tools.lock ; ne touche
#                            # pas aux paquets système (alias shell : dotup)
#   ./install.sh --skip-packages
#                            # avec --tools : binaires seulement, sans apt/dnf
#   ./install.sh --check    # ne modifie rien : contrôle les liens, la config
#                            # git, le PATH, les outils et les alias
#   ./install.sh --uninstall
#                            # retire les liens vers le dépôt et l'inclusion
#                            # des alias git, remet les fichiers d'origine les
#                            # plus récents de ~/.dotfiles_backup ; laisse en
#                            # place les binaires (liste affichée)
#   ./install.sh --wezterm-windows
#                            # (WSL) copie la config WezTerm dans le profil
#                            # Windows ; combinable avec les autres options
#   ./install.sh --help
#
# Exemple, serveur sans droits root :
#   ./install.sh --no-root --bash --tools --bin-dir /data/outils/bin

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles_backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"

usage() {
    sed -n '/^# Usage :/,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# Choix mémorisés d'une exécution à l'autre (dossier des binaires, groupes
# d'outils). Ce fichier est aussi lu par ~/.shell/env pour le PATH.
STATE_FILE="$HOME/.config/dotfiles/env"
DOTFILES_BIN=""
DOTFILES_GROUPS=""
# shellcheck disable=SC1090
[ -f "$STATE_FILE" ] && . "$STATE_FILE"

ALL_GROUPS="extra docker k8s iac secu"

DO_UPDATE=0
DO_TOOLS=0
DO_BASH=0
DO_CHECK=0
DO_UPGRADE=0
DO_UNINSTALL=0
SKIP_PACKAGES=0
NO_ROOT=0
DO_WEZTERM_WINDOWS=0
BIN_DIR="${DOTFILES_BIN:-$HOME/.local/bin}"
TOOL_GROUPS="$DOTFILES_GROUPS"
SAVE_STATE=0

# set_groups <liste séparée par des virgules> : valide puis retient les groupes
set_groups() {
    local g list=""
    for g in ${1//,/ }; do
        case "$g" in
            all) list="$ALL_GROUPS" ;;
            extra|docker|k8s|iac|secu) list="$list $g" ;;
            base) ;;
            *) echo "Groupe inconnu : $g (groupes : ${ALL_GROUPS// /, }, all)" >&2; exit 2 ;;
        esac
    done
    TOOL_GROUPS=$(echo "$list" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/^ *//; s/ *$//; s/ /,/g')
    SAVE_STATE=1
}

# has_group <groupe> : vrai si le groupe est demandé ("base" l'est toujours)
has_group() {
    [ "$1" = "base" ] && return 0
    case ",$TOOL_GROUPS," in *",$1,"*) return 0 ;; esac
    return 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --update)          DO_UPDATE=1 ;;
        --tools)           DO_TOOLS=1 ;;
        --with|--with=*)
            if [ "$1" = "--with" ]; then
                [ $# -ge 2 ] || { echo "--with attend une liste de groupes" >&2; exit 2; }
                shift
                set_groups "$1"
            else
                set_groups "${1#--with=}"
            fi
            DO_TOOLS=1
            ;;
        --sysadmin)        DO_UPDATE=1; DO_TOOLS=1; set_groups "extra,docker,k8s,iac" ;;
        --bash)            DO_BASH=1 ;;
        --bin-dir|--bin-dir=*)
            if [ "$1" = "--bin-dir" ]; then
                [ $# -ge 2 ] || { echo "--bin-dir attend un dossier" >&2; exit 2; }
                shift
                BIN_DIR="$1"
            else
                BIN_DIR="${1#--bin-dir=}"
            fi
            SAVE_STATE=1
            ;;
        --no-root)         NO_ROOT=1 ;;
        --upgrade)         DO_UPGRADE=1 ;;
        --skip-packages)   SKIP_PACKAGES=1 ;;
        --check)           DO_CHECK=1 ;;
        --uninstall)       DO_UNINSTALL=1 ;;
        --wezterm-windows) DO_WEZTERM_WINDOWS=1 ;;
        -h|--help)         usage; exit 0 ;;
        *)                 echo "Option inconnue : $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# Le dossier des binaires : chemin absolu, sans caractère qui casserait le
# fichier d'état (il est relu par le shell)
BIN_DIR="${BIN_DIR/#\~/$HOME}"
case "$BIN_DIR" in
    /*) ;;
    *) BIN_DIR="$PWD/$BIN_DIR" ;;
esac
BIN_DIR="${BIN_DIR%/}"
case "$BIN_DIR" in
    *[\'\"\$\`\\]*|*$'\n'*)
        echo "Dossier refusé (guillemet, \$, \` ou antislash dans le chemin) : $BIN_DIR" >&2
        exit 2
        ;;
esac

IS_WSL=0
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=1
fi

# lien symbolique src (dans le repo) -> dest (dans $HOME), avec backup
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$2")"
        mv "$dest" "$BACKUP_DIR/$2"
        echo "Sauvegarde : $dest -> $BACKUP_DIR/$2"
    fi

    ln -snf "$src" "$dest"
    echo "Lien créé  : $dest -> $src"
}

# Copie la config WezTerm dans le profil Windows (WezTerm tourne côté Windows
# et ne peut pas suivre un lien symbolique créé dans WSL).
sync_wezterm_windows() {
    if [ "$IS_WSL" -eq 0 ]; then
        echo "  ! --wezterm-windows n'a de sens que dans WSL, étape ignorée"
        return 0
    fi
    if ! command -v cmd.exe >/dev/null 2>&1 || ! command -v wslpath >/dev/null 2>&1; then
        echo "  ! cmd.exe/wslpath introuvables (interop WSL désactivée ?), étape ignorée"
        return 0
    fi

    local win_home
    # cmd.exe refuse un répertoire courant UNC (\\wsl$\...) : on part de /mnt/c
    win_home=$(cd /mnt/c 2>/dev/null && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r') || win_home=""
    if [ -z "$win_home" ]; then
        echo "  ! Profil Windows introuvable, étape ignorée"
        return 0
    fi
    win_home=$(wslpath -u "$win_home")

    local dest="$win_home/.config/wezterm"
    if [ -e "$dest" ]; then
        mv "$dest" "$dest.bak-$(date +%Y%m%d-%H%M%S)"
        echo "Sauvegarde : ancienne config WezTerm Windows renommée en .bak-<date>"
    fi
    mkdir -p "$dest"
    cp -r "$DOTFILES_DIR/wezterm/." "$dest/"
    echo "Copié      : $DOTFILES_DIR/wezterm -> $dest"
    echo "  (copie, pas un lien : relance cette option après chaque modification)"
}

# Liens à créer : "fichier du repo:emplacement dans $HOME"
LINKS=(
    ".zshrc:.zshrc"
    ".vimrc:.vimrc"
    ".tmux.conf:.tmux.conf"
    ".shell:.shell"
    "wezterm:.config/wezterm"
    "sheldon/plugins.toml:.config/sheldon/plugins.toml"
    "starship.toml:.config/starship.toml"
)
GIT_ALIASES="$DOTFILES_DIR/git/aliases.gitconfig"
LIST_FILE="$DOTFILES_DIR/tools.list"
LOCK_FILE="$DOTFILES_DIR/tools.lock"
# Binaires installés par ce script : "commande|url de l'archive", pour savoir
# lesquels sont à remplacer quand tools.lock change de version
INSTALLED_FILE="$HOME/.config/dotfiles/tools.installed"
UPDATE_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/last-check"

# Le contrôle « en retard sur la version en ligne ? » est partagé avec le shell
# shellcheck disable=SC1091
. "$DOTFILES_DIR/.shell/update-check"

# ---------------------------------------------------------------------------
# --upgrade : récupère la dernière version puis se relance pour l'appliquer
# ---------------------------------------------------------------------------
if [ "$DO_UPGRADE" -eq 1 ]; then
    command -v git >/dev/null 2>&1 || { echo "Erreur : git est requis pour --upgrade." >&2; exit 1; }
    echo "==> Mise à jour du dépôt ($DOTFILES_DIR)"
    before=$(git -C "$DOTFILES_DIR" rev-parse HEAD)
    if ! git -C "$DOTFILES_DIR" pull --ff-only; then
        echo "Erreur : 'git pull' a échoué (réseau, modifications locales en conflit ou" >&2
        echo "historique divergent). Rien n'a été modifié : règle-le à la main dans le dépôt." >&2
        exit 1
    fi
    after=$(git -C "$DOTFILES_DIR" rev-parse HEAD)
    if [ "$before" = "$after" ]; then
        echo "Dépôt déjà à jour."
    else
        git -C "$DOTFILES_DIR" --no-pager log --oneline "$before..$after"
    fi
    mkdir -p "$(dirname "$UPDATE_STAMP")"
    echo "$(date +%F) ok" > "$UPDATE_STAMP"

    # On relance le script : c'est sa nouvelle version qui doit s'appliquer.
    # Les outils ne sont repris que s'ils avaient été installés par ce script.
    next=(--update)
    if [ -f "$INSTALLED_FILE" ] || [ -x "$BIN_DIR/starship" ] || [ -x "$BIN_DIR/sheldon" ]; then
        next+=(--tools --skip-packages)
    fi
    echo
    exec "$DOTFILES_DIR/install.sh" "${next[@]}"
fi

# tool_present <commande> : vrai si l'outil est disponible, sous son nom ou
# sous celui du paquet Debian (batcat, fdfind), dans le PATH ou dans BIN_DIR
tool_present() {
    command -v "$1" >/dev/null 2>&1 && return 0
    [ -x "$BIN_DIR/$1" ] && return 0
    case "$1" in
        bat) command -v batcat >/dev/null 2>&1 && return 0 ;;
        fd)  command -v fdfind >/dev/null 2>&1 && return 0 ;;
    esac
    return 1
}

# Commandes fournies par les paquets système (pas par tools.list), par groupe
pkg_commands() {
    case "$1" in
        base) echo "git curl vim tmux btop" ;;
        iac)  echo "ansible" ;;
        secu) echo "nmap lynis" ;;
    esac
}

# report_tools : liste les outils absents. Ceux d'un groupe demandé comptent
# comme manquants (code retour 1), les autres sont seulement mentionnés.
report_tools() {
    local missing="" optional="" tool group cmd
    while IFS='|' read -r tool group _ <&3; do
        case "$tool" in ''|\#*) continue ;; esac
        tool_present "$tool" && continue
        if has_group "$group"; then missing="$missing $tool"; else optional="$optional $tool($group)"; fi
    done 3< "$LIST_FILE"
    for group in base $ALL_GROUPS; do
        for cmd in $(pkg_commands "$group"); do
            tool_present "$cmd" && continue
            if has_group "$group"; then missing="$missing $cmd"; else optional="$optional $cmd($group)"; fi
        done
    done
    command -v zsh >/dev/null 2>&1 || command -v bash >/dev/null 2>&1 || missing="$missing zsh"

    if [ -n "$missing" ]; then
        echo "  Outils absents :$missing"
    else
        echo "  Tous les outils demandés sont présents (groupes : base${TOOL_GROUPS:+,$TOOL_GROUPS})."
    fi
    [ -n "$optional" ] && echo "  Non demandés (ajoute le groupe avec --with) :$optional"
    [ -z "$missing" ]
}

# ---------------------------------------------------------------------------
# --check : contrôle l'installation sans rien modifier
# ---------------------------------------------------------------------------
if [ "$DO_CHECK" -eq 1 ]; then
    problems=0
    ok()  { echo "  ok   $1"; }
    bad() { echo "  !!   $1"; problems=$((problems + 1)); }

    echo "==> Version"
    if _dotfiles_behind "$DOTFILES_DIR"; then
        bad "une nouvelle version est en ligne -> ./install.sh --upgrade (ou dotup)"
    else
        ok "dépôt à jour (ou version en ligne injoignable)"
    fi

    echo "==> Liens symboliques"
    [ -L "$HOME/.bashrc" ] && LINKS+=(".bashrc:.bashrc")
    for entry in "${LINKS[@]}"; do
        src="$DOTFILES_DIR/${entry%%:*}"
        dest="$HOME/${entry#*:}"
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            ok "$dest"
        elif [ -L "$dest" ]; then
            bad "$dest pointe vers $(readlink "$dest") (attendu : $src) -> ./install.sh --update"
        elif [ -e "$dest" ]; then
            bad "$dest existe mais n'est pas un lien vers le repo -> ./install.sh"
        else
            bad "$dest absent -> ./install.sh"
        fi
    done
    [ -L "$HOME/.bashrc" ] || echo "  --   ~/.bashrc non géré par le repo (optionnel : ./install.sh --bash)"

    echo "==> Git"
    if command -v git >/dev/null 2>&1; then
        found=0
        while IFS= read -r inc; do
            inc_path="${inc/#\~/$HOME}"
            [ "$inc_path" = "$GIT_ALIASES" ] && found=1
            [ -e "$inc_path" ] || bad "include.path introuvable : $inc -> ./install.sh --update"
        done < <(git config --global --get-all include.path 2>/dev/null || true)
        if [ "$found" -eq 1 ]; then ok "alias git inclus ($GIT_ALIASES)"; else bad "alias git non inclus dans ~/.gitconfig -> ./install.sh"; fi
    else
        bad "git absent"
    fi

    echo "==> Dossier des binaires et PATH"
    if [ -d "$BIN_DIR" ] && [ -w "$BIN_DIR" ]; then ok "$BIN_DIR"; else bad "$BIN_DIR absent ou non inscriptible"; fi
    case ":$PATH:" in
        *":$BIN_DIR:"*) ok "$BIN_DIR est dans le PATH" ;;
        *) bad "$BIN_DIR n'est pas dans le PATH de ce shell (ouvre un nouveau shell ou lance 'reload')" ;;
    esac

    echo "==> Shell"
    for f in .shell/add_srv.sh .shell/motd; do
        if [ -x "$DOTFILES_DIR/$f" ]; then ok "$f exécutable"; else bad "$f absent ou non exécutable"; fi
    done
    if command -v zsh >/dev/null 2>&1; then
        if command -v sheldon >/dev/null 2>&1 || [ -x "$BIN_DIR/sheldon" ]; then
            if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/plugins.lock" ]; then
                ok "plugins Sheldon verrouillés"
            else
                bad "plugins Sheldon non installés -> sheldon lock --update"
            fi
        fi
        [ "$(basename "${SHELL:-}")" = "zsh" ] || echo "  --   shell de connexion : ${SHELL:-inconnu} (zsh disponible : chsh -s \"$(command -v zsh)\")"
    else
        echo "  --   zsh absent : utilise la config bash (./install.sh --bash)"
    fi

    echo "==> Alias"
    if "$DOTFILES_DIR/tests/check-aliases.sh"; then ok "chaque alias lance une commande existante"; else problems=$((problems + 1)); fi

    echo "==> Outils"
    manque=""
    command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || manque="$manque curl"
    for cmd in tar gzip sha256sum; do command -v "$cmd" >/dev/null 2>&1 || manque="$manque $cmd"; done
    if [ -n "$manque" ]; then
        bad "prérequis de --tools absents :$manque"
    else
        ok "prérequis de --tools présents (téléchargement, tar, gzip, sha256sum)"
    fi
    report_tools || problems=$((problems + 1))

    echo "==> Sauvegardes"
    vieilles=0
    if [ -d "$BACKUP_ROOT" ]; then
        vieilles=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +30 | wc -l)
    fi
    if [ "$vieilles" -gt 0 ]; then
        echo "  --   $vieilles sauvegarde(s) de plus de 30 jours dans $BACKUP_ROOT : à supprimer"
        echo "       à la main si tout va bien (--uninstall s'en sert pour remettre les fichiers)"
    else
        ok "aucune sauvegarde de plus de 30 jours"
    fi

    echo
    if [ "$problems" -eq 0 ]; then
        echo "Tout est en ordre."
        exit 0
    fi
    echo "$problems point(s) à corriger."
    exit 1
fi

# ---------------------------------------------------------------------------
# --uninstall : retire ce que le script a mis en place dans $HOME
# ---------------------------------------------------------------------------
if [ "$DO_UNINSTALL" -eq 1 ]; then
    echo "==> Retrait des liens vers le dépôt"
    for entry in "${LINKS[@]}" ".bashrc:.bashrc"; do
        src="$DOTFILES_DIR/${entry%%:*}"
        rel="${entry#*:}"
        dest="$HOME/$rel"
        [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] || continue
        rm "$dest"
        echo "Retiré     : $dest"
        # Version d'origine la plus récente (les dossiers sont datés), sauf un
        # ancien lien vers le dépôt ou un lien cassé
        while IFS= read -r d; do
            b="$d/$rel"
            [ -e "$b" ] || continue
            case "$(readlink "$b" 2>/dev/null || true)" in "$DOTFILES_DIR"/*) continue ;; esac
            cp -a "$b" "$dest"
            echo "Remis      : $dest (depuis $b)"
            break
        done < <(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r)
    done

    if command -v git >/dev/null 2>&1 \
        && git config --global --get-all include.path 2>/dev/null | grep -qxF "$GIT_ALIASES"; then
        git config --global --fixed-value --unset-all include.path "$GIT_ALIASES"
        echo "Retiré     : include.path = $GIT_ALIASES dans ~/.gitconfig"
    fi

    if [ -s "$INSTALLED_FILE" ]; then
        echo
        echo "Binaires installés par le dépôt, laissés dans $BIN_DIR :"
        echo "  $(cut -d'|' -f1 "$INSTALLED_FILE" | tr '\n' ' ')"
        echo "  pour les retirer : cd \"$BIN_DIR\" && rm $(cut -d'|' -f1 "$INSTALLED_FILE" | tr '\n' ' ')"
    fi
    echo
    echo "Terminé. Le dépôt lui-même ($DOTFILES_DIR) n'est pas supprimé."
    exit 0
fi

# Requis par `set undofile` / `set undodir` dans .vimrc
mkdir -p "$HOME/.vim/undodir" "$HOME/.local/bin"
if ! mkdir -p "$BIN_DIR" 2>/dev/null || [ ! -w "$BIN_DIR" ]; then
    echo "Erreur : impossible d'écrire dans $BIN_DIR (choisis un autre dossier avec --bin-dir)." >&2
    exit 1
fi

# Mémorise le dossier des binaires et les groupes ; ~/.shell/env relit ce
# fichier pour mettre le dossier dans le PATH
if [ "$SAVE_STATE" -eq 1 ]; then
    mkdir -p "$(dirname "$STATE_FILE")"
    {
        echo "# Écrit par install.sh (--bin-dir, --with) : ne pas modifier à la main."
        [ "$BIN_DIR" != "$HOME/.local/bin" ] && echo "DOTFILES_BIN='$BIN_DIR'"
        echo "DOTFILES_GROUPS='$TOOL_GROUPS'"
    } > "$STATE_FILE"
fi

echo "==> Mise en place des liens symboliques"
# ~/.bashrc déjà géré par le repo : il le reste (cas d'un --update / --upgrade)
case "$(readlink "$HOME/.bashrc" 2>/dev/null || true)" in
    "$DOTFILES_DIR/.bashrc") DO_BASH=1 ;;
esac
[ "$DO_BASH" -eq 1 ] && LINKS+=(".bashrc:.bashrc")
for entry in "${LINKS[@]}"; do
    link "${entry%%:*}" "${entry#*:}"
done

# bash ne lit ~/.bashrc à la connexion (SSH) que si un fichier de profil le
# lui demande : on en crée un s'il n'y en a aucun
if [ "$DO_BASH" -eq 1 ] && [ ! -e "$HOME/.bash_profile" ] && [ ! -e "$HOME/.bash_login" ] && [ ! -e "$HOME/.profile" ]; then
    # shellcheck disable=SC2016
    echo '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"' > "$HOME/.bash_profile"
    echo "Créé       : ~/.bash_profile (charge ~/.bashrc à la connexion)"
fi

# Alias git : inclus depuis ~/.gitconfig sans écraser l'identité existante.
# Rappelé après l'installation des paquets : sur une machine neuve, git
# n'existe pas encore à ce stade.
setup_git_include() {
    command -v git >/dev/null 2>&1 || return 0
    if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$GIT_ALIASES"; then
        git config --global --add include.path "$GIT_ALIASES"
        echo "Ajouté        : include.path = $GIT_ALIASES dans ~/.gitconfig"
    fi

    if [ "$DO_UPDATE" -eq 1 ]; then
        # Nettoie les anciennes références include.path qui pointaient vers
        # un précédent emplacement du repo (dépôt déplacé/renommé)
        while IFS= read -r old_path; do
            case "$old_path" in
                */aliases.gitconfig)
                    if [ "$old_path" != "$GIT_ALIASES" ] && [ ! -e "$old_path" ]; then
                        git config --global --unset-all include.path "$old_path" 2>/dev/null || true
                        echo "Retiré        : include.path = $old_path (chemin obsolète)"
                    fi
                    ;;
            esac
        done < <(git config --global --get-all include.path 2>/dev/null || true)
    fi
}
setup_git_include

# Dépôt public : le hook pre-commit refuse un commit qui contiendrait une
# information propre à la machine (voir tests/check-leaks.sh). git refuse un
# dépôt appartenant à un autre compte (root sur le clone d'un utilisateur) :
# le hook est alors laissé de côté plutôt que d'arrêter l'installation.
if command -v git >/dev/null 2>&1 && git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1 \
    && [ "$(git -C "$DOTFILES_DIR" config --local core.hooksPath 2>/dev/null || true)" != ".githooks" ]; then
    git -C "$DOTFILES_DIR" config --local core.hooksPath .githooks
    echo "Activé     : hook pre-commit du dépôt (contrôle anti-fuite)"
fi

if [ -d "$BACKUP_DIR" ]; then
    echo "Anciens fichiers sauvegardés dans : $BACKUP_DIR"
fi

if [ "$DO_WEZTERM_WINDOWS" -eq 1 ]; then
    echo
    echo "==> Config WezTerm côté Windows"
    sync_wezterm_windows
elif [ "$IS_WSL" -eq 1 ]; then
    echo
    echo "WSL détecté : WezTerm tourne côté Windows et ne voit pas ~/.config/wezterm."
    echo "Lance './install.sh --wezterm-windows' pour copier la config dans ton profil Windows."
fi

if [ "$DO_TOOLS" -eq 0 ]; then
    echo
    if [ "$DO_UPDATE" -eq 1 ]; then
        echo "Liens symboliques et configuration git mis à jour."
        exit 0
    fi
    echo "==> Outils de la stack"
    if report_tools; then
        exit 0
    fi
    # Sans terminal (script, CI), on se contente de la liste
    reponse=""
    if [ -t 0 ] && [ -t 1 ]; then
        read -r -p "  Installer maintenant les outils manquants (comme --tools) ? [o/N] " reponse || reponse=""
    fi
    case "$reponse" in
        [oOyY]*) DO_TOOLS=1 ;;
        *)
            echo "  Relance avec '--tools' pour les installer, ou '--check' pour contrôler l'installation."
            exit 0
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# Détection root / sudo, de la famille de distribution et de l'architecture
# ---------------------------------------------------------------------------

SUDO=""
HAS_ROOT=0
if [ "$NO_ROOT" -eq 1 ] || [ "$SKIP_PACKAGES" -eq 1 ]; then
    :
elif [ "$(id -u)" -eq 0 ]; then
    HAS_ROOT=1
elif command -v sudo >/dev/null 2>&1 && sudo -v 2>/dev/null; then
    HAS_ROOT=1
    SUDO="sudo"
fi

PKG_FAMILY="unknown"
PKG_MGR=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_FAMILY="debian"
    PKG_MGR="apt-get"
elif command -v dnf >/dev/null 2>&1; then
    PKG_FAMILY="rhel"
    PKG_MGR="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_FAMILY="rhel"
    PKG_MGR="yum"
fi

OS_ID=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    OS_ID=$(. /etc/os-release && echo "${ID:-}")
fi

# ARCH_KEY  : nom de l'architecture dans tools.lock
# ARCH_RUST : nom utilisé dans les chemins internes de certaines archives
case "$(uname -m)" in
    x86_64|amd64)  ARCH_KEY="x86_64"; ARCH_RUST="x86_64" ;;
    aarch64|arm64) ARCH_KEY="arm64";  ARCH_RUST="aarch64" ;;
    *)             ARCH_KEY="";       ARCH_RUST="" ;;
esac

echo
echo "==> Système détecté : famille='$PKG_FAMILY' (${OS_ID:-inconnu}), arch=$(uname -m), WSL=$([ "$IS_WSL" -eq 1 ] && echo oui || echo non), root/sudo=$([ "$HAS_ROOT" -eq 1 ] && echo oui || echo non)"

# Installe une liste de paquets. Si l'installation groupée échoue (un seul
# paquet absent du dépôt suffit à tout faire échouer), réessaie paquet par
# paquet et signale ceux qui manquent, sans arrêter le script.
pkg_install() {
    if $SUDO "$PKG_MGR" install -y "$@"; then
        return 0
    fi
    echo "  ! Installation groupée impossible, nouvel essai paquet par paquet"
    local pkg missing=""
    for pkg in "$@"; do
        $SUDO "$PKG_MGR" install -y "$pkg" >/dev/null 2>&1 || missing="$missing $pkg"
    done
    if [ -n "$missing" ]; then
        echo "  ! Paquets indisponibles sur ce système :$missing"
        echo "    (ceux qui existent en binaire seront installés dans $BIN_DIR plus bas)"
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Paquets système (nécessitent root/sudo + apt ou dnf/yum)
# ---------------------------------------------------------------------------

# Paquets par famille de distribution, selon les groupes demandés.
# eza, lazygit, gping, glow... n'existent pas sur toutes les versions
# (Debian 12, Ubuntu 22.04), et pas du tout sur RHEL-like : pkg_install tolère
# les absents, qui sont ensuite installés en binaire.
# xclip est requis pour `set clipboard=unnamedplus` (.vimrc) ; util-linux-user
# fournit chsh (pour passer à zsh).
DEB_PKGS="zsh curl git tar unzip eza bat fd-find ripgrep fzf zoxide btop tmux httpie git-delta vim xclip bash-completion"
RHEL_PKGS="zsh curl git tar unzip util-linux-user ripgrep fzf bat fd-find tmux btop httpie vim-enhanced xclip bash-completion"
if has_group extra; then DEB_PKGS="$DEB_PKGS lazygit gping glow"; fi
if has_group iac;   then DEB_PKGS="$DEB_PKGS ansible"; fi
if has_group secu;  then DEB_PKGS="$DEB_PKGS lynis nmap gobuster"; RHEL_PKGS="$RHEL_PKGS nmap lynis"; fi

if [ "$SKIP_PACKAGES" -eq 1 ]; then
    echo
    echo "==> Paquets système laissés au gestionnaire de paquets (apt/dnf)"
elif [ "$HAS_ROOT" -eq 0 ]; then
    echo
    echo "==> Paquets système ignorés (pas de droits root/sudo)"
    echo "  Les outils disponibles en binaire sont installés dans $BIN_DIR ci-dessous."
    echo "  Pour le reste (zsh, tmux, btop, vim...), demande à un admin d'installer :"
    echo "  Debian/Ubuntu : $DEB_PKGS"
    echo "  RHEL-like     : epel-release $RHEL_PKGS$(has_group iac && echo ' ansible-core')"
else
    case "$PKG_FAMILY" in
        debian)
            echo
            echo "==> Installation des outils CLI (apt)"
            $SUDO apt-get update
            # shellcheck disable=SC2086
            pkg_install $DEB_PKGS
            ;;
        rhel)
            if [ "$OS_ID" != "fedora" ]; then
                echo
                echo "==> Activation des dépôts EPEL et CRB"
                # epel-release est dans les dépôts de Rocky/Alma/CentOS ; sur RHEL
                # il faut passer par le RPM publié par le projet Fedora.
                $SUDO "$PKG_MGR" install -y epel-release 2>/dev/null \
                    || $SUDO "$PKG_MGR" install -y \
                        "https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm" \
                    || echo "  ! EPEL indisponible, certains paquets risquent de manquer"
                # Plusieurs paquets EPEL dépendent de CRB (nommé PowerTools sur EL8)
                $SUDO "$PKG_MGR" config-manager --set-enabled crb 2>/dev/null \
                    || $SUDO "$PKG_MGR" config-manager --set-enabled powertools 2>/dev/null \
                    || true
            fi

            echo
            echo "==> Installation des outils CLI ($PKG_MGR)"
            # shellcheck disable=SC2086
            pkg_install $RHEL_PKGS

            if has_group iac; then
                $SUDO "$PKG_MGR" install -y ansible-core 2>/dev/null \
                    || $SUDO "$PKG_MGR" install -y ansible \
                    || echo "  ! ansible/ansible-core indisponible, à installer manuellement"
            fi
            ;;
        *)
            echo
            echo "==> Gestionnaire de paquets non reconnu, étape des paquets système ignorée"
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# Outils en binaire (Starship, Sheldon et les outils additionnels), installés
# dans BIN_DIR (~/.local/bin, ou le dossier donné par --bin-dir) : ne
# nécessite PAS de droits root, fonctionne sur Debian comme sur RHEL-like.
# Si le paquet système est déjà présent (ex: apt sur Debian), l'outil est
# détecté et l'étape est ignorée.
#
# Un binaire déjà posé dans BIN_DIR est remplacé quand tools.lock désigne une
# autre archive que celle installée (suivi dans ~/.config/dotfiles/tools.installed) :
# relancer --tools, ou --upgrade, met donc à jour ce qui est en place.
#
# La liste des outils est dans tools.list. La version exacte de chacun et la
# somme SHA-256 de son archive sont figées dans tools.lock (régénéré par
# ./update-tools.sh) : aucune archive n'est installée sans vérification.
# ---------------------------------------------------------------------------

# install_binary_release <commande> [nom_binaire] [motif_chemin]
#   nom_binaire  : nom du binaire dans l'archive (défaut : <commande>)
#   motif_chemin : motif `find -path` pour choisir le bon binaire quand
#                  l'archive en contient plusieurs (une par architecture)
# telecharger <url> <fichier> : curl, ou wget sur les systèmes minimaux
telecharger() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    else
        wget -q -O "$2" "$1"
    fi
}

# Ne fait jamais échouer le script : tout problème est signalé puis ignoré.
install_binary_release() {
    local name="$1" bin_name="${2:-$1}" path_glob="${3:-*}"
    # Présent ailleurs que dans BIN_DIR : fourni par le système, on n'y touche pas
    if [ ! -x "$BIN_DIR/$bin_name" ] && tool_present "$name"; then
        return 0
    fi

    if [ -z "$ARCH_KEY" ]; then
        echo "  ! $name : architecture $(uname -m) non gérée, à installer manuellement"
        return 0
    fi

    local entry url sha256
    entry=$(awk -F'|' -v n="$name" -v a="$ARCH_KEY" \
        '$1 == n && $2 == a { print $3 "|" $4; exit }' "$LOCK_FILE" 2>/dev/null || true)
    url=${entry%%|*}
    sha256=${entry##*|}
    if [ -z "$entry" ] || [ -z "$url" ] || [ -z "$sha256" ]; then
        echo "  ! $name : pas de version figée pour $ARCH_KEY dans tools.lock (lance ./update-tools.sh $name)"
        return 0
    fi

    # Déjà dans BIN_DIR, à la version de tools.lock : rien à faire
    if [ -x "$BIN_DIR/$bin_name" ] && grep -qxF "$name|$url" "$INSTALLED_FILE" 2>/dev/null; then
        return 0
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    echo "  -> $name : $url"
    if ! telecharger "$url" "$tmpdir/archive"; then
        echo "  ! $name : téléchargement impossible"
        rm -rf "$tmpdir"
        return 0
    fi

    # L'archive doit être exactement celle qui a été enregistrée dans tools.lock
    if ! echo "$sha256  $tmpdir/archive" | sha256sum -c --status -; then
        echo "  ! $name : somme de contrôle INCORRECTE, archive rejetée (rien n'est installé)"
        echo "    attendu : $sha256"
        echo "    obtenu  : $(sha256sum "$tmpdir/archive" | cut -d' ' -f1)"
        rm -rf "$tmpdir"
        return 0
    fi

    local ok=1
    case "$url" in
        *.tar.gz|*.tgz)
            tar -xzf "$tmpdir/archive" -C "$tmpdir" || ok=0
            ;;
        *.zip)
            if ! command -v unzip >/dev/null 2>&1; then
                echo "  ! $name : 'unzip' est requis pour extraire l'archive, installe-le puis relance"
                rm -rf "$tmpdir"
                return 0
            fi
            unzip -q "$tmpdir/archive" -d "$tmpdir" || ok=0
            # Certains projets publient un .tar.gz à l'intérieur du .zip
            local inner
            while IFS= read -r inner; do
                tar -xzf "$inner" -C "$tmpdir" || ok=0
            done < <(find "$tmpdir" -type f \( -name '*.tar.gz' -o -name '*.tgz' \))
            ;;
        *)
            echo "  ! $name : format d'archive non géré ($url)"
            rm -rf "$tmpdir"
            return 0
            ;;
    esac

    local bin_path=""
    [ "$ok" -eq 1 ] && bin_path=$(find "$tmpdir" -type f -name "$bin_name" -path "$path_glob" | head -1)
    if [ -z "$bin_path" ]; then
        echo "  ! $name : binaire '$bin_name' introuvable dans l'archive téléchargée"
    else
        install -m755 "$bin_path" "$BIN_DIR/$bin_name"
        mkdir -p "$(dirname "$INSTALLED_FILE")"
        { grep -v "^$name|" "$INSTALLED_FILE" 2>/dev/null || true; echo "$name|$url"; } > "$INSTALLED_FILE.tmp"
        mv "$INSTALLED_FILE.tmp" "$INSTALLED_FILE"
        echo "  -> $name installé dans $BIN_DIR"
    fi
    rm -rf "$tmpdir"
}

echo
echo "==> Installation des outils en binaire (versions figées dans tools.lock, $BIN_DIR)"
# Prérequis vérifiés une fois ici, plutôt qu'une erreur par outil plus bas
prerequis=""
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || prerequis="$prerequis curl"
for cmd in tar gzip sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || prerequis="$prerequis $cmd"
done
if [ -n "$prerequis" ]; then
    echo "  ! Prérequis absents :$prerequis ; aucun binaire installé (starship, sheldon...)"
    case "$PKG_FAMILY" in
        debian) echo "    à installer : sudo apt-get install${prerequis/sha256sum/coreutils}" ;;
        rhel)   echo "    à installer : sudo $PKG_MGR install${prerequis/sha256sum/coreutils}" ;;
        *)      echo "    à installer avec le gestionnaire de paquets du système" ;;
    esac
    echo "    puis relance : ./install.sh --tools"
else
    while IFS='|' read -r tool group _repo _pattern tool_bin tool_glob <&3; do
        case "$tool" in ''|\#*) continue ;; esac
        has_group "$group" || continue
        install_binary_release "$tool" "${tool_bin:-$tool}" "${tool_glob//\{RUST\}/$ARCH_RUST}"
    done 3< "$LIST_FILE"
fi

# Les binaires fraîchement installés ne sont pas forcément dans le PATH courant
export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"

# git vient peut-être d'être installé : l'inclusion des alias se fait maintenant
setup_git_include

echo
echo "==> Verrouillage des plugins Sheldon"
if ! command -v zsh >/dev/null 2>&1; then
    echo "  -> ignoré : zsh absent (les plugins ne servent qu'à zsh)"
elif ! command -v sheldon >/dev/null 2>&1; then
    echo "  ! sheldon absent : plugins zsh non installés"
else
    sheldon lock --update \
        || echo "  ! 'sheldon lock' a échoué (réseau/proxy ?), relance-le manuellement"
fi

echo
echo "==> Pré-installation des plugins WezTerm (cache local, voir wezterm/README.md)"
if [ "$IS_WSL" -eq 1 ]; then
    echo "  -> ignoré dans WSL : WezTerm (côté Windows) clone ses plugins lui-même au premier lancement"
elif ! command -v wezterm >/dev/null 2>&1 && [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    echo "  -> ignoré : pas de WezTerm ni de session graphique sur cette machine"
else
    "$DOTFILES_DIR/wezterm/plugins.sh" || echo "  ! Certains plugins WezTerm n'ont pas pu être clonés (réseau/proxy git ?)"
fi

if has_group secu; then
    echo
    echo "==> SecLists (wordlists)"
    SECLISTS_DIR="$HOME/tools/SecLists"
    if [ ! -d "$SECLISTS_DIR" ]; then
        echo "  -> clonage dans $SECLISTS_DIR (~1 Go, peut prendre du temps)"
        mkdir -p "$HOME/tools"
        git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR" \
            || echo "  ! Clonage de SecLists impossible (réseau/proxy ?)"
    else
        echo "  -> déjà présent dans $SECLISTS_DIR"
    fi
fi

# ---------------------------------------------------------------------------
# Récapitulatif
# ---------------------------------------------------------------------------

echo
echo "==> Récapitulatif"
report_tools || echo "  (normal sans root pour ceux qui n'existent qu'en paquet : voir README.md)"

if [ "$BIN_DIR" != "$HOME/.local/bin" ]; then
    echo
    echo "  Binaires installés dans $BIN_DIR : ce dossier est ajouté au PATH par"
    echo "  ~/.shell/env (choix mémorisé dans $STATE_FILE)."
fi

if ! command -v zsh >/dev/null 2>&1; then
    echo
    if [ -L "$HOME/.bashrc" ]; then
        echo "  zsh absent : la config bash (~/.bashrc) est en place."
    else
        echo "  zsh absent : relance avec '--bash' pour mettre en place la config bash."
    fi
fi

if command -v zsh >/dev/null 2>&1 && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo
    echo "  Ton shell de connexion n'est pas zsh. Pour le changer :"
    echo "    chsh -s \"$(command -v zsh)\""
fi

echo
echo "Terminé. Ouvre un nouveau shell (ou lance 'reload') pour appliquer la config."
