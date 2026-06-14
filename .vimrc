" Configuration basique
set nocompatible              " Désactive la compatibilité avec vi pour plus de fonctionnalités
set encoding=utf-8            " Encodage en UTF-8

" Améliorations de l'interface
syntax on                     " Active la coloration syntaxique
set number                    " Affiche les numéros de ligne
set relativenumber            " Numéros relatifs pour naviguer facilement avec des commandes 'j' et 'k'
set cursorline                " Met en surbrillance la ligne courante
set showcmd                   " Affiche les commandes partiellement tapées
set wildmenu                  " Menu de complétion en ligne de commande
set laststatus=2              " Affiche la barre de statut en bas

" Options d'édition
set tabstop=4                 " Largeur d'un tab à 4 espaces
set shiftwidth=4              " Indentation de 4 espaces
set expandtab                 " Utilise des espaces au lieu de tabulations
set autoindent                " Indentation automatique
set smartindent               " Indentation intelligente
set clipboard=unnamedplus     " Utilise le presse-papier système pour copier/coller

" Navigation et recherche
set ignorecase                " Recherche insensible à la casse
set smartcase                 " Sensible à la casse si la recherche contient des majuscules
set incsearch                 " Recherche incrémentielle
set hlsearch                  " Met en surbrillance les résultats de la recherche
nnoremap <C-n> :noh<CR>       " Supprime la surbrillance de recherche avec Ctrl+n
set splitbelow                " Fenêtres split horizontales s'ouvrent en bas
set splitright                " Fenêtres split verticales s'ouvrent à droite

" Raccourcis utiles
nnoremap <Leader>w :w!<CR>    " Sauvegarde rapide avec <Leader>w
nnoremap <Leader>q :q!<CR>    " Quitte rapidement avec <Leader>q
nnoremap <Leader>e :e!<CR>    " Recharge le fichier sans sauvegarder
nnoremap <Leader>s :sp<CR>    " Split horizontal avec <Leader>s
nnoremap <Leader>v :vsp<CR>   " Split vertical avec <Leader>v

" Raccourcis pour la navigation dans les fichiers système
nnoremap <Leader>cf :e /etc/<CR>  " Ouvre le dossier /etc pour accéder aux fichiers de configuration
nnoremap <Leader>var :e /var/log/<CR>  " Ouvre le dossier /var/log pour examiner les logs

" Raccourcis pour basculer entre les buffers
nnoremap <Leader>bn :bnext<CR>   " Passe au buffer suivant
nnoremap <Leader>bp :bprevious<CR>  " Passe au buffer précédent
nnoremap <Leader>bd :bdelete<CR>   " Supprime le buffer courant

" Amélioration de la productivité
set backspace=indent,eol,start " Backspace fonctionne comme prévu
set undofile                   " Active les fichiers d'undo pour récupérer les modifications
set undodir=~/.vim/undodir     " Spécifie le répertoire d'undo

" Meilleure intégration du terminal
set shell=/usr/bin/zsh            " Utilise Bash comme shell par défaut

