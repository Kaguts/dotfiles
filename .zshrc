# Environnement commun avec bash : PATH, éditeur, nvm, bun. Avant Sheldon,
# car sheldon, starship, zoxide... peuvent être dans ~/.local/bin ou dans
# le dossier choisi avec `install.sh --bin-dir`.
[ -f ~/.shell/env ] && source ~/.shell/env
[ -n "${BUN_INSTALL:-}" ] && [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Gestionnaire de plugins : Sheldon (config dans sheldon/plugins.toml)
if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
fi

# Un nom de dossier seul suffit pour s'y rendre ("..", "/etc", "projets")
setopt AUTO_CD

# Historique des commandes
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY    # enregistre la date et la durée de chaque commande
setopt SHARE_HISTORY       # partage l'historique entre sessions ouvertes
setopt HIST_IGNORE_DUPS    # pas de doublons consécutifs
setopt HIST_FIND_NO_DUPS   # la recherche ne montre chaque commande qu'une fois
setopt HIST_IGNORE_SPACE   # ignore les commandes commençant par un espace
setopt HIST_REDUCE_BLANKS  # retire les espaces superflus
setopt APPEND_HISTORY      # ajoute au lieu d'écraser

# Alias et fonctions perso
[ -f ~/.shell/alias ] && source ~/.shell/alias
# Message d'accueil : exécuté (et non sourcé) pour ne pas laisser ses
# variables dans le shell
[ -x ~/.shell/motd ] && ~/.shell/motd

alias reload="source ~/.zshrc"

# Une fois par jour : signale si une nouvelle version des dotfiles est en ligne
[ -f ~/.shell/update-check ] && source ~/.shell/update-check

# Réglages propres à cette machine (fichier local, non versionné)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
