# Axolotl Tower Defense (AxolotlTD)

A cooperative tower defense game on Roblox featuring axolotl-themed towers and enemies.

## Concept
- Place towers (axolotl heroes) to stop waves of aquatic enemies.
- Earn currency from kills to place more towers and survive all waves.
- MVP: 3 towers, 5 enemies, 10 waves, one map.

## Tech Stack
- **Roblox Studio** — world building + playtesting
- **Rojo** — sync Roblox DataModel ↔ filesystem
- **Luau** — Roblox scripting language
- **GitHub** — collaboration and version control

## Development Setup

### Prerequisites
- Roblox Studio
- Rojo (CLI)

Install Rojo:
```bash
cargo install rojo
# or via aftman (recommended in many Roblox projects)
```

### Run Rojo
From the repo root:
```bash
rojo serve
```

Then in Roblox Studio:
1. Install the Rojo plugin (if you don't have it)
2. Open a place
3. Connect Rojo to the running server

## Project Structure

- `default.project.json` — Rojo project file
- `src/server/` — Server-side scripts (authoritative gameplay)
  - `init.server.luau` — server entry point
  - `systems/` — core game systems (waves, combat, economy, etc.)
- `src/shared/` — ReplicatedStorage shared modules and config
  - `config/` — data-driven balancing (towers, enemies, waves, game constants)
  - `modules/` — shared utilities (EventBus)
  - `types/` — Luau type aliases
- `src/client/` — Client-side scripts and GUI
  - `scripts/` — tower placement, UI bindings
  - `gui/` — UI screens (HUD, victory/defeat)
- `src/storage/` — ServerStorage (tower models, enemy models, assets)
- `docs/` — architecture + Codex task breakdown
- `assets/` — reference images, design docs

## How to Contribute

### Will (world building + creative input)
- Build the map + path in Roblox Studio
- Place waypoint Parts tagged `Waypoint` (with a `NumberValue` named `Order`)
- Create tower and enemy models (placeholder geometry is fine)
- Give feedback on pacing, difficulty curve, visual readability

### Engineers
- Implement systems per `docs/CODEX-TASKS.md`
- Keep gameplay numbers in `src/shared/config/`
- Maintain server-authoritative state (clients are UI + input)

## Notes
- The repo is scaffolded with stubs to make Codex tasks easy to dispatch.
- The architecture is config-driven: balance changes should not require system code changes.
