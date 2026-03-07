--[[
    GameHUD.client.luau
    Client-side Game HUD system
    
    Creates and manages all UI elements:
    - Money display (top right)
    - Wave counter (top center)
    - Base HP bar (top left)
    - Tower shop (bottom center)
    - Feedback messages
    
    Listens for RemoteEvents from server:
    - UpdateBalance
    - UpdateWave
    - UpdateBaseHealth
    - TowerPlacementResult
    
    Tower selection:
    - Sets StringValue "SelectedTower" in ReplicatedStorage
    - TowerPlacement script listens to this value
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Config
local TowerConfig = require(ReplicatedStorage.config.TowerConfig)
local GameConfig = require(ReplicatedStorage.config.GameConfig)

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local UpdateBalanceEvent = ReplicatedStorage:WaitForChild("UpdateBalance")
local UpdateWaveEvent = ReplicatedStorage:WaitForChild("UpdateWave")
local UpdateBaseHealthEvent = ReplicatedStorage:WaitForChild("UpdateBaseHealth")
local TowerPlacementResultEvent = ReplicatedStorage:WaitForChild("TowerPlacementResult")

-- Create or get SelectedTower value
local SelectedTowerValue = ReplicatedStorage:FindFirstChild("SelectedTower")
if not SelectedTowerValue then
    SelectedTowerValue = Instance.new("StringValue")
    SelectedTowerValue.Name = "SelectedTower"
    SelectedTowerValue.Value = ""
    SelectedTowerValue.Parent = ReplicatedStorage
end

-- State
local currentBalance = GameConfig.startingMoney
local currentBaseHealth = GameConfig.baseHealth
local maxBaseHealth = GameConfig.baseHealth
local currentWave = 1
local totalWaves = 10
local waveState = "Preparing"

-- UI References
local screenGui
local moneyLabel
local waveLabel
local hpBar
local hpBarFill
local hpLabel
local shopFrame
local feedbackLabel
local towerButtons = {}

--[[
    Create the main ScreenGui
]]
local function createScreenGui()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
end

--[[
    Create money display (top right)
]]
local function createMoneyDisplay()
    local frame = Instance.new("Frame")
    frame.Name = "MoneyFrame"
    frame.Size = UDim2.new(0, 150, 0, 50)
    frame.Position = UDim2.new(1, -160, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    moneyLabel = Instance.new("TextLabel")
    moneyLabel.Name = "MoneyLabel"
    moneyLabel.Size = UDim2.new(1, 0, 1, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "$" .. currentBalance
    moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    moneyLabel.TextSize = 24
    moneyLabel.Font = Enum.Font.GothamBold
    moneyLabel.Parent = frame
end

--[[
    Create wave counter (top center)
]]
local function createWaveDisplay()
    local frame = Instance.new("Frame")
    frame.Name = "WaveFrame"
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(0.5, -125, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    waveLabel = Instance.new("TextLabel")
    waveLabel.Name = "WaveLabel"
    waveLabel.Size = UDim2.new(1, 0, 1, 0)
    waveLabel.BackgroundTransparency = 1
    waveLabel.Text = "Wave " .. currentWave .. "/" .. totalWaves .. "\n" .. waveState
    waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    waveLabel.TextSize = 20
    waveLabel.Font = Enum.Font.GothamBold
    waveLabel.Parent = frame
end

--[[
    Create base HP bar (top left)
]]
local function createHealthDisplay()
    local frame = Instance.new("Frame")
    frame.Name = "HealthFrame"
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- HP label
    hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HPLabel"
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0, 0, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: " .. currentBaseHealth .. "/" .. maxBaseHealth
    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpLabel.TextSize = 18
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.Parent = frame
    
    -- HP bar background
    hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(0.9, 0, 0.3, 0)
    hpBar.Position = UDim2.new(0.05, 0, 0.6, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = frame
    
    -- HP bar fill
    hpBarFill = Instance.new("Frame")
    hpBarFill.Name = "Fill"
    hpBarFill.Size = UDim2.new(1, 0, 1, 0)
    hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpBarFill.BorderSizePixel = 0
    hpBarFill.Parent = hpBar
end

--[[
    Create tower shop (bottom center)
]]
local function createTowerShop()
    shopFrame = Instance.new("Frame")
    shopFrame.Name = "TowerShop"
    shopFrame.Size = UDim2.new(0, 600, 0, 100)
    shopFrame.Position = UDim2.new(0.5, -300, 1, -110)
    shopFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shopFrame.BackgroundTransparency = 0.4
    shopFrame.BorderSizePixel = 0
    shopFrame.Parent = screenGui
    
    -- Tower buttons
    local towers = {"Sparky", "Rocky", "Zippy"}
    local colors = {
        Sparky = Color3.fromRGB(255, 255, 0), -- Yellow
        Rocky = Color3.fromRGB(139, 90, 43),  -- Brown
        Zippy = Color3.fromRGB(0, 255, 127),  -- Green
    }
    
    for i, towerName in ipairs(towers) do
        local config = TowerConfig[towerName]
        if not config then continue end
        
        local button = Instance.new("TextButton")
        button.Name = towerName .. "Button"
        button.Size = UDim2.new(0, 180, 0, 80)
        button.Position = UDim2.new(0, (i - 1) * 200 + 10, 0, 10)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        button.BackgroundTransparency = 0.3
        button.BorderSizePixel = 2
        button.BorderColor3 = colors[towerName]
        button.Text = config.displayName .. "\n$" .. config.cost
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.GothamBold
        button.Parent = shopFrame
        
        -- Button click handler
        button.MouseButton1Click:Connect(function()
            -- Toggle selection
            if SelectedTowerValue.Value == towerName then
                -- Deselect
                SelectedTowerValue.Value = ""
                button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                -- Select
                SelectedTowerValue.Value = towerName
                -- Update button visuals
                for _, btn in pairs(towerButtons) do
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end
                button.BackgroundColor3 = colors[towerName]
            end
        end)
        
        towerButtons[towerName] = button
    end
end

--[[
    Create feedback label (for placement results)
]]
local function createFeedbackLabel()
    feedbackLabel = Instance.new("TextLabel")
    feedbackLabel.Name = "FeedbackLabel"
    feedbackLabel.Size = UDim2.new(0, 400, 0, 40)
    feedbackLabel.Position = UDim2.new(0.5, -200, 0.5, -20)
    feedbackLabel.BackgroundTransparency = 1
    feedbackLabel.Text = ""
    feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    feedbackLabel.TextSize = 24
    feedbackLabel.Font = Enum.Font.GothamBold
    feedbackLabel.TextStrokeTransparency = 0.5
    feedbackLabel.Parent = screenGui
end

--[[
    Show feedback message briefly
    @param message: string
    @param isSuccess: boolean
]]
local function showFeedback(message: string, isSuccess: boolean)
    feedbackLabel.Text = message
    feedbackLabel.TextColor3 = isSuccess and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    -- Hide after 2 seconds
    task.delay(2, function()
        if feedbackLabel.Text == message then
            feedbackLabel.Text = ""
        end
    end)
end

--[[
    Update money display
    @param amount: number
]]
local function updateBalance(amount: number)
    currentBalance = amount
    moneyLabel.Text = "$" .. currentBalance
end

--[[
    Update wave counter
    @param waveNumber: number
    @param totalWavesCount: number
    @param state: string
]]
local function updateWave(waveNumber: number, totalWavesCount: number, state: string)
    currentWave = waveNumber
    totalWaves = totalWavesCount
    waveState = state
    waveLabel.Text = "Wave " .. currentWave .. "/" .. totalWaves .. "\n" .. state
end

--[[
    Update base health bar
    @param current: number
    @param max: number
]]
local function updateBaseHealth(current: number, max: number)
    currentBaseHealth = current
    maxBaseHealth = max
    hpLabel.Text = "HP: " .. currentBaseHealth .. "/" .. maxBaseHealth
    
    -- Update fill bar
    local healthPercent = currentBaseHealth / maxBaseHealth
    hpBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
    
    -- Change color based on health percentage
    if healthPercent > 0.6 then
        hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
    elseif healthPercent > 0.3 then
        hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
    else
        hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
    end
end

--[[
    Handle tower placement result
    @param success: boolean
    @param message: string
]]
local function onTowerPlacementResult(success: boolean, message: string)
    showFeedback(message, success)
end

--[[
    Initialize the HUD
]]
local function init()
    -- Create UI elements
    createScreenGui()
    createMoneyDisplay()
    createWaveDisplay()
    createHealthDisplay()
    createTowerShop()
    createFeedbackLabel()
    
    -- Connect to RemoteEvents
    UpdateBalanceEvent.OnClientEvent:Connect(updateBalance)
    UpdateWaveEvent.OnClientEvent:Connect(updateWave)
    UpdateBaseHealthEvent.OnClientEvent:Connect(updateBaseHealth)
    TowerPlacementResultEvent.OnClientEvent:Connect(onTowerPlacementResult)
    
    print("GameHUD initialized!")
end

-- Initialize
init()
