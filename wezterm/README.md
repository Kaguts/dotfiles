# WezTerm Config

Configuration modulaire pour [WezTerm](https://wezfurlong.org/wezterm/).

## Répertoires

- `config/` → modules de configuration principaux (UI, options, GPU, clés…)
- `mappings/` → définitions des raccourcis en tables lisibles
- `events/` → callbacks et comportements dynamiques
- `utils/` → fonctions utilitaires partagées
- `colors/` → thèmes personnalisés (Lua)
- `backdrops/` → images d’arrière-plan
- `plugins.sh` → pré-clone les plugins WezTerm en local (voir section Plugins)

Voir le README de chaque dossier pour plus de détails.

---

## 🔌 Plugins

`wezterm.lua` charge les plugins via `wezterm.plugin.require(url)`, le
gestionnaire intégré à WezTerm (clone Git automatique dans
`~/.local/share/wezterm/plugins/`).

| Plugin | Statut | Rôle |
|---|---|---|
| [bar.wezterm](https://github.com/adriankarlen/bar.wezterm) | Actif | Barre d'onglets/statut personnalisée |
| [smart_workspace_switcher.wezterm](https://github.com/MLFlexer/smart_workspace_switcher.wezterm) | Actif (`LEADER+s` / `LEADER+Maj+s`) | Bascule/crée des workspaces à partir de dossiers (zoxide) |
| [wezterm-cmd-sender](https://github.com/aureolebigben/wezterm-cmd-sender) | Cloné, non activé | Envoie une commande à un pane distant |
| [quick_domains.wezterm](https://github.com/DavidRR-F/quick_domains.wezterm) | Cloné, non activé | Lanceur rapide pour les domaines SSH/WSL |
| [workspace-picker.wezterm](https://github.com/isseii10/workspace-picker.wezterm) | Cloné, non activé | Alternative à smart_workspace_switcher |
| [sessionizer.wezterm](https://github.com/mikkasendke/sessionizer.wezterm) | Cloné, non activé | Alternative façon tmux-sessionizer |
| [workspacesionizer.wezterm](https://github.com/vieitesss/workspacesionizer.wezterm) | Cloné, non activé | Alternative à smart_workspace_switcher |
| [wezterm-sessions](https://github.com/abidibo/wezterm-sessions) | Cloné, non activé | Sauvegarde/restauration de sessions (panes/tabs/cwd) |

Plusieurs plugins ci-dessus font la même chose (changer de workspace à partir
d'un dossier) : seul `smart_workspace_switcher.wezterm` est activé pour
éviter les conflits de raccourcis. Les autres sont déjà clonés en local — pour
en essayer un, décommente le bloc correspondant dans `wezterm.lua` (section
"Autres plugins pré-clonés mais non activés").

### Installation locale (proxy)

`wezterm.plugin.require(url)` clone le plugin via `git` au premier lancement,
ce qui échoue derrière un proxy non configuré pour `git`. Le script
`plugins.sh` pré-clone tous les plugins ci-dessus dans
`~/.local/share/wezterm/plugins/` (même nommage que WezTerm) :

```bash
# configure d'abord git pour ton proxy si besoin, ex :
#   git config --global http.proxy http://proxy:port
./wezterm/plugins.sh
```

Lancé automatiquement par `./install.sh --tools`. Une fois les dossiers
présents, `wezterm.plugin.require()` les détecte et ne tente plus de les
re-cloner — fonctionne donc aussi hors-ligne.


---

## 📂 config/README.md

```markdown
# Dossier `config/`

Contient les modules de configuration principaux, appelés par `wezterm.lua`.

- `options.lua` → options générales (scrollback, décorations, FPS…)
- `platform.lua` → détection de l’environnement (Windows, WSL, Linux, macOS)
- `gpu.lua` → choix du GPU WebGPU (NVIDIA > Discret > Intégré > fallback)
- `ui.lua` → police, taille, couleurs, opacité, padding
- `domains.lua` → définition des domaines SSH et WSL
- `launch.lua` → shell par défaut + menu de lancement
- `keys.lua` → raccourcis, qui charge le dossier `mappings/`

⚙️ **Astuce** : tu peux désactiver un module en commentant son `require(...)` dans `wezterm.lua`.


---

## 📂 mappings/README.md


# Dossier `mappings/`

Centralise les raccourcis clavier dans des tables Lua lisibles, séparées par thèmes.

- `default.lua` → raccourcis de base (split panes, tabs…)
- `navigation.lua` → navigation et redimensionnement des panes
- `editing.lua` → recherche, copy mode, gestion police
- `utils.lua` → convertit les tables en vrais `wezterm.action`

Le fichier `config/keys.lua` charge `mappings/utils.lua` pour construire `config.keys`.

⚙️ **Astuce** : ajoute tes propres fichiers (`foo.lua`) puis modifie `mappings/utils.lua` pour les inclure.


---

## 📂 events/README.md


# Dossier `events/`

Callbacks WezTerm branchés sur les hooks internes (`update-right-status`, `gui-startup`, …).

- `status.lua` → barre d’état personnalisée (hostname, date, OS)
- `backdrop.lua` → gestion des fonds d’écran (cycle, toggle)

Pour activer un event : appelle sa fonction `register(...)` depuis `wezterm.lua`, ex. :

```lua
require("events.status").register(config, wezterm, platform)
require("events.backdrop").register(config, wezterm, platform)
````

⚙️ **Astuce** : tu peux ajouter des events pour batterie, workspace, git branch…


---

## 📂 utils/README.md


# Dossier `utils/`

Bibliothèque maison pour simplifier la config.

- `init.lua` → point d’entrée (`require("utils")`)
- `tbl.lua` → helpers sur les tables (merge, clone, defaults, map, filter)
- `path.lua` → gestion chemins (expand_home, join, glob, exists)
- `log.lua` → couche de log (`info`, `warn`, `err`, `time`)
- `runtime.lua` → require sûr, once, try

Exemples :

```lua
local U = require("utils")

-- Fusion de tables
local conf = U.tbl.merge({a=1}, {b=2})

-- Log
U.log.info("Config chargée")

-- Expand path
local imgs = U.path.glob("~/.config/wezterm/backdrops/*.png")
````

---

## 📂 colors/README.md


# Dossier `colors/`

Schémas de couleurs personnalisés (Lua).

- Exemple : `mon-theme.lua`

Chaque fichier doit retourner une table conforme à `config.colors`.

Utilisation dans `config/ui.lua` :

```lua
config.colors = require("colors.mon-theme")
````

⚙️ **Astuce** : copie-colle des palettes existantes (ex. Catppuccin, Gruvbox) et adapte-les.

---

## 📂 backdrops/README.md

# Dossier `backdrops/`

Contient tes images d’arrière-plan.

Formats supportés : `.png`, `.jpg`, `.jpeg`, `.webp`.

Tu peux :
- Changer de fond → `LEADER + ]`
- Revenir au précédent → `LEADER + [`
- Activer/Désactiver → `LEADER + b`

⚙️ **Astuce** : place plusieurs images pour les faire défiler avec l’event `backdrop.lua`.
