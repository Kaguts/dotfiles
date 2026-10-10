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
#     outils installables en binaire dans ~/.local/bin (sans root) le sont
#     quand même.
#
# Usage :
#   ./install.sh            # liens symboliques uniquement
#   ./install.sh --update   # recrée les liens symboliques (utile après avoir
#                            # déplacé/renommé le dossier du repo) et nettoie
#                            # les anciennes références dans ~/.gitconfig
#   ./install.sh --tools    # liens symboliques + installation des outils
#   ./install.sh --sysadmin # comme --update + --tools, sans les outils sécu
#                            # (gobuster, nmap, lynis, rustscan, nuclei) ni SecLists
#   ./install.sh --wezterm-windows
#                            # (WSL) copie la config WezTerm dans le profil
#                            # Windows ; combinable avec les autres options
#   ./install.sh --help

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

usage() {
    sed -n '/^# Usage :/,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

DO_UPDATE=0
DO_TOOLS=0
SKIP_SECURITY=0
DO_WEZTERM_WINDOWS=0
for arg in "$@"; do
    case "$arg" in
        --update)          DO_UPDATE=1 ;;
        --tools)           DO_TOOLS=1 ;;
        --sysadmin)        DO_UPDATE=1; DO_TOOLS=1; SKIP_SECURITY=1 ;;
        --wezterm-windows) DO_WEZTERM_WINDOWS=1 ;;
        -h|--help)         usage; exit 0 ;;
        *)                 echo "Option inconnue : $arg" >&2; usage >&2; exit 2 ;;
    esac
done

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

# Requis par `set undofile` / `set undodir` dans .vimrc
mkdir -p "$HOME/.vim/undodir" "$HOME/.local/bin"

echo "==> Mise en place des liens symboliques"
link ".zshrc"             ".zshrc"
link ".vimrc"              ".vimrc"
link ".tmux.conf"          ".tmux.conf"
link ".shell"              ".shell"
link "wezterm"             ".config/wezterm"
link "sheldon/plugins.toml" ".config/sheldon/plugins.toml"
link "starship.toml"       ".config/starship.toml"

# Alias git : inclus depuis ~/.gitconfig sans écraser l'identité existante
GIT_ALIASES="$DOTFILES_DIR/git/aliases.gitconfig"
if command -v git >/dev/null 2>&1; then
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
    else
        echo "Astuce : relance avec '--tools' pour installer les outils CLI de la stack."
    fi
    exit 0
fi

# ---------------------------------------------------------------------------
# Détection root / sudo, de la famille de distribution et de l'architecture
# ---------------------------------------------------------------------------

SUDO=""
HAS_ROOT=0
if [ "$(id -u)" -eq 0 ]; then
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

# Les projets ne nomment pas leurs archives de la même façon :
#   ARCH_RUST : x86_64 / aarch64     (eza, zoxide, delta, rustscan, dysk)
#   ARCH_GO   : x86_64 / arm64       (lazygit, gobuster, gping, glow, lazydocker, tenv)
#   ARCH_DEB  : amd64  / arm64       (k9s, dive, nuclei)
case "$(uname -m)" in
    x86_64|amd64)  ARCH_RUST="x86_64";  ARCH_GO="x86_64"; ARCH_DEB="amd64" ;;
    aarch64|arm64) ARCH_RUST="aarch64"; ARCH_GO="arm64";  ARCH_DEB="arm64" ;;
    *)             ARCH_RUST="";        ARCH_GO="";       ARCH_DEB="" ;;
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
        echo "    (ceux qui existent en binaire seront installés dans ~/.local/bin plus bas)"
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Paquets système (nécessitent root/sudo + apt ou dnf/yum)
# ---------------------------------------------------------------------------

if [ "$HAS_ROOT" -eq 0 ]; then
    echo
    echo "==> Paquets système ignorés (pas de droits root/sudo)"
    echo "  Demande à un admin d'installer (selon la distro) :"
    echo "  Debian/Ubuntu : zsh eza bat fd-find ripgrep fzf zoxide btop tmux lazygit lynis nmap httpie direnv ansible gobuster gping git-delta glow vim xclip unzip"
    echo "  RHEL-like     : epel-release zsh ripgrep fzf bat fd-find tmux btop nmap lynis httpie direnv ansible-core vim-enhanced xclip git unzip util-linux-user"
    echo "  Les outils restants seront tout de même installés en binaire dans ~/.local/bin ci-dessous."
else
    case "$PKG_FAMILY" in
        debian)
            echo
            echo "==> Installation des outils CLI (apt)"
            $SUDO apt-get update
            # eza, lazygit, gping, glow... n'existent pas sur toutes les versions
            # (Debian 12, Ubuntu 22.04) : pkg_install tolère les absents.
            pkg_install \
                zsh curl git tar unzip \
                eza bat fd-find ripgrep fzf zoxide btop tmux \
                lazygit httpie \
                direnv ansible gping git-delta glow \
                vim xclip   # xclip requis pour `set clipboard=unnamedplus` (.vimrc)
            if [ "$SKIP_SECURITY" -eq 0 ]; then
                pkg_install lynis nmap gobuster
            fi
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
            # eza, zoxide, lazygit, gobuster, gping, git-delta (delta), glow,
            # lazydocker, k9s, dive, tenv, rustscan, nuclei ne sont pas
            # packagés sur RHEL-like : ils sont installés en binaire plus bas.
            # util-linux-user fournit chsh (pour passer à zsh).
            pkg_install \
                zsh curl git tar unzip util-linux-user \
                ripgrep fzf bat fd-find tmux btop httpie \
                direnv vim-enhanced xclip
            if [ "$SKIP_SECURITY" -eq 0 ]; then
                pkg_install nmap lynis
            fi

            $SUDO "$PKG_MGR" install -y ansible-core 2>/dev/null \
                || $SUDO "$PKG_MGR" install -y ansible \
                || echo "  ! ansible/ansible-core indisponible, à installer manuellement"
            ;;
        *)
            echo
            echo "==> Gestionnaire de paquets non reconnu, étape des paquets système ignorée"
            ;;
    esac
fi

echo
echo "==> Installation de Starship"
# -b : installe dans ~/.local/bin (le défaut /usr/local/bin exige root)
command -v starship >/dev/null 2>&1 \
    || curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
    || echo "  ! Starship n'a pas pu être installé, à installer manuellement"

echo
echo "==> Installation de Sheldon"
command -v sheldon >/dev/null 2>&1 || [ -x "$HOME/.local/bin/sheldon" ] \
    || curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin" \
    || echo "  ! Sheldon n'a pas pu être installé, à installer manuellement"

echo
echo "==> Verrouillage des plugins Sheldon"
"$HOME/.local/bin/sheldon" lock --update 2>/dev/null \
    || sheldon lock --update \
    || echo "  ! 'sheldon lock' a échoué (réseau/proxy ?), relance-le manuellement"

# ---------------------------------------------------------------------------
# Outils additionnels : binaires depuis la dernière release GitHub,
# installés dans ~/.local/bin (ne nécessite PAS de droits root, fonctionne
# sur Debian comme sur RHEL-like). Si le paquet système est déjà présent
# (ex: apt sur Debian), l'outil est détecté et l'étape est ignorée.
# ---------------------------------------------------------------------------

# install_binary_release <commande> <owner/repo> <motif_asset> [nom_binaire] [motif_chemin]
#   motif_asset  : expression régulière sur le nom de l'archive
#   nom_binaire  : nom du binaire dans l'archive (défaut : <commande>)
#   motif_chemin : motif `find -path` pour choisir le bon binaire quand
#                  l'archive en contient plusieurs (une par architecture)
# Ne fait jamais échouer le script : tout problème est signalé puis ignoré.
install_binary_release() {
    local name="$1" repo="$2" pattern="$3" bin_name="${4:-$1}" path_glob="${5:-*}"
    command -v "$name" >/dev/null 2>&1 && return 0

    if [ -z "$ARCH_RUST" ]; then
        echo "  ! $name : architecture $(uname -m) non gérée, à installer manuellement"
        return 0
    fi

    local url
    # `|| true` : sans correspondance, grep renvoie 1 et `set -e -o pipefail`
    # arrêterait tout le script avant le message ci-dessous.
    url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | grep -oP "\"browser_download_url\": ?\"\\K[^\"]*${pattern}(?=\")" \
        | head -1 || true)

    if [ -z "$url" ]; then
        echo "  ! $name : aucune archive correspondant à '$pattern' trouvée pour $repo"
        echo "    (format de release modifié, ou quota de l'API GitHub atteint) : à installer manuellement"
        return 0
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    echo "  -> $name : $url"
    if ! curl -fsSL "$url" -o "$tmpdir/archive"; then
        echo "  ! $name : téléchargement impossible"
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
        install -m755 "$bin_path" "$HOME/.local/bin/$bin_name"
        echo "  -> $name installé dans ~/.local/bin"
    fi
    rm -rf "$tmpdir"
}

echo
echo "==> Installation des outils additionnels (binaires depuis GitHub releases, ~/.local/bin)"
# Les variantes musl (liées statiquement) sont préférées quand elles existent :
# elles tournent aussi sur les glibc anciennes (RHEL 8).
install_binary_release eza        eza-community/eza  "${ARCH_RUST}-unknown-linux-gnu\\.tar\\.gz"
install_binary_release zoxide     ajeetdsouza/zoxide "${ARCH_RUST}-unknown-linux-musl\\.tar\\.gz"
install_binary_release lazygit    jesseduffield/lazygit "_linux_${ARCH_GO}\\.tar\\.gz"
install_binary_release gping      orf/gping          "Linux-musl-${ARCH_GO}\\.tar\\.gz"
install_binary_release delta      dandavison/delta   "${ARCH_RUST}-unknown-linux-(musl|gnu)\\.tar\\.gz"
install_binary_release glow       charmbracelet/glow "_Linux_${ARCH_GO}\\.tar\\.gz"
install_binary_release lazydocker jesseduffield/lazydocker "_Linux_${ARCH_GO}\\.tar\\.gz"
install_binary_release k9s        derailed/k9s       "_Linux_${ARCH_DEB}\\.tar\\.gz"
install_binary_release dive       wagoodman/dive     "_linux_${ARCH_DEB}\\.tar\\.gz"
install_binary_release tenv       tofuutils/tenv     "_Linux_${ARCH_GO}\\.tar\\.gz"
install_binary_release dysk       Canop/dysk         "dysk_[0-9.]+\\.zip" dysk "*/${ARCH_RUST}-unknown-linux-musl/*"
if [ "$SKIP_SECURITY" -eq 0 ]; then
    install_binary_release gobuster OJ/gobuster         "_Linux_${ARCH_GO}\\.tar\\.gz"
    install_binary_release rustscan RustScan/RustScan   "/${ARCH_RUST}-linux-rustscan(\\.tar\\.gz)?\\.zip"
    install_binary_release nuclei   projectdiscovery/nuclei "_linux_${ARCH_DEB}\\.zip"
fi

echo
echo "==> Pré-installation des plugins WezTerm (cache local, voir wezterm/README.md)"
if [ "$IS_WSL" -eq 1 ]; then
    echo "  -> ignoré dans WSL : WezTerm (côté Windows) clone ses plugins lui-même au premier lancement"
else
    "$DOTFILES_DIR/wezterm/plugins.sh" || echo "  ! Certains plugins WezTerm n'ont pas pu être clonés (réseau/proxy git ?)"
fi

if [ "$SKIP_SECURITY" -eq 0 ]; then
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

# Les binaires fraîchement installés ne sont pas forcément dans le PATH courant
export PATH="$HOME/.local/bin:$PATH"

echo
echo "==> Récapitulatif"
MISSING=""
# bat/fd/httpie ont des noms de binaire différents selon la distro
# (batcat/fdfind sur Debian, bat/fd sur RHEL-like) : on accepte les deux.
SEC_CMDS=""
[ "$SKIP_SECURITY" -eq 0 ] && SEC_CMDS="lynis nmap gobuster rustscan nuclei"
for cmd in zsh eza rg fzf zoxide btop tmux lazygit \
    direnv ansible gping delta glow vim xclip \
    lazydocker k9s dive tenv dysk git starship sheldon $SEC_CMDS; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING="$MISSING $cmd"
done
command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1 || MISSING="$MISSING bat"
command -v fd  >/dev/null 2>&1 || command -v fdfind  >/dev/null 2>&1 || MISSING="$MISSING fd"
command -v http >/dev/null 2>&1 || MISSING="$MISSING httpie"

if [ -n "$MISSING" ]; then
    echo "  Outils absents (non installés automatiquement, à voir manuellement) :"
    echo "   $MISSING"
    echo "  (normal sur RHEL-like ou sans root pour certains : voir README.md)"
else
    echo "  Tous les outils de la stack sont présents."
fi

if command -v zsh >/dev/null 2>&1 && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo
    echo "  Ton shell de connexion n'est pas zsh. Pour le changer :"
    echo "    chsh -s \"$(command -v zsh)\""
fi

echo
echo "Terminé. Ouvre un nouveau shell (ou lance 'reload') pour appliquer la config."
