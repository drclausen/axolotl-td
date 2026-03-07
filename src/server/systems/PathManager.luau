--[[
    PathManager.luau
    Manages the enemy path waypoints
    
    Responsibilities:
    - Store ordered list of waypoints (Vector3 positions)
    - Provide path data to enemy movement system
    - Calculate total path distance
    - Support waypoint lookup by index
    
    Implementation:
    - Waypoints defined in workspace as Parts tagged "Waypoint"
    - Each waypoint has NumberValue "Order" attribute for sequencing
    - On init, collect and sort waypoints by Order
    
    State:
    - waypoints: Array<Vector3>
    - totalDistance: number
    
    Methods:
    - getWaypoints(): Array<Vector3>
    - getNextWaypoint(currentIndex): Vector3?
    - getTotalDistance(): number
]]

local PathManager = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Private state
local waypoints = {}
local totalDistance = 0

--[[
    Initialize PathManager
    Collects waypoints from workspace and sorts them
]]
function PathManager.init()
    -- TODO: Get all parts tagged with "Waypoint" using CollectionService
    -- TODO: For each waypoint part:
    --         Find NumberValue child named "Order"
    --         Store {order, position} in temp table
    -- TODO: Sort temp table by order
    -- TODO: Extract positions into waypoints array
    -- TODO: Calculate totalDistance by summing distances between consecutive waypoints
    -- TODO: If no waypoints found, warn and create default path
end

--[[
    Get all waypoints
    @return Array<Vector3>
]]
function PathManager.getWaypoints(): {Vector3}
    return waypoints
end

--[[
    Get a specific waypoint by index
    @param index: number - 1-based index
    @return Vector3?
]]
function PathManager.getWaypoint(index: number): Vector3?
    -- TODO: Return waypoints[index] or nil if out of bounds
    return nil
end

--[[
    Get next waypoint after current index
    @param currentIndex: number
    @return Vector3?
]]
function PathManager.getNextWaypoint(currentIndex: number): Vector3?
    -- TODO: Return waypoints[currentIndex + 1] or nil if at end
    return nil
end

--[[
    Get total distance of the path
    @return number
]]
function PathManager.getTotalDistance(): number
    return totalDistance
end

--[[
    Get number of waypoints
    @return number
]]
function PathManager.getWaypointCount(): number
    return #waypoints
end

--[[
    Check if index is the last waypoint
    @param index: number
    @return boolean
]]
function PathManager.isLastWaypoint(index: number): boolean
    return index >= #waypoints
end

--[[
    Create default path if no waypoints found
    Used for testing/development
]]
function PathManager.createDefaultPath()
    -- TODO: Create a simple straight line path
    -- TODO: Waypoints at (0, 0, 0), (50, 0, 0), (100, 0, 0), etc.
    warn("PathManager: No waypoints found, using default path")
end

--[[
    Visualize path with lines (debug helper)
]]
function PathManager.visualizePath()
    -- TODO: Create Part attachments between consecutive waypoints
    -- TODO: Use Beams or LineHandleAdornments to draw path
end

return PathManager
