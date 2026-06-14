# Dossier `sheldon/`

Config du gestionnaire de plugins Zsh [Sheldon](https://github.com/rossmacarthur/sheldon),
qui remplace Oh My Zsh dans ce setup (chargement plus rapide, config TOML).

- `plugins.toml` → liste des plugins, chargé par `~/.zshrc` via `eval "$(sheldon source)"`

## Plugins installés

| Plugin | Rôle |
|---|---|
| `zsh-defer` | Charge certains plugins en arrière-plan pour accélérer le démarrage |
| `zsh-completions` | Complétions supplémentaires (docker, kubectl, terraform...), ajoutées au `fpath` |
| `compinit` | Initialise le système de complétion Zsh (`autoload -Uz compinit && compinit`) |
| `fzf-tab` | Remplace le menu de complétion natif par un sélecteur fzf |
| `zsh-autosuggestions` | Suggère une commande en fonction de l'historique (flèche droite pour accepter) |
| `zsh-syntax-highlighting` | Colore la commande tapée (vert = valide, rouge = invalide) |
| `starship` | Charge le prompt Starship (config dans `../starship.toml`) |
| `zoxide` | Charge `zoxide init zsh` — navigation intelligente entre dossiers (`z <dossier>`) |
| `direnv` | Charge `direnv hook zsh` — active les `.envrc` par dossier (`direnv allow`) |

⚠️ **Ordre important** (l'ordre dans `plugins.toml` = ordre de chargement) :

1. `zsh-completions` doit ajouter ses complétions au `fpath` **avant** `compinit`
2. `compinit` doit tourner **avant** `fzf-tab`
3. `zsh-autosuggestions` et `zsh-syntax-highlighting` doivent être chargés
   **en dernier** (après `fzf-tab`), car ils enveloppent des widgets ZLE —
   les charger trop tôt casse `fzf-tab`.

## Commandes utiles

```bash
# Ajouter un plugin : édite plugins.toml puis
sheldon lock --update   # régénère le lockfile

# Voir le script généré (debug)
sheldon source

# Mettre à jour tous les plugins
sheldon lock --update
```

⚙️ **Astuce** : versionne uniquement `plugins.toml` — le lockfile
(`~/.local/share/sheldon/plugins.lock`) est régénéré automatiquement et
dépend de la machine.
