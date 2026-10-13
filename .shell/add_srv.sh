#!/bin/bash
#
# Ajoute un serveur : une entrée Host dans ~/.ssh/config. L'alias de
# connexion (le nom du serveur) en découle : ~/.shell/alias en crée un par
# Host à l'ouverture du shell.

set -euo pipefail

SSH_DIR="$HOME/.ssh"
KEY_DIR="$SSH_DIR/KEY"
SSH_CONFIG="$SSH_DIR/config"

# ask <question> : lit une réponse non vide
ask() {
    local answer=""
    while [ -z "$answer" ]; do
        read -rp "$1" answer
    done
    printf '%s' "$answer"
}

mkdir -p "$KEY_DIR"
chmod 700 "$SSH_DIR" "$KEY_DIR"
# Clés privées en 600 (sans erreur si le dossier est vide)
find "$KEY_DIR" -maxdepth 1 -type f ! -name '*.pub' -exec chmod 600 {} +
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

target_server=$(ask "Entrez le nom du serveur cible: ")
if ! [[ "$target_server" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Erreur : nom invalide (lettres, chiffres, '.', '_' et '-' uniquement)." >&2
    exit 1
fi

# Refuse les doublons plutôt que d'empiler des entrées contradictoires
if grep -qE "^[[:space:]]*Host[[:space:]]+${target_server//./\\.}[[:space:]]*$" "$SSH_CONFIG"; then
    echo "Erreur : un Host '$target_server' existe déjà dans $SSH_CONFIG." >&2
    exit 1
fi

# Clé : celle qui porte le nom du serveur si elle existe, sinon chemin saisi
ssh_key="$KEY_DIR/ssh_$target_server"
if [ -f "$ssh_key" ]; then
    read -rp "Une clé nommée ssh_$target_server a été trouvée. Voulez-vous l'utiliser ? (oui/non): " use_existing_key
    case "$use_existing_key" in
        o|O|oui|OUI|Oui|y|Y|yes) ;;
        *) ssh_key=$(ask "Veuillez spécifier le chemin de la clé SSH: ") ;;
    esac
else
    ssh_key=$(ask "Aucune clé ne correspond au nom du serveur. Veuillez spécifier le chemin de la clé SSH: ")
fi
ssh_key="${ssh_key/#\~/$HOME}"
if [ ! -f "$ssh_key" ]; then
    echo "Erreur : la clé '$ssh_key' est introuvable." >&2
    exit 1
fi

ssh_user=$(ask "Entrez le nom de l'utilisateur pour la connexion: ")
server_address=$(ask "Entrez l'adresse IP ou le nom de domaine du serveur: ")
if [[ "$ssh_user$server_address" =~ [[:space:]\'\"] ]]; then
    echo "Erreur : l'utilisateur et l'adresse ne doivent contenir ni espace ni guillemet." >&2
    exit 1
fi

cat >> "$SSH_CONFIG" <<EOF

Host $target_server
    HostName $server_address
    User $ssh_user
    IdentityFile $ssh_key
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    ConnectionAttempts 3
EOF

echo "Configuration SSH pour $target_server ajoutée dans $SSH_CONFIG."
echo "Connexion : 'ssh $target_server', ou simplement '$target_server' après 'reload'."
