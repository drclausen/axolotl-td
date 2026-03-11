--[[
    generate_map.luau
    Studio command bar script for generating the Pond Temple map.
]]

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local terrain = Workspace.Terrain

local MAP_SIZE = 200
local CLEAR_SIZE = Vector3.new(240, 120, 240)

local function destroyWorkspaceChild(name: string)
    local existing = Workspace:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end
end

local function createFolder(name: string): Folder
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = Workspace
    return folder
end

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = true
    part.Material = material
    part.Color = color
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

-- Cleanup for idempotent generation
for _, name in ipairs({
    "Waypoints",
    "TowerZones",
    "Base",
    "EnemySpawn1",
    "EnemySpawn2",
    "MapDecor",
    "Towers",
    "Enemies",
}) do
    destroyWorkspaceChild(name)
end

-- Clear previous terrain in the map bounds
terrain:FillBlock(CFrame.new(0, 20, 0), CLEAR_SIZE, Enum.Material.Air)

-- 1) Terrain
terrain:FillBlock(CFrame.new(0, -6, 0), Vector3.new(MAP_SIZE, 12, MAP_SIZE), Enum.Material.Grass)

-- Central pond + shoreline
terrain:FillBall(Vector3.new(0, -2, 0), 28, Enum.Material.Air)
terrain:FillCylinder(CFrame.new(0, -4, 0), Vector3.new(52, 8, 52), Enum.Material.Water)
terrain:FillCylinder(CFrame.new(0, -2, 0), Vector3.new(64, 4, 64), Enum.Material.Sand)
terrain:FillBall(Vector3.new(0, -3, 0), 25, Enum.Material.Water)

-- Temple island in the center
terrain:FillCylinder(CFrame.new(0, -1, 0), Vector3.new(24, 8, 24), Enum.Material.Sand)
terrain:FillCylinder(CFrame.new(0, 1, 0), Vector3.new(18, 5, 18), Enum.Material.Rock)
terrain:FillBlock(CFrame.new(0, 3, 0), Vector3.new(14, 2, 14), Enum.Material.Grass)

-- Edge hills/elevation
local hillCenters = {
    Vector3.new(-82, 0, -78),
    Vector3.new(84, 0, -72),
    Vector3.new(-78, 0, 76),
    Vector3.new(82, 0, 78),
    Vector3.new(-96, 0, 14),
    Vector3.new(98, 0, -10),
}

for _, center in ipairs(hillCenters) do
    terrain:FillBall(center + Vector3.new(0, -4, 0), 16, Enum.Material.Rock)
    terrain:FillBall(center + Vector3.new(0, 4, 0), 10, Enum.Material.Grass)
end

terrain:FillCylinder(CFrame.new(-95, -4, 28), Vector3.new(18, 14, 18), Enum.Material.Rock)
terrain:FillCylinder(CFrame.new(95, -4, -24), Vector3.new(18, 14, 18), Enum.Material.Rock)

-- 2) Enemy path
local waypointsFolder = createFolder("Waypoints")

local waypointPositions = {
    Vector3.new(-90, 1, -80),
    Vector3.new(-78, 1, -66),
    Vector3.new(-66, 1, -48),
    Vector3.new(-56, 1, -28),
    Vector3.new(-46, 1, -8),
    Vector3.new(-34, 1, 10),
    Vector3.new(-20, 1, 24),
    Vector3.new(-4, 1, 34),
    Vector3.new(14, 1, 30),
    Vector3.new(30, 1, 18),
    Vector3.new(40, 1, 2),
    Vector3.new(38, 1, -18),
    Vector3.new(26, 1, -34),
    Vector3.new(8, 1, -42),
    Vector3.new(-14, 1, -38),
    Vector3.new(-24, 1, -22),
    Vector3.new(-18, 1, -4),
    Vector3.new(-6, 1, 8),
    Vector3.new(0, 1, 2),
}

for index, position in ipairs(waypointPositions) do
    local waypoint = Instance.new("Part")
    waypoint.Name = "WP" .. tostring(index)
    waypoint.Size = Vector3.new(2, 1, 2)
    waypoint.Position = position
    waypoint.Anchored = true
    waypoint.CanCollide = false
    waypoint.CanTouch = false
    waypoint.CanQuery = false
    waypoint.Transparency = 1
    waypoint.Parent = waypointsFolder

    local order = Instance.new("NumberValue")
    order.Name = "Order"
    order.Value = index
    order.Parent = waypoint

    CollectionService:AddTag(waypoint, "Waypoint")
end

-- 3) Tower placement zones
local towerZonesFolder = createFolder("TowerZones")

local towerZonePositions = {
    Vector3.new(-62, 0.25, -42),
    Vector3.new(-52, 0.25, -12),
    Vector3.new(-32, 0.25, 20),
    Vector3.new(-8, 0.25, 42),
    Vector3.new(24, 0.25, 24),
    Vector3.new(44, 0.25, -6),
    Vector3.new(28, 0.25, -38),
    Vector3.new(2, 0.25, -46),
    Vector3.new(-26, 0.25, -20),
    Vector3.new(-14, 0.25, 4),
}

for index, position in ipairs(towerZonePositions) do
    local zone = createPart(
        towerZonesFolder,
        "Zone" .. tostring(index),
        Vector3.new(6, 0.5, 6),
        CFrame.new(position),
        Color3.fromRGB(178, 196, 182),
        Enum.Material.SmoothPlastic
    )
    zone.Transparency = 0.12
end

-- 4) Base (Temple)
local baseModel = Instance.new("Model")
baseModel.Name = "Base"
baseModel.Parent = Workspace

local templePlatform = createPart(
    baseModel,
    "TemplePlatform",
    Vector3.new(12, 2, 12),
    CFrame.new(0, 4, 0),
    Color3.fromRGB(132, 132, 122),
    Enum.Material.Slate
)

local pillarOffsets = {
    Vector3.new(-4, 6, -4),
    Vector3.new(4, 6, -4),
    Vector3.new(-4, 6, 4),
    Vector3.new(4, 6, 4),
}

for index, offset in ipairs(pillarOffsets) do
    createPart(
        baseModel,
        "Pillar" .. tostring(index),
        Vector3.new(1.8, 8, 1.8),
        CFrame.new(offset),
        Color3.fromRGB(154, 154, 146),
        Enum.Material.Rock
    )
end

createPart(
    baseModel,
    "TempleRoof",
    Vector3.new(14, 1.5, 14),
    CFrame.new(0, 10.25, 0),
    Color3.fromRGB(113, 113, 108),
    Enum.Material.Slate
)

local baseCore = createPart(
    baseModel,
    "BaseCore",
    Vector3.new(2, 2, 2),
    CFrame.new(0, 5.5, 0),
    Color3.fromRGB(98, 167, 132),
    Enum.Material.Neon
)
baseCore.CanCollide = false

local baseHealthGui = Instance.new("BillboardGui")
baseHealthGui.Name = "BaseHealth"
baseHealthGui.Size = UDim2.new(0, 120, 0, 24)
baseHealthGui.StudsOffset = Vector3.new(0, 3, 0)
baseHealthGui.AlwaysOnTop = true
baseHealthGui.Parent = baseCore

local healthBg = Instance.new("Frame")
healthBg.Size = UDim2.new(1, 0, 1, 0)
healthBg.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
healthBg.BorderSizePixel = 0
healthBg.Parent = baseHealthGui

local healthBar = Instance.new("Frame")
healthBar.Name = "Fill"
healthBar.Size = UDim2.new(1, 0, 0.55, 0)
healthBar.Position = UDim2.new(0, 0, 0.45, 0)
healthBar.BackgroundColor3 = Color3.fromRGB(114, 210, 145)
healthBar.BorderSizePixel = 0
healthBar.Parent = healthBg

local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(1, 0, 0.45, 0)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "Temple HP"
healthLabel.TextColor3 = Color3.fromRGB(255, 242, 214)
healthLabel.TextScaled = true
healthLabel.Font = Enum.Font.GothamBold
healthLabel.Parent = healthBg

baseModel.PrimaryPart = templePlatform

-- 5) Spawn points (two entries)
local spawn1 = createPart(
    Workspace,
    "EnemySpawn1",
    Vector3.new(4, 1, 4),
    CFrame.new(-92, 1, -82),
    Color3.fromRGB(255, 170, 128),
    Enum.Material.Neon
)
spawn1.CanCollide = false
spawn1.Transparency = 0.25

local spawn2 = createPart(
    Workspace,
    "EnemySpawn2",
    Vector3.new(4, 1, 4),
    CFrame.new(92, 1, -84),
    Color3.fromRGB(255, 188, 138),
    Enum.Material.Neon
)
spawn2.CanCollide = false
spawn2.Transparency = 0.25

-- 6) Required runtime folders
createFolder("Towers")
createFolder("Enemies")

-- Style decor: lily pads + branch path markers from second entry to merged path
local decorFolder = createFolder("MapDecor")

local lilyPadData = {
    {Vector3.new(-18, 0.1, 8), 5.2, 12},
    {Vector3.new(-12, 0.1, -6), 4.6, 38},
    {Vector3.new(-4, 0.1, 14), 5.4, -22},
    {Vector3.new(8, 0.1, 10), 5.0, 55},
    {Vector3.new(14, 0.1, -4), 4.2, 16},
    {Vector3.new(2, 0.1, -14), 5.8, -40},
    {Vector3.new(-10, 0.1, -18), 4.8, 72},
    {Vector3.new(18, 0.1, 6), 4.4, -65},
}

for index, pad in ipairs(lilyPadData) do
    local position = pad[1]
    local diameter = pad[2]
    local yaw = pad[3]

    local lilyPad = createPart(
        decorFolder,
        "LilyPad" .. tostring(index),
        Vector3.new(0.25, diameter, diameter),
        CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), math.rad(90)),
        Color3.fromRGB(117, 160, 90),
        Enum.Material.SmoothPlastic
    )
    lilyPad.CanCollide = false

    if index % 3 == 0 then
        local flower = createPart(
            decorFolder,
            "LilyFlower" .. tostring(index),
            Vector3.new(0.6, 0.4, 0.6),
            CFrame.new(position + Vector3.new(0, 0.28, 0)),
            Color3.fromRGB(255, 211, 227),
            Enum.Material.Neon
        )
        flower.CanCollide = false
    end
end

local function createPathStone(name: string, position: Vector3)
    local stone = createPart(
        decorFolder,
        name,
        Vector3.new(3.5, 0.7, 3.5),
        CFrame.new(position),
        Color3.fromRGB(124, 117, 108),
        Enum.Material.Slate
    )
    stone.CanCollide = true
end

for index, waypointPosition in ipairs(waypointPositions) do
    if index % 2 == 0 then
        createPathStone("MainPathStone" .. tostring(index), waypointPosition + Vector3.new(0, -0.5, 0))
    end
end

local branch2Markers = {
    Vector3.new(80, 0.5, -68),
    Vector3.new(64, 0.5, -52),
    Vector3.new(48, 0.5, -34),
    Vector3.new(30, 0.5, -10),
    Vector3.new(14, 0.5, 12),
    Vector3.new(-2, 0.5, 32),
}

for index, markerPosition in ipairs(branch2Markers) do
    createPathStone("Branch2Stone" .. tostring(index), markerPosition)
end

print("[generate_map] Pond Temple map generated successfully.")
print("[generate_map] Waypoints:", #waypointPositions, "| TowerZones:", #towerZonePositions)
