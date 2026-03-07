--[[
    WaveConfig.luau
    Wave compositions for MVP (10 waves)
    
    Structure:
    {
        [waveNumber] = {
            enemies = {
                {type: string, count: number, interval: number (seconds)},
                ...
            }
        }
    }
    
    Progression design:
    - Wave 1-2: Tadpoles only (tutorial)
    - Wave 3-4: Mix Tadpoles + Minnows (introduce speed)
    - Wave 5: First Frog (tier 2 intro)
    - Wave 6-7: Frog + Minnow combos
    - Wave 8-9: Introduce Crayfish (tier 2 armor)
    - Wave 10: Boss wave with Snapping Turtle + support
]]

local WaveConfig = {
    -- Wave 1: Tutorial - just Tadpoles
    {
        enemies = {
            {type = "Tadpole", count = 5, interval = 1.5}
        }
    },
    
    -- Wave 2: More Tadpoles, faster spawn
    {
        enemies = {
            {type = "Tadpole", count = 8, interval = 1.2}
        }
    },
    
    -- Wave 3: Introduce Minnows (speed enemies)
    {
        enemies = {
            {type = "Tadpole", count = 5, interval = 1.0},
            {type = "Minnow", count = 3, interval = 1.0}
        }
    },
    
    -- Wave 4: More Minnows
    {
        enemies = {
            {type = "Minnow", count = 8, interval = 0.8}
        }
    },
    
    -- Wave 5: Introduce Frog (tier 2)
    {
        enemies = {
            {type = "Tadpole", count = 10, interval = 0.8},
            {type = "Frog", count = 2, interval = 2.0}
        }
    },
    
    -- Wave 6: Frog + Minnow combo
    {
        enemies = {
            {type = "Frog", count = 5, interval = 1.5},
            {type = "Minnow", count = 5, interval = 1.0}
        }
    },
    
    -- Wave 7: Introduce Crayfish (tier 2 armor)
    {
        enemies = {
            {type = "Frog", count = 5, interval = 1.0},
            {type = "Crayfish", count = 2, interval = 2.5}
        }
    },
    
    -- Wave 8: Swarm + armor
    {
        enemies = {
            {type = "Crayfish", count = 5, interval = 2.0},
            {type = "Tadpole", count = 15, interval = 0.5}
        }
    },
    
    -- Wave 9: Mixed tier 2
    {
        enemies = {
            {type = "Crayfish", count = 5, interval = 1.5},
            {type = "Frog", count = 5, interval = 1.0}
        }
    },
    
    -- Wave 10: Boss wave - Snapping Turtle + support
    {
        enemies = {
            {type = "SnappingTurtle", count = 2, interval = 3.0},
            {type = "Frog", count = 8, interval = 0.8},
            {type = "Crayfish", count = 3, interval = 2.0}
        }
    },
}

return WaveConfig
