#!/bin/bash

# Script pour afficher le manuel des fonctions personnalisées

function asysf() {
  if [ -z "$1" ]; then
    echo "Manuel des Fonctions Personnalisées"
    echo
    echo "### h"
    echo "- Commande : h <mot-clé>"
    echo "- Description : Recherche rapide dans l'historique des commandes contenant le mot-clé spécifié."
    echo
    echo "### cdd"
    echo "- Commande : cdd <répertoire>"
    echo "- Description : Aller à un répertoire spécifique. Si le répertoire n'existe pas, un message d'erreur est affiché."
    echo
    echo "### extract"
    echo "- Commande : extract <fichier>"
    echo "- Description : Extraire automatiquement le contenu d'un fichier compressé. Gère plusieurs formats courants (tar, zip, rar, etc.)."
    echo
    echo "### ff"
    echo "- Commande : ff <nom_fichier>"
    echo "- Description : Rechercher un fichier par nom dans le répertoire courant et ses sous-répertoires."
    echo
    echo "### fstr"
    echo "- Commande : fstr <mot-clé>"
    echo "- Description : Rechercher un contenu spécifique dans les fichiers du répertoire courant et ses sous-répertoires."
    echo
    echo "### mkcd"
    echo "- Commande : mkcd <répertoire>"
    echo "- Description : Créer un répertoire et y entrer immédiatement."
    echo
    echo "### topmem"
    echo "- Commande : topmem"
    echo "- Description : Afficher les 10 processus les plus gourmands en mémoire."
    echo
    echo "### topcpu"
    echo "- Commande : topcpu"
    echo "- Description : Afficher les 10 processus les plus gourmands en CPU."
    echo
    echo "### myip"
    echo "- Commande : myip"
    echo "- Description : Obtenir l'adresse IP locale de la machine."
  else
    case "$1" in
      h) echo -e "\n### h\n- Commande : h <mot-clé>\n- Description : Recherche rapide dans l'historique des commandes contenant le mot-clé spécifié." ;;
      cdd) echo -e "\n### cdd\n- Commande : cdd <répertoire>\n- Description : Aller à un répertoire spécifique. Si le répertoire n'existe pas, un message d'erreur est affiché." ;;
      extract) echo -e "\n### extract\n- Commande : extract <fichier>\n- Description : Extraire automatiquement le contenu d'un fichier compressé. Gère plusieurs formats courants (tar, zip, rar, etc.)." ;;
      ff) echo -e "\n### ff\n- Commande : ff <nom_fichier>\n- Description : Rechercher un fichier par nom dans le répertoire courant et ses sous-répertoires." ;;
      fstr) echo -e "\n### fstr\n- Commande : fstr <mot-clé>\n- Description : Rechercher un contenu spécifique dans les fichiers du répertoire courant et ses sous-répertoires." ;;
      mkcd) echo -e "\n### mkcd\n- Commande : mkcd <répertoire>\n- Description : Créer un répertoire et y entrer immédiatement." ;;
      topmem) echo -e "\n### topmem\n- Commande : topmem\n- Description : Afficher les 10 processus les plus gourmands en mémoire." ;;
      topcpu) echo -e "\n### topcpu\n- Commande : topcpu\n- Description : Afficher les 10 processus les plus gourmands en CPU." ;;
      myip) echo -e "\n### myip\n- Commande : myip\n- Description : Obtenir l'adresse IP locale de la machine." ;;
      *) echo "Fonction non trouvée : $1" ;;
    esac
  fi
}

# Exécution de la fonction pour afficher le manuel
asysf "$1"
