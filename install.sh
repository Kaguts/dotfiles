#!/usr/bin/env bash
#
# Bootstrap des dotfiles : crée des liens symboliques depuis ce repo
# vers leur emplacement attendu dans $HOME, et installe les outils CLI
# de la stack.
#
# Compatible :
#   - Debian/Ubuntu (apt)
#   - RHEL-like : Rocky/Alma/CentOS (dnf ou yum, via EPEL)
#   - Sans droits root/sudo : les paquets système sont ignorés (avec un
#     message indiquant ce qu'il faudra installer via un admin), mais les
#     outils installables en binaire dans ~/.local/bin (sans root) le sont
#     quand même.
#
# Usage :
#   ./install.sh          # liens symboliques uniquement
#   ./install.sh --update # recrée les liens symboliques (utile après avoir
#                          # déplacé/renommé le dossier du repo) et nettoie
#                          # les anciennes références dans ~/.gitconfig
#   ./install.sh --tools  # liens symboliques + installation des outils

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

# lien symbolique src (dans le repo) -> dest (dans $HOME), avec backup
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return 0
    fi

    if [ -e "$dest" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$2")"
        mv "$dest" "$BACKUP_DIR/$2"
        echo "Sauvegarde : $dest -> $BACKUP_DIR/$2"
    fi

    ln -snf "$src" "$dest"
    echo "Lien créé  : $dest -> $src"
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

    if [ "${1:-}" = "--update" ]; then
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

if [ "${1:-}" != "--tools" ]; then
    echo
    if [ "${1:-}" = "--update" ]; then
        echo "Liens symboliques et configuration git mis à jour."
    else
        echo "Astuce : relance avec '--tools' pour installer les outils CLI de la stack."
    fi
    exit 0
fi

# ---------------------------------------------------------------------------
# Détection root / sudo et de la famille de distribution
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
elif command -v dnf >/dev/null 2>&1; then
    PKG_FAMILY="rhel"
    PKG_MGR="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_FAMILY="rhel"
    PKG_MGR="yum"
fi

echo
echo "==> Système détecté : famille='$PKG_FAMILY', root/sudo=$([ "$HAS_ROOT" -eq 1 ] && echo oui || echo non)"

# ---------------------------------------------------------------------------
# Paquets système (nécessitent root/sudo + apt ou dnf/yum)
# ---------------------------------------------------------------------------

if [ "$HAS_ROOT" -eq 0 ]; then
    echo
    echo "==> Paquets système ignorés (pas de droits root/sudo)"
    echo "  Demande à un admin d'installer (selon la distro) :"
    echo "  Debian/Ubuntu : eza bat fd-find ripgrep fzf zoxide btop tmux lazygit lynis nmap httpie direnv ansible gobuster gping git-delta glow vim xclip unzip"
    echo "  RHEL-like     : epel-release ripgrep fzf bat fd-find tmux btop nmap lynis httpie direnv ansible-core vim-enhanced xclip git unzip"
    echo "  Les outils restants seront tout de même installés en binaire dans ~/.local/bin ci-dessous."
else
    case "$PKG_FAMILY" in
        debian)
            echo
            echo "==> Installation des outils CLI (apt)"
            $SUDO apt update
            $SUDO apt install -y \
                eza bat fd-find ripgrep fzf zoxide btop tmux \
                lazygit lynis nmap httpie \
                direnv ansible gobuster gping git-delta glow \
                vim xclip unzip   # xclip requis pour `set clipboard=unnamedplus` (.vimrc)
            ;;
        rhel)
            echo
            echo "==> Activation du dépôt EPEL"
            $SUDO "$PKG_MGR" install -y epel-release || echo "  ! epel-release indisponible, certains paquets risquent de manquer"

            echo
            echo "==> Installation des outils CLI ($PKG_MGR + EPEL)"
            # eza, zoxide, lazygit, gobuster, gping, git-delta (delta), glow,
            # lazydocker, k9s, dive, tenv, rustscan, nuclei ne sont pas
            # packagés sur RHEL-like : ils sont installés en binaire plus bas.
            $SUDO "$PKG_MGR" install -y \
                ripgrep fzf bat fd-find tmux btop nmap lynis httpie \
                direnv vim-enhanced xclip git unzip \
                || echo "  ! Certains paquets ci-dessus sont peut-être indisponibles selon ta version de RHEL"

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
command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y

echo
echo "==> Installation de Sheldon"
command -v sheldon >/dev/null || curl --proto '=https' -fLsS \
    https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"

echo
echo "==> Verrouillage des plugins Sheldon"
"$HOME/.local/bin/sheldon" lock --update 2>/dev/null || sheldon lock --update

# ---------------------------------------------------------------------------
# Outils additionnels : binaires depuis la dernière release GitHub,
# installés dans ~/.local/bin (ne nécessite PAS de droits root, fonctionne
# sur Debian comme sur RHEL-like). Si le paquet système est déjà présent
# (ex: apt sur Debian), l'outil est détecté et l'étape est ignorée.
# ---------------------------------------------------------------------------

# install_binary_release <commande> <owner/repo> <motif_asset> [nom_binaire_dans_l_archive]
install_binary_release() {
    local name="$1" repo="$2" pattern="$3" bin_name="${4:-$1}"
    command -v "$name" >/dev/null 2>&1 && return 0

    local url
    url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP "\"browser_download_url\": ?\"[^\"]*${pattern}[^\"]*\"" \
        | head -1 | grep -oP "https://[^\"]+")

    if [ -z "$url" ]; then
        echo "  ! $name : aucune archive correspondant à '$pattern' trouvée pour $repo, à installer manuellement"
        return 0
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    echo "  -> $name : $url"
    curl -fsSL "$url" -o "$tmpdir/archive"

    case "$url" in
        *.tar.gz|*.tgz)
            tar -xzf "$tmpdir/archive" -C "$tmpdir"
            ;;
        *.zip)
            if ! command -v unzip >/dev/null 2>&1; then
                echo "  ! $name : 'unzip' est requis pour extraire l'archive, installe-le puis relance"
                rm -rf "$tmpdir"
                return 0
            fi
            unzip -q "$tmpdir/archive" -d "$tmpdir"
            ;;
        *)
            echo "  ! $name : format d'archive non géré ($url)"
            rm -rf "$tmpdir"
            return 0
            ;;
    esac

    local bin_path
    bin_path=$(find "$tmpdir" -type f -name "$bin_name" | head -1)
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
install_binary_release eza        eza-community/eza  "x86_64-unknown-linux-gnu.tar.gz"
install_binary_release zoxide     ajeetdsouza/zoxide "x86_64-unknown-linux-musl.tar.gz"
install_binary_release lazygit    jesseduffield/lazygit "_linux_x86_64.tar.gz"
install_binary_release gobuster   OJ/gobuster        "Linux_x86_64.tar.gz"
install_binary_release gping      orf/gping          "x86_64-unknown-linux-gnu.tar.gz"
install_binary_release delta      dandavison/delta   "x86_64-unknown-linux-gnu.tar.gz"
install_binary_release glow       charmbracelet/glow "Linux_x86_64.tar.gz"
install_binary_release lazydocker jesseduffield/lazydocker "Linux_x86_64.tar.gz"
install_binary_release k9s        derailed/k9s       "Linux_amd64.tar.gz"
install_binary_release dive       wagoodman/dive     "linux_amd64.tar.gz"
install_binary_release tenv       tofuutils/tenv     "linux_amd64.tar.gz"
install_binary_release rustscan   RustScan/RustScan  "x86_64-unknown-linux-gnu.tar.gz"
install_binary_release nuclei     projectdiscovery/nuclei "linux_amd64.zip"
install_binary_release dysk       Canop/dysk         "x86_64-unknown-linux-musl.tar.gz"

echo
echo "==> Pré-installation des plugins WezTerm (cache local, voir wezterm/README.md)"
"$DOTFILES_DIR/wezterm/plugins.sh" || echo "  ! Certains plugins WezTerm n'ont pas pu être clonés (réseau/proxy git ?)"

echo
echo "==> SecLists (wordlists)"
SECLISTS_DIR="$HOME/tools/SecLists"
if [ ! -d "$SECLISTS_DIR" ]; then
    echo "  -> clonage dans $SECLISTS_DIR (~1 Go, peut prendre du temps)"
    mkdir -p "$HOME/tools"
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR"
else
    echo "  -> déjà présent dans $SECLISTS_DIR"
fi

# ---------------------------------------------------------------------------
# Récapitulatif
# ---------------------------------------------------------------------------

echo
echo "==> Récapitulatif"
MISSING=""
# bat/fd/httpie ont des noms de binaire différents selon la distro
# (batcat/fdfind sur Debian, bat/fd sur RHEL-like) : on accepte les deux.
for cmd in eza rg fzf zoxide btop tmux lazygit lynis nmap \
    direnv ansible gobuster gping delta glow vim xclip \
    lazydocker k9s dive tenv rustscan nuclei dysk git starship sheldon; do
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

echo
echo "Terminé. Ouvre un nouveau shell (ou lance 'reload') pour appliquer la config."
