local CollectionService = game:GetService("CollectionService")

local PathManager = {}

local waypoints: {Vector3} = {}

function PathManager.init()
	-- Find all parts tagged "Waypoint" in workspace
	-- Each must have a NumberValue child named "Order"
	-- Sort by Order value ascending
	-- Store their Position (Vector3) in waypoints array
	local waypointParts = CollectionService:GetTagged("Waypoint")
	local sorted = {}
	for _, waypoint in ipairs(waypointParts) do
		if waypoint:IsA("BasePart") then
			local orderValue = waypoint:FindFirstChild("Order")
			if orderValue and orderValue:IsA("NumberValue") then
				table.insert(sorted, {order = orderValue.Value, position = waypoint.Position})
			end
		end
	end
	table.sort(sorted, function(a, b) return a.order < b.order end)
	waypoints = {}
	for _, wp in ipairs(sorted) do
		table.insert(waypoints, wp.position)
	end
	print("[PathManager] Initialized with " .. #waypoints .. " waypoints")
end

function PathManager.getWaypoints(): {Vector3}
	return waypoints
end

function PathManager.getWaypoint(index: number): Vector3?
	return waypoints[index]
end

function PathManager.getNextWaypoint(currentIndex: number): Vector3?
	return waypoints[currentIndex + 1]
end

function PathManager.getWaypointCount(): number
	return #waypoints
end

function PathManager.getTotalDistance(): number
	local total = 0
	for i = 1, #waypoints - 1 do
		total += (waypoints[i + 1] - waypoints[i]).Magnitude
	end
	return total
end

return PathManager
