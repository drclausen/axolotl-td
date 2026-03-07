--[[
    WaveManager.luau
    Handles wave spawning, progression, and enemy lifecycle
    
    Responsibilities:
    - Read WaveConfig to determine wave composition
    - Spawn enemies at intervals along the path
    - Track current wave number and enemies alive
    - Trigger next wave when all enemies dead + prep time elapsed
    - Fire events: "WaveStarted", "WaveCompleted", "AllWavesComplete"
    
    State:
    - currentWave: number
    - waveState: "preparing" | "active" | "complete" | "gameover"
    - enemiesAlive: number
    - enemiesSpawned: number
    - enemiesTotal: number (for current wave)
    
    Dependencies:
    - EnemyManager (for spawning)
    - WaveConfig (data)
    - GameConfig (wavePrepTime)
    - EventBus (notifications)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyManager = require(script.Parent:WaitForChild("EnemyManager"))
local WaveConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("WaveConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("GameConfig"))
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))

local WaveManager = {}

-- Private state
local currentWave = 0
local waveState = "preparing" -- "preparing" | "active" | "complete" | "gameover"
local enemiesAlive = 0
local enemiesSpawned = 0
local enemiesTotal = 0
local totalWaves = #WaveConfig

--[[
    Initialize WaveManager
    Sets up event listeners and initial state
]]
function WaveManager.init()
    -- Subscribe to enemy lifecycle events
    EventBus.on("EnemyKilled", function()
        WaveManager._onEnemyRemoved()
    end)
    
    EventBus.on("EnemyReachedEnd", function()
        WaveManager._onEnemyRemoved()
    end)
    
    print("[WaveManager] Initialized with " .. totalWaves .. " waves")
end

--[[
    Start the game (wave 1 after prep time)
]]
function WaveManager.startGame()
    waveState = "preparing"
    currentWave = 0
    
    print("[WaveManager] Starting game in " .. GameConfig.wavePrepTime .. " seconds")
    
    -- Start wave 1 after prep time
    task.spawn(function()
        task.wait(GameConfig.wavePrepTime)
        WaveManager._startWave(1)
    end)
end

--[[
    Internal: Start a specific wave
    @param waveNumber: number - Wave to start (1-10)
]]
function WaveManager._startWave(waveNumber: number)
    if waveNumber < 1 or waveNumber > totalWaves then
        warn("[WaveManager] Invalid wave number: " .. waveNumber)
        return
    end
    
    currentWave = waveNumber
    waveState = "active"
    enemiesSpawned = 0
    enemiesTotal = 0
    
    local waveData = WaveConfig[waveNumber]
    if not waveData then
        warn("[WaveManager] No config for wave " .. waveNumber)
        return
    end
    
    -- Calculate total enemies for this wave
    for _, enemyGroup in ipairs(waveData.enemies) do
        enemiesTotal += enemyGroup.count
    end
    
    print("[WaveManager] Starting Wave " .. waveNumber .. " (" .. enemiesTotal .. " enemies)")
    EventBus.fire("WaveStarted", waveNumber)
    
    -- Spawn enemies for this wave
    task.spawn(function()
        for _, enemyGroup in ipairs(waveData.enemies) do
            WaveManager._spawnEnemyGroup(enemyGroup.type, enemyGroup.count, enemyGroup.interval)
        end
    end)
end

--[[
    Internal: Spawn a group of enemies at intervals
    @param enemyType: string - Type of enemy to spawn
    @param count: number - How many to spawn
    @param interval: number - Seconds between spawns
]]
function WaveManager._spawnEnemyGroup(enemyType: string, count: number, interval: number)
    for i = 1, count do
        local id = EnemyManager.spawn(enemyType)
        if id ~= "" then
            enemiesSpawned += 1
            enemiesAlive += 1
        else
            warn("[WaveManager] Failed to spawn " .. enemyType)
        end
        
        -- Wait between spawns (except after last one)
        if i < count then
            task.wait(interval)
        end
    end
end

--[[
    Internal: Handle enemy removed from play (killed or reached end)
]]
function WaveManager._onEnemyRemoved()
    enemiesAlive = math.max(0, enemiesAlive - 1)
    
    -- Check if wave is complete
    if waveState == "active" and enemiesAlive == 0 and enemiesSpawned >= enemiesTotal then
        waveState = "complete"
        
        print("[WaveManager] Wave " .. currentWave .. " completed")
        EventBus.fire("WaveCompleted", currentWave)
        
        -- Check if all waves are complete
        if currentWave >= totalWaves then
            waveState = "gameover"
            print("[WaveManager] All waves complete!")
            EventBus.fire("AllWavesComplete")
        else
            -- Start prep for next wave
            waveState = "preparing"
            local nextWave = currentWave + 1
            
            print("[WaveManager] Next wave in " .. GameConfig.wavePrepTime .. " seconds")
            
            task.spawn(function()
                task.wait(GameConfig.wavePrepTime)
                WaveManager._startWave(nextWave)
            end)
        end
    end
end

--[[
    Get current wave number
    @return number
]]
function WaveManager.getCurrentWave(): number
    return currentWave
end

--[[
    Get current wave state
    @return string - "preparing" | "active" | "complete" | "gameover"
]]
function WaveManager.getState(): string
    return waveState
end

--[[
    Get wave info
    @return table - {
        currentWave: number,
        state: string,
        enemiesAlive: number,
        enemiesSpawned: number,
        enemiesTotal: number,
        totalWaves: number
    }
]]
function WaveManager.getWaveInfo()
    return {
        currentWave = currentWave,
        state = waveState,
        enemiesAlive = enemiesAlive,
        enemiesSpawned = enemiesSpawned,
        enemiesTotal = enemiesTotal,
        totalWaves = totalWaves,
    }
end

return WaveManager
