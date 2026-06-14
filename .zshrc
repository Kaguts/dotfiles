# Gestionnaire de plugins : Sheldon (config dans sheldon/plugins.toml)
eval "$(sheldon source)"

# Éditeur par défaut
export EDITOR='vim'

# PATH personnalisé
export PATH="$HOME/.local/bin:$PATH"

# Correction automatique des commandes
setopt CORRECT

# Alias et fonctions perso
source ~/.shell/alias
source ~/.shell/motd

alias reload="source ~/.zshrc"

# fzf (si installé via le package fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
