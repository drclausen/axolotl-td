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
    - waveState: "preparing" | "active" | "complete"
    - enemiesAlive: number
    - prepTimer: number
    
    Dependencies:
    - EnemyManager (for spawning)
    - WaveConfig (data)
    - EventBus (notifications)
]]

local WaveManager = {}

-- Private state
local currentWave = 0
local waveState = "preparing"
local enemiesAlive = 0
local prepTimer = 0
local totalWaves = 10

--[[
    Initialize WaveManager
    Sets up event listeners and initial state
]]
function WaveManager.init()
    -- TODO: Initialize wave state
    -- TODO: Subscribe to "EnemyDied" and "EnemyReachedEnd" events
    -- TODO: Load WaveConfig
    -- TODO: Start prep timer for wave 1
end

--[[
    Start a specific wave
    @param waveNumber: number - Wave to start (1-10)
]]
function WaveManager.startWave(waveNumber: number)
    -- TODO: Validate wave number
    -- TODO: Read WaveConfig[waveNumber]
    -- TODO: Set waveState to "active"
    -- TODO: Fire "WaveStarted" event with wave number
    -- TODO: Spawn enemies at configured intervals
    --       For each enemy type in wave:
    --         Spawn `count` enemies with `interval` seconds between each
    -- TODO: Track total enemies spawned for this wave
end

--[[
    Handle enemy death
    @param enemyId: string - ID of the enemy that died
]]
function WaveManager.onEnemyDied(enemyId: string)
    -- TODO: Decrement enemiesAlive count
    -- TODO: If enemiesAlive == 0:
    --         Set waveState to "complete"
    --         Fire "WaveCompleted" event with wave number
    --         If currentWave < totalWaves:
    --           Start prep timer for next wave
    --         Else:
    --           Fire "AllWavesComplete" event
end

--[[
    Handle enemy reaching end of path
    @param enemyId: string - ID of the enemy
]]
function WaveManager.onEnemyReachedEnd(enemyId: string)
    -- TODO: Decrement enemiesAlive count (enemy removed, not killed)
    -- TODO: Check if wave complete (same logic as onEnemyDied)
end

--[[
    Update loop (called every frame)
    @param dt: number - Delta time in seconds
]]
function WaveManager.update(dt: number)
    -- TODO: If waveState == "preparing":
    --         Decrement prepTimer by dt
    --         If prepTimer <= 0:
    --           Increment currentWave
    --           Start next wave
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
    @return string - "preparing" | "active" | "complete"
]]
function WaveManager.getWaveState(): string
    return waveState
end

--[[
    Get enemies alive count
    @return number
]]
function WaveManager.getEnemiesAlive(): number
    return enemiesAlive
end

return WaveManager
