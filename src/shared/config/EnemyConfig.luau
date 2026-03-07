--[[
    EnemyConfig.luau
    Enemy definitions: stats, rewards, behaviors
    
    Structure:
    {
        [EnemyName] = {
            tier: number (1-3),
            health: number,
            speed: number (studs per second),
            damage: number (to base),
            reward: number (currency awarded on kill),
            description: string
        }
    }
]]

local EnemyConfig = {
    Tadpole = {
        tier = 1,
        health = 30,
        speed = 18,
        damage = 1,
        reward = 5,
        description = "Swarm - appears in groups"
    },
    Minnow = {
        tier = 1,
        health = 25,
        speed = 22,
        damage = 1,
        reward = 5,
        description = "Dart - bursts of speed"
    },
    Frog = {
        tier = 2,
        health = 80,
        speed = 14,
        damage = 3,
        reward = 15,
        description = "Leap - skips obstacles"
    },
    Crayfish = {
        tier = 2,
        health = 150,
        speed = 8,
        damage = 3,
        reward = 15,
        description = "Armor - damage resistance"
    },
    SnappingTurtle = {
        tier = 3,
        health = 300,
        speed = 6,
        damage = 5,
        reward = 30,
        description = "Shell - immune while tucked"
    },
}

return EnemyConfig
