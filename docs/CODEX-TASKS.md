# Axolotl Tower Defense — CODEX Tasks (Phase 1 MVP)

These tasks are designed to be dispatched sequentially to Codex. Each task is self-contained, references explicit files, and includes acceptance criteria.

## T1: EventBus Module
**Goal:** Implement a simple pub/sub event system to decouple server systems.

- **File:** `src/shared/modules/EventBus.luau`
- **Implement:**
  - `fire(eventName, ...)`
  - `on(eventName, callback)`
  - `off(eventName, callback)`
  - (Optional) `clear(eventName)`, `clearAll()`
- **Approach:** Use a `BindableEvent` per event name (or a callback registry). Keep it lightweight and predictable.

**Acceptance Criteria:**
- Calling `EventBus.on("Test", cb)` then `EventBus.fire("Test", 123)` invokes `cb(123)`.
- `EventBus.off("Test", cb)` prevents future invocations.
- Multiple listeners on the same event all receive the event.

---

## T2: Types Module
**Goal:** Provide shared Luau type aliases for core entities.

- **File:** `src/shared/types/Types.luau`
- **Implement:**
  - Type aliases for: `Tower`, `Enemy`, `Wave`, `GameState`
  - Keep this file pure types (no logic).

**Acceptance Criteria:**
- Types are exported and can be imported by server/client modules without runtime side effects.
- No runtime logic beyond `return {}`.

---

## T3: PathManager System
**Goal:** Provide waypoint-based path data for enemies.

- **File:** `src/server/systems/PathManager.luau`
- **Implement:**
  - `getWaypoints()` returns ordered `{Vector3}`.
  - `getNextWaypoint(currentIndex)` returns next Vector3 or nil.
  - `getTotalDistance()` returns total distance across all segments.
- **Waypoint Definition:** Workspace Parts tagged `"Waypoint"` with a `NumberValue` child named `"Order"`.

**Acceptance Criteria:**
- If workspace has waypoint parts tagged properly, PathManager returns them sorted by Order.
- Total distance equals sum of consecutive distances.

---

## T4: Enemy Spawning & Movement
**Goal:** Spawn enemies and move them along the path.

- **File:** `src/server/systems/EnemyManager.luau` *(new file; already stubbed)*
- **Implement:**
  - Spawn enemy model at first waypoint
  - Move along waypoints via `RunService.Heartbeat` (lerp / step by `speed * dt`)
  - Track alive enemies in a table
  - Fire events:
    - `"EnemyReachedEnd"`
    - `"EnemyDied"`
  - Use `EnemyConfig` for stats

**Acceptance Criteria:**
- Spawning an enemy creates a model and registers it.
- Enemy moves from waypoint 1 to end.
- Reaching end fires `EnemyReachedEnd` once and removes enemy.

---

## T5: WaveManager Implementation
**Goal:** Drive wave progression from WaveConfig.

- **File:** `src/server/systems/WaveManager.luau`
- **Implement:**
  - Read `WaveConfig` for current wave
  - Spawn enemies via `EnemyManager` at configured intervals
  - Track wave state: preparing / active / complete
  - Auto-advance after `GameConfig.wavePrepTime`
  - Fire events:
    - `"WaveStarted"`
    - `"WaveCompleted"`
    - `"AllWavesComplete"`

**Acceptance Criteria:**
- Starting wave N spawns enemies matching the config counts/intervals.
- When all enemies are gone, wave completes and the next prep phase begins.
- After final wave, `AllWavesComplete` fires.

---

## T6: CombatSystem Implementation
**Goal:** Towers target enemies, fire, and apply damage.

- **File:** `src/server/systems/CombatSystem.luau`
- **Implement:**
  - Heartbeat loop
  - For each tower:
    - Find nearest enemy in range
    - Respect fire rate cooldown
    - Apply damage
    - Create a simple projectile visual (Part tween)
  - On enemy HP <= 0, fire `"EnemyKilled"`
  - Use `TowerConfig` for tower stats

**Acceptance Criteria:**
- A tower damages enemies in range over time.
- Projectiles appear and tween to target.
- Enemy death triggers `EnemyKilled` with correct reward metadata.

---

## T7: EconomyManager Implementation
**Goal:** Track and broadcast per-player currency.

- **File:** `src/server/systems/EconomyManager.luau`
- **Implement:**
  - Track per-player money starting at `GameConfig.startingMoney`
  - Listen for `"EnemyKilled"` and award based on `EnemyConfig.reward`
  - Methods:
    - `canAfford(player, amount)`
    - `spend(player, amount)`
    - `getBalance(player)`
  - Fire `"BalanceChanged"` for UI updates

**Acceptance Criteria:**
- Players spawn with starting money.
- Killing enemies increases money.
- Spending fails if insufficient funds.

---

## T8: TowerPlacement (Server)
**Goal:** Validate and place towers on the server.

- **File:** `src/server/systems/TowerManager.luau` *(new file; already stubbed)*
- **Implement:**
  - Listen for `PlaceTower` RemoteEvent
  - Validate:
    - Tower type exists
    - Player has money
    - Valid position (raycast to ground)
    - Not overlapping other towers
  - Deduct cost via EconomyManager
  - Create tower model, register with CombatSystem
  - Fire `"TowerPlaced"`

**Acceptance Criteria:**
- Valid placement spawns a tower and deducts money.
- Invalid placement does not deduct money and returns a failure reason.

---

## T9: TowerPlacement (Client)
**Goal:** Implement placement UX on the client.

- **File:** `src/client/scripts/TowerPlacement.client.luau`
- **Implement:**
  - Placement ghost follows mouse
  - Click sends PlaceTower RemoteEvent (position + tower type)
  - Cancel with right-click or Escape
  - Disable placement when insufficient money

**Acceptance Criteria:**
- Ghost appears and moves with mouse.
- Clicking attempts placement.
- Cancel works reliably.

---

## T10: Game UI (Client)
**Goal:** MVP HUD for money/waves/base health + tower shop.

- **Files:** `src/client/gui/` (create ScreenGui + components)
- **Implement:**
  - Money display (top right)
  - Wave counter (top center)
  - Base HP bar (top left)
  - Tower purchase buttons (bottom panel): Sparky/Rocky/Zippy
  - Bind to server RemoteEvents for live updates

**Acceptance Criteria:**
- HUD updates when RemoteEvents fire.
- Buttons select towers for placement.

---

## T11: Server Init & Game Loop
**Goal:** Wire everything together and run the round.

- **File:** `src/server/init.server.luau`
- **Implement:**
  - Initialize all systems
  - Create RemoteEvents
  - Start loop: prep → waves → victory/game over
  - Game Over when base HP reaches 0
  - Victory when all waves complete

**Acceptance Criteria:**
- Server boots without errors.
- Waves run from 1 to 10.
- Game ends properly on victory/defeat.

---

## T12: Game Over / Victory UI
**Goal:** End-of-game screens.

- **Files:** `src/client/gui/` (GameOverScreen, VictoryScreen)
- **Implement:**
  - Show final score: wave reached, enemies killed, money earned
  - Restart button

**Acceptance Criteria:**
- Correct screen displays on corresponding server RemoteEvent.
- Restart returns player to a fresh game session (MVP can rejoin).
