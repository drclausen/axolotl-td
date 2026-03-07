--[[
    init.server.luau
    Main server entry point - wires all systems together
    
    Responsibilities:
    - Initialize all game systems in correct order
    - Create RemoteEvents for client-server communication
    - Start game loop (prep phase → waves → game over)
    - Handle base HP reaching 0 (game over)
    - Handle all waves complete (victory)
    
    System initialization order:
    1. EventBus (needed by all systems)
    2. PathManager (needed by EnemyManager)
    3. BaseHealth (standalone)
    4. EnemyManager (needed by WaveManager)
    5. EconomyManager (needed by TowerManager)
    6. CombatSystem (needed by TowerManager)
    7. TowerManager (depends on multiple systems)
    8. WaveManager (orchestrates gameplay)
    
    Game flow:
    1. Wait for players
    2. Prep phase (10 seconds)
    3. Wave 1 → Wave 10
    4. Victory or Game Over
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Systems
local EventBus = require(ReplicatedStorage.modules.EventBus)
local PathManager = require(ServerScriptService.systems.PathManager)
local BaseHealth = require(ServerScriptService.systems.BaseHealth)
local EnemyManager = require(ServerScriptService.systems.EnemyManager)
local EconomyManager = require(ServerScriptService.systems.EconomyManager)
local CombatSystem = require(ServerScriptService.systems.CombatSystem)
local TowerManager = require(ServerScriptService.systems.TowerManager)
local WaveManager = require(ServerScriptService.systems.WaveManager)

-- Game state
local gameState = "Lobby" -- Lobby | Preparing | Active | Complete | GameOver

--[[
    Initialize all game systems
]]
local function initializeSystems()
    print("Initializing Axolotl Tower Defense...")
    
    -- TODO: Initialize EventBus
    -- TODO: Initialize PathManager
    -- TODO: Initialize BaseHealth
    -- TODO: Initialize EnemyManager
    -- TODO: Initialize EconomyManager
    -- TODO: Initialize CombatSystem
    -- TODO: Initialize TowerManager
    -- TODO: Initialize WaveManager
    
    print("All systems initialized!")
end

--[[
    Create RemoteEvents for client-server communication
]]
local function createRemoteEvents()
    -- TODO: Create folder in ReplicatedStorage for RemoteEvents
    -- TODO: Create RemoteEvent "PlaceTower"
    -- TODO: Create RemoteEvent "BalanceChanged"
    -- TODO: Create RemoteEvent "WaveStarted"
    -- TODO: Create RemoteEvent "WaveCompleted"
    -- TODO: Create RemoteEvent "BaseHealthChanged"
    -- TODO: Create RemoteEvent "TowerPlaced"
    -- TODO: Create RemoteEvent "TowerPlacementFailed"
    -- TODO: Create RemoteEvent "GameOver"
    -- TODO: Create RemoteEvent "Victory"
    
    print("RemoteEvents created!")
end

--[[
    Start the game loop
]]
local function startGame()
    -- TODO: Set gameState to "Preparing"
    -- TODO: Fire "GameStarted" event
    -- TODO: WaveManager will handle wave progression
    
    print("Game started!")
end

--[[
    Handle game over
]]
local function onGameOver()
    -- TODO: Set gameState to "GameOver"
    -- TODO: Stop all systems (WaveManager, CombatSystem)
    -- TODO: Fire RemoteEvent "GameOver" to all clients
    -- TODO: Display final stats (wave reached, enemies killed, etc.)
    
    print("Game Over!")
end

--[[
    Handle victory
]]
local function onVictory()
    -- TODO: Set gameState to "Complete"
    -- TODO: Stop all systems
    -- TODO: Fire RemoteEvent "Victory" to all clients
    -- TODO: Display victory screen with stats
    
    print("Victory!")
end

--[[
    Main game loop (Heartbeat)
]]
local function gameLoop(dt: number)
    -- TODO: Update WaveManager
    -- TODO: Update CombatSystem
    -- TODO: Update EnemyManager
    
    -- Game state checks happen via EventBus events
end

--[[
    Main initialization
]]
local function main()
    -- Create remote events first
    createRemoteEvents()
    
    -- Initialize all systems
    initializeSystems()
    
    -- Subscribe to game events
    EventBus.on("GameOver", onGameOver)
    EventBus.on("AllWavesComplete", onVictory)
    
    -- Connect game loop
    RunService.Heartbeat:Connect(gameLoop)
    
    -- Wait for players, then start
    -- TODO: For MVP, start immediately
    -- TODO: For full version, wait for player count or ready-up
    wait(3) -- Brief delay for initialization
    startGame()
end

-- Run the game!
main()
