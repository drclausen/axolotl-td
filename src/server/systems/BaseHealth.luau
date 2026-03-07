--[[
    BaseHealth.luau
    Manages the base health pool
    
    Responsibilities:
    - Track base HP pool (starts at 100)
    - Receive damage when enemies reach end of path
    - Fire "GameOver" event when HP reaches 0
    - Broadcast HP changes to clients for UI
    
    State:
    - currentHealth: number
    - maxHealth: number
    
    Methods:
    - takeDamage(amount)
    - getHealth(): number
    - getMaxHealth(): number
    
    Events Fired:
    - "BaseHealthChanged" → {newHealth, maxHealth}
    - "GameOver"
    
    Dependencies:
    - GameConfig (initial health)
    - EventBus (health updates, game over)
]]

local BaseHealth = {}

-- Private state
local currentHealth = 100
local maxHealth = 100

--[[
    Initialize BaseHealth
    Sets up event listeners and initial health
]]
function BaseHealth.init()
    -- TODO: Load maxHealth from GameConfig
    -- TODO: Set currentHealth to maxHealth
    -- TODO: Subscribe to "EnemyReachedEnd" event
    -- TODO: Fire initial "BaseHealthChanged" event to clients
end

--[[
    Handle enemy reaching end of path
    @param eventData: EnemyReachedEndEvent
]]
function BaseHealth.onEnemyReachedEnd(eventData)
    -- TODO: Extract damage amount from eventData
    -- TODO: Call takeDamage(amount)
end

--[[
    Apply damage to base
    @param amount: number
]]
function BaseHealth.takeDamage(amount: number)
    -- TODO: Reduce currentHealth by amount (min 0)
    -- TODO: Fire "BaseHealthChanged" event with {newHealth, maxHealth}
    -- TODO: If currentHealth <= 0:
    --         Fire "GameOver" event
    --         Trigger game over logic
end

--[[
    Get current health
    @return number
]]
function BaseHealth.getHealth(): number
    return currentHealth
end

--[[
    Get max health
    @return number
]]
function BaseHealth.getMaxHealth(): number
    return maxHealth
end

--[[
    Get health percentage
    @return number - 0 to 1
]]
function BaseHealth.getHealthPercent(): number
    -- TODO: Return currentHealth / maxHealth
    return 1
end

--[[
    Reset health (for new game)
]]
function BaseHealth.reset()
    -- TODO: Set currentHealth to maxHealth
    -- TODO: Fire "BaseHealthChanged" event
end

--[[
    Check if base is destroyed
    @return boolean
]]
function BaseHealth.isDestroyed(): boolean
    return currentHealth <= 0
end

return BaseHealth
