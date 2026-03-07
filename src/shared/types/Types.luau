--[[
    Types - Shared type definitions for Axolotl Tower Defense
    
    Defines Luau type aliases for game entities and state.
    No runtime logic - pure type exports for static analysis.
]]

-- Tower instance data
export type TowerData = {
    id: string,
    towerType: string,
    position: Vector3,
    tier: number,
    owner: Player?,
}

-- Enemy instance data
export type EnemyData = {
    id: string,
    enemyType: string,
    health: number,
    maxHealth: number,
    speed: number,
    waypointIndex: number,
    progress: number, -- 0-1 between current and next waypoint
    model: Model?,
}

-- Wave progression state
export type WaveState = {
    waveNumber: number,
    state: "preparing" | "active" | "complete",
    enemiesAlive: number,
    enemiesSpawned: number,
    enemiesTotal: number,
}

-- Global game state
export type GameState = {
    baseHealth: number,
    currentWave: number,
    isGameOver: boolean,
    isVictory: boolean,
}

-- Per-player state
export type PlayerState = {
    money: number,
    towersPlaced: number,
}

return {}
