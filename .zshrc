# PATH personnalisé (avant Sheldon : sheldon, starship, zoxide... peuvent
# être installés dans ~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"

# Gestionnaire de plugins : Sheldon (config dans sheldon/plugins.toml)
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

# Éditeur par défaut
export EDITOR='vim'

# Correction automatique des commandes
setopt CORRECT

# Historique des commandes
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY       # partage l'historique entre sessions ouvertes
setopt HIST_IGNORE_DUPS    # pas de doublons consécutifs
setopt HIST_IGNORE_SPACE   # ignore les commandes commençant par un espace
setopt APPEND_HISTORY      # ajoute au lieu d'écraser

# Alias et fonctions perso
[ -f ~/.shell/alias ] && source ~/.shell/alias
# Message d'accueil : exécuté (et non sourcé) pour ne pas laisser ses
# variables dans le shell
[ -x ~/.shell/motd ] && ~/.shell/motd

alias reload="source ~/.zshrc"

# fzf (si installé via le package fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# nvm (si installé)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun (si installé)
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# Réglages propres à cette machine (fichier local, non versionné)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
