# Roblox Cyber Hitman — V0+V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Pour Anton :** lis la section *"Comment lire ce plan"* en premier. Chaque tâche a un objectif, les fichiers concernés, les étapes exactes, et un critère "test ✅" pour valider.

**Goal:** Construire V0 (squelette Rojo + Studio + GitHub avec un perso qui spawne sur un sol gris) puis V1 (un quartier cyberpunk style Tokyo explorable, ambiance néon/pluie/synthwave).

**Architecture:** Workflow Rojo hybride — tout le code Lua vit dans `src/` synchronisé vers Studio via Rojo (port `localhost:34872`) ; tout le 3D (bâtiments, lights, particules, audio) est construit dans Studio et persisté dans `assets/places/main.rbxlx` (format XML, donc lisible par Git). TestEZ inclus dès V0 pour les modules Lua qui ont une vraie logique. Outils épinglés via Rokit (`rokit.toml`) pour reproductibilité.

**Tech Stack:** Roblox Studio · Luau · Rojo (sync fichiers ↔ Studio) · Rokit (versionning d'outils) · TestEZ (tests unitaires) · Selene (linter) · StyLua (formateur) · Git/GitHub via `gh`

---

## Comment lire ce plan

**Le rythme :**
- 1 tâche = 1 morceau cohérent (5 min à 60 min selon le type)
- 1 tâche = 1 commit en fin
- À la fin de V0 → tag `v0.0`. À la fin de V1 → tag `v1.0`. Toujours pouvoir revenir en arrière.

**Le format des étapes :**
- Étapes "code/terminal" → commande exacte à taper, sortie attendue
- Étapes "Studio" (visuelles) → instructions pas-à-pas (clics, valeurs à mettre)
- Critère **test ✅** → ce que tu dois voir/observer pour valider que l'étape marche

**TDD adapté à Roblox :**
- **Pour le code Lua avec logique** (pédestres, animations néon) → TDD propre : test d'abord (qui échoue), puis implé minimale qui passe.
- **Pour les visuels** (bâtiments, lights) → pas de TDD, mais critère d'acceptation explicite à chaque étape ("quand tu cliques Play, tu dois voir X, Y, Z"). C'est une adaptation honnête du principe — on ne peut pas écrire un test unitaire pour "le néon a la bonne couleur".
- **Pour le setup** (install d'outils, fichiers de config) → vérification via commande de status.

**Tu peux pauser n'importe quand.** Les commits fréquents te garantissent qu'aucun travail n'est perdu.

---

## File Structure

### Fichiers V0 (créés ou modifiés)

| Fichier | Rôle |
|---|---|
| `rokit.toml` | Pin des versions des outils Roblox (Rojo, Selene, StyLua) |
| `default.project.json` | Recette Rojo : décrit comment monter le `.rbxlx` à partir des fichiers |
| `.gitignore` | Ignore les fichiers temporaires Studio et Rokit |
| `README.md` | Description du projet, instructions de lancement |
| `src/server/init.server.lua` | Script principal serveur — print "V0 alive" en V0 |
| `src/client/init.client.lua` | Script principal client — vide en V0 |
| `src/shared/Constants.lua` | Constantes partagées (couleurs, distances, IDs assets) |
| `tests/SpecRunner.server.lua` | Lance TestEZ et imprime les résultats en console |
| `assets/places/main.rbxlx` | Le fichier de place Studio (versionné) |

### Fichiers V1 (créés en plus)

| Fichier | Rôle |
|---|---|
| `src/server/lighting/LightingConfig.lua` | Setup nuit cyberpunk + fog (couleurs, intensités) |
| `src/server/lighting/Weather.lua` | Pilote la pluie (on/off, intensité) |
| `src/server/visual/NeonAnimations.lua` | Logique animations néons (clignote, défile) |
| `src/server/visual/NeonAnimations.spec.lua` | Tests TestEZ pour NeonAnimations |
| `src/server/npc/Pedestrian.lua` | Comportement d'un seul piéton sur un trajet |
| `src/server/npc/Pedestrian.spec.lua` | Tests TestEZ pour Pedestrian |
| `src/server/npc/PedestrianSpawner.lua` | Spawn 3-5 piétons sur les paths définis |
| `src/shared/CityPaths.lua` | Données : trajets prédéfinis pour piétons |
| `src/shared/CityPaths.spec.lua` | Tests TestEZ pour CityPaths |
| `src/server/init.server.lua` | **Modifié** : appelle LightingConfig, Weather, PedestrianSpawner |

`assets/places/main.rbxlx` est massivement modifié en V1 (toute la ville).

---

# 🟦 V0 — Le squelette

**Objectif V0 :** un projet "bien plombé" — `rojo serve`, Studio, plugin connecté, perso qui spawne sur un sol gris, push sur GitHub. Aucun gameplay.

**Estimation :** 2–3 jours (~10–15h) pour un débutant.

---

### Task 1: Installer Rokit (gestionnaire d'outils)

**Files:**
- (aucun fichier modifié — install système)

**Pourquoi:** Rokit pin les versions de Rojo, Selene, StyLua. Pas de "ça marche chez moi mais pas chez toi" possible.

- [ ] **Step 1.1: Vérifier que Homebrew est là**

```bash
brew --version
```
Expected: une ligne "Homebrew X.Y.Z". Si erreur "command not found" → installer Homebrew d'abord (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`).

- [ ] **Step 1.2: Installer Rokit**

```bash
curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
```

- [ ] **Step 1.3: Recharger le shell pour que `rokit` soit dans le PATH**

```bash
source ~/.zshrc
```

- [ ] **Step 1.4: Vérifier l'installation**

```bash
rokit --version
```
Expected: "rokit 1.x.x" ou similaire.

**Test ✅:** `rokit --version` retourne un numéro de version sans erreur.

---

### Task 2: Initialiser Rokit dans le projet + installer Rojo, Selene, StyLua

**Files:**
- Create: `rokit.toml`

- [ ] **Step 2.1: Initialiser Rokit dans le repo**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
rokit init
```
Expected: création de `rokit.toml` (vide ou minimal).

- [ ] **Step 2.2: Ajouter Rojo**

```bash
rokit add rojo-rbx/rojo
```
Expected: ligne ajoutée à `rokit.toml`, binaire `rojo` installé localement au projet.

- [ ] **Step 2.3: Ajouter Selene (linter Lua)**

```bash
rokit add Kampfkarren/selene
```

- [ ] **Step 2.4: Ajouter StyLua (formateur Lua)**

```bash
rokit add JohnnyMorganz/StyLua
```

- [ ] **Step 2.5: Vérifier que les outils marchent**

```bash
rojo --version
selene --version
stylua --version
```
Expected: 3 lignes de versions, aucune erreur.

- [ ] **Step 2.6: Commit**

```bash
git add rokit.toml
git commit -m "chore: pin Rojo, Selene, StyLua via Rokit"
```

**Test ✅:** `cat rokit.toml` montre les 3 outils. Les 3 commandes répondent.

---

### Task 3: Créer la structure de dossiers + `default.project.json`

**Files:**
- Create: `src/server/`, `src/client/`, `src/shared/`, `tests/`, `assets/places/`
- Create: `default.project.json`

- [ ] **Step 3.1: Créer les dossiers**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
mkdir -p src/server src/client src/shared tests assets/places
```

- [ ] **Step 3.2: Créer le fichier `default.project.json`**

Contenu **exact** (copie-le tel quel) :

```json
{
  "name": "RobloxCyberHitman",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Source": {
        "$path": "src/server"
      },
      "Tests": {
        "$path": "tests"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Source": {
          "$path": "src/client"
        }
      }
    },
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/shared"
      }
    },
    "Workspace": {
      "$className": "Workspace",
      "$properties": {
        "Gravity": 196.2
      }
    }
  }
}
```

- [ ] **Step 3.3: Vérifier que Rojo accepte le projet**

```bash
rojo build default.project.json --output /tmp/test-build.rbxlx
```
Expected: "Built project to /tmp/test-build.rbxlx" sans erreur. Le fichier est créé. Si erreur de parsing JSON, relire la copie.

- [ ] **Step 3.4: Nettoyer le fichier de test**

```bash
rm /tmp/test-build.rbxlx
```

- [ ] **Step 3.5: Commit**

```bash
git add src/ tests/ assets/ default.project.json
git commit -m "chore: scaffold Rojo project structure"
```

**Test ✅:** `rojo build` réussit. `tree -L 3 src tests assets` montre les 5 dossiers vides.

---

### Task 4: Créer les scripts d'init serveur, client, et le module Constants

**Files:**
- Create: `src/server/init.server.lua`
- Create: `src/client/init.client.lua`
- Create: `src/shared/Constants.lua`

- [ ] **Step 4.1: Créer `src/shared/Constants.lua`**

```lua
--!strict
-- Constantes partagées server/client. Single source of truth.

local Constants = {}

Constants.Version = "0.0"
Constants.GameName = "Roblox Cyber Hitman"

return Constants
```

- [ ] **Step 4.2: Créer `src/server/init.server.lua`**

```lua
--!strict
-- Point d'entrée serveur. Tourne au lancement de la place.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))
```

- [ ] **Step 4.3: Créer `src/client/init.client.lua`**

```lua
--!strict
-- Point d'entrée client. Tourne sur la machine de chaque joueur au join.

print("[Client] connected")
```

- [ ] **Step 4.4: Vérifier que ça compile**

```bash
rojo build default.project.json --output /tmp/test-build.rbxlx
rm /tmp/test-build.rbxlx
```
Expected: build OK.

- [ ] **Step 4.5: Linter Selene**

```bash
selene src/
```
Expected: "Results: 0 errors, 0 warnings". Si warnings → corriger.

- [ ] **Step 4.6: Formater avec StyLua**

```bash
stylua src/
```

- [ ] **Step 4.7: Commit**

```bash
git add src/
git commit -m "feat(v0): add server/client/shared init scripts"
```

**Test ✅:** Les 3 fichiers `.lua` existent, le build Rojo passe, Selene est silencieux.

---

### Task 5: Installer TestEZ + créer le runner de tests

**Files:**
- Create: `tests/SpecRunner.server.lua`
- Modify: `default.project.json`

**Pourquoi maintenant:** on ne fait pas de tests en V0, mais on installe l'infra pour V1+. Coût : 10 minutes une seule fois.

- [ ] **Step 5.1: Ajouter TestEZ via Rokit (en tant que dépendance Roblox)**

TestEZ s'installe différemment de Rojo : c'est une lib Roblox, pas un binaire. On va utiliser **Wally** (gestionnaire de paquets pour Roblox).

```bash
rokit add UpliftGames/wally
wally --version
```

- [ ] **Step 5.2: Initialiser Wally**

```bash
wally init
```
Expected: création de `wally.toml`.

- [ ] **Step 5.3: Ajouter TestEZ comme dépendance**

Édite `wally.toml` pour ajouter sous `[dependencies]` :
```toml
TestEZ = "roblox/testez@0.4.1"
```

- [ ] **Step 5.4: Installer**

```bash
wally install
```
Expected: création de `Packages/`. Ajouter `Packages/_Index/**` au `.gitignore` plus tard, mais pour l'instant on track tout (Wally lock file + Packages).

- [ ] **Step 5.5: Modifier `default.project.json` pour exposer Packages**

Ajoute sous `ReplicatedStorage` (à côté de `Shared`) :
```json
"Packages": {
  "$path": "Packages"
}
```

- [ ] **Step 5.6: Créer le runner de tests `tests/SpecRunner.server.lua`**

```lua
--!strict
-- TestEZ runner. Lancé automatiquement quand on Play en Studio.
-- Cherche tous les fichiers *.spec.lua dans ServerScriptService.Source et les exécute.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

local function findSpecs(parent: Instance, found: { Instance })
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ModuleScript") and string.match(child.Name, "%.spec$") then
            table.insert(found, child)
        end
        findSpecs(child, found)
    end
end

local specs = {}
findSpecs(ServerScriptService.Source, specs)

if #specs == 0 then
    print("[SpecRunner] no .spec modules found, skipping")
else
    print(string.format("[SpecRunner] found %d spec modules", #specs))
    TestEZ.TestBootstrap:run(specs)
end
```

- [ ] **Step 5.7: Build vérification**

```bash
rojo build default.project.json --output /tmp/test-build.rbxlx
rm /tmp/test-build.rbxlx
```

- [ ] **Step 5.8: Commit**

```bash
git add wally.toml wally.lock Packages/ default.project.json tests/
git commit -m "chore: add Wally + TestEZ for unit testing"
```

**Test ✅:** `Packages/TestEZ` existe, `default.project.json` réfère `Packages`, build OK.

---

### Task 6: `.gitignore` + `README.md`

**Files:**
- Create: `.gitignore`
- Create: `README.md`

- [ ] **Step 6.1: Créer `.gitignore`**

```
# Rojo / build outputs
*.rbxl.lock
*.rbxlx.lock
build/

# OS
.DS_Store
Thumbs.db

# Editors
.vscode/settings.json
.idea/

# Rokit cache
.rokit-cache/
```

- [ ] **Step 6.2: Créer `README.md`**

```markdown
# Roblox Cyber Hitman

Jeu Roblox multijoueur (1–4 joueurs) dans un quartier cyberpunk style néo-Tokyo.
Un agent secret élimine un dictateur sur des missions briefées par Agent 47.

🚧 **Statut** : V0 (squelette). Voir `docs/superpowers/specs/` pour le design et `docs/superpowers/plans/` pour le plan d'implémentation.

## Setup

Prérequis : macOS, Roblox Studio installé, Homebrew.

```bash
# 1. Cloner le repo
git clone https://github.com/anton-analyze/roblox-cyber-hitman.git
cd roblox-cyber-hitman

# 2. Installer Rokit (si pas déjà fait)
curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
source ~/.zshrc

# 3. Installer les outils du projet
rokit install
wally install
```

## Lancer une session de dev

```bash
rojo serve
```

Puis dans Roblox Studio :
1. Ouvrir `assets/places/main.rbxlx`
2. Cliquer "Connect" dans le plugin Rojo (port 34872)
3. Cliquer Play

## Structure

```
src/server/   — code serveur (gameplay, missions, IA)
src/client/   — code client (UI, contrôles)
src/shared/   — code partagé serveur/client
tests/        — runner TestEZ + tests
assets/places/main.rbxlx   — fichier de place Studio (versionné en XML)
docs/         — design specs + plans d'implémentation
```
```

- [ ] **Step 6.3: Commit**

```bash
git add .gitignore README.md
git commit -m "docs: add README and .gitignore"
```

**Test ✅:** `cat README.md` montre le README, `.gitignore` est tracké.

---

### Task 7: Installer le plugin Rojo dans Roblox Studio

**Files:**
- (aucun — install Studio)

- [ ] **Step 7.1: Ouvrir Roblox Studio**

Lance Studio depuis Applications.

- [ ] **Step 7.2: Ouvrir le marketplace de plugins**

Dans Studio : onglet `View` → `Toolbox` → onglet `Marketplace` (en haut de la Toolbox) → catégorie `Plugins` → barre de recherche.

- [ ] **Step 7.3: Chercher et installer Rojo**

- Recherche : "Rojo"
- Identifier le plugin officiel par **rojo-rbx** (ou "Rojo Studio Plugin")
- Cliquer "Install" / "Get"

- [ ] **Step 7.4: Vérifier que le plugin apparaît**

Onglet `Plugins` (en haut de Studio) → tu dois voir un bouton "Rojo".

**Test ✅:** Le bouton "Rojo" apparaît dans l'onglet Plugins de Studio.

---

### Task 8: Créer la place Studio + premier sync Rojo

**Files:**
- Create (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 8.1: Démarrer Rojo en serveur**

Dans un terminal **séparé** (laisse-le tourner) :
```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
rojo serve
```
Expected: "Rojo server listening on port 34872".

- [ ] **Step 8.2: Dans Studio, créer une nouvelle place vide**

`File` → `New` → choisir le template **Baseplate** (le plus simple : sol + ciel par défaut).

- [ ] **Step 8.3: Sauvegarder la place dans le repo**

`File` → `Save As` → naviguer vers `~/Documents/Roblox/roblox-cyber-hitman/assets/places/` → nom : `main.rbxlx` → **format : "Roblox XML Place Files (*.rbxlx)"** (PAS le format binaire `.rbxl`).

⚠️ Critique : le format **XML** est mandatory pour que Git puisse track les changements. Si tu sauvegardes en `.rbxl` (binaire), Git ne sert à rien.

- [ ] **Step 8.4: Connecter le plugin Rojo**

Onglet Plugins → bouton Rojo → "Connect" (port 34872 par défaut).
Expected: la fenêtre Rojo affiche "Connected" + la liste des fichiers sync'és (Source, Tests, Shared, Packages).

- [ ] **Step 8.5: Vérifier que les scripts apparaissent**

Dans l'Explorer Studio :
- `ServerScriptService` → `Source` → tu vois `init` (= ton `init.server.lua`)
- `ReplicatedStorage` → `Shared` → `Constants`
- `ReplicatedStorage` → `Packages` → `TestEZ`
- `StarterPlayer` → `StarterPlayerScripts` → `Source` → `init`

**Test ✅:** Plugin Rojo affiche "Connected", scripts visibles dans l'Explorer Studio.

---

### Task 9: Build du sol gris + spawn point

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 9.1: Vérifier le baseplate par défaut**

Le template Baseplate a déjà un sol vert (`Workspace.Baseplate`).
Sélectionne-le dans l'Explorer.

- [ ] **Step 9.2: Configurer le sol**

Dans le panneau Properties :
- `Size` : `(200, 1, 200)` (200 studs × 1 stud d'épaisseur × 200 studs)
- `Color` : `(80, 80, 80)` (gris foncé)
- `Material` : `Concrete`
- `Anchored` : `true` (case cochée)

- [ ] **Step 9.3: Ajouter un SpawnLocation**

`Model` (dans le ribbon haut) → `Spawn` → ça insère un SpawnLocation à l'origine.
Dans Properties :
- `Position` : `(0, 5, 0)` (5 studs au-dessus du sol pour pas que le perso tombe à travers)
- `Anchored` : `true`

- [ ] **Step 9.4: Sauvegarder la place**

`File` → `Save` (Cmd+S).
Format : **doit rester `.rbxlx` XML** — Studio peut prompter, dis "Replace".

- [ ] **Step 9.5: Vérifier en jouant**

Clique le bouton **Play** (▶︎) dans le ribbon.
Expected:
- Ton avatar spawne sur le SpawnLocation, sur le sol gris
- Tu peux te déplacer (WASD) et jumper (Space)
- En console (`View` → `Output`) tu dois voir : `[Roblox Cyber Hitman] V0.0 alive` et `[Client] connected`

⚠️ Si tu ne vois pas les messages, tu n'es probablement pas connecté à Rojo. Refais Step 8.4.

- [ ] **Step 9.6: Stopper le play**

Bouton **Stop** (⏹).

- [ ] **Step 9.7: Re-sauver la place**

Cmd+S (Studio peut avoir modifié des trucs au play, on resauve l'état propre).

**Test ✅:** Tu joues, ton perso spawne sur sol gris, console affiche "V0.0 alive". Tu rentres au menu propre.

---

### Task 10: Premier commit du fichier de place

**Files:**
- Track: `assets/places/main.rbxlx`

- [ ] **Step 10.1: Vérifier l'état Git**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
git status
```
Expected: `assets/places/main.rbxlx` apparaît en "untracked".

- [ ] **Step 10.2: Vérifier que c'est bien du XML lisible**

```bash
file assets/places/main.rbxlx
head -3 assets/places/main.rbxlx
```
Expected: "XML 1.0 document" + une balise `<roblox version=...>`. Si c'est binaire → tu as sauvegardé en `.rbxl` → refais Step 8.3.

- [ ] **Step 10.3: Commit**

```bash
git add assets/places/main.rbxlx
git commit -m "feat(v0): add baseplate with spawn location"
```

**Test ✅:** `git log --oneline` montre le commit. Le fichier est ~1 KB en XML.

---

### Task 11: Test de sync bout-en-bout (modifier code → voir l'effet en Studio)

**Files:**
- Modify: `src/server/init.server.lua`

- [ ] **Step 11.1: Modifier le print serveur**

Édite `src/server/init.server.lua` pour ajouter une seconde ligne :

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))
print("[Server] sync test ok")
```

- [ ] **Step 11.2: Sauvegarder le fichier**

Cmd+S dans VS Code.

- [ ] **Step 11.3: Vérifier la sync immédiate**

Dans Studio (Rojo connecté), clique Play. En console tu dois voir les **deux** messages :
```
[Roblox Cyber Hitman] V0.0 alive
[Server] sync test ok
```

Si tu ne vois que le premier → la sync ne marche pas, redémarre `rojo serve`.

- [ ] **Step 11.4: Stop, retirer la ligne de test**

Stop. Retire la ligne `print("[Server] sync test ok")` (revert manuel).

- [ ] **Step 11.5: Vérifier que le print disparaît**

Re-Play. Tu ne dois plus voir que la ligne d'origine.

- [ ] **Step 11.6: Commit (rien à committer puisque code revenu à l'état précédent)**

```bash
git status
```
Expected: "nothing to commit, working tree clean".

**Test ✅:** Sync bidirectionnelle fonctionnelle (ajouter/enlever une ligne se voit immédiatement en Studio).

---

### Task 12: Créer le repo GitHub et push

**Files:**
- Remote: `github.com/anton-analyze/roblox-cyber-hitman`

- [ ] **Step 12.1: Décider public ou privé**

Public (recommandé) → tout le monde peut voir ton travail, c'est une chouette vitrine.
Privé → seulement toi.

Anton choisit. Pour la suite je suppose public.

- [ ] **Step 12.2: Créer le repo via gh**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
gh repo create roblox-cyber-hitman \
  --public \
  --source=. \
  --remote=origin \
  --description "Multiplayer cyberpunk hitman game built in Roblox" \
  --push
```

(Si privé : remplace `--public` par `--private`.)

Expected: création du repo + push de tous les commits + setup du remote `origin`.

- [ ] **Step 12.3: Vérifier sur GitHub**

```bash
gh repo view --web
```
Expected: ton navigateur ouvre `https://github.com/anton-analyze/roblox-cyber-hitman` et tu vois tes fichiers.

- [ ] **Step 12.4: Vérifier le tracking de la branche**

```bash
git branch -vv
```
Expected: la branche `main` track `origin/main`.

**Test ✅:** Repo visible sur github.com, tous les commits sont là, README s'affiche.

---

### Task 13: Tag v0.0

**Files:**
- (aucun — tag git)

- [ ] **Step 13.1: Créer le tag annoté**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
git tag -a v0.0 -m "V0 — skeleton complete: Rojo + Studio + GitHub working, baseplate with spawn"
```

- [ ] **Step 13.2: Push le tag**

```bash
git push origin v0.0
```

- [ ] **Step 13.3: Vérifier sur GitHub**

```bash
gh release list
```
Expected: pas encore de release, mais le tag `v0.0` est visible. Tu peux optionnellement créer une release :
```bash
gh release create v0.0 --title "V0 — Skeleton" --notes "Foundation: Rojo + GitHub + Roblox Studio sync working. Baseplate with spawn point."
```

**Test ✅:** `git tag` liste `v0.0`. Sur GitHub, l'onglet Releases (ou Tags) montre v0.0.

---

### Task 14: V0 verification — cold restart test

**Files:**
- (aucun — test rituel)

**Pourquoi:** prouver que V0 marche **sans état caché en mémoire**. C'est le critère "V0 réussie" du spec.

- [ ] **Step 14.1: Tout fermer**

- Quitte Roblox Studio (Cmd+Q)
- Stop `rojo serve` dans le terminal (Ctrl+C)
- Redémarre ton ordi (optionnel mais recommandé)

- [ ] **Step 14.2: Relancer la séquence depuis zéro**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
rojo serve
```

- [ ] **Step 14.3: Ouvrir Studio + place + Connect**

- Lance Studio
- `File` → `Open` → naviguer vers `assets/places/main.rbxlx`
- Plugin Rojo → Connect

- [ ] **Step 14.4: Play**

Bouton Play. Vérifie :
- Perso spawne sur le sol gris ✓
- Console affiche `[Roblox Cyber Hitman] V0.0 alive` ✓
- Tu peux te déplacer ✓

- [ ] **Step 14.5: Stop**

Stop.

🎉 **V0 OFFICIELLEMENT TERMINÉE.** Pause justifiée. Repo GitHub vivant, foundation propre.

**Test ✅:** Cold restart → tout marche → V0 ✅.

---

# 🟪 V1 — La ville cyberpunk

**Objectif V1 :** un quartier qui donne envie d'être exploré, ambiance synthwave/néon/pluie. Pas de gameplay encore.

**Estimation :** ~2 semaines (~30–40h) en sprint motivé.

**Avant de commencer V1 :** Anton, tu peux décider de **chercher 1–2 références visuelles** sur Pinterest / YouTube ("Neon Tokyo Roblox", "cyberpunk street build Roblox") pendant 15-20 min pour avoir des idées de proportions/couleurs. Pas obligatoire mais ça aide.

---

### Task 15: Setup lighting nuit cyberpunk + fog

**Files:**
- Create: `src/server/lighting/LightingConfig.lua`
- Modify: `src/server/init.server.lua`

- [ ] **Step 15.1: Créer `src/server/lighting/LightingConfig.lua`**

```lua
--!strict
-- Configure le service Lighting pour ambiance nuit cyberpunk.
-- Appelé une fois au démarrage de la place, côté serveur.

local Lighting = game:GetService("Lighting")

local LightingConfig = {}

function LightingConfig.apply()
    -- Couleur globale
    Lighting.Ambient = Color3.fromRGB(20, 20, 35)
    Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 30)
    Lighting.Brightness = 0.3
    Lighting.ClockTime = 0  -- minuit

    -- Soleil/lune : faible
    Lighting.GeographicLatitude = 35  -- Tokyo
    Lighting.ExposureCompensation = 0

    -- Fog cyberpunk
    Lighting.FogColor = Color3.fromRGB(40, 20, 60)  -- violet sombre
    Lighting.FogStart = 50
    Lighting.FogEnd = 300

    -- Atmosphere effect (si pas déjà là)
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.4
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(60, 40, 80)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0
    atmosphere.Haze = 1.5
end

return LightingConfig
```

- [ ] **Step 15.2: Modifier `src/server/init.server.lua` pour appeler LightingConfig**

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local LightingConfig = require(ServerScriptService.Source.lighting.LightingConfig)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))

LightingConfig.apply()
print("[Lighting] applied cyberpunk night preset")
```

- [ ] **Step 15.3: Mettre à jour `src/shared/Constants.lua`**

```lua
--!strict
local Constants = {}

Constants.Version = "1.0-dev"
Constants.GameName = "Roblox Cyber Hitman"

return Constants
```

- [ ] **Step 15.4: Build + lint**

```bash
rojo build default.project.json --output /tmp/test-build.rbxlx
selene src/
stylua src/
rm /tmp/test-build.rbxlx
```

- [ ] **Step 15.5: Tester en Studio**

`rojo serve` actif, Play.
Expected:
- Tout est sombre, ambiance nuit
- Brouillard violet visible au loin
- Console : `[Lighting] applied cyberpunk night preset`

- [ ] **Step 15.6: Commit**

```bash
git add src/
git commit -m "feat(v1): cyberpunk night lighting preset"
```

**Test ✅:** Le sol gris est éclairé en nuit avec fog violet. Console confirme l'application.

---

### Task 16: Build de la rue principale + ruelle (route, trottoirs, passages piéton)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

⚠️ Étape "build visuel". Pas de TDD. Critère = visuel + dimensions.

- [ ] **Step 16.1: Préparer le sol**

Dans Studio :
- Sélectionne le `Baseplate`, clique-droit → `Group` → renomme le groupe "Terrain" (Model)
- Met le `Baseplate` à `Color (40, 40, 40)` et `Material Concrete` (sol urbain)
- Garde sa Size `(200, 1, 200)`

- [ ] **Step 16.2: Construire la rue principale**

Insère un **Part** : `Model` → `Part`. Configure :
- Name: `MainStreet`
- Size: `(20, 0.2, 100)` (20 studs de large, 100 de long)
- Position: `(0, 1.1, 0)` (juste au-dessus du Baseplate)
- Color: `(15, 15, 15)` (asphalte sombre)
- Material: `Asphalt`
- Anchored: `true`
- Parent: dans `Workspace` → crée un Model nommé `City`, parent dedans.

- [ ] **Step 16.3: Construire la ruelle perpendiculaire**

Part :
- Name: `SideAlley`
- Size: `(8, 0.2, 40)` (plus étroite)
- Rotation: `(0, 90, 0)` (perpendiculaire — utilise `CFrame.Angles` ou la rotation manuelle)
- Position: `(0, 1.1, 30)` (à 30 studs sur la rue principale)
- Color, Material, Anchored : pareil que MainStreet
- Parent: `Workspace.City`

- [ ] **Step 16.4: Construire les trottoirs**

Pour chaque côté de la rue principale (gauche/droit), un Part :
- Name: `Sidewalk_Main_Left` / `Sidewalk_Main_Right`
- Size: `(4, 0.5, 100)`
- Position: `(-12, 1.25, 0)` (gauche), `(12, 1.25, 0)` (droite)
- Color: `(70, 70, 75)`
- Material: `Concrete`
- Anchored: `true`
- Parent: `Workspace.City`

Pareil pour la ruelle (mais Size `(2, 0.5, 40)`, et adapter positions).

- [ ] **Step 16.5: Construire 2 passages piétons**

Méthode rapide : un Part fin par bande blanche.
- Pour chaque passage : 6 bandes de Size `(20, 0.05, 1)`, Color `(240, 240, 240)`, espacées de 1 stud
- Positions : 1 passage à `Z = -30`, l'autre à `Z = +30` sur la rue principale
- Group dans un Model "Crosswalk_North" et "Crosswalk_South"
- Anchored: `true`
- Parent: `Workspace.City`

- [ ] **Step 16.6: Sauvegarder + Play**

Cmd+S. Play.
Expected: tu vois la rue grise sombre en croix, les trottoirs surélevés, les bandes blanches des passages piétons. Tu peux marcher dessus.

- [ ] **Step 16.7: Commit**

```bash
git add assets/places/main.rbxlx
git commit -m "feat(v1): basic street, alley, sidewalks, crosswalks"
```

**Test ✅:** Vue de dessus = une croix asphalte avec trottoirs gris.

---

### Task 17: Build de la tour corporate #1

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 17.1: Créer le model `CorpTower_A`**

Dans Studio : `Workspace.City` → clic-droit → `Insert Object` → `Model` → nom `CorpTower_A`.

- [ ] **Step 17.2: Construire le corps de la tour**

Part dans le model :
- Name: `Body`
- Size: `(20, 80, 20)` (20×80×20 studs — tour de 8-10 étages)
- Position: `(-22, 41, -30)` (juste à gauche de la rue principale, vers le sud)
- Color: `(20, 25, 35)` (bleu très sombre)
- Material: `Glass` ou `Metal`
- Reflectance: `0.4`
- Anchored: `true`

- [ ] **Step 17.3: Ajouter les "étages" (lignes de séparation)**

Pour donner l'illusion d'étages :
- 9 Parts horizontaux `(20.2, 0.3, 20.2)`, color `(50, 60, 80)`, material `Metal`
- Positions Y régulièrement espacées sur les 80 studs (de Y=8 à Y=80, step 8)
- Toutes parent du model `CorpTower_A`

Astuce : duplique le premier (`Cmd+D`) et ajuste Position Y.

- [ ] **Step 17.4: Ajouter une lumière au sommet**

PointLight :
- `Workspace.City.CorpTower_A` → Insert → `PointLight`
- Color: `(255, 50, 200)` (magenta)
- Brightness: `2`
- Range: `40`
- Position: au sommet (Y=82)

⚠️ Compte les PointLights — max 20 sur tout le projet.

- [ ] **Step 17.5: Save + Play**

Tu dois voir une tour sombre vitrée avec lignes d'étages et un halo magenta en haut.

- [ ] **Step 17.6: Commit**

```bash
git add assets/places/main.rbxlx
git commit -m "feat(v1): corp tower A south of main street"
```

**Test ✅:** Une tour sombre vitrée visible avec halo magenta sommital.

---

### Task 18: Build de la tour corporate #2

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 18.1: Dupliquer CorpTower_A**

Dans l'Explorer, sélectionne `CorpTower_A` → Cmd+D → renomme `CorpTower_B`.

- [ ] **Step 18.2: Repositionner**

- Sélectionne tous les Parts du model `CorpTower_B`, déplace en bloc :
  - Position X : `+22` (de l'autre côté de la rue)
  - Position Z : `+30` (dans l'autre direction)
- Modifie la hauteur : `Size.Y = 100` sur le `Body` (10-12 étages, plus haut que A pour varier)
- Change la couleur du PointLight : `(50, 200, 255)` (cyan, contraste avec A)

- [ ] **Step 18.3: Ajouter 8-10 nouveaux étages pour matcher la nouvelle hauteur**

(Recopier la même technique qu'en 17.3 pour les nouveaux étages haut.)

- [ ] **Step 18.4: Save + Play**

Tu dois voir 2 tours différentes, l'une magenta (sud), l'autre cyan plus haute (nord).

- [ ] **Step 18.5: Commit**

```bash
git add assets/places/main.rbxlx
git commit -m "feat(v1): corp tower B north, taller, cyan top light"
```

**Test ✅:** 2 tours visibles, couleurs et hauteurs distinctes.

---

### Task 19: Build commerce — ramen shop (rez-de-chaussée style izakaya)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 19.1: Créer le model `Shop_Ramen`**

Dans `Workspace.City`.

- [ ] **Step 19.2: Construire le bâtiment**

Part `Body`:
- Size: `(15, 6, 12)` (petit bâtiment 1 étage)
- Position: `(-22, 4, 0)` (côté gauche, milieu de la rue)
- Color: `(30, 20, 20)` (rouge sombre)
- Material: `Brick`
- Anchored

- [ ] **Step 19.3: Façade — devanture vitrée**

Part `Window`:
- Size: `(12, 4, 0.5)`
- Position: `(-15.5, 4, 0)` (face à la rue)
- Color: `(60, 80, 100)`
- Material: `Glass`
- Transparency: `0.3`
- Anchored

- [ ] **Step 19.4: Enseigne (sera animée plus tard)**

Part `Sign`:
- Size: `(8, 1.5, 0.3)`
- Position: `(-15.5, 8, 0)` (au-dessus de la fenêtre)
- Color: `(255, 50, 50)` (rouge néon)
- Material: `Neon`
- Anchored
- Ajouter un **SurfaceGui** sur la face devant (`Face: Front`), avec un TextLabel : "ラーメン" (ramen en japonais), font `SourceSansBold`, taille 60, couleur blanc.

- [ ] **Step 19.5: PointLight devant l'enseigne**

PointLight enfant du `Sign` :
- Color `(255, 50, 50)`
- Brightness `1.5`
- Range `15`

- [ ] **Step 19.6: Save + Play + Commit**

```bash
git add assets/places/main.rbxlx
git commit -m "feat(v1): ramen shop with neon sign"
```

**Test ✅:** Petit shop rouge sombre avec enseigne néon "ラーメン" qui éclaire la rue.

---

### Task 20: Build commerce — bar cyberpunk

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 20.1: Dupliquer Shop_Ramen → Shop_Bar**

Cmd+D, renommer.

- [ ] **Step 20.2: Repositionner**

- Position du `Body` : `(22, 4, 15)` (côté droit, plus au nord)
- Color body : `(15, 15, 25)` (bleu très sombre)
- Window : repositionner face à la rue principale
- Sign : texte "BAR // 0XR1ON", color `(50, 200, 255)` (cyan)
- PointLight cyan, range 18

- [ ] **Step 20.3: Save + Commit**

```bash
git commit -am "feat(v1): cyberpunk bar with cyan neon"
```

**Test ✅:** Un deuxième commerce visible, ambiance cyan.

---

### Task 21: Build commerce — boutique tech

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 21.1: Dupliquer Shop_Bar → Shop_Tech**

- [ ] **Step 21.2: Repositionner et restyler**

- Position Body : `(-22, 4, 30)` (gauche, après ruelle)
- Color Body : `(20, 30, 25)` (vert sombre)
- Sign : "CHIPSET // 互換" couleur `(150, 255, 100)` (vert néon)
- PointLight vert, range 15

- [ ] **Step 21.3: Save + Commit**

```bash
git commit -am "feat(v1): tech shop with green neon"
```

**Test ✅:** 3 commerces alignés, 3 couleurs néon différentes (rouge / cyan / vert).

---

### Task 22: Build de l'immeuble d'habitation #1

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 22.1: Créer le model `Apartment_A`**

- [ ] **Step 22.2: Body**

- Size: `(18, 50, 14)` (5-6 étages)
- Position: `(22, 26, -25)` (côté droit, au sud des shops)
- Color: `(40, 35, 30)` (beige sombre, contraste avec corpos)
- Material: `Brick`
- Anchored

- [ ] **Step 22.3: Ajouter ~20 fenêtres aléatoires**

Méthode rapide :
- Insère un Part `Window_proto` : Size `(2, 1.5, 0.2)`, Material `Neon`, Color au choix entre `(255, 220, 100)` (jaune chaud), `(60, 60, 60)` (éteint), `(255, 100, 200)` (rose)
- Place-le sur la façade devant, à hauteur Y=4
- Duplique-le ~20 fois et place les copies à différentes positions (X varié sur la façade, Y varié sur les étages, certaines éteintes)

⚠️ Pas de PointLight par fenêtre (limite de 20). Les fenêtres `Neon` brillent toutes seules sans light.

- [ ] **Step 22.4: Balcons (optionnel, 2-3)**

Parts `(3, 0.3, 1.5)`, color `(50, 50, 50)`, material `Metal`, à mi-hauteur.

- [ ] **Step 22.5: Save + Commit**

```bash
git commit -am "feat(v1): apartment building A with random lit windows"
```

**Test ✅:** Immeuble d'habitation visible avec fenêtres allumées/éteintes en pattern aléatoire.

---

### Task 23: Build de l'immeuble d'habitation #2

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 23.1: Dupliquer Apartment_A → Apartment_B**

- [ ] **Step 23.2: Repositionner et restyler**

- Position Body : `(-22, 24, 30)` (gauche après ruelle)
- Size Body : `(16, 48, 14)` (légèrement plus petit)
- Material : changer en `Concrete`
- Couleur fenêtres : varier (plus de cyan/violet)

- [ ] **Step 23.3: Save + Commit**

```bash
git commit -am "feat(v1): apartment building B with violet/cyan windows"
```

**Test ✅:** Deuxième immeuble distinct.

---

### Task 24: Build du bâtiment avec **toit accessible** (futur sniper spot V5)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 24.1: Créer le model `Rooftop_Building`**

- [ ] **Step 24.2: Body**

- Size: `(14, 30, 18)` (pas trop haut pour qu'on puisse y accéder)
- Position: `(0, 16, 50)` (au bout de la rue principale, axe central)
- Color: `(45, 40, 50)`
- Material: `Concrete`

- [ ] **Step 24.3: Toit (Part séparé pour pouvoir s'y poser)**

Part `Roof`:
- Size: `(14, 0.5, 18)`
- Position: `(0, 30.25, 50)` (juste au-dessus du body)
- Color: `(60, 60, 65)`
- Anchored
- **CanCollide: true** (pour qu'on puisse marcher dessus en V5)

- [ ] **Step 24.4: Échelle ou escalier extérieur (pour qu'on puisse y monter)**

Méthode simple : une série de Parts en escalier sur le côté du bâtiment.
- 12 marches de Size `(2, 0.5, 1.5)`, color `(50, 50, 55)`, espacées en Y de 2.5 et en Z de 1.5
- Position de départ : `(8, 1, 50)` (côté est du bâtiment)

⚠️ Vérifie que tu peux **vraiment monter** au play (test grimper).

- [ ] **Step 24.5: Antenne / structure rooftop (déco)**

3-4 Parts cylindriques fins sur le toit (size `(0.5, 5, 0.5)`, color noir, material Metal).

- [ ] **Step 24.6: Save + Play (test grimper)**

Au play, monte les escaliers, marche sur le toit. Si tu tombes à travers, vérifie `CanCollide` sur `Roof` et les marches.

- [ ] **Step 24.7: Commit**

```bash
git commit -am "feat(v1): rooftop-accessible building (sniper spot for V5)"
```

**Test ✅:** Tu peux monter au toit en grimpant les escaliers. Test "wow" en avance pour le futur sniper.

---

### Task 25: Ajouter 4-6 voitures statiques

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 25.1: Créer un model `Car_proto`**

Construction simple en Parts :
- Body : `(4, 1, 8)`, color au choix, material `SmoothPlastic`
- Toit : `(3.5, 1, 4)`, color même, position au-dessus arrière du body
- 4 roues (cylindres) `(1, 1, 1)` rotation 90°, color `(20, 20, 20)`, material `Plastic`
- 2 phares (Parts neon `(0.5, 0.4, 0.2)`, color `(255, 255, 200)`)

Group le tout en `Car_proto` puis duplique 5 fois.

- [ ] **Step 25.2: Disperser les voitures**

Place 5 voitures à différentes positions le long de la rue principale et dans la ruelle :
- 2 garées sur le côté gauche
- 2 garées sur le côté droit
- 1 dans la ruelle
- Couleurs variées : noir, gris, rouge sombre, bleu nuit
- Toutes Anchored

- [ ] **Step 25.3: Save + Commit**

```bash
git commit -am "feat(v1): static parked cars on street"
```

**Test ✅:** La rue ne se sent plus vide. 5-6 voitures réparties.

---

### Task 26: Ajouter 10 enseignes néon statiques (premier batch)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

⚠️ Étape créative — Anton, lâche-toi sur les textes et couleurs. Mix japonais (kana/kanji) et anglais "tech".

- [ ] **Step 26.1: Pour chaque enseigne, le pattern est :**

1. Part `Sign_<NameXX>` :
   - Size variable (3 à 12 studs de large, 1 à 3 de haut, 0.3 d'épais)
   - Material `Neon`
   - Color vif (rose, cyan, vert, jaune, violet)
   - Position attachée à un mur de bâtiment
2. SurfaceGui dessus avec TextLabel pour le texte (font `SourceSansBold`).

- [ ] **Step 26.2: Idées de textes (libre)**

`サイバー` / `2 0 7 7` / `OPEN` / `Yakuza Express` / `BIO-CHIP` / `寿司` / `NEURAL.BAR` / `深夜カフェ` / `データ` / `XR-Cybernetics`

- [ ] **Step 26.3: Place ~10 enseignes sur les façades** (corpos, immeubles, shops)

Varie les hauteurs (rez-de-chaussée et plus haut sur les tours).

- [ ] **Step 26.4: Save + Commit**

```bash
git commit -am "feat(v1): batch 1 of static neon signs (10)"
```

**Test ✅:** En jouant, la ville respire le néon — tu peux compter au moins 10 enseignes lumineuses.

---

### Task 27: Ajouter 5-10 enseignes néon de plus (deuxième batch)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 27.1: Même pattern que Task 26**

Cette fois, vise les zones encore vides (haut des tours, ruelle, façades arrière).

- [ ] **Step 27.2: Save + Commit**

```bash
git commit -am "feat(v1): batch 2 of static neon signs"
```

**Test ✅:** Total ~15-20 enseignes statiques. La ruelle commence à avoir du caractère.

---

### Task 28: Système d'animations pour 3-4 enseignes (clignote, défile)

**Files:**
- Create: `src/server/visual/NeonAnimations.lua`
- Create: `src/server/visual/NeonAnimations.spec.lua`
- Modify: `src/server/init.server.lua`
- Modify (via Studio): tagger 3-4 enseignes

**TDD honnête possible ici** — la logique d'animation est testable.

- [ ] **Step 28.1: Écrire le test qui échoue**

Crée `src/server/visual/NeonAnimations.spec.lua` :

```lua
--!strict
return function()
    local NeonAnimations = require(script.Parent.NeonAnimations)

    describe("NeonAnimations.computeBlinkAlpha", function()
        it("returns 1 at t=0 with blinkPeriod=2", function()
            local alpha = NeonAnimations.computeBlinkAlpha(0, 2)
            expect(alpha).to.equal(1)
        end)

        it("returns 0 at t=1 with blinkPeriod=2", function()
            local alpha = NeonAnimations.computeBlinkAlpha(1, 2)
            expect(alpha).to.equal(0)
        end)

        it("returns 1 at t=2 with blinkPeriod=2 (loops)", function()
            local alpha = NeonAnimations.computeBlinkAlpha(2, 2)
            expect(alpha).to.equal(1)
        end)
    end)

    describe("NeonAnimations.computeMarqueeOffset", function()
        it("returns 0 at t=0", function()
            expect(NeonAnimations.computeMarqueeOffset(0, 10)).to.equal(0)
        end)

        it("returns 5 at t=0.5 with speed=10", function()
            expect(NeonAnimations.computeMarqueeOffset(0.5, 10)).to.equal(5)
        end)
    end)
end
```

- [ ] **Step 28.2: Lancer les tests — ils doivent échouer**

Dans Studio (Rojo connecté), Play. Console doit afficher l'erreur "NeonAnimations module not found" ou similaire.

- [ ] **Step 28.3: Implémentation minimale**

`src/server/visual/NeonAnimations.lua` :

```lua
--!strict
-- Animations pour enseignes néon : clignote, défile.
-- Pure functions testables + fonction d'application Studio-aware.

local NeonAnimations = {}

-- Retourne 1 (allumé) ou 0 (éteint) selon le temps t et la période blinkPeriod (en secondes).
-- Half-cycle: ON pendant période/2, OFF pendant période/2.
function NeonAnimations.computeBlinkAlpha(t: number, blinkPeriod: number): number
    local phase = t % blinkPeriod
    if phase < blinkPeriod / 2 then
        return 1
    else
        return 0
    end
end

-- Retourne l'offset de défilement (en studs) selon temps et vitesse (studs/sec).
function NeonAnimations.computeMarqueeOffset(t: number, speed: number): number
    return t * speed
end

-- Application en jeu : pour chaque Part avec attribut "NeonAnimType",
-- modifier sa Transparency (blink) ou la position de son TextLabel (marquee).
function NeonAnimations.startLoop(): ()
    local CollectionService = game:GetService("CollectionService")
    local RunService = game:GetService("RunService")

    RunService.Heartbeat:Connect(function()
        local t = tick()
        for _, part in ipairs(CollectionService:GetTagged("NeonBlink")) do
            local period = part:GetAttribute("BlinkPeriod") or 1
            local alpha = NeonAnimations.computeBlinkAlpha(t, period)
            part.Transparency = 1 - alpha
        end
        for _, part in ipairs(CollectionService:GetTagged("NeonMarquee")) do
            local speed = part:GetAttribute("MarqueeSpeed") or 5
            local gui = part:FindFirstChildOfClass("SurfaceGui")
            local label = gui and gui:FindFirstChildOfClass("TextLabel")
            if label then
                label.Position = UDim2.new(1, -math.floor(NeonAnimations.computeMarqueeOffset(t, speed) * 10) % 200, 0, 0)
            end
        end
    end)
end

return NeonAnimations
```

- [ ] **Step 28.4: Lancer les tests — ils doivent passer**

Studio Play. Console doit afficher "TestEZ: 5 passed".

- [ ] **Step 28.5: Modifier `src/server/init.server.lua` pour démarrer la loop**

Ajouter :
```lua
local NeonAnimations = require(ServerScriptService.Source.visual.NeonAnimations)
NeonAnimations.startLoop()
print("[NeonAnimations] loop started")
```

- [ ] **Step 28.6: Tagger des enseignes existantes dans Studio**

Sélectionne 2 enseignes existantes :
- Avec le **Tag Editor** (View → Tag Editor) ou via console : `CollectionService:AddTag(part, "NeonBlink")`
- Mettre attribut `BlinkPeriod` = `0.8` (sec)

Sélectionne 1-2 autres :
- Tag `NeonMarquee`, attribut `MarqueeSpeed` = `8`

- [ ] **Step 28.7: Save + Play**

Tu dois voir au moins 2 enseignes clignoter et 1-2 avec texte qui défile.

- [ ] **Step 28.8: Commit**

```bash
git add src/ assets/places/main.rbxlx
git commit -m "feat(v1): neon animation system (blink + marquee), 3-4 signs animated"
```

**Test ✅:** Tests TestEZ passent (5/5). En jeu, enseignes clignotantes et défilantes visibles.

---

### Task 29: Effet de pluie (particules)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 29.1: Créer la zone de pluie**

Insère un Part `RainEmitter` :
- Size: `(200, 0.1, 200)` (couvre toute la map)
- Position: `(0, 80, 0)` (au-dessus de tout)
- Transparency: `1` (invisible)
- CanCollide: `false`
- Anchored: `true`
- Parent: Workspace (pas dans City)

- [ ] **Step 29.2: Ajouter ParticleEmitter enfant**

Insère un `ParticleEmitter` dans `RainEmitter`. Properties :
- Texture: `rbxasset://textures/particles/sparkles_main.dds` (placeholder, on peut changer pour une vraie texture de goutte d'eau plus tard ; ou chercher "rain drop" dans la Toolbox)
- Color: `Color3.new(0.7, 0.8, 0.9)` (bleu pâle)
- LightEmission: `0.3`
- Size: `NumberSequence` `0.1` constant
- Lifetime: `1.5`
- Rate: `200`
- Speed: `(50, 50)`
- VelocityInheritance: `0`
- VelocitySpread: `0` (tombe droit)
- Acceleration: `(0, -50, 0)` (gravité)
- ZOffset: `0`

⚠️ Si performance laggy → réduire Rate à 100 ou 80.

- [ ] **Step 29.3: Save + Play**

Tu dois voir une pluie continue. Si trop dense, baisse Rate.

- [ ] **Step 29.4: Commit**

```bash
git commit -am "feat(v1): rain particle effect covering map"
```

**Test ✅:** Il pleut visiblement sur toute la ville.

---

### Task 30: Skybox + Mont Fuji holographique

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 30.1: Skybox de nuit**

Dans `Lighting` → Insert → `Sky`. Properties :
- Garde les SkyboxIDs par défaut (un peu sombres ça marche), OU :
- Cherche dans la Toolbox "night sky cyberpunk" et essaye 1-2 skyboxes free-to-use.

Si tu veux un setup minimal sans Toolbox : laisse les SkyboxIds vides (Studio met du sombre par défaut), Sky.SunAngularSize = 0, Sky.MoonAngularSize = 0.

- [ ] **Step 30.2: Mont Fuji holographique au loin**

Méthode "stylisée" :
- Insère un grand Part `MtFujiHologram` :
  - Size: `(200, 100, 5)` (200 large, 100 haut, ultra-fin)
  - Position: `(0, 60, -300)` (loin au sud, haut)
  - Shape: garde Block
  - Transparency: `0.85`
  - Material: `Neon`
  - Color: `(150, 100, 255)` (violet)
  - Anchored: `true`
  - CanCollide: `false`
- Sur sa face avant (Front), pose un SurfaceGui + ImageLabel
- Image : trouve un PNG simple silhouette du Mont Fuji (transparent), upload via Studio Asset Manager → reçois un assetId → mets-le dans ImageLabel.Image

⚠️ Alternative simple si l'image te galère : utilise juste un triangle stylisé (3 Wedges juxtaposés) en violet semi-transparent. L'idée holographique est l'effet visuel, pas le réalisme.

- [ ] **Step 30.3: Save + Play**

Regarde au sud-est : tu dois voir une silhouette violette transparente d'un mont. Si invisible → check transparency / position.

- [ ] **Step 30.4: Commit**

```bash
git commit -am "feat(v1): night skybox + Mt Fuji holographic backdrop"
```

**Test ✅:** Le Mont Fuji holographique est visible au loin et donne une touche Tokyo identifiable.

---

### Task 31: Audio — bruit ambient ville (TOS-safe)

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

⚠️ **Contrainte légale Roblox** : tu ne peux pas utiliser n'importe quel audio. Sources autorisées :
1. Audio uploadé par toi-même (Roblox vérifie automatiquement)
2. Roblox Audio Library officielle (filtrer "Free to use")
3. Musiques licenciées explicitement pour Roblox sur le devforum

- [ ] **Step 31.1: Trouver un asset "city ambience" gratuit**

Dans Studio → Toolbox → Audio (au lieu de Models) → recherche "city ambience" / "urban hum" → filtre **par "Free Audio"** uniquement (Roblox a un filtre depuis 2025) → écoute 2-3 → choisis-en un (≥ 30 secondes idéalement, qui boucle bien).

Note l'AssetId (clic-droit → "Copy Asset ID").

- [ ] **Step 31.2: Insérer un Sound dans Workspace**

`Workspace` → Insert → `Sound`. Name: `Ambience_City`. Properties :
- SoundId: `rbxassetid://[ASSETID]`
- Volume: `0.4`
- Looped: `true`
- Playing: `true`

- [ ] **Step 31.3: Save + Play (active le son)**

Tu dois entendre un fond sonore urbain.

- [ ] **Step 31.4: Commit**

```bash
git commit -am "feat(v1): ambient city sound loop"
```

**Test ✅:** Au play, tu entends un drone urbain en fond.

---

### Task 32: Audio — musique synthwave

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 32.1: Trouver une track synthwave free**

Toolbox → Audio → "synthwave" / "retrowave" / "cyberpunk music" → filtre Free → écoute → choisis-en une (idéalement boucle 1-2 min).

- [ ] **Step 32.2: Insérer un Sound `Music_Synthwave`**

- SoundId, Volume `0.25`, Looped `true`, Playing `true`
- Optionnel : ajoute un `SoundGroup` dans `SoundService` pour pouvoir baisser musique séparément de l'ambience plus tard.

- [ ] **Step 32.3: Save + Play + Commit**

```bash
git commit -am "feat(v1): synthwave music loop"
```

**Test ✅:** Musique synthwave audible avec ambient en arrière-plan.

---

### Task 33: Audio — bruit de pluie

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 33.1: Trouver un asset "rain"**

Toolbox → Audio → "rain ambient" filtre Free.

- [ ] **Step 33.2: Insérer Sound `Rain_Sound`**

- Volume `0.3`, Looped, Playing
- Place-le idéalement dans `Workspace.RainEmitter` pour le lier visuellement.

- [ ] **Step 33.3: Save + Commit**

```bash
git commit -am "feat(v1): rain audio layer"
```

**Test ✅:** Tu entends la pluie en plus du reste, immersion complète.

---

### Task 34: PNJ piétons (3-5 walkers sur paths prédéfinis)

**Files:**
- Create: `src/shared/CityPaths.lua`
- Create: `src/shared/CityPaths.spec.lua`
- Create: `src/server/npc/Pedestrian.lua`
- Create: `src/server/npc/Pedestrian.spec.lua`
- Create: `src/server/npc/PedestrianSpawner.lua`
- Modify: `src/server/init.server.lua`

**TDD propre** ici — c'est la partie la plus codée de V1.

- [ ] **Step 34.1: Test pour CityPaths**

`src/shared/CityPaths.spec.lua` :

```lua
--!strict
return function()
    local CityPaths = require(script.Parent.CityPaths)

    describe("CityPaths", function()
        it("defines at least 3 paths", function()
            expect(#CityPaths.PATHS >= 3).to.equal(true)
        end)

        it("each path has at least 2 waypoints", function()
            for _, path in ipairs(CityPaths.PATHS) do
                expect(#path.waypoints >= 2).to.equal(true)
            end
        end)

        it("each waypoint is a Vector3", function()
            for _, path in ipairs(CityPaths.PATHS) do
                for _, wp in ipairs(path.waypoints) do
                    expect(typeof(wp)).to.equal("Vector3")
                end
            end
        end)
    end)
end
```

- [ ] **Step 34.2: Lancer les tests — doivent échouer**

Play en Studio → erreur "module CityPaths not found".

- [ ] **Step 34.3: Implémentation `src/shared/CityPaths.lua`**

```lua
--!strict
-- Trajets prédéfinis pour les piétons. Boucles fermées (le piéton tourne en rond).
-- Coordonnées choisies pour rester sur les trottoirs.

local CityPaths = {}

export type Path = {
    name: string,
    waypoints: { Vector3 },
}

CityPaths.PATHS = {
    {
        name = "MainStreet_Loop",
        waypoints = {
            Vector3.new(-12, 2, -45),
            Vector3.new(-12, 2, 45),
            Vector3.new(12, 2, 45),
            Vector3.new(12, 2, -45),
        },
    },
    {
        name = "Alley_Loop",
        waypoints = {
            Vector3.new(-18, 2, 30),
            Vector3.new(18, 2, 30),
        },
    },
    {
        name = "South_Crosswalk",
        waypoints = {
            Vector3.new(-15, 2, -30),
            Vector3.new(15, 2, -30),
        },
    },
} :: { Path }

return CityPaths
```

- [ ] **Step 34.4: Tests CityPaths doivent passer**

Play → Console "TestEZ: X passed".

- [ ] **Step 34.5: Test pour Pedestrian**

`src/server/npc/Pedestrian.spec.lua` :

```lua
--!strict
return function()
    local Pedestrian = require(script.Parent.Pedestrian)

    describe("Pedestrian.computeNextWaypointIndex", function()
        it("advances to next waypoint", function()
            expect(Pedestrian.computeNextWaypointIndex(1, 4)).to.equal(2)
        end)

        it("loops back to 1 from last", function()
            expect(Pedestrian.computeNextWaypointIndex(4, 4)).to.equal(1)
        end)

        it("handles a 2-waypoint path", function()
            expect(Pedestrian.computeNextWaypointIndex(2, 2)).to.equal(1)
        end)
    end)
end
```

- [ ] **Step 34.6: Lancer — doit échouer**

- [ ] **Step 34.7: Implémentation `src/server/npc/Pedestrian.lua`**

```lua
--!strict
-- Un piéton qui boucle sur un Path. NPC simple sans IA — juste de la déambulation.

local CityPaths = require(game:GetService("ReplicatedStorage").Shared.CityPaths)

local Pedestrian = {}
Pedestrian.__index = Pedestrian

export type Pedestrian = typeof(setmetatable(
    {} :: {
        model: Model,
        path: CityPaths.Path,
        currentIndex: number,
    },
    Pedestrian
))

-- Pure function (testable) — index du prochain waypoint dans la boucle.
function Pedestrian.computeNextWaypointIndex(currentIndex: number, totalWaypoints: number): number
    if currentIndex >= totalWaypoints then
        return 1
    end
    return currentIndex + 1
end

-- Crée un piéton (model basique en Parts) à la position du waypoint 1.
function Pedestrian.new(path: CityPaths.Path): Pedestrian
    local model = Instance.new("Model")
    model.Name = "Pedestrian_" .. path.name

    -- HumanoidRootPart pour pouvoir utiliser le pathfinding Roblox de base
    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2, 2, 1)
    hrp.Anchored = false
    hrp.CanCollide = true
    hrp.Color = Color3.fromRGB(80, 80, 90)
    hrp.Position = path.waypoints[1]
    hrp.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model
    model.PrimaryPart = hrp

    -- Tête (cosmétique)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1, 1, 1)
    head.Anchored = false
    head.CanCollide = false
    head.Color = Color3.fromRGB(220, 200, 180)
    head.Parent = model
    head.CFrame = hrp.CFrame * CFrame.new(0, 1.5, 0)

    -- Joint head-hrp (Weld)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = head
    weld.Parent = head

    model.Parent = workspace

    local self = setmetatable({
        model = model,
        path = path,
        currentIndex = 1,
    }, Pedestrian)

    return self
end

-- Démarre la marche en boucle (utilise Humanoid:MoveTo de Roblox).
function Pedestrian:start()
    local humanoid = self.model:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    task.spawn(function()
        while self.model.Parent do
            self.currentIndex = Pedestrian.computeNextWaypointIndex(self.currentIndex, #self.path.waypoints)
            local target = self.path.waypoints[self.currentIndex]
            humanoid:MoveTo(target)
            humanoid.MoveToFinished:Wait()
        end
    end)
end

return Pedestrian
```

- [ ] **Step 34.8: Tests Pedestrian doivent passer**

- [ ] **Step 34.9: Implémentation `src/server/npc/PedestrianSpawner.lua`**

```lua
--!strict
local CityPaths = require(game:GetService("ReplicatedStorage").Shared.CityPaths)
local Pedestrian = require(script.Parent.Pedestrian)

local PedestrianSpawner = {}

function PedestrianSpawner.spawnAll(): { Pedestrian.Pedestrian }
    local pedestrians = {}
    for _, path in ipairs(CityPaths.PATHS) do
        local p = Pedestrian.new(path)
        p:start()
        table.insert(pedestrians, p)
    end
    -- Spawn 1-2 piétons supplémentaires sur les paths les plus longs (pour avoir 3-5 total)
    if #CityPaths.PATHS >= 1 then
        local extra = Pedestrian.new(CityPaths.PATHS[1])
        extra:start()
        table.insert(pedestrians, extra)
    end
    return pedestrians
end

return PedestrianSpawner
```

- [ ] **Step 34.10: Modifier `src/server/init.server.lua`**

Ajouter :
```lua
local PedestrianSpawner = require(ServerScriptService.Source.npc.PedestrianSpawner)
local pedestrians = PedestrianSpawner.spawnAll()
print(string.format("[PedestrianSpawner] spawned %d pedestrians", #pedestrians))
```

- [ ] **Step 34.11: Lint + format**

```bash
selene src/
stylua src/
```

- [ ] **Step 34.12: Test in Studio**

Play → tu dois voir 3-5 PNJs simples (un cube avec une tête au-dessus) qui marchent sur les trottoirs en boucle.

⚠️ Si les PNJs glissent dans le sol → check Position des waypoints (Y trop bas), augmente à 3 ou 4.

- [ ] **Step 34.13: Commit**

```bash
git add src/ assets/places/main.rbxlx
git commit -m "feat(v1): pedestrian NPCs walking on predefined city paths"
```

**Test ✅:** 3-5 PNJ visibles, marchent en boucle sur leurs trajets, ne tombent pas dans le sol.

---

### Task 35: Performance pass — audit des PointLights et particules

**Files:**
- Modify (via Studio): `assets/places/main.rbxlx`

- [ ] **Step 35.1: Compter les PointLights**

Dans la Console Studio (View → Command Bar) :
```lua
local count = 0
for _, d in ipairs(workspace:GetDescendants()) do
    if d:IsA("PointLight") or d:IsA("SpotLight") then
        count = count + 1
    end
end
print("Lights:", count)
```

Cible: ≤ 20 (cap du spec). Si plus, retire les moins importantes (lampadaires non vus, lights cachées dans des pièces fermées).

- [ ] **Step 35.2: Vérifier le ParticleEmitter**

Toujours **un seul** ParticleEmitter pour la pluie (sinon FPS chute). Vérifie dans l'Explorer.

- [ ] **Step 35.3: Test FPS en Play**

Play → cmd `View → Stats` → regarde le compteur FPS. Cible: ≥ 60 fps stable. Si < 30 → réduire Rate de pluie ou enlever des lights.

- [ ] **Step 35.4: Commit (si modifs)**

```bash
git commit -am "perf(v1): cap point lights to 20, optimize rain rate"
```

**Test ✅:** ≤ 20 lights, ≥ 60 fps en Play.

---

### Task 36: V1 final — tag v1.0 + push

**Files:**
- (aucun — git tag)

- [ ] **Step 36.1: Vérifier que tout est commité**

```bash
cd ~/Documents/Roblox/roblox-cyber-hitman
git status
```
Expected: "nothing to commit, working tree clean".

- [ ] **Step 36.2: Push final**

```bash
git push
```

- [ ] **Step 36.3: Tag v1.0**

```bash
git tag -a v1.0 -m "V1 — cyberpunk city explorable: street + alley + 8 buildings + neons + rain + audio + 3-5 pedestrians"
git push origin v1.0
```

- [ ] **Step 36.4: GitHub Release (optionnel mais cool)**

```bash
gh release create v1.0 \
  --title "V1 — Cyberpunk City" \
  --notes "Walkable cyberpunk Tokyo neighborhood: 1 main street + 1 alley, 8 buildings (2 towers, 3 shops, 2 apartments, 1 rooftop spot), animated neon signs, rain particles + audio, 3-5 walking pedestrians, synthwave soundtrack."
```

**Test ✅:** Tag visible sur GitHub Releases.

---

### Task 37: V1 wow test (le critère d'acceptation du spec)

**Files:**
- (aucun — test rituel)

- [ ] **Step 37.1: Cold restart (comme V0 Task 14)**

Quitte tout, relance Studio + rojo serve, ouvre la place, Connect, Play.

- [ ] **Step 37.2: Visite ta ville**

Marche dans la rue principale, dans la ruelle, monte sur le toit du Rooftop_Building, regarde les enseignes animées, écoute la musique + pluie.

- [ ] **Step 37.3: Le test "wow"**

Demande à un proche (frère, sœur, parent, ami) de venir tester :
1. Tu lances le jeu
2. Tu lui passes la souris/clavier
3. Tu ne dis rien et tu observes sa réaction

Si la première phrase qui sort est "wow" / "c'est toi qui as fait ça ?!" / "c'est trop stylé" → **V1 ✅**.

Si c'est "c'est joli mais..." → note ce qui manque, ouvre une issue GitHub `gh issue create`, et planifie une mini-itération avant V2.

🎉 **V1 OFFICIELLEMENT TERMINÉE.** Tu peux te reposer. Bravo Anton.

**Test ✅:** Réaction "wow" obtenue d'un proche → V1 validée.

---

# Self-review du plan

(Section pour Claude — vérification post-rédaction.)

**Coverage spec → tasks :**
- ✅ V0 Section 3.1 livrables → Tasks 1–14 (Rokit, Rojo plugin, structure, scripts, GitHub, baseplate, tag)
- ✅ V1 Section 4 livrables architecture → Tasks 16–24 (rue, ruelle, 8 bâtiments dont rooftop)
- ✅ V1 Section 4 livrables ambiance → Tasks 15, 29, 30 (lighting, pluie, skybox+Fuji)
- ✅ V1 Section 4 livrables son → Tasks 31–33 (ambient, musique, pluie)
- ✅ V1 Section 4 livrables vie → Task 34 (pédestres TDD)
- ✅ Section 8 risque "performance" → Task 35
- ✅ Section 6 contrainte audio TOS → Task 31 step 31.1 explicite

**Placeholder scan :** aucun TBD/TODO. Toutes les couleurs, tailles, positions, codes Lua sont concrets.

**Type consistency :** `Pedestrian.Pedestrian`, `CityPaths.Path` sont déclarés explicitement. `NeonAnimations.computeBlinkAlpha`, `computeMarqueeOffset` cohérents entre tests et implémentation.

**Scope :** V0+V1 uniquement. V2-V5 explicitement hors scope.

**Issues à noter :** la "Toolbox audio" reste un point d'incertitude opérationnelle — si Anton ne trouve pas d'asset Free, alternative à documenter au moment de l'exécution (uploader son propre audio).
