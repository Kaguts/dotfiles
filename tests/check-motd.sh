#!/usr/bin/env bash
#
# Comptage des mises à jour du motd, rejoué sur de vraies sorties de apt et
# dnf (tests/fixtures/maj/). Le 14/10/2026, la sortie de dnf4 (Rocky/Alma 9),
# qui commence par une ligne vide, donnait 0 au lieu de 110.

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOTD="$DIR/.shell/motd"
FIX="$DIR/tests/fixtures/maj"

# gestionnaire|fichier|nombre attendu
CAS=(
    "apt|apt.txt|5"
    "dnf|dnf4.txt|6"
    "dnf|dnf5.txt|3"
    "dnf|vide.txt|0"
)

echec=0
for cas in "${CAS[@]}"; do
    IFS='|' read -r gest fichier attendu <<< "$cas"
    obtenu=$(bash "$MOTD" --compter-maj="$gest" < "$FIX/$fichier")
    if [ "$obtenu" = "$attendu" ]; then
        echo "ok   $fichier ($gest) : $obtenu"
    else
        echo "!!   $fichier ($gest) : $obtenu au lieu de $attendu"
        echec=1
    fi
done

# Le motd complet doit s'afficher sans erreur
if ! bash "$MOTD" --demo --no-color > /dev/null; then
    echo "!!   motd --demo en erreur"
    echec=1
fi

exit "$echec"
