# Axolotl Tower Defense - Architecture

## System Overview

**Server-Authoritative Design:**
- All game state lives on the server: wave state, economy, base HP, tower positions, enemy positions
- Client is responsible for: tower placement preview, UI rendering, input handling
- Communication: RemoteEvents for bidirectional communication
  - Client→Server: Player actions (tower placement, tower selection)
  - Server→Client: State updates (balance changes, wave progress, base HP)

**Why Server-Authoritative?**
- Prevents cheating (money hacks, invincible towers)
- Single source of truth for game state
- Simplifies multiplayer synchronization
- Reduces client-side complexity

## Core Systems (Server-Side)

### 1. WaveManager
**Responsibilities:**
- Read WaveConfig to determine wave composition
- Spawn enemies at configured intervals along the path
- Track current wave number and enemies alive
- Trigger next wave when all enemies dead + prep time elapsed
- Boss waves every 5 waves (future feature)
- Fire events: "WaveStarted", "WaveCompleted", "AllWavesComplete"

**State:**
- currentWave: number
- waveState: "preparing" | "active" | "complete"
- enemiesAlive: number
- prepTimer: number

**Dependencies:**
- EnemyManager (for spawning)
- WaveConfig (data)
- EventBus (notifications)

### 2. CombatSystem
**Responsibilities:**
- Each tower finds nearest enemy in range every tick
- Apply damage based on tower stats and fire rate cooldown
- Create visual projectiles (simple part tween from tower to enemy)
- Handle enemy death → fire "EnemyKilled" event with enemy data
- Track tower cooldowns

**State:**
- towers: Map<towerId, TowerData>
- towerCooldowns: Map<towerId, number>

**Dependencies:**
- TowerConfig (stats)
- EnemyManager (enemy positions, health)
- EventBus (death notifications)

### 3. EconomyManager
**Responsibilities:**
- Track per-player currency balance
- Award money on enemy kill (amount based on enemy tier/reward)
- Deduct money on tower purchase/upgrade
- Validate player can afford actions
- Broadcast balance updates to clients

**State:**
- playerBalances: Map<Player, number>

**Methods:**
- `canAfford(player, amount): boolean`
- `spend(player, amount): boolean`
- `award(player, amount)`
- `getBalance(player): number`

**Events Fired:**
- "BalanceChanged" → {player, newBalance}

**Dependencies:**
- GameConfig (starting money)
- EventBus (kill notifications, balance updates)

### 4. PathManager
**Responsibilities:**
- Store ordered list of waypoints (Vector3 positions)
- Provide path data to enemy movement system
- Calculate total path distance
- Support waypoint lookup by index

**Implementation:**
- Waypoints defined in workspace as Parts tagged "Waypoint"
- Each waypoint has NumberValue "Order" attribute for sequencing
- On init, collect and sort waypoints by Order

**State:**
- waypoints: Array<Vector3>

**Methods:**
- `getWaypoints(): Array<Vector3>`
- `getNextWaypoint(currentIndex): Vector3?`
- `getTotalDistance(): number`

### 5. EnemyManager
**Responsibilities:**
- Spawn enemy models at first waypoint
- Move enemies along waypoints using Heartbeat (lerp by speed * dt)
- Track all alive enemies in a table
- Handle enemy reaching end of path → deal damage to base
- Handle enemy death → cleanup, notify systems
- Apply difficulty multipliers to enemy stats

**State:**
- aliveEnemies: Map<enemyId, EnemyData>
- enemyModels: Map<enemyId, Model>

**Events Fired:**
- "EnemyReachedEnd" → {enemyId, damageAmount}
- "EnemyDied" → {enemyId, enemyType, rewardAmount}

**Dependencies:**
- PathManager (waypoint data)
- EnemyConfig (stats)
- GameConfig (difficulty multipliers)

### 6. BaseHealth
**Responsibilities:**
- Track base HP pool (starts at 100)
- Receive damage when enemies reach end of path
- Fire "GameOver" event when HP reaches 0
- Broadcast HP changes to clients for UI

**State:**
- currentHealth: number

**Methods:**
- `takeDamage(amount)`
- `getHealth(): number`

**Events Fired:**
- "BaseHealthChanged" → {newHealth}
- "GameOver"

### 7. TowerManager
**Responsibilities:**
- Listen for PlaceTower RemoteEvent from clients
- Validate tower placement:
  - Player has enough money
  - Position is on valid ground
  - No overlap with existing towers
  - Tower type exists in TowerConfig
- Deduct cost via EconomyManager
- Create tower model at position
- Register tower with CombatSystem
- Handle tower upgrades (future)

**State:**
- placedTowers: Map<towerId, TowerData>

**Events Listened:**
- RemoteEvent "PlaceTower" → {player, towerType, position}

**Events Fired:**
- "TowerPlaced" → {towerId, towerType, position, owner}
- "TowerPlacementFailed" → {player, reason}

**Dependencies:**
- TowerConfig (stats, costs)
- EconomyManager (money validation, spending)
- CombatSystem (tower registration)

## Client Systems

### 1. TowerPlacement
**Responsibilities:**
- Show ghost tower following mouse on ground plane
- On click, fire PlaceTower RemoteEvent with position + selected tower type
- Cancel placement with right-click or Escape
- Disable placement when player lacks money
- Visual feedback (green = valid, red = invalid placement)

**State:**
- selectedTowerType: string?
- ghostModel: Model?
- canPlace: boolean

**Dependencies:**
- TowerConfig (for ghost model, cost display)
- RemoteEvent "PlaceTower"

### 2. GameUI
**Components:**
- Money display (top right) — listens for "BalanceChanged" RemoteEvent
- Wave counter (top center) — listens for "WaveStarted" RemoteEvent
- Base HP bar (top left) — listens for "BaseHealthChanged" RemoteEvent
- Tower purchase buttons (bottom panel):
  - Sparky button (cost: 100)
  - Rocky button (cost: 75)
  - Zippy button (cost: 50)
  - Each shows icon, name, cost
  - Disabled when player can't afford

**Events Listened:**
- RemoteEvent "BalanceChanged" → update money display
- RemoteEvent "WaveStarted" → update wave counter
- RemoteEvent "BaseHealthChanged" → update HP bar
- RemoteEvent "TowerPlacementFailed" → show error message

### 3. GameOverScreen / VictoryScreen
**Responsibilities:**
- Display final score when game ends
  - Wave reached
  - Enemies killed
  - Money earned
- Show victory message if all waves complete
- Show defeat message if base HP reached 0
- Restart button → rejoin game

**Events Listened:**
- RemoteEvent "GameOver" → show defeat screen
- RemoteEvent "Victory" → show victory screen

## Data Flow

### Tower Placement Flow
```
1. Client: Player clicks tower button → selectedTowerType = "Sparky"
2. Client: Ghost tower follows mouse
3. Client: Player clicks ground → fire RemoteEvent "PlaceTower" {player, "Sparky", position}
4. Server: TowerManager receives event
5. Server: Validate position, check money via EconomyManager
6. Server: If valid → spend money, create tower model, register with CombatSystem
7. Server: Fire RemoteEvent "TowerPlaced" → all clients render tower
8. Server: Fire RemoteEvent "BalanceChanged" → update UI for player
9. Client: Remove ghost, update money display
```

### Combat Flow
```
1. Server: CombatSystem Heartbeat tick
2. Server: For each tower, find nearest enemy in range
3. Server: If enemy found and cooldown expired:
   - Create projectile part, tween to enemy
   - Apply damage to enemy
   - Reset cooldown
4. Server: If enemy HP <= 0:
   - Remove enemy model
   - Fire "EnemyKilled" event
   - EconomyManager awards money to players
   - WaveManager decrements alive count
5. Server: Fire RemoteEvent "BalanceChanged" → update UI
```

### Wave Progression Flow
```
1. Server: WaveManager init → prep phase (10 seconds)
2. Server: After prep → startWave(1)
3. Server: Read WaveConfig[1], spawn enemies via EnemyManager at intervals
4. Server: Track enemies alive
5. Server: When all enemies dead:
   - Fire "WaveCompleted" event
   - Start prep timer for next wave
6. Server: Repeat for waves 2-10
7. Server: After wave 10 complete → fire "Victory" event
```

### Game Over Flow
```
1. Server: Enemy reaches end of path
2. Server: EnemyManager fires "EnemyReachedEnd" {damage}
3. Server: BaseHealth.takeDamage(damage)
4. Server: Fire RemoteEvent "BaseHealthChanged" → update UI
5. Server: If health <= 0:
   - Fire "GameOver" event
   - Stop wave spawning
   - Fire RemoteEvent "GameOver" → show defeat screen
```

## Config-Driven Design

**Principle:** All gameplay data (tower stats, enemy stats, wave composition, costs) lives in pure data tables under `src/shared/config/`. No magic numbers in system code.

**Benefits:**
- **Separation of concerns:** Game logic vs. game data
- **Codex-friendly:** Tasks can modify configs without touching systems
- **Balance iteration:** Designers can tweak values without code changes
- **Testability:** Easy to test systems with mock configs

**Config Files:**
- `TowerConfig.luau` — tower stats, costs, upgrade paths
- `EnemyConfig.luau` — enemy stats, rewards, behaviors
- `WaveConfig.luau` — wave compositions, spawn intervals
- `GameConfig.luau` — global constants (starting money, base HP, difficulty multipliers)

**Access Pattern:**
```lua
local TowerConfig = require(game.ReplicatedStorage.config.TowerConfig)
local sparkyStats = TowerConfig.Sparky
print(sparkyStats.cost, sparkyStats.damage, sparkyStats.range)
```

## File Structure

```
axolotl-td/
├── default.project.json          # Rojo project definition
├── src/
│   ├── server/
│   │   ├── init.server.luau      # Main server entry, wires all systems
│   │   └── systems/
│   │       ├── WaveManager.luau
│   │       ├── CombatSystem.luau
│   │       ├── EconomyManager.luau
│   │       ├── EnemyManager.luau
│   │       ├── PathManager.luau
│   │       ├── BaseHealth.luau
│   │       └── TowerManager.luau
│   ├── shared/                   # ReplicatedStorage
│   │   ├── config/
│   │   │   ├── TowerConfig.luau
│   │   │   ├── EnemyConfig.luau
│   │   │   ├── WaveConfig.luau
│   │   │   └── GameConfig.luau
│   │   ├── modules/
│   │   │   └── EventBus.luau
│   │   └── types/
│   │       └── Types.luau
│   ├── client/
│   │   ├── gui/                  # UI screens (created in Studio)
│   │   └── scripts/
│   │       └── TowerPlacement.client.luau
│   └── storage/                  # ServerStorage (models, assets)
├── assets/                       # Reference images, design docs
└── docs/
    ├── ARCHITECTURE.md           # This file
    └── CODEX-TASKS.md            # Task breakdown for Codex
```

## Technology Stack

- **Roblox Studio** — game engine, level editor
- **Rojo** — project sync between filesystem and Studio
- **Luau** — typed Lua dialect for Roblox
- **Git + GitHub** — version control

## Development Workflow

1. Edit code in filesystem (VS Code, Cursor, etc.)
2. Run `rojo serve` — syncs changes to Studio in real-time
3. Test in Studio
4. Commit to git when feature complete
5. Push to GitHub

## Future Enhancements (Post-MVP)

- Tower upgrades (visual + stat changes)
- Boss enemies every 5 waves
- Enemy abilities (Frog leap, Crayfish armor, Turtle shell)
- Tower abilities (Chain Lightning, Earthquake, Blur Strike)
- Multiplayer cooperative play (shared economy vs. per-player)
- Leaderboards
- Additional maps
- More tower types (8 total planned)
- More enemy types (15+ total planned)
- Sound effects and music
- Visual polish (particles, animations)
- Mobile controls
