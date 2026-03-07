local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("EnemyConfig"))
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))
local PathManager = require(script.Parent:WaitForChild("PathManager"))

local EnemyManager = {}

local enemies: {[string]: any} = {} -- id -> enemy data
local nextId = 0

function EnemyManager.init()
    -- Connect heartbeat for movement
    RunService.Heartbeat:Connect(function(dt)
        EnemyManager._update(dt)
    end)
end

function EnemyManager.spawn(enemyType: string): string
    local config = EnemyConfig[enemyType]
    if not config then
        warn("[EnemyManager] Unknown enemy type: " .. enemyType)
        return ""
    end
    
    nextId += 1
    local id = "enemy_" .. nextId
    
    local startPos = PathManager.getWaypoint(1)
    if not startPos then
        warn("[EnemyManager] No waypoints!")
        return ""
    end
    
    -- Create simple enemy model (a colored part)
    local model = Instance.new("Model")
    model.Name = id
    
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 2, 2)
    body.Position = startPos
    body.Anchored = true
    body.CanCollide = false
    body.Color = Color3.fromRGB(255, 100, 100) -- red-ish
    body.Parent = model
    model.PrimaryPart = body
    
    -- Health bar (BillboardGui)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 60, 0, 10)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = body
    
    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bgFrame.BorderSizePixel = 0
    bgFrame.Parent = billboard
    
    local hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = bgFrame
    
    model.Parent = workspace:FindFirstChild("Enemies") or workspace
    
    local enemyData = {
        id = id,
        enemyType = enemyType,
        health = config.health,
        maxHealth = config.health,
        speed = config.speed,
        damage = config.damage,
        reward = config.reward,
        waypointIndex = 1,
        progress = 0,
        model = model,
    }
    
    enemies[id] = enemyData
    return id
end

function EnemyManager.takeDamage(id: string, amount: number)
    local enemy = enemies[id]
    if not enemy then return end
    
    enemy.health -= amount
    
    -- Update health bar
    if enemy.model then
        local body = enemy.model:FindFirstChild("Body")
        if body then
            local billboard = body:FindFirstChildOfClass("BillboardGui")
            if billboard then
                local bg = billboard:FindFirstChildOfClass("Frame")
                if bg then
                    local hpBar = bg:FindFirstChild("HPBar")
                    if hpBar then
                        hpBar.Size = UDim2.new(math.max(0, enemy.health / enemy.maxHealth), 0, 1, 0)
                    end
                end
            end
        end
    end
    
    if enemy.health <= 0 then
        EventBus.fire("EnemyKilled", id, enemy.enemyType, enemy.reward)
        EnemyManager._removeEnemy(id)
    end
end

function EnemyManager.getEnemy(id: string)
    return enemies[id]
end

function EnemyManager.getAllEnemies()
    return enemies
end

function EnemyManager.getAliveCount(): number
    local count = 0
    for _ in pairs(enemies) do
        count += 1
    end
    return count
end

function EnemyManager.getEnemyPosition(id: string): Vector3?
    local enemy = enemies[id]
    if not enemy or not enemy.model or not enemy.model.PrimaryPart then return nil end
    return enemy.model.PrimaryPart.Position
end

function EnemyManager._update(dt: number)
    for id, enemy in pairs(enemies) do
        local currentWP = PathManager.getWaypoint(enemy.waypointIndex)
        local nextWP = PathManager.getWaypoint(enemy.waypointIndex + 1)
        
        if not currentWP or not nextWP then
            -- Reached end of path
            EventBus.fire("EnemyReachedEnd", id, enemy.damage)
            EnemyManager._removeEnemy(id)
            continue
        end
        
        local direction = (nextWP - currentWP)
        local segmentLength = direction.Magnitude
        if segmentLength == 0 then
            enemy.waypointIndex += 1
            continue
        end
        
        enemy.progress += (enemy.speed * dt) / segmentLength
        
        if enemy.progress >= 1 then
            enemy.progress = 0
            enemy.waypointIndex += 1
            -- Check if we've passed the last waypoint
            if enemy.waypointIndex >= PathManager.getWaypointCount() then
                EventBus.fire("EnemyReachedEnd", id, enemy.damage)
                EnemyManager._removeEnemy(id)
                continue
            end
        else
            -- Lerp position
            local newPos = currentWP:Lerp(nextWP, enemy.progress)
            if enemy.model and enemy.model.PrimaryPart then
                enemy.model.PrimaryPart.Position = newPos
            end
        end
    end
end

function EnemyManager._removeEnemy(id: string)
    local enemy = enemies[id]
    if enemy then
        if enemy.model then
            enemy.model:Destroy()
        end
        enemies[id] = nil
    end
end

return EnemyManager
