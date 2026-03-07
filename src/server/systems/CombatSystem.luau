--[[
    CombatSystem.luau
    Handles tower targeting, firing, and damage application
    
    Responsibilities:
    - Each tower finds nearest enemy in range every tick
    - Apply damage based on tower stats and fire rate cooldown
    - Create visual projectiles (simple part tween from tower to enemy)
    - Handle enemy death → fire "EnemyKilled" event with enemy data
    - Track tower cooldowns
    
    State:
    - towers: Map<towerId, TowerData>
    - towerCooldowns: Map<towerId, number>
    
    Dependencies:
    - TowerConfig (stats)
    - EnemyManager (enemy positions, health)
    - EventBus (death notifications)
]]

local CombatSystem = {}

-- Private state
local towers = {}
local towerCooldowns = {}

--[[
    Initialize CombatSystem
    Sets up Heartbeat connection for combat ticks
]]
function CombatSystem.init()
    -- TODO: Connect to RunService.Heartbeat for combat loop
    -- TODO: Subscribe to "TowerPlaced" event to register new towers
    -- TODO: Subscribe to "TowerRemoved" event to unregister towers
end

--[[
    Register a tower for combat
    @param towerData: TowerData - Tower to register
]]
function CombatSystem.registerTower(towerData)
    -- TODO: Add tower to towers table
    -- TODO: Initialize cooldown to 0
end

--[[
    Unregister a tower (sold/destroyed)
    @param towerId: string - ID of tower to remove
]]
function CombatSystem.unregisterTower(towerId: string)
    -- TODO: Remove tower from towers table
    -- TODO: Remove cooldown entry
end

--[[
    Combat tick (called every Heartbeat)
    @param dt: number - Delta time in seconds
]]
function CombatSystem.tick(dt: number)
    -- TODO: For each tower:
    --   1. Update cooldown (subtract dt)
    --   2. If cooldown <= 0:
    --      a. Find nearest enemy in range
    --      b. If enemy found:
    --         - Create projectile visual (part tween)
    --         - Apply damage to enemy
    --         - Reset cooldown based on fireRate (1 / fireRate)
    --      c. If enemy health <= 0:
    --         - Fire "EnemyKilled" event with enemy data
    --         - Remove enemy from world
end

--[[
    Find nearest enemy to a tower within range
    @param towerPosition: Vector3
    @param range: number
    @return EnemyData? - Nearest enemy or nil
]]
function CombatSystem.findNearestEnemy(towerPosition: Vector3, range: number)
    -- TODO: Get all alive enemies from EnemyManager
    -- TODO: Filter enemies within range
    -- TODO: Return enemy with smallest distance
    -- TODO: Return nil if no enemies in range
end

--[[
    Create projectile visual from tower to enemy
    @param startPos: Vector3
    @param endPos: Vector3
]]
function CombatSystem.createProjectile(startPos: Vector3, endPos: Vector3)
    -- TODO: Create a Part for the projectile
    -- TODO: Position at startPos
    -- TODO: Tween to endPos over ~0.2 seconds
    -- TODO: Destroy part when tween completes
end

--[[
    Apply damage to an enemy
    @param enemyData: EnemyData
    @param damage: number
    @return boolean - true if enemy died
]]
function CombatSystem.damageEnemy(enemyData, damage: number): boolean
    -- TODO: Reduce enemy currentHealth by damage
    -- TODO: Update enemy health display (if exists)
    -- TODO: Return true if currentHealth <= 0
end

--[[
    Get all registered towers
    @return table
]]
function CombatSystem.getTowers(): {any}
    return towers
end

return CombatSystem
