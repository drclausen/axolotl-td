--[[
    TowerConfig.luau
    Tower definitions: stats, costs, upgrade paths
    
    Structure:
    {
        [TowerName] = {
            displayName: string,
            type: "Tech" | "Skill",
            role: "DPS" | "Tank" | "Speed" | "Support",
            cost: number,
            range: number (studs),
            fireRate: number (shots per second),
            damage: number,
            description: string,
            upgrades: {
                [level] = { cost, ...stat overrides }
            }
        }
    }
]]

local TowerConfig = {
    Sparky = {
        displayName = "Sparky",
        type = "Tech",
        role = "DPS",
        cost = 100,
        range = 15,
        fireRate = 1.0, -- shots per second
        damage = 10,
        description = "Zap turret - single target lightning",
        upgrades = {
            [2] = { cost = 100, damage = 15, range = 18, fireRate = 1.2 },
            [3] = { cost = 250, damage = 25, range = 20, fireRate = 1.5, ability = "ChainLightning" },
        },
    },
    Rocky = {
        displayName = "Rocky",
        type = "Skill",
        role = "Tank",
        cost = 75,
        range = 8,
        fireRate = 0.5,
        damage = 25,
        description = "Body slam - knockback enemies",
        upgrades = {
            [2] = { cost = 100, damage = 35, range = 10, fireRate = 0.6 },
            [3] = { cost = 250, damage = 50, range = 12, fireRate = 0.7, ability = "Earthquake" },
        },
    },
    Zippy = {
        displayName = "Zippy",
        type = "Skill",
        role = "Speed",
        cost = 50,
        range = 12,
        fireRate = 2.0,
        damage = 5,
        description = "Quick strike - fast attacks, low damage",
        upgrades = {
            [2] = { cost = 100, damage = 8, range = 14, fireRate = 2.5 },
            [3] = { cost = 250, damage = 12, range = 16, fireRate = 3.0, ability = "BlurStrike" },
        },
    },
}

return TowerConfig
