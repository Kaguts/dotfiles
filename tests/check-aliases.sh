#!/usr/bin/env bash
#
# Vérifie que chaque alias défini par .shell/alias lance une commande ou un
# fichier qui existe. Les alias conditionnels (eza, bat, btop...) ne sont
# définis que si l'outil est là : seuls les alias réellement actifs sur la
# machine sont contrôlés. Sert à la CI et à `./install.sh --check`.

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

shopt -s expand_aliases
# shellcheck disable=SC1091
. "$DOTFILES_DIR/.shell/alias"

status=0
for name in "${!BASH_ALIASES[@]}"; do
    value="${BASH_ALIASES[$name]}"
    # Premier mot de la commande, sans le sudo éventuel
    read -r first second _ <<<"$value"
    [ "$first" = "sudo" ] && first="$second"

    # Le tilde est celui écrit tel quel dans l'alias : on compare du texte
    # shellcheck disable=SC2088
    case "$first" in
        "~/.shell/"*)
            # ~/.shell est un lien vers le dossier .shell du repo
            target="$DOTFILES_DIR/.shell/${first#"~/.shell/"}"
            [ -x "$target" ] && continue
            ;;
        "~/"*|/*)
            target="${first/#\~/$HOME}"
            [ -x "$target" ] && continue
            ;;
        *)
            [ -n "$(type -t "$first" 2>/dev/null)" ] && continue
            ;;
    esac
    echo "  !!   alias $name : '$first' introuvable"
    status=1
done
exit $status
