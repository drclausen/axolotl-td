--[[
    TowerManager.luau
    Handles tower placement and management
    
    Responsibilities:
    - Listen for PlaceTower RemoteEvent from clients
    - Validate tower placement:
      * Player has enough money
      * Position is on valid ground
      * No overlap with existing towers
      * Tower type exists in TowerConfig
    - Deduct cost via EconomyManager
    - Create tower model at position
    - Register tower with CombatSystem
    - Handle tower upgrades (future)
    
    State:
    - placedTowers: Map<towerId, TowerData>
    - nextTowerId: number
    
    Events Listened:
    - RemoteEvent "PlaceTower" → {player, towerType, position}
    
    Events Fired:
    - "TowerPlaced" → {towerId, towerType, position, owner}
    - "TowerPlacementFailed" → {player, reason}
    
    Dependencies:
    - TowerConfig (stats, costs)
    - EconomyManager (money validation, spending)
    - CombatSystem (tower registration)
]]

local TowerManager = {}

-- Private state
local placedTowers = {}
local nextTowerId = 1

-- Constants
local MIN_TOWER_SPACING = 8 -- Minimum distance between towers

--[[
    Initialize TowerManager
    Sets up RemoteEvent listeners
]]
function TowerManager.init()
    -- TODO: Create or get RemoteEvent "PlaceTower" in ReplicatedStorage
    -- TODO: Connect OnServerEvent to handlePlaceTower
    -- TODO: Load TowerConfig
end

--[[
    Handle tower placement request from client
    @param player: Player
    @param towerType: string
    @param position: Vector3
]]
function TowerManager.handlePlaceTower(player: Player, towerType: string, position: Vector3)
    -- TODO: Validate tower type exists in TowerConfig
    -- TODO: Get tower stats and cost
    -- TODO: Check player can afford via EconomyManager
    -- TODO: Validate position (see validatePosition)
    -- TODO: If all valid:
    --         Spend money via EconomyManager
    --         Create tower model at position
    --         Register tower with CombatSystem
    --         Fire "TowerPlaced" event
    -- TODO: If invalid:
    --         Fire "TowerPlacementFailed" event with reason
end

--[[
    Validate tower placement position
    @param position: Vector3
    @param player: Player
    @return boolean, string - valid, reason
]]
function TowerManager.validatePosition(position: Vector3, player: Player): (boolean, string)
    -- TODO: Check if position is on valid ground (raycast down)
    -- TODO: Check if position is within build area (if defined)
    -- TODO: Check no overlap with existing towers (MIN_TOWER_SPACING)
    -- TODO: Return true, "" if valid
    -- TODO: Return false, "reason" if invalid
    return false, "Not implemented"
end

--[[
    Create tower model at position
    @param towerType: string
    @param position: Vector3
    @param owner: Player
    @return Model
]]
function TowerManager.createTowerModel(towerType: string, position: Vector3, owner: Player): Model
    -- TODO: Create a simple tower model (for now, just colored parts)
    -- TODO: Set model position
    -- TODO: Parent to workspace
    -- TODO: Add ObjectValue "Owner" = player
    -- TODO: Add StringValue "TowerType" = towerType
    -- TODO: Return model
    return nil
end

--[[
    Register a placed tower
    @param towerType: string
    @param position: Vector3
    @param owner: Player
    @param model: Model
    @return string - towerId
]]
function TowerManager.registerTower(towerType: string, position: Vector3, owner: Player, model: Model): string
    -- TODO: Generate unique towerId
    -- TODO: Create TowerData from TowerConfig stats
    -- TODO: Add to placedTowers
    -- TODO: Register with CombatSystem
    -- TODO: Fire "TowerPlaced" event
    -- TODO: Return towerId
    return ""
end

--[[
    Remove a tower (sold/destroyed)
    @param towerId: string
]]
function TowerManager.removeTower(towerId: string)
    -- TODO: Get tower data
    -- TODO: Unregister from CombatSystem
    -- TODO: Destroy model
    -- TODO: Remove from placedTowers
    -- TODO: Fire "TowerRemoved" event
end

--[[
    Get all placed towers
    @return table
]]
function TowerManager.getTowers(): {any}
    return placedTowers
end

--[[
    Get tower by id
    @param towerId: string
    @return TowerData?
]]
function TowerManager.getTower(towerId: string)
    return placedTowers[towerId]
end

--[[
    Clear all towers (for game reset)
]]
function TowerManager.clearAll()
    -- TODO: For each tower:
    --         Destroy model
    --         Unregister from CombatSystem
    -- TODO: Clear placedTowers table
    -- TODO: Reset nextTowerId
end

return TowerManager
