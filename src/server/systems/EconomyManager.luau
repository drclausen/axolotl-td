local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage:WaitForChild("config"):WaitForChild("GameConfig"))
local EventBus = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("EventBus"))

local EconomyManager = {}
local balances: {[Player]: number} = {}

function EconomyManager.init()
    -- Give starting money to new players
    Players.PlayerAdded:Connect(function(player)
        balances[player] = GameConfig.startingMoney
        EventBus.fire("BalanceChanged", player, balances[player])
    end)
    Players.PlayerRemoving:Connect(function(player)
        balances[player] = nil
    end)
    -- Award money on enemy kill
    EventBus.on("EnemyKilled", function(enemyId, enemyType, reward)
        -- Award to all players for now (cooperative)
        for player, _ in pairs(balances) do
            balances[player] += reward
            EventBus.fire("BalanceChanged", player, balances[player])
        end
    end)
    -- Init existing players
    for _, player in ipairs(Players:GetPlayers()) do
        balances[player] = GameConfig.startingMoney
        EventBus.fire("BalanceChanged", player, balances[player])
    end
end

function EconomyManager.getBalance(player: Player): number
    return balances[player] or 0
end

function EconomyManager.canAfford(player: Player, amount: number): boolean
    return (balances[player] or 0) >= amount
end

function EconomyManager.spend(player: Player, amount: number): boolean
    if not EconomyManager.canAfford(player, amount) then return false end
    balances[player] -= amount
    EventBus.fire("BalanceChanged", player, balances[player])
    return true
end

function EconomyManager.award(player: Player, amount: number)
    balances[player] = (balances[player] or 0) + amount
    EventBus.fire("BalanceChanged", player, balances[player])
end

return EconomyManager
