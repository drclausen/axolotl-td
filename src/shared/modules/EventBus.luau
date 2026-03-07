--[[
    EventBus - Pure Luau event system
    
    A lightweight callback registry for decoupled event communication.
    No BindableEvents - works in pure Luau testing environments.
    
    Methods:
        - on(eventName, callback) - Register a listener
        - off(eventName, callback) - Unregister a listener
        - fire(eventName, ...) - Invoke all listeners for an event
        - clear(eventName) - Remove all listeners for an event
]]

local EventBus = {}

-- Private table mapping event names to arrays of callbacks
local _listeners: { [string]: { (...any) -> () } } = {}

--[[
    Register a callback for an event.
    
    @param eventName string - The event to listen for
    @param callback function - The function to invoke when event fires
]]
function EventBus.on(eventName: string, callback: (...any) -> ())
    assert(type(eventName) == "string", "eventName must be a string")
    assert(type(callback) == "function", "callback must be a function")
    
    if not _listeners[eventName] then
        _listeners[eventName] = {}
    end
    
    table.insert(_listeners[eventName], callback)
end

--[[
    Unregister a callback for an event.
    Uses reference equality to identify the callback.
    
    @param eventName string - The event to stop listening to
    @param callback function - The exact function reference to remove
]]
function EventBus.off(eventName: string, callback: (...any) -> ())
    assert(type(eventName) == "string", "eventName must be a string")
    assert(type(callback) == "function", "callback must be a function")
    
    local listeners = _listeners[eventName]
    if not listeners then
        return
    end
    
    -- Remove by reference equality
    for i = #listeners, 1, -1 do
        if listeners[i] == callback then
            table.remove(listeners, i)
        end
    end
    
    -- Clean up empty listener arrays
    if #listeners == 0 then
        _listeners[eventName] = nil
    end
end

--[[
    Invoke all registered listeners for an event.
    Uses pcall to prevent one failing listener from breaking others.
    
    @param eventName string - The event to fire
    @param ... any - Arguments to pass to all listeners
]]
function EventBus.fire(eventName: string, ...: any)
    assert(type(eventName) == "string", "eventName must be a string")
    
    local listeners = _listeners[eventName]
    if not listeners then
        return
    end
    
    -- Iterate over a shallow copy to allow listeners to unregister during fire
    local listenersCopy = table.clone(listeners)
    
    for _, callback in listenersCopy do
        local success, err = pcall(callback, ...)
        if not success then
            warn(string.format("EventBus: Error in listener for '%s': %s", eventName, tostring(err)))
        end
    end
end

--[[
    Remove all listeners for a specific event.
    
    @param eventName string - The event to clear
]]
function EventBus.clear(eventName: string)
    assert(type(eventName) == "string", "eventName must be a string")
    _listeners[eventName] = nil
end

return EventBus
