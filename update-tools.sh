#!/usr/bin/env bash
#
# Régénère tools.lock : pour chaque outil de tools.list, cherche la dernière
# release GitHub, télécharge l'archive de chaque architecture et enregistre
# son URL et sa somme SHA-256.
#
# install.sh n'installe ensuite QUE ces versions-là, et refuse toute archive
# dont la somme ne correspond pas. Une montée de version est donc un commit
# visible : relis `git diff tools.lock` avant de le valider.
#
# Usage :
#   ./update-tools.sh              # met à jour tous les outils
#   ./update-tools.sh eza delta    # met à jour seulement ceux-là
#
# L'API GitHub limite les appels anonymes (60 par heure) : en cas de refus,
# exporte GITHUB_TOKEN (un jeton sans aucun droit suffit).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="$DOTFILES_DIR/tools.list"
LOCK_FILE="$DOTFILES_DIR/tools.lock"
ARCHS=(x86_64 arm64)

for cmd in curl sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Erreur : '$cmd' est requis." >&2; exit 1; }
done

only=("$@")
wanted() {
    [ "${#only[@]}" -eq 0 ] && return 0
    local t
    for t in "${only[@]}"; do [ "$t" = "$1" ] && return 0; done
    return 1
}

auth=()
[ -n "${GITHUB_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
new_lock="$workdir/tools.lock"
{
    echo "# Généré par update-tools.sh : ne pas modifier à la main."
    echo "# commande|architecture|url|sha256"
} > "$new_lock"

errors=0
while IFS='|' read -r name _group repo pattern _bin _glob <&3; do
    case "$name" in ''|\#*) continue ;; esac

    if ! wanted "$name"; then
        # Outil non demandé : ses entrées actuelles sont conservées telles quelles
        grep "^$name|" "$LOCK_FILE" >> "$new_lock" 2>/dev/null || true
        continue
    fi

    echo "==> $name ($repo)"
    if ! urls=$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"browser_download_url": ?"\K[^"]+'); then
        echo "  ! release introuvable (quota de l'API GitHub atteint ?)" >&2
        grep "^$name|" "$LOCK_FILE" >> "$new_lock" 2>/dev/null || true
        errors=$((errors + 1))
        continue
    fi

    for arch in "${ARCHS[@]}"; do
        case "$arch" in
            x86_64) rust="x86_64";  go="x86_64"; deb="amd64" ;;
            arm64)  rust="aarch64"; go="arm64";  deb="arm64" ;;
        esac
        regex=${pattern//\{RUST\}/$rust}
        regex=${regex//\{GO\}/$go}
        regex=${regex//\{DEB\}/$deb}

        matches=$(grep -E "${regex}\$" <<<"$urls" || true)
        # À motif égal, la variante musl est préférée
        url=$(grep -m1 musl <<<"$matches" || head -1 <<<"$matches")
        if [ -z "$url" ]; then
            echo "  ! $arch : aucune archive ne correspond à '$regex'" >&2
            errors=$((errors + 1))
            continue
        fi

        if ! curl -fsSL "$url" -o "$workdir/archive"; then
            echo "  ! $arch : téléchargement impossible ($url)" >&2
            errors=$((errors + 1))
            continue
        fi
        sha256=$(sha256sum "$workdir/archive" | cut -d' ' -f1)
        echo "$name|$arch|$url|$sha256" >> "$new_lock"
        echo "  -> $arch : $(basename "$url")"
    done
done 3< "$LIST_FILE"

mv "$new_lock" "$LOCK_FILE"
echo
echo "tools.lock mis à jour. Relis les changements avant de les valider : git diff tools.lock"
if [ "$errors" -gt 0 ]; then
    echo "$errors problème(s) rencontré(s) : les entrées concernées sont absentes ou inchangées." >&2
    exit 1
fi
