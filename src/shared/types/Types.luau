--[[
    Types.luau
    Type definitions for Axolotl Tower Defense
    
    Provides type aliases for:
    - Tower data structures
    - Enemy data structures
    - Wave data structures
    - Game state
    - Events
]]

export type TowerStats = {
    displayName: string,
    type: "Tech" | "Skill",
    role: "DPS" | "Tank" | "Speed" | "Support",
    cost: number,
    range: number,
    fireRate: number,
    damage: number,
    description: string,
    upgrades: {[number]: TowerUpgrade}?
}

export type TowerUpgrade = {
    cost: number,
    damage: number?,
    range: number?,
    fireRate: number?,
    ability: string?
}

export type TowerData = {
    id: string,
    type: string,
    position: Vector3,
    level: number,
    owner: Player,
    model: Model,
    stats: TowerStats
}

export type EnemyStats = {
    tier: number,
    health: number,
    speed: number,
    damage: number,
    reward: number,
    description: string
}

export type EnemyData = {
    id: string,
    type: string,
    currentHealth: number,
    maxHealth: number,
    speed: number,
    damage: number,
    reward: number,
    position: Vector3,
    waypointIndex: number,
    model: Model
}

export type WaveEnemy = {
    type: string,
    count: number,
    interval: number
}

export type WaveData = {
    enemies: {WaveEnemy}
}

export type GameState = "Lobby" | "Preparing" | "Active" | "Complete" | "GameOver"

export type WaveState = "Preparing" | "Active" | "Complete"

export type Difficulty = "Easy" | "Normal" | "Hard"

export type DifficultyModifiers = {
    hpMult: number,
    speedMult: number,
    spawnMult: number,
    pointMult: number
}

-- Event payload types
export type EnemyKilledEvent = {
    enemyId: string,
    enemyType: string,
    rewardAmount: number
}

export type EnemyReachedEndEvent = {
    enemyId: string,
    damageAmount: number
}

export type TowerPlacedEvent = {
    towerId: string,
    towerType: string,
    position: Vector3,
    owner: Player
}

export type BalanceChangedEvent = {
    player: Player,
    newBalance: number
}

export type BaseHealthChangedEvent = {
    newHealth: number
}

export type WaveStartedEvent = {
    waveNumber: number
}

export type WaveCompletedEvent = {
    waveNumber: number
}

return {}
