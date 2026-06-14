# Gestionnaire de plugins : Sheldon (config dans sheldon/plugins.toml)
eval "$(sheldon source)"

# Éditeur par défaut
export EDITOR='vim'

# PATH personnalisé
export PATH="$HOME/.local/bin:$PATH"

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
source ~/.shell/alias
source ~/.shell/motd

alias reload="source ~/.zshrc"

# fzf (si installé via le package fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
