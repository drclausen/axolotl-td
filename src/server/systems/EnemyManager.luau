--[[
    EnemyManager.luau
    Handles enemy spawning, movement, and lifecycle
    
    Responsibilities:
    - Spawn enemy models at first waypoint
    - Move enemies along waypoints using Heartbeat (lerp by speed * dt)
    - Track all alive enemies in a table
    - Handle enemy reaching end of path → deal damage to base
    - Handle enemy death → cleanup, notify systems
    - Apply difficulty multipliers to enemy stats
    
    State:
    - aliveEnemies: Map<enemyId, EnemyData>
    - enemyModels: Map<enemyId, Model>
    - nextEnemyId: number
    
    Events Fired:
    - "EnemyReachedEnd" → {enemyId, damageAmount}
    - "EnemyDied" → {enemyId, enemyType, rewardAmount}
    
    Dependencies:
    - PathManager (waypoint data)
    - EnemyConfig (stats)
    - GameConfig (difficulty multipliers)
]]

local EnemyManager = {}

-- Private state
local aliveEnemies = {}
local enemyModels = {}
local nextEnemyId = 1

--[[
    Initialize EnemyManager
    Sets up Heartbeat connection for enemy movement
]]
function EnemyManager.init()
    -- TODO: Connect to RunService.Heartbeat for movement loop
    -- TODO: Load EnemyConfig
    -- TODO: Load GameConfig for difficulty modifiers
    -- TODO: Get PathManager reference
end

--[[
    Spawn an enemy
    @param enemyType: string - Type from EnemyConfig
    @return string - enemyId
]]
function EnemyManager.spawnEnemy(enemyType: string): string
    -- TODO: Generate unique enemyId
    -- TODO: Get stats from EnemyConfig[enemyType]
    -- TODO: Apply difficulty multipliers (health, speed)
    -- TODO: Create enemy model at first waypoint
    -- TODO: Initialize EnemyData:
    --         id, type, currentHealth, maxHealth, speed, damage, reward,
    --         position, waypointIndex = 1, model
    -- TODO: Add to aliveEnemies and enemyModels
    -- TODO: Return enemyId
    return ""
end

--[[
    Movement tick (called every Heartbeat)
    @param dt: number - Delta time in seconds
]]
function EnemyManager.tick(dt: number)
    -- TODO: For each alive enemy:
    --   1. Get current waypoint and next waypoint
    --   2. Calculate direction to next waypoint
    --   3. Move enemy toward next waypoint (speed * dt)
    --   4. If reached next waypoint:
    --      a. Increment waypointIndex
    --      b. If at end of path:
    --         - Fire "EnemyReachedEnd" event with damage
    --         - Remove enemy from game
    --   5. Update model position
end

--[[
    Remove an enemy from the game
    @param enemyId: string
    @param reachedEnd: boolean - true if enemy reached end, false if killed
]]
function EnemyManager.removeEnemy(enemyId: string, reachedEnd: boolean)
    -- TODO: Get enemy data
    -- TODO: If reachedEnd:
    --         Fire "EnemyReachedEnd" event with {enemyId, damage}
    --       Else:
    --         Fire "EnemyDied" event with {enemyId, type, reward}
    -- TODO: Destroy enemy model
    -- TODO: Remove from aliveEnemies and enemyModels
end

--[[
    Damage an enemy
    @param enemyId: string
    @param damage: number
    @return boolean - true if enemy died
]]
function EnemyManager.damageEnemy(enemyId: string, damage: number): boolean
    -- TODO: Get enemy data
    -- TODO: Reduce currentHealth by damage
    -- TODO: Update health display (if exists)
    -- TODO: If currentHealth <= 0:
    --         Call removeEnemy(enemyId, false)
    --         Return true
    -- TODO: Return false
    return false
end

--[[
    Get an enemy's data
    @param enemyId: string
    @return EnemyData?
]]
function EnemyManager.getEnemy(enemyId: string)
    -- TODO: Return aliveEnemies[enemyId]
    return nil
end

--[[
    Get all alive enemies
    @return table
]]
function EnemyManager.getAllEnemies(): {any}
    return aliveEnemies
end

--[[
    Get enemies within range of a position
    @param position: Vector3
    @param range: number
    @return table - array of EnemyData
]]
function EnemyManager.getEnemiesInRange(position: Vector3, range: number): {any}
    -- TODO: Filter aliveEnemies by distance to position
    -- TODO: Return array of enemies within range
    return {}
end

--[[
    Clear all enemies (for game reset)
]]
function EnemyManager.clearAll()
    -- TODO: Remove all enemy models
    -- TODO: Clear aliveEnemies and enemyModels tables
    -- TODO: Reset nextEnemyId
end

return EnemyManager
