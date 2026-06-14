#!/bin/bash

# Demander le serveur cible
read -p "Entrez le nom du serveur cible: " target_server

# Copier les clés depuis le répertoire spécifié
mkdir -p "$HOME/.ssh/KEY"
chmod 600 "$HOME/.ssh/KEY"/*

# Vérifier si une clé portant le nom du serveur existe dans .ssh
key_path="$HOME/.ssh/KEY/ssh_$target_server"
if [ -f "$key_path" ]; then
    read -p "Une clé nommée ssh_$target_server a été trouvée. Voulez-vous l'utiliser ? (oui/non): " use_existing_key
    if [ "$use_existing_key" == "oui" ]; then
        ssh_key="$key_path"
    else
        read -p "Veuillez spécifier le chemin de la clé SSH: " ssh_key
    fi
else
    read -p "Aucune clé ne correspond au nom du serveur. Veuillez spécifier le chemin de la clé SSH: " ssh_key
fi

# Demander l'utilisateur de connexion
read -p "Entrez le nom de l'utilisateur pour la connexion: " ssh_user

# Demander l'adresse IP ou le nom de domaine du serveur
read -p "Entrez l'adresse IP ou le nom de domaine du serveur: " server_address

# Mettre à jour le fichier .ssh/config
config_entry="\nHost $target_server\n    HostName $server_address\n    User $ssh_user\n    IdentityFile $ssh_key\n    ServerAliveInterval 60\n    ServerAliveCountMax 3\n    Compression yes\n    ConnectionAttempts 3\n"

echo -e "$config_entry" >> "$HOME/.ssh/config"

echo "alias ${target_server}='ssh -i ${key_path} ${ssh_user}@${server_address}'" >> "$HOME/.shell/alias_srv"

# Afficher un message de confirmation
echo "Configuration SSH pour $target_server ajoutée avec succès dans $HOME/.ssh/config."
