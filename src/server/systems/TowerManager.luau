local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("TowerConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("GameConfig"))
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))
local EconomyManager = require(script.Parent:WaitForChild("EconomyManager"))
local CombatSystem = require(script.Parent:WaitForChild("CombatSystem"))

local function loadAnimationHelper()
    local modulesFolder = ReplicatedStorage:FindFirstChild("modules")
    if not modulesFolder then
        return nil
    end

    local helperModule = modulesFolder:FindFirstChild("AnimationHelper")
    if not helperModule or not helperModule:IsA("ModuleScript") then
        return nil
    end

    local ok, helper = pcall(require, helperModule)
    if ok then
        return helper
    end

    warn("[TowerManager] Failed to load AnimationHelper:", helper)
    return nil
end

local AnimationHelper = loadAnimationHelper()

local TowerManager = {}
local towers: {[string]: any} = {}
local nextId = 0
local MIN_TOWER_DISTANCE = 4 -- minimum studs between towers
local MIN_PLACEMENT_Y = -5
local MAX_PLACEMENT_Y = 10

local function isFiniteNumber(value: number): boolean
    return value == value and value > -math.huge and value < math.huge
end

function TowerManager.isPlacementValid(position: Vector3): (boolean, string?)
    if not isFiniteNumber(position.X) or not isFiniteNumber(position.Y) or not isFiniteNumber(position.Z) then
        return false, "Invalid placement position"
    end
    if position.Y < MIN_PLACEMENT_Y or position.Y > MAX_PLACEMENT_Y then
        return false, "Tower must be placed on valid ground"
    end
    return true, nil
end

function TowerManager.init()
    -- Create Towers folder in workspace
    if not workspace:FindFirstChild("Towers") then
        local folder = Instance.new("Folder")
        folder.Name = "Towers"
        folder.Parent = workspace
    end
    -- Create Enemies folder too if missing
    if not workspace:FindFirstChild("Enemies") then
        local folder = Instance.new("Folder")
        folder.Name = "Enemies"
        folder.Parent = workspace
    end
end

function TowerManager.placeTower(player: Player, towerType: string, position: Vector3): (boolean, string)
    local config = TowerConfig[towerType]
    if not config then
        return false, "Unknown tower type"
    end
    local placementValid, placementError = TowerManager.isPlacementValid(position)
    if not placementValid then
        return false, placementError or "Invalid placement"
    end
    if TowerManager.getTowerCount() >= GameConfig.maxTowers then
        return false, "Tower limit reached"
    end
    if not EconomyManager.canAfford(player, config.cost) then
        return false, "Not enough money"
    end
    -- Check overlap with existing towers
    for _, tower in pairs(towers) do
        if tower.model and tower.model.PrimaryPart then
            local dist = (tower.model.PrimaryPart.Position - position).Magnitude
            if dist < MIN_TOWER_DISTANCE then
                return false, "Too close to another tower"
            end
        end
    end
    
    -- Deduct cost
    if not EconomyManager.spend(player, config.cost) then
        return false, "Payment failed"
    end
    
    nextId += 1
    local id = "tower_" .. nextId
    
    -- Create tower model
    local model = Instance.new("Model")
    model.Name = id
    
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(3, 1, 3)
    base.Position = position
    base.Anchored = true
    base.CanCollide = true
    base.Color = Color3.fromRGB(100, 200, 255) -- axolotl blue
    base.Parent = model
    
    local turret = Instance.new("Part")
    turret.Name = "Turret"
    turret.Size = Vector3.new(1.5, 2, 1.5)
    turret.Position = position + Vector3.new(0, 1.5, 0)
    turret.Anchored = true
    turret.CanCollide = false
    -- Color by type
    if towerType == "Sparky" then
        turret.Color = Color3.fromRGB(255, 255, 0) -- yellow
    elseif towerType == "Rocky" then
        turret.Color = Color3.fromRGB(150, 100, 50) -- brown
    elseif towerType == "Zippy" then
        turret.Color = Color3.fromRGB(0, 255, 150) -- green
    end
    turret.Parent = model
    
    -- Label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 80, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = turret
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.displayName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard
    
    model.PrimaryPart = base
    model.Parent = workspace.Towers

    if AnimationHelper and AnimationHelper.startTowerIdle then
        AnimationHelper.startTowerIdle(model)
    end
    
    local towerData = {
        id = id,
        towerType = towerType,
        position = position,
        tier = 1,
        owner = player,
        model = model,
    }
    towers[id] = towerData
    
    -- Register with combat system
    CombatSystem.registerTower(towerData)
    
    EventBus.fire("TowerPlaced", id, towerType, position, player)
    return true, string.format("%s placed!", config.displayName)
end

function TowerManager.getTower(id: string)
    return towers[id]
end

function TowerManager.getTowerCount(): number
    local count = 0
    for _ in pairs(towers) do count += 1 end
    return count
end

return TowerManager
