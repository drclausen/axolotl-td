# Axolotl Tower Defense — CODEX Phase 2: World Bootstrap & Fixes

All work in this file targets the `axolotl-td/` repo at `/Users/drclausen/clawd/axolotl-td/`.
Run tasks sequentially. Each task is self-contained. Push after each.

---

## P2-1: Fix PathManager.init() Call (Critical Bug)

**File:** `src/server/init.server.luau`

**Problem:** `PathManager.init()` is never called during server bootstrap. Enemy pathfinding will break if waypoints aren't pre-configured in workspace.

**Fix:**
- Add `PathManager.init()` call BEFORE `EnemyManager.init()` in the initialization sequence
- Verify the init order makes sense: PathManager → EnemyManager → TowerManager → WaveManager → CombatSystem → EconomyManager → BaseHealth

**Acceptance Criteria:**
- `PathManager.init()` is called before any system that depends on waypoints
- No other initialization order changes
- Game still boots cleanly (no require errors)

---

## P2-2: Tower Range Indicator During Placement

**File:** `src/client/scripts/TowerPlacement.client.luau`

**Problem:** Ghost tower preview shows position validity (green/red) but no attack range visualization. Players can't see coverage before placing.

**Implement:**
- When ghost model is created, also create a semi-transparent circle/cylinder at ground level showing the tower's attack range from `TowerConfig[towerType].range`
- The range indicator should be:
  - A flat cylinder (Part with Shape = Cylinder, rotated 90° on Z axis) OR a transparent sphere
  - Diameter = `range * 2` studs
  - Height/thickness = 0.1 studs (flat disc)
  - Transparency = 0.7
  - Color matches validity state (green = valid, red = invalid), same as ghost
  - Material = ForceField or Neon (visible but not distracting)
- Range indicator follows the ghost model during `updateGhostPosition()`
- Range indicator is destroyed with ghost on cancel/place
- When hovering, enemies within range could optionally get a subtle highlight (stretch goal, skip if complex)

**Acceptance Criteria:**
- Range circle visible during placement mode
- Circle size accurately reflects tower's configured range
- Circle color updates with validity state (green/red)
- Circle destroyed when placement ends
- Different tower types show different range sizes (Sparky=15, Rocky=8, Zippy=12)

---

## P2-3: Map Generator Script (Pond Temple Theme)

**File:** `tools/generate_map.luau` (NEW — runs in Studio command bar)

**Goal:** Generate a playable map with Will's pond temple theme. The script runs once in Studio's command bar to create the workspace objects.

**Generate:**

1. **Terrain:**
   - Flat grassy base (200x200 studs)
   - Central pond (water terrain, roughly circular, radius ~25 studs)
   - Small temple island in center of pond (the base to defend)
   - Hills/elevation around edges for visual interest
   - Use `workspace.Terrain:FillBlock()`, `FillBall()`, `FillCylinder()` with appropriate materials (Grass, Water, Rock, Sand)

2. **Enemy Path:**
   - Create a `Waypoints` folder in workspace
   - Generate 15-20 ordered waypoint Parts (named WP1, WP2, ... WPN)
   - Path should wind from map edge toward the temple, crossing terrain features
   - Two entry points that merge into one path near the temple (for variety)
   - Waypoints are small transparent anchored parts (2x1x2, Transparency=1 in-game, but visible in Studio via name labels)

3. **Tower Placement Zones:**
   - Create a `TowerZones` folder in workspace
   - 8-12 flat platform Parts along the path where towers can be placed
   - Each zone: 6x0.5x6 studs, Material=SmoothPlastic, slight color tint (e.g. light gray with green tint)
   - Zones should be at strategic positions: path corners, chokepoints, overlook positions

4. **Base (Temple):**
   - Create a `Base` model in workspace on the temple island
   - Simple structure: platform + 4 pillars + roof (assembled from Parts)
   - Add a `BaseHealth` BillboardGui showing health bar (or just a Part the BaseHealth system can reference)

5. **Spawn Points:**
   - Create `EnemySpawn1` and `EnemySpawn2` Parts at path entry points
   - These are where EnemyManager spawns enemies

6. **Folders:**
   - Ensure `workspace.Towers` folder exists (TowerManager expects it)
   - Ensure `workspace.Enemies` folder exists (EnemyManager expects it)
   - Ensure `workspace.Waypoints` folder exists with ordered waypoints

**Style notes:** Think Studio Ghibli meets Minecraft — organic shapes, warm colors, nature-heavy. Pond should feel alive (lily pad parts floating on water). Temple is ancient stone.

**Acceptance Criteria:**
- Running the script in Studio command bar creates a complete playable map
- Path waypoints are correctly ordered and traversable
- Tower zones are positioned at meaningful strategic locations
- Base/temple exists at the path endpoint
- All workspace folders expected by game systems exist
- Script is idempotent (cleans up previous generation before creating)

---

## P2-4: Tower Model Generator

**File:** `tools/generate_towers.luau` (NEW — runs in Studio command bar)

**Goal:** Generate 3D models for each tower type in TowerConfig, stored in ReplicatedStorage for the placement system to clone.

**For each tower (Sparky, Rocky, Zippy), generate a Model containing:**

1. **Base:** Cylinder or box, 3x1x3 studs (matches ghost model size)
2. **Body:** Axolotl-shaped character assembled from Parts:
   - Torso (rounded box)
   - Head with external gills (3 small Parts on each side — the iconic axolotl feature)
   - Eyes (two small sphere Parts, black with white pupils)
   - Tail (tapered wedge Part)
   - 4 stubby legs
3. **Tower-specific features:**
   - **Sparky:** Yellow color scheme, small antenna/tesla coil on back (cylinder + sphere), electric material accents (Neon)
   - **Rocky:** Brown/earth color scheme, rocky armor plates (extra Parts on torso), larger/stockier proportions
   - **Zippy:** Green/teal color scheme, sleeker/thinner proportions, speed lines decal or streamlined fins
4. **Turret/weapon:**
   - Sparky: Small barrel/cannon on top pointing forward
   - Rocky: Oversized fists (large sphere Parts as hands)
   - Zippy: Dual small dart launchers on sides
5. **Range indicator reference:** Add a NumberValue "Range" inside each model matching TowerConfig range

**Store models in:** `ReplicatedStorage.TowerModels.[TowerName]`

**Acceptance Criteria:**
- 3 distinct tower models generated in ReplicatedStorage
- Each model has a PrimaryPart set
- Models are visually distinct and recognizable at game-camera distance
- Each model is ≤30 Parts (performance)
- Script is idempotent

---

## P2-5: Enemy Model Generator

**File:** `tools/generate_enemies.luau` (NEW — runs in Studio command bar)

**Goal:** Generate 3D models for each enemy type in EnemyConfig.

**For each enemy, generate a Model:**

1. **Tadpole (Tier 1):** Tiny, simple — oval body + tail fin. Dark green. Small. Appears in swarms so keep Part count very low (≤8).
2. **Minnow (Tier 1):** Slightly larger fish shape — elongated body + dorsal fin + tail. Silver/blue. Fast-looking.
3. **Frog (Tier 2):** Squat body + large back legs + bulging eyes. Green with yellow belly. Larger than Tier 1.
4. **Crayfish (Tier 2):** Segmented body + two large claws (front) + tail fan. Red/orange. Armored look — use SmoothPlastic or Metal material.
5. **SnappingTurtle (Tier 3):** Large domed shell (hemisphere Part) + head + 4 legs + tail. Dark green/brown shell, lighter underbelly. Boss-sized.

**Each model should have:**
- PrimaryPart set (body/torso)
- Humanoid with appropriate WalkSpeed matching EnemyConfig speed (for animation)
- BillboardGui with health bar (can be basic: green Part that shrinks)
- Anchored = false, all parts welded to PrimaryPart

**Store in:** `ReplicatedStorage.EnemyModels.[EnemyName]`

**Acceptance Criteria:**
- 5 distinct enemy models, visually recognizable
- Each model ≤15 Parts
- Health bars visible above each enemy
- Models scaled appropriately relative to each other (Tadpole small, SnappingTurtle large)
- Script is idempotent

---

## P2-6: Basic Animation Generator

**File:** `tools/generate_animations.luau` (NEW — runs in Studio command bar)

**Goal:** Create basic KeyframeSequences for tower and enemy animations.

**Tower animations (per tower type):**
- **Idle:** Gentle bob up/down (0.5 stud amplitude, 2s loop). Gills wave slightly.
- **Attack:** Quick forward lunge or weapon recoil (0.3s), return to idle. Tower-specific:
  - Sparky: Antenna glows (change material to Neon briefly)
  - Rocky: Slam forward
  - Zippy: Quick double-tap motion

**Enemy animations:**
- **Walk:** Simple oscillating leg/fin movement synced to speed
- **Death:** Quick shrink + fade (Transparency tween to 1, Size tween to 0)

**Implementation approach:**
- Create AnimationController + Animator in each model
- Store KeyframeSequences in ReplicatedStorage.Animations.[ModelName].[AnimName]
- OR use TweenService-based animations in a shared AnimationHelper module (simpler, no animation editor needed)

**Recommendation:** Use a `src/shared/modules/AnimationHelper.luau` that runs tweens rather than Roblox KeyframeSequences — much simpler for procedurally generated models. The generator script just creates the module.

**Acceptance Criteria:**
- Towers have idle + attack animations
- Enemies have walk + death animations
- Animations don't interfere with gameplay logic
- Performance: animations use TweenService, not per-frame updates

---

## Integration Notes for Codex

After running all generator scripts:
1. The game should be fully playable: enemies spawn, walk the path, towers can be placed on zones, combat works
2. `TowerPlacement` should clone from `ReplicatedStorage.TowerModels` instead of creating placeholder Parts (update `createGhostModel` if needed)
3. `EnemyManager` should clone from `ReplicatedStorage.EnemyModels` instead of creating placeholder Parts (update spawn logic if needed)
4. Test: Run `rojo serve` in project root, connect Studio, press Play — full game loop should work
