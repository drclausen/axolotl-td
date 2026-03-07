# Getting Started — Axolotl Tower Defense

A step-by-step guide for DC + Will to get the game running in Roblox Studio.

## Prerequisites

1. **Roblox Studio** installed (Will probably has this already)
2. **Rojo** — syncs our code files into Studio

## Step 1: Install Rojo

### Rojo CLI (on Mac)
```bash
# If you have Aftman (Roblox toolchain manager):
aftman add rojo-rbx/rojo

# Or install directly with Cargo:
cargo install rojo

# Or download from: https://github.com/rojo-rbx/rojo/releases
```

### Rojo Plugin (in Roblox Studio)
1. Open Roblox Studio
2. Go to **Plugins** → **Plugin Manager** → search "Rojo"
3. Install the **Rojo** plugin by LPGhatguy
4. You'll see a Rojo button in the Plugins toolbar

## Step 2: Start Rojo Server

Open a terminal:
```bash
cd /Users/drclausen/axolotl-td
rojo serve
```

You should see:
```
Rojo server listening on port 34872
```

Leave this running.

## Step 3: Connect Studio to Rojo

1. Open Roblox Studio → create a new **Baseplate** place
2. Click the **Rojo** plugin button in the toolbar
3. Click **Connect** (it finds the local server automatically)
4. You should see "Connected" — scripts will sync in automatically

All the `.luau` files from `src/` are now live in Studio. Any changes you make to files on disk update in Studio instantly.

## Step 4: Build the Map (Will's Part! 🎨)

This is the creative work. The game needs:

### A. Create the Path
The path is where enemies walk from spawn to your base.

1. **Create waypoint parts:**
   - Insert → Part → create a small Part (2x1x2, any color)
   - Name it "Waypoint"
   - Add a **NumberValue** child (right-click → Insert Object → NumberValue)
   - Name the NumberValue "Order" and set Value = 1
   - This is the enemy spawn point

2. **Repeat for each turn in the path:**
   - Duplicate the part, move it to the next position
   - Set Order = 2, 3, 4, etc.
   - 8-12 waypoints makes a good path

3. **Tag each waypoint:**
   - Select a waypoint part
   - In the Properties panel, find **Tags** (or use the Tag Editor plugin)
   - Add the tag: `Waypoint`
   - Do this for ALL waypoint parts

4. **Suggested path layout:**
   ```
   [Spawn] → → → ↓
                   ↓
         ↑ ← ← ← ↓
         ↑
         ↑ → → → [Base/Temple]
   ```
   A winding path gives players more spots to place towers.

### B. Build the Temple (Base)
- Create a cool-looking structure at the LAST waypoint
- This is what the axolotls are defending!
- Will can go wild here — it's the centerpiece

### C. Decorate
- Terrain: Use the Terrain tools to create water, grass, ponds
- Props: Lily pads, rocks, trees around the path
- Lighting: Underwater/pond vibes (bluish ambient light)

### D. Create Folders
In the Explorer panel, create these folders in Workspace:
- **Towers** (empty — towers get placed here during gameplay)
- **Enemies** (empty — enemies spawn here during gameplay)

## Step 5: Test It!

1. Make sure Rojo is connected (green indicator)
2. Click **Play** in Studio (or F5)
3. You should see:
   - HUD appears (money, wave counter, HP bar, tower shop)
   - After 3 seconds, Wave 1 starts
   - Tadpoles spawn at Waypoint 1 and walk the path
   - Click a tower button → click the ground to place it
   - Towers should shoot at enemies!

## Troubleshooting

**"No waypoints" warning in Output:**
- Make sure all waypoint parts have the `Waypoint` tag
- Make sure each has a NumberValue child named "Order"

**Enemies not moving:**
- Check waypoints are in order (1, 2, 3...)
- Check the Output panel for errors

**Can't place towers:**
- Make sure you have enough money (start with $200)
- Click a tower button first, THEN click the ground

**Scripts not showing up:**
- Is Rojo server running? (`rojo serve` in terminal)
- Is the Rojo plugin connected in Studio?

## What Will Can Customize

These are safe for Will to experiment with (no coding needed):

- **Map layout** — waypoint positions, terrain, decorations
- **Tower/enemy colors** — edit the Color3 values in config files
- **Game balance** — edit numbers in `src/shared/config/`:
  - `GameConfig.luau` — starting money, base HP, prep time
  - `TowerConfig.luau` — tower costs, damage, range
  - `EnemyConfig.luau` — enemy health, speed, rewards
  - `WaveConfig.luau` — which enemies per wave, how many

## Project Structure (for reference)
```
axolotl-td/
├── default.project.json    ← Rojo project config
├── src/
│   ├── server/             ← Runs on Roblox server
│   │   ├── init.server.luau  ← Main game loop
│   │   └── systems/        ← Game systems
│   ├── shared/             ← Shared between server + client
│   │   ├── config/         ← All game data (tweak these!)
│   │   ├── modules/        ← EventBus
│   │   └── types/          ← Type definitions
│   └── client/             ← Runs on player's machine
│       ├── gui/            ← UI scripts
│       └── scripts/        ← Input handling
└── docs/                   ← Architecture + task specs
```

## Next Session Ideas
Once the basic game works:
- More tower types (Bubbles healer, Mystic slow field, Gadget decoy)
- Tower upgrades (click tower → upgrade button)
- Boss enemies every 5 waves
- Sound effects
- Better tower/enemy models (Will can build these in Studio!)
- Multiplayer testing

---

*Built by DC + Will + Clawd 🦔🪓🎮*
