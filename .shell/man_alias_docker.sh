#!/bin/bash

# Script pour afficher le manuel des alias de base supplémentaires

function docker() {
  if [ -z "$1" ]; then
    echo "Manuel des Alias de base supplémentaires"
    echo
    echo "### cd.."
    echo "- Commande : alias cd..=\"cd ..\""
    echo "- Description : Remonter d'un niveau dans l'arborescence des dossiers. Utile pour corriger la faute fréquente d'oublier l'espace après cd."
    echo
    echo "### h"
    echo "- Commande : alias h=\"history\""
    echo "- Description : Afficher l'historique des commandes passées dans le terminal."
    echo
    echo "### psg"
    echo "- Commande : alias psg=\"ps aux | grep\""
    echo "- Description : Rechercher un processus spécifique en utilisant ps et grep. Utiliser comme psg <nom_processus>."
    echo
    echo "### dfh"
    echo "- Commande : alias dfh=\"df -h\""
    echo "- Description : Afficher l'utilisation des systèmes de fichiers avec des tailles lisibles pour l'humain."
    echo
    echo "### duh"
    echo "- Commande : alias duh=\"du -sh\""
    echo "- Description : Afficher la taille totale d'un répertoire ou d'un fichier de manière lisible. Utiliser comme duh <nom_dossier>."
    echo
    echo "### ports"
    echo "- Commande : alias ports=\"netstat -plantu\""
    echo "- Description : Afficher les ports ouverts et les connexions en écoute avec les programmes associés."
    echo
    echo "### topcpu"
    echo "- Commande : alias topcpu=\"ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head\""
    echo "- Description : Afficher les processus les plus gourmands en CPU, classés par utilisation."
    echo
    echo "### topmem"
    echo "- Commande : alias topmem=\"ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head\""
    echo "- Description : Afficher les processus les plus gourmands en mémoire, classés par utilisation."
    echo
    echo "### chx"
    echo "- Commande : alias chx=\"chmod +x\""
    echo "- Description : Rendre un fichier exécutable. Utiliser comme chx <nom_fichier>."
    echo
    echo "### vi"
    echo "- Commande : alias vi=\"vim\""
    echo "- Description : Utiliser vim à la place de vi pour une meilleure expérience d'édition."
    echo
    echo "### reload"
    echo "- Commande : alias reload=\"source ~/.zshrc\""
    echo "- Description : Recharger la configuration du terminal en appliquant les changements faits dans le fichier .zshrc."
    echo
    echo "### upg"
    echo "- Commande : alias upg=\"sudo apt update && sudo apt upgrade -y\""
    echo "- Description : Mettre à jour la liste des paquets et appliquer toutes les mises à jour disponibles sur les systèmes basés sur Debian/Ubuntu."
    echo
    echo "### log"
    echo "- Commande : alias log=\"sudo tail -f /var/log/messages\""
    echo "- Description : Afficher en temps réel les messages du journal système."
    echo
    echo "### ls"
    echo "- Commande : alias ls=\"ls --color\""
    echo "- Description : Afficher les fichiers et dossiers avec des couleurs pour différencier les types de fichiers."
    echo
    echo "### grep"
    echo "- Commande : alias grep=\"grep --color\""
    echo "- Description : Ajouter des couleurs aux résultats de grep pour faciliter la lecture."
    echo
    echo "### ll"
    echo "- Commande : alias ll=\"ls -lha --color\""
    echo "- Description : Afficher la liste des fichiers avec des détails (y compris les fichiers cachés), en format lisible et avec des couleurs."
    echo
    echo "### lh"
    echo "- Commande : alias lh=\"ls -lh --color\""
    echo "- Description : Afficher la liste des fichiers avec des détails (sans les fichiers cachés), en format lisible et avec des couleurs."
    echo
    echo "### la"
    echo "- Commande : alias la=\"ls -a --color\""
    echo "- Description : Afficher tous les fichiers, y compris les fichiers cachés, avec des couleurs."
    echo
    echo "### igrep"
    echo "- Commande : alias igrep=\"grep -i\""
    echo "- Description : Utiliser grep sans tenir compte de la casse pour trouver des correspondances."
    echo
    echo "### .."
    echo "- Commande : alias ..=\"cd ..\""
    echo "- Description : Remonter d'un niveau dans l'arborescence des dossiers."
    echo
    echo "### up"
    echo "- Commande : alias up=\"sudo -i\""
    echo "- Description : Passer en mode superutilisateur (root)."
    echo
    echo "### flushdns"
    echo "- Commande : alias flushdns=\"sudo systemd-resolve --flush-caches\""
    echo "- Description : Vider le cache DNS sur les systèmes basés sur systemd."
  else
    case "$1" in
      cd..) echo -e "\n### cd..\n- Commande : alias cd..=\"cd ..\"\n- Description : Remonter d'un niveau dans l'arborescence des dossiers. Utile pour corriger la faute fréquente d'oublier l'espace après cd." ;;
      h) echo -e "\n### h\n- Commande : alias h=\"history\"\n- Description : Afficher l'historique des commandes passées dans le terminal." ;;
      psg) echo -e "\n### psg\n- Commande : alias psg=\"ps aux | grep\"\n- Description : Rechercher un processus spécifique en utilisant ps et grep. Utiliser comme psg <nom_processus>." ;;
      dfh) echo -e "\n### dfh\n- Commande : alias dfh=\"df -h\"\n- Description : Afficher l'utilisation des systèmes de fichiers avec des tailles lisibles pour l'humain." ;;
      duh) echo -e "\n### duh\n- Commande : alias duh=\"du -sh\"\n- Description : Afficher la taille totale d'un répertoire ou d'un fichier de manière lisible. Utiliser comme duh <nom_dossier>." ;;
      ports) echo -e "\n### ports\n- Commande : alias ports=\"netstat -plantu\"\n- Description : Afficher les ports ouverts et les connexions en écoute avec les programmes associés." ;;
      topcpu) echo -e "\n### topcpu\n- Commande : alias topcpu=\"ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head\"\n- Description : Afficher les processus les plus gourmands en CPU, classés par utilisation." ;;
      topmem) echo -e "\n### topmem\n- Commande : alias topmem=\"ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head\"\n- Description : Afficher les processus les plus gourmands en mémoire, classés par utilisation." ;;
      chx) echo -e "\n### chx\n- Commande : alias chx=\"chmod +x\"\n- Description : Rendre un fichier exécutable. Utiliser comme chx <nom_fichier>." ;;
      vi) echo -e "\n### vi\n- Commande : alias vi=\"vim\"\n- Description : Utiliser vim à la place de vi pour une meilleure expérience d'édition." ;;
      reload) echo -e "\n### reload\n- Commande : alias reload=\"source ~/.zshrc\"\n- Description : Recharger la configuration du terminal en appliquant les changements faits dans le fichier .zshrc." ;;
      upg) echo -e "\n### upg\n- Commande : alias upg=\"sudo apt update && sudo apt upgrade -y\"\n- Description : Mettre à jour la liste des paquets et appliquer toutes les mises à jour disponibles sur les systèmes basés sur Debian/Ubuntu." ;;
      log) echo -e "\n### log\n- Commande : alias log=\"sudo tail -f /var/log/messages\"\n- Description : Afficher en temps réel les messages du journal système." ;;
      ls) echo -e "\n### ls\n- Commande : alias ls=\"ls --color\"\n- Description : Afficher les fichiers et dossiers avec des couleurs pour différencier les types de fichiers." ;;
      grep) echo -e "\n### grep\n- Commande : alias grep=\"grep --color\"\n- Description : Ajouter des couleurs aux résultats de grep pour faciliter la lecture." ;;
      ll) echo -e "\n### ll\n- Commande : alias ll=\"ls -lha --color\"\n- Description : Afficher la liste des fichiers avec des détails (y compris les fichiers cachés), en format lisible et avec des couleurs." ;;
      lh) echo -e "\n### lh\n- Commande : alias lh=\"ls -lh --color\"\n- Description : Afficher la liste des fichiers avec des détails (sans les fichiers cachés), en format lisible et avec des couleurs." ;;
      la) echo -e "\n### la\n- Commande : alias la=\"ls -a --color\"\n- Description : Afficher tous les fichiers, y compris les fichiers cachés, avec des couleurs." ;;
      igrep) echo -e "\n### igrep\n- Commande : alias igrep=\"grep -i\"\n- Description : Utiliser grep sans tenir compte de la casse pour trouver des correspondances." ;;
      ..) echo -e "\n### ..\n- Commande : alias ..=\"cd ..\"\n- Description : Remonter d'un niveau dans l'arborescence des dossiers." ;;
      up) echo -e "\n### up\n- Commande : alias up=\"sudo -i\"\n- Description : Passer en mode superutilisateur (root)." ;;
      flushdns) echo -e "\n### flushdns\n- Commande : alias flushdns=\"sudo systemd-resolve --flush-caches\"\n- Description : Vider le cache DNS sur les systèmes basés sur systemd." ;;
      *) echo "Alias non trouvé : $1" ;;
    esac
  fi
}

# Exécution de la fonction pour afficher le manuel
adocker "$1"

