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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("GameConfig"))
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))

-- Private state
local currentHealth = 100
local maxHealth = 100
local initialized = false

--[[
    Initialize BaseHealth
    Sets up event listeners and initial health
]]
function BaseHealth.init()
    if initialized then
        return
    end
    initialized = true

    maxHealth = GameConfig.baseHealth
    currentHealth = maxHealth

    EventBus.on("EnemyReachedEnd", function(_enemyId: string, damage: number)
        BaseHealth.takeDamage(damage)
    end)

    EventBus.fire("BaseHealthChanged", currentHealth, maxHealth)
end

--[[
    Handle enemy reaching end of path
    @param eventData: EnemyReachedEndEvent
]]
function BaseHealth.onEnemyReachedEnd(eventData)
    if type(eventData) == "number" then
        BaseHealth.takeDamage(eventData)
        return
    end
    if type(eventData) == "table" then
        local damage = eventData.damage or eventData.damageAmount
        if type(damage) == "number" then
            BaseHealth.takeDamage(damage)
        end
    end
end

--[[
    Apply damage to base
    @param amount: number
]]
function BaseHealth.takeDamage(amount: number)
    if amount <= 0 or currentHealth <= 0 then
        return
    end

    currentHealth = math.max(0, currentHealth - amount)
    EventBus.fire("BaseHealthChanged", currentHealth, maxHealth)

    if currentHealth <= 0 then
        EventBus.fire("GameOver")
    end
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
    if maxHealth <= 0 then
        return 0
    end
    return currentHealth / maxHealth
end

--[[
    Reset health (for new game)
]]
function BaseHealth.reset()
    currentHealth = maxHealth
    EventBus.fire("BaseHealthChanged", currentHealth, maxHealth)
end

--[[
    Check if base is destroyed
    @return boolean
]]
function BaseHealth.isDestroyed(): boolean
    return currentHealth <= 0
end

return BaseHealth
