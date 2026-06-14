#!/bin/bash

# Script pour afficher le manuel des alias de Git

function agit() {
  if [ -z "$1" ]; then
    echo "Manuel des Alias de git supplémentaires"
    echo
    echo "### gs"
    echo "- Commande : alias gs=\"git status\""
    echo "- Description : Voir l'état du dépôt Git."
    echo
    echo "### ga"
    echo "- Commande : alias ga=\"git add\""
    echo "- Description : Ajouter un fichier à Git. Utiliser comme ga <nom_fichier>."
    echo
    echo "### gaa"
    echo "- Commande : alias gaa=\"git add --all\""
    echo "- Description : Ajouter tous les fichiers au suivi de Git."
    echo
    echo "### gc"
    echo "- Commande : alias gc=\"git commit -m\""
    echo "- Description : Commiter des modifications avec un message. Utiliser comme gc \"message\"."
    echo
    echo "### gl"
    echo "- Commande : alias gl=\"git log --oneline --graph --decorate\""
    echo "- Description : Voir le log Git sous une forme compacte et graphique."
    echo
    echo "### gb"
    echo "- Commande : alias gb=\"git checkout -b\""
    echo "- Description : Créer une nouvelle branche et se déplacer dessus. Utiliser comme gb <nom_branche>."
    echo
    echo "### gd"
    echo "- Commande : alias gd=\"git diff\""
    echo "- Description : Voir la différence entre les versions."
    echo
    echo "### gp"
    echo "- Commande : alias gp=\"git push\""
    echo "- Description : Pousser les modifications vers le dépôt distant."
    echo
    echo "### gpl"
    echo "- Commande : alias gpl=\"git pull\""
    echo "- Description : Récupérer les dernières modifications depuis le dépôt distant."
    echo
    echo "### gbr"
    echo "- Commande : alias gbr=\"git branch -a\""
    echo "- Description : Voir toutes les branches Git, locales et distantes."
    echo
    echo "### gbd"
    echo "- Commande : alias gbd=\"git branch -d\""
    echo "- Description : Supprimer une branche Git. Utiliser comme gbd <nom_branche>."
    echo
    echo "### gco"
    echo "- Commande : alias gco=\"git checkout\""
    echo "- Description : Changer de branche ou restaurer des fichiers dans Git. Utiliser comme gco <nom_branche>."
    echo
    echo "### gf"
    echo "- Commande : alias gf=\"git fetch\""
    echo "- Description : Récupérer les changements du dépôt distant sans les fusionner."
    echo
    echo "### grh"
    echo "- Commande : alias grh=\"git reset --hard\""
    echo "- Description : Réinitialiser le dépôt à un état précédent, en supprimant les modifications locales. Utiliser avec précaution."
    echo
    echo "### gstash"
    echo "- Commande : alias gstash=\"git stash\""
    echo "- Description : Sauvegarder temporairement des modifications sans les committer."
    echo
    echo "### gpop"
    echo "- Commande : alias gpop=\"git stash pop\""
    echo "- Description : Restaurer les modifications précédemment sauvegardées avec git stash."
    echo
    echo "### gsl"
    echo "- Commande : alias gsl=\"git stash list\""
    echo "- Description : Voir la liste des stashes disponibles."
    echo
    echo "### gplr"
    echo "- Commande : alias gplr=\"git pull --rebase\""
    echo "- Description : Récupérer les modifications distantes et rebaser les changements locaux par-dessus."
    echo
    echo "### glast"
    echo "- Commande : alias glast=\"git show --stat\""
    echo "- Description : Voir les informations sur le dernier commit, y compris les fichiers modifiés."
    echo
    echo "### gca"
    echo "- Commande : alias gca=\"git commit --amend\""
    echo "- Description : Modifier le dernier commit, par exemple pour ajouter des fichiers oubliés ou corriger le message de commit."
    echo
    echo "### girb"
    echo "- Commande : alias girb=\"git rebase -i\""
    echo "- Description : Interagir avec l'historique des commits pour les modifier, les fusionner ou les réorganiser."
    echo
    echo "### gtags"
    echo "- Commande : alias gtags=\"git tag -l\""
    echo "- Description : Lister tous les tags du dépôt Git."
    echo
    echo "### gbd-remote"
    echo "- Commande : alias gbd-remote=\"git push origin --delete\""
    echo "- Description : Supprimer une branche distante. Utiliser comme gbd-remote <nom_branche>."
    echo
    echo "### gsall"
    echo "- Commande : alias gsall=\"git status --short --branch\""
    echo "- Description : Voir l'état du dépôt avec un résumé succinct, y compris la branche courante."
  else
    case "$1" in
      gs) echo -e "\n### gs\n- Commande : alias gs=\"git status\"\n- Description : Voir l'état du dépôt Git." ;;
      ga) echo -e "\n### ga\n- Commande : alias ga=\"git add\"\n- Description : Ajouter un fichier à Git. Utiliser comme ga <nom_fichier>." ;;
      gaa) echo -e "\n### gaa\n- Commande : alias gaa=\"git add --all\"\n- Description : Ajouter tous les fichiers au suivi de Git." ;;
      gc) echo -e "\n### gc\n- Commande : alias gc=\"git commit -m\"\n- Description : Commiter des modifications avec un message. Utiliser comme gc \"message\"." ;;
      gl) echo -e "\n### gl\n- Commande : alias gl=\"git log --oneline --graph --decorate\"\n- Description : Voir le log Git sous une forme compacte et graphique." ;;
      gb) echo -e "\n### gb\n- Commande : alias gb=\"git checkout -b\"\n- Description : Créer une nouvelle branche et se déplacer dessus. Utiliser comme gb <nom_branche>." ;;
      gd) echo -e "\n### gd\n- Commande : alias gd=\"git diff\"\n- Description : Voir la différence entre les versions." ;;
      gp) echo -e "\n### gp\n- Commande : alias gp=\"git push\"\n- Description : Pousser les modifications vers le dépôt distant." ;;
      gpl) echo -e "\n### gpl\n- Commande : alias gpl=\"git pull\"\n- Description : Récupérer les dernières modifications depuis le dépôt distant." ;;
      gbr) echo -e "\n### gbr\n- Commande : alias gbr=\"git branch -a\"\n- Description : Voir toutes les branches Git, locales et distantes." ;;
      gbd) echo -e "\n### gbd\n- Commande : alias gbd=\"git branch -d\"\n- Description : Supprimer une branche Git. Utiliser comme gbd <nom_branche>." ;;
      gco) echo -e "\n### gco\n- Commande : alias gco=\"git checkout\"\n- Description : Changer de branche ou restaurer des fichiers dans Git. Utiliser comme gco <nom_branche>." ;;
      gf) echo -e "\n### gf\n- Commande : alias gf=\"git fetch\"\n- Description : Récupérer les changements du dépôt distant sans les fusionner." ;;
      grh) echo -e "\n### grh\n- Commande : alias grh=\"git reset --hard\"\n- Description : Réinitialiser le dépôt à un état précédent, en supprimant les modifications locales. Utiliser avec précaution." ;;
      gstash) echo -e "\n### gstash\n- Commande : alias gstash=\"git stash\"\n- Description : Sauvegarder temporairement des modifications sans les committer." ;;
      gpop) echo -e "\n### gpop\n- Commande : alias gpop=\"git stash pop\"\n- Description : Restaurer les modifications précédemment sauvegardées avec git stash." ;;
      gsl) echo -e "\n### gsl\n- Commande : alias gsl=\"git stash list\"\n- Description : Voir la liste des stashes disponibles." ;;
      gplr) echo -e "\n### gplr\n- Commande : alias gplr=\"git pull --rebase\"\n- Description : Récupérer les modifications distantes et rebaser les changements locaux par-dessus." ;;
      glast) echo -e "\n### glast\n- Commande : alias glast=\"git show --stat\"\n- Description : Voir les informations sur le dernier commit, y compris les fichiers modifiés." ;;
      gca) echo -e "\n### gca\n- Commande : alias gca=\"git commit --amend\"\n- Description : Modifier le dernier commit, par exemple pour ajouter des fichiers oubliés ou corriger le message de commit." ;;
      girb) echo -e "\n### girb\n- Commande : alias girb=\"git rebase -i\"\n- Description : Interagir avec l'historique des commits pour les modifier, les fusionner ou les réorganiser." ;;
      gtags) echo -e "\n### gtags\n- Commande : alias gtags=\"git tag -l\"\n- Description : Lister tous les tags du dépôt Git." ;;
      gbd-remote) echo -e "\n### gbd-remote\n- Commande : alias gbd-remote=\"git push origin --delete\"\n- Description : Supprimer une branche distante. Utiliser comme gbd-remote <nom_branche>." ;;
      gsall) echo -e "\n### gsall\n- Commande : alias gsall=\"git status --short --branch\"\n- Description : Voir l'état du dépôt avec un résumé succinct, y compris la branche courante." ;;
      *) echo "Alias non trouvé : $1" ;;
    esac
  fi
}

# Exécution de la fonction pour afficher le manuel
agit "$1"
