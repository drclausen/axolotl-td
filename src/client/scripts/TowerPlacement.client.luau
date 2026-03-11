--[[
    TowerPlacement.client.luau
    Client-side tower placement system
    
    Responsibilities:
    - Show ghost tower following mouse on ground plane
    - On click, fire PlaceTower RemoteEvent with position + selected tower type
    - Cancel placement with right-click or Escape
    - Disable placement when player lacks money
    - Visual feedback (green = valid, red = invalid placement)
    
    State:
    - selectedTowerType: string?
    - ghostModel: Model?
    - canPlace: boolean
    - isPlacing: boolean
    
    Input flow:
    1. Player clicks tower button in UI → sets selectedTowerType
    2. Ghost tower appears, follows mouse
    3. Player clicks ground → fires RemoteEvent "PlaceTower"
    4. Server validates and responds
    5. If successful, ghost disappears; if failed, show error
    
    Dependencies:
    - TowerConfig (for ghost model, cost display)
    - RemoteEvent "PlaceTower"
    - UI buttons (created separately)
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- References
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Wait for RemoteEvents
local PlaceTowerEvent = ReplicatedStorage:WaitForChild("PlaceTower")
local TowerPlacementResultEvent = ReplicatedStorage:WaitForChild("TowerPlacementResult")

-- Wait for shared state (used by UI to communicate selected tower)
local SelectedTowerValue = ReplicatedStorage:WaitForChild("SelectedTower")

-- Config
local TowerConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("TowerConfig"))

-- State
local selectedTowerType = nil
local ghostModel = nil
local rangeIndicator = nil
local isPlacing = false
local canPlace = false
local renderConnection = nil

-- Constants
local VALID_COLOR = Color3.fromRGB(0, 255, 0) -- Green
local INVALID_COLOR = Color3.fromRGB(255, 0, 0) -- Red
local MIN_TOWER_SPACING = 4 -- Must match server-side validation in TowerManager
local GHOST_TRANSPARENCY = 0.5
local cancelPlacement

--[[
    Create a ghost model for the selected tower type
    @param towerType: string
    @return Model?
]]
local function createGhostModel(towerType: string)
    local config = TowerConfig[towerType]
    if not config then
        warn("Invalid tower type:", towerType)
        return nil
    end
    
    -- Create a simple ghost part (cylinder representing tower)
    local ghost = Instance.new("Model")
    ghost.Name = "GhostTower"
    
    local part = Instance.new("Part")
    part.Name = "Base"
    part.Size = Vector3.new(3, 1, 3)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = GHOST_TRANSPARENCY
    part.Material = Enum.Material.Neon
    
    -- Color based on tower type
    if towerType == "Sparky" then
        part.Color = Color3.fromRGB(255, 255, 0) -- Yellow
    elseif towerType == "Rocky" then
        part.Color = Color3.fromRGB(139, 90, 43) -- Brown
    elseif towerType == "Zippy" then
        part.Color = Color3.fromRGB(0, 255, 127) -- Green
    else
        part.Color = Color3.fromRGB(200, 200, 200) -- Default gray
    end
    
    part.Parent = ghost
    ghost.PrimaryPart = part
    
    return ghost
end

--[[
    Create a flat range indicator disc for the selected tower type
    @param towerType: string
    @return Part?
]]
local function createRangeIndicator(towerType: string)
    local config = TowerConfig[towerType]
    if not config then
        warn("Invalid tower type for range indicator:", towerType)
        return nil
    end

    local range = config.range or 0
    local diameter = range * 2

    local indicator = Instance.new("Part")
    indicator.Name = "RangeIndicator"
    indicator.Anchored = true
    indicator.CanCollide = false
    indicator.CanQuery = false
    indicator.CanTouch = false
    indicator.Shape = Enum.PartType.Cylinder
    indicator.Size = Vector3.new(0.1, diameter, diameter)
    indicator.Transparency = 0.7
    indicator.Material = Enum.Material.ForceField
    indicator.Color = INVALID_COLOR

    return indicator
end

--[[
    Check if a position is valid for tower placement
    @param position: Vector3
    @return boolean
]]
local function isValidPlacement(position: Vector3): boolean
    -- Check if too close to other towers
    local towers = workspace:FindFirstChild("Towers")
    if towers then
        for _, tower in ipairs(towers:GetChildren()) do
            if tower:IsA("Model") and tower.PrimaryPart then
                local distance = (tower.PrimaryPart.Position - position).Magnitude
                if distance < MIN_TOWER_SPACING then
                    return false
                end
            end
        end
    end
    
    -- Check if on ground (y coordinate should be close to 0.5, which is half the part height)
    if position.Y < -5 or position.Y > 10 then
        return false
    end
    
    return true
end

--[[
    Update ghost model position (called every frame while placing)
]]
local function updateGhostPosition()
    if not isPlacing or not ghostModel then
        return
    end
    
    -- Raycast from mouse to ground
    local ray = mouse.Hit
    local position = ray.Position
    
    -- Move ghost to mouse position
    if ghostModel.PrimaryPart then
        ghostModel:SetPrimaryPartCFrame(CFrame.new(position.X, position.Y + 0.5, position.Z))
        
        -- Check if placement is valid
        canPlace = isValidPlacement(position)
        
        -- Update ghost color based on validity
        local color = canPlace and VALID_COLOR or INVALID_COLOR
        ghostModel.PrimaryPart.Color = color

        if rangeIndicator then
            rangeIndicator.Color = color
            rangeIndicator.CFrame = CFrame.new(position.X, position.Y + 0.05, position.Z) * CFrame.Angles(0, 0, math.rad(90))
        end
    end
end

--[[
    Start tower placement mode
    @param towerType: string
]]
local function startPlacement(towerType: string)
    -- Cancel any existing placement
    if isPlacing then
        cancelPlacement()
    end
    
    selectedTowerType = towerType
    isPlacing = true
    
    -- Create ghost model
    ghostModel = createGhostModel(towerType)
    if not ghostModel then
        isPlacing = false
        return
    end

    rangeIndicator = createRangeIndicator(towerType)

    ghostModel.Parent = workspace
    if rangeIndicator then
        rangeIndicator.Parent = workspace
    end
    
    -- Connect to RenderStepped for smooth ghost updates
    renderConnection = RunService.RenderStepped:Connect(updateGhostPosition)
end

--[[
    Cancel tower placement
]]
cancelPlacement = function()
    isPlacing = false
    canPlace = false
    selectedTowerType = nil
    
    -- Destroy ghost model
    if ghostModel then
        ghostModel:Destroy()
        ghostModel = nil
    end
    if rangeIndicator then
        rangeIndicator:Destroy()
        rangeIndicator = nil
    end
    
    -- Disconnect render connection
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    
    -- Clear selected tower in ReplicatedStorage
    SelectedTowerValue.Value = ""
end

--[[
    Attempt to place tower at current ghost position
]]
local function placeTower()
    if not canPlace or not isPlacing or not selectedTowerType or not ghostModel then
        return
    end
    
    -- Get ghost position
    local position = ghostModel.PrimaryPart.Position
    
    -- Fire RemoteEvent to server
    PlaceTowerEvent:FireServer(selectedTowerType, position)
    
    -- Cancel placement (server will handle success/failure)
    cancelPlacement()
end

--[[
    Handle input (Escape to cancel, right-click to cancel, left-click to place)
]]
local function onInputBegan(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    
    -- Escape or right-click to cancel
    if input.KeyCode == Enum.KeyCode.Escape or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if isPlacing then
            cancelPlacement()
        end
    end
    
    -- Left-click to place
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isPlacing then
            placeTower()
        end
    end
end

--[[
    Listen for tower placement result from server
]]
local function onPlaceTowerResult(success: boolean, message: string)
    if not success then
        warn("Tower placement failed:", message)
        -- Could show UI feedback here
    end
end

--[[
    Listen for changes to selected tower (from UI)
]]
local function onSelectedTowerChanged()
    local towerType = SelectedTowerValue.Value
    
    if towerType == "" then
        -- Deselected
        if isPlacing then
            cancelPlacement()
        end
    else
        -- Selected a tower type
        startPlacement(towerType)
    end
end

--[[
    Initialize client-side placement system
]]
local function init()
    -- Connect to UserInputService
    UserInputService.InputBegan:Connect(onInputBegan)
    
    -- Listen for placement results
    TowerPlacementResultEvent.OnClientEvent:Connect(onPlaceTowerResult)
    
    -- Listen for tower selection changes
    SelectedTowerValue.Changed:Connect(onSelectedTowerChanged)
    
    print("TowerPlacement client initialized!")
end

-- Initialize
init()

-- Export functions for UI to call (though UI now uses SelectedTowerValue)
return {
    startPlacement = startPlacement,
    cancelPlacement = cancelPlacement,
}
