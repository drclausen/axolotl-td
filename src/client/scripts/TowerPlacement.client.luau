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
local camera = workspace.CurrentCamera

-- Config
local TowerConfig = require(ReplicatedStorage.config.TowerConfig)

-- Remote Events
-- TODO: Get RemoteEvent "PlaceTower" from ReplicatedStorage

-- State
local selectedTowerType = nil
local ghostModel = nil
local isPlacing = false
local canPlace = false
local playerMoney = 0 -- Updated by server RemoteEvent

--[[
    Start tower placement mode
    @param towerType: string
]]
local function startPlacement(towerType: string)
    -- TODO: Check if player can afford tower
    -- TODO: Set selectedTowerType
    -- TODO: Set isPlacing = true
    -- TODO: Create ghost model (transparent copy of tower)
    -- TODO: Connect to RunService.RenderStepped to update ghost position
end

--[[
    Cancel tower placement
]]
local function cancelPlacement()
    -- TODO: Set isPlacing = false
    -- TODO: Destroy ghost model
    -- TODO: Set selectedTowerType = nil
    -- TODO: Disconnect RenderStepped connection
end

--[[
    Update ghost model position (called every frame while placing)
]]
local function updateGhostPosition()
    -- TODO: Raycast from mouse to ground
    -- TODO: If hit, move ghost to hit position
    -- TODO: Check if position is valid (not overlapping, on ground)
    -- TODO: Set ghost color: green if valid, red if invalid
    -- TODO: Update canPlace boolean
end

--[[
    Attempt to place tower at current ghost position
]]
local function placeTower()
    -- TODO: If not canPlace, return
    -- TODO: Get ghost position
    -- TODO: Fire RemoteEvent "PlaceTower" with {player, selectedTowerType, position}
    -- TODO: cancelPlacement()
end

--[[
    Handle mouse click
]]
local function onMouseClick()
    -- TODO: If isPlacing and canPlace:
    --         placeTower()
end

--[[
    Handle input (Escape to cancel, right-click to cancel)
]]
local function onInputBegan(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    
    -- TODO: If input is Escape or right-click:
    --         If isPlacing, cancelPlacement()
    
    -- TODO: If input is left-click:
    --         If isPlacing, onMouseClick()
end

--[[
    Listen for tower placement failures from server
]]
local function onPlacementFailed(reason: string)
    -- TODO: Show error message to player
    -- TODO: Play error sound
    -- TODO: Re-enable placement (don't cancel, let them try again)
end

--[[
    Listen for balance changes from server
]]
local function onBalanceChanged(newBalance: number)
    -- TODO: Update playerMoney
    -- TODO: If isPlacing and can no longer afford:
    --         cancelPlacement()
end

--[[
    Initialize client-side placement system
]]
local function init()
    -- TODO: Connect to UserInputService.InputBegan
    -- TODO: Listen for RemoteEvent "TowerPlacementFailed"
    -- TODO: Listen for RemoteEvent "BalanceChanged"
    -- TODO: Listen for UI button clicks (when UI is created)
    
    print("TowerPlacement client initialized!")
end

-- Initialize
init()

-- Export functions for UI to call
return {
    startPlacement = startPlacement,
    cancelPlacement = cancelPlacement,
}
