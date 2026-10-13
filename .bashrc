# Équivalent bash de .zshrc, pour les serveurs où zsh n'est pas disponible.
# Mis en place par `./install.sh --bash` (l'ancien ~/.bashrc est sauvegardé).
# Partage ~/.shell/env et ~/.shell/alias avec zsh.

# Shell non interactif (scp, rsync, ansible, `ssh serveur commande`) : ne
# rien faire, pour ne rien afficher ni ralentir ces usages
case $- in
    *i*) ;;
    *) return ;;
esac

# Réglages système (RHEL-like ; Debian charge /etc/bash.bashrc tout seul)
# shellcheck disable=SC1091
[ -f /etc/bashrc ] && . /etc/bashrc

# Environnement commun avec zsh : PATH, éditeur, nvm, bun
# shellcheck disable=SC1090
[ -f ~/.shell/env ] && . ~/.shell/env

# Un nom de dossier seul suffit pour s'y rendre (bash 4+)
shopt -s autocd 2>/dev/null
shopt -s checkwinsize

# Historique des commandes
HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=100000
HISTTIMEFORMAT='%F %T '                # enregistre la date de chaque commande
HISTCONTROL=ignoredups:ignorespace     # ni doublons consécutifs, ni lignes commençant par un espace
shopt -s histappend                    # ajoute au lieu d'écraser
# Écrit chaque commande tout de suite (sinon perdue si la session est coupée)
case "${PROMPT_COMMAND:-}" in
    *'history -a'*) ;;
    *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac

# Complétion (si le paquet bash-completion est installé et pas déjà chargé)
if ! shopt -oq posix && [ -z "${BASH_COMPLETION_VERSINFO:-}" ] \
    && [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
fi

# Prompt : Starship s'il est installé, sinon un prompt simple en couleur
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
fi

# fzf : Ctrl-R (historique), Ctrl-T (fichiers), Alt-C (dossiers)
if command -v fzf >/dev/null 2>&1; then
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        # fzf < 0.48 : raccourcis fournis par le paquet (Debian, puis RHEL-like)
        for _f in /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/shell/key-bindings.bash; do
            # shellcheck disable=SC1090
            [ -f "$_f" ] && . "$_f" && break
        done
        unset _f
    fi
fi

# Alias et fonctions perso
# shellcheck disable=SC1090
[ -f ~/.shell/alias ] && . ~/.shell/alias
# Message d'accueil : exécuté (et non sourcé) pour ne pas laisser ses
# variables dans le shell
[ -x ~/.shell/motd ] && ~/.shell/motd

alias reload="source ~/.bashrc"

# Une fois par jour : signale si une nouvelle version des dotfiles est en ligne
# shellcheck disable=SC1090
[ -f ~/.shell/update-check ] && . ~/.shell/update-check

# zoxide : `cd` retient les dossiers visités (à initialiser en dernier)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd cd)"
fi

# Réglages propres à cette machine (fichier local, non versionné)
if [ -f ~/.bashrc.local ]; then
    # shellcheck disable=SC1090
    . ~/.bashrc.local
fi
