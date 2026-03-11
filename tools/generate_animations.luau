--[[
    generate_animations.luau
    Studio command bar script for generating tween-based animations.

    Creates/updates:
    - ReplicatedStorage.modules.AnimationHelper (ModuleScript)
    - ReplicatedStorage.Animations registry folders for tower/enemy animation names
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ANIMATION_HELPER_SOURCE = [==[
local TweenService = game:GetService("TweenService")

local AnimationHelper = {}

local towerIdleState = {}
local towerAttackState = {}
local enemyWalkState = {}
local enemyDeathState = {}

local function collectParts(model, filter)
    local parts = {}
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and (not filter or filter(descendant)) then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local function cancelTweens(tweenList)
    for _, tween in ipairs(tweenList) do
        tween:Cancel()
    end
    table.clear(tweenList)
end

local function connectCompletion(referenceTween, callback)
    local connection
    connection = referenceTween.Completed:Connect(function()
        if connection then
            connection:Disconnect()
        end
        callback()
    end)
end

function AnimationHelper.stopTowerIdle(model)
    local state = towerIdleState[model]
    if not state then
        return
    end

    cancelTweens(state.tweens)

    for part, originalPosition in pairs(state.originalPositions) do
        if part.Parent then
            part.Position = originalPosition
        end
    end

    for part, originalSize in pairs(state.originalSizes) do
        if part.Parent then
            part.Size = originalSize
        end
    end

    towerIdleState[model] = nil
end

function AnimationHelper.startTowerIdle(model)
    if towerIdleState[model] then
        return
    end

    local moveParts = collectParts(model, function(part)
        return part.Name ~= "Base"
    end)

    if #moveParts == 0 then
        return
    end

    local gillParts = collectParts(model, function(part)
        return string.find(part.Name, "Gill") ~= nil
    end)

    local state = {
        tweens = {},
        originalPositions = {},
        originalSizes = {},
    }

    for _, part in ipairs(moveParts) do
        state.originalPositions[part] = part.Position
    end

    for _, part in ipairs(gillParts) do
        state.originalSizes[part] = part.Size
    end

    towerIdleState[model] = state

    local function animateHalf(direction)
        if towerIdleState[model] ~= state or model.Parent == nil then
            AnimationHelper.stopTowerIdle(model)
            return
        end

        cancelTweens(state.tweens)

        local referenceTween = nil
        for _, part in ipairs(moveParts) do
            if part.Parent then
                local goal = {
                    Position = state.originalPositions[part] + Vector3.new(0, 0.5 * direction, 0),
                }
                local tween = TweenService:Create(
                    part,
                    TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    goal
                )
                table.insert(state.tweens, tween)
                tween:Play()
                referenceTween = referenceTween or tween
            end
        end

        for _, part in ipairs(gillParts) do
            local originalSize = state.originalSizes[part]
            if part.Parent and originalSize then
                local goal = {
                    Size = Vector3.new(
                        originalSize.X,
                        originalSize.Y,
                        math.max(0.05, originalSize.Z + (0.08 * direction))
                    ),
                }
                local tween = TweenService:Create(
                    part,
                    TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    goal
                )
                table.insert(state.tweens, tween)
                tween:Play()
                referenceTween = referenceTween or tween
            end
        end

        if referenceTween then
            connectCompletion(referenceTween, function()
                if towerIdleState[model] == state then
                    animateHalf(-direction)
                end
            end)
        end
    end

    animateHalf(1)
end

local function collectAttackParts(model, towerType)
    local parts = {}

    local function includePart(part)
        if part.Name == "Base" then
            return false
        end

        if towerType == "Sparky" then
            return string.find(part.Name, "Antenna")
                or string.find(part.Name, "Cannon")
                or part.Name == "Turret"
                or part.Name == "Head"
                or part.Name == "Torso"
        end

        if towerType == "Rocky" then
            return string.find(part.Name, "Fist")
                or string.find(part.Name, "Shoulder")
                or part.Name == "Turret"
                or part.Name == "Head"
                or part.Name == "Torso"
        end

        if towerType == "Zippy" then
            return string.find(part.Name, "Dart")
                or string.find(part.Name, "Fin")
                or part.Name == "Turret"
                or part.Name == "Head"
                or part.Name == "Torso"
        end

        return part.Name == "Turret" or part.Name == "Head" or part.Name == "Torso"
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and includePart(descendant) then
            table.insert(parts, descendant)
        end
    end

    if #parts == 0 then
        parts = collectParts(model, function(part)
            return part.Name ~= "Base"
        end)
    end

    return parts
end

local function tweenParts(parts, originalCFrames, zOffset, duration)
    local referenceTween = nil

    for _, part in ipairs(parts) do
        local originalCFrame = originalCFrames[part]
        if part.Parent and originalCFrame then
            local goal = {
                CFrame = originalCFrame * CFrame.new(0, 0, zOffset),
            }
            local tween = TweenService:Create(
                part,
                TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                goal
            )
            tween:Play()
            referenceTween = referenceTween or tween
        end
    end

    return referenceTween
end

function AnimationHelper.playTowerAttack(model, towerType)
    if towerAttackState[model] then
        return
    end

    local attackParts = collectAttackParts(model, towerType)
    if #attackParts == 0 then
        return
    end

    towerAttackState[model] = true

    local hadIdle = towerIdleState[model] ~= nil
    if hadIdle then
        AnimationHelper.stopTowerIdle(model)
    end

    local originalCFrames = {}
    for _, part in ipairs(attackParts) do
        originalCFrames[part] = part.CFrame
    end

    local restoreMaterials = {}
    if towerType == "Sparky" then
        for _, part in ipairs(attackParts) do
            if string.find(part.Name, "Antenna") then
                restoreMaterials[part] = part.Material
                part.Material = Enum.Material.Neon
            end
        end
    end

    local function finish()
        for part, originalCFrame in pairs(originalCFrames) do
            if part.Parent then
                part.CFrame = originalCFrame
            end
        end

        for part, originalMaterial in pairs(restoreMaterials) do
            if part.Parent then
                part.Material = originalMaterial
            end
        end

        towerAttackState[model] = nil

        if hadIdle and model.Parent then
            AnimationHelper.startTowerIdle(model)
        end
    end

    local function playSinglePulse(offset, forwardDuration, returnDuration, onDone)
        local forward = tweenParts(attackParts, originalCFrames, offset, forwardDuration)
        if not forward then
            onDone()
            return
        end

        connectCompletion(forward, function()
            local back = tweenParts(attackParts, originalCFrames, 0, returnDuration)
            if not back then
                onDone()
                return
            end
            connectCompletion(back, onDone)
        end)
    end

    if towerType == "Zippy" then
        playSinglePulse(-0.22, 0.055, 0.055, function()
            playSinglePulse(-0.16, 0.055, 0.07, finish)
        end)
        return
    end

    local forwardOffset = -0.35
    local forwardDuration = 0.12
    local returnDuration = 0.14

    if towerType == "Rocky" then
        forwardOffset = -0.45
        forwardDuration = 0.11
        returnDuration = 0.17
    end

    playSinglePulse(forwardOffset, forwardDuration, returnDuration, finish)
end

function AnimationHelper.stopEnemyWalk(model)
    local state = enemyWalkState[model]
    if not state then
        return
    end

    cancelTweens(state.tweens)

    for part, originalSize in pairs(state.originalSizes) do
        if part.Parent then
            part.Size = originalSize
        end
    end

    enemyWalkState[model] = nil
end

function AnimationHelper.startEnemyWalk(model, speed)
    if enemyWalkState[model] then
        return
    end

    local walkParts = collectParts(model, function(part)
        return string.find(part.Name, "Leg")
            or string.find(part.Name, "Fin")
            or string.find(part.Name, "Tail")
    end)

    if #walkParts == 0 and model.PrimaryPart then
        walkParts = { model.PrimaryPart }
    end

    if #walkParts == 0 then
        return
    end

    local state = {
        tweens = {},
        originalSizes = {},
    }

    for _, part in ipairs(walkParts) do
        state.originalSizes[part] = part.Size
    end

    enemyWalkState[model] = state

    local safeSpeed = math.max(1, speed or 8)
    local halfDuration = math.clamp(7 / safeSpeed, 0.12, 0.6)

    local function animateHalf(direction)
        if enemyWalkState[model] ~= state or model.Parent == nil then
            AnimationHelper.stopEnemyWalk(model)
            return
        end

        cancelTweens(state.tweens)

        local referenceTween = nil
        for _, part in ipairs(walkParts) do
            local originalSize = state.originalSizes[part]
            if part.Parent and originalSize then
                local goalSize
                if string.find(part.Name, "Leg") then
                    goalSize = Vector3.new(
                        originalSize.X,
                        math.max(0.05, originalSize.Y + (0.07 * direction)),
                        originalSize.Z
                    )
                elseif string.find(part.Name, "Fin") or string.find(part.Name, "Tail") then
                    goalSize = Vector3.new(
                        originalSize.X,
                        originalSize.Y,
                        math.max(0.05, originalSize.Z + (0.1 * direction))
                    )
                else
                    goalSize = Vector3.new(
                        math.max(0.05, originalSize.X + (0.06 * direction)),
                        originalSize.Y,
                        math.max(0.05, originalSize.Z - (0.06 * direction))
                    )
                end

                local tween = TweenService:Create(
                    part,
                    TweenInfo.new(halfDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { Size = goalSize }
                )
                table.insert(state.tweens, tween)
                tween:Play()
                referenceTween = referenceTween or tween
            end
        end

        if referenceTween then
            connectCompletion(referenceTween, function()
                if enemyWalkState[model] == state then
                    animateHalf(-direction)
                end
            end)
        end
    end

    animateHalf(1)
end

function AnimationHelper.playEnemyDeath(model, onComplete)
    if enemyDeathState[model] then
        return
    end

    enemyDeathState[model] = true
    AnimationHelper.stopEnemyWalk(model)

    local parts = collectParts(model)
    if #parts == 0 then
        enemyDeathState[model] = nil
        if onComplete then
            onComplete()
        end
        return
    end

    local remaining = 0

    local function completeOne()
        remaining -= 1
        if remaining <= 0 then
            enemyDeathState[model] = nil
            if onComplete then
                onComplete()
            end
        end
    end

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false

            local goal = {
                Transparency = 1,
                Size = Vector3.new(
                    math.max(0.05, part.Size.X * 0.05),
                    math.max(0.05, part.Size.Y * 0.05),
                    math.max(0.05, part.Size.Z * 0.05)
                ),
            }

            local tween = TweenService:Create(
                part,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                goal
            )

            remaining += 1
            tween.Completed:Connect(completeOne)
            tween:Play()
        end
    end

    if remaining == 0 then
        enemyDeathState[model] = nil
        if onComplete then
            onComplete()
        end
    end
end

return AnimationHelper
]==]

local function ensureFolder(parent: Instance, name: string): Folder
    local existing = parent:FindFirstChild(name)
    if existing and not existing:IsA("Folder") then
        existing:Destroy()
        existing = nil
    end

    if not existing then
        local folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
        return folder
    end

    return existing
end

local modulesFolder = ensureFolder(ReplicatedStorage, "modules")

local helperModule = modulesFolder:FindFirstChild("AnimationHelper")
if helperModule and not helperModule:IsA("ModuleScript") then
    helperModule:Destroy()
    helperModule = nil
end

if not helperModule then
    helperModule = Instance.new("ModuleScript")
    helperModule.Name = "AnimationHelper"
    helperModule.Parent = modulesFolder
end

helperModule.Source = ANIMATION_HELPER_SOURCE

local animationsFolder = ensureFolder(ReplicatedStorage, "Animations")

local function ensureAnimationRegistry(modelName: string, animationNames: {string})
    local modelFolder = animationsFolder:FindFirstChild(modelName)
    if modelFolder and not modelFolder:IsA("Folder") then
        modelFolder:Destroy()
        modelFolder = nil
    end

    if not modelFolder then
        modelFolder = Instance.new("Folder")
        modelFolder.Name = modelName
        modelFolder.Parent = animationsFolder
    end

    for _, animationName in ipairs(animationNames) do
        local marker = modelFolder:FindFirstChild(animationName)
        if marker and not marker:IsA("StringValue") then
            marker:Destroy()
            marker = nil
        end

        if not marker then
            marker = Instance.new("StringValue")
            marker.Name = animationName
            marker.Parent = modelFolder
        end

        marker.Value = "TweenService"
    end
end

for _, towerName in ipairs({ "Sparky", "Rocky", "Zippy" }) do
    ensureAnimationRegistry(towerName, { "Idle", "Attack" })
end

for _, enemyName in ipairs({ "Tadpole", "Minnow", "Frog", "Crayfish", "SnappingTurtle" }) do
    ensureAnimationRegistry(enemyName, { "Walk", "Death" })
end

print("Animation generation complete: modules.AnimationHelper + Animations registry updated.")
