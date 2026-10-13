#!/usr/bin/env bash
#
# Ce dépôt est public : vérifie qu'aucune information propre à une machine
# ne s'y glisse. Contrôle les fichiers suivis par git et les nouveaux fichiers
# non ignorés (ce qui partirait au prochain commit).
#
# Cherche : adresses IP, chemins de dossier personnel, clés privées et jetons,
# et, sur ta machine, ce qui t'identifie : ton nom d'utilisateur, le nom de
# la machine, et les Host / HostName / User de ~/.ssh/config. Ces valeurs sont
# lues sur place au moment du contrôle : aucune n'est écrite dans le dépôt.
#
# Lancé par la CI, par `git commit` (voir .githooks/pre-commit) ou à la main.

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

# Motifs génériques. Les adresses d'exemple ou publiques connues sont admises.
ALLOWED_IPS='^(1\.1\.1\.1|1\.2\.3\.4|127\.0\.0\.1|0\.0\.0\.0)$'
GENERIC='/home/[a-z][a-z0-9_-]*/|/Users/[A-Za-z]|BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{20}|glpat-[A-Za-z0-9_-]{15}|AKIA[0-9A-Z]{16}'
# /home/user/ et /home/invite/ sont des chemins d'exemple
GENERIC_OK='/home/(user|invite|utilisateur)/'

# Mots propres à cette machine (aucun en CI)
words=()
add_word() {
    # Ignore les valeurs trop courtes ou banales, sources de faux positifs
    case "$1" in
        ''|?|??|root|git|admin|user|localhost|debian|ubuntu) return ;;
    esac
    words+=("$1")
}
add_word "${USER:-}"
add_word "$(hostname 2>/dev/null || true)"
if [ -r "$HOME/.ssh/config" ]; then
    while read -r value; do
        add_word "$value"
    done < <(awk 'tolower($1) ~ /^(host|hostname|user)$/ { for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i }' "$HOME/.ssh/config" | sort -u)
fi

status=0
report() {
    echo "  !!   $1"
    status=1
}

while IFS= read -r file; do
    [ -f "$file" ] || continue
    # Fichiers binaires (images...) : ignorés
    grep -Iq . "$file" 2>/dev/null || continue

    while IFS= read -r hit; do
        report "$file:$hit"
    done < <(grep -nE "$GENERIC" "$file" | grep -vE "$GENERIC_OK" || true)

    while IFS=: read -r line ip; do
        [[ "$ip" =~ $ALLOWED_IPS ]] || report "$file:$line: adresse IP $ip"
    done < <(grep -noE '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' "$file" || true)

    for word in "${words[@]}"; do
        while IFS= read -r hit; do
            report "$file:${hit%%:*}: contient un nom propre à cette machine"
        done < <(grep -nwiF -- "$word" "$file" || true)
    done
done < <({ git ls-files; git ls-files --others --exclude-standard; } | sort -u)

if [ "$status" -ne 0 ]; then
    echo "Informations personnelles détectées : corrige avant de commiter (dépôt public)."
fi
exit $status
