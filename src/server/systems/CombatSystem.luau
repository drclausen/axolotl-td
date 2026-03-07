--[[
    CombatSystem.luau
    Handles tower targeting, firing, and damage application
    
    Responsibilities:
    - Each tower finds nearest enemy in range every tick
    - Apply damage based on tower stats and fire rate cooldown
    - Create visual projectiles (simple part tween from tower to enemy)
    - Track tower cooldowns
    
    State:
    - towers: Map<towerId, TowerData>
    
    Dependencies:
    - TowerConfig (stats)
    - EnemyManager (enemy positions, damage)
    - EventBus (for potential future events)
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("TowerConfig"))
local EnemyManager = require(script.Parent:WaitForChild("EnemyManager"))

local CombatSystem = {}

-- Private state
local towers = {} -- Map<towerId, TowerData & { lastFired: number }>
local initialized = false

--[[
    Initialize CombatSystem
    Sets up Heartbeat connection for combat loop
]]
function CombatSystem.init()
    if initialized then
        warn("[CombatSystem] Already initialized")
        return
    end
    
    initialized = true
    
    -- Connect to Heartbeat for combat ticks
    RunService.Heartbeat:Connect(function(dt)
        CombatSystem._tick(dt)
    end)
    
    print("[CombatSystem] Initialized")
end

--[[
    Register a tower for combat
    @param towerData: { id: string, towerType: string, position: Vector3, model: Model }
]]
function CombatSystem.registerTower(towerData)
    assert(towerData.id, "towerData must have an id")
    assert(towerData.towerType, "towerData must have a towerType")
    assert(towerData.position, "towerData must have a position")
    assert(towerData.model, "towerData must have a model")
    
    local config = TowerConfig[towerData.towerType]
    if not config then
        warn("[CombatSystem] Unknown tower type: " .. towerData.towerType)
        return
    end
    
    -- Store tower with combat tracking data
    towers[towerData.id] = {
        id = towerData.id,
        towerType = towerData.towerType,
        position = towerData.position,
        model = towerData.model,
        range = config.range,
        fireRate = config.fireRate,
        damage = config.damage,
        lastFired = -math.huge, -- Allow immediate first shot
    }
    
    print("[CombatSystem] Registered tower:", towerData.id, towerData.towerType)
end

--[[
    Unregister a tower (sold/destroyed)
    @param towerId: string - ID of tower to remove
]]
function CombatSystem.removeTower(towerId: string)
    if towers[towerId] then
        towers[towerId] = nil
        print("[CombatSystem] Removed tower:", towerId)
    end
end

--[[
    Combat tick (called every Heartbeat)
    @param dt: number - Delta time in seconds
]]
function CombatSystem._tick(dt: number)
    local currentTime = os.clock()
    
    for towerId, tower in pairs(towers) do
        -- Check cooldown (time since last shot must exceed 1/fireRate)
        local cooldownTime = 1 / tower.fireRate
        local timeSinceLastFired = currentTime - tower.lastFired
        
        if timeSinceLastFired >= cooldownTime then
            -- Find nearest enemy in range
            local targetId, targetPos = CombatSystem._findNearestEnemy(tower.position, tower.range)
            
            if targetId and targetPos then
                -- Apply damage
                EnemyManager.takeDamage(targetId, tower.damage)
                
                -- Create projectile visual
                CombatSystem._createProjectile(tower.position, targetPos)
                
                -- Update cooldown
                tower.lastFired = currentTime
            end
        end
    end
end

--[[
    Find nearest enemy to a tower within range
    @param towerPosition: Vector3
    @param range: number
    @return (string?, Vector3?) - (enemyId, position) or (nil, nil)
]]
function CombatSystem._findNearestEnemy(towerPosition: Vector3, range: number): (string?, Vector3?)
    local allEnemies = EnemyManager.getAllEnemies()
    local nearestId = nil
    local nearestPos = nil
    local nearestDist = math.huge
    
    for enemyId, enemyData in pairs(allEnemies) do
        local enemyPos = EnemyManager.getEnemyPosition(enemyId)
        if enemyPos then
            local dist = (enemyPos - towerPosition).Magnitude
            if dist <= range and dist < nearestDist then
                nearestDist = dist
                nearestId = enemyId
                nearestPos = enemyPos
            end
        end
    end
    
    return nearestId, nearestPos
end

--[[
    Create projectile visual from tower to enemy
    @param startPos: Vector3
    @param endPos: Vector3
]]
function CombatSystem._createProjectile(startPos: Vector3, endPos: Vector3)
    -- Create a simple projectile part
    local projectile = Instance.new("Part")
    projectile.Name = "Projectile"
    projectile.Size = Vector3.new(0.5, 0.5, 0.5)
    projectile.Position = startPos + Vector3.new(0, 1, 0) -- Slightly above tower
    projectile.Anchored = true
    projectile.CanCollide = false
    projectile.Color = Color3.fromRGB(255, 255, 0) -- Yellow
    projectile.Material = Enum.Material.Neon
    projectile.Shape = Enum.PartType.Ball
    projectile.Parent = workspace
    
    -- Tween to enemy position
    local tweenInfo = TweenInfo.new(
        0.2, -- Duration: 0.2 seconds
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local goal = { Position = endPos + Vector3.new(0, 1, 0) } -- Match enemy height
    local tween = TweenService:Create(projectile, tweenInfo, goal)
    
    -- Destroy projectile when tween completes
    tween.Completed:Connect(function()
        projectile:Destroy()
    end)
    
    tween:Play()
end

--[[
    Get count of registered towers
    @return number
]]
function CombatSystem.getTowerCount(): number
    local count = 0
    for _ in pairs(towers) do
        count += 1
    end
    return count
end

--[[
    Get all registered towers
    @return table
]]
function CombatSystem.getTowers(): {any}
    return towers
end

return CombatSystem
