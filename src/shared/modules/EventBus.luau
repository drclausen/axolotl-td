--[[
    EventBus.luau
    Simple pub/sub event system for cross-system communication
    
    Responsibilities:
    - Provide centralized event management
    - Allow systems to subscribe to events without tight coupling
    - Support multiple listeners per event
    - Handle event firing with arbitrary arguments
    
    Usage:
        EventBus.on("EnemyKilled", function(enemyData)
            print("Enemy killed:", enemyData.type)
        end)
        
        EventBus.fire("EnemyKilled", {type = "Tadpole", reward = 5})
        
        EventBus.off("EnemyKilled", callback)
]]

local EventBus = {}

-- Private state
local events = {}

--[[
    Subscribe to an event
    @param eventName: string - Name of the event to listen for
    @param callback: function - Function to call when event fires
    @return connection: table - Object with Disconnect method
]]
function EventBus.on(eventName: string, callback: (...any) -> ())
    -- TODO: Store callback in events table
    -- TODO: Return connection object with Disconnect method
end

--[[
    Unsubscribe from an event
    @param eventName: string - Name of the event
    @param callback: function - Specific callback to remove
]]
function EventBus.off(eventName: string, callback: (...any) -> ())
    -- TODO: Remove callback from events table
end

--[[
    Fire an event to all subscribers
    @param eventName: string - Name of the event to fire
    @param ...: any - Arguments to pass to callbacks
]]
function EventBus.fire(eventName: string, ...)
    -- TODO: Call all registered callbacks for this event
    -- TODO: Pass arguments to each callback
    -- TODO: Handle errors gracefully (pcall)
end

--[[
    Clear all subscribers for an event (useful for cleanup)
    @param eventName: string - Name of the event to clear
]]
function EventBus.clear(eventName: string)
    -- TODO: Remove all callbacks for this event
end

--[[
    Clear all events (use sparingly, mainly for testing)
]]
function EventBus.clearAll()
    -- TODO: Reset events table
end

return EventBus
