# Roblox Cyber Hitman — Design Spec

**Auteur** : Anton (14 ans, débutant Roblox/dev)
**Date** : 2026-04-27
**Statut** : Validé — sections 1 à 4 approuvées par Anton avant écriture
**Repo cible** : `roblox-cyber-hitman` (local : `~/Documents/Roblox/roblox-cyber-hitman/`)

---

## 1. Vision

Un jeu Roblox **multijoueur 1 à 4 joueurs** dans un quartier cyberpunk style néo-Tokyo (néons, pluie, panneaux holographiques, ambiance synthwave). Chaque joueur incarne un agent secret. Une voix féminine *Agent 47* le briefe par radio. **Mission centrale** : éliminer un dictateur dans un environnement gardé. Plusieurs méthodes possibles à terme (sniper depuis un toit, poison, déguisement, "accident" environnemental, etc.).

Inspirations : franchise *Hitman*, esthétique *Cyberpunk 2077* / *Blade Runner 2049* / *Neon Tokyo* sur Roblox.

## 2. Roadmap — 6 versions, chacune jouable de bout en bout

| Version | Contenu | Estimation |
|---|---|---|
| **V0 — Squelette** | Repo GitHub + Rojo opérationnel + plugin Studio connecté + perso qui spawne sur un sol gris | ~2–3 jours |
| **V1 — La ville** | Quartier cyberpunk explorable (1 rue + 1 ruelle, ~8 bâtiments, néons, pluie, son ambient, 3–5 PNJ piétons) | ~2 semaines |
| **V2 — Première mission** | 1 cible (le dictateur), gardes basiques avec patrouille + détection, 1 arme (pistolet), briefing texte avant mission, conditions de victoire/échec | ~2 semaines |
| **V3 — Multijoueur** | 1–4 joueurs partagent objectifs, sync de l'état mission, n'importe quel joueur peut éliminer la cible | ~1–2 semaines |
| **V4 — Voix Agent 47** | Briefings audio + commentaires temps réel pendant les missions | ~1 semaine |
| **V5 — Méthodes multiples** | Poison, sniper, accident environnemental, déguisement de garde | ~3–4 semaines |

**Ce spec couvre uniquement V0 + V1.** V2 → V5 sont la roadmap pour mémoire ; chacune aura son propre spec + plan quand on y arrivera.

**Cadence cible** : ~20–25h/semaine en sprint motivé. Anton a évoqué « 100h/semaine » : irréaliste, calibré à 20–25h max pour ne pas brûler le projet.

## 3. V0 — Squelette (détail)

### Objectifs
- Avoir un projet "bien plombé" : structure propre, outils installés, sync Studio↔fichiers fonctionnel, GitHub vivant.
- Aucun gameplay. Juste : `play` → un perso spawne sur un sol gris.

### Livrables
- ✅ Compte GitHub Anton (`anton-analyze`) + repo `roblox-cyber-hitman` créé via `gh repo create` (Anton choisit public ou privé à la création — public conseillé pour montrer ton travail)
- ✅ **Rokit** installé (successeur moderne d'Aftman, par la même équipe que Rojo), fichier `rokit.toml` qui épingle `rojo-rbx/rojo` à une version précise
- ✅ **Rojo** installé via Rokit
- ✅ **Plugin Rojo** installé dans Roblox Studio (via Plugin Marketplace)
- ✅ Structure de dossiers (voir section 5)
- ✅ Fichier `default.project.json` minimal qui définit `ServerScriptService`, `StarterPlayerScripts`, `ReplicatedStorage`, `Workspace`
- ✅ Un baseplate (sol gris, 200×200 studs) construit dans Studio et exporté
- ✅ Un script `src/server/init.server.lua` qui imprime `"V0 alive"` en console au démarrage
- ✅ `README.md` : nom du jeu, comment lancer, dépendances
- ✅ `.gitignore` qui ignore les fichiers temporaires Studio (`*.rbxlx.lock`, etc.)

### Critère "V0 réussie"
Anton ferme tout, revient le lendemain, exécute la séquence (`rojo serve` + Studio + Connect + Play), **son perso spawne sur le sol gris et `"V0 alive"` apparaît en console**. Tag `v0.0` posé.

## 4. V1 — La ville cyberpunk (détail)

### Objectifs
Un quartier qu'on a envie d'explorer **même sans rien y faire**. C'est l'accroche émotionnelle du projet.

### Style visuel locké
- **"Cyberpunk stylisé"** — formes simples, énormément de détails néon. **PAS** photoréaliste.
- **Palette** : noir/charbon dominant + néons rose/magenta + cyan/bleu électrique en accents. Quelques touches violet et jaune ambre.
- **Référence visuelle** : style Roblox *Neon Tokyo* / *2077 Cyber Dreamscape*, pas Cyberpunk 2077 PC.

### Livrables

**Architecture (~50%)**
- 1 rue principale, ~100 studs de long
- 1 ruelle perpendiculaire, ~40 studs
- 8 bâtiments répartis :
  - 2 tours corpo (8–12 étages, façades vitrées)
  - 3 commerces niveau rue (ramen, bar, magasin de tech)
  - 2 immeubles d'habitation (4–6 étages, balcons)
  - 1 bâtiment avec **toit accessible** (servira pour le sniper en V5)
- Trottoirs, route bitume, 2 passages piétons
- 4–6 voitures **statiques** garées (pas de circulation animée)

**Ambiance (~30%)**
- 15–20 enseignes néon (japonais/anglais mélangés style Tokyo)
- 3–4 enseignes **animées** (clignote, défile)
- Lumière globale : nuit, brouillard légèrement coloré
- Effet de **pluie** (particules `Workspace.Rain`)
- Skybox de nuit : ciel sombre + Mont Fuji holographique au loin (clin d'œil Tokyo, validé par Anton)

**Son (~10%)**
- Bruit ambient ville (rumeur basse, ventilation, klaxons lointains)
- 1 piste musicale synthwave en boucle
- Bruit de pluie
- ⚠️ **Contrainte légale** : Roblox a durci les règles audio. **Aucun audio "trouvé sur internet" ou pris dans le toolbox sans vérification.** Sources autorisées : (a) audio uploadé par Anton lui-même (Roblox vérifie automatiquement les droits), (b) Roblox Audio Library officielle filtrée "free to use", (c) musiciens indé qui licencient explicitement pour Roblox (cherche sur le devforum). À traiter dans le plan V1.

**Vie de la ville (~10%)**
- 3–5 PNJ piétons sur trajets prédéfinis (`Animation.Walk` en boucle, pas d'IA, pas d'interaction)

### Hors scope V1 (volontairement reportés)
- ❌ Le dictateur, les gardes (V2)
- ❌ Toute arme (V2)
- ❌ Tout système de mission (V2)
- ❌ Multijoueur testé spécifiquement (V3) — V1 marchera en multi par défaut Roblox sans être optimisé
- ❌ Voix off (V4)
- ❌ Trafic routier animé (V3+ ou plus tard)

### Critère "V1 réussie"
Anton fait tester la ville à un proche → réaction "wow". Tag `v1.0` posé.

## 5. Architecture technique

### Structure du repo
```
roblox-cyber-hitman/
├── default.project.json     ← recette Rojo
├── rokit.toml               ← outils épinglés
├── .gitignore
├── README.md
├── docs/
│   ├── superpowers/
│   │   ├── specs/           ← ce fichier
│   │   └── plans/           ← plans d'implémentation
│   └── notes/               ← notes libres
├── src/
│   ├── server/              ← logique serveur (gameplay, missions, IA)
│   ├── client/              ← UI, contrôles, caméra (par joueur)
│   └── shared/              ← code partagé (constantes, types, utils)
└── assets/
    └── places/              ← export périodique de la place Studio (.rbxlx)
```

### Conventions
- **Modules Lua** : `PascalCase.lua` (ex. `MissionService.lua`)
- **Scripts d'init Rojo** : `init.server.lua` ou `init.client.lua`
- **Dossiers** : `kebab-case` (ex. `mission-system/`)
- `--!strict` en haut de chaque module → typage Luau strict
- **1 module = 1 responsabilité.** Aucun fichier ne dépasse 200 lignes en V0/V1.
- **Pas de magic numbers** : constantes dans `src/shared/constants/`

### Workflow Rojo↔Studio
- Code en fichiers (sur disque) → Rojo sert sur `localhost:34872` → plugin Rojo dans Studio se connecte → sync temps réel
- Visuels (bâtiments, lights, particles) construits **dans Studio** → sauvegarde de la place dans `assets/places/main.rbxlx` → ce fichier est tracké par Git
- Le `.rbxlx` Studio est **versionné** (texte XML, lisible par Git, pas binaire)

## 6. Workflow quotidien d'Anton

1. **Démarrer une session** : terminal → `cd ~/Documents/Roblox/roblox-cyber-hitman && rojo serve`
2. **Ouvrir Studio** → ouvrir `assets/places/main.rbxlx` → cliquer "Connect" dans le plugin Rojo
3. **Coder** : édition dans VS Code, chaque sauvegarde se sync dans Studio en temps réel
4. **Construire** (visuel) : à la souris dans Studio, puis `File → Save` (place exportée vers `assets/places/`)
5. **Tester** : `Play` dans Studio
6. **Fin de session** : `git add -A && git commit -m "<message clair>" && git push`
7. **Fin d'une version** : `git tag vX.Y && git push --tags`

### Comment Anton interagit avec Claude
- Pour le **code** : Claude lit/édite les fichiers Lua directement → Rojo les pousse dans Studio (Anton ne copie/colle jamais de code)
- Pour le **visuel** : Claude donne des instructions pas-à-pas ("dans Studio, clique sur X, mets la valeur Y")
- Granularité de commit : un commit = une fonctionnalité fermée (~5–30 min de boulot)

## 7. Décisions reportées

Ces choix seront tranchés au moment de leur version respective ; **ne pas les pré-décider** :

- **V4 — Voix Agent 47** : 3 options (a) ElevenLabs IA payant ~5€/mois, (b) enregistrement humain, (c) TTS gratuit. À décider début V4.
- **V2 — Système d'IA gardes** : pathfinding Roblox natif + scripts perso, vs plugin "NoobAI" (gratuit, 1600+ installs sur le devforum, patrouille + chase + line-of-sight clés-en-main). NoobAI est probablement le bon choix pour démarrer vite. À confirmer début V2.
- **V3 — Architecture réseau multijoueur** : **Sleitnick/RbxUtil** (le successeur moderne de Knit, Knit étant archivé en 2025) / **Matter** (ECS) / vanilla RemoteEvents. RbxUtil semble par défaut la bonne option (modulaire, MIT, maintenu). À confirmer début V3.
- **V3 — Persistance données joueur** : **MadStudioRoblox/ProfileService** (standard de l'industrie, 322 stars, Apache-2.0) sera quasi-certainement le choix — écrire ses propres DataStores perd des données joueurs en pratique. À confirmer début V3.

## 8. Risques connus & mitigations

| Risque | Mitigation |
|---|---|
| Anton se décourage si V1 prend trop long | Découpage en sous-livrables hebdomadaires dans le plan ; chaque jeudi soir on doit voir un progrès visible |
| Performance Roblox (trop de lights/particles) | Cap : pas plus de **20 PointLights** simultanés en V1 ; pluie en `ParticleEmitter` unique |
| Conflits Studio↔Git sur le `.rbxlx` | Convention : on ne **jamais** modifier la place dans Studio sans avoir `rojo serve` actif et code à jour ; commit du `.rbxlx` après chaque session de build |
| Anton perd accès à un état qui marchait | Tag git après chaque version + commits fréquents (>=3/session) |
| Surcharge ambition (Anton veut sauter à V3) | Règle : aucune V_N+1 ne démarre tant que `vN.0` n'est pas tagué |

## 9. Définition de "fini" pour ce spec

Ce spec est "fini" quand Anton l'a relu et donné son OK. Le plan détaillé d'implémentation V0+V1 sera écrit ensuite via la skill `superpowers:writing-plans` dans `docs/superpowers/plans/2026-04-27-v0-v1-implementation.md`.

## 10. Recherche complémentaire

Une recherche de repos publics utiles a été menée le 2026-04-27 et sauvegardée dans `~/Documents/Roblox/research-2026-04-27.md`. Les trouvailles qui impactent ce spec sont déjà intégrées (Rokit, RbxUtil, ProfileService, NoobAI, contrainte audio). Le rapport complet contient ~6 catégories de ressources additionnelles à exploiter au fur et à mesure des versions.
