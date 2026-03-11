--[[
    generate_enemies.luau
    Studio command bar script for generating enemy models in ReplicatedStorage.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("EnemyConfig"))

local MAX_PARTS_PER_ENEMY = 15

local function createPart(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame,
    color: Color3,
    material: Enum.Material?,
    shape: Enum.PartType?
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = false
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Massless = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    if shape then
        part.Shape = shape
    end
    part.Parent = parent
    return part
end

local function createWedge(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame,
    color: Color3,
    material: Enum.Material?
): WedgePart
    local wedge = Instance.new("WedgePart")
    wedge.Name = name
    wedge.Size = size
    wedge.CFrame = cframe
    wedge.Anchored = false
    wedge.CanCollide = false
    wedge.CanQuery = false
    wedge.CanTouch = false
    wedge.Massless = true
    wedge.TopSurface = Enum.SurfaceType.Smooth
    wedge.BottomSurface = Enum.SurfaceType.Smooth
    wedge.Color = color
    wedge.Material = material or Enum.Material.SmoothPlastic
    wedge.Parent = parent
    return wedge
end

local function countParts(root: Instance): number
    local count = 0
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("BasePart") then
            count += 1
        end
    end
    return count
end

local function addHumanoid(model: Model, health: number, walkSpeed: number)
    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.MaxHealth = health
    humanoid.Health = health
    humanoid.WalkSpeed = walkSpeed
    humanoid.Parent = model
end

local function addHealthBar(primaryPart: BasePart, heightOffset: number)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(0, 64, 0, 10)
    billboard.StudsOffset = Vector3.new(0, heightOffset, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = primaryPart

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    background.BorderSizePixel = 0
    background.Parent = billboard

    local hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(65, 232, 84)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = background
end

local function weldPartsToPrimary(model: Model, primaryPart: BasePart)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant ~= primaryPart then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = primaryPart
            weld.Part1 = descendant
            weld.Parent = primaryPart
        end
    end
end

local function buildTadpole(model: Model): (BasePart, number)
    local bodyColor = Color3.fromRGB(34, 91, 56)
    local accentColor = Color3.fromRGB(22, 66, 41)

    local body = createPart(
        model,
        "Body",
        Vector3.new(0.9, 0.6, 1.2),
        CFrame.new(0, 0.8, 0),
        bodyColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )

    createWedge(
        model,
        "TailFin",
        Vector3.new(0.35, 0.25, 0.8),
        CFrame.new(0, 0.78, 0.9) * CFrame.Angles(0, math.rad(180), 0),
        accentColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "TopFin",
        Vector3.new(0.14, 0.24, 0.6),
        CFrame.new(0, 1.05, 0.22),
        accentColor,
        Enum.Material.SmoothPlastic
    )

    return body, 1.25
end

local function buildMinnow(model: Model): (BasePart, number)
    local bodyColor = Color3.fromRGB(156, 184, 208)
    local backColor = Color3.fromRGB(106, 143, 180)
    local finColor = Color3.fromRGB(188, 216, 235)

    local body = createPart(
        model,
        "Body",
        Vector3.new(1.3, 0.7, 2.4),
        CFrame.new(0, 0.95, 0),
        bodyColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )

    createPart(
        model,
        "BackStripe",
        Vector3.new(1.0, 0.18, 1.8),
        CFrame.new(0, 1.2, -0.1),
        backColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "DorsalFin",
        Vector3.new(0.22, 0.45, 0.75),
        CFrame.new(0, 1.32, 0.05),
        finColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "Tail",
        Vector3.new(0.55, 0.45, 0.75),
        CFrame.new(0, 0.95, 1.5) * CFrame.Angles(0, math.rad(180), 0),
        finColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "SideFinLeft",
        Vector3.new(0.35, 0.12, 0.5),
        CFrame.new(-0.55, 0.85, 0.35) * CFrame.Angles(0, math.rad(-25), math.rad(8)),
        finColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "SideFinRight",
        Vector3.new(0.35, 0.12, 0.5),
        CFrame.new(0.55, 0.85, 0.35) * CFrame.Angles(0, math.rad(25), math.rad(-8)),
        finColor,
        Enum.Material.SmoothPlastic
    )

    return body, 1.4
end

local function buildFrog(model: Model): (BasePart, number)
    local bodyColor = Color3.fromRGB(83, 164, 76)
    local bellyColor = Color3.fromRGB(225, 214, 127)
    local eyeColor = Color3.fromRGB(235, 244, 148)

    local body = createPart(
        model,
        "Body",
        Vector3.new(2.1, 0.95, 2.3),
        CFrame.new(0, 1.1, 0),
        bodyColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "Belly",
        Vector3.new(1.4, 0.35, 1.4),
        CFrame.new(0, 0.82, -0.15),
        bellyColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "Head",
        Vector3.new(1.7, 0.75, 1.5),
        CFrame.new(0, 1.45, -0.9),
        bodyColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "LegBackLeft",
        Vector3.new(0.6, 0.6, 1.4),
        CFrame.new(-0.8, 0.7, 0.9) * CFrame.Angles(math.rad(90), 0, math.rad(12)),
        bodyColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Cylinder
    )

    createPart(
        model,
        "LegBackRight",
        Vector3.new(0.6, 0.6, 1.4),
        CFrame.new(0.8, 0.7, 0.9) * CFrame.Angles(math.rad(90), 0, math.rad(-12)),
        bodyColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Cylinder
    )

    createPart(
        model,
        "EyeLeft",
        Vector3.new(0.35, 0.35, 0.35),
        CFrame.new(-0.45, 1.82, -1.35),
        eyeColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )

    createPart(
        model,
        "EyeRight",
        Vector3.new(0.35, 0.35, 0.35),
        CFrame.new(0.45, 1.82, -1.35),
        eyeColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )

    return body, 1.8
end

local function buildCrayfish(model: Model): (BasePart, number)
    local shellColor = Color3.fromRGB(174, 80, 42)
    local clawColor = Color3.fromRGB(199, 103, 61)

    local body = createPart(
        model,
        "Body",
        Vector3.new(1.8, 0.8, 1.8),
        CFrame.new(0, 1.05, -0.05),
        shellColor,
        Enum.Material.Metal
    )

    createPart(
        model,
        "MidSegment",
        Vector3.new(1.5, 0.7, 1.1),
        CFrame.new(0, 1.0, 0.92),
        shellColor,
        Enum.Material.Metal
    )

    createPart(
        model,
        "TailSegment",
        Vector3.new(1.25, 0.62, 0.85),
        CFrame.new(0, 0.98, 1.72),
        shellColor,
        Enum.Material.Metal
    )

    createPart(
        model,
        "ClawArmLeft",
        Vector3.new(0.36, 0.36, 1.0),
        CFrame.new(-1.0, 1.02, -0.6) * CFrame.Angles(0, math.rad(20), math.rad(90)),
        shellColor,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )

    createPart(
        model,
        "ClawArmRight",
        Vector3.new(0.36, 0.36, 1.0),
        CFrame.new(1.0, 1.02, -0.6) * CFrame.Angles(0, math.rad(-20), math.rad(90)),
        shellColor,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )

    createWedge(
        model,
        "ClawLeft",
        Vector3.new(0.8, 0.4, 0.7),
        CFrame.new(-1.45, 1.0, -1.02) * CFrame.Angles(0, math.rad(-35), 0),
        clawColor,
        Enum.Material.Metal
    )

    createWedge(
        model,
        "ClawRight",
        Vector3.new(0.8, 0.4, 0.7),
        CFrame.new(1.45, 1.0, -1.02) * CFrame.Angles(0, math.rad(35), 0),
        clawColor,
        Enum.Material.Metal
    )

    createWedge(
        model,
        "TailFanLeft",
        Vector3.new(0.45, 0.2, 0.55),
        CFrame.new(-0.42, 0.95, 2.22) * CFrame.Angles(0, math.rad(155), 0),
        clawColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "TailFanCenter",
        Vector3.new(0.45, 0.2, 0.55),
        CFrame.new(0, 0.95, 2.3) * CFrame.Angles(0, math.rad(180), 0),
        clawColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "TailFanRight",
        Vector3.new(0.45, 0.2, 0.55),
        CFrame.new(0.42, 0.95, 2.22) * CFrame.Angles(0, math.rad(-155), 0),
        clawColor,
        Enum.Material.SmoothPlastic
    )

    return body, 1.9
end

local function buildSnappingTurtle(model: Model): (BasePart, number)
    local shellColor = Color3.fromRGB(70, 92, 56)
    local bodyColor = Color3.fromRGB(156, 148, 112)
    local limbColor = Color3.fromRGB(92, 116, 74)

    local body = createPart(
        model,
        "Body",
        Vector3.new(2.9, 0.95, 3.4),
        CFrame.new(0, 1.25, 0),
        bodyColor,
        Enum.Material.SmoothPlastic
    )

    -- Squashed sphere gives a domed shell silhouette similar to a hemisphere.
    createPart(
        model,
        "Shell",
        Vector3.new(3.2, 1.7, 3.5),
        CFrame.new(0, 1.98, -0.05),
        shellColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )

    createPart(
        model,
        "Head",
        Vector3.new(1.0, 0.75, 0.95),
        CFrame.new(0, 1.3, -2.0),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "LegFrontLeft",
        Vector3.new(0.65, 0.45, 0.9),
        CFrame.new(-1.35, 0.9, -1.1),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "LegFrontRight",
        Vector3.new(0.65, 0.45, 0.9),
        CFrame.new(1.35, 0.9, -1.1),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "LegBackLeft",
        Vector3.new(0.72, 0.45, 0.95),
        CFrame.new(-1.35, 0.9, 1.2),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    createPart(
        model,
        "LegBackRight",
        Vector3.new(0.72, 0.45, 0.95),
        CFrame.new(1.35, 0.9, 1.2),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    createWedge(
        model,
        "Tail",
        Vector3.new(0.45, 0.35, 0.9),
        CFrame.new(0, 1.0, 2.2) * CFrame.Angles(0, math.rad(180), 0),
        limbColor,
        Enum.Material.SmoothPlastic
    )

    return body, 2.2
end

local builders: {[string]: (Model) -> (BasePart, number)} = {
    Tadpole = buildTadpole,
    Minnow = buildMinnow,
    Frog = buildFrog,
    Crayfish = buildCrayfish,
    SnappingTurtle = buildSnappingTurtle,
}

local function generateEnemyModel(enemyFolder: Folder, enemyName: string)
    local config = EnemyConfig[enemyName]
    if not config then
        warn("Skipping missing enemy config: " .. enemyName)
        return
    end

    local builder = builders[enemyName]
    if not builder then
        warn("Skipping enemy with no model builder: " .. enemyName)
        return
    end

    local existing = enemyFolder:FindFirstChild(enemyName)
    if existing then
        existing:Destroy()
    end

    local model = Instance.new("Model")
    model.Name = enemyName
    model.Parent = enemyFolder

    local primaryPart, healthBarOffset = builder(model)
    model.PrimaryPart = primaryPart

    addHumanoid(model, config.health, config.speed)
    addHealthBar(primaryPart, healthBarOffset)
    weldPartsToPrimary(model, primaryPart)

    local partCount = countParts(model)
    if partCount > MAX_PARTS_PER_ENEMY then
        warn(string.format("%s generated with %d parts (over %d)", enemyName, partCount, MAX_PARTS_PER_ENEMY))
    end

    print(string.format(
        "Generated enemy model: %s (%d parts, speed %.1f)",
        enemyName,
        partCount,
        config.speed
    ))
end

local enemyModelsFolder = ReplicatedStorage:FindFirstChild("EnemyModels")
if not enemyModelsFolder then
    enemyModelsFolder = Instance.new("Folder")
    enemyModelsFolder.Name = "EnemyModels"
    enemyModelsFolder.Parent = ReplicatedStorage
end

for _, enemyName in ipairs({ "Tadpole", "Minnow", "Frog", "Crayfish", "SnappingTurtle" }) do
    generateEnemyModel(enemyModelsFolder, enemyName)
end

print("Enemy model generation complete.")
