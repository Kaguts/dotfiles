#!/usr/bin/env bash
#
# Pré-clone les plugins WezTerm dans le cache local
# (~/.local/share/wezterm/plugins), pour que `wezterm.plugin.require(url)`
# les trouve directement sans accès réseau au démarrage.
#
# Utile derrière un proxy : configure d'abord `git` pour qu'il passe par le
# proxy (ex. `git config --global http.proxy http://proxy:port` ou les
# variables d'environnement http_proxy/https_proxy), puis lance ce script.
# wezterm.plugin.require() détecte que le plugin est déjà présent et ne
# tente pas de le re-cloner.
#
# Usage : ./wezterm/plugins.sh

set -euo pipefail

PLUGINS_DIR="$HOME/.local/share/wezterm/plugins"
mkdir -p "$PLUGINS_DIR"

# url du plugin -> nom de dossier attendu par WezTerm (encodage interne de l'URL)
declare -A PLUGINS=(
    ["https://github.com/adriankarlen/bar.wezterm"]="httpssCssZssZsgithubsDscomsZsadriankarlensZsbarsDswezterm"
    ["https://github.com/MLFlexer/smart_workspace_switcher.wezterm"]="httpssCssZssZsgithubsDscomsZsMLFlexersZssmart_workspace_switchersDswezterm"
    ["https://github.com/aureolebigben/wezterm-cmd-sender"]="httpssCssZssZsgithubsDscomsZsaureolebigbensZswezterm-cmd-sender"
    ["https://github.com/DavidRR-F/quick_domains.wezterm"]="httpssCssZssZsgithubsDscomsZsDavidRR-FsZsquick_domainssDswezterm"
    ["https://github.com/isseii10/workspace-picker.wezterm"]="httpssCssZssZsgithubsDscomsZsisseii10sZsworkspace-pickersDswezterm"
    ["https://github.com/mikkasendke/sessionizer.wezterm"]="httpssCssZssZsgithubsDscomsZsmikkasendkesZssessionizersDswezterm"
    ["https://github.com/vieitesss/workspacesionizer.wezterm"]="httpssCssZssZsgithubsDscomsZsvieitesssZsworkspacesionizersDswezterm"
    ["https://github.com/abidibo/wezterm-sessions"]="httpssCssZssZsgithubsDscomsZsabidibosZswezterm-sessions"
)

for url in "${!PLUGINS[@]}"; do
    dir="$PLUGINS_DIR/${PLUGINS[$url]}"
    if [ -d "$dir" ]; then
        echo "  -> déjà présent : $(basename "$url")"
    else
        echo "  -> clonage : $url"
        git clone --depth 1 "$url" "$dir" \
            || echo "  ! Échec du clonage de $url (réseau/proxy ?)"
    fi
done
