--[[
    generate_towers.luau
    Studio command bar script for generating tower models in ReplicatedStorage.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("TowerConfig"))

local MAX_PARTS_PER_TOWER = 30

type TowerStyle = {
    baseColor: Color3,
    bodyColor: Color3,
    headColor: Color3,
    gillColor: Color3,
    eyeColor: Color3,
    accentColor: Color3,
    torsoSize: Vector3,
    headSize: Vector3,
    legSize: Vector3,
    tailSize: Vector3,
}

local styles: {[string]: TowerStyle} = {
    Sparky = {
        baseColor = Color3.fromRGB(244, 208, 74),
        bodyColor = Color3.fromRGB(255, 230, 136),
        headColor = Color3.fromRGB(255, 240, 165),
        gillColor = Color3.fromRGB(255, 173, 87),
        eyeColor = Color3.fromRGB(17, 17, 17),
        accentColor = Color3.fromRGB(133, 240, 255),
        torsoSize = Vector3.new(1.9, 1.1, 2.0),
        headSize = Vector3.new(1.5, 1.0, 1.5),
        legSize = Vector3.new(0.45, 0.35, 0.55),
        tailSize = Vector3.new(1.0, 0.6, 1.3),
    },
    Rocky = {
        baseColor = Color3.fromRGB(108, 80, 58),
        bodyColor = Color3.fromRGB(130, 102, 74),
        headColor = Color3.fromRGB(146, 114, 83),
        gillColor = Color3.fromRGB(166, 138, 104),
        eyeColor = Color3.fromRGB(20, 20, 20),
        accentColor = Color3.fromRGB(187, 164, 126),
        torsoSize = Vector3.new(2.3, 1.4, 2.2),
        headSize = Vector3.new(1.7, 1.2, 1.8),
        legSize = Vector3.new(0.65, 0.45, 0.7),
        tailSize = Vector3.new(1.2, 0.7, 1.4),
    },
    Zippy = {
        baseColor = Color3.fromRGB(58, 156, 124),
        bodyColor = Color3.fromRGB(83, 203, 165),
        headColor = Color3.fromRGB(99, 218, 183),
        gillColor = Color3.fromRGB(72, 245, 202),
        eyeColor = Color3.fromRGB(14, 23, 20),
        accentColor = Color3.fromRGB(132, 255, 227),
        torsoSize = Vector3.new(1.7, 1.0, 2.4),
        headSize = Vector3.new(1.4, 0.95, 1.45),
        legSize = Vector3.new(0.4, 0.3, 0.5),
        tailSize = Vector3.new(0.9, 0.55, 1.4),
    },
}

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
    part.Anchored = true
    part.CanCollide = name == "Base"
    part.CanQuery = name == "Base"
    part.CanTouch = name == "Base"
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

local function createWedge(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): WedgePart
    local wedge = Instance.new("WedgePart")
    wedge.Name = name
    wedge.Size = size
    wedge.CFrame = cframe
    wedge.Anchored = true
    wedge.CanCollide = false
    wedge.CanQuery = false
    wedge.CanTouch = false
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

local function addCommonAxolotlBody(model: Model, style: TowerStyle): {[string]: BasePart}
    local base = createPart(
        model,
        "Base",
        Vector3.new(3, 1, 3),
        CFrame.new(0, 0.5, 0),
        style.baseColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Block
    )
    local torso = createPart(
        model,
        "Torso",
        style.torsoSize,
        CFrame.new(0, 1.45, 0),
        style.bodyColor
    )
    local head = createPart(
        model,
        "Head",
        style.headSize,
        CFrame.new(0, 2.2, -0.95),
        style.headColor
    )

    local gillOffsets = {
        Vector3.new(-0.95, 2.2, -0.95),
        Vector3.new(-0.95, 2.36, -0.82),
        Vector3.new(-0.95, 2.04, -0.78),
        Vector3.new(0.95, 2.2, -0.95),
        Vector3.new(0.95, 2.36, -0.82),
        Vector3.new(0.95, 2.04, -0.78),
    }
    for index, offset in ipairs(gillOffsets) do
        createPart(
            model,
            "Gill" .. tostring(index),
            Vector3.new(0.22, 0.32, 0.45),
            CFrame.new(offset),
            style.gillColor
        )
    end

    createPart(
        model,
        "EyeLeft",
        Vector3.new(0.2, 0.2, 0.2),
        CFrame.new(-0.35, 2.35, -1.66),
        style.eyeColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "EyeRight",
        Vector3.new(0.2, 0.2, 0.2),
        CFrame.new(0.35, 2.35, -1.66),
        style.eyeColor,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "PupilLeft",
        Vector3.new(0.1, 0.1, 0.1),
        CFrame.new(-0.32, 2.37, -1.75),
        Color3.fromRGB(245, 245, 245),
        Enum.Material.Neon,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "PupilRight",
        Vector3.new(0.1, 0.1, 0.1),
        CFrame.new(0.32, 2.37, -1.75),
        Color3.fromRGB(245, 245, 245),
        Enum.Material.Neon,
        Enum.PartType.Ball
    )

    local legOffsets = {
        Vector3.new(-0.6, 0.85, -0.55),
        Vector3.new(0.6, 0.85, -0.55),
        Vector3.new(-0.6, 0.85, 0.55),
        Vector3.new(0.6, 0.85, 0.55),
    }
    for index, offset in ipairs(legOffsets) do
        createPart(model, "Leg" .. tostring(index), style.legSize, CFrame.new(offset), style.bodyColor)
    end

    createWedge(
        model,
        "Tail",
        style.tailSize,
        CFrame.new(0, 1.3, 1.55) * CFrame.Angles(0, math.rad(180), 0),
        style.bodyColor
    )

    model.PrimaryPart = base
    return {
        base = base,
        torso = torso,
        head = head,
    }
end

local function addSparkyFeatures(model: Model, bodyParts: {[string]: BasePart}, style: TowerStyle)
    createPart(
        model,
        "AntennaStem",
        Vector3.new(0.16, 0.85, 0.16),
        CFrame.new(0, 2.65, 0.6) * CFrame.Angles(0, 0, math.rad(90)),
        style.accentColor,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )
    createPart(
        model,
        "AntennaOrb",
        Vector3.new(0.32, 0.32, 0.32),
        CFrame.new(0, 3.15, 0.6),
        style.accentColor,
        Enum.Material.Neon,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "CannonBase",
        Vector3.new(0.55, 0.35, 0.7),
        CFrame.new(0, 2.75, -0.2),
        style.baseColor,
        Enum.Material.Metal
    )
    createPart(
        model,
        "CannonBarrel",
        Vector3.new(0.24, 0.24, 0.95),
        CFrame.new(0, 2.75, -0.95) * CFrame.Angles(0, math.rad(90), 0),
        style.accentColor,
        Enum.Material.Neon,
        Enum.PartType.Cylinder
    )
    createPart(
        model,
        "ElectricAccentLeft",
        Vector3.new(0.08, 0.65, 1.2),
        bodyParts.torso.CFrame * CFrame.new(-0.95, 0, 0),
        style.accentColor,
        Enum.Material.Neon
    )
    createPart(
        model,
        "ElectricAccentRight",
        Vector3.new(0.08, 0.65, 1.2),
        bodyParts.torso.CFrame * CFrame.new(0.95, 0, 0),
        style.accentColor,
        Enum.Material.Neon
    )
end

local function addRockyFeatures(model: Model, bodyParts: {[string]: BasePart}, style: TowerStyle)
    local armorOffsets = {
        Vector3.new(0, 0.38, -0.5),
        Vector3.new(0.95, 0.2, 0),
        Vector3.new(-0.95, 0.2, 0),
        Vector3.new(0, 0.1, 0.6),
    }
    for index, offset in ipairs(armorOffsets) do
        createPart(
            model,
            "ArmorPlate" .. tostring(index),
            Vector3.new(0.85, 0.35, 0.5),
            bodyParts.torso.CFrame * CFrame.new(offset),
            style.accentColor,
            Enum.Material.Slate
        )
    end

    createPart(
        model,
        "FistLeft",
        Vector3.new(0.88, 0.88, 0.88),
        CFrame.new(-1.55, 1.4, -0.25),
        style.baseColor,
        Enum.Material.Rock,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "FistRight",
        Vector3.new(0.88, 0.88, 0.88),
        CFrame.new(1.55, 1.4, -0.25),
        style.baseColor,
        Enum.Material.Rock,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "ShoulderLeft",
        Vector3.new(0.55, 0.45, 0.55),
        CFrame.new(-1.0, 1.55, -0.15),
        style.bodyColor,
        Enum.Material.Slate
    )
    createPart(
        model,
        "ShoulderRight",
        Vector3.new(0.55, 0.45, 0.55),
        CFrame.new(1.0, 1.55, -0.15),
        style.bodyColor,
        Enum.Material.Slate
    )
end

local function addZippyFeatures(model: Model, bodyParts: {[string]: BasePart}, style: TowerStyle)
    createWedge(
        model,
        "FinLeft",
        Vector3.new(0.35, 0.6, 0.9),
        CFrame.new(-0.55, 1.9, 0.65) * CFrame.Angles(0, math.rad(-30), 0),
        style.accentColor,
        Enum.Material.SmoothPlastic
    )
    createWedge(
        model,
        "FinRight",
        Vector3.new(0.35, 0.6, 0.9),
        CFrame.new(0.55, 1.9, 0.65) * CFrame.Angles(0, math.rad(30), 0),
        style.accentColor,
        Enum.Material.SmoothPlastic
    )

    local launcherLeft = createPart(
        model,
        "DartLauncherLeft",
        Vector3.new(0.2, 0.2, 0.9),
        CFrame.new(-1.0, 1.75, -0.2) * CFrame.Angles(0, math.rad(90), 0),
        style.accentColor,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )
    local launcherRight = createPart(
        model,
        "DartLauncherRight",
        Vector3.new(0.2, 0.2, 0.9),
        CFrame.new(1.0, 1.75, -0.2) * CFrame.Angles(0, math.rad(90), 0),
        style.accentColor,
        Enum.Material.Metal,
        Enum.PartType.Cylinder
    )

    createPart(
        model,
        "DartTipLeft",
        Vector3.new(0.18, 0.18, 0.18),
        launcherLeft.CFrame * CFrame.new(0, 0, -0.5),
        Color3.fromRGB(238, 255, 249),
        Enum.Material.Neon,
        Enum.PartType.Ball
    )
    createPart(
        model,
        "DartTipRight",
        Vector3.new(0.18, 0.18, 0.18),
        launcherRight.CFrame * CFrame.new(0, 0, -0.5),
        Color3.fromRGB(238, 255, 249),
        Enum.Material.Neon,
        Enum.PartType.Ball
    )

    local speedDecal = Instance.new("Decal")
    speedDecal.Name = "SpeedLines"
    speedDecal.Texture = "rbxassetid://3926305904"
    speedDecal.Color3 = style.accentColor
    speedDecal.Transparency = 0.15
    speedDecal.Face = Enum.NormalId.Top
    speedDecal.Parent = bodyParts.torso
end

local function generateTowerModel(towerFolder: Folder, towerName: string)
    local config = TowerConfig[towerName]
    if not config then
        warn("Skipping missing tower config: " .. towerName)
        return
    end

    local style = styles[towerName]
    if not style then
        warn("Skipping tower with no generation style: " .. towerName)
        return
    end

    local existing = towerFolder:FindFirstChild(towerName)
    if existing then
        existing:Destroy()
    end

    local model = Instance.new("Model")
    model.Name = towerName
    model.Parent = towerFolder

    local bodyParts = addCommonAxolotlBody(model, style)

    if towerName == "Sparky" then
        addSparkyFeatures(model, bodyParts, style)
    elseif towerName == "Rocky" then
        addRockyFeatures(model, bodyParts, style)
    elseif towerName == "Zippy" then
        addZippyFeatures(model, bodyParts, style)
    end

    local rangeValue = Instance.new("NumberValue")
    rangeValue.Name = "Range"
    rangeValue.Value = config.range
    rangeValue.Parent = model

    local partCount = countParts(model)
    if partCount > MAX_PARTS_PER_TOWER then
        warn(string.format("%s generated with %d parts (over %d)", towerName, partCount, MAX_PARTS_PER_TOWER))
    end

    print(string.format("Generated tower model: %s (%d parts, range %.1f)", towerName, partCount, rangeValue.Value))
end

local towerModelsFolder = ReplicatedStorage:FindFirstChild("TowerModels")
if not towerModelsFolder then
    towerModelsFolder = Instance.new("Folder")
    towerModelsFolder.Name = "TowerModels"
    towerModelsFolder.Parent = ReplicatedStorage
end

for _, towerName in ipairs({ "Sparky", "Rocky", "Zippy" }) do
    generateTowerModel(towerModelsFolder, towerName)
end

print("Tower model generation complete.")
