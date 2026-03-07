--[[
    EndScreen.client.luau
    Client-side Game Over and Victory screens
    
    Responsibilities:
    - Listen for GameOver and Victory RemoteEvents
    - Display appropriate end screen with dark overlay
    - Game Over: Red title, wave reached, restart button
    - Victory: Gold title, success message, play again button
    - For MVP, restart button shows chat message to rejoin
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local GameOverEvent = ReplicatedStorage:WaitForChild("GameOver")
local VictoryEvent = ReplicatedStorage:WaitForChild("Victory")

-- UI References
local screenGui
local gameOverFrame
local victoryFrame

--[[
    Create the main ScreenGui
]]
local function createScreenGui()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EndScreens"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100 -- On top of other UI
    screenGui.Parent = playerGui
end

--[[
    Create the Game Over screen
]]
local function createGameOverScreen()
    -- Dark overlay
    gameOverFrame = Instance.new("Frame")
    gameOverFrame.Name = "GameOverFrame"
    gameOverFrame.Size = UDim2.new(1, 0, 1, 0)
    gameOverFrame.Position = UDim2.new(0, 0, 0, 0)
    gameOverFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    gameOverFrame.BackgroundTransparency = 0.3
    gameOverFrame.BorderSizePixel = 0
    gameOverFrame.Visible = false
    gameOverFrame.Parent = screenGui
    
    -- Title: "GAME OVER" in red
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 600, 0, 120)
    titleLabel.Position = UDim2.new(0.5, -300, 0.3, -60)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "GAME OVER"
    titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
    titleLabel.TextSize = 80
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Parent = gameOverFrame
    
    -- Subtitle: "You reached Wave X"
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(0, 500, 0, 60)
    subtitleLabel.Position = UDim2.new(0.5, -250, 0.5, -30)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "You reached Wave 1"
    subtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitleLabel.TextSize = 36
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextStrokeTransparency = 0.5
    subtitleLabel.Parent = gameOverFrame
    
    -- Restart button
    local restartButton = Instance.new("TextButton")
    restartButton.Name = "RestartButton"
    restartButton.Size = UDim2.new(0, 300, 0, 80)
    restartButton.Position = UDim2.new(0.5, -150, 0.7, -40)
    restartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    restartButton.BackgroundTransparency = 0.2
    restartButton.BorderSizePixel = 0
    restartButton.Text = "Restart Game"
    restartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    restartButton.TextSize = 32
    restartButton.Font = Enum.Font.GothamBold
    restartButton.Parent = gameOverFrame
    
    -- Button hover effect
    restartButton.MouseEnter:Connect(function()
        restartButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    end)
    
    restartButton.MouseLeave:Connect(function()
        restartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
    
    -- Button click handler (MVP: show message to rejoin)
    restartButton.MouseButton1Click:Connect(function()
        -- Try to teleport to same place (restart)
        local placeId = game.PlaceId
        local success, err = pcall(function()
            TeleportService:Teleport(placeId, player)
        end)
        
        if not success then
            -- Fallback: show chat message
            player:Kick("Game over! Rejoin to play again.")
        end
    end)
    
    return gameOverFrame
end

--[[
    Create the Victory screen
]]
local function createVictoryScreen()
    -- Dark overlay
    victoryFrame = Instance.new("Frame")
    victoryFrame.Name = "VictoryFrame"
    victoryFrame.Size = UDim2.new(1, 0, 1, 0)
    victoryFrame.Position = UDim2.new(0, 0, 0, 0)
    victoryFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    victoryFrame.BackgroundTransparency = 0.3
    victoryFrame.BorderSizePixel = 0
    victoryFrame.Visible = false
    victoryFrame.Parent = screenGui
    
    -- Title: "VICTORY!" in gold
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 600, 0, 120)
    titleLabel.Position = UDim2.new(0.5, -300, 0.3, -60)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "VICTORY!"
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
    titleLabel.TextSize = 80
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Parent = victoryFrame
    
    -- Subtitle: "All waves cleared!"
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(0, 500, 0, 60)
    subtitleLabel.Position = UDim2.new(0.5, -250, 0.5, -30)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "All waves cleared!"
    subtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitleLabel.TextSize = 36
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextStrokeTransparency = 0.5
    subtitleLabel.Parent = victoryFrame
    
    -- Play Again button
    local playAgainButton = Instance.new("TextButton")
    playAgainButton.Name = "PlayAgainButton"
    playAgainButton.Size = UDim2.new(0, 300, 0, 80)
    playAgainButton.Position = UDim2.new(0.5, -150, 0.7, -40)
    playAgainButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    playAgainButton.BackgroundTransparency = 0.2
    playAgainButton.BorderSizePixel = 0
    playAgainButton.Text = "Play Again"
    playAgainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playAgainButton.TextSize = 32
    playAgainButton.Font = Enum.Font.GothamBold
    playAgainButton.Parent = victoryFrame
    
    -- Button hover effect
    playAgainButton.MouseEnter:Connect(function()
        playAgainButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    end)
    
    playAgainButton.MouseLeave:Connect(function()
        playAgainButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    end)
    
    -- Button click handler (MVP: show message to rejoin)
    playAgainButton.MouseButton1Click:Connect(function()
        -- Try to teleport to same place (restart)
        local placeId = game.PlaceId
        local success, err = pcall(function()
            TeleportService:Teleport(placeId, player)
        end)
        
        if not success then
            -- Fallback: show chat message
            player:Kick("Victory! Rejoin to play again.")
        end
    end)
    
    return victoryFrame
end

--[[
    Show Game Over screen
    @param waveReached: number - Wave number player reached
]]
local function showGameOver(waveReached: number)
    -- Hide other UI
    local gameHUD = playerGui:FindFirstChild("GameHUD")
    if gameHUD then
        gameHUD.Enabled = false
    end
    
    -- Update subtitle with wave reached
    local subtitle = gameOverFrame:FindFirstChild("Subtitle")
    if subtitle then
        subtitle.Text = "You reached Wave " .. waveReached
    end
    
    -- Show game over frame
    gameOverFrame.Visible = true
end

--[[
    Show Victory screen
]]
local function showVictory()
    -- Hide other UI
    local gameHUD = playerGui:FindFirstChild("GameHUD")
    if gameHUD then
        gameHUD.Enabled = false
    end
    
    -- Show victory frame
    victoryFrame.Visible = true
end

--[[
    Initialize the End Screen system
]]
local function init()
    -- Create UI elements
    createScreenGui()
    createGameOverScreen()
    createVictoryScreen()
    
    -- Connect to RemoteEvents
    GameOverEvent.OnClientEvent:Connect(function(waveReached)
        showGameOver(waveReached)
    end)
    
    VictoryEvent.OnClientEvent:Connect(function()
        showVictory()
    end)
    
    print("[AxolotlTD] EndScreen initialized!")
end

-- Initialize
init()
