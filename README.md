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
```

TestEZ est vendored dans `Packages/TestEZ/` (Wally étant x86_64-only sur Mac, on saute Wally pour V0).

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
Packages/     — dépendances vendored (TestEZ)
assets/places/main.rbxlx   — fichier de place Studio (versionné en XML)
docs/         — design specs + plans d'implémentation
```
