--[[
    GameConfig.luau
    Global game constants and difficulty modifiers
    
    Structure:
    {
        startingMoney: number,
        baseHealth: number,
        maxTowers: number,
        wavePrepTime: number (seconds),
        maxPlayers: number,
        difficulties: {
            [name] = {
                hpMult: number,
                speedMult: number,
                spawnMult: number,
                pointMult: number
            }
        }
    }
]]

local GameConfig = {
    -- Starting conditions
    startingMoney = 200,
    baseHealth = 100,
    maxTowers = 8,
    wavePrepTime = 10, -- seconds between waves
    maxPlayers = 5,
    
    -- Difficulty modifiers (MVP uses Normal)
    difficulties = {
        Easy = {
            hpMult = 0.75,      -- Enemies have 75% health
            speedMult = 0.8,     -- Enemies move 80% speed
            spawnMult = 0.8,     -- Fewer enemies spawn
            pointMult = 1.0      -- Normal rewards
        },
        Normal = {
            hpMult = 1.0,
            speedMult = 1.0,
            spawnMult = 1.0,
            pointMult = 1.25     -- 25% bonus rewards
        },
        Hard = {
            hpMult = 1.5,        -- Enemies have 50% more health
            speedMult = 1.2,     -- Enemies move 20% faster
            spawnMult = 1.3,     -- More enemies spawn
            pointMult = 1.5      -- 50% bonus rewards
        },
    },
}

return GameConfig
