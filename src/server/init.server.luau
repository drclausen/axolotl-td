--[[
    init.server.luau
    Main server script for Axolotl Tower Defense
    
    Responsibilities:
    - Initialize all server systems
    - Create RemoteEvents for client-server communication
    - Wire up EventBus listeners to RemoteEvents
    - Handle player joining/leaving
    - Start game when first player joins
    - Track base health and game over state
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared modules to be available
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))
local GameConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("GameConfig"))
local WaveConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("WaveConfig"))

-- Require server systems
local PathManager = require(script:WaitForChild("systems"):WaitForChild("PathManager"))
local EnemyManager = require(script:WaitForChild("systems"):WaitForChild("EnemyManager"))
local WaveManager = require(script:WaitForChild("systems"):WaitForChild("WaveManager"))
local CombatSystem = require(script:WaitForChild("systems"):WaitForChild("CombatSystem"))
local EconomyManager = require(script:WaitForChild("systems"):WaitForChild("EconomyManager"))
local TowerManager = require(script:WaitForChild("systems"):WaitForChild("TowerManager"))

-- Create RemoteEvents for client-server communication
local function createRemote(name, className)
    className = className or "RemoteEvent"
    local remote = Instance.new(className)
    remote.Name = name
    remote.Parent = ReplicatedStorage
    return remote
end

local placeTowerEvent = createRemote("PlaceTower")
local updateBalanceEvent = createRemote("UpdateBalance")
local updateWaveEvent = createRemote("UpdateWave")
local updateBaseHealthEvent = createRemote("UpdateBaseHealth")
local towerPlacementResultEvent = createRemote("TowerPlacementResult")
local gameOverEvent = createRemote("GameOver")
local victoryEvent = createRemote("Victory")

-- Create SelectedTower StringValue for client tower selection
local selectedTower = Instance.new("StringValue")
selectedTower.Name = "SelectedTower"
selectedTower.Value = ""
selectedTower.Parent = ReplicatedStorage

-- Initialize all systems
print("[AxolotlTD] Initializing systems...")
PathManager.init()
EnemyManager.init()
WaveManager.init()
CombatSystem.init()
EconomyManager.init()
TowerManager.init()

-- BaseHealth setup
local baseHP = GameConfig.baseHealth
local gameOver = false
local totalWaves = #WaveConfig

print("[AxolotlTD] Total waves:", totalWaves)

-- Wire up events

-- Tower placement from client
placeTowerEvent.OnServerEvent:Connect(function(player, towerType, position)
    if gameOver then return end
    local success, result = TowerManager.placeTower(player, towerType, position)
    towerPlacementResultEvent:FireClient(player, success, result)
    if success then
        -- Update balance for this player
        updateBalanceEvent:FireClient(player, EconomyManager.getBalance(player))
    end
end)

-- Balance changes → client
EventBus.on("BalanceChanged", function(player, amount)
    updateBalanceEvent:FireClient(player, amount)
end)

-- Wave updates → all clients
EventBus.on("WaveStarted", function(waveNumber)
    updateWaveEvent:FireAllClients(waveNumber, totalWaves, "Active")
end)

EventBus.on("WaveCompleted", function(waveNumber)
    updateWaveEvent:FireAllClients(waveNumber, totalWaves, "Preparing")
end)

-- Enemy reaches end → damage base
EventBus.on("EnemyReachedEnd", function(enemyId, damage)
    if gameOver then return end
    baseHP -= damage
    baseHP = math.max(0, baseHP)
    updateBaseHealthEvent:FireAllClients(baseHP, GameConfig.baseHealth)
    
    if baseHP <= 0 then
        gameOver = true
        local currentWave = WaveManager.getCurrentWave()
        gameOverEvent:FireAllClients(currentWave)
        print("[AxolotlTD] GAME OVER at wave " .. currentWave)
    end
end)

-- Victory
EventBus.on("AllWavesComplete", function()
    if gameOver then return end
    gameOver = true
    victoryEvent:FireAllClients()
    print("[AxolotlTD] VICTORY!")
end)

-- Send initial state to joining players
Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- let client load
    updateBalanceEvent:FireClient(player, EconomyManager.getBalance(player))
    updateBaseHealthEvent:FireClient(player, baseHP, GameConfig.baseHealth)
    local currentWave = WaveManager.getCurrentWave()
    local state = WaveManager.getState()
    -- Convert state to display format
    local displayState = "Preparing"
    if state == "active" then
        displayState = "Active"
    elseif state == "complete" then
        displayState = "Complete"
    end
    updateWaveEvent:FireClient(player, currentWave, totalWaves, displayState)
end)

-- Start the game when first player joins (or after a short delay)
local gameStarted = false
Players.PlayerAdded:Connect(function(player)
    if not gameStarted then
        gameStarted = true
        task.wait(3) -- give player time to load
        print("[AxolotlTD] Starting game!")
        updateBaseHealthEvent:FireAllClients(baseHP, GameConfig.baseHealth)
        WaveManager.startGame()
    end
end)

print("[AxolotlTD] Server ready! Waiting for players...")
