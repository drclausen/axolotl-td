--[[
    EconomyManager.luau
    Handles player currency and rewards
    
    Responsibilities:
    - Track per-player currency balance
    - Award money on enemy kill (amount based on enemy tier/reward)
    - Deduct money on tower purchase/upgrade
    - Validate player can afford actions
    - Broadcast balance updates to clients
    
    State:
    - playerBalances: Map<Player, number>
    
    Methods:
    - canAfford(player, amount): boolean
    - spend(player, amount): boolean
    - award(player, amount)
    - getBalance(player): number
    
    Events Fired:
    - "BalanceChanged" → {player, newBalance}
    
    Dependencies:
    - GameConfig (starting money)
    - EventBus (kill notifications, balance updates)
]]

local EconomyManager = {}

-- Private state
local playerBalances = {}

--[[
    Initialize EconomyManager
    Sets up event listeners for enemy kills
]]
function EconomyManager.init()
    -- TODO: Subscribe to "EnemyKilled" event
    -- TODO: Subscribe to Players.PlayerAdded to initialize balance
    -- TODO: Subscribe to Players.PlayerRemoving to cleanup balance
    -- TODO: Load GameConfig for starting money
end

--[[
    Initialize a player's balance
    @param player: Player
]]
function EconomyManager.initPlayer(player: Player)
    -- TODO: Set player balance to GameConfig.startingMoney
    -- TODO: Fire "BalanceChanged" event to sync with client
end

--[[
    Remove a player's balance entry
    @param player: Player
]]
function EconomyManager.removePlayer(player: Player)
    -- TODO: Remove player from playerBalances
end

--[[
    Check if player can afford an amount
    @param player: Player
    @param amount: number
    @return boolean
]]
function EconomyManager.canAfford(player: Player, amount: number): boolean
    -- TODO: Return true if player balance >= amount
    return false
end

--[[
    Deduct money from player balance
    @param player: Player
    @param amount: number
    @return boolean - true if successful, false if can't afford
]]
function EconomyManager.spend(player: Player, amount: number): boolean
    -- TODO: Check if player can afford
    -- TODO: If yes:
    --         Deduct amount from balance
    --         Fire "BalanceChanged" event
    --         Return true
    -- TODO: If no, return false
    return false
end

--[[
    Award money to player
    @param player: Player
    @param amount: number
]]
function EconomyManager.award(player: Player, amount: number)
    -- TODO: Add amount to player balance
    -- TODO: Fire "BalanceChanged" event
end

--[[
    Award money to all players (for cooperative gameplay)
    @param amount: number
]]
function EconomyManager.awardAll(amount: number)
    -- TODO: For each player in game:
    --         Call award(player, amount)
end

--[[
    Get player's current balance
    @param player: Player
    @return number
]]
function EconomyManager.getBalance(player: Player): number
    -- TODO: Return player balance or 0 if not found
    return 0
end

--[[
    Handle enemy killed event
    Called by EventBus when "EnemyKilled" fires
    @param eventData: EnemyKilledEvent
]]
function EconomyManager.onEnemyKilled(eventData)
    -- TODO: Extract reward amount from eventData
    -- TODO: Award money to all players (cooperative mode)
    --       OR award to player who killed it (competitive mode)
    -- TODO: For MVP, use awardAll(reward)
end

--[[
    Get all player balances (for debugging)
    @return table
]]
function EconomyManager.getAllBalances(): {[Player]: number}
    return playerBalances
end

return EconomyManager
