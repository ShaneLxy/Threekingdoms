class_name BattleRenderer
extends Node2D

const PLAYER_SPRITE_SCALE := 0.75
const PLAYER_SOURCE_FOOT_ANCHOR := Vector2(64, 99)
const PLAYER_WORLD_FOOT_OFFSET := Vector2(0, 13)
const PLAYER_IDLE_FRAME_DURATION := 0.22
const PLAYER_WALK_FRAME_DURATION := 0.10
const PLAYER_ATTACK_01_FRAME_DURATION := 0.06
const PLAYER_ATTACK_02_FRAME_DURATION := 0.08
const PLAYER_ATTACK_03_FRAME_DURATION := 0.08
const PLAYER_ATTACK_04_FRAME_DURATION := 0.08
const PLAYER_ATTACK_05_FRAME_DURATION := 0.15
const PLAYER_GUARD_FRAME_DURATION := 0.15
const GUAN_YU_GUARD_FRAME_DURATION := 0.10
const ZHANG_FEI_GUARD_FRAME_DURATION := 0.10
const ZHANG_FEI_GUARD_FRAMES := [1, 3, 8]
const GUARD_SHIELD_FRAME_DURATION := 0.075
const GUARD_SHIELD_SCALE := 0.46
const GUARD_SHIELD_TEXTURES: Array[Texture2D] = [
	preload("res://assets/art/effects/guard/guard-01.png"),
	preload("res://assets/art/effects/guard/guard-02.png"),
	preload("res://assets/art/effects/guard/guard-03.png"),
	preload("res://assets/art/effects/guard/guard-04.png"),
]
const LOOT_COIN_TEXTURE: Texture2D = preload("res://assets/art/ui/coin.png")
const LOOT_COIN_SOURCE_RECT := Rect2(38.0, 56.0, 334.0, 296.0)
const LOOT_COIN_DISPLAY_SIZE := Vector2(16.0, 15.0)
const PLAYER_ATTACK_04_SOURCE_FOOT_ANCHOR := Vector2(64, 82)
const PLAYER_ATTACK_05_FOOT_ANCHORS := [Vector2(64, 100), Vector2(64, 87)]
const PLAYER_DEATH_SOURCE_FOOT_ANCHOR := Vector2(64, 86)
const PLAYER_DEATH_FRAME_01_DURATION := 0.12
const PLAYER_DEATH_FRAME_02_DURATION := 0.12
const PLAYER_DEATH_FRAME_03_DURATION := 0.34
const PLAYER_DEATH_FRAME_04_DURATION := 0.72
const PLAYER_DEATH_CINEMATIC_DURATION := PLAYER_DEATH_FRAME_01_DURATION + PLAYER_DEATH_FRAME_02_DURATION + PLAYER_DEATH_FRAME_03_DURATION + PLAYER_DEATH_FRAME_04_DURATION
const ZHANG_FEI_DEATH_FRAME_DURATIONS: Array[float] = [0.12, 0.16, 0.30, 0.72]
const ZHANG_FEI_DEATH_CINEMATIC_DURATION := 1.30
const SPEAR_VFX_HEIGHT_OFFSET := Vector2(0, -12)
const SWEEP_VFX_HEIGHT_OFFSET := Vector2(0, -22)
const FLASH_DURATION := 0.16
const PLAYER_HIT_FLASH_DURATION := 0.16
const PLAYER_HIT_FLASH_PEAK_DURATION := 0.045
const FIREWHEEL_PROJECTILE_FLASH_DURATION := 0.38
const FIREWHEEL_RING_SPEED := 420.0
const FIREWHEEL_RING_RADIUS := 68.0
const GUAN_BLADE_WAVE_SPEED := 520.0
const GUAN_KNIFE_WAVE_SOURCE_ANCHOR := Vector2(24.0, 204.0)
const GUAN_KNIFE_WAVE_FRAME_DURATION := 0.040
const GUAN_KNIFE_WAVE_FADE_DURATION := GUAN_KNIFE_WAVE_FRAME_DURATION * 3.0
const GUAN_KNIFE_WAVE_EXPANSION_DURATION := 0.40
const GUAN_KNIFE_WAVE_INFINITE_HOLD_DURATION := 0.16
const GUAN_KNIFE_WAVE_EXPANSION_FRAMES: Array[int] = [0, 1, 2, 4, 5, 7, 9, 10, 11, 13]
const GUAN_KNIFE_WAVE_FADE_FRAMES: Array[int] = [14, 15, 17]
const GUAN_KNIFE_WAVE_FIT_PADDING := 24.0
const GUAN_KNIFE_WUSHENG_FIXED_SCALE := 1.24
const GUAN_KNIFE_WAVE_TEXTURES := {
	0: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_00.png"),
	1: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_01.png"),
	2: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_02.png"),
	4: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_04.png"),
	5: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_05.png"),
	7: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_07.png"),
	9: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_09.png"),
	10: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_10.png"),
	11: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_11.png"),
	13: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_13.png"),
	14: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_14.png"),
	15: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_15.png"),
	17: preload("res://assets/art/characters/guan_yu/effects/knife_wave_cyan_gold/067 MYNSZD E53216_17.png"),
}
const ENEMY_MOVE_ANIMATION_HOLD := 0.12
const BOSS_TRIAL_ARENA_BOUNDS := BattlefieldLayout.BOSS_TRIAL_ARENA_BOUNDS
const TRIAL_ATMOSPHERE_ATTACK_INTERVAL := 3.20
const TRIAL_ATMOSPHERE_ATTACK_DURATION := 0.52
const TRIAL_ATMOSPHERE_GUARD_SCALE := 0.52
const TRIAL_ATMOSPHERE_POSITIONS: Array[Dictionary] = [
	{"position": Vector2(305.0, 188.0), "shield": true, "phase": 0.00},
	{"position": Vector2(453.0, 176.0), "shield": false, "phase": 0.62},
	{"position": Vector2(627.0, 169.0), "shield": true, "phase": 1.24},
	{"position": Vector2(810.0, 169.0), "shield": false, "phase": 1.86},
	{"position": Vector2(993.0, 176.0), "shield": true, "phase": 2.48},
	{"position": Vector2(1184.0, 188.0), "shield": false, "phase": 3.10},
	{"position": Vector2(305.0, 810.0), "shield": false, "phase": 1.58},
	{"position": Vector2(470.0, 824.0), "shield": true, "phase": 2.20},
	{"position": Vector2(662.0, 831.0), "shield": false, "phase": 2.82},
	{"position": Vector2(862.0, 831.0), "shield": true, "phase": 3.44},
	{"position": Vector2(1054.0, 824.0), "shield": false, "phase": 4.06},
	{"position": Vector2(1219.0, 810.0), "shield": true, "phase": 4.68},
	{"position": Vector2(239.0, 305.0), "shield": true, "phase": 0.94},
	{"position": Vector2(225.0, 496.0), "shield": false, "phase": 2.34},
	{"position": Vector2(230.0, 688.0), "shield": true, "phase": 3.74},
	{"position": Vector2(1435.0, 305.0), "shield": false, "phase": 1.34},
	{"position": Vector2(1447.0, 496.0), "shield": true, "phase": 2.74},
	{"position": Vector2(1442.0, 688.0), "shield": false, "phase": 4.14},
]
const TIANJI_ARROW_VOLLEY_RADIUS := 230.0
const TIANJI_ARROW_VOLLEY_ARROW_COUNT := 18
const VICTORY_ARROW_SALVO_ARROW_COUNT := 28
const TIANJI_ARROW_FLIGHT_DURATION := 0.40
const TIANJI_ARROW_LODGED_DURATION := 0.92
const TIANJI_ARROW_MAX_VOLLEY_MARKS := 4
const TIANJI_ARROW_TEXTURE_SCALE := 0.70
const TIANJI_ARROW_SOURCE_EXPOSED := Rect2(25.0, 27.0, 53.0, 12.0)
const TIANJI_ARROW_SOURCE_ANCHOR := Vector2(64.0, 32.0)
const TIANJI_ARROW_TRAIL_LENGTH := 86.0
const TIANJI_ARROW_SKY_ENTRY_OFFSET := 42.0
const TIANJI_LIGHTNING_FRAME_DURATION := 0.05
const TIANJI_LIGHTNING_SOURCE_IMPACT_ANCHOR := Vector2(930.0, 895.0)
const TIANJI_LIGHTNING_SOURCE_ENTRY_ANCHOR := Vector2(930.0, 164.0)
const TIANJI_LIGHTNING_SKY_EDGE_OFFSET := 6.0
const TIANJI_LIGHTNING_TEXTURES := {
	"1": preload("res://assets/art/effects/tianji/lightning/1.png"),
	"1-2": preload("res://assets/art/effects/tianji/lightning/1-2.png"),
	"1-3": preload("res://assets/art/effects/tianji/lightning/1-3.png"),
	"1-4": preload("res://assets/art/effects/tianji/lightning/1-4.png"),
	"1-5": preload("res://assets/art/effects/tianji/lightning/1-5.png"),
	"1-5-1": preload("res://assets/art/effects/tianji/lightning/1-5-1.png"),
	"2": preload("res://assets/art/effects/tianji/lightning/2.png"),
	"3": preload("res://assets/art/effects/tianji/lightning/3.png"),
	"4": preload("res://assets/art/effects/tianji/lightning/4.png"),
	"5": preload("res://assets/art/effects/tianji/lightning/5.png"),
}
const TIANJI_LIGHTNING_FRAME_SEQUENCES := {
	1: ["1", "2", "3", "4", "5"],
	2: ["1", "1-2", "2", "3", "4", "5"],
	3: ["1", "1-3", "2", "3", "4", "5"],
	4: ["1", "1-4", "1-2", "2", "3", "4", "5"],
	5: ["1", "1-5", "1-5-1", "1-2", "2", "3", "4", "5"],
}
const TIANJI_WIND_FORMATION_FRAME_DURATION := 0.030
const TIANJI_WIND_CORE_FRAME_DURATION := 0.050
const TIANJI_WIND_COLLAPSE_FRAME_DURATION := 0.045
const TIANJI_WIND_SOURCE_ANCHOR := Vector2(126.0, 261.0)
const TIANJI_WIND_FORMATION_FRAMES: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8]
const TIANJI_WIND_CORE_FRAMES: Array[int] = [9, 10, 11, 12, 13]
const TIANJI_WIND_COLLAPSE_FRAMES: Array[int] = [14, 15, 16, 17, 18, 19, 20, 21, 22]
const TIANJI_WIND_TEXTURES: Array[Texture2D] = [
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_00.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_01.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_02.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_03.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_04.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_05.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_06.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_07.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_08.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_09.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_10.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_11.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_12.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_13.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_14.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_15.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_16.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_17.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_18.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_19.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_20.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_21.png"),
	preload("res://assets/art/effects/tianji/wind/eff_tornado-in_22.png"),
]
const TIANJI_WATER_FORMATION_FRAME_DURATION := 0.045
const TIANJI_WATER_PEAK_FRAME_DURATION := 0.065
const TIANJI_WATER_COLLAPSE_FRAME_DURATION := 0.075
const TIANJI_WATER_SOURCE_ANCHOR := Vector2(466.0, 1008.0)
const TIANJI_WATER_LAYER_SIZE_RATIOS: Array[float] = [1.0, 0.84, 0.74, 0.90, 1.06]
const TIANJI_WATER_LAYER_Y_RATIOS: Array[float] = [0.0, -0.12, 0.10, -0.06, 0.16]
const TIANJI_WATER_LAYER_ALPHAS: Array[float] = [1.0, 0.64, 0.52, 0.70, 0.46]
const TIANJI_WATER_LAYER_FRAME_OFFSETS: Array[int] = [0, 2, 4, 1, 3]
const TIANJI_WATER_LAYER_SPEEDS: Array[float] = [1.0, 1.08, 0.92, 1.04, 0.96]
const TIANJI_WATER_TEXTURES: Array[Texture2D] = [
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_03.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_04.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_05.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_06.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_07.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_08.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_09.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_10.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_11.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_12.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_13.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_14.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_15.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_16.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_17.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_18.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_19.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_20.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_21.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_22.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_23.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_24.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_25.png"),
	preload("res://assets/art/effects/tianji/water_no_rainbow/action-action1_26.png"),
]
const TIANJI_FIRE_RAIN_FRAME_DURATION := 0.060
const TIANJI_FIRE_RAIN_FINAL_FRAME_DURATION := 0.085
const TIANJI_FIRE_RAIN_FINAL_FLIGHT_DURATION := 0.46
const TIANJI_FIRE_RAIN_FINAL_LANDING_FRAME := 9
const TIANJI_FIRE_RAIN_MAX_MARKS := 24
const TIANJI_FIRE_RAIN_METEOR_SCALE := 0.84
const TIANJI_FIRE_RAIN_FINAL_SCALE := 1.52
const TIANJI_FIRE_RAIN_FINAL_ANCHOR_RATIO := Vector2(0.66, 0.66)
const TIANJI_FIRE_RAIN_SKY_MARGIN := 18.0
const TIANJI_FIRE_RAIN_METEOR_TEXTURES: Array[Texture2D] = [
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_00.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_01.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_02.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_03.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_04.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_05.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_06.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_07.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_08.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_09.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_10.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_11.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_12.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_13.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_14.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_15.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_16.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_17.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_18.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_19.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_20.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_21.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_22.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_23.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_24.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_25.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_26.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_27.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_28.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_29.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_30.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_31.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_32.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_33.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_34.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_35.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_36.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_37.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_38.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_39.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_40.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_41.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_42.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_43.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_44.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_45.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor/062 MYNSZD E53209_46.png")
]
const TIANJI_FIRE_RAIN_FINAL_TEXTURES: Array[Texture2D] = [
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_00.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_01.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_02.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_03.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_04.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_05.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_06.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_07.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_08.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_09.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_10.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_11.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_12.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_13.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_14.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_15.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_16.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_17.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_18.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_19.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_20.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_21.png"),
	preload("res://assets/art/effects/tianji/fire_rain/meteor_final/055 MYNSZD E53202_22.png")
]
const PLAYER_ULTIMATE_SOURCE_FOOT_ANCHOR := Vector2(64, 108)
const GUAN_YU_SPRITE_SCALE := 0.75
const GUAN_YU_SOURCE_FOOT_ANCHOR := Vector2(64, 86)
const GUAN_YU_TALL_SWING_SOURCE_FOOT_ANCHOR := Vector2(50, 124)
const GUAN_YU_WORLD_FOOT_OFFSET := Vector2(0, 13)
const GUAN_YU_IDLE_FRAME_DURATION := 0.16
const GUAN_YU_WALK_ENTRY_DURATION := 0.09
const GUAN_YU_WALK_LOOP_FRAME_DURATION := 0.10
const GUAN_YU_DRAG_FRAME_DURATION := 0.09
const GUAN_YU_DEATH_FRAME_DURATIONS: Array[float] = [0.14, 0.14, 0.18, 0.20, 0.72]
const GUAN_YU_DEATH_CINEMATIC_DURATION := 1.38
const ZHANG_FEI_SPRITE_SCALE := 1.0
const ZHANG_FEI_WORLD_FOOT_OFFSET := Vector2(0, 15)
const ZHANG_FEI_IDLE_FRAME_DURATION := 0.14
const ZHANG_FEI_WALK_ENTRY_DURATION := 0.09
const ZHANG_FEI_WALK_LOOP_FRAME_DURATION := 0.10
const ZHANG_FEI_ULTIMATE_FRAME_DURATION := 0.085
const ZHANG_FEI_LANDING_FRAME_DURATIONS: Array[float] = [0.20, 0.10]
const ZHANG_FEI_LANDING_SOURCE_ANCHOR := Vector2(288.0, 338.0)
const ZHANG_FEI_LANDING_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/effects/landing/zhang-fei-landing-01.png"),
	preload("res://assets/art/characters/zhang_fei/effects/landing/zhang-fei-landing-02.png"),
]
const WUSHUANG_IMPACT_FRAME_DURATION := 0.06
const WUSHUANG_IMPACT_SOURCE_ANCHOR := Vector2(420.0, 388.0)
const WUSHUANG_IMPACT_TEXTURES := [
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-01.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-02.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-03.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-04.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-05.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-06.png"),
	preload("res://assets/art/effects/wushuang/impact_wave/impact-wave-07.png"),
]
const WUSHUANG_READY_FRAME_DURATION := 0.08
const WUSHUANG_READY_SCALE := 0.50
const WUSHUANG_READY_OFFSET := Vector2(0, -22)
const WUSHUANG_READY_SOURCE_CENTER := Vector2(194, 209)
const ENEMY_SWORD_SPRITE_SCALE := 0.55
const ENEMY_SWORD_SOURCE_FOOT_ANCHOR := Vector2(64, 116)
const ENEMY_SWORD_IDLE_FRAME_DURATION := 0.18
const ENEMY_SWORD_WALK_FRAME_DURATION := 0.10
const ENEMY_SWORD_WINDUP_DURATION := 0.60
const ENEMY_SHIELD_SPRITE_SCALE := 0.64
const ENEMY_SHIELD_SOURCE_FOOT_ANCHOR := Vector2(64, 112)
const ENEMY_SHIELD_IDLE_FRAME_DURATION := 0.26
const ENEMY_SHIELD_WALK_FRAME_DURATION := 0.12
const ENEMY_SHIELD_WINDUP_DURATION := 0.70
const ENEMY_ARCHER_SPRITE_SCALE := 0.55
const ENEMY_ARCHER_SOURCE_FOOT_ANCHOR := Vector2(64, 124)
const ENEMY_ARCHER_IDLE_FRAME_DURATION := 0.24
const ENEMY_ARCHER_WALK_FRAME_DURATION := 0.12
const ENEMY_ARCHER_WINDUP_DURATION := 0.85
const ENEMY_HALBERD_SPRITE_SCALE := 0.65
const ENEMY_HALBERD_SOURCE_FOOT_ANCHOR := Vector2(64, 116)
const ENEMY_HALBERD_IDLE_FRAME_DURATION := 0.22
const ENEMY_HALBERD_WALK_FRAME_DURATION := 0.10
const ENEMY_HALBERD_WINDUP_DURATION := 0.75
const ENEMY_SPEAR_SPRITE_SCALE := 0.55
const ENEMY_SPEAR_IDLE_FRAME_DURATION := 0.20
const ENEMY_SPEAR_WALK_FRAME_DURATION := 0.10
const ENEMY_SPEAR_WINDUP_DURATION := 0.58
const ENEMY_SPEAR_IDLE_FOOT_ANCHORS := [Vector2(64, 110), Vector2(64, 110), Vector2(64, 110)]
const ENEMY_SPEAR_WALK_FOOT_ANCHORS := [Vector2(64, 112), Vector2(64, 111), Vector2(64, 113), Vector2(64, 109), Vector2(64, 112)]
const ENEMY_SPEAR_ATTACK_FOOT_ANCHORS := [Vector2(64, 110), Vector2(64, 99), Vector2(64, 85), Vector2(64, 96)]
const ENEMY_SPEAR_ATTACK_SCALES := [0.55, 0.583, 0.616, 0.594]
const ENEMY_SPEAR_DEATH_FOOT_ANCHORS := [Vector2(64, 110), Vector2(64, 113), Vector2(64, 117)]
const ENEMY_CROSSBOW_SPRITE_SCALE := 0.55
const ENEMY_CROSSBOW_IDLE_FRAME_DURATION := 0.24
const ENEMY_CROSSBOW_WALK_FRAME_DURATION := 0.12
const ENEMY_CROSSBOW_WINDUP_DURATION := 0.72
const ENEMY_CROSSBOW_IDLE_FOOT_ANCHORS := [Vector2(64, 105), Vector2(64, 104), Vector2(64, 105)]
const ENEMY_CROSSBOW_WALK_FOOT_ANCHORS := [Vector2(64, 104), Vector2(64, 106), Vector2(64, 105), Vector2(64, 105)]
const ENEMY_CROSSBOW_ATTACK_FOOT_ANCHORS := [
	Vector2(64, 105), Vector2(64, 105), Vector2(64, 104), Vector2(64, 105),
	Vector2(64, 104), Vector2(64, 105), Vector2(64, 105), Vector2(64, 104),
]
const ENEMY_CROSSBOW_DEATH_FOOT_ANCHORS := [Vector2(64, 105), Vector2(64, 104), Vector2(64, 115), Vector2(64, 117)]
const ENEMY_CAVALRY_SPRITE_SCALE := 0.62
const ENEMY_CAVALRY_IDLE_FRAME_DURATION := 0.18
const ENEMY_CAVALRY_WALK_FRAME_DURATION := 0.085
const ENEMY_CAVALRY_CHARGE_FRAME_DURATION := 0.055
const ENEMY_CAVALRY_IDLE_FOOT_ANCHORS := [
	Vector2(64, 119), Vector2(64, 119), Vector2(64, 119), Vector2(64, 119), Vector2(64, 118),
]
const ENEMY_CAVALRY_WALK_FOOT_ANCHORS := [
	Vector2(64, 116), Vector2(64, 116), Vector2(64, 115), Vector2(64, 117), Vector2(64, 116),
	Vector2(64, 114), Vector2(64, 118), Vector2(64, 116), Vector2(64, 115), Vector2(64, 115),
]
const ENEMY_CAVALRY_ATTACK_FOOT_ANCHORS := [Vector2(64, 117), Vector2(64, 118)]
const ENEMY_CAVALRY_DEATH_FOOT_ANCHORS := [
	Vector2(64, 119), Vector2(64, 119), Vector2(64, 120), Vector2(64, 122), Vector2(64, 123), Vector2(64, 122),
]
# These values are calibrated from each source frame's opaque pixel height, not its canvas size.
# They keep elites at 1.12x and Zhang He at 1.20x Zhao Yun's visible idle height.
const ELITE_XIAHOU_EN_SPRITE_SCALE := 0.528
const ELITE_XIAHOU_EN_SOURCE_FOOT_ANCHOR := Vector2(64, 118)
const ELITE_XIAHOU_EN_IDLE_FRAME_DURATION := 0.20
const ELITE_XIAHOU_EN_WALK_FRAME_DURATION := 0.11
const ELITE_CHUNYU_DAO_SPRITE_SCALE := 0.543
const ELITE_CHUNYU_DAO_IDLE_FRAME_DURATION := 0.20
const ELITE_CHUNYU_DAO_WALK_FRAME_DURATION := 0.10
const ELITE_CHUNYU_DAO_IDLE_FOOT_ANCHORS := [Vector2(64, 120), Vector2(64, 120), Vector2(64, 121)]
const ELITE_CHUNYU_DAO_WALK_FOOT_ANCHORS := [Vector2(64, 121), Vector2(64, 120), Vector2(64, 121), Vector2(64, 120)]
const ELITE_CHUNYU_DAO_ATTACK_FOOT_ANCHORS := [Vector2(64, 156), Vector2(105, 120), Vector2(64, 120), Vector2(105, 120)]
const ELITE_CHUNYU_DAO_DEATH_FOOT_ANCHORS := [Vector2(64, 118), Vector2(64, 117), Vector2(64, 120)]
const BOSS_ZHANG_HE_SPRITE_SCALE := 0.571
const NAMED_SPRITE_OUTLINE_WIDTH := 0.0
const BOSS_ZHANG_HE_SOURCE_FOOT_ANCHOR := Vector2(64, 112)
const BOSS_ZHANG_HE_IDLE_FRAME_DURATION := 0.20
const BOSS_ZHANG_HE_WALK_FRAME_DURATION := 0.10
const BOSS_ZHANG_HE_IDLE_TEXTURES := [
	preload("res://assets/art/bosses/zhang_he/idle_right/zhang-he-idle-01.png"),
	preload("res://assets/art/bosses/zhang_he/idle_right/zhang-he-idle-02.png"),
	preload("res://assets/art/bosses/zhang_he/idle_right/zhang-he-idle-03.png"),
	preload("res://assets/art/bosses/zhang_he/idle_right/zhang-he-idle-04.png"),
]
const BOSS_ZHANG_HE_WALK_TEXTURES := [
	preload("res://assets/art/bosses/zhang_he/walk_right/zhang-he-walk-01.png"),
	preload("res://assets/art/bosses/zhang_he/walk_right/zhang-he-walk-02.png"),
	preload("res://assets/art/bosses/zhang_he/walk_right/zhang-he-walk-03.png"),
	preload("res://assets/art/bosses/zhang_he/walk_right/zhang-he-walk-04.png"),
]
const BOSS_ZHANG_HE_ATTACK_TEXTURES := [
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-01.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-02.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-03.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-04.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-05.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-06.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-07.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-08.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-09.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-10.png"),
	preload("res://assets/art/bosses/zhang_he/attack_right/zhang-he-attack-11.png"),
]
const BOSS_ZHANG_HE_DEATH_TEXTURES := [
	preload("res://assets/art/bosses/zhang_he/death_right/zhang-he-death-01.png"),
	preload("res://assets/art/bosses/zhang_he/death_right/zhang-he-death-02.png"),
	preload("res://assets/art/bosses/zhang_he/death_right/zhang-he-death-03.png"),
	preload("res://assets/art/bosses/zhang_he/death_right/zhang-he-death-04.png"),
]
const BOSS_ZHANG_HE_THRUST_SEQUENCE := [2, 1, 0]
const BOSS_ZHANG_HE_SWEEP_SEQUENCE := [5, 4, 3, 5]
const BOSS_ZHANG_HE_SUPPORT_SEQUENCE := [3, 4, 5]
const BOSS_ZHANG_HE_WHIRL_SEQUENCE := [6, 7, 8, 9, 10]
const BOSS_XIAHOU_DUN_SPRITE_SCALE := 0.80
const BOSS_XIAHOU_DUN_IDLE_FRAME_DURATION := 0.20
const BOSS_XIAHOU_DUN_WALK_FRAME_DURATION := 0.10
const BOSS_XIAHOU_DUN_ATTACK_FRAME_DURATION := 0.09
const BOSS_XIAHOU_DUN_DEATH_FRAME_DURATION := 0.16
const BOSS_XIAHOU_DUN_IDLE_FOOT_ANCHORS := [
	Vector2(64, 93), Vector2(64, 94), Vector2(64, 94), Vector2(64, 94),
	Vector2(64, 93), Vector2(64, 93), Vector2(64, 94),
]
const BOSS_XIAHOU_DUN_WALK_FOOT_ANCHORS := [
	Vector2(64, 94), Vector2(64, 93), Vector2(64, 94), Vector2(64, 94),
	Vector2(64, 94), Vector2(64, 94), Vector2(64, 93),
]
const BOSS_XIAHOU_DUN_ATTACK_1_FOOT_ANCHORS := [Vector2(64, 94), Vector2(64, 93), Vector2(64, 95)]
const BOSS_XIAHOU_DUN_ATTACK_2_FOOT_ANCHORS := [
	Vector2(64, 94), Vector2(64, 94), Vector2(64, 94), Vector2(64, 94), Vector2(64, 85),
]
const BOSS_XIAHOU_DUN_ATTACK_3_FOOT_ANCHORS := [
	Vector2(64, 94), Vector2(64, 123), Vector2(64, 115), Vector2(64, 108), Vector2(64, 95),
	Vector2(64, 124), Vector2(64, 94), Vector2(64, 94), Vector2(64, 124),
]
const BOSS_XIAHOU_DUN_ATTACK_4_FOOT_ANCHORS := [Vector2(64, 94), Vector2(64, 120), Vector2(64, 94), Vector2(64, 124)]
const BOSS_XIAHOU_DUN_DEATH_FOOT_ANCHORS := [
	Vector2(64, 94), Vector2(64, 94), Vector2(64, 94), Vector2(64, 95), Vector2(64, 95),
]
const BOSS_XIAHOU_DUN_IDLE_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/idle_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/4.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/5.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/6.png"),
	preload("res://assets/art/bosses/xiahou_dun/idle_right/7.png"),
]
const BOSS_XIAHOU_DUN_WALK_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/walk_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/4.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/5.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/6.png"),
	preload("res://assets/art/bosses/xiahou_dun/walk_right/7.png"),
]
const BOSS_XIAHOU_DUN_ATTACK_1_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/attack_1_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_1_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_1_right/3.png"),
]
const BOSS_XIAHOU_DUN_ATTACK_2_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/attack_2_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_2_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_2_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_2_right/4.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_2_right/5.png"),
]
const BOSS_XIAHOU_DUN_ATTACK_3_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/4.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/5.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/6.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/7.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/8.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_3_right/9.png"),
]
const BOSS_XIAHOU_DUN_ATTACK_4_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/attack_4_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_4_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_4_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/attack_4_right/4.png"),
]
const BOSS_XIAHOU_DUN_DEATH_TEXTURES := [
	preload("res://assets/art/bosses/xiahou_dun/death_right/1.png"),
	preload("res://assets/art/bosses/xiahou_dun/death_right/2.png"),
	preload("res://assets/art/bosses/xiahou_dun/death_right/3.png"),
	preload("res://assets/art/bosses/xiahou_dun/death_right/4.png"),
	preload("res://assets/art/bosses/xiahou_dun/death_right/5.png"),
]
const BOSS_XIAHOU_DUN_ACTION_1_SEQUENCE := [
	{"textures": BOSS_XIAHOU_DUN_ATTACK_1_TEXTURES, "anchors": BOSS_XIAHOU_DUN_ATTACK_1_FOOT_ANCHORS},
]
const BOSS_XIAHOU_DUN_ACTION_2_SEQUENCE := [
	{"textures": BOSS_XIAHOU_DUN_ATTACK_2_TEXTURES, "anchors": BOSS_XIAHOU_DUN_ATTACK_2_FOOT_ANCHORS},
]
const BOSS_XIAHOU_DUN_ACTION_3_SEQUENCE := [
	{"textures": BOSS_XIAHOU_DUN_ATTACK_3_TEXTURES, "anchors": BOSS_XIAHOU_DUN_ATTACK_3_FOOT_ANCHORS},
]
const BOSS_XIAHOU_DUN_ACTION_34_SEQUENCE := [
	{"textures": BOSS_XIAHOU_DUN_ATTACK_3_TEXTURES, "anchors": BOSS_XIAHOU_DUN_ATTACK_3_FOOT_ANCHORS},
	{"textures": BOSS_XIAHOU_DUN_ATTACK_4_TEXTURES, "anchors": BOSS_XIAHOU_DUN_ATTACK_4_FOOT_ANCHORS},
]
const BOSS_LV_BU_SPRITE_SCALE := 1.22
const BOSS_LV_BU_IDLE_FRAME_DURATION := 0.18
const BOSS_LV_BU_WALK_FRAME_DURATION := 0.085
const BOSS_LV_BU_ATTACK_FRAME_DURATION := 0.085
const BOSS_LV_BU_DEATH_FRAME_DURATION := 0.16
const BOSS_LV_BU_IDLE_FOOT_ANCHORS := [
	Vector2(64, 66), Vector2(64, 65), Vector2(64, 65), Vector2(64, 65), Vector2(64, 66),
	Vector2(64, 65), Vector2(64, 65), Vector2(64, 66), Vector2(64, 65), Vector2(64, 65), Vector2(64, 66),
]
const BOSS_LV_BU_WALK_FOOT_ANCHORS := [
	Vector2(64, 66), Vector2(64, 65), Vector2(64, 65), Vector2(64, 64), Vector2(64, 65), Vector2(64, 66), Vector2(64, 65),
]
const BOSS_LV_BU_ATTACK_1_FOOT_ANCHORS := [
	Vector2(64, 66), Vector2(64, 64), Vector2(64, 51), Vector2(64, 51), Vector2(64, 51), Vector2(64, 57), Vector2(64, 66),
]
const BOSS_LV_BU_ATTACK_2_FOOT_ANCHORS := [
	Vector2(64, 76), Vector2(64, 88), Vector2(64, 76), Vector2(64, 124), Vector2(64, 124), Vector2(64, 91), Vector2(64, 66),
]
const BOSS_LV_BU_ATTACK_3_FOOT_ANCHORS := [
	Vector2(64, 124), Vector2(64, 124), Vector2(64, 76), Vector2(64, 88), Vector2(64, 76), Vector2(64, 124), Vector2(64, 69), Vector2(64, 66),
]
# Lv Bu's source action frames have substantially different crops. These values
# normalize the visible body height to the idle pose without shrinking extended
# weapon arcs. Weapon tips are source-space sockets for attack VFX attachment.
const BOSS_LV_BU_ATTACK_1_FRAME_SCALES := [1.00, 1.03, 1.28, 1.22, 1.24, 1.12, 1.00]
const BOSS_LV_BU_ATTACK_2_FRAME_SCALES := [0.98, 0.96, 0.98, 0.82, 0.80, 0.96, 1.00]
const BOSS_LV_BU_ATTACK_3_FRAME_SCALES := [1.00, 1.00, 1.04, 1.02, 1.04, 1.00, 1.04, 1.04]
const BOSS_LV_BU_ATTACK_1_WEAPON_TIPS := [
	Vector2(123, 27), Vector2(125, 27), Vector2(120, 25), Vector2(127, 31), Vector2(120, 29), Vector2(116, 28), Vector2(126, 28),
]
const BOSS_LV_BU_ATTACK_2_WEAPON_TIPS := [
	Vector2(84, 73), Vector2(104, 85), Vector2(124, 54), Vector2(97, 14), Vector2(78, 6), Vector2(112, 12), Vector2(125, 30),
]
const BOSS_LV_BU_ATTACK_3_WEAPON_TIPS := [
	Vector2(97, 14), Vector2(78, 6), Vector2(84, 73), Vector2(104, 85), Vector2(124, 54), Vector2(115, 20), Vector2(112, 14), Vector2(125, 28),
]
const BOSS_LV_BU_DEFAULT_WEAPON_TIP := Vector2(123, 28)
const BOSS_LV_BU_DEATH_FOOT_ANCHORS := [Vector2(64, 66), Vector2(64, 71), Vector2(64, 68), Vector2(64, 69), Vector2(64, 70)]
const BOSS_LV_BU_IDLE_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/idle_right/1.png"), preload("res://assets/art/bosses/lvbu/idle_right/2.png"),
	preload("res://assets/art/bosses/lvbu/idle_right/3.png"), preload("res://assets/art/bosses/lvbu/idle_right/4.png"),
	preload("res://assets/art/bosses/lvbu/idle_right/5.png"), preload("res://assets/art/bosses/lvbu/idle_right/6.png"),
	preload("res://assets/art/bosses/lvbu/idle_right/7.png"), preload("res://assets/art/bosses/lvbu/idle_right/8.png"),
	preload("res://assets/art/bosses/lvbu/idle_right/9.png"), preload("res://assets/art/bosses/lvbu/idle_right/10.png"),
	preload("res://assets/art/bosses/lvbu/idle_right/11.png"),
]
const BOSS_LV_BU_WALK_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/walk_right/1.png"), preload("res://assets/art/bosses/lvbu/walk_right/2.png"),
	preload("res://assets/art/bosses/lvbu/walk_right/3.png"), preload("res://assets/art/bosses/lvbu/walk_right/4.png"),
	preload("res://assets/art/bosses/lvbu/walk_right/5.png"), preload("res://assets/art/bosses/lvbu/walk_right/6.png"),
	preload("res://assets/art/bosses/lvbu/walk_right/7.png"),
]
const BOSS_LV_BU_ATTACK_1_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/attack_1_right/1.png"), preload("res://assets/art/bosses/lvbu/attack_1_right/2.png"),
	preload("res://assets/art/bosses/lvbu/attack_1_right/3.png"), preload("res://assets/art/bosses/lvbu/attack_1_right/4.png"),
	preload("res://assets/art/bosses/lvbu/attack_1_right/9.png"), preload("res://assets/art/bosses/lvbu/attack_1_right/11.png"),
	preload("res://assets/art/bosses/lvbu/attack_1_right/12.png"),
]
const BOSS_LV_BU_ATTACK_2_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/attack_2_right/13.png"), preload("res://assets/art/bosses/lvbu/attack_2_right/14.png"),
	preload("res://assets/art/bosses/lvbu/attack_2_right/15.png"), preload("res://assets/art/bosses/lvbu/attack_2_right/16.png"),
	preload("res://assets/art/bosses/lvbu/attack_2_right/17.png"), preload("res://assets/art/bosses/lvbu/attack_2_right/18.png"),
	preload("res://assets/art/bosses/lvbu/attack_2_right/19.png"),
]
const BOSS_LV_BU_ATTACK_3_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/attack_3_right/1.png"), preload("res://assets/art/bosses/lvbu/attack_3_right/2.png"),
	preload("res://assets/art/bosses/lvbu/attack_3_right/3.png"), preload("res://assets/art/bosses/lvbu/attack_3_right/4.png"),
	preload("res://assets/art/bosses/lvbu/attack_3_right/5.png"), preload("res://assets/art/bosses/lvbu/attack_3_right/6.png"),
	preload("res://assets/art/bosses/lvbu/attack_3_right/7.png"), preload("res://assets/art/bosses/lvbu/attack_3_right/8.png"),
]
const LV_BU_ATTACK_VFX_FRAME_DURATION := 0.055
# Both source sheets place the impact near the right-hand side of the canvas;
# anchoring there keeps the strike rooted at the boss while the effect rotates
# with his facing direction.
const LV_BU_ATTACK_1_VFX_SOURCE_ANCHOR := Vector2(448.0, 500.0)
const LV_BU_ATTACK_2_VFX_SOURCE_ANCHOR := Vector2(500.0, 500.0)
const LV_BU_ATTACK_1_VFX_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_00.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_01.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_02.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_03.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_04.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_05.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_06.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_07.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_08.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_1/action-action1_09.png"),
]
const LV_BU_ATTACK_2_VFX_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_00.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_01.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_02.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_03.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_04.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_05.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_06.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_07.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_08.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_09.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_10.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_11.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_12.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_13.png"),
	preload("res://assets/art/bosses/lvbu/effects/attack_2/action-action2_14.png"),
]
const BOSS_LV_BU_DEATH_TEXTURES := [
	preload("res://assets/art/bosses/lvbu/death_right/1.png"), preload("res://assets/art/bosses/lvbu/death_right/2.png"),
	preload("res://assets/art/bosses/lvbu/death_right/3.png"), preload("res://assets/art/bosses/lvbu/death_right/5.png"),
	preload("res://assets/art/bosses/lvbu/death_right/6.png"),
]
const MAX_ELITE_CORPSES := 12
const ARCHER_PROJECTILE_LAUNCH_RATIO := 0.25
const ARCHER_PROJECTILE_ARC_HEIGHT := 44.0
const ARCHER_PROJECTILE_SCALE := 0.45
const ARCHER_PROJECTILE_SOURCE_ANCHOR := Vector2(64, 32)
const WEATHER_SUNNY := "sunny"
const WEATHER_RAIN := "rain"
const WEATHER_STORM := "storm"
const WEATHER_DUST_COUNT := 22
const WEATHER_RAIN_COUNT := 58
const WEATHER_LIGHTNING_DURATION := 0.12
const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")
const PLAYER_IDLE_FRAME_ORDER := [0, 1, 2, 3, 2, 1]
const PLAYER_IDLE_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-04.png"),
]
const PLAYER_DEATH_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/death_right/zhaoyun-death-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/death_right/zhaoyun-death-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/death_right/zhaoyun-death-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/death_right/zhaoyun-death-right-04.png"),
]
const ZHANG_FEI_DEATH_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/death_right/zhang-fei-death-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/death_right/zhang-fei-death-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/death_right/zhang-fei-death-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/death_right/zhang-fei-death-04.png"),
]
const ZHANG_FEI_DEATH_FOOT_ANCHORS := [
	Vector2(49, 67), Vector2(49, 68), Vector2(49, 69), Vector2(49, 70),
]
const PLAYER_WALK_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-04.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-05.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-06.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-07.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-08.png"),
]
const PLAYER_ATTACK_01_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/attack_01_right/zhaoyun-attack-01-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_01_right/zhaoyun-attack-01-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_01_right/zhaoyun-attack-01-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_01_right/zhaoyun-attack-01-right-04.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_01_right/zhaoyun-attack-01-right-05.png"),
]
const PLAYER_ATTACK_02_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/attack_02_right/zhaoyun-attack-02-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_02_right/zhaoyun-attack-02-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_02_right/zhaoyun-attack-02-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_02_right/zhaoyun-attack-02-right-04.png"),
]
const PLAYER_ATTACK_02_FOOT_ANCHORS := [
	Vector2(64, 100),
	Vector2(64, 102),
	Vector2(64, 97),
	Vector2(64, 100),
]
const PLAYER_ATTACK_03_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-04.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-05.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_03_right/zhaoyun-attack-03-right-06.png"),
]
const PLAYER_ATTACK_04_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-04.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-05.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_04_right/zhaoyun-attack-04-right-06.png"),
]
const PLAYER_ATTACK_05_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/attack_05_right/zhaoyun-attack-05-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/attack_05_right/zhaoyun-attack-05-right-02.png"),
]
const PLAYER_ULTIMATE_TEXTURE := preload("res://assets/art/characters/zhao_yun/sprites/ultimate_right/zhaoyun-ultimate-right-01.png")
const ZHAO_YUN_ULTIMATE_EFFECT_TEXTURES := [
	preload("res://assets/art/effects/zhao_yun/ultimate/zhaoyun-ultimate-effect-01.png"),
	preload("res://assets/art/effects/zhao_yun/ultimate/zhaoyun-ultimate-effect-02.png"),
	preload("res://assets/art/effects/zhao_yun/ultimate/zhaoyun-ultimate-effect-03.png"),
	preload("res://assets/art/effects/zhao_yun/ultimate/zhaoyun-ultimate-effect-04.png"),
	preload("res://assets/art/effects/zhao_yun/ultimate/zhaoyun-ultimate-effect-05.png"),
]
const ZHAO_YUN_ULTIMATE_EFFECT_FRAME_DURATION := 0.06
const ZHAO_YUN_ULTIMATE_EFFECT_SCALE := 0.58
const ZHAO_YUN_ULTIMATE_EFFECT_SOURCE_ANCHOR := Vector2(491.0, 180.0)
const ZHAO_YUN_ULTIMATE_EFFECT_GUN_TIP_OFFSET := Vector2(0.0, -27.0)
const WUSHUANG_READY_TEXTURES := [
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_15.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_16.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_17.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_18.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_19.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_20.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_21.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_22.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_23.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_24.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_25.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_26.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_27.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_28.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_29.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_30.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_31.png"),
	preload("res://assets/art/effects/wushuang/eff_mechanical-in2_32.png"),
]
const FIREWHEEL_TEXTURE := preload("res://assets/art/characters/zhao_yun/effects/zhaoyun-firewheel.png")
const GUAN_YU_IDLE_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-05.png"),
]
const GUAN_YU_WALK_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-05.png"),
]
const GUAN_YU_ATTACK_01_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-05.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-06.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-07.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_01_right/guan-yu-attack_01-08.png"),
]
const GUAN_YU_ATTACK_01_FOOT_ANCHORS := [
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_TALL_SWING_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
]
const GUAN_YU_ATTACK_02_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/attack_02_right/guan-yu-attack_02-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_02_right/guan-yu-attack_02-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_02_right/guan-yu-attack_02-03.png"),
]
const GUAN_YU_ATTACK_02_FOOT_ANCHORS := [
	GUAN_YU_TALL_SWING_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
	GUAN_YU_SOURCE_FOOT_ANCHOR,
]
const GUAN_YU_ATTACK_03_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/attack_03_right/guan-yu-attack_03-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_03_right/guan-yu-attack_03-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_03_right/guan-yu-attack_03-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/attack_03_right/guan-yu-attack_03-04.png"),
]
const GUAN_YU_ATTACK_03_FOOT_ANCHORS := [
	Vector2(64, 87),
	Vector2(64, 81),
	Vector2(64, 84),
	Vector2(64, 84),
]
const GUAN_YU_DRAG_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-05.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-06.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-07.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-08.png"),
	preload("res://assets/art/characters/guan_yu/sprites/drag_right/guan-yu-drag-right-09.png"),
]
const GUAN_YU_DRAG_FOOT_ANCHORS := [
	Vector2(64, 86),
	Vector2(64, 87),
	Vector2(70, 85),
	Vector2(70, 85),
	Vector2(72, 84),
	Vector2(78, 84),
	Vector2(85, 84),
	Vector2(92, 84),
	Vector2(101, 84),
]
const GUAN_YU_DEATH_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/death_right/guan-yu-death-right-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/death_right/guan-yu-death-right-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/death_right/guan-yu-death-right-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/death_right/guan-yu-death-right-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/death_right/guan-yu-death-right-05.png"),
]
const GUAN_YU_DEATH_FOOT_ANCHORS := [
	Vector2(64, 87),
	Vector2(64, 117),
	Vector2(64, 123),
	Vector2(64, 121),
	Vector2(64, 124),
]
const ZHANG_FEI_IDLE_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-04.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-05.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-06.png"),
]
const ZHANG_FEI_IDLE_FOOT_ANCHORS := [
	Vector2(49, 65), Vector2(49, 65), Vector2(49, 65),
	Vector2(49, 65), Vector2(49, 65), Vector2(49, 65),
]
const ZHANG_FEI_WALK_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-04.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-05.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-06.png"),
]
const ZHANG_FEI_WALK_FOOT_ANCHORS := [
	Vector2(49, 65), Vector2(49, 65), Vector2(49, 64),
	Vector2(49, 65), Vector2(49, 65), Vector2(49, 62),
]
const ZHANG_FEI_ATTACK_01_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/attack_01_right/zhang-fei-attack-01-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_01_right/zhang-fei-attack-01-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_01_right/zhang-fei-attack-01-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_01_right/zhang-fei-attack-01-04.png"),
]
const ZHANG_FEI_ATTACK_01_FOOT_ANCHORS := [Vector2(49, 65), Vector2(44, 66), Vector2(44, 66), Vector2(44, 66)]
const ZHANG_FEI_ATTACK_02_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-04.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-05.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_02_right/zhang-fei-attack-02-06.png"),
]
const ZHANG_FEI_ATTACK_02_FOOT_ANCHORS := [
	Vector2(49, 65), Vector2(48, 65), Vector2(49, 65),
	Vector2(49, 65), Vector2(49, 66), Vector2(48, 66),
]
const ZHANG_FEI_ATTACK_03_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-04.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-05.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-06.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-07.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-08.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/attack_03_right/zhang-fei-attack-03-09.png"),
]
const ZHANG_FEI_ATTACK_03_FOOT_ANCHORS := [
	Vector2(49, 65), Vector2(50, 87), Vector2(49, 103),
	Vector2(64, 89), Vector2(74, 65), Vector2(54, 99),
	Vector2(51, 116), Vector2(49, 65), Vector2(49, 65),
]
const ENEMY_SWORD_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/sword/idle_right/knife-idle-right-01.png"),
	preload("res://assets/art/enemies/sword/idle_right/knife-idle-right-02.png"),
	preload("res://assets/art/enemies/sword/idle_right/knife-idle-right-03.png"),
]
const ENEMY_SWORD_IDLE_FRAME_ORDER := [0, 1, 2, 1]
const ENEMY_SWORD_WALK_TEXTURES := [
	preload("res://assets/art/enemies/sword/walk_right/knife-walk-right-01.png"),
	preload("res://assets/art/enemies/sword/walk_right/knife-walk-right-02.png"),
	preload("res://assets/art/enemies/sword/walk_right/knife-walk-right-03.png"),
	preload("res://assets/art/enemies/sword/walk_right/knife-walk-right-04.png"),
]
const ENEMY_SWORD_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/sword/attack_01_right/knife-attack-01-right-01.png"),
	preload("res://assets/art/enemies/sword/attack_01_right/knife-attack-01-right-02.png"),
	preload("res://assets/art/enemies/sword/attack_01_right/knife-attack-01-right-03.png"),
	preload("res://assets/art/enemies/sword/attack_01_right/knife-attack-01-right-04.png"),
]
const ENEMY_SWORD_ATTACK_FOOT_ANCHORS := [
	Vector2(64, 116), Vector2(45, 169), Vector2(64, 118), Vector2(64, 118),
]
const ENEMY_SWORD_ATTACK_SCALES := [0.55, 0.55, 0.55, 0.55]
const ENEMY_SWORD_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/sword/death_right/knife-death-right-01.png"),
	preload("res://assets/art/enemies/sword/death_right/knife-death-right-02.png"),
	preload("res://assets/art/enemies/sword/death_right/knife-death-right-03.png"),
	preload("res://assets/art/enemies/sword/death_right/knife-death-right-04.png"),
	preload("res://assets/art/enemies/sword/death_right/knife-death-right-05.png"),
]
const ENEMY_SHIELD_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/shield/idle_right/shield-idle-right-01.png"),
	preload("res://assets/art/enemies/shield/idle_right/shield-idle-right-02.png"),
]
const ENEMY_SHIELD_WALK_TEXTURES := [
	preload("res://assets/art/enemies/shield/walk_right/shield-walk-right-01.png"),
	preload("res://assets/art/enemies/shield/walk_right/shield-walk-right-02.png"),
	preload("res://assets/art/enemies/shield/walk_right/shield-walk-right-03.png"),
]
const ENEMY_SHIELD_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/shield/attack_01_right/shield-attack-01-right-01.png"),
	preload("res://assets/art/enemies/shield/attack_01_right/shield-attack-01-right-02.png"),
	preload("res://assets/art/enemies/shield/attack_01_right/shield-attack-01-right-03.png"),
	preload("res://assets/art/enemies/shield/attack_01_right/shield-attack-01-right-04.png"),
]
const ENEMY_SHIELD_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/shield/death_right/shield-death-right-01.png"),
	preload("res://assets/art/enemies/shield/death_right/shield-death-right-02.png"),
	preload("res://assets/art/enemies/shield/death_right/shield-death-right-03.png"),
	preload("res://assets/art/enemies/shield/death_right/shield-death-right-04.png"),
]
const ENEMY_ARCHER_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/archer/idle_right/archer-idle-right-01.png"),
	preload("res://assets/art/enemies/archer/idle_right/archer-idle-right-02.png"),
]
const ENEMY_ARCHER_WALK_TEXTURES := [
	preload("res://assets/art/enemies/archer/walk_right/archer-walk-right-01.png"),
	preload("res://assets/art/enemies/archer/walk_right/archer-walk-right-02.png"),
	preload("res://assets/art/enemies/archer/walk_right/archer-walk-right-03.png"),
	preload("res://assets/art/enemies/archer/walk_right/archer-walk-right-04.png"),
]
const ENEMY_ARCHER_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/archer/attack_01_right/archer-attack-01-right-01.png"),
	preload("res://assets/art/enemies/archer/attack_01_right/archer-attack-01-right-02.png"),
	preload("res://assets/art/enemies/archer/attack_01_right/archer-attack-01-right-03.png"),
	preload("res://assets/art/enemies/archer/attack_01_right/archer-attack-01-right-04.png"),
]
const ENEMY_ARCHER_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/archer/death_right/archer-death-right-01.png"),
	preload("res://assets/art/enemies/archer/death_right/archer-death-right-02.png"),
	preload("res://assets/art/enemies/archer/death_right/archer-death-right-03.png"),
	preload("res://assets/art/enemies/archer/death_right/archer-death-right-04.png"),
]
const ENEMY_HALBERD_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/halberd/idle_right/halberd-idle-right-01.png"),
	preload("res://assets/art/enemies/halberd/idle_right/halberd-idle-right-02.png"),
]
const ENEMY_HALBERD_WALK_TEXTURES := [
	preload("res://assets/art/enemies/halberd/walk_right/halberd-walk-right-01.png"),
	preload("res://assets/art/enemies/halberd/walk_right/halberd-walk-right-02.png"),
	preload("res://assets/art/enemies/halberd/walk_right/halberd-walk-right-03.png"),
]
const ENEMY_HALBERD_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/halberd/attack_01_right/halberd-attack-01-right-01.png"),
	preload("res://assets/art/enemies/halberd/attack_01_right/halberd-attack-01-right-02.png"),
	preload("res://assets/art/enemies/halberd/attack_01_right/halberd-attack-01-right-03.png"),
	preload("res://assets/art/enemies/halberd/attack_01_right/halberd-attack-01-right-04.png"),
]
const ENEMY_HALBERD_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/halberd/death_right/halberd-death-right-01.png"),
	preload("res://assets/art/enemies/halberd/death_right/halberd-death-right-02.png"),
	preload("res://assets/art/enemies/halberd/death_right/halberd-death-right-03.png"),
]
const ENEMY_SPEAR_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/spear/idle_right/spear-idle-right-01.png"),
	preload("res://assets/art/enemies/spear/idle_right/spear-idle-right-02.png"),
	preload("res://assets/art/enemies/spear/idle_right/spear-idle-right-03.png"),
]
const ENEMY_SPEAR_WALK_TEXTURES := [
	preload("res://assets/art/enemies/spear/walk_right/spear-walk-right-01.png"),
	preload("res://assets/art/enemies/spear/walk_right/spear-walk-right-02.png"),
	preload("res://assets/art/enemies/spear/walk_right/spear-walk-right-03.png"),
	preload("res://assets/art/enemies/spear/walk_right/spear-walk-right-04.png"),
	preload("res://assets/art/enemies/spear/walk_right/spear-walk-right-05.png"),
]
const ENEMY_SPEAR_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/spear/attack_01_right/spear-attack-01-right-01.png"),
	preload("res://assets/art/enemies/spear/attack_01_right/spear-attack-01-right-02.png"),
	preload("res://assets/art/enemies/spear/attack_01_right/spear-attack-01-right-03.png"),
	preload("res://assets/art/enemies/spear/attack_01_right/spear-attack-01-right-04.png"),
]
const ENEMY_SPEAR_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/spear/death_right/spear-death-right-01.png"),
	preload("res://assets/art/enemies/spear/death_right/spear-death-right-02.png"),
	preload("res://assets/art/enemies/spear/death_right/spear-death-right-03.png"),
]
const ENEMY_CROSSBOW_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/crossbow/idle_right/crossbow-idle-right-01.png"),
	preload("res://assets/art/enemies/crossbow/idle_right/crossbow-idle-right-02.png"),
	preload("res://assets/art/enemies/crossbow/idle_right/crossbow-idle-right-03.png"),
]
const ENEMY_CROSSBOW_WALK_TEXTURES := [
	preload("res://assets/art/enemies/crossbow/walk_right/crossbow-walk-right-01.png"),
	preload("res://assets/art/enemies/crossbow/walk_right/crossbow-walk-right-02.png"),
	preload("res://assets/art/enemies/crossbow/walk_right/crossbow-walk-right-03.png"),
	preload("res://assets/art/enemies/crossbow/walk_right/crossbow-walk-right-04.png"),
]
const ENEMY_CROSSBOW_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-01.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-02.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-03.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-04.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-05.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-06.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-07.png"),
	preload("res://assets/art/enemies/crossbow/attack_01_right/crossbow-attack-01-right-08.png"),
]
const ENEMY_CROSSBOW_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/crossbow/death_right/crossbow-death-right-01.png"),
	preload("res://assets/art/enemies/crossbow/death_right/crossbow-death-right-02.png"),
	preload("res://assets/art/enemies/crossbow/death_right/crossbow-death-right-03.png"),
	preload("res://assets/art/enemies/crossbow/death_right/crossbow-death-right-04.png"),
]
const ENEMY_CAVALRY_IDLE_TEXTURES := [
	preload("res://assets/art/enemies/cavalry/idle_right/1.png"),
	preload("res://assets/art/enemies/cavalry/idle_right/2.png"),
	preload("res://assets/art/enemies/cavalry/idle_right/3.png"),
	preload("res://assets/art/enemies/cavalry/idle_right/4.png"),
	preload("res://assets/art/enemies/cavalry/idle_right/5.png"),
]
const ENEMY_CAVALRY_WALK_TEXTURES := [
	preload("res://assets/art/enemies/cavalry/walk_right/1.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/2.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/3.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/4.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/5.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/6.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/7.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/8.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/9.png"),
	preload("res://assets/art/enemies/cavalry/walk_right/10.png"),
]
const ENEMY_CAVALRY_ATTACK_TEXTURES := [
	preload("res://assets/art/enemies/cavalry/attack_01_right/1.png"),
	preload("res://assets/art/enemies/cavalry/attack_01_right/2.png"),
]
const ENEMY_CAVALRY_DEATH_TEXTURES := [
	preload("res://assets/art/enemies/cavalry/death_right/1.png"),
	preload("res://assets/art/enemies/cavalry/death_right/2.png"),
	preload("res://assets/art/enemies/cavalry/death_right/3.png"),
	preload("res://assets/art/enemies/cavalry/death_right/4.png"),
	preload("res://assets/art/enemies/cavalry/death_right/5.png"),
	preload("res://assets/art/enemies/cavalry/death_right/6.png"),
]
const ELITE_XIAHOU_EN_IDLE_TEXTURES := [
	preload("res://assets/art/elites/xiahou_en/idle_right/xiahou-en-idle-01.png"),
	preload("res://assets/art/elites/xiahou_en/idle_right/xiahou-en-idle-02.png"),
	preload("res://assets/art/elites/xiahou_en/idle_right/xiahou-en-idle-03.png"),
]
const ELITE_XIAHOU_EN_WALK_TEXTURES := [
	preload("res://assets/art/elites/xiahou_en/walk_right/xiahou-en-walk-01.png"),
	preload("res://assets/art/elites/xiahou_en/walk_right/xiahou-en-walk-02.png"),
	preload("res://assets/art/elites/xiahou_en/walk_right/xiahou-en-walk-03.png"),
]
const ELITE_XIAHOU_EN_ATTACK_TEXTURES := [
	preload("res://assets/art/elites/xiahou_en/attack_right/xiahou-en-attack-01.png"),
	preload("res://assets/art/elites/xiahou_en/attack_right/xiahou-en-attack-02.png"),
	preload("res://assets/art/elites/xiahou_en/attack_right/xiahou-en-attack-03.png"),
	preload("res://assets/art/elites/xiahou_en/attack_right/xiahou-en-attack-04.png"),
]
const ELITE_XIAHOU_EN_DEATH_TEXTURES := [
	preload("res://assets/art/elites/xiahou_en/death_right/xiahou-en-death-01.png"),
	preload("res://assets/art/elites/xiahou_en/death_right/xiahou-en-death-02.png"),
	preload("res://assets/art/elites/xiahou_en/death_right/xiahou-en-death-03.png"),
	preload("res://assets/art/elites/xiahou_en/death_right/xiahou-en-death-04.png"),
]
const ELITE_CHUNYU_DAO_IDLE_TEXTURES := [
	preload("res://assets/art/elites/chunyu_dao/idle_right/chunyu-dao-idle-01.png"),
	preload("res://assets/art/elites/chunyu_dao/idle_right/chunyu-dao-idle-02.png"),
	preload("res://assets/art/elites/chunyu_dao/idle_right/chunyu-dao-idle-03.png"),
]
const ELITE_CHUNYU_DAO_WALK_TEXTURES := [
	preload("res://assets/art/elites/chunyu_dao/walk_right/chunyu-dao-walk-01.png"),
	preload("res://assets/art/elites/chunyu_dao/walk_right/chunyu-dao-walk-02.png"),
	preload("res://assets/art/elites/chunyu_dao/walk_right/chunyu-dao-walk-03.png"),
	preload("res://assets/art/elites/chunyu_dao/walk_right/chunyu-dao-walk-04.png"),
]
const ELITE_CHUNYU_DAO_ATTACK_TEXTURES := [
	preload("res://assets/art/elites/chunyu_dao/attack_right/chunyu-dao-attack-01.png"),
	preload("res://assets/art/elites/chunyu_dao/attack_right/chunyu-dao-attack-02.png"),
	preload("res://assets/art/elites/chunyu_dao/attack_right/chunyu-dao-attack-03.png"),
	preload("res://assets/art/elites/chunyu_dao/attack_right/chunyu-dao-attack-04.png"),
]
const ELITE_CHUNYU_DAO_DEATH_TEXTURES := [
	preload("res://assets/art/elites/chunyu_dao/death_right/chunyu-dao-death-01.png"),
	preload("res://assets/art/elites/chunyu_dao/death_right/chunyu-dao-death-02.png"),
	preload("res://assets/art/elites/chunyu_dao/death_right/chunyu-dao-death-03.png"),
]
const ARCHER_PROJECTILE_TEXTURE := preload("res://assets/art/projectiles/archer-arrow.png")

var bounds := Rect2(0, 0, 2560, 1440)
var enemies: EnemySimulation
var player: HeroActor
var boss: BossActor
var battle_camera: Camera2D
var elites: Array[EliteActor] = []
var telegraphs: Array[Telegraph] = []
var loot
var flashes: Array[Dictionary] = []
var pickup_marks: Array[Dictionary] = []
var impact_marks: Array[Dictionary] = []
var named_hit_marks: Array[Dictionary] = []
var tianji_marks: Array[Dictionary] = []
var tianji_wind_marks: Array[Dictionary] = []
var tianji_water_marks: Array[Dictionary] = []
var tianji_arrow_marks: Array[Dictionary] = []
var tianji_fire_rain_marks: Array[Dictionary] = []
var weapon_clash_marks: Array[Dictionary] = []
var guard_feedback_marks: Array[Dictionary] = []
var stance_break_marks: Array[Dictionary] = []
var shield_break_marks: Array[Dictionary] = []
var ultimate_wave_marks: Array[Dictionary] = []
var zhao_yun_ultimate_effect_marks: Array[Dictionary] = []
var death_collision_marks: Array[Dictionary] = []
var archer_projectiles: Array[Dictionary] = []
var archer_impact_marks: Array[Dictionary] = []
var crossbow_bolts: Array[Dictionary] = []
var crossbow_impact_marks: Array[Dictionary] = []
var banner_command_marks: Array[Dictionary] = []
var firewheel_rings: Array[Dictionary] = []
var guan_blade_waves: Array[Dictionary] = []
var guan_knife_wave_frames: Dictionary = {}
var elite_corpses: Array[Dictionary] = []
var visual_time := 0.0
var shake_remaining := 0.0
var shake_strength := 0.0
var player_last_position := Vector2.ZERO
var player_is_moving := false
var guan_yu_was_moving := false
var guan_yu_was_using_drag_motion := false
var zhang_fei_was_moving := false
var zhang_fei_ultimate_animation_time := 0.0
var zhang_fei_is_casting_ultimate := false
var wushuang_ready_animation_time := 0.0
var wushuang_ready_was_active := false
var player_faces_left := false
var player_idle_time := 0.0
var player_walk_time := 0.0
var player_attack_01_time := 0.0
var player_is_playing_attack_01 := false
var player_attack_02_time := 0.0
var player_is_playing_attack_02 := false
var player_attack_03_time := 0.0
var player_is_playing_attack_03 := false
var player_attack_04_time := 0.0
var player_is_playing_attack_04 := false
var player_attack_05_time := 0.0
var player_is_playing_attack_05 := false
var player_guard_time := 0.0
var player_hit_flash_remaining := 0.0
var player_hit_flash_strength := 0.0
var player_hit_white_textures: Dictionary = {}
var player_death_cinematic_active := false
var player_death_elapsed := 0.0
var player_death_faces_left := false
var player_death_hero_id := ""
var player_death_cinematic_duration := PLAYER_DEATH_CINEMATIC_DURATION
var enemy_last_positions: Array[Vector2] = []
var enemy_is_moving := PackedByteArray()
var enemy_move_animation_holds := PackedFloat32Array()
var weather_mode := WEATHER_SUNNY
var weather_seed := 0.0
var weather_lightning_seed := 0.0
var weather_lightning_remaining := 0.0
var weather_lightning_cooldown := 0.0
var battlefield_id := "changban"
var battlefield_ground_layers: Array[Dictionary] = []

func configure(world_bounds: Rect2, enemy_simulation: EnemySimulation, player_actor: HeroActor, boss_actor: BossActor, active_telegraphs: Array[Telegraph], loot_system = null, elite_actors: Array[EliteActor] = [], selected_battlefield_id: String = "changban") -> void:
	_load_guan_knife_wave_frames()
	bounds = world_bounds
	battlefield_id = selected_battlefield_id if selected_battlefield_id in ["changban", "xinye", "bowangpo", "bowangpo_story", "huoshaoxinye", "xiangyangchetui", "dangyangduanhou", "hulao"] else "changban"
	battlefield_ground_layers.clear()
	for raw_layer in BATTLEFIELD_LAYOUT.ground_layers_for(battlefield_id):
		var layer := raw_layer.duplicate(true)
		var texture := load(str(layer.get("path", ""))) as Texture2D
		if texture == null:
			continue
		layer["texture"] = texture
		battlefield_ground_layers.append(layer)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemies = enemy_simulation
	player = player_actor
	boss = boss_actor
	elites = elite_actors
	telegraphs = active_telegraphs
	loot = loot_system
	player.protection_broken.connect(_on_player_protection_broken)
	player.damaged.connect(_on_player_damaged)
	player.visual_effect_started.connect(_on_hero_visual_effect_started)
	position = Vector2.ZERO
	player_last_position = player.position
	player_is_moving = false
	guan_yu_was_moving = false
	guan_yu_was_using_drag_motion = false
	zhang_fei_was_moving = false
	zhang_fei_ultimate_animation_time = 0.0
	zhang_fei_is_casting_ultimate = false
	wushuang_ready_animation_time = 0.0
	wushuang_ready_was_active = false
	player_faces_left = false
	player_idle_time = 0.0
	player_walk_time = 0.0
	player_attack_01_time = 0.0
	player_is_playing_attack_01 = false
	player_attack_02_time = 0.0
	player_is_playing_attack_02 = false
	player_attack_03_time = 0.0
	player_is_playing_attack_03 = false
	player_attack_04_time = 0.0
	player_is_playing_attack_04 = false
	player_attack_05_time = 0.0
	player_is_playing_attack_05 = false
	player_guard_time = 0.0
	player_hit_flash_remaining = 0.0
	player_hit_flash_strength = 0.0
	player_hit_white_textures.clear()
	zhao_yun_ultimate_effect_marks.clear()
	player_death_cinematic_active = false
	player_death_elapsed = 0.0
	player_death_faces_left = false
	player_death_hero_id = ""
	player_death_cinematic_duration = PLAYER_DEATH_CINEMATIC_DURATION
	archer_projectiles.clear()
	archer_impact_marks.clear()
	crossbow_bolts.clear()
	crossbow_impact_marks.clear()
	banner_command_marks.clear()
	firewheel_rings.clear()
	guan_blade_waves.clear()
	elite_corpses.clear()
	named_hit_marks.clear()
	tianji_marks.clear()
	tianji_wind_marks.clear()
	tianji_water_marks.clear()
	tianji_arrow_marks.clear()
	tianji_fire_rain_marks.clear()
	weapon_clash_marks.clear()
	guard_feedback_marks.clear()
	stance_break_marks.clear()
	enemy_last_positions.resize(EnemySimulation.CAPACITY)
	enemy_is_moving.resize(EnemySimulation.CAPACITY)
	enemy_move_animation_holds.resize(EnemySimulation.CAPACITY)
	for id in range(EnemySimulation.CAPACITY):
		enemy_last_positions[id] = enemies.positions[id]
		enemy_is_moving[id] = 0
		enemy_move_animation_holds[id] = 0.0

func set_elites(elite_actors: Array[EliteActor]) -> void:
	elites = elite_actors
	queue_redraw()

func set_battle_camera(camera: Camera2D) -> void:
	battle_camera = camera

func set_weather_mode(mode: String) -> void:
	weather_mode = mode if mode in [WEATHER_SUNNY, WEATHER_RAIN, WEATHER_STORM] else WEATHER_SUNNY
	weather_seed = randf_range(0.0, 1000.0)
	weather_lightning_seed = randf_range(0.0, 1000.0)
	weather_lightning_remaining = 0.0
	weather_lightning_cooldown = randf_range(4.8, 8.4)
	queue_redraw()

func begin_player_death_cinematic(hero_id: String) -> void:
	player_death_cinematic_active = true
	player_death_elapsed = 0.0
	player_death_faces_left = player != null and player.last_attack_direction.x < 0.0
	player_death_hero_id = hero_id
	player_death_cinematic_duration = GUAN_YU_DEATH_CINEMATIC_DURATION if hero_id == "guan_yu" else (ZHANG_FEI_DEATH_CINEMATIC_DURATION if hero_id == "zhang_fei" else PLAYER_DEATH_CINEMATIC_DURATION)
	player_is_moving = false
	guan_yu_was_moving = false
	zhang_fei_was_moving = false
	zhang_fei_ultimate_animation_time = 0.0
	zhang_fei_is_casting_ultimate = false
	wushuang_ready_animation_time = 0.0
	wushuang_ready_was_active = false
	player_is_playing_attack_01 = false
	player_is_playing_attack_02 = false
	player_is_playing_attack_03 = false
	player_is_playing_attack_04 = false
	player_is_playing_attack_05 = false
	player_hit_flash_remaining = 0.0
	flashes.clear()
	pickup_marks.clear()
	impact_marks.clear()
	named_hit_marks.clear()
	tianji_marks.clear()
	tianji_wind_marks.clear()
	tianji_water_marks.clear()
	tianji_arrow_marks.clear()
	tianji_fire_rain_marks.clear()
	weapon_clash_marks.clear()
	guard_feedback_marks.clear()
	stance_break_marks.clear()
	shield_break_marks.clear()
	ultimate_wave_marks.clear()
	zhao_yun_ultimate_effect_marks.clear()
	death_collision_marks.clear()
	archer_projectiles.clear()
	archer_impact_marks.clear()
	crossbow_bolts.clear()
	crossbow_impact_marks.clear()
	banner_command_marks.clear()
	firewheel_rings.clear()
	guan_blade_waves.clear()
	for id in range(enemy_is_moving.size()):
		enemy_is_moving[id] = 0
		enemy_move_animation_holds[id] = 0.0
	queue_redraw()

func tick_player_death_cinematic(delta: float) -> void:
	if not player_death_cinematic_active:
		return
	player_death_elapsed = minf(player_death_cinematic_duration, player_death_elapsed + delta)
	visual_time += delta
	_tick_weather(delta)
	queue_redraw()

func is_player_death_cinematic_finished() -> bool:
	return player_death_cinematic_active and player_death_elapsed >= player_death_cinematic_duration

func end_player_death_cinematic() -> void:
	player_death_cinematic_active = false
	player_death_elapsed = 0.0
	player_death_hero_id = ""
	queue_redraw()

func add_flash(request: AttackRequest) -> void:
	if request.label == "穿阵挑刺":
		return
	# Keep a small visual seed on creation so the wind shape does not visibly reshuffle every frame.
	var duration := _flash_duration_for_request(request)
	flashes.append({"request": _copy_request_for_visual(request), "remaining": duration, "duration": duration, "variant": randi_range(0, 5)})

func _flash_duration_for_request(request: AttackRequest) -> float:
	if request.label == "乾坤掷轮":
		return FIREWHEEL_PROJECTILE_FLASH_DURATION
	if request.label in ["丈八跃砸", "据水断桥·跃砸"]:
		var landing_duration := 0.0
		for frame_duration in ZHANG_FEI_LANDING_FRAME_DURATIONS:
			landing_duration += frame_duration
		return landing_duration
	if request.label in ["武圣震阵", "武圣拖刀震阵", "万夫莫开·怒喝震阵"]:
		return WUSHUANG_IMPACT_FRAME_DURATION * float(WUSHUANG_IMPACT_TEXTURES.size())
	if request.label in ["拖刀刀浪", "青龙断浪", "武圣刀浪"]:
		return 0.34
	if request.label.begins_with("威震华夏"):
		return 0.24
	return FLASH_DURATION

func add_pickup(at: Vector2) -> void:
	pickup_marks.append({"position": at, "remaining": 0.45})

func add_impact(at: Vector2, attack_label: String, hit_count: int) -> void:
	var heavy_hit: bool = attack_label in ["穿阵挑刺", "破军", "破军收势", "七进七出", "七进七出·收势", "哪吒火轮", "拖刀断阵", "青龙断浪", "威震华夏·横江", "威震华夏·断岳", "威震华夏·斩将", "丈八跃砸", "据水断桥·跃砸", "万夫莫开·怒喝震阵"]
	impact_marks.append({"position": at, "remaining": 0.18 if heavy_hit else 0.13, "label": attack_label, "hits": hit_count})
	shake_remaining = maxf(shake_remaining, 0.13 if heavy_hit else 0.09)
	var base_strength := 5.0 if heavy_hit else 2.8
	shake_strength = maxf(shake_strength, minf(12.0, base_strength + float(hit_count) * 1.25))

func add_weapon_clash(at: Vector2, perfect: bool, skill_clash: bool = false, minor: bool = false) -> void:
	var duration := 0.23 if minor else (0.44 if perfect else (0.38 if skill_clash else 0.30))
	weapon_clash_marks.append({"position": at, "remaining": duration, "duration": duration, "perfect": perfect, "skill": skill_clash, "minor": minor, "seed": randi_range(0, 10)})
	shake_remaining = maxf(shake_remaining, 0.075 if minor else (0.22 if perfect else (0.18 if skill_clash else 0.13)))
	shake_strength = maxf(shake_strength, 5.5 if minor else (16.0 if perfect else (13.0 if skill_clash else 10.0)))

func add_guard_feedback(at: Vector2, direction: Vector2, perfect: bool) -> void:
	var normalized_direction := direction.normalized()
	if normalized_direction.length_squared() <= 0.01:
		normalized_direction = Vector2.RIGHT
	var duration := 0.40 if perfect else 0.32
	guard_feedback_marks.append({
		"position": at,
		"direction": normalized_direction,
		"remaining": duration,
		"duration": duration,
		"perfect": perfect,
	})

func add_stance_break(at: Vector2) -> void:
	stance_break_marks.append({"position": at, "remaining": 0.48})
	shake_remaining = maxf(shake_remaining, 0.15)
	shake_strength = maxf(shake_strength, 10.0)

func add_named_hit_feedback(at: Vector2, direction: Vector2, strength: float, emphasized: bool = false) -> void:
	var normalized_direction := direction.normalized()
	if normalized_direction.length_squared() <= 0.01:
		normalized_direction = Vector2.RIGHT
	var duration := 0.30 if emphasized else 0.24
	named_hit_marks.append({
		"position": at,
		"direction": normalized_direction,
		"remaining": duration,
		"duration": duration,
		"strength": clampf(strength, 0.35, 1.0),
		"emphasized": emphasized,
		"seed": randi_range(0, 1000),
	})
	shake_remaining = maxf(shake_remaining, 0.10 if emphasized else 0.06)
	shake_strength = maxf(shake_strength, 7.0 if emphasized else 4.0)

func add_tianji_windup(skill_id: String, center: Vector2, direction: Vector2, definition: Dictionary, rank: int = 1, radius: float = 0.0) -> void:
	var normalized_direction := direction.normalized()
	if normalized_direction.length_squared() <= 0.01:
		normalized_direction = Vector2.RIGHT
	var duration := maxf(0.10, float(definition.get("precast", 0.50)))
	var windup_width := float(definition.get("width", 0.0))
	if skill_id == "xun_wind_break":
		# The windup must preview the same rank-scaled breadth as the tornado
		# that follows, otherwise the effect visibly expands after it fires.
		windup_width = maxf(windup_width, radius)
	tianji_marks.append({
		"id": skill_id,
		"phase": "windup",
		"position": center,
		"direction": normalized_direction,
		"remaining": duration,
		"duration": duration,
		"rank": rank,
		"radius": radius if radius > 0.0 else float(definition.get("radius", 0.0)),
		"range": float(definition.get("range", 0.0)),
		"width": windup_width,
	})

func add_tianji_impact(skill_id: String, center: Vector2, direction: Vector2, hit_count: int, active_duration: float = 0.0, rank: int = 1, radius: float = 0.0) -> void:
	var normalized_direction := direction.normalized()
	if normalized_direction.length_squared() <= 0.01:
		normalized_direction = Vector2.UP
	if skill_id == "arrow_support_volley":
		_add_tianji_arrow_volley(center, radius if radius > 0.0 else TIANJI_ARROW_VOLLEY_RADIUS)
		shake_remaining = maxf(shake_remaining, 0.05)
		shake_strength = maxf(shake_strength, 2.5)
		return
	if skill_id in ["fire_rain_burning", "fire_rain_final"]:
		return
	if skill_id == "xun_wind_break":
		var visible_rect := _visible_battle_rect()
		var wind_width := maxf(48.0, radius)
		var wind_travel_distance := visible_rect.size.x + wind_width * 2.0
		var wind_duration := maxf(0.28, active_duration if active_duration > 0.0 else 0.42)
		tianji_wind_marks.append({
			"position": center,
			"direction": normalized_direction,
			"elapsed": 0.0,
			"remaining": wind_duration,
			"duration": wind_duration,
			"width": wind_width,
			"travel_distance": wind_travel_distance,
			"rank": clampi(rank, 1, 5),
		})
		shake_remaining = maxf(shake_remaining, 0.05)
		shake_strength = maxf(shake_strength, 2.5)
		return
	if skill_id == "eight_trigram_tide":
		var water_rank := clampi(rank, 1, 5)
		var travel_distances: Array[float] = [560.0, 640.0, 720.0, 800.0, 880.0]
		var visible_rect := _visible_battle_rect()
		var water_width := maxf(140.0, radius)
		var path_y := clampf(center.y, visible_rect.position.y + water_width * 0.32, visible_rect.end.y - water_width * 0.32)
		var start_x := visible_rect.position.x - water_width
		var end_x := visible_rect.end.x + water_width
		var water_origin := Vector2(start_x, path_y)
		var water_travel_distance := maxf(travel_distances[water_rank - 1], end_x - start_x)
		var reflux_delay := 0.16 if water_rank >= 5 else 0.0
		var reflux_duration := 0.72 if water_rank >= 5 else 0.0
		var layer_count := _tianji_water_layer_count(water_rank)
		var layer_stagger := _tianji_water_layer_stagger(layer_count)
		# TianjiSystem includes the delayed trailing crests in active_duration.
		# Remove that shared delay here so every visual crest keeps the same
		# travel speed as its corresponding gameplay wave.
		var total_duration := maxf(1.0, active_duration if active_duration > 0.0 else 1.55)
		var trailing_delay := float(layer_count - 1) * layer_stagger
		var wave_duration := maxf(0.60, total_duration - trailing_delay)
		var surge_duration := maxf(0.60, wave_duration - reflux_delay - reflux_duration)
		tianji_water_marks.append({
			"origin": water_origin,
			"direction": Vector2.RIGHT,
			"elapsed": 0.0,
			"remaining": total_duration + 0.18,
			"duration": wave_duration,
			"surge_duration": surge_duration,
			"reflux_delay": reflux_delay,
			"reflux_duration": reflux_duration,
			"width": water_width,
			"travel_distance": water_travel_distance,
			"rank": water_rank,
			"layer_count": layer_count,
			"layer_stagger": layer_stagger,
		})
		shake_remaining = maxf(shake_remaining, 0.12 if water_rank >= 5 else 0.08)
		shake_strength = maxf(shake_strength, 7.5 if water_rank >= 5 else 4.0)
		return
	var duration := TIANJI_LIGHTNING_FRAME_DURATION * float((TIANJI_LIGHTNING_FRAME_SEQUENCES.get(clampi(rank, 1, 5), []) as Array).size()) if skill_id == "seven_star_lightning" else maxf(0.28, active_duration if active_duration > 0.0 else 0.42)
	var wind_range := 0.0
	var wind_width := 0.0
	tianji_marks.append({
		"id": skill_id,
		"phase": "impact",
		"position": center,
		"direction": normalized_direction,
		"remaining": duration,
		"duration": duration,
		"hit_count": hit_count,
		"active_duration": active_duration,
		"rank": rank,
		"radius": radius if radius > 0.0 else (TIANJI_ARROW_VOLLEY_RADIUS if skill_id == "arrow_support_volley" else 0.0),
		"range": wind_range,
		"width": wind_width,
		"seed": randi_range(0, 100000),
	})
	shake_remaining = maxf(shake_remaining, 0.10 if active_duration <= 0.0 else 0.05)
	shake_strength = maxf(shake_strength, 6.0 if active_duration <= 0.0 else 2.5)

func add_fire_rain_meteor(center: Vector2, rank: int, final_meteor: bool, delay: float, radius: float, wave_index: int = -1, wave_last: bool = false) -> void:
	var is_final := final_meteor
	var frame_count := TIANJI_FIRE_RAIN_FINAL_TEXTURES.size() if is_final else TIANJI_FIRE_RAIN_METEOR_TEXTURES.size()
	var frame_duration := TIANJI_FIRE_RAIN_FINAL_FRAME_DURATION if is_final else TIANJI_FIRE_RAIN_FRAME_DURATION
	var scale := TIANJI_FIRE_RAIN_FINAL_SCALE if is_final else TIANJI_FIRE_RAIN_METEOR_SCALE
	tianji_fire_rain_marks.append({
		"target": center,
		"elapsed": -maxf(0.0, delay),
		"frame_duration": frame_duration,
		"frame_count": frame_count,
		"scale": scale * randf_range(0.92, 1.08) if not is_final else scale,
		"final": is_final,
		"radius": radius,
		"wave_last": wave_last,
		"wave_index": wave_index,
		"sky_distance": randf_range(180.0, 260.0) if not is_final else 220.0,
		"impact_feedback_played": false,
	})
	while tianji_fire_rain_marks.size() > TIANJI_FIRE_RAIN_MAX_MARKS:
		tianji_fire_rain_marks.pop_front()

func _add_tianji_arrow_volley(center: Vector2, radius: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(center.x * 17.0 + center.y * 31.0)) + randi_range(1, 100000)
	var ground_center := center + Vector2(0.0, 9.0)
	var outer_radius := maxf(48.0, radius)
	var visible_rect := _visible_battle_rect()
	var arrows: Array[Dictionary] = []
	for index in range(TIANJI_ARROW_VOLLEY_ARROW_COUNT):
		var angle := TAU * rng.randf() + float(index) * 2.39996323
		var distance := sqrt(rng.randf_range(0.15, 1.0)) * outer_radius * 0.86
		var target := ground_center + Vector2.from_angle(angle) * distance
		var sky_x := clampf(target.x + rng.randf_range(-118.0, 118.0), visible_rect.position.x + 16.0, visible_rect.end.x - 16.0)
		var sky_y := visible_rect.position.y - TIANJI_ARROW_SKY_ENTRY_OFFSET - rng.randf_range(0.0, 34.0)
		var origin := Vector2(sky_x, sky_y)
		var delay := rng.randf_range(0.0, 0.14)
		var flight_duration := TIANJI_ARROW_FLIGHT_DURATION + rng.randf_range(-0.05, 0.06)
		var lodged_direction := Vector2.DOWN.rotated(rng.randf_range(-0.52, 0.52))
		arrows.append({
			"origin": origin,
			"target": target,
			"delay": delay,
			"flight_duration": flight_duration,
			"lodged_direction": lodged_direction,
		})
	var total_duration := 0.14 + TIANJI_ARROW_FLIGHT_DURATION + 0.08 + TIANJI_ARROW_LODGED_DURATION
	tianji_arrow_marks.append({
		"center": ground_center,
		"radius": outer_radius,
		"elapsed": 0.0,
		"duration": total_duration,
		"arrows": arrows,
	})
	while tianji_arrow_marks.size() > TIANJI_ARROW_MAX_VOLLEY_MARKS:
		tianji_arrow_marks.pop_front()

func add_victory_arrow_salvo() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = randi_range(1, 1000000)
	var visible_rect := _visible_battle_rect()
	var arrows: Array[Dictionary] = []
	for index in range(VICTORY_ARROW_SALVO_ARROW_COUNT):
		var target := Vector2(
			rng.randf_range(visible_rect.position.x + 22.0, visible_rect.end.x - 22.0),
			rng.randf_range(visible_rect.position.y + visible_rect.size.y * 0.18, visible_rect.position.y + visible_rect.size.y * 0.90)
		)
		var origin := Vector2(
			clampf(target.x + rng.randf_range(-132.0, 132.0), visible_rect.position.x + 12.0, visible_rect.end.x - 12.0),
			visible_rect.position.y - TIANJI_ARROW_SKY_ENTRY_OFFSET - rng.randf_range(12.0, 80.0)
		)
		arrows.append({
			"origin": origin,
			"target": target,
			"delay": rng.randf_range(0.0, 0.18),
			"flight_duration": rng.randf_range(0.32, 0.44),
			"lodged_direction": Vector2.DOWN.rotated(rng.randf_range(-0.56, 0.56)),
		})
	var total_duration := 0.18 + 0.44 + TIANJI_ARROW_LODGED_DURATION
	tianji_arrow_marks.append({
		"center": visible_rect.get_center(),
		"radius": 0.0,
		"elapsed": 0.0,
		"duration": total_duration,
		"arrows": arrows,
		"show_ground_ring": false,
	})
	while tianji_arrow_marks.size() > TIANJI_ARROW_MAX_VOLLEY_MARKS:
		tianji_arrow_marks.pop_front()

func add_named_skill_shake(strength: float) -> void:
	shake_remaining = maxf(shake_remaining, 0.15)
	shake_strength = maxf(shake_strength, clampf(strength, 4.0, 13.0))

func add_ultimate_dash_wave(at: Vector2, direction: Vector2, distance: float, segment: int) -> void:
	var normalized_direction := direction.normalized()
	if normalized_direction.length_squared() <= 0.01:
		normalized_direction = Vector2.RIGHT
	ultimate_wave_marks.append({"position": at, "direction": normalized_direction, "distance": distance, "segment": segment, "remaining": 0.48})
	if player == null or player.presentation_id() != "zhao_yun":
		return
	# A fresh burst accompanies each Seven Entries, Seven Exits dash without stacking opaque frames.
	for index in range(zhao_yun_ultimate_effect_marks.size() - 1, -1, -1):
		var previous_mark: Dictionary = zhao_yun_ultimate_effect_marks[index]
		previous_mark["remaining"] = minf(float(previous_mark.get("remaining", 0.0)), 0.08)
		zhao_yun_ultimate_effect_marks[index] = previous_mark
	var duration := ZHAO_YUN_ULTIMATE_EFFECT_FRAME_DURATION * float(ZHAO_YUN_ULTIMATE_EFFECT_TEXTURES.size())
	zhao_yun_ultimate_effect_marks.append({
		"position": at,
		"direction": normalized_direction,
		"segment": player.ultimate_segment_index,
		"elapsed": 0.0,
		"remaining": duration,
		"duration": duration,
	})

func add_death_collision(at: Vector2, direction: Vector2) -> void:
	death_collision_marks.append({"position": at, "direction": direction.normalized(), "remaining": 0.22})

func add_elite_corpse(elite: EliteActor) -> void:
	if elite_corpses.size() >= MAX_ELITE_CORPSES:
		elite_corpses.pop_front()
	var direction := elite.current_direction
	if direction.length_squared() <= 0.01:
		direction = Vector2.DOWN
	elite_corpses.append({
		"archetype": int(elite.archetype),
		"position": elite.position,
		"direction": direction,
	})
	queue_redraw()

func add_archer_projectile(source_enemy_id: int, origin: Vector2, target: Vector2, windup: float) -> void:
	var direction := (target - origin).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var launch_delay := windup * ARCHER_PROJECTILE_LAUNCH_RATIO
	var flight_duration := maxf(0.12, windup - launch_delay)
	archer_projectiles.append({
		"source_enemy_id": source_enemy_id,
		"origin": origin + direction * 18.0 + Vector2(0, -24),
		"target": target,
		"total_duration": windup,
		"launch_delay": launch_delay,
		"flight_duration": flight_duration,
		"remaining": windup,
	})

func cancel_archer_projectiles(source_enemy_id: int) -> void:
	for index in range(archer_projectiles.size() - 1, -1, -1):
		if int(archer_projectiles[index].get("source_enemy_id", -1)) == source_enemy_id:
			archer_projectiles.remove_at(index)

func cancel_next_archer_projectile(source_enemy_id: int) -> void:
	var selected_index := -1
	var selected_remaining := INF
	for index in range(archer_projectiles.size()):
		var projectile: Dictionary = archer_projectiles[index] as Dictionary
		if int(projectile.get("source_enemy_id", -1)) != source_enemy_id:
			continue
		var remaining := float(projectile.get("remaining", INF))
		if remaining < selected_remaining:
			selected_index = index
			selected_remaining = remaining
	if selected_index >= 0:
		archer_projectiles.remove_at(selected_index)

func add_crossbow_bolt(source_enemy_id: int, origin: Vector2, target: Vector2, windup: float) -> void:
	var direction := (target - origin).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var launch_delay := windup * 0.42
	crossbow_bolts.append({
		"source_enemy_id": source_enemy_id,
		"origin": origin + direction * 18.0 + Vector2(0.0, -18.0),
		"target": target,
		"total_duration": windup,
		"launch_delay": launch_delay,
		"flight_duration": maxf(0.08, windup - launch_delay),
		"remaining": windup,
	})

func cancel_crossbow_bolts(source_enemy_id: int) -> void:
	for index in range(crossbow_bolts.size() - 1, -1, -1):
		if int(crossbow_bolts[index].get("source_enemy_id", -1)) == source_enemy_id:
			crossbow_bolts.remove_at(index)

func cancel_next_crossbow_bolt(source_enemy_id: int) -> void:
	var selected_index := -1
	var selected_remaining := INF
	for index in range(crossbow_bolts.size()):
		var bolt: Dictionary = crossbow_bolts[index] as Dictionary
		if int(bolt.get("source_enemy_id", -1)) != source_enemy_id:
			continue
		var remaining := float(bolt.get("remaining", INF))
		if remaining < selected_remaining:
			selected_index = index
			selected_remaining = remaining
	if selected_index >= 0:
		crossbow_bolts.remove_at(selected_index)

func cancel_projectiles_for_enemy(source_enemy_id: int) -> void:
	cancel_archer_projectiles(source_enemy_id)
	cancel_crossbow_bolts(source_enemy_id)

func add_banner_command(at: Vector2) -> void:
	banner_command_marks.append({"position": at, "remaining": 0.54, "duration": 0.54})

func _load_guan_knife_wave_frames() -> void:
	# Static references keep every required frame inside the Android export PCK.
	guan_knife_wave_frames = GUAN_KNIFE_WAVE_TEXTURES.duplicate()

static func archer_projectile_position(origin: Vector2, target: Vector2, progress: float, arc_height: float = ARCHER_PROJECTILE_ARC_HEIGHT) -> Vector2:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	return origin.lerp(target, clamped_progress) + Vector2.UP * sin(clamped_progress * PI) * arc_height

static func archer_projectile_tangent(origin: Vector2, target: Vector2, progress: float, arc_height: float = ARCHER_PROJECTILE_ARC_HEIGHT) -> Vector2:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	return (target - origin) + Vector2.UP * cos(clamped_progress * PI) * arc_height * PI

func _on_player_protection_broken() -> void:
	if player != null:
		shield_break_marks.append({"position": player.position + Vector2(0, -12), "remaining": 0.24})

func _on_player_damaged(amount: float) -> void:
	player_hit_flash_remaining = PLAYER_HIT_FLASH_DURATION
	player_hit_flash_strength = clampf(0.82 + amount * 0.018, 0.82, 1.0)

func _on_hero_visual_effect_started(effect_id: String, origin: Vector2, direction: Vector2, travel_distance: float, metadata: Dictionary) -> void:
	if effect_id == "firewheel_ring":
		firewheel_rings.append({"position": origin, "direction": direction.normalized(), "remaining": travel_distance})
	elif effect_id in ["guan_drag_wave", "guan_active_wave", "guan_wusheng_wave", "guan_fourth_wave"]:
		var frame_max := clampi(int(metadata.get("max_frame", 4)), 0, 13)
		var expansion_frames := _guan_knife_wave_expansion_frames(frame_max)
		var infinite := bool(metadata.get("infinite", false))
		var hold_duration := GUAN_KNIFE_WAVE_INFINITE_HOLD_DURATION if infinite else 0.0
		var expansion_duration := GUAN_KNIFE_WAVE_EXPANSION_DURATION
		var travel_duration := maxf(expansion_duration + hold_duration, float(metadata.get("travel_duration", travel_distance / GUAN_BLADE_WAVE_SPEED)))
		var base_scale := float(metadata.get("scale", 0.60))
		var display_scale := _guan_knife_wave_display_scale(frame_max, base_scale, travel_distance, infinite)
		guan_blade_waves.append({
			"origin": origin,
			"direction": direction.normalized(),
			"elapsed": 0.0,
			"expansion_duration": expansion_duration,
			"hold_duration": hold_duration,
			"frame_max": frame_max,
			"scale": display_scale,
			"infinite": infinite,
			"kind": effect_id,
		})

func tick_visuals(delta: float) -> void:
	visual_time += delta
	_tick_weather(delta)
	player_hit_flash_remaining = maxf(0.0, player_hit_flash_remaining - delta)
	_tick_player_animation(delta)
	_tick_enemy_animation(delta)
	for index in range(flashes.size() - 1, -1, -1):
		flashes[index].remaining -= delta
		if flashes[index].remaining <= 0.0:
			flashes.remove_at(index)
	for index in range(pickup_marks.size() - 1, -1, -1):
		pickup_marks[index].remaining -= delta
		if pickup_marks[index].remaining <= 0.0:
			pickup_marks.remove_at(index)
	for index in range(impact_marks.size() - 1, -1, -1):
		impact_marks[index].remaining -= delta
		if impact_marks[index].remaining <= 0.0:
			impact_marks.remove_at(index)
	for index in range(named_hit_marks.size() - 1, -1, -1):
		named_hit_marks[index].remaining -= delta
		if named_hit_marks[index].remaining <= 0.0:
			named_hit_marks.remove_at(index)
	for index in range(tianji_marks.size() - 1, -1, -1):
		tianji_marks[index].remaining -= delta
		if tianji_marks[index].remaining <= 0.0:
			tianji_marks.remove_at(index)
	for index in range(tianji_wind_marks.size() - 1, -1, -1):
		var wind_mark: Dictionary = tianji_wind_marks[index]
		wind_mark["elapsed"] = float(wind_mark.get("elapsed", 0.0)) + delta
		wind_mark["remaining"] = float(wind_mark.get("remaining", 0.0)) - delta
		if float(wind_mark.get("remaining", 0.0)) <= 0.0:
			tianji_wind_marks.remove_at(index)
		else:
			tianji_wind_marks[index] = wind_mark
	for index in range(tianji_water_marks.size() - 1, -1, -1):
		var water_mark: Dictionary = tianji_water_marks[index]
		water_mark["elapsed"] = float(water_mark.get("elapsed", 0.0)) + delta
		water_mark["remaining"] = float(water_mark.get("remaining", 0.0)) - delta
		if float(water_mark.get("remaining", 0.0)) <= 0.0:
			tianji_water_marks.remove_at(index)
		else:
			tianji_water_marks[index] = water_mark
	for index in range(tianji_arrow_marks.size() - 1, -1, -1):
		var arrow_mark: Dictionary = tianji_arrow_marks[index]
		arrow_mark["elapsed"] = float(arrow_mark.get("elapsed", 0.0)) + delta
		if float(arrow_mark.get("elapsed", 0.0)) >= float(arrow_mark.get("duration", 0.0)):
			tianji_arrow_marks.remove_at(index)
		else:
			tianji_arrow_marks[index] = arrow_mark
	for index in range(tianji_fire_rain_marks.size() - 1, -1, -1):
		var meteor: Dictionary = tianji_fire_rain_marks[index]
		meteor["elapsed"] = float(meteor.get("elapsed", 0.0)) + delta
		var elapsed := float(meteor.get("elapsed", 0.0))
		var final_meteor := bool(meteor.get("final", false))
		var frame_duration := maxf(0.01, float(meteor.get("frame_duration", 0.035)))
		var flight_duration := TIANJI_FIRE_RAIN_FINAL_FLIGHT_DURATION if final_meteor else 0.34
		var impact_elapsed := flight_duration + (frame_duration * float(TIANJI_FIRE_RAIN_FINAL_LANDING_FRAME) if final_meteor else 0.0)
		if elapsed >= 0.0 and not bool(meteor.get("impact_feedback_played", false)):
			if elapsed >= impact_elapsed:
				meteor["impact_feedback_played"] = true
				if final_meteor:
					var final_rank := int(meteor.get("rank", 1))
					shake_remaining = maxf(shake_remaining, 0.70 if final_rank >= 5 else 0.48)
					shake_strength = maxf(shake_strength, 32.0 if final_rank >= 5 else 22.0)
				elif bool(meteor.get("wave_last", false)):
					shake_remaining = maxf(shake_remaining, 0.18)
					shake_strength = maxf(shake_strength, 8.0)
				else:
					shake_remaining = maxf(shake_remaining, 0.09)
					shake_strength = maxf(shake_strength, 5.0)
		var frame_count := int(meteor.get("frame_count", 1))
		# The timer starts at -delay. Keep the delay implicit, but retain the full
		# sky-to-ground flight before the impact animation and its fade-out.
		var total_duration := flight_duration + float(frame_count) * frame_duration + 0.28
		if elapsed > total_duration:
			tianji_fire_rain_marks.remove_at(index)
		else:
			tianji_fire_rain_marks[index] = meteor
	for index in range(weapon_clash_marks.size() - 1, -1, -1):
		weapon_clash_marks[index].remaining -= delta
		if weapon_clash_marks[index].remaining <= 0.0:
			weapon_clash_marks.remove_at(index)
	for index in range(guard_feedback_marks.size() - 1, -1, -1):
		guard_feedback_marks[index].remaining -= delta
		if guard_feedback_marks[index].remaining <= 0.0:
			guard_feedback_marks.remove_at(index)
	for index in range(stance_break_marks.size() - 1, -1, -1):
		stance_break_marks[index].remaining -= delta
		if stance_break_marks[index].remaining <= 0.0:
			stance_break_marks.remove_at(index)
	for index in range(shield_break_marks.size() - 1, -1, -1):
		shield_break_marks[index].remaining -= delta
		if shield_break_marks[index].remaining <= 0.0:
			shield_break_marks.remove_at(index)
	for index in range(ultimate_wave_marks.size() - 1, -1, -1):
		ultimate_wave_marks[index].remaining -= delta
		if ultimate_wave_marks[index].remaining <= 0.0:
			ultimate_wave_marks.remove_at(index)
	for index in range(zhao_yun_ultimate_effect_marks.size() - 1, -1, -1):
		var effect_mark: Dictionary = zhao_yun_ultimate_effect_marks[index]
		if player != null and player.presentation_id() == "zhao_yun" and player.ultimate_time > 0.0 and int(effect_mark.get("segment", -1)) == player.ultimate_segment_index:
			effect_mark["position"] = player.position
		effect_mark["elapsed"] = float(effect_mark.get("elapsed", 0.0)) + delta
		effect_mark["remaining"] = float(effect_mark.get("remaining", 0.0)) - delta
		if float(effect_mark.get("remaining", 0.0)) <= 0.0:
			zhao_yun_ultimate_effect_marks.remove_at(index)
		else:
			zhao_yun_ultimate_effect_marks[index] = effect_mark
	for index in range(death_collision_marks.size() - 1, -1, -1):
		death_collision_marks[index].remaining -= delta
		if death_collision_marks[index].remaining <= 0.0:
			death_collision_marks.remove_at(index)
	for index in range(archer_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = archer_projectiles[index]
		projectile["remaining"] = float(projectile.get("remaining", 0.0)) - delta
		if float(projectile.get("remaining", 0.0)) <= 0.0:
			var origin: Vector2 = projectile.get("origin", Vector2.ZERO)
			var target: Vector2 = projectile.get("target", origin)
			var direction := archer_projectile_tangent(origin, target, 1.0).normalized()
			archer_impact_marks.append({"position": target, "direction": direction, "remaining": 0.18})
			archer_projectiles.remove_at(index)
		else:
			archer_projectiles[index] = projectile
	for index in range(archer_impact_marks.size() - 1, -1, -1):
		archer_impact_marks[index].remaining -= delta
		if archer_impact_marks[index].remaining <= 0.0:
			archer_impact_marks.remove_at(index)
	for index in range(crossbow_bolts.size() - 1, -1, -1):
		var bolt: Dictionary = crossbow_bolts[index]
		bolt["remaining"] = float(bolt.get("remaining", 0.0)) - delta
		if float(bolt.get("remaining", 0.0)) <= 0.0:
			var bolt_target: Vector2 = bolt.get("target", Vector2.ZERO)
			crossbow_impact_marks.append({"position": bolt_target, "remaining": 0.14})
			crossbow_bolts.remove_at(index)
		else:
			crossbow_bolts[index] = bolt
	for index in range(crossbow_impact_marks.size() - 1, -1, -1):
		crossbow_impact_marks[index].remaining -= delta
		if crossbow_impact_marks[index].remaining <= 0.0:
			crossbow_impact_marks.remove_at(index)
	for index in range(banner_command_marks.size() - 1, -1, -1):
		banner_command_marks[index].remaining -= delta
		if banner_command_marks[index].remaining <= 0.0:
			banner_command_marks.remove_at(index)
	for index in range(firewheel_rings.size() - 1, -1, -1):
		var ring: Dictionary = firewheel_rings[index]
		var remaining := maxf(0.0, float(ring.get("remaining", 0.0)) - FIREWHEEL_RING_SPEED * delta)
		var direction: Vector2 = ring.get("direction", Vector2.RIGHT)
		var ring_position: Vector2 = ring.get("position", Vector2.ZERO)
		ring["position"] = ring_position + direction * minf(FIREWHEEL_RING_SPEED * delta, float(ring.get("remaining", 0.0)))
		ring["remaining"] = remaining
		if remaining <= 0.0:
			firewheel_rings.remove_at(index)
		else:
			firewheel_rings[index] = ring
	for index in range(guan_blade_waves.size() - 1, -1, -1):
		var wave: Dictionary = guan_blade_waves[index]
		var elapsed := float(wave.get("elapsed", 0.0)) + delta
		var expansion_duration := maxf(0.01, float(wave.get("expansion_duration", GUAN_KNIFE_WAVE_FRAME_DURATION)))
		var hold_duration := maxf(0.0, float(wave.get("hold_duration", 0.0)))
		if elapsed >= expansion_duration + hold_duration + GUAN_KNIFE_WAVE_FADE_DURATION:
			guan_blade_waves.remove_at(index)
			continue
		wave["elapsed"] = elapsed
		guan_blade_waves[index] = wave
	shake_remaining = maxf(0.0, shake_remaining - delta)
	if shake_remaining > 0.0:
		position = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	else:
		position = Vector2.ZERO
		shake_strength = 0.0
	queue_redraw()

func _tick_weather(delta: float) -> void:
	if weather_mode != WEATHER_STORM:
		return
	weather_lightning_remaining = maxf(0.0, weather_lightning_remaining - delta)
	weather_lightning_cooldown = maxf(0.0, weather_lightning_cooldown - delta)
	if weather_lightning_cooldown > 0.0:
		return
	weather_lightning_remaining = WEATHER_LIGHTNING_DURATION
	weather_lightning_cooldown = randf_range(5.0, 10.0)
	weather_lightning_seed = randf_range(0.0, 1000.0)

func _tick_player_animation(delta: float) -> void:
	if player == null:
		return
	var ultimate_ready := player.is_ultimate_ready()
	if ultimate_ready:
		if not wushuang_ready_was_active:
			wushuang_ready_animation_time = 0.0
		else:
			wushuang_ready_animation_time += delta
	else:
		wushuang_ready_animation_time = 0.0
	wushuang_ready_was_active = ultimate_ready
	var movement := player.position - player_last_position
	var has_moved := movement.length_squared() > 0.25
	var is_guan_yu := player.presentation_id() == "guan_yu"
	var is_zhang_fei := player.presentation_id() == "zhang_fei"
	var drag_charge_ready := _guan_yu_drag_charge_ready()
	var can_render_standard_movement := not player.is_action_locked() and (player.ultimate_time <= 0.0 or is_guan_yu or is_zhang_fei)
	# Use Guan Yu's actual hold state rather than the transient action label.  Trial-mode
	# upgrade transitions may reset action labels while the held-input state is still active.
	var can_render_drag_movement := is_guan_yu and player.is_drag_charging()
	var has_drag_movement_input := can_render_drag_movement and player.movement_input_direction().length_squared() > 0.01
	var is_moving_for_animation := has_drag_movement_input if can_render_drag_movement else has_moved
	player_is_moving = is_moving_for_animation and (can_render_standard_movement or can_render_drag_movement)
	var uses_drag_motion := player_is_moving and is_guan_yu and (drag_charge_ready or player.is_wusheng_active())
	var sprite_direction := player.path_dash_visual_direction() if player.is_path_dashing() else player.last_attack_direction
	player_faces_left = sprite_direction.x < 0.0
	var is_zhang_fei_ultimate := is_zhang_fei and player.current_action == "ultimate"
	if is_zhang_fei_ultimate:
		zhang_fei_ultimate_animation_time = 0.0 if not zhang_fei_is_casting_ultimate else zhang_fei_ultimate_animation_time + delta
	zhang_fei_is_casting_ultimate = is_zhang_fei_ultimate
	var is_attack_01 := player.current_action == "basic" and player.combo_stage == 1
	if is_attack_01:
		player_attack_01_time = 0.0 if not player_is_playing_attack_01 else player_attack_01_time + delta
	player_is_playing_attack_01 = is_attack_01
	var is_attack_02 := player.current_action == "basic" and player.combo_stage == 2
	if is_attack_02:
		player_attack_02_time = 0.0 if not player_is_playing_attack_02 else player_attack_02_time + delta
	player_is_playing_attack_02 = is_attack_02
	var is_attack_03 := player.current_action == "basic" and player.combo_stage == 3
	if is_attack_03:
		player_attack_03_time = 0.0 if not player_is_playing_attack_03 else player_attack_03_time + delta
	player_is_playing_attack_03 = is_attack_03
	var is_attack_04 := player.is_firewheel_active()
	if is_attack_04:
		player_attack_04_time = 0.0 if not player_is_playing_attack_04 else player_attack_04_time + delta
	player_is_playing_attack_04 = is_attack_04
	var is_attack_05 := player.is_firewheel_finisher_active()
	if is_attack_05:
		player_attack_05_time = 0.0 if not player_is_playing_attack_05 else player_attack_05_time + delta
	player_is_playing_attack_05 = is_attack_05
	player_guard_time = player.guard_elapsed() if player.is_guard_active() else 0.0
	if player_is_moving:
		var started_moving := (is_guan_yu and not guan_yu_was_moving) or (is_zhang_fei and not zhang_fei_was_moving)
		if (is_guan_yu and (started_moving or uses_drag_motion != guan_yu_was_using_drag_motion)) or (is_zhang_fei and started_moving):
			player_walk_time = 0.0
		else:
			player_walk_time += delta
	else:
		player_idle_time += delta
	guan_yu_was_moving = player_is_moving if is_guan_yu else false
	guan_yu_was_using_drag_motion = uses_drag_motion if is_guan_yu else false
	zhang_fei_was_moving = player_is_moving if is_zhang_fei else false
	player_last_position = player.position

func _tick_enemy_animation(delta: float) -> void:
	if enemies == null:
		return
	for id in range(EnemySimulation.CAPACITY):
		var current_position := enemies.positions[id]
		var moved := enemies.is_active(id) and (enemies.has_movement_intent(id) or enemies.is_cavalry_charging(id)) and current_position.distance_squared_to(enemy_last_positions[id]) > 0.0025
		if moved:
			enemy_move_animation_holds[id] = ENEMY_MOVE_ANIMATION_HOLD
		else:
			enemy_move_animation_holds[id] = maxf(0.0, enemy_move_animation_holds[id] - delta)
		enemy_is_moving[id] = 1 if enemy_move_animation_holds[id] > 0.0 else 0
		enemy_last_positions[id] = current_position

func _draw() -> void:
	_draw_background()
	_draw_trial_atmosphere()
	_draw_weather_back()
	_draw_duel_formation()
	_draw_telegraphs()
	_draw_tianji_marks()
	_draw_tianji_wind_marks()
	_draw_tianji_water_marks()
	_draw_tianji_arrow_marks()
	_draw_tianji_fire_rain_marks()
	_draw_pickups()
	_draw_elite_corpses()
	_draw_enemies()
	_draw_elites()
	_draw_ultimate_waves()
	_draw_boss()
	_draw_player()
	_draw_zhao_yun_ultimate_effects()
	_draw_firewheel_rings()
	_draw_guan_blade_waves()
	_draw_archer_projectiles()
	_draw_archer_impact_marks()
	_draw_crossbow_bolts()
	_draw_crossbow_impact_marks()
	_draw_banner_command_marks()
	_draw_shield_breaks()
	_draw_flashes()
	_draw_impacts()
	_draw_weapon_clashes()
	_draw_guard_feedback()
	_draw_stance_breaks()
	_draw_death_collisions()
	_draw_named_hit_feedback()
	_draw_weather_front()

func _draw_trial_atmosphere() -> void:
	if battlefield_id != "hulao":
		return
	for guard_data in TRIAL_ATMOSPHERE_POSITIONS:
		var guard_position: Vector2 = guard_data.get("position", Vector2.ZERO)
		var is_shield := bool(guard_data.get("shield", false))
		var phase := float(guard_data.get("phase", 0.0))
		var facing := (BOSS_TRIAL_ARENA_BOUNDS.get_center() - guard_position).normalized()
		_draw_trial_atmosphere_guard(guard_position, is_shield, facing, phase)

func _draw_trial_atmosphere_guard(at: Vector2, is_shield: bool, facing: Vector2, phase: float) -> void:
	# Atmosphere guards are deliberately draw-only. Their animation has no
	# simulation slot, collision, hit points, AI, rewards, or attack effects.
	var cycle := fposmod(visual_time + phase, TRIAL_ATMOSPHERE_ATTACK_INTERVAL)
	var attacking := cycle >= TRIAL_ATMOSPHERE_ATTACK_INTERVAL - TRIAL_ATMOSPHERE_ATTACK_DURATION
	var texture: Texture2D
	var source_anchor: Vector2
	var frame_index := 0
	if is_shield:
		if attacking:
			var attack_progress := (cycle - (TRIAL_ATMOSPHERE_ATTACK_INTERVAL - TRIAL_ATMOSPHERE_ATTACK_DURATION)) / TRIAL_ATMOSPHERE_ATTACK_DURATION
			frame_index = mini(int(attack_progress * float(ENEMY_SHIELD_ATTACK_TEXTURES.size())), ENEMY_SHIELD_ATTACK_TEXTURES.size() - 1)
			texture = ENEMY_SHIELD_ATTACK_TEXTURES[frame_index]
		else:
			frame_index = int((visual_time + phase) / ENEMY_SHIELD_IDLE_FRAME_DURATION) % ENEMY_SHIELD_IDLE_TEXTURES.size()
			texture = ENEMY_SHIELD_IDLE_TEXTURES[frame_index]
		source_anchor = ENEMY_SHIELD_SOURCE_FOOT_ANCHOR
	else:
		if attacking:
			var attack_progress := (cycle - (TRIAL_ATMOSPHERE_ATTACK_INTERVAL - TRIAL_ATMOSPHERE_ATTACK_DURATION)) / TRIAL_ATMOSPHERE_ATTACK_DURATION
			frame_index = mini(int(attack_progress * float(ENEMY_SWORD_ATTACK_TEXTURES.size())), ENEMY_SWORD_ATTACK_TEXTURES.size() - 1)
			texture = ENEMY_SWORD_ATTACK_TEXTURES[frame_index]
			source_anchor = ENEMY_SWORD_ATTACK_FOOT_ANCHORS[frame_index]
		else:
			frame_index = int((visual_time + phase) / ENEMY_SWORD_IDLE_FRAME_DURATION) % ENEMY_SWORD_IDLE_FRAME_ORDER.size()
			var idle_index: int = int(ENEMY_SWORD_IDLE_FRAME_ORDER[frame_index])
			texture = ENEMY_SWORD_IDLE_TEXTURES[idle_index]
			source_anchor = ENEMY_SWORD_SOURCE_FOOT_ANCHOR
	var horizontal := -TRIAL_ATMOSPHERE_GUARD_SCALE if facing.x < -0.05 else TRIAL_ATMOSPHERE_GUARD_SCALE
	var foot_position := at + Vector2(0.0, 14.0)
	draw_set_transform(foot_position, 0.0, Vector2(horizontal, TRIAL_ATMOSPHERE_GUARD_SCALE))
	draw_texture(texture, -source_anchor, Color(0.78, 0.80, 0.77, 0.72))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_duel_formation() -> void:
	if enemies == null or not enemies.is_duel_formation_active():
		return
	var center := enemies.duel_formation_center() + Vector2(0.0, 12.0)
	var sealed := enemies.is_duel_formation_sealed()
	var phase_alpha := 0.16 if sealed else 0.42
	var pulse := 0.76 + 0.24 * (sin(visual_time * 4.0) + 1.0) * 0.5
	var shield_radius := enemies.duel_containment_radii()
	var spear_radius := EnemySimulation.DUEL_SPEAR_RADIUS
	var ranged_radius := EnemySimulation.DUEL_RANGED_RADIUS
	if not sealed:
		var soft_radius := enemies.duel_soft_boundary_radii()
		_draw_ellipse_arc(center, soft_radius, 0.0, TAU, 40, Color(0.95, 0.62, 0.24, 0.24 * pulse), 1.6)
		_draw_ellipse_arc(center, ranged_radius, 0.0, TAU, 40, Color(0.72, 0.50, 0.24, 0.09 * phase_alpha), 1.0)
		_draw_ellipse_arc(center, spear_radius, 0.0, TAU, 36, Color(0.82, 0.62, 0.28, 0.12 * phase_alpha), 1.3)
	else:
		_draw_ellipse_arc(center, shield_radius, 0.0, TAU, 32, Color(0.90, 0.32, 0.18, 0.09 * pulse), 1.4)
	for slot in range(EnemySimulation.DUEL_SHIELD_SLOTS):
		var angle := TAU * (float(slot) + 0.5) / float(EnemySimulation.DUEL_SHIELD_SLOTS)
		var direction := Vector2(cos(angle), sin(angle))
		var tick_root := center + Vector2(direction.x * shield_radius.x, direction.y * shield_radius.y)
		var tick_tip := center + Vector2(direction.x * (shield_radius.x + 9.0), direction.y * (shield_radius.y + 6.0))
		if not sealed:
			draw_line(tick_root, tick_tip, Color(0.96, 0.67, 0.30, 0.18 * pulse), 1.2)

func _draw_background() -> void:
	draw_rect(bounds.grow(96.0), BATTLEFIELD_LAYOUT.ground_fill_color_for(battlefield_id))
	_draw_auto_ground_layers()
	_draw_weather_ground_tint()

func _draw_auto_ground_layers() -> void:
	for layer in battlefield_ground_layers:
		var texture := layer.get("texture") as Texture2D
		if texture == null:
			continue
		var tint := Color(str(layer.get("tint", "ffffff")))
		tint.a = clampf(float(layer.get("opacity", 1.0)), 0.0, 1.0)
		var role := str(layer.get("role", "blend"))
		if role == "canvas":
			draw_texture_rect(texture, bounds, false, tint)
			continue
		if role == "base":
			_draw_mirrored_ground(texture, tint)
			continue
		if role == "blend":
			draw_texture_rect(texture, bounds, true, tint)
			continue
		var regions: Array = layer.get("regions", []) as Array
		for raw_region in regions:
			if not raw_region is Rect2:
				continue
			var region := raw_region as Rect2
			var region_rect := Rect2(bounds.position + bounds.size * region.position, bounds.size * region.size)
			draw_texture_rect(texture, region_rect, true, tint)

func _draw_mirrored_ground(texture: Texture2D, tint: Color = Color.WHITE) -> void:
	if texture == null:
		return
	var tile_size := texture.get_size()
	if tile_size.x <= 0.0 or tile_size.y <= 0.0:
		return
	var columns := maxi(1, ceili(bounds.size.x / tile_size.x))
	var rows := maxi(1, ceili(bounds.size.y / tile_size.y))
	for row in range(rows):
		for column in range(columns):
			var origin := bounds.position + Vector2(float(column) * tile_size.x, float(row) * tile_size.y)
			var rect_size := Vector2(
				minf(tile_size.x, bounds.end.x - origin.x),
				minf(tile_size.y, bounds.end.y - origin.y)
			)
			if rect_size.x <= 0.0 or rect_size.y <= 0.0:
				continue
			var flip_x := column % 2 == 1
			var flip_y := row % 2 == 1
			if not flip_x and not flip_y:
				draw_texture_rect(texture, Rect2(origin, rect_size), false, tint)
				continue
			var transform_origin := Vector2(
				origin.x * 2.0 + rect_size.x if flip_x else 0.0,
				origin.y * 2.0 + rect_size.y if flip_y else 0.0
			)
			var transform_scale := Vector2(-1.0 if flip_x else 1.0, -1.0 if flip_y else 1.0)
			draw_set_transform(transform_origin, 0.0, transform_scale)
			draw_texture_rect(texture, Rect2(origin, rect_size), false, tint)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_weather_ground_tint() -> void:
	match weather_mode:
		WEATHER_SUNNY:
			draw_rect(bounds, Color(1.0, 0.82, 0.50, 0.035))
		WEATHER_RAIN:
			draw_rect(bounds, Color(0.29, 0.43, 0.56, 0.13))
		WEATHER_STORM:
			draw_rect(bounds, Color(0.16, 0.22, 0.34, 0.22))

func _draw_weather_back() -> void:
	match weather_mode:
		WEATHER_SUNNY:
			_draw_sunny_motes(0.34)
		WEATHER_RAIN:
			_draw_rain_layer(WEATHER_RAIN_COUNT, 1, 0.28, 0.0)
		WEATHER_STORM:
			_draw_rain_layer(WEATHER_RAIN_COUNT + 10, 1, 0.34, 0.0)
			_draw_storm_lightning()

func _draw_weather_front() -> void:
	match weather_mode:
		WEATHER_RAIN:
			_draw_rain_layer(WEATHER_RAIN_COUNT, 3, 0.16, 118.0)
		WEATHER_STORM:
			_draw_rain_layer(WEATHER_RAIN_COUNT + 10, 3, 0.20, 124.0)

func _draw_sunny_motes(alpha: float) -> void:
	for index in range(WEATHER_DUST_COUNT):
		var mote := _weather_particle_position(index, 1520.0, 940.0, 10.0, 12.0)
		var mote_size := 1.0 if index % 3 else 2.0
		draw_rect(Rect2(mote, Vector2(mote_size, mote_size)), Color(1.0, 0.88, 0.62, alpha * (0.64 + float(index % 4) * 0.08)))

func _draw_rain_layer(count: int, stride: int, alpha: float, vertical_offset: float) -> void:
	for index in range(0, count, stride):
		var drop := _weather_particle_position(index, 1580.0, 980.0, 480.0, -78.0) + Vector2(0.0, vertical_offset)
		var length := 10.0 + float(index % 4) * 2.2
		var color := Color(0.62, 0.77, 0.90, alpha * (0.70 + float(index % 3) * 0.10))
		draw_line(drop, drop + Vector2(-3.4, length), color, 1.0)

func _draw_storm_lightning() -> void:
	if weather_lightning_remaining <= 0.0:
		return
	var intensity := clampf(weather_lightning_remaining / WEATHER_LIGHTNING_DURATION, 0.0, 1.0)
	draw_rect(bounds, Color(0.56, 0.68, 0.90, intensity * 0.16))
	var anchor := _weather_anchor()
	var root := anchor + Vector2(fposmod(weather_lightning_seed * 41.0, 780.0) - 390.0, -500.0)
	var points := PackedVector2Array([root])
	for step in range(1, 6):
		var x_offset := sin(weather_lightning_seed * 0.08 + float(step) * 1.9) * 18.0
		points.append(root + Vector2(x_offset, float(step) * 54.0))
	draw_polyline(points, Color(0.78, 0.88, 1.0, intensity * 0.62), 2.0, true)

func _weather_particle_position(index: int, horizontal_span: float, vertical_span: float, vertical_speed: float, horizontal_speed: float) -> Vector2:
	var local_x := fposmod(weather_seed * 37.0 + float(index) * 97.0 + visual_time * horizontal_speed, horizontal_span) - horizontal_span * 0.5
	var local_y := fposmod(weather_seed * 19.0 + float(index) * 53.0 + visual_time * vertical_speed, vertical_span) - vertical_span * 0.5
	return _weather_anchor() + Vector2(local_x, local_y)

func _weather_anchor() -> Vector2:
	return player.position if player != null else bounds.get_center()

func _draw_enemies() -> void:
	if enemies == null:
		return
	var draw_region := _enemy_draw_region()
	for id in range(EnemySimulation.CAPACITY):
		var ground_at := enemies.positions[id]
		if not draw_region.has_point(ground_at):
			continue
		if enemies.is_dying(id):
			_draw_enemy_death(id)
			continue
		if not enemies.is_active(id):
			continue
		var is_launched := enemies.is_enemy_launched(id)
		var at := ground_at + enemies.launch_visual_offset(id)
		var enemy_type := enemies.get_type(id)
		var facing := enemies.get_facing_direction(id)
		var color := _enemy_color(enemy_type)
		var hurt_ratio := enemies.get_hit_feedback_ratio(id)
		var hit_strength := enemies.get_hit_feedback_strength(id)
		var crowd_dim := _named_target_crowd_dim(at)
		var is_being_displaced := enemies.is_being_displaced(id)
		if enemies.is_tianji_lifted(id):
			_draw_tianji_lifted_enemy(id, at, enemy_type, facing, crowd_dim)
			continue
		color = color.lerp(Color.WHITE, hurt_ratio * 0.82)
		var size := 20.0 if enemy_type == EnemySimulation.EnemyType.ELITE else (17.0 if enemy_type == EnemySimulation.EnemyType.CAVALRY else 12.0)
		var uses_enemy_sprite := enemy_type == EnemySimulation.EnemyType.SWORD or enemy_type == EnemySimulation.EnemyType.SHIELD or enemy_type == EnemySimulation.EnemyType.ARCHER or enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.SPEAR or enemy_type == EnemySimulation.EnemyType.CROSSBOW or enemy_type == EnemySimulation.EnemyType.BANNER or enemy_type == EnemySimulation.EnemyType.CAVALRY
		var shadow_horizontal := 32.0 if enemy_type == EnemySimulation.EnemyType.CAVALRY else (22.0 if uses_enemy_sprite else size * 1.05)
		var shadow_vertical := 7.5 if enemy_type == EnemySimulation.EnemyType.CAVALRY else (6.5 if uses_enemy_sprite else size * 0.34)
		_draw_ground_shadow(ground_at + Vector2(0, size * 0.55), shadow_horizontal, shadow_vertical, Color(0.0, 0.0, 0.0, 0.28))
		if is_launched:
			_draw_death_launch_trail(at, facing, 0.86)
		if is_being_displaced:
			_draw_enemy_knockback_pose(enemy_type, at, facing, hurt_ratio, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.SWORD:
			_draw_sword_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.SHIELD:
			_draw_shield_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.ARCHER:
			_draw_archer_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.HALBERD:
			_draw_halberd_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.SPEAR:
			_draw_spear_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.CROSSBOW:
			_draw_crossbow_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1, crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.BANNER:
			_draw_banner_enemy_proxy(at, facing, hurt_ratio, hit_strength, enemies.is_banner_commanding(id), crowd_dim)
		elif enemy_type == EnemySimulation.EnemyType.CAVALRY:
			_draw_cavalry_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemies.is_cavalry_charging(id), enemy_is_moving[id] == 1, crowd_dim)
		else:
			var deform_x := 1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)
			var deform_y := 1.0 - hurt_ratio * (0.04 + hit_strength * 0.035)
			draw_set_transform(at, 0.0, Vector2(deform_x, deform_y))
			draw_rect(Rect2(-Vector2(size * 0.55, size), Vector2(size * 1.1, size * 1.5)), color)
			draw_rect(Rect2(-Vector2(size * 0.27, size * 1.45), Vector2(size * 0.54, size * 0.42)), Color("d8c9b1"))
			match enemy_type:
				EnemySimulation.EnemyType.HALBERD, EnemySimulation.EnemyType.ELITE:
					draw_line(facing * 6.0, facing * 30.0, Color("d9d5ca"), 3.0)
				EnemySimulation.EnemyType.SHIELD:
					draw_circle(facing * 10.0, size * 0.55, Color("68747f"))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_draw_enemy_hit_feedback(at, id, facing, hurt_ratio, hit_strength)
		if enemies.is_duel_shield(id):
			_draw_duel_shield_marker(at)
		var command_ratio := enemies.command_aura_ratio(id)
		if command_ratio > 0.0 and enemy_type != EnemySimulation.EnemyType.BANNER:
			_draw_banner_commanded_marker(at, command_ratio)

func _draw_tianji_lifted_enemy(id: int, at: Vector2, enemy_type: int, facing: Vector2, crowd_dim: float) -> void:
	var alpha := clampf(0.92 - crowd_dim * 0.25, 0.58, 0.92)
	var horizontal := -1.0 if facing.x < -0.05 else 1.0
	match enemy_type:
		EnemySimulation.EnemyType.SWORD:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_SWORD_SPRITE_SCALE, ENEMY_SWORD_SPRITE_SCALE))
			draw_texture(ENEMY_SWORD_DEATH_TEXTURES[0], -ENEMY_SWORD_SOURCE_FOOT_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.SHIELD:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_SHIELD_SPRITE_SCALE, ENEMY_SHIELD_SPRITE_SCALE))
			draw_texture(ENEMY_SHIELD_DEATH_TEXTURES[0], -ENEMY_SHIELD_SOURCE_FOOT_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.ARCHER:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_ARCHER_SPRITE_SCALE, ENEMY_ARCHER_SPRITE_SCALE))
			draw_texture(ENEMY_ARCHER_DEATH_TEXTURES[0], -ENEMY_ARCHER_SOURCE_FOOT_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.HALBERD:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_HALBERD_SPRITE_SCALE, ENEMY_HALBERD_SPRITE_SCALE))
			draw_texture(ENEMY_HALBERD_DEATH_TEXTURES[0], -ENEMY_HALBERD_SOURCE_FOOT_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.SPEAR:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_SPEAR_SPRITE_SCALE, ENEMY_SPEAR_SPRITE_SCALE))
			draw_texture(ENEMY_SPEAR_DEATH_TEXTURES[0], -ENEMY_SPEAR_DEATH_FOOT_ANCHORS[0], Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.CROSSBOW:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_CROSSBOW_SPRITE_SCALE, ENEMY_CROSSBOW_SPRITE_SCALE))
			draw_texture(ENEMY_CROSSBOW_DEATH_TEXTURES[0], -ENEMY_CROSSBOW_DEATH_FOOT_ANCHORS[0], Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.CAVALRY:
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal * ENEMY_CAVALRY_SPRITE_SCALE, ENEMY_CAVALRY_SPRITE_SCALE))
			draw_texture(ENEMY_CAVALRY_DEATH_TEXTURES[0], -ENEMY_CAVALRY_DEATH_FOOT_ANCHORS[0], Color(1.0, 1.0, 1.0, alpha))
		EnemySimulation.EnemyType.BANNER:
			_draw_banner_enemy_death_proxy(at, facing, 0.0, alpha)
		_:
			var size := 12.0 if enemy_type != EnemySimulation.EnemyType.ELITE else 20.0
			draw_set_transform(at, 0.0, Vector2.ONE)
			var fallback_color := _enemy_color(enemy_type)
			fallback_color.a = alpha
			draw_rect(Rect2(-size * 0.55, -size, size * 1.1, size * 1.5), fallback_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _enemy_draw_region() -> Rect2:
	if player == null:
		return bounds.grow(128.0)
	var battle_camera := player.get_node_or_null("BattleCamera") as Camera2D
	if battle_camera == null:
		return bounds.grow(128.0)
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return bounds.grow(128.0)
	var zoom := battle_camera.zoom
	var visible_world_size := Vector2(
		viewport_size.x / maxf(0.01, zoom.x),
		viewport_size.y / maxf(0.01, zoom.y)
	)
	return Rect2(battle_camera.get_screen_center_position() - visible_world_size * 0.5, visible_world_size).grow(96.0)

func _draw_duel_shield_marker(at: Vector2) -> void:
	var pulse := 0.72 + 0.28 * (sin(visual_time * 6.0 + at.x * 0.03) + 1.0) * 0.5
	var center := at + Vector2(0.0, -47.0)
	draw_arc(center, 8.0, 0.10, PI - 0.10, 8, Color(0.98, 0.66, 0.30, 0.40 * pulse), 1.2)
	draw_line(center + Vector2(-5.0, 1.0), center + Vector2(5.0, 1.0), Color(0.88, 0.25, 0.16, 0.40 * pulse), 1.4)

func _draw_enemy_knockback_pose(enemy_type: int, at: Vector2, facing: Vector2, hurt_ratio: float, crowd_dim: float) -> void:
	if enemy_type == EnemySimulation.EnemyType.SWORD:
		_draw_knockback_texture_pose(at, facing, ENEMY_SWORD_DEATH_TEXTURES[0], ENEMY_SWORD_SOURCE_FOOT_ANCHOR, ENEMY_SWORD_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.SHIELD:
		_draw_knockback_texture_pose(at, facing, ENEMY_SHIELD_DEATH_TEXTURES[0], ENEMY_SHIELD_SOURCE_FOOT_ANCHOR, ENEMY_SHIELD_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		_draw_knockback_texture_pose(at, facing, ENEMY_ARCHER_DEATH_TEXTURES[0], ENEMY_ARCHER_SOURCE_FOOT_ANCHOR, ENEMY_ARCHER_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.HALBERD:
		_draw_knockback_texture_pose(at, facing, ENEMY_HALBERD_DEATH_TEXTURES[0], ENEMY_HALBERD_SOURCE_FOOT_ANCHOR, ENEMY_HALBERD_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.SPEAR:
		_draw_knockback_texture_pose(at, facing, ENEMY_SPEAR_DEATH_TEXTURES[0], ENEMY_SPEAR_DEATH_FOOT_ANCHORS[0], ENEMY_SPEAR_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.CROSSBOW:
		_draw_knockback_texture_pose(at, facing, ENEMY_CROSSBOW_DEATH_TEXTURES[0], ENEMY_CROSSBOW_DEATH_FOOT_ANCHORS[0], ENEMY_CROSSBOW_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	if enemy_type == EnemySimulation.EnemyType.CAVALRY:
		_draw_knockback_texture_pose(at, facing, ENEMY_CAVALRY_DEATH_TEXTURES[0], ENEMY_CAVALRY_DEATH_FOOT_ANCHORS[0], ENEMY_CAVALRY_SPRITE_SCALE, hurt_ratio, crowd_dim)
		return
	var tilt := 0.10 * (-1.0 if facing.x < 0.0 else 1.0)
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		_draw_banner_enemy_death_proxy(at, facing, tilt, 1.0)
	else:
		var body_color := _enemy_color(enemy_type).lerp(Color.WHITE, hurt_ratio * 0.72)
		draw_set_transform(at, tilt, Vector2.ONE)
		draw_rect(Rect2(-11.0, -18.0, 22.0, 30.0), body_color)
		draw_rect(Rect2(-6.0, -24.0, 12.0, 8.0), Color("d8c9b1"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_knockback_texture_pose(at: Vector2, facing: Vector2, texture: Texture2D, source_anchor: Vector2, sprite_scale: float, hurt_ratio: float, crowd_dim: float) -> void:
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var tint := Color(0.80, 0.84, 0.86).lerp(Color.WHITE, hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale, sprite_scale))
	draw_texture(texture, -source_anchor, tint)
	_draw_crowd_muting_overlay(texture, source_anchor, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_enemy_death(id: int) -> void:
	var ground_at := enemies.positions[id]
	var at := ground_at + enemies.launch_visual_offset(id)
	var enemy_type := enemies.get_type(id)
	var progress := enemies.death_animation_progress(id)
	var fade_progress := enemies.death_fade_progress(id)
	var alpha := clampf(1.0 - fade_progress, 0.0, 1.0)
	var facing := enemies.get_facing_direction(id)
	var tilt := lerpf(0.10, 0.62, progress) * (-1.0 if facing.x < 0.0 else 1.0)
	var shadow_scale := 1.0 + progress * 0.28
	_draw_ground_shadow(ground_at + Vector2(0, 15), 18.0 * shadow_scale, 5.8 * shadow_scale, Color(0.0, 0.0, 0.0, 0.24 * alpha))
	if enemies.is_death_launched(id) or enemies.is_enemy_launched(id):
		_draw_death_launch_trail(at, facing, alpha)
	if enemy_type == EnemySimulation.EnemyType.SWORD:
		var death_frame := mini(int(progress * ENEMY_SWORD_DEATH_TEXTURES.size()), ENEMY_SWORD_DEATH_TEXTURES.size() - 1)
		var sprite_scale := ENEMY_SWORD_SPRITE_SCALE
		var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale, sprite_scale))
		draw_texture(ENEMY_SWORD_DEATH_TEXTURES[death_frame], -ENEMY_SWORD_SOURCE_FOOT_ANCHOR, Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.SHIELD:
		var death_frame := mini(int(progress * ENEMY_SHIELD_DEATH_TEXTURES.size()), ENEMY_SHIELD_DEATH_TEXTURES.size() - 1)
		var sprite_scale := ENEMY_SHIELD_SPRITE_SCALE
		var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale, sprite_scale))
		draw_texture(ENEMY_SHIELD_DEATH_TEXTURES[death_frame], -ENEMY_SHIELD_SOURCE_FOOT_ANCHOR, Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		var death_frame := mini(int(progress * ENEMY_ARCHER_DEATH_TEXTURES.size()), ENEMY_ARCHER_DEATH_TEXTURES.size() - 1)
		var sprite_scale := ENEMY_ARCHER_SPRITE_SCALE
		var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale, sprite_scale))
		draw_texture(ENEMY_ARCHER_DEATH_TEXTURES[death_frame], -ENEMY_ARCHER_SOURCE_FOOT_ANCHOR, Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.HALBERD:
		var death_frame := mini(int(progress * ENEMY_HALBERD_DEATH_TEXTURES.size()), ENEMY_HALBERD_DEATH_TEXTURES.size() - 1)
		var sprite_scale := ENEMY_HALBERD_SPRITE_SCALE
		var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale, sprite_scale))
		draw_texture(ENEMY_HALBERD_DEATH_TEXTURES[death_frame], -ENEMY_HALBERD_SOURCE_FOOT_ANCHOR, Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.SPEAR:
		var spear_death_frame := mini(int(progress * ENEMY_SPEAR_DEATH_TEXTURES.size()), ENEMY_SPEAR_DEATH_TEXTURES.size() - 1)
		var spear_horizontal_scale := -ENEMY_SPEAR_SPRITE_SCALE if facing.x < -0.05 else ENEMY_SPEAR_SPRITE_SCALE
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(spear_horizontal_scale, ENEMY_SPEAR_SPRITE_SCALE))
		draw_texture(ENEMY_SPEAR_DEATH_TEXTURES[spear_death_frame], -ENEMY_SPEAR_DEATH_FOOT_ANCHORS[spear_death_frame], Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.CROSSBOW:
		var crossbow_death_frame := mini(int(progress * ENEMY_CROSSBOW_DEATH_TEXTURES.size()), ENEMY_CROSSBOW_DEATH_TEXTURES.size() - 1)
		var crossbow_horizontal_scale := -ENEMY_CROSSBOW_SPRITE_SCALE if facing.x < -0.05 else ENEMY_CROSSBOW_SPRITE_SCALE
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(crossbow_horizontal_scale, ENEMY_CROSSBOW_SPRITE_SCALE))
		draw_texture(ENEMY_CROSSBOW_DEATH_TEXTURES[crossbow_death_frame], -ENEMY_CROSSBOW_DEATH_FOOT_ANCHORS[crossbow_death_frame], Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.CAVALRY:
		var cavalry_death_frame := mini(int(progress * ENEMY_CAVALRY_DEATH_TEXTURES.size()), ENEMY_CAVALRY_DEATH_TEXTURES.size() - 1)
		var cavalry_horizontal_scale := -ENEMY_CAVALRY_SPRITE_SCALE if facing.x < -0.05 else ENEMY_CAVALRY_SPRITE_SCALE
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(cavalry_horizontal_scale, ENEMY_CAVALRY_SPRITE_SCALE))
		draw_texture(ENEMY_CAVALRY_DEATH_TEXTURES[cavalry_death_frame], -ENEMY_CAVALRY_DEATH_FOOT_ANCHORS[cavalry_death_frame], Color(0.76, 0.80, 0.82, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		_draw_banner_enemy_death_proxy(at, facing, tilt, alpha)
		return
	var size := 12.0 if enemy_type != EnemySimulation.EnemyType.ELITE else 20.0
	var color := _enemy_color(enemy_type)
	color.a = alpha
	draw_set_transform(at, tilt, Vector2.ONE)
	draw_rect(Rect2(-size * 0.55, -size, size * 1.1, size * 1.5), color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_death_launch_trail(at: Vector2, direction: Vector2, alpha: float) -> void:
	var forward := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	var perpendicular := Vector2(-forward.y, forward.x)
	for index in range(2):
		var distance := 20.0 + float(index) * 16.0
		var center := at - forward * distance + perpendicular * (-1.0 if index == 0 else 1.0) * (6.0 + float(index) * 3.0)
		var shard := PackedVector2Array([
			center - forward * 8.0 - perpendicular * 3.0,
			center - perpendicular * 5.0,
			center + forward * 15.0,
			center + perpendicular * 3.0,
		])
		draw_colored_polygon(shard, Color(0.82, 0.92, 0.94, alpha * (0.24 - float(index) * 0.06)))

func _draw_archer_projectiles() -> void:
	for projectile in archer_projectiles:
		var total_duration := float(projectile.get("total_duration", 0.0))
		var elapsed := total_duration - float(projectile.get("remaining", 0.0))
		var launch_delay := float(projectile.get("launch_delay", 0.0))
		if elapsed < launch_delay:
			continue
		var flight_duration := maxf(0.01, float(projectile.get("flight_duration", 0.0)))
		var progress := clampf((elapsed - launch_delay) / flight_duration, 0.0, 1.0)
		var origin: Vector2 = projectile.get("origin", Vector2.ZERO)
		var target: Vector2 = projectile.get("target", origin)
		var position := archer_projectile_position(origin, target, progress)
		var direction := archer_projectile_tangent(origin, target, progress).normalized()
		draw_set_transform(position, direction.angle(), Vector2(ARCHER_PROJECTILE_SCALE, ARCHER_PROJECTILE_SCALE))
		draw_texture(ARCHER_PROJECTILE_TEXTURE, -ARCHER_PROJECTILE_SOURCE_ANCHOR)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_archer_impact_marks() -> void:
	for mark in archer_impact_marks:
		var alpha := clampf(float(mark.get("remaining", 0.0)) / 0.18, 0.0, 1.0)
		var position: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		draw_set_transform(position, direction.angle(), Vector2(ARCHER_PROJECTILE_SCALE, ARCHER_PROJECTILE_SCALE))
		draw_texture(ARCHER_PROJECTILE_TEXTURE, -ARCHER_PROJECTILE_SOURCE_ANCHOR, Color(1.0, 0.92, 0.68, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_crossbow_bolts() -> void:
	for bolt in crossbow_bolts:
		var total_duration := float(bolt.get("total_duration", 0.0))
		var elapsed := total_duration - float(bolt.get("remaining", 0.0))
		var launch_delay := float(bolt.get("launch_delay", 0.0))
		if elapsed < launch_delay:
			continue
		var flight_duration := maxf(0.01, float(bolt.get("flight_duration", 0.0)))
		var progress := clampf((elapsed - launch_delay) / flight_duration, 0.0, 1.0)
		var origin: Vector2 = bolt.get("origin", Vector2.ZERO)
		var target: Vector2 = bolt.get("target", origin)
		var position := origin.lerp(target, progress)
		var direction := (target - origin).normalized()
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		draw_set_transform(position, direction.angle(), Vector2(ARCHER_PROJECTILE_SCALE, ARCHER_PROJECTILE_SCALE))
		draw_texture(ARCHER_PROJECTILE_TEXTURE, -ARCHER_PROJECTILE_SOURCE_ANCHOR)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_crossbow_impact_marks() -> void:
	for mark in crossbow_impact_marks:
		var alpha := clampf(float(mark.get("remaining", 0.0)) / 0.14, 0.0, 1.0)
		var at: Vector2 = mark.get("position", Vector2.ZERO)
		for index in range(3):
			var direction := Vector2.from_angle(float(index) * TAU / 3.0 + 0.18)
			draw_line(at + direction * 3.0, at + direction * 14.0, Color(1.0, 0.80, 0.38, alpha), 1.5)

func _draw_banner_command_marks() -> void:
	for mark in banner_command_marks:
		var duration := maxf(0.01, float(mark.get("duration", 0.54)))
		var alpha := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var at: Vector2 = mark.get("position", Vector2.ZERO)
		var radius := lerpf(24.0, 138.0, 1.0 - alpha)
		_draw_ellipse_arc(at + Vector2(0.0, 13.0), Vector2(radius, radius * 0.30), 0.0, TAU, 18, Color(0.96, 0.76, 0.30, alpha * 0.76), 2.0)

func _draw_enemy_hit_feedback(at: Vector2, enemy_id: int, facing: Vector2, hurt_ratio: float, hit_strength: float) -> void:
	if hurt_ratio <= 0.0:
		return
	var direction := enemies.get_knockback_direction(enemy_id)
	if direction.length_squared() <= 0.01:
		direction = facing.normalized() if facing.length_squared() > 0.01 else Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	var travel := (1.0 - hurt_ratio) * (20.0 + hit_strength * 16.0)
	var shard_count := 3 + int(maxf(0.0, hit_strength - 1.0) * 3.0)
	for index in range(shard_count):
		var side := -1.0 if (enemy_id + index) % 2 == 0 else 1.0
		var center := at + direction * (8.0 + travel + float(index) * 4.0) + perpendicular * side * (5.0 + float(index) * 3.0)
		var shard := PackedVector2Array([
			center - direction * 4.0 - perpendicular * 1.8,
			center - perpendicular * 3.2,
			center + direction * (8.0 + float(index) * 2.0),
			center + perpendicular * 2.0,
		])
		draw_colored_polygon(shard, Color(0.70, 0.92, 1.0, hurt_ratio * maxf(0.18, 0.58 - float(index) * 0.065)))

func _draw_ultimate_waves() -> void:
	for mark in ultimate_wave_marks:
		var alpha := clampf(float(mark.get("remaining", 0.0)) / 0.48, 0.0, 1.0)
		var origin: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		var distance := float(mark.get("distance", 0.0))
		var segment := int(mark.get("segment", 0))
		var perpendicular := Vector2(-direction.y, direction.x)
		for index in range(3):
			var ratio := 0.22 + float(index) * 0.22
			var center := origin + direction * distance * ratio + perpendicular * float((index + segment) % 2 * 2 - 1) * (8.0 + float(index) * 5.0)
			var length := 34.0 + float(index) * 12.0
			var width := 8.0 + float(index) * 2.5
			var wave := PackedVector2Array([
				center - direction * (length * 0.55) - perpendicular * (width * 0.45),
				center - direction * (length * 0.16) - perpendicular * width,
				center + direction * (length * 0.52) - perpendicular * (width * 0.26),
				center + direction * length,
				center + direction * (length * 0.42) + perpendicular * (width * 0.34),
				center - direction * (length * 0.12) + perpendicular * (width * 0.72),
			])
			draw_colored_polygon(wave, Color(0.40, 0.86, 1.0, alpha * (0.24 - float(index) * 0.04)))
		var ring_center := origin + direction * (18.0 + float(segment % 2) * 9.0) + SPEAR_VFX_HEIGHT_OFFSET
		_draw_ultimate_shock_ring(ring_center, direction, alpha)

func _draw_zhao_yun_ultimate_effects() -> void:
	if player == null or player.presentation_id() != "zhao_yun":
		return
	for mark in zhao_yun_ultimate_effect_marks:
		var elapsed := float(mark.get("elapsed", 0.0))
		var frame_index := mini(int(elapsed / ZHAO_YUN_ULTIMATE_EFFECT_FRAME_DURATION), ZHAO_YUN_ULTIMATE_EFFECT_TEXTURES.size() - 1)
		var texture: Texture2D = ZHAO_YUN_ULTIMATE_EFFECT_TEXTURES[frame_index]
		var duration := maxf(0.01, float(mark.get("duration", 0.01)))
		var remaining := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var fade_out := clampf(remaining * 5.0, 0.0, 1.0)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		var anchor: Vector2 = mark.get("position", Vector2.ZERO) + ZHAO_YUN_ULTIMATE_EFFECT_GUN_TIP_OFFSET + direction * 44.0
		draw_set_transform(anchor, direction.angle(), Vector2(ZHAO_YUN_ULTIMATE_EFFECT_SCALE, ZHAO_YUN_ULTIMATE_EFFECT_SCALE))
		draw_texture(texture, -ZHAO_YUN_ULTIMATE_EFFECT_SOURCE_ANCHOR, Color(1.0, 1.0, 1.0, 0.46 * fade_out))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_death_collisions() -> void:
	for mark in death_collision_marks:
		var alpha := clampf(float(mark.get("remaining", 0.0)) / 0.22, 0.0, 1.0)
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		var perpendicular := Vector2(-direction.y, direction.x)
		for index in range(4):
			var side := -1.0 if index % 2 == 0 else 1.0
			var shard_center := center + direction * (10.0 + float(index) * 4.0) + perpendicular * side * (4.0 + float(index) * 3.0)
			var shard := PackedVector2Array([
				shard_center - direction * 5.0 - perpendicular * 2.0,
				shard_center + perpendicular * side * 3.0,
				shard_center + direction * (10.0 + float(index) * 2.0),
			])
			draw_colored_polygon(shard, Color(0.94, 0.78, 0.38, alpha * (0.52 - float(index) * 0.07)))
		draw_arc(center, 12.0 + (1.0 - alpha) * 16.0, direction.angle() - 0.8, direction.angle() + 0.8, 8, Color(0.96, 0.82, 0.48, alpha * 0.66), 2.0)

func _draw_player() -> void:
	if player == null:
		return
	var at := player.position
	if player_death_cinematic_active:
		_draw_player_death(at)
		return
	if player.presentation_id() == "guan_yu":
		_draw_guan_yu(at)
		return
	if player.presentation_id() in ["zhang_fei", "ma_chao", "huang_zhong"]:
		_draw_prototype_hero(at)
		return
	if player.presentation_id() != "zhao_yun":
		_draw_generic_hero_placeholder(at)
		return
	_draw_ground_shadow(at + Vector2(0, 14), 27.0, 7.5, Color(0.0, 0.0, 0.0, 0.34))
	_draw_player_status_aura(at)
	_draw_player_guard_shield(at)
	_draw_player_sprite(at)
	if player.is_ultimate_ready():
		_draw_ultimate_ready_burst(at)
	if player.is_firewheel_active():
		_draw_firewheel_flames(at)
	_draw_player_hit_marker(at)
	_draw_attack_03_spear_flare(at)
	if player.ultimate_time > 0.0:
		if player.is_ultimate_dashing():
			_draw_ultimate_dash_wind(at)
		else:
			draw_arc(at, 30.0, 0.0, TAU, 24, Color(0.78, 0.94, 1.0, 0.58), 2.0)

func _draw_generic_hero_placeholder(at: Vector2) -> void:
	_draw_ground_shadow(at + Vector2(0, 14), 24.0, 7.0, Color(0.0, 0.0, 0.0, 0.34))
	_draw_player_guard_shield(at)
	draw_circle(at + Vector2(0, -10), 14.0, Color("d6c3a1"))
	draw_rect(Rect2(at + Vector2(-15, 3), Vector2(30, 28)), Color("596e7f"))
	draw_arc(at + Vector2(0, 8), 24.0, 0.0, TAU, 16, Color("d9b66e"), 1.5)

func _draw_prototype_hero(at: Vector2) -> void:
	var body_at := at
	var shadow_horizontal := 28.0
	var shadow_vertical := 8.0
	var shadow_alpha := 0.36
	if player.presentation_id() == "zhang_fei":
		var jump_height := float(player.call("zhang_fei_jump_visual_height")) if player.has_method("zhang_fei_jump_visual_height") else 0.0
		var lift_ratio := clampf(jump_height / 82.0, 0.0, 1.0)
		body_at -= Vector2(0.0, jump_height)
		shadow_horizontal = lerpf(28.0, 18.0, lift_ratio)
		shadow_vertical = lerpf(8.0, 4.5, lift_ratio)
		shadow_alpha = lerpf(0.36, 0.20, lift_ratio)
	_draw_ground_shadow(at + Vector2(0, 15), shadow_horizontal, shadow_vertical, Color(0.0, 0.0, 0.0, shadow_alpha))
	_draw_player_guard_shield(body_at)
	match player.presentation_id():
		"zhang_fei":
			_draw_zhang_fei_body(body_at, 1.0)
			if player.is_zhang_fei_ultimate_active():
				_draw_zhang_fei_ultimate_aura(body_at)
			if player.has_breakout_guard():
				_draw_zhang_fei_guard(body_at)
		"ma_chao":
			_draw_ma_chao_afterimages(at)
			_draw_ma_chao_body(at, 1.0)
		"huang_zhong":
			_draw_huang_zhong_body(at)
	if player.is_ultimate_ready():
		_draw_ultimate_ready_burst(at)
	_draw_player_hit_marker(body_at)

func _prototype_facing_direction() -> Vector2:
	var direction := player.last_attack_direction.normalized()
	return direction if direction.length_squared() > 0.01 else Vector2.RIGHT

func _draw_zhang_fei_body(at: Vector2, alpha: float) -> void:
	var texture: Texture2D = _current_zhang_fei_texture()
	var source_anchor := _current_zhang_fei_source_foot_anchor()
	var horizontal_scale := -ZHANG_FEI_SPRITE_SCALE if player_faces_left else ZHANG_FEI_SPRITE_SCALE
	draw_set_transform(at + ZHANG_FEI_WORLD_FOOT_OFFSET, 0.0, Vector2(horizontal_scale, ZHANG_FEI_SPRITE_SCALE))
	draw_texture(texture, -source_anchor, Color(1.0, 1.0, 1.0, alpha))
	if player_hit_flash_remaining > 0.0 and alpha > 0.99:
		var flash_texture := _player_white_flash_texture(texture)
		var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength
		draw_texture(flash_texture, -source_anchor, Color(1.0, 1.0, 1.0, flash_ratio))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _current_zhang_fei_texture() -> Texture2D:
	if player.is_guard_active():
		var guard_index := mini(int(player_guard_time / ZHANG_FEI_GUARD_FRAME_DURATION), ZHANG_FEI_GUARD_FRAMES.size() - 1)
		var guard_frame: int = ZHANG_FEI_GUARD_FRAMES[guard_index]
		return ZHANG_FEI_ATTACK_03_TEXTURES[guard_frame]
	if player.current_action == "basic":
		match player.combo_stage:
			1:
				return ZHANG_FEI_ATTACK_01_TEXTURES[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_01_TEXTURES.size())]
			2:
				return ZHANG_FEI_ATTACK_02_TEXTURES[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_02_TEXTURES.size())]
			_:
				return ZHANG_FEI_ATTACK_03_TEXTURES[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_03_TEXTURES.size())]
	if player.current_action in ["active", "ultimate"]:
		return ZHANG_FEI_ATTACK_03_TEXTURES[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_03_TEXTURES.size())]
	if player_is_moving:
		return ZHANG_FEI_WALK_TEXTURES[_zhang_fei_walk_frame_index()]
	var idle_frame := int(player_idle_time / ZHANG_FEI_IDLE_FRAME_DURATION) % ZHANG_FEI_IDLE_TEXTURES.size()
	return ZHANG_FEI_IDLE_TEXTURES[idle_frame]

func _current_zhang_fei_source_foot_anchor() -> Vector2:
	if player.is_guard_active():
		var guard_index := mini(int(player_guard_time / ZHANG_FEI_GUARD_FRAME_DURATION), ZHANG_FEI_GUARD_FRAMES.size() - 1)
		var guard_frame: int = ZHANG_FEI_GUARD_FRAMES[guard_index]
		return ZHANG_FEI_ATTACK_03_FOOT_ANCHORS[guard_frame]
	if player.current_action == "basic":
		match player.combo_stage:
			1:
				return ZHANG_FEI_ATTACK_01_FOOT_ANCHORS[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_01_TEXTURES.size())]
			2:
				return ZHANG_FEI_ATTACK_02_FOOT_ANCHORS[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_02_TEXTURES.size())]
			_:
				return ZHANG_FEI_ATTACK_03_FOOT_ANCHORS[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_03_TEXTURES.size())]
	if player.current_action in ["active", "ultimate"]:
		return ZHANG_FEI_ATTACK_03_FOOT_ANCHORS[_zhang_fei_action_frame_index(ZHANG_FEI_ATTACK_03_TEXTURES.size())]
	if player_is_moving:
		return ZHANG_FEI_WALK_FOOT_ANCHORS[_zhang_fei_walk_frame_index()]
	var idle_frame := int(player_idle_time / ZHANG_FEI_IDLE_FRAME_DURATION) % ZHANG_FEI_IDLE_FOOT_ANCHORS.size()
	return ZHANG_FEI_IDLE_FOOT_ANCHORS[idle_frame]

func _zhang_fei_action_frame_index(frame_count: int) -> int:
	if player.current_action == "ultimate":
		return mini(int(zhang_fei_ultimate_animation_time / ZHANG_FEI_ULTIMATE_FRAME_DURATION), frame_count - 1)
	var action_progress := float(player.call("visual_action_progress")) if player.has_method("visual_action_progress") else 0.0
	return mini(int(action_progress * float(frame_count)), frame_count - 1)

func _zhang_fei_walk_frame_index() -> int:
	if player_walk_time < ZHANG_FEI_WALK_ENTRY_DURATION:
		return 0
	var loop_elapsed := player_walk_time - ZHANG_FEI_WALK_ENTRY_DURATION
	return 1 + int(loop_elapsed / ZHANG_FEI_WALK_LOOP_FRAME_DURATION) % (ZHANG_FEI_WALK_TEXTURES.size() - 1)

func _draw_zhang_fei_guard(at: Vector2) -> void:
	var pulse := 0.66 + 0.24 * (sin(visual_time * 11.0) + 1.0) * 0.5
	_draw_ellipse_arc(at + Vector2(0, 9), Vector2(43.0, 15.0), -0.32, PI + 0.32, 14, Color(0.96, 0.54, 0.22, pulse), 2.8)
	for index in range(3):
		var root := at + Vector2(-20.0 + float(index) * 20.0, -7.0)
		draw_line(root, root + Vector2(0, -18), Color(1.0, 0.78, 0.36, pulse * 0.68), 2.0)

func _draw_zhang_fei_ultimate_aura(at: Vector2) -> void:
	var pulse := 0.64 + 0.22 * (sin(visual_time * 7.0) + 1.0) * 0.5
	var center := at + Vector2(0, 9)
	_draw_ellipse_arc(center, Vector2(43.0, 15.0), visual_time * 1.4, visual_time * 1.4 + 2.24, 16, Color(0.94, 0.34, 0.16, pulse * 0.80), 2.6)
	_draw_ellipse_arc(center, Vector2(35.0, 11.0), -visual_time * 1.8 + PI, -visual_time * 1.8 + PI + 2.04, 14, Color(1.0, 0.74, 0.26, pulse * 0.72), 2.0)
	for index in range(3):
		var angle := visual_time * 1.8 + TAU * float(index) / 3.0
		var root := center + Vector2.from_angle(angle) * 32.0
		draw_line(root, root + Vector2(0, -12), Color(1.0, 0.69, 0.30, pulse * 0.64), 1.8)

func _draw_ma_chao_afterimages(at: Vector2) -> void:
	var momentum := player.momentum_ratio()
	if momentum < 0.16 and not player.is_path_dashing() and not player.is_ultimate_dashing():
		return
	var direction := _prototype_facing_direction()
	var count := 4 if player.is_ultimate_dashing() else 3
	for index in range(count, 0, -1):
		var progress := float(index) / float(count)
		var offset := direction * -(18.0 + progress * (42.0 + momentum * 42.0)) + Vector2(0, sin(visual_time * 15.0 + float(index)) * 1.5)
		_draw_ma_chao_body(at + offset, 0.08 + (1.0 - progress) * 0.11)
	var dust_center := at - direction * 17.0 + Vector2(0, 16)
	for index in range(4):
		var dust := dust_center - direction * float(index) * 12.0 + Vector2(0, float(index % 2) * 3.0)
		draw_circle(dust, 4.0 + float(index), Color(0.72, 0.74, 0.70, 0.10 + momentum * 0.12))

func _draw_ma_chao_body(at: Vector2, alpha: float) -> void:
	var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength if player_hit_flash_remaining > 0.0 and alpha > 0.99 else 0.0
	var facing := _prototype_facing_direction()
	var side := Vector2(-facing.y, facing.x)
	var armor := Color("d7dde2").lerp(Color.WHITE, flash_ratio)
	var cloak := Color("6d7c9b").lerp(Color.WHITE, flash_ratio)
	var skin := Color("d1aa83").lerp(Color.WHITE, flash_ratio)
	var body := PackedVector2Array([
		at - side * 16.0 + Vector2(0, 13), at - side * 14.0 + Vector2(0, -15),
		at + side * 14.0 + Vector2(0, -15), at + side * 17.0 + Vector2(0, 13),
	])
	draw_colored_polygon(body, Color(armor.r, armor.g, armor.b, alpha))
	draw_colored_polygon(PackedVector2Array([at - side * 15.0 + Vector2(0, -4), at - side * 29.0 + Vector2(0, 15), at + Vector2(0, 17), at + side * 13.0 + Vector2(0, -4)]), Color(cloak.r, cloak.g, cloak.b, alpha * 0.88))
	draw_circle(at + Vector2(0, -28), 9.5, Color(skin.r, skin.g, skin.b, alpha))
	draw_rect(Rect2(at + Vector2(-11, -38), Vector2(22, 6)), Color(0.22, 0.25, 0.31, alpha))
	draw_line(at + Vector2(-12, 13), at + Vector2(-6, 21), Color(0.18, 0.22, 0.28, alpha), 5.2)
	draw_line(at + Vector2(12, 13), at + Vector2(6, 21), Color(0.18, 0.22, 0.28, alpha), 5.2)
	var action_progress := float(player.call("visual_action_progress")) if player.has_method("visual_action_progress") else 0.0
	var spear_direction := facing.rotated(lerpf(0.48, -0.40, action_progress))
	var hand := at + Vector2(0, -8)
	draw_line(hand - spear_direction * 42.0, hand + spear_direction * 86.0, Color(0.55, 0.34, 0.19, alpha), 3.6)
	var tip := hand + spear_direction * 92.0
	var head := PackedVector2Array([tip, tip - spear_direction * 16.0 + Vector2(-spear_direction.y, spear_direction.x) * 5.0, tip - spear_direction * 16.0 - Vector2(-spear_direction.y, spear_direction.x) * 5.0])
	draw_colored_polygon(head, Color(0.86, 0.94, 0.98, alpha))

func _draw_huang_zhong_body(at: Vector2) -> void:
	var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength if player_hit_flash_remaining > 0.0 else 0.0
	var facing := _prototype_facing_direction()
	var robe := Color("8c6135").lerp(Color.WHITE, flash_ratio)
	var cloak := Color("2f5a4d").lerp(Color.WHITE, flash_ratio)
	var skin := Color("cda67f").lerp(Color.WHITE, flash_ratio)
	var body := PackedVector2Array([
		at + Vector2(-16, 13), at + Vector2(-14, -15), at + Vector2(14, -15), at + Vector2(18, 13),
	])
	draw_colored_polygon(body, robe)
	draw_colored_polygon(PackedVector2Array([at + Vector2(-14, -9), at + Vector2(-24, 14), at + Vector2(0, 17), at + Vector2(14, -8)]), cloak)
	draw_circle(at + Vector2(0, -28), 9.5, skin)
	draw_rect(Rect2(at + Vector2(-12, -37), Vector2(24, 6)), Color("c4c7bd").lerp(Color.WHITE, flash_ratio))
	draw_line(at + Vector2(-11, 13), at + Vector2(-5, 21), Color("30312e").lerp(Color.WHITE, flash_ratio), 5.0)
	draw_line(at + Vector2(11, 13), at + Vector2(5, 21), Color("30312e").lerp(Color.WHITE, flash_ratio), 5.0)
	var hand := at + Vector2(0, -7)
	if player.is_bow_stance():
		var bow_direction := facing
		var bow_center := hand + bow_direction * 12.0
		var bow_side := Vector2(-bow_direction.y, bow_direction.x)
		draw_arc(bow_center, 22.0, bow_direction.angle() - 1.18, bow_direction.angle() + 1.18, 12, Color("c8964f"), 2.4)
		draw_line(bow_center - bow_direction * 20.0, bow_center + bow_direction * 20.0, Color("e8dfc5"), 1.0)
		var arrow_tip := hand + bow_direction * 64.0
		draw_line(hand - bow_direction * 12.0, arrow_tip, Color("ddd9ca"), 1.4)
		draw_colored_polygon(PackedVector2Array([arrow_tip, arrow_tip - bow_direction * 9.0 + bow_side * 3.5, arrow_tip - bow_direction * 9.0 - bow_side * 3.5]), Color("e8edf0"))
	else:
		var blade_direction := facing.rotated(0.20)
		draw_line(hand - blade_direction * 16.0, hand + blade_direction * 42.0, Color("6d4c2d"), 3.2)
		var blade_tip := hand + blade_direction * 58.0
		draw_arc(blade_tip - blade_direction * 11.0, 15.0, blade_direction.angle() - 2.4, blade_direction.angle() + 0.3, 10, Color("d9e5df"), 5.4)

func _draw_guan_yu(at: Vector2) -> void:
	_draw_ground_shadow(at + Vector2(0, 15), 29.0, 8.0, Color(0.0, 0.0, 0.0, 0.38))
	if player.is_wusheng_active():
		_draw_guan_wusheng_aura(at)
	_draw_player_guard_shield(at)
	_draw_guan_yu_body(at)
	if player.is_ultimate_ready():
		_draw_ultimate_ready_burst(at)
	if player.is_drag_charging():
		_draw_guan_drag_charge(at)
	_draw_player_hit_marker(at)

func _draw_guan_drag_charge(at: Vector2) -> void:
	var ratio := player.drag_charge_ratio()
	var bar := Rect2(at + Vector2(-29.0, -60.0), Vector2(58.0, 6.0))
	draw_rect(bar, Color("091013", 0.92))
	draw_rect(Rect2(bar.position + Vector2.ONE, Vector2((bar.size.x - 2.0) * ratio, bar.size.y - 2.0)), Color("e4b64b").lerp(Color("fff0a6"), ratio))
	draw_rect(bar, Color("f6d778"), false, 1.0)
	var pulse := 0.38 + ratio * 0.52
	_draw_ellipse_arc(at + Vector2(0, 12), Vector2(32.0 + ratio * 11.0, 10.0 + ratio * 3.0), -visual_time * 1.8, -visual_time * 1.8 + PI * 1.58, 12, Color(0.94, 0.70, 0.24, pulse), 1.8)

func _draw_guan_wusheng_aura(at: Vector2) -> void:
	var pulse := 0.68 + 0.18 * (sin(visual_time * 6.0) + 1.0) * 0.5
	var center := at + Vector2(0, 9)
	_draw_ellipse_arc(center, Vector2(39.0, 13.0), -visual_time * 0.9, -visual_time * 0.9 + 2.35, 14, Color(0.31, 0.94, 0.62, pulse * 0.80), 2.4)
	_draw_ellipse_arc(center, Vector2(39.0, 13.0), -visual_time * 0.9 + PI, -visual_time * 0.9 + PI + 2.35, 14, Color(0.96, 0.73, 0.28, pulse * 0.82), 2.4)
	for index in range(4):
		var angle := visual_time * 1.4 + TAU * float(index) / 4.0
		var radial := Vector2.from_angle(angle)
		var side := Vector2.from_angle(angle + PI * 0.5) * 3.6
		var tip := center + radial * 37.0
		draw_colored_polygon(PackedVector2Array([tip, tip - radial * 10.0 + side, tip - radial * 10.0 - side]), Color(0.96, 0.78, 0.34, pulse * 0.78))

func _draw_guan_yu_body(at: Vector2) -> void:
	var texture: Texture2D = _current_guan_yu_texture()
	var source_anchor: Vector2 = _current_guan_yu_source_foot_anchor()
	var horizontal_scale := -GUAN_YU_SPRITE_SCALE if player_faces_left else GUAN_YU_SPRITE_SCALE
	draw_set_transform(at + GUAN_YU_WORLD_FOOT_OFFSET, 0.0, Vector2(horizontal_scale, GUAN_YU_SPRITE_SCALE))
	draw_texture(texture, -source_anchor)
	if player_hit_flash_remaining > 0.0:
		var flash_texture := _player_white_flash_texture(texture)
		var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength
		draw_texture(flash_texture, -source_anchor, Color(1.0, 1.0, 1.0, flash_ratio))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _current_guan_yu_texture() -> Texture2D:
	if player.is_guard_active():
		var guard_frame := mini(int(player_guard_time / GUAN_YU_GUARD_FRAME_DURATION), GUAN_YU_ATTACK_02_TEXTURES.size() - 1)
		return GUAN_YU_ATTACK_02_TEXTURES[guard_frame]
	if player.current_action == "basic":
		match player.combo_stage:
			1:
				return GUAN_YU_ATTACK_01_TEXTURES[_guan_yu_action_frame_index(GUAN_YU_ATTACK_01_TEXTURES.size())]
			2:
				return GUAN_YU_ATTACK_02_TEXTURES[_guan_yu_action_frame_index(GUAN_YU_ATTACK_02_TEXTURES.size())]
			_:
				return GUAN_YU_ATTACK_03_TEXTURES[_guan_yu_action_frame_index(GUAN_YU_ATTACK_03_TEXTURES.size())]
	if player.current_action == "active" or _guan_yu_is_ultimate_casting():
		return GUAN_YU_ATTACK_03_TEXTURES[_guan_yu_action_frame_index(GUAN_YU_ATTACK_03_TEXTURES.size())]
	if player.current_action == "drag_release":
		return GUAN_YU_ATTACK_01_TEXTURES[_guan_yu_action_frame_index(GUAN_YU_ATTACK_01_TEXTURES.size())]
	if player.is_drag_charging() and _guan_yu_drag_charge_ready():
		return GUAN_YU_DRAG_TEXTURES[_guan_yu_drag_frame_index()] if player_is_moving else GUAN_YU_DRAG_TEXTURES[1]
	if player_is_moving:
		if player.is_wusheng_active():
			return GUAN_YU_DRAG_TEXTURES[_guan_yu_drag_frame_index()]
		return GUAN_YU_WALK_TEXTURES[_guan_yu_walk_frame_index()]
	var idle_frame := int(player_idle_time / GUAN_YU_IDLE_FRAME_DURATION) % GUAN_YU_IDLE_TEXTURES.size()
	return GUAN_YU_IDLE_TEXTURES[idle_frame]

func _current_guan_yu_source_foot_anchor() -> Vector2:
	if player.is_guard_active():
		var guard_frame := mini(int(player_guard_time / GUAN_YU_GUARD_FRAME_DURATION), GUAN_YU_ATTACK_02_FOOT_ANCHORS.size() - 1)
		return GUAN_YU_ATTACK_02_FOOT_ANCHORS[guard_frame]
	if player.current_action == "basic":
		match player.combo_stage:
			1:
				return GUAN_YU_ATTACK_01_FOOT_ANCHORS[_guan_yu_action_frame_index(GUAN_YU_ATTACK_01_TEXTURES.size())]
			2:
				return GUAN_YU_ATTACK_02_FOOT_ANCHORS[_guan_yu_action_frame_index(GUAN_YU_ATTACK_02_TEXTURES.size())]
			_:
				return GUAN_YU_ATTACK_03_FOOT_ANCHORS[_guan_yu_action_frame_index(GUAN_YU_ATTACK_03_TEXTURES.size())]
	if player.current_action == "active" or _guan_yu_is_ultimate_casting():
		return GUAN_YU_ATTACK_03_FOOT_ANCHORS[_guan_yu_action_frame_index(GUAN_YU_ATTACK_03_TEXTURES.size())]
	if player.current_action == "drag_release":
		return GUAN_YU_ATTACK_01_FOOT_ANCHORS[_guan_yu_action_frame_index(GUAN_YU_ATTACK_01_TEXTURES.size())]
	if player.is_drag_charging() and _guan_yu_drag_charge_ready():
		return GUAN_YU_DRAG_FOOT_ANCHORS[_guan_yu_drag_frame_index()] if player_is_moving else GUAN_YU_DRAG_FOOT_ANCHORS[1]
	if player_is_moving and player.is_wusheng_active():
		return GUAN_YU_DRAG_FOOT_ANCHORS[_guan_yu_drag_frame_index()]
	return GUAN_YU_SOURCE_FOOT_ANCHOR

func _guan_yu_action_frame_index(frame_count: int) -> int:
	var action_progress: float = 0.0
	if _guan_yu_is_ultimate_casting():
		action_progress = float(player.call("ultimate_cast_animation_progress"))
	elif player.has_method("visual_action_progress"):
		action_progress = float(player.call("visual_action_progress"))
	return mini(int(action_progress * float(frame_count)), frame_count - 1)

func _guan_yu_walk_frame_index() -> int:
	if player_walk_time < GUAN_YU_WALK_ENTRY_DURATION:
		return 0
	var loop_elapsed := player_walk_time - GUAN_YU_WALK_ENTRY_DURATION
	return 1 + int(loop_elapsed / GUAN_YU_WALK_LOOP_FRAME_DURATION) % 4

func _guan_yu_drag_frame_index() -> int:
	var entry_duration := GUAN_YU_DRAG_FRAME_DURATION * float(GUAN_YU_DRAG_TEXTURES.size())
	if player_walk_time < entry_duration:
		return mini(int(player_walk_time / GUAN_YU_DRAG_FRAME_DURATION), GUAN_YU_DRAG_TEXTURES.size() - 1)
	var loop_elapsed := player_walk_time - entry_duration
	return 2 + int(loop_elapsed / GUAN_YU_DRAG_FRAME_DURATION) % (GUAN_YU_DRAG_TEXTURES.size() - 2)

func _guan_yu_drag_charge_ready() -> bool:
	return player != null and player.is_drag_charging() and player.drag_charge_ratio() >= 0.98

func _guan_yu_is_ultimate_casting() -> bool:
	return player != null and player.has_method("is_ultimate_casting") and bool(player.call("is_ultimate_casting"))

func _draw_player_status_aura(at: Vector2) -> void:
	var has_dragon_shield := player.health_component.shield_charges > 0
	var has_breakout_shield := player.has_breakout_guard()
	if player.has_dragon():
		_draw_dragon_state_marker(at)
	if has_dragon_shield:
		_draw_dragon_shield(at)
	if has_breakout_shield:
		_draw_breakout_guard(at)
	if player.has_firewheel_talent() and player.firewheel_cooldown_ratio() > 0.0:
		_draw_firewheel_cooldown_marker(at)

func _draw_player_guard_shield(at: Vector2) -> void:
	if player == null or not player.is_guard_active() or GUARD_SHIELD_TEXTURES.is_empty():
		return
	var frame_index := mini(int(player_guard_time / GUARD_SHIELD_FRAME_DURATION), GUARD_SHIELD_TEXTURES.size() - 1)
	var texture := GUARD_SHIELD_TEXTURES[frame_index]
	if texture == null:
		return
	var progress := clampf(player_guard_time / HeroActor.GUARD_ACTIVE_DURATION, 0.0, 1.0)
	var fade_in := clampf(player_guard_time / 0.055, 0.0, 1.0)
	var fade_out := clampf((1.0 - progress) / 0.24, 0.0, 1.0)
	var pulse := 0.86 + 0.14 * (sin(visual_time * 12.0) + 1.0) * 0.5
	var shield_alpha := 0.30 * fade_in * fade_out * pulse
	var shield_center := at + Vector2(0.0, -24.0)
	var texture_size := Vector2(texture.get_size())
	var shield_scale := GUARD_SHIELD_SCALE * lerpf(0.90, 1.0, fade_in)
	draw_set_transform(shield_center, 0.0, Vector2(shield_scale, shield_scale))
	draw_texture(texture, -texture_size * 0.5, Color(0.82, 0.97, 1.0, shield_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# The texture is a full shell; this brighter front arc communicates the
	# actual 180-degree guard direction without implying rear protection.
	var facing := player.guard_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = Vector2.RIGHT
	var arc_alpha := 0.50 * fade_in * fade_out * pulse
	var arc_center := shield_center + facing * 4.0
	var arc_angle := facing.angle()
	draw_arc(arc_center, 61.0, arc_angle - PI * 0.50, arc_angle + PI * 0.50, 24, Color(0.72, 0.94, 1.0, arc_alpha), 2.2, true)
	draw_arc(arc_center, 55.0, arc_angle - PI * 0.47, arc_angle + PI * 0.47, 20, Color(0.92, 1.0, 1.0, arc_alpha * 0.58), 1.0, true)
	draw_arc(arc_center, 67.0, arc_angle - PI * 0.43, arc_angle + PI * 0.43, 20, Color(0.52, 0.84, 1.0, arc_alpha * 0.34), 1.2, true)

func _draw_firewheel_flames(at: Vector2) -> void:
	var elapsed := player.firewheel_animation_time()
	var spin_start := 0.32
	var spin_end := player.firewheel_spin_end_time()
	var is_finisher := player.is_firewheel_finisher_active()
	var intensity := 1.0 if is_finisher else clampf(elapsed / spin_start, 0.30, 1.0)
	if not is_finisher and elapsed > spin_end:
		intensity *= clampf(1.0 - (elapsed - spin_end) / 0.18, 0.0, 1.0)
	_draw_firewheel_texture(at + Vector2(0, -10), 0.78, -(visual_time * 12.0 + elapsed * 4.0), Color(1.0, 1.0, 1.0, intensity))

func _draw_firewheel_cooldown_marker(at: Vector2) -> void:
	var center := at + Vector2(31, 13)
	var remaining_ratio := player.firewheel_cooldown_ratio()
	_draw_firewheel_texture(center, 0.15, -visual_time * 4.0, Color(0.38, 0.34, 0.31, 0.62))
	var charged_span := TAU * (1.0 - remaining_ratio)
	if charged_span > 0.01:
		draw_arc(center, 13.0, -PI * 0.5, -PI * 0.5 + charged_span, 12, Color(1.0, 0.66, 0.28, 0.88), 1.6)

func _draw_dragon_state_marker(at: Vector2) -> void:
	var center := at + Vector2(0, 13)
	var pulse := 0.68 + 0.22 * (sin(visual_time * 7.0) + 1.0) * 0.5
	var ring_color := Color(0.42, 0.84, 1.0, 0.72 * pulse)
	draw_set_transform(center, 0.0, Vector2(1.0, 0.48))
	draw_arc(Vector2.ZERO, 25.0, 0.0, TAU, 20, ring_color, 2.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var stacks := player.dragon_stack_count()
	for index in range(stacks):
		var pip := center + Vector2((float(index) - float(stacks - 1) * 0.5) * 10.0, -18.0)
		draw_rect(Rect2(pip - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), Color(0.70, 0.94, 1.0, 0.90 * pulse))
		draw_rect(Rect2(pip - Vector2(1.2, 1.2), Vector2(2.4, 2.4)), Color.WHITE)

func _draw_dragon_shield(at: Vector2) -> void:
	var pulse := 0.68 + 0.22 * (sin(visual_time * 7.0) + 1.0) * 0.5
	var center := at + Vector2(0, -14)
	var shield_color := Color(0.50, 0.88, 1.0, 0.16)
	var edge_color := Color(0.63, 0.93, 1.0, pulse)
	var points := PackedVector2Array([
		center + Vector2(-58, 0), center + Vector2(-43, -36), center + Vector2(0, -55), center + Vector2(43, -36),
		center + Vector2(58, 0), center + Vector2(38, 42), center + Vector2(0, 52), center + Vector2(-38, 42),
	])
	draw_colored_polygon(points, shield_color)
	for index in range(points.size()):
		draw_line(points[index], points[(index + 1) % points.size()], edge_color, 2.0)

func _draw_breakout_guard(at: Vector2) -> void:
	var direction := player.last_attack_direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var side := Vector2(-direction.y, direction.x)
	var origin := at + Vector2(0, -8) + direction * 9.0
	var pulse := 0.72 + 0.24 * (sin(visual_time * 14.0) + 1.0) * 0.5
	for index in range(3):
		var offset := side * float(index - 1) * 9.0
		var length := 24.0 - absf(float(index - 1)) * 4.0
		var root := origin + offset
		var tip := root + direction * length
		var wedge := PackedVector2Array([
			root - side * 2.5,
			root + direction * (length * 0.56) - side * 3.5,
			tip,
			root + direction * (length * 0.56) + side * 3.5,
			root + side * 2.5,
		])
		draw_colored_polygon(wedge, Color(0.74, 0.96, 1.0, 0.42 * pulse))
		draw_line(root, tip, Color(0.90, 1.0, 1.0, 0.86 * pulse), 1.2)

func _draw_ultimate_ready_burst(at: Vector2) -> void:
	if WUSHUANG_READY_TEXTURES.is_empty():
		return
	var frame := int(wushuang_ready_animation_time / WUSHUANG_READY_FRAME_DURATION) % WUSHUANG_READY_TEXTURES.size()
	var texture: Texture2D = WUSHUANG_READY_TEXTURES[frame]
	var center := at + WUSHUANG_READY_OFFSET
	draw_set_transform(center, 0.0, Vector2(WUSHUANG_READY_SCALE, WUSHUANG_READY_SCALE))
	draw_texture(texture, -WUSHUANG_READY_SOURCE_CENTER, Color(1.0, 1.0, 1.0, 0.76))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_ground_shadow(center: Vector2, horizontal_radius: float, vertical_radius: float, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(horizontal_radius, vertical_radius))
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_player_sprite(at: Vector2) -> void:
	var using_ultimate_pose := player != null and player.ultimate_time > 0.0
	var texture := PLAYER_ULTIMATE_TEXTURE if using_ultimate_pose else _current_player_texture()
	if texture == null:
		return
	var foot_position := at + PLAYER_WORLD_FOOT_OFFSET
	var horizontal_scale := -PLAYER_SPRITE_SCALE if player_faces_left else PLAYER_SPRITE_SCALE
	draw_set_transform(foot_position, 0.0, Vector2(horizontal_scale, PLAYER_SPRITE_SCALE))
	var source_anchor := PLAYER_ULTIMATE_SOURCE_FOOT_ANCHOR if using_ultimate_pose else _current_player_source_foot_anchor()
	draw_texture(texture, -source_anchor)
	if player_hit_flash_remaining > 0.0:
		var flash_texture := _player_white_flash_texture(texture)
		var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength
		draw_texture(flash_texture, -source_anchor, Color(1.0, 1.0, 1.0, flash_ratio))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_player_death(at: Vector2) -> void:
	_draw_ground_shadow(at + Vector2(0, 14), 29.0, 8.0, Color(0.0, 0.0, 0.0, 0.38))
	var frame_index := _player_death_frame_index()
	if player.presentation_id() == "guan_yu":
		var guan_horizontal_scale := -GUAN_YU_SPRITE_SCALE if player_death_faces_left else GUAN_YU_SPRITE_SCALE
		draw_set_transform(at + GUAN_YU_WORLD_FOOT_OFFSET, 0.0, Vector2(guan_horizontal_scale, GUAN_YU_SPRITE_SCALE))
		draw_texture(GUAN_YU_DEATH_TEXTURES[frame_index], -GUAN_YU_DEATH_FOOT_ANCHORS[frame_index])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if player.presentation_id() == "zhang_fei":
		var zhang_horizontal_scale := -ZHANG_FEI_SPRITE_SCALE if player_death_faces_left else ZHANG_FEI_SPRITE_SCALE
		draw_set_transform(at + ZHANG_FEI_WORLD_FOOT_OFFSET, 0.0, Vector2(zhang_horizontal_scale, ZHANG_FEI_SPRITE_SCALE))
		draw_texture(ZHANG_FEI_DEATH_TEXTURES[frame_index], -ZHANG_FEI_DEATH_FOOT_ANCHORS[frame_index])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if player.presentation_id() != "zhao_yun":
		_draw_generic_hero_placeholder(at)
		return
	var horizontal_scale := -PLAYER_SPRITE_SCALE if player_death_faces_left else PLAYER_SPRITE_SCALE
	draw_set_transform(at + PLAYER_WORLD_FOOT_OFFSET, 0.0, Vector2(horizontal_scale, PLAYER_SPRITE_SCALE))
	draw_texture(PLAYER_DEATH_TEXTURES[frame_index], -PLAYER_DEATH_SOURCE_FOOT_ANCHOR)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _player_white_flash_texture(source_texture: Texture2D) -> Texture2D:
	if player_hit_white_textures.has(source_texture):
		return player_hit_white_textures[source_texture]
	var image := source_texture.get_image()
	if image == null:
		return source_texture
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha > 0.0:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var white_texture := ImageTexture.create_from_image(image)
	player_hit_white_textures[source_texture] = white_texture
	return white_texture

func _player_hit_flash_ratio() -> float:
	var elapsed := PLAYER_HIT_FLASH_DURATION - player_hit_flash_remaining
	if elapsed <= PLAYER_HIT_FLASH_PEAK_DURATION:
		return 1.0
	var fade_duration := PLAYER_HIT_FLASH_DURATION - PLAYER_HIT_FLASH_PEAK_DURATION
	var fade_progress := clampf((elapsed - PLAYER_HIT_FLASH_PEAK_DURATION) / fade_duration, 0.0, 1.0)
	return pow(1.0 - fade_progress, 0.58)

func _draw_player_hit_marker(at: Vector2) -> void:
	if player_hit_flash_remaining <= 0.0:
		return
	var flash_ratio := _player_hit_flash_ratio() * player_hit_flash_strength
	var color := Color(1.0, 0.56, 0.42, flash_ratio * 0.78)
	draw_arc(at + Vector2(0, -6), 30.0 + (1.0 - flash_ratio) * 8.0, 0.0, TAU, 16, color, 1.8)
	for index in range(4):
		var direction := Vector2.from_angle(TAU * float(index) / 4.0 + 0.25)
		draw_line(at + Vector2(0, -6) + direction * 12.0, at + Vector2(0, -6) + direction * 24.0, color, 2.0)

func _draw_sword_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var frame_step := int(visual_time / ENEMY_SWORD_IDLE_FRAME_DURATION) % ENEMY_SWORD_IDLE_FRAME_ORDER.size()
	var texture: Texture2D = ENEMY_SWORD_IDLE_TEXTURES[ENEMY_SWORD_IDLE_FRAME_ORDER[frame_step]]
	var source_anchor: Vector2 = ENEMY_SWORD_SOURCE_FOOT_ANCHOR
	var sprite_scale := ENEMY_SWORD_SPRITE_SCALE
	if moving:
		var walk_frame := int(visual_time / ENEMY_SWORD_WALK_FRAME_DURATION) % ENEMY_SWORD_WALK_TEXTURES.size()
		texture = ENEMY_SWORD_WALK_TEXTURES[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_SWORD_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := mini(int(windup_progress * 3.0), 2)
		texture = ENEMY_SWORD_ATTACK_TEXTURES[attack_frame]
		source_anchor = ENEMY_SWORD_ATTACK_FOOT_ANCHORS[attack_frame]
		sprite_scale = ENEMY_SWORD_ATTACK_SCALES[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		texture = ENEMY_SWORD_ATTACK_TEXTURES[3]
		source_anchor = ENEMY_SWORD_ATTACK_FOOT_ANCHORS[3]
		sprite_scale = ENEMY_SWORD_ATTACK_SCALES[3]
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var foot_position := at + Vector2(0, 14)
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(foot_position, 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -source_anchor, hurt_color)
	_draw_crowd_muting_overlay(texture, source_anchor, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_shield_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_SHIELD_IDLE_FRAME_DURATION) % ENEMY_SHIELD_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_SHIELD_IDLE_TEXTURES[idle_frame]
	if moving:
		var walk_frame := int(visual_time / ENEMY_SHIELD_WALK_FRAME_DURATION) % ENEMY_SHIELD_WALK_TEXTURES.size()
		texture = ENEMY_SHIELD_WALK_TEXTURES[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_SHIELD_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := mini(int(windup_progress * ENEMY_SHIELD_ATTACK_TEXTURES.size()), ENEMY_SHIELD_ATTACK_TEXTURES.size() - 1)
		texture = ENEMY_SHIELD_ATTACK_TEXTURES[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		texture = ENEMY_SHIELD_ATTACK_TEXTURES[ENEMY_SHIELD_ATTACK_TEXTURES.size() - 1]
	var sprite_scale := ENEMY_SHIELD_SPRITE_SCALE
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -ENEMY_SHIELD_SOURCE_FOOT_ANCHOR, hurt_color)
	_draw_crowd_muting_overlay(texture, ENEMY_SHIELD_SOURCE_FOOT_ANCHOR, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_archer_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_ARCHER_IDLE_FRAME_DURATION) % ENEMY_ARCHER_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_ARCHER_IDLE_TEXTURES[idle_frame]
	if moving:
		var walk_frame := int(visual_time / ENEMY_ARCHER_WALK_FRAME_DURATION) % ENEMY_ARCHER_WALK_TEXTURES.size()
		texture = ENEMY_ARCHER_WALK_TEXTURES[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_ARCHER_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := 0 if windup_progress < 0.25 else (1 if windup_progress < 0.45 else 2)
		texture = ENEMY_ARCHER_ATTACK_TEXTURES[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		# The fourth frame is a dedicated recovery pose and remains visible through the full after-swing.
		texture = ENEMY_ARCHER_ATTACK_TEXTURES[ENEMY_ARCHER_ATTACK_TEXTURES.size() - 1]
	var sprite_scale := ENEMY_ARCHER_SPRITE_SCALE
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -ENEMY_ARCHER_SOURCE_FOOT_ANCHOR, hurt_color)
	_draw_crowd_muting_overlay(texture, ENEMY_ARCHER_SOURCE_FOOT_ANCHOR, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_halberd_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_HALBERD_IDLE_FRAME_DURATION) % ENEMY_HALBERD_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_HALBERD_IDLE_TEXTURES[idle_frame]
	if moving:
		var walk_frame := int(visual_time / ENEMY_HALBERD_WALK_FRAME_DURATION) % ENEMY_HALBERD_WALK_TEXTURES.size()
		texture = ENEMY_HALBERD_WALK_TEXTURES[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_HALBERD_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := 0 if windup_progress < 0.34 else (1 if windup_progress < 0.67 else 2)
		texture = ENEMY_HALBERD_ATTACK_TEXTURES[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		# Frame four is the recovery pose and stays visible until the enemy can move again.
		texture = ENEMY_HALBERD_ATTACK_TEXTURES[ENEMY_HALBERD_ATTACK_TEXTURES.size() - 1]
	var sprite_scale := ENEMY_HALBERD_SPRITE_SCALE
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -ENEMY_HALBERD_SOURCE_FOOT_ANCHOR, hurt_color)
	_draw_crowd_muting_overlay(texture, ENEMY_HALBERD_SOURCE_FOOT_ANCHOR, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_spear_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_SPEAR_IDLE_FRAME_DURATION) % ENEMY_SPEAR_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_SPEAR_IDLE_TEXTURES[idle_frame]
	var foot_anchor: Vector2 = ENEMY_SPEAR_IDLE_FOOT_ANCHORS[idle_frame]
	var sprite_scale := ENEMY_SPEAR_SPRITE_SCALE
	if moving:
		var walk_frame := int(visual_time / ENEMY_SPEAR_WALK_FRAME_DURATION) % ENEMY_SPEAR_WALK_TEXTURES.size()
		texture = ENEMY_SPEAR_WALK_TEXTURES[walk_frame]
		foot_anchor = ENEMY_SPEAR_WALK_FOOT_ANCHORS[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_SPEAR_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := 0 if windup_progress < 0.25 else (1 if windup_progress < 0.50 else (2 if windup_progress < 0.75 else 3))
		texture = ENEMY_SPEAR_ATTACK_TEXTURES[attack_frame]
		foot_anchor = ENEMY_SPEAR_ATTACK_FOOT_ANCHORS[attack_frame]
		sprite_scale = ENEMY_SPEAR_ATTACK_SCALES[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		texture = ENEMY_SPEAR_ATTACK_TEXTURES[ENEMY_SPEAR_ATTACK_TEXTURES.size() - 1]
		foot_anchor = ENEMY_SPEAR_ATTACK_FOOT_ANCHORS[ENEMY_SPEAR_ATTACK_FOOT_ANCHORS.size() - 1]
		sprite_scale = ENEMY_SPEAR_ATTACK_SCALES[ENEMY_SPEAR_ATTACK_SCALES.size() - 1]
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -foot_anchor, hurt_color)
	_draw_crowd_muting_overlay(texture, foot_anchor, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_crossbow_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_CROSSBOW_IDLE_FRAME_DURATION) % ENEMY_CROSSBOW_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_CROSSBOW_IDLE_TEXTURES[idle_frame]
	var foot_anchor: Vector2 = ENEMY_CROSSBOW_IDLE_FOOT_ANCHORS[idle_frame]
	if moving:
		var walk_frame := int(visual_time / ENEMY_CROSSBOW_WALK_FRAME_DURATION) % ENEMY_CROSSBOW_WALK_TEXTURES.size()
		texture = ENEMY_CROSSBOW_WALK_TEXTURES[walk_frame]
		foot_anchor = ENEMY_CROSSBOW_WALK_FOOT_ANCHORS[walk_frame]
	elif attack_state == EnemySimulation.AttackState.WINDUP:
		var windup_progress := clampf(1.0 - attack_remaining / ENEMY_CROSSBOW_WINDUP_DURATION, 0.0, 1.0)
		var attack_frame := mini(int(windup_progress * ENEMY_CROSSBOW_ATTACK_TEXTURES.size()), ENEMY_CROSSBOW_ATTACK_TEXTURES.size() - 1)
		texture = ENEMY_CROSSBOW_ATTACK_TEXTURES[attack_frame]
		foot_anchor = ENEMY_CROSSBOW_ATTACK_FOOT_ANCHORS[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		texture = ENEMY_CROSSBOW_ATTACK_TEXTURES[ENEMY_CROSSBOW_ATTACK_TEXTURES.size() - 1]
		foot_anchor = ENEMY_CROSSBOW_ATTACK_FOOT_ANCHORS[ENEMY_CROSSBOW_ATTACK_FOOT_ANCHORS.size() - 1]
	var sprite_scale := ENEMY_CROSSBOW_SPRITE_SCALE
	var horizontal_scale := -sprite_scale if facing.x < -0.05 else sprite_scale
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)), sprite_scale * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))))
	draw_texture(texture, -foot_anchor, hurt_color)
	_draw_crowd_muting_overlay(texture, foot_anchor, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_banner_enemy_proxy(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, commanding: bool, crowd_dim: float) -> void:
	var forward := Vector2.RIGHT if facing.x >= 0.0 else Vector2.LEFT
	var deform_x := 1.0 + hurt_ratio * (0.06 + hit_strength * 0.05)
	var deform_y := 1.0 - hurt_ratio * (0.04 + hit_strength * 0.035)
	var body_color := Color("7e4039").lerp(Color.WHITE, hurt_ratio * 0.76).lerp(Color("252b32"), crowd_dim * 0.28)
	draw_set_transform(at + Vector2(0.0, 13.0), 0.0, Vector2(deform_x, deform_y))
	draw_rect(Rect2(-11.0, -23.0, 22.0, 27.0), body_color)
	draw_rect(Rect2(-13.0, -29.0, 26.0, 6.0), Color("30282b").lerp(Color.WHITE, hurt_ratio * 0.44))
	draw_circle(Vector2(0.0, -33.0), 7.2, Color("d6af84").lerp(Color.WHITE, hurt_ratio * 0.50))
	draw_line(Vector2(-7.0, 1.0), Vector2(-7.0, -76.0), Color("7d5631"), 3.2)
	var flutter := sin(visual_time * 5.0 + at.x * 0.03) * 3.0
	var flag := PackedVector2Array([
		Vector2(-6.0, -73.0), Vector2(-6.0, -43.0), Vector2(27.0 * forward.x, -49.0 + flutter), Vector2(22.0 * forward.x, -72.0 + flutter),
	])
	draw_colored_polygon(flag, Color("b53933").lerp(Color(1.0, 0.78, 0.34), 0.24 if commanding else 0.0))
	draw_circle(Vector2(-7.0, -77.0), 3.0, Color("d3a84f"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_ellipse_arc(at + Vector2(0.0, 13.0), Vector2(76.0, 23.0), -0.18, 1.72, 10, Color(0.96, 0.74, 0.28, 0.27), 1.2)
	_draw_ellipse_arc(at + Vector2(0.0, 13.0), Vector2(76.0, 23.0), PI - 0.18, PI + 1.72, 10, Color(0.96, 0.74, 0.28, 0.27), 1.2)
	if commanding:
		var pulse := 0.74 + 0.26 * (sin(visual_time * 15.0) + 1.0) * 0.5
		_draw_ellipse_arc(at + Vector2(0.0, 13.0), Vector2(94.0 * pulse, 29.0 * pulse), 0.0, TAU, 16, Color(1.0, 0.80, 0.34, 0.72), 2.0)

func _draw_cavalry_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, charging: bool, moving: bool, crowd_dim: float) -> void:
	var idle_frame := int(visual_time / ENEMY_CAVALRY_IDLE_FRAME_DURATION) % ENEMY_CAVALRY_IDLE_TEXTURES.size()
	var texture: Texture2D = ENEMY_CAVALRY_IDLE_TEXTURES[idle_frame]
	var foot_anchor: Vector2 = ENEMY_CAVALRY_IDLE_FOOT_ANCHORS[idle_frame]
	if attack_state == EnemySimulation.AttackState.WINDUP:
		# The source has two attack poses: hold the first through the windup and cut to the thrust near impact.
		var attack_frame := 0 if attack_remaining > 0.20 else 1
		texture = ENEMY_CAVALRY_ATTACK_TEXTURES[attack_frame]
		foot_anchor = ENEMY_CAVALRY_ATTACK_FOOT_ANCHORS[attack_frame]
	elif attack_state == EnemySimulation.AttackState.RECOVER:
		texture = ENEMY_CAVALRY_ATTACK_TEXTURES[ENEMY_CAVALRY_ATTACK_TEXTURES.size() - 1]
		foot_anchor = ENEMY_CAVALRY_ATTACK_FOOT_ANCHORS[ENEMY_CAVALRY_ATTACK_FOOT_ANCHORS.size() - 1]
	elif charging:
		var charge_frame := int(visual_time / ENEMY_CAVALRY_CHARGE_FRAME_DURATION) % ENEMY_CAVALRY_WALK_TEXTURES.size()
		texture = ENEMY_CAVALRY_WALK_TEXTURES[charge_frame]
		foot_anchor = ENEMY_CAVALRY_WALK_FOOT_ANCHORS[charge_frame]
	elif moving:
		var walk_frame := int(visual_time / ENEMY_CAVALRY_WALK_FRAME_DURATION) % ENEMY_CAVALRY_WALK_TEXTURES.size()
		texture = ENEMY_CAVALRY_WALK_TEXTURES[walk_frame]
		foot_anchor = ENEMY_CAVALRY_WALK_FOOT_ANCHORS[walk_frame]
	var horizontal_scale := -ENEMY_CAVALRY_SPRITE_SCALE if facing.x < -0.05 else ENEMY_CAVALRY_SPRITE_SCALE
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	var deform_x := horizontal_scale * (1.0 + hurt_ratio * (0.06 + hit_strength * 0.05))
	var deform_y := ENEMY_CAVALRY_SPRITE_SCALE * (1.0 - hurt_ratio * (0.04 + hit_strength * 0.035))
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(deform_x, deform_y))
	draw_texture(texture, -foot_anchor, hurt_color)
	_draw_crowd_muting_overlay(texture, foot_anchor, crowd_dim)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if charging:
		var forward := Vector2.RIGHT if facing.x >= 0.0 else Vector2.LEFT
		for index in range(3):
			var dust := at - forward * (18.0 + float(index) * 12.0) + Vector2(0.0, 16.0 + float(index) * 2.0)
			draw_circle(dust, 4.0 + float(index) * 1.4, Color(0.72, 0.67, 0.51, 0.16 - float(index) * 0.03))

func _draw_banner_enemy_death_proxy(at: Vector2, facing: Vector2, tilt: float, alpha: float) -> void:
	var forward := Vector2.RIGHT if facing.x >= 0.0 else Vector2.LEFT
	draw_set_transform(at + Vector2(0.0, 12.0), tilt, Vector2.ONE)
	draw_rect(Rect2(-12.0, -9.0, 24.0, 17.0), Color(0.50, 0.23, 0.22, alpha))
	draw_circle(Vector2(5.0, -11.0), 6.0, Color(0.78, 0.68, 0.56, alpha))
	draw_line(-forward * 38.0 + Vector2(0.0, -2.0), forward * 26.0 + Vector2(0.0, -2.0), Color(0.50, 0.34, 0.18, alpha), 2.8)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_banner_commanded_marker(at: Vector2, ratio: float) -> void:
	var alpha := clampf(ratio, 0.0, 1.0) * 0.76
	var center := at + Vector2(0.0, -31.0)
	draw_arc(center, 10.0, -2.48, -0.66, 7, Color(1.0, 0.78, 0.30, alpha), 1.5)
	draw_arc(center, 10.0, 0.66, 2.48, 7, Color(1.0, 0.78, 0.30, alpha), 1.5)

func _draw_crowd_muting_overlay(texture: Texture2D, source_anchor: Vector2, amount: float) -> void:
	if amount <= 0.0:
		return
	draw_texture(texture, -source_anchor, Color(0.22, 0.24, 0.29, amount * 0.18))

func _named_target_crowd_dim(at: Vector2) -> float:
	var dim := 0.0
	if boss != null and boss.active:
		dim = maxf(dim, _crowd_dim_for_distance(at.distance_to(boss.position)))
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			dim = maxf(dim, _crowd_dim_for_distance(at.distance_to(elite.position)))
	return dim

func _crowd_dim_for_distance(distance: float) -> float:
	return clampf((122.0 - distance) / 72.0, 0.0, 1.0)

func _draw_attack_03_spear_flare(at: Vector2) -> void:
	if not player_is_playing_attack_03:
		return
	var frame_index := _attack_03_frame_index()
	if frame_index < 2:
		return
	var direction := player.path_dash_visual_direction() if player.is_path_dashing() else player.last_attack_direction
	var perpendicular := Vector2(-direction.y, direction.x)
	var hit_half_width: float = float(player.path_dash_visual_width()) * 0.5
	var flare_step := mini(frame_index - 2, 3)
	var lengths := [40.0, 58.0, 48.0, 34.0]
	var widths := [4.0, 5.6, 4.5, 3.0]
	var alphas := [0.70, 1.0, 0.80, 0.56]
	# Keep the flare outside the sprite silhouette.  It follows Zhao Yun's current position,
	# rather than the dash segment's old origin, so it never trails through his body.
	var root := at + SPEAR_VFX_HEIGHT_OFFSET + direction * 52.0
	var length: float = lengths[flare_step]
	var width: float = widths[flare_step]
	var alpha: float = alphas[flare_step]
	var tip := root + direction * length
	var outer := PackedVector2Array([
		root - perpendicular * (width * 1.45),
		root + direction * (length * 0.24) - perpendicular * (width * 1.86),
		root + direction * (length * 0.62) - perpendicular * (width * 0.62),
		tip,
		root + direction * (length * 0.68) + perpendicular * (width * 0.48),
		root + direction * (length * 0.20) + perpendicular * (width * 1.15),
	])
	draw_colored_polygon(outer, Color(0.34, 0.82, 1.0, alpha * 0.62))
	var core := PackedVector2Array([
		root + direction * 3.0 - perpendicular * width,
		root + direction * (length * 0.44) - perpendicular * (width * 0.74),
		tip - direction * 1.4,
		root + direction * (length * 0.50) + perpendicular * (width * 0.42),
		root + direction * 3.0 + perpendicular * (width * 0.72),
	])
	draw_colored_polygon(core, Color(0.78, 0.97, 1.0, alpha * 0.82))
	var shard_center := root + direction * (length * 0.54) - perpendicular * (width * 2.0)
	var shard := PackedVector2Array([shard_center - direction * 4.0, shard_center + perpendicular * 2.6, shard_center + direction * 8.0])
	draw_colored_polygon(shard, Color(0.58, 0.91, 1.0, alpha * 0.46))
	# The side gusts make the widened third-strike clearing corridor readable in play.
	var clearing_root := at + SPEAR_VFX_HEIGHT_OFFSET + direction * 26.0
	for side in [-1.0, 1.0]:
		var side_sign: float = side
		var start := clearing_root + perpendicular * side_sign * hit_half_width * 0.22
		var end := clearing_root + direction * 24.0 + perpendicular * side_sign * hit_half_width
		draw_line(start, end, Color(0.42, 0.86, 1.0, alpha * 0.42), 2.0)
		draw_line(start + direction * 4.0, end + direction * 7.0, Color(0.78, 0.97, 1.0, alpha * 0.52), 1.0)

func _copy_request_for_visual(source: AttackRequest) -> AttackRequest:
	var copy := AttackRequest.new()
	copy.shape = source.shape
	copy.origin = source.origin
	copy.direction = source.direction
	copy.range = source.range
	copy.inner_radius = source.inner_radius
	copy.width = source.width
	copy.half_angle = source.half_angle
	copy.multiplier = source.multiplier
	copy.pierce = source.pierce
	copy.knockback = source.knockback
	copy.ignore_knockback_resistance = source.ignore_knockback_resistance
	copy.forced_displacement = source.forced_displacement
	copy.forced_displacement_duration = source.forced_displacement_duration
	copy.visual_scale = source.visual_scale
	copy.label = source.label
	copy.fan_knockback = source.fan_knockback
	copy.displacement_only = source.displacement_only
	copy.suppress_visual_feedback = source.suppress_visual_feedback
	copy.empowered_knockback_active = source.empowered_knockback_active
	copy.empowered_knockback_target_limit = source.empowered_knockback_target_limit
	copy.empowered_knockback_multiplier = source.empowered_knockback_multiplier
	copy.launches_enemies = source.launches_enemies
	copy.launch_speed = source.launch_speed
	copy.launch_duration = source.launch_duration
	copy.launch_collision_damage_multiplier = source.launch_collision_damage_multiplier
	copy.launch_collision_knockback = source.launch_collision_knockback
	copy.launch_collision_max_targets = source.launch_collision_max_targets
	copy.launch_relay_count = source.launch_relay_count
	copy.launch_target_limit = source.launch_target_limit
	copy.grants_special_target_dragon_progress = source.grants_special_target_dragon_progress
	return copy

func _current_player_texture() -> Texture2D:
	if player.is_guard_active():
		var guard_frames := [1, 3]
		var guard_frame := mini(int(player_guard_time / PLAYER_GUARD_FRAME_DURATION), guard_frames.size() - 1)
		return PLAYER_ATTACK_02_TEXTURES[guard_frames[guard_frame]]
	if player_is_playing_attack_01:
		var attack_frame := mini(int(player_attack_01_time / PLAYER_ATTACK_01_FRAME_DURATION), PLAYER_ATTACK_01_TEXTURES.size() - 1)
		return PLAYER_ATTACK_01_TEXTURES[attack_frame]
	if player_is_playing_attack_02:
		return PLAYER_ATTACK_02_TEXTURES[_attack_02_frame_index()]
	if player_is_playing_attack_03:
		return PLAYER_ATTACK_03_TEXTURES[_attack_03_frame_index()]
	if player_is_playing_attack_05:
		return PLAYER_ATTACK_05_TEXTURES[_attack_05_frame_index()]
	if player_is_playing_attack_04:
		return PLAYER_ATTACK_04_TEXTURES[_attack_04_frame_index()]
	if player_is_moving:
		var walk_frame := int(player_walk_time / PLAYER_WALK_FRAME_DURATION) % PLAYER_WALK_TEXTURES.size()
		return PLAYER_WALK_TEXTURES[walk_frame]
	var idle_step := int(player_idle_time / PLAYER_IDLE_FRAME_DURATION) % PLAYER_IDLE_FRAME_ORDER.size()
	return PLAYER_IDLE_TEXTURES[PLAYER_IDLE_FRAME_ORDER[idle_step]]

func _current_player_source_foot_anchor() -> Vector2:
	if player.is_guard_active():
		var guard_frames := [1, 3]
		var guard_frame := mini(int(player_guard_time / PLAYER_GUARD_FRAME_DURATION), guard_frames.size() - 1)
		return PLAYER_ATTACK_02_FOOT_ANCHORS[guard_frames[guard_frame]]
	if player_is_playing_attack_02:
		return PLAYER_ATTACK_02_FOOT_ANCHORS[_attack_02_frame_index()]
	if player_is_playing_attack_05:
		return PLAYER_ATTACK_05_FOOT_ANCHORS[_attack_05_frame_index()]
	if player_is_playing_attack_04:
		return PLAYER_ATTACK_04_SOURCE_FOOT_ANCHOR
	return PLAYER_SOURCE_FOOT_ANCHOR

func _attack_02_frame_index() -> int:
	return mini(int(player_attack_02_time / PLAYER_ATTACK_02_FRAME_DURATION), PLAYER_ATTACK_02_TEXTURES.size() - 1)

func _attack_03_frame_index() -> int:
	return mini(int(player_attack_03_time / PLAYER_ATTACK_03_FRAME_DURATION), PLAYER_ATTACK_03_TEXTURES.size() - 1)

func _attack_04_frame_index() -> int:
	if player_attack_04_time < PLAYER_ATTACK_04_FRAME_DURATION * 4.0:
		return mini(int(player_attack_04_time / PLAYER_ATTACK_04_FRAME_DURATION), 3)
	return 4 + int((player_attack_04_time - PLAYER_ATTACK_04_FRAME_DURATION * 4.0) / PLAYER_ATTACK_04_FRAME_DURATION) % 2

func _attack_05_frame_index() -> int:
	return mini(int(player_attack_05_time / PLAYER_ATTACK_05_FRAME_DURATION), PLAYER_ATTACK_05_TEXTURES.size() - 1)

func _player_death_frame_index() -> int:
	if player_death_hero_id == "guan_yu":
		var elapsed := player_death_elapsed
		for index in range(GUAN_YU_DEATH_FRAME_DURATIONS.size()):
			elapsed -= GUAN_YU_DEATH_FRAME_DURATIONS[index]
			if elapsed < 0.0:
				return index
		return GUAN_YU_DEATH_FRAME_DURATIONS.size() - 1
	if player_death_hero_id == "zhang_fei":
		var zhang_elapsed := player_death_elapsed
		for index in range(ZHANG_FEI_DEATH_FRAME_DURATIONS.size()):
			zhang_elapsed -= ZHANG_FEI_DEATH_FRAME_DURATIONS[index]
			if zhang_elapsed < 0.0:
				return index
		return ZHANG_FEI_DEATH_FRAME_DURATIONS.size() - 1
	if player_death_elapsed < PLAYER_DEATH_FRAME_01_DURATION:
		return 0
	if player_death_elapsed < PLAYER_DEATH_FRAME_01_DURATION + PLAYER_DEATH_FRAME_02_DURATION:
		return 1
	if player_death_elapsed < PLAYER_DEATH_FRAME_01_DURATION + PLAYER_DEATH_FRAME_02_DURATION + PLAYER_DEATH_FRAME_03_DURATION:
		return 2
	return 3

func _draw_boss() -> void:
	if boss == null or (not boss.active and not boss.is_dying()):
		return
	var at := boss.position + boss.knockback_visual_offset() if boss.is_knockback_visual_active() else boss.position
	var spear_direction := boss.facing_direction if boss.facing_direction.length_squared() > 0.01 else Vector2.DOWN
	if boss.archetype == BossActor.Archetype.LV_BU and boss.is_ultimate_airborne():
		var target := boss.ultimate_target()
		var leap_progress := boss.ultimate_airborne_progress()
		_draw_ground_shadow(target + Vector2(0, 22), lerpf(36.0, 22.0, leap_progress), lerpf(10.5, 5.0, leap_progress), Color(0.0, 0.0, 0.0, 0.30 - leap_progress * 0.16))
		if leap_progress < 0.18:
			var takeoff_ratio := leap_progress / 0.18
			var takeoff_scale := BOSS_LV_BU_SPRITE_SCALE * (1.0 - takeoff_ratio * 0.42)
			var takeoff_vertical := BOSS_LV_BU_SPRITE_SCALE * (1.08 + (1.0 - takeoff_ratio) * 0.26)
			var takeoff_facing := -takeoff_scale if spear_direction.x < -0.05 else takeoff_scale
			_draw_named_sprite(BOSS_LV_BU_ATTACK_3_TEXTURES[0], BOSS_LV_BU_ATTACK_3_FOOT_ANCHORS[0], at + Vector2(0.0, -takeoff_ratio * 20.0 + 14.0), takeoff_facing, takeoff_vertical, Color(1.0, 1.0, 1.0, 1.0 - takeoff_ratio), Color(0.13, 0.04, 0.04, 0.90 * (1.0 - takeoff_ratio)), 1.6)
		return
	if boss.archetype == BossActor.Archetype.LV_BU and boss.is_ultimate_landing():
		at = boss.ultimate_target()
		_draw_lv_bu_skyfall_marker(at, boss.ultimate_landing_progress(), true)
	_draw_ground_shadow(at + Vector2(0, 22), 36.0, 10.5, Color(0.0, 0.0, 0.0, 0.38))
	if boss.is_dying():
		if boss.archetype == BossActor.Archetype.XIAHOU_DUN:
			_draw_xiahou_dun_death_sprite(at, spear_direction)
			return
		if boss.archetype == BossActor.Archetype.LV_BU:
			_draw_lv_bu_death_sprite(at, spear_direction)
			return
		_draw_boss_death_sprite(at, spear_direction)
		return
	if not boss.is_vulnerable():
		_draw_boss_aura(at, spear_direction)
	if boss.is_cast_invulnerable():
		_draw_cast_invulnerability_marker(at, spear_direction, 1.0, boss.current_action)
	if boss.archetype == BossActor.Archetype.XIAHOU_DUN:
		var xiahou_recoil_wave := sin(boss.knockback_visual_progress() * PI) if boss.is_knockback_visual_active() else 0.0
		var xiahou_dun_tilt := (0.12 + xiahou_recoil_wave * 0.16 * boss.knockback_visual_strength()) * (-1.0 if spear_direction.x < 0.0 else 1.0) if boss.is_knockback_visual_active() else 0.0
		_draw_xiahou_dun_sprite(at, spear_direction, xiahou_dun_tilt)
		_draw_boss_command_marker(at)
		if boss.is_vulnerable():
			_draw_named_vulnerable_marker(at, 1.0, boss.vulnerable_ratio())
		if boss.is_stance_broken():
			_draw_named_stance_break_marker(at, 1.0)
		return
	if boss.archetype == BossActor.Archetype.LV_BU:
		if boss.is_ultimate_landing():
			_draw_lv_bu_landing_sprite(at, spear_direction, boss.ultimate_landing_progress())
			_draw_boss_command_marker(at)
			return
		var lvbu_recoil_wave := sin(boss.knockback_visual_progress() * PI) if boss.is_knockback_visual_active() else 0.0
		var lvbu_tilt := (0.10 + lvbu_recoil_wave * 0.18 * boss.knockback_visual_strength()) * (-1.0 if spear_direction.x < 0.0 else 1.0) if boss.is_knockback_visual_active() else 0.0
		_draw_lv_bu_sprite(at, spear_direction, lvbu_tilt)
		_draw_lv_bu_rush_trail(at, spear_direction)
		_draw_lv_bu_attack_vfx(at, spear_direction)
		_draw_boss_command_marker(at)
		if boss.is_vulnerable():
			_draw_named_vulnerable_marker(at, 1.08, boss.vulnerable_ratio())
		if boss.is_stance_broken():
			_draw_named_stance_break_marker(at, 1.08)
		return
	var texture: Texture2D
	var recoil_wave := sin(boss.knockback_visual_progress() * PI) if boss.is_knockback_visual_active() else 0.0
	var recoil_tilt := (0.08 + recoil_wave * 0.14 * boss.knockback_visual_strength()) * (-1.0 if spear_direction.x < 0.0 else 1.0) if boss.is_knockback_visual_active() else 0.0
	var recoil_scale_x := 1.0 + recoil_wave * 0.10 * boss.knockback_visual_strength()
	var recoil_scale_y := 1.0 - recoil_wave * 0.06 * boss.knockback_visual_strength()
	if boss.is_knockback_visual_active():
		texture = BOSS_ZHANG_HE_DEATH_TEXTURES[0]
	else:
		var idle_frame := int(visual_time / BOSS_ZHANG_HE_IDLE_FRAME_DURATION) % BOSS_ZHANG_HE_IDLE_TEXTURES.size()
		texture = BOSS_ZHANG_HE_IDLE_TEXTURES[idle_frame]
		if boss.is_moving():
			var walk_frame := int(visual_time / BOSS_ZHANG_HE_WALK_FRAME_DURATION) % BOSS_ZHANG_HE_WALK_TEXTURES.size()
			texture = BOSS_ZHANG_HE_WALK_TEXTURES[walk_frame]
		elif boss.state == BossActor.State.WINDUP or boss.is_recovering():
			texture = _boss_attack_texture(boss.current_action, boss.attack_animation_progress())
	var facing_scale := -BOSS_ZHANG_HE_SPRITE_SCALE if spear_direction.x < -0.05 else BOSS_ZHANG_HE_SPRITE_SCALE
	_draw_named_sprite(texture, BOSS_ZHANG_HE_SOURCE_FOOT_ANCHOR, at + Vector2(0, 14), facing_scale * recoil_scale_x, BOSS_ZHANG_HE_SPRITE_SCALE * recoil_scale_y, Color.WHITE, Color("211c3a", 0.94), 1.6, recoil_tilt)
	_draw_zhang_he_attack_vfx(at, spear_direction)
	_draw_boss_command_marker(at)
	if boss.is_vulnerable():
		_draw_named_vulnerable_marker(at, 1.0, boss.vulnerable_ratio())
	if boss.is_stance_broken():
		_draw_named_stance_break_marker(at, 1.0)

func _draw_boss_death_sprite(at: Vector2, direction: Vector2) -> void:
	var frame_index := mini(int(boss.death_animation_progress() * BOSS_ZHANG_HE_DEATH_TEXTURES.size()), BOSS_ZHANG_HE_DEATH_TEXTURES.size() - 1)
	var facing_scale := -BOSS_ZHANG_HE_SPRITE_SCALE if direction.x < -0.05 else BOSS_ZHANG_HE_SPRITE_SCALE
	_draw_named_sprite(BOSS_ZHANG_HE_DEATH_TEXTURES[frame_index], BOSS_ZHANG_HE_SOURCE_FOOT_ANCHOR, at + Vector2(0, 14), facing_scale, BOSS_ZHANG_HE_SPRITE_SCALE, Color.WHITE, Color("211c3a", 0.94), 1.6)

func _draw_xiahou_dun_sprite(at: Vector2, direction: Vector2, recoil_tilt: float = 0.0) -> void:
	var frame_data := _xiahou_dun_frame_data()
	var texture: Texture2D = frame_data.get("texture")
	var source_anchor: Vector2 = frame_data.get("anchor", Vector2(64.0, 94.0))
	var facing_scale := -BOSS_XIAHOU_DUN_SPRITE_SCALE if direction.x < -0.05 else BOSS_XIAHOU_DUN_SPRITE_SCALE
	var recoil_wave := sin(boss.knockback_visual_progress() * PI) if boss.is_knockback_visual_active() else 0.0
	var recoil_scale_x := 1.0 + recoil_wave * 0.08 * boss.knockback_visual_strength() if boss.is_knockback_visual_active() else 1.0
	var recoil_scale_y := 1.0 - recoil_wave * 0.05 * boss.knockback_visual_strength() if boss.is_knockback_visual_active() else 1.0
	var hurt_ratio := clampf(boss.hurt_remaining / 0.14, 0.0, 1.0)
	var hurt_color := Color.WHITE.lerp(Color("d8e9f2"), hurt_ratio * 0.62)
	_draw_named_sprite(texture, source_anchor, at + Vector2(0.0, 14.0), facing_scale * recoil_scale_x, BOSS_XIAHOU_DUN_SPRITE_SCALE * recoil_scale_y, hurt_color, Color("211c3a", 0.94), 1.6, recoil_tilt)

func _draw_xiahou_dun_death_sprite(at: Vector2, direction: Vector2) -> void:
	var frame_index := mini(int(boss.death_animation_progress() / BOSS_XIAHOU_DUN_DEATH_FRAME_DURATION), BOSS_XIAHOU_DUN_DEATH_TEXTURES.size() - 1)
	var facing_scale := -BOSS_XIAHOU_DUN_SPRITE_SCALE if direction.x < -0.05 else BOSS_XIAHOU_DUN_SPRITE_SCALE
	var source_anchor: Vector2 = BOSS_XIAHOU_DUN_DEATH_FOOT_ANCHORS[frame_index]
	var fade := 1.0 - boss.death_animation_progress() * 0.36
	_draw_named_sprite(BOSS_XIAHOU_DUN_DEATH_TEXTURES[frame_index], source_anchor, at + Vector2(0.0, 14.0), facing_scale, BOSS_XIAHOU_DUN_SPRITE_SCALE, Color(1.0, 1.0, 1.0, fade), Color(0.13, 0.11, 0.17, fade * 0.92), 1.6)

func _draw_lv_bu_sprite(at: Vector2, direction: Vector2, recoil_tilt: float = 0.0) -> void:
	var frame_data := _lv_bu_frame_data()
	var texture: Texture2D = frame_data.get("texture")
	var source_anchor: Vector2 = frame_data.get("anchor", Vector2(64.0, 66.0))
	var frame_scale := float(frame_data.get("scale", 1.0))
	var sprite_scale := BOSS_LV_BU_SPRITE_SCALE * frame_scale
	var facing_scale := -sprite_scale if direction.x < -0.05 else sprite_scale
	var hurt_ratio := clampf(boss.hurt_remaining / 0.14, 0.0, 1.0)
	var hurt_color := Color.WHITE.lerp(Color("ffe2b6"), hurt_ratio * 0.56)
	_draw_named_sprite(texture, source_anchor, at + Vector2(0.0, 14.0), facing_scale, sprite_scale, hurt_color, Color("211c3a", 0.94), 1.6, recoil_tilt)

func _draw_lv_bu_landing_sprite(at: Vector2, direction: Vector2, progress: float) -> void:
	var texture: Texture2D = BOSS_LV_BU_ATTACK_3_TEXTURES[3]
	var source_anchor: Vector2 = BOSS_LV_BU_ATTACK_3_FOOT_ANCHORS[3]
	var rebound := sin(clampf(progress, 0.0, 1.0) * PI)
	var scale_x := BOSS_LV_BU_SPRITE_SCALE * lerpf(0.72, 1.06, progress) * (1.0 + rebound * 0.12)
	var scale_y := BOSS_LV_BU_SPRITE_SCALE * lerpf(1.24, 0.96, progress) * (1.0 - rebound * 0.10)
	var facing_scale := -scale_x if direction.x < -0.05 else scale_x
	_draw_named_sprite(texture, source_anchor, at + Vector2(0.0, 14.0), facing_scale, scale_y, Color.WHITE, Color("211c3a", 0.94), 1.6, 0.0)

func _draw_lv_bu_skyfall_marker(center: Vector2, progress: float, landing: bool) -> void:
	var pulse := 0.62 + 0.30 * (sin(visual_time * 10.0) + 1.0) * 0.5
	var radius := 212.0 * (0.82 + progress * 0.18)
	var red := Color(0.92, 0.12, 0.16, pulse * (0.62 if landing else 0.46))
	var gold := Color(1.0, 0.72, 0.30, pulse * (0.82 if landing else 0.58))
	draw_arc(center, radius, -PI * 0.5, TAU - PI * 0.5, 40, red, 3.0)
	draw_arc(center, radius * 0.78, visual_time * 0.8, visual_time * 0.8 + PI * 1.2, 24, gold, 2.0)
	if landing:
		var burst := 1.0 - progress
		for index in range(10):
			var direction := Vector2.from_angle(TAU * float(index) / 10.0)
			draw_line(center + direction * 28.0, center + direction * (72.0 + burst * 30.0), Color(1.0, 0.66, 0.24, burst * 0.84), 2.4)
	else:
		var beam_height := 90.0 + progress * 70.0
		draw_line(center + Vector2(0, -beam_height), center + Vector2(0, -18.0), Color(1.0, 0.42, 0.18, pulse * 0.45), 3.0)
		draw_line(center + Vector2(-10.0, -beam_height + 12.0), center + Vector2(-3.0, -22.0), Color(1.0, 0.78, 0.36, pulse * 0.28), 1.6)

func _draw_lv_bu_death_sprite(at: Vector2, direction: Vector2) -> void:
	var frame_index := mini(int(boss.death_animation_progress() / BOSS_LV_BU_DEATH_FRAME_DURATION), BOSS_LV_BU_DEATH_TEXTURES.size() - 1)
	var facing_scale := -BOSS_LV_BU_SPRITE_SCALE if direction.x < -0.05 else BOSS_LV_BU_SPRITE_SCALE
	var source_anchor: Vector2 = BOSS_LV_BU_DEATH_FOOT_ANCHORS[frame_index]
	var fade := 1.0 - boss.death_animation_progress() * 0.36
	_draw_named_sprite(BOSS_LV_BU_DEATH_TEXTURES[frame_index], source_anchor, at + Vector2(0.0, 14.0), facing_scale, BOSS_LV_BU_SPRITE_SCALE, Color(1.0, 1.0, 1.0, fade), Color(0.13, 0.11, 0.17, fade * 0.92), 1.6)

func _lv_bu_frame_data() -> Dictionary:
	if boss.is_knockback_visual_active():
		if boss.is_stance_broken():
			return {"texture": BOSS_LV_BU_DEATH_TEXTURES[0], "anchor": BOSS_LV_BU_DEATH_FOOT_ANCHORS[0], "scale": 1.0, "weapon_tip": BOSS_LV_BU_DEFAULT_WEAPON_TIP}
		return {"texture": BOSS_LV_BU_ATTACK_1_TEXTURES[0], "anchor": BOSS_LV_BU_ATTACK_1_FOOT_ANCHORS[0], "scale": BOSS_LV_BU_ATTACK_1_FRAME_SCALES[0], "weapon_tip": BOSS_LV_BU_ATTACK_1_WEAPON_TIPS[0]}
	if boss.state in [BossActor.State.WINDUP, BossActor.State.DASH, BossActor.State.RECOVER]:
		return _lv_bu_attack_frame_data(boss.current_action, boss.attack_animation_progress())
	if boss.is_moving():
		var walk_frame := int(visual_time / BOSS_LV_BU_WALK_FRAME_DURATION) % BOSS_LV_BU_WALK_TEXTURES.size()
		return {"texture": BOSS_LV_BU_WALK_TEXTURES[walk_frame], "anchor": BOSS_LV_BU_WALK_FOOT_ANCHORS[walk_frame], "scale": 1.0, "weapon_tip": BOSS_LV_BU_DEFAULT_WEAPON_TIP}
	var idle_frame := int(visual_time / BOSS_LV_BU_IDLE_FRAME_DURATION) % BOSS_LV_BU_IDLE_TEXTURES.size()
	return {"texture": BOSS_LV_BU_IDLE_TEXTURES[idle_frame], "anchor": BOSS_LV_BU_IDLE_FOOT_ANCHORS[idle_frame], "scale": 1.0, "weapon_tip": BOSS_LV_BU_DEFAULT_WEAPON_TIP}

func _lv_bu_attack_frame_data(action: String, progress: float) -> Dictionary:
	var textures: Array = BOSS_LV_BU_ATTACK_1_TEXTURES
	var anchors: Array = BOSS_LV_BU_ATTACK_1_FOOT_ANCHORS
	var scales: Array = BOSS_LV_BU_ATTACK_1_FRAME_SCALES
	var weapon_tips: Array = BOSS_LV_BU_ATTACK_1_WEAPON_TIPS
	if action in ["lvbu_sweep", "lvbu_slow_sweep"]:
		textures = BOSS_LV_BU_ATTACK_2_TEXTURES
		anchors = BOSS_LV_BU_ATTACK_2_FOOT_ANCHORS
		scales = BOSS_LV_BU_ATTACK_2_FRAME_SCALES
		weapon_tips = BOSS_LV_BU_ATTACK_2_WEAPON_TIPS
	elif action in ["lvbu_whirl", "lvbu_glaive_return", "lvbu_rush"]:
		textures = BOSS_LV_BU_ATTACK_3_TEXTURES
		anchors = BOSS_LV_BU_ATTACK_3_FOOT_ANCHORS
		scales = BOSS_LV_BU_ATTACK_3_FRAME_SCALES
		weapon_tips = BOSS_LV_BU_ATTACK_3_WEAPON_TIPS
	var frame_index := mini(int(clampf(progress, 0.0, 1.0) * textures.size()), textures.size() - 1)
	return {"texture": textures[frame_index], "anchor": anchors[frame_index], "scale": scales[frame_index], "weapon_tip": weapon_tips[frame_index]}

func _xiahou_dun_frame_data() -> Dictionary:
	if boss.is_knockback_visual_active():
		return {"texture": BOSS_XIAHOU_DUN_ATTACK_1_TEXTURES[0], "anchor": BOSS_XIAHOU_DUN_ATTACK_1_FOOT_ANCHORS[0]}
	# Keep dash attacks on their attack sequence even while the actor is moving.
	if boss.state in [BossActor.State.WINDUP, BossActor.State.DASH, BossActor.State.RECOVER]:
		return _xiahou_dun_attack_frame_data(boss.current_action, boss.attack_animation_progress())
	if boss.is_moving():
		var walk_frame := int(visual_time / BOSS_XIAHOU_DUN_WALK_FRAME_DURATION) % BOSS_XIAHOU_DUN_WALK_TEXTURES.size()
		return {"texture": BOSS_XIAHOU_DUN_WALK_TEXTURES[walk_frame], "anchor": BOSS_XIAHOU_DUN_WALK_FOOT_ANCHORS[walk_frame]}
	var idle_frame := int(visual_time / BOSS_XIAHOU_DUN_IDLE_FRAME_DURATION) % BOSS_XIAHOU_DUN_IDLE_TEXTURES.size()
	return {"texture": BOSS_XIAHOU_DUN_IDLE_TEXTURES[idle_frame], "anchor": BOSS_XIAHOU_DUN_IDLE_FOOT_ANCHORS[idle_frame]}

func _xiahou_dun_attack_frame_data(action: String, progress: float) -> Dictionary:
	var sequence: Array = BOSS_XIAHOU_DUN_ACTION_2_SEQUENCE
	if action == "command_thrust":
		sequence = BOSS_XIAHOU_DUN_ACTION_1_SEQUENCE
	elif action == "fire_charge":
		sequence = BOSS_XIAHOU_DUN_ACTION_3_SEQUENCE
	elif action == "fire_lines":
		sequence = BOSS_XIAHOU_DUN_ACTION_34_SEQUENCE
	var total_frames := 0
	for segment in sequence:
		total_frames += (segment["textures"] as Array).size()
	var frame_index := mini(int(clampf(progress, 0.0, 1.0) * total_frames), total_frames - 1)
	for segment in sequence:
		var textures: Array = segment["textures"]
		var anchors: Array = segment["anchors"]
		if frame_index < textures.size():
			return {"texture": textures[frame_index], "anchor": anchors[frame_index]}
		frame_index -= textures.size()
	return {"texture": BOSS_XIAHOU_DUN_IDLE_TEXTURES[0], "anchor": BOSS_XIAHOU_DUN_IDLE_FOOT_ANCHORS[0]}

func _boss_attack_texture(action: String, progress: float) -> Texture2D:
	var sequence := BOSS_ZHANG_HE_SWEEP_SEQUENCE
	if action in ["thrust", "pursuit"]:
		sequence = BOSS_ZHANG_HE_THRUST_SEQUENCE
	elif action in ["spear_wall", "summon"]:
		sequence = BOSS_ZHANG_HE_SUPPORT_SEQUENCE
	elif action in ["three_thrust", "whirl"]:
		sequence = BOSS_ZHANG_HE_WHIRL_SEQUENCE
	var frame_index := mini(int(clampf(progress, 0.0, 1.0) * sequence.size()), sequence.size() - 1)
	return BOSS_ZHANG_HE_ATTACK_TEXTURES[int(sequence[frame_index])]

func _draw_elites() -> void:
	for elite in elites:
		if not is_instance_valid(elite) or (not elite.active and not elite.is_dying()):
			continue
		var at := elite.position + elite.knockback_visual_offset() if elite.is_knockback_visual_active() else elite.position
		var direction := elite.current_direction if elite.current_direction.length_squared() > 0.01 else Vector2.DOWN
		_draw_ground_shadow(at + Vector2(0, 21), 33.0, 9.2, Color(0.0, 0.0, 0.0, 0.34))
		if elite.is_dying():
			_draw_elite_death_sprite(elite, at, direction)
			continue
		_draw_elite_aura(elite, at, direction)
		if elite.is_cast_invulnerable():
			_draw_cast_invulnerability_marker(at, direction, 0.82, elite.current_action)
		if elite.is_knockback_visual_active():
			_draw_elite_knockback_pose(elite, at, direction)
		else:
			match elite.archetype:
				EliteActor.Archetype.XIAHOU_EN:
					_draw_xiahou_en_sprite(elite, at, direction)
				EliteActor.Archetype.CHUNYU_DAO:
					_draw_chunyu_dao_sprite(elite, at, direction)
				EliteActor.Archetype.XIAHOU_LAN:
					_draw_xiahou_lan_proxy(elite, at, direction)
				EliteActor.Archetype.HAN_HAO:
					_draw_han_hao_proxy(elite, at, direction)
		_draw_elite_attack_vfx(elite, at, direction)
		_draw_elite_command_marker(at)
		if elite.is_stance_broken():
			_draw_named_stance_break_marker(at, 0.82)

func _draw_elite_knockback_pose(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var hurt_ratio := clampf(elite.hurt_remaining / 0.14, 0.0, 1.0)
	var recoil_wave := sin(elite.knockback_visual_progress() * PI)
	var recoil_strength := elite.knockback_visual_strength()
	if elite.archetype == EliteActor.Archetype.XIAHOU_EN:
		var xiahou_scale := -ELITE_XIAHOU_EN_SPRITE_SCALE if direction.x < -0.05 else ELITE_XIAHOU_EN_SPRITE_SCALE
		var xiahou_tilt := (0.09 + recoil_wave * 0.16 * recoil_strength) * (-1.0 if direction.x < 0.0 else 1.0)
		_draw_named_sprite(ELITE_XIAHOU_EN_DEATH_TEXTURES[0], ELITE_XIAHOU_EN_SOURCE_FOOT_ANCHOR, at + Vector2(0, 14), xiahou_scale * (1.0 + recoil_wave * 0.10 * recoil_strength), ELITE_XIAHOU_EN_SPRITE_SCALE * (1.0 - recoil_wave * 0.06 * recoil_strength), Color.WHITE.lerp(Color("c4e4ef"), hurt_ratio * 0.45), Color("4c2018", 0.90), 1.35, xiahou_tilt)
		return
	if elite.archetype == EliteActor.Archetype.CHUNYU_DAO:
		var chunyu_scale := -ELITE_CHUNYU_DAO_SPRITE_SCALE if direction.x < -0.05 else ELITE_CHUNYU_DAO_SPRITE_SCALE
		var chunyu_tilt := (0.10 + recoil_wave * 0.18 * recoil_strength) * (-1.0 if direction.x < 0.0 else 1.0)
		_draw_named_sprite(ELITE_CHUNYU_DAO_DEATH_TEXTURES[0], ELITE_CHUNYU_DAO_DEATH_FOOT_ANCHORS[0], at + Vector2(0, 14), chunyu_scale * (1.0 + recoil_wave * 0.10 * recoil_strength), ELITE_CHUNYU_DAO_SPRITE_SCALE * (1.0 - recoil_wave * 0.06 * recoil_strength), Color.WHITE.lerp(Color("f3d0b0"), hurt_ratio * 0.45), Color("4c3717", 0.90), 1.35, chunyu_tilt)
		return
	var tilt := (0.10 + recoil_wave * 0.16 * recoil_strength) * (-1.0 if direction.x < 0.0 else 1.0)
	if elite.archetype == EliteActor.Archetype.XIAHOU_LAN:
		_draw_xiahou_lan_proxy(elite, at, direction, tilt)
	else:
		_draw_han_hao_proxy(elite, at, direction, tilt)

func _draw_xiahou_en_sprite(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var idle_frame := int(visual_time / ELITE_XIAHOU_EN_IDLE_FRAME_DURATION) % ELITE_XIAHOU_EN_IDLE_TEXTURES.size()
	var texture: Texture2D = ELITE_XIAHOU_EN_IDLE_TEXTURES[idle_frame]
	if elite.is_moving():
		var walk_frame := int(visual_time / ELITE_XIAHOU_EN_WALK_FRAME_DURATION) % ELITE_XIAHOU_EN_WALK_TEXTURES.size()
		texture = ELITE_XIAHOU_EN_WALK_TEXTURES[walk_frame]
	elif elite.state == EliteActor.State.WINDUP:
		var attack_frame := mini(int(elite.attack_animation_progress() * ELITE_XIAHOU_EN_ATTACK_TEXTURES.size()), ELITE_XIAHOU_EN_ATTACK_TEXTURES.size() - 1)
		texture = ELITE_XIAHOU_EN_ATTACK_TEXTURES[attack_frame]
	elif elite.state == EliteActor.State.RECOVER:
		texture = ELITE_XIAHOU_EN_ATTACK_TEXTURES[ELITE_XIAHOU_EN_ATTACK_TEXTURES.size() - 1]
	var hurt_ratio := clampf(elite.hurt_remaining / 0.14, 0.0, 1.0)
	var facing_scale := -ELITE_XIAHOU_EN_SPRITE_SCALE if direction.x < -0.05 else ELITE_XIAHOU_EN_SPRITE_SCALE
	var hurt_color := Color.WHITE.lerp(Color(0.72, 0.90, 1.0), hurt_ratio * 0.72)
	_draw_named_sprite(texture, ELITE_XIAHOU_EN_SOURCE_FOOT_ANCHOR, at + Vector2(0, 14), facing_scale * (1.0 + hurt_ratio * 0.08), ELITE_XIAHOU_EN_SPRITE_SCALE * (1.0 - hurt_ratio * 0.05), hurt_color, Color("4c2018", 0.90), 1.35)

func _draw_chunyu_dao_sprite(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var idle_frame := int(visual_time / ELITE_CHUNYU_DAO_IDLE_FRAME_DURATION) % ELITE_CHUNYU_DAO_IDLE_TEXTURES.size()
	var texture: Texture2D = ELITE_CHUNYU_DAO_IDLE_TEXTURES[idle_frame]
	var foot_anchor: Vector2 = ELITE_CHUNYU_DAO_IDLE_FOOT_ANCHORS[idle_frame]
	if elite.is_moving():
		var walk_frame := int(visual_time / ELITE_CHUNYU_DAO_WALK_FRAME_DURATION) % ELITE_CHUNYU_DAO_WALK_TEXTURES.size()
		texture = ELITE_CHUNYU_DAO_WALK_TEXTURES[walk_frame]
		foot_anchor = ELITE_CHUNYU_DAO_WALK_FOOT_ANCHORS[walk_frame]
	elif elite.state == EliteActor.State.WINDUP:
		var attack_frame := mini(int(elite.attack_animation_progress() * ELITE_CHUNYU_DAO_ATTACK_TEXTURES.size()), ELITE_CHUNYU_DAO_ATTACK_TEXTURES.size() - 1)
		texture = ELITE_CHUNYU_DAO_ATTACK_TEXTURES[attack_frame]
		foot_anchor = ELITE_CHUNYU_DAO_ATTACK_FOOT_ANCHORS[attack_frame]
	elif elite.state == EliteActor.State.RECOVER:
		texture = ELITE_CHUNYU_DAO_ATTACK_TEXTURES[ELITE_CHUNYU_DAO_ATTACK_TEXTURES.size() - 1]
		foot_anchor = ELITE_CHUNYU_DAO_ATTACK_FOOT_ANCHORS[ELITE_CHUNYU_DAO_ATTACK_FOOT_ANCHORS.size() - 1]
	var hurt_ratio := clampf(elite.hurt_remaining / 0.14, 0.0, 1.0)
	var facing_scale := -ELITE_CHUNYU_DAO_SPRITE_SCALE if direction.x < -0.05 else ELITE_CHUNYU_DAO_SPRITE_SCALE
	var hurt_color := Color.WHITE.lerp(Color(0.98, 0.78, 0.58), hurt_ratio * 0.72)
	_draw_named_sprite(texture, foot_anchor, at + Vector2(0, 14), facing_scale * (1.0 + hurt_ratio * 0.08), ELITE_CHUNYU_DAO_SPRITE_SCALE * (1.0 - hurt_ratio * 0.05), hurt_color, Color("4c3717", 0.90), 1.35)

func _draw_xiahou_lan_proxy(elite: EliteActor, at: Vector2, direction: Vector2, recoil_tilt: float = 0.0) -> void:
	var facing := -1.0 if direction.x < -0.05 else 1.0
	var hurt_ratio := clampf(elite.hurt_remaining / 0.14, 0.0, 1.0)
	var step := sin(visual_time * 10.0) * 2.0 if elite.is_moving() else 0.0
	var attack_lean := 5.0 * facing if elite.state == EliteActor.State.WINDUP else 0.0
	draw_set_transform(at + Vector2(attack_lean, step + 5.0), recoil_tilt, Vector2(1.12 + hurt_ratio * 0.06, 1.12 - hurt_ratio * 0.04))
	draw_rect(Rect2(-14.0, 8.0, 10.0, 17.0), Color("2e2930"))
	draw_rect(Rect2(4.0, 8.0, 10.0, 17.0), Color("2e2930"))
	draw_rect(Rect2(-18.0, -20.0, 36.0, 31.0), Color("71433a"))
	draw_rect(Rect2(-14.0, -17.0, 28.0, 20.0), Color("a45d42"))
	draw_circle(Vector2(0.0, -28.0), 10.5, Color.WHITE.lerp(Color("d7b596"), 1.0 - hurt_ratio))
	draw_rect(Rect2(-12.0, -37.0, 24.0, 8.0), Color("435263"))
	var spear_root := Vector2(8.0 * facing, -1.0)
	var spear_tip := spear_root + Vector2(56.0 * facing, -34.0)
	draw_line(spear_root, spear_tip, Color("9b6b42"), 3.4)
	draw_line(spear_tip - Vector2(9.0 * facing, -5.0), spear_tip + Vector2(14.0 * facing, -10.0), Color("e6e2d4"), 2.6)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_han_hao_proxy(elite: EliteActor, at: Vector2, direction: Vector2, recoil_tilt: float = 0.0) -> void:
	var facing := -1.0 if direction.x < -0.05 else 1.0
	var hurt_ratio := clampf(elite.hurt_remaining / 0.14, 0.0, 1.0)
	var push := 5.0 * facing if elite.state in [EliteActor.State.WINDUP, EliteActor.State.DASH] else 0.0
	draw_set_transform(at + Vector2(push, 5.0), recoil_tilt, Vector2(1.12 + hurt_ratio * 0.06, 1.12 - hurt_ratio * 0.04))
	draw_rect(Rect2(-17.0, 7.0, 13.0, 19.0), Color("27252a"))
	draw_rect(Rect2(4.0, 7.0, 13.0, 19.0), Color("27252a"))
	draw_rect(Rect2(-21.0, -22.0, 42.0, 34.0), Color("432d2c"))
	draw_rect(Rect2(-17.0, -19.0, 34.0, 25.0), Color("7b5344"))
	draw_circle(Vector2(0.0, -29.0), 11.5, Color.WHITE.lerp(Color("d7b596"), 1.0 - hurt_ratio))
	draw_rect(Rect2(-14.0, -39.0, 28.0, 9.0), Color("6c4735"))
	var shield_center := Vector2(18.0 * facing, -7.0)
	draw_circle(shield_center, 18.0, Color("27343a"))
	draw_arc(shield_center, 18.0, 0.0, TAU, 12, Color("d2b26d"), 2.6)
	draw_line(Vector2(-4.0 * facing, 3.0), Vector2(32.0 * facing, -26.0), Color("d6d3c6"), 4.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_named_sprite(texture: Texture2D, source_anchor: Vector2, foot_position: Vector2, scale_x: float, scale_y: float, color: Color, outline_color: Color, outline_width: float, rotation: float = 0.0) -> void:
	# Named enemies already have dedicated status bars, ground auras, and command
	# markers. A second silhouette outline makes small source frames look muddy.
	var applied_outline_width := minf(outline_width, NAMED_SPRITE_OUTLINE_WIDTH)
	if applied_outline_width > 0.0 and outline_color.a > 0.0:
		for offset in [Vector2(-applied_outline_width, 0.0), Vector2(applied_outline_width, 0.0), Vector2(0.0, -applied_outline_width), Vector2(0.0, applied_outline_width), Vector2(-applied_outline_width, -applied_outline_width), Vector2(applied_outline_width, -applied_outline_width), Vector2(-applied_outline_width, applied_outline_width), Vector2(applied_outline_width, applied_outline_width)]:
			draw_set_transform(foot_position + offset, rotation, Vector2(scale_x, scale_y))
			draw_texture(texture, -source_anchor, outline_color)
	draw_set_transform(foot_position, rotation, Vector2(scale_x, scale_y))
	draw_texture(texture, -source_anchor, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_elite_death_sprite(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var progress := elite.death_animation_progress()
	if elite.archetype == EliteActor.Archetype.XIAHOU_LAN or elite.archetype == EliteActor.Archetype.HAN_HAO:
		_draw_elite_proxy_death(elite.archetype, at, direction, progress)
		return
	if elite.archetype == EliteActor.Archetype.XIAHOU_EN:
		var xiahou_frame := mini(int(progress * ELITE_XIAHOU_EN_DEATH_TEXTURES.size()), ELITE_XIAHOU_EN_DEATH_TEXTURES.size() - 1)
		var xiahou_facing_scale := -ELITE_XIAHOU_EN_SPRITE_SCALE if direction.x < -0.05 else ELITE_XIAHOU_EN_SPRITE_SCALE
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(xiahou_facing_scale, ELITE_XIAHOU_EN_SPRITE_SCALE))
		draw_texture(ELITE_XIAHOU_EN_DEATH_TEXTURES[xiahou_frame], -ELITE_XIAHOU_EN_SOURCE_FOOT_ANCHOR, Color(0.82, 0.84, 0.86))
	else:
		var chunyu_frame := mini(int(progress * ELITE_CHUNYU_DAO_DEATH_TEXTURES.size()), ELITE_CHUNYU_DAO_DEATH_TEXTURES.size() - 1)
		var chunyu_facing_scale := -ELITE_CHUNYU_DAO_SPRITE_SCALE if direction.x < -0.05 else ELITE_CHUNYU_DAO_SPRITE_SCALE
		draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(chunyu_facing_scale, ELITE_CHUNYU_DAO_SPRITE_SCALE))
		draw_texture(ELITE_CHUNYU_DAO_DEATH_TEXTURES[chunyu_frame], -ELITE_CHUNYU_DAO_DEATH_FOOT_ANCHORS[chunyu_frame], Color(0.88, 0.76, 0.62))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_elite_proxy_death(archetype: EliteActor.Archetype, at: Vector2, direction: Vector2, progress: float) -> void:
	var tilt := -0.48 if direction.x >= 0.0 else 0.48
	var fade := 1.0 - progress * 0.38
	var armor_color := Color(0.42, 0.25, 0.21, fade) if archetype == EliteActor.Archetype.XIAHOU_LAN else Color(0.32, 0.27, 0.23, fade)
	draw_set_transform(at + Vector2(0.0, 16.0), tilt, Vector2(1.12, 1.12))
	draw_rect(Rect2(-23.0, -12.0, 46.0, 22.0), armor_color)
	draw_circle(Vector2(-15.0, -15.0), 10.0, Color(0.70, 0.59, 0.48, fade))
	if archetype == EliteActor.Archetype.XIAHOU_LAN:
		draw_line(Vector2(7.0, 1.0), Vector2(56.0, -25.0), Color(0.66, 0.62, 0.52, fade), 3.0)
	else:
		draw_circle(Vector2(21.0, -5.0), 13.0, Color(0.24, 0.29, 0.30, fade))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_elite_corpses() -> void:
	for corpse in elite_corpses:
		var at: Vector2 = corpse.get("position", Vector2.ZERO)
		var direction: Vector2 = corpse.get("direction", Vector2.DOWN)
		var archetype := int(corpse.get("archetype", EliteActor.Archetype.XIAHOU_EN))
		_draw_ground_shadow(at + Vector2(0, 22), 34.0, 9.2, Color(0.0, 0.0, 0.0, 0.28))
		if archetype == EliteActor.Archetype.XIAHOU_LAN or archetype == EliteActor.Archetype.HAN_HAO:
			_draw_elite_proxy_death(archetype, at, direction, 0.28)
			continue
		if archetype == EliteActor.Archetype.XIAHOU_EN:
			var xiahou_facing_scale := -ELITE_XIAHOU_EN_SPRITE_SCALE if direction.x < -0.05 else ELITE_XIAHOU_EN_SPRITE_SCALE
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(xiahou_facing_scale, ELITE_XIAHOU_EN_SPRITE_SCALE))
			draw_texture(ELITE_XIAHOU_EN_DEATH_TEXTURES[ELITE_XIAHOU_EN_DEATH_TEXTURES.size() - 1], -ELITE_XIAHOU_EN_SOURCE_FOOT_ANCHOR, Color(0.70, 0.70, 0.66, 0.90))
		else:
			var chunyu_facing_scale := -ELITE_CHUNYU_DAO_SPRITE_SCALE if direction.x < -0.05 else ELITE_CHUNYU_DAO_SPRITE_SCALE
			draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(chunyu_facing_scale, ELITE_CHUNYU_DAO_SPRITE_SCALE))
			draw_texture(ELITE_CHUNYU_DAO_DEATH_TEXTURES[ELITE_CHUNYU_DAO_DEATH_TEXTURES.size() - 1], -ELITE_CHUNYU_DAO_DEATH_FOOT_ANCHORS[ELITE_CHUNYU_DAO_DEATH_FOOT_ANCHORS.size() - 1], Color(0.72, 0.64, 0.54, 0.90))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_elite_aura(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var ground := at + Vector2(0, 20)
	var pulse := 0.74 + 0.20 * (sin(visual_time * 3.4) + 1.0) * 0.5
	var action_boost := 1.18 if elite.state == EliteActor.State.WINDUP else 1.0
	var color := Color("f3a842")
	match elite.archetype:
		EliteActor.Archetype.CHUNYU_DAO:
			color = Color("f5be54")
		EliteActor.Archetype.XIAHOU_LAN:
			color = Color("e9b34d")
		EliteActor.Archetype.HAN_HAO:
			color = Color("e57b4b")
	var rotation := visual_time * 0.72
	var ellipse_radius := Vector2(41.0, 13.0)
	for index in range(4):
		var start_angle := rotation + TAU * float(index) / 4.0 + 0.10
		var end_angle := start_angle + 0.92
		var radius := ellipse_radius + Vector2(float(index % 2) * 2.4, float(index % 2) * 0.8)
		_draw_ellipse_arc(ground, radius, start_angle, end_angle, 7, Color(color.r, color.g, color.b, pulse * action_boost), 2.4)
		var tick_angle := start_angle + 0.46
		var tick_root := _ellipse_point(ground, radius - Vector2(2.2, 0.8), tick_angle)
		var tick_tip := _ellipse_point(ground, radius + Vector2(3.6, 1.3), tick_angle)
		draw_line(tick_root, tick_tip, Color(1.0, 0.88, 0.60, pulse * 0.82), 1.3)
	if elite.is_recovering():
		for index in range(3):
			var mark_angle := visual_time * 2.0 + TAU * float(index) / 3.0
			var mark_start := _ellipse_point(ground, Vector2(27.0, 8.5), mark_angle)
			var mark_end := _ellipse_point(ground, Vector2(36.0, 12.0), mark_angle)
			draw_line(mark_start, mark_end, Color("ffd16c"), 2.0)

func _draw_ellipse_arc(center: Vector2, radius: Vector2, start_angle: float, end_angle: float, segments: int, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for step in range(segments + 1):
		var progress := float(step) / float(segments)
		points.append(_ellipse_point(center, radius, lerpf(start_angle, end_angle, progress)))
	draw_polyline(points, color, width, true)

func _ellipse_point(center: Vector2, radius: Vector2, angle: float) -> Vector2:
	return center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y)

func _draw_elite_command_marker(at: Vector2) -> void:
	_draw_named_command_marker(at + Vector2(0, -66.0 + sin(visual_time * 3.2) * 1.2), "将", Color("e79a36"), 14.0, 16)

func _draw_boss_command_marker(at: Vector2) -> void:
	_draw_named_command_marker(at + Vector2(0, -72.0 + sin(visual_time * 2.8) * 1.4), "帅", Color("b489e7"), 16.0, 18)

func _draw_named_command_marker(center: Vector2, label: String, fill_color: Color, radius: float, font_size: int) -> void:
	var outer := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
	])
	var inner_radius := radius - 3.0
	var inner := PackedVector2Array([
		center + Vector2(0, -inner_radius),
		center + Vector2(inner_radius, 0),
		center + Vector2(0, inner_radius),
		center + Vector2(-inner_radius, 0),
	])
	draw_colored_polygon(outer, Color(0.19, 0.10, 0.05, 0.94))
	draw_colored_polygon(inner, fill_color)
	draw_string(ThemeDB.fallback_font, center + Vector2(-radius * 0.56, font_size * 0.36), label, HORIZONTAL_ALIGNMENT_LEFT, radius * 1.12, font_size, Color("fff0c2"))

func _draw_elite_body(elite: EliteActor, at: Vector2) -> void:
	var body_color := elite.hud_color().lerp(Color.WHITE, elite.hurt_remaining / 0.14 * 0.72)
	var armor_color := Color("332d30") if elite.archetype == EliteActor.Archetype.XIAHOU_EN else Color("45352a")
	var outline_color := Color("8d332d") if elite.archetype == EliteActor.Archetype.XIAHOU_EN else Color("89602d")
	draw_set_transform(at, 0.0, Vector2(1.05, 1.05))
	draw_rect(Rect2(-20, -25, 40, 48), outline_color)
	draw_rect(Rect2(-17, -22, 34, 42), armor_color)
	draw_rect(Rect2(-21, -8, 42, 21), body_color)
	draw_circle(Vector2(0, -31), 12.0, Color("dec8af"))
	if elite.archetype == EliteActor.Archetype.XIAHOU_EN:
		draw_line(Vector2(9, 12), Vector2(48, -42), Color("d9d5ca"), 5.0)
		draw_line(Vector2(41, -36), Vector2(56, -47), Color("ebe2c7"), 4.0)
	else:
		draw_line(Vector2(8, 9), Vector2(42, -29), Color("c7c1b4"), 8.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_boss_aura(at: Vector2, direction: Vector2) -> void:
	var perpendicular := Vector2(-direction.y, direction.x)
	var windup_boost: float = 1.38 if boss.state == BossActor.State.WINDUP else 1.0
	var phase_boost := 0.72 + float(boss.phase - 1) * 0.16
	var aura_color := Color(0.62, 0.49, 0.94)
	var spark_color := Color(0.82, 0.71, 0.38)
	if boss.archetype == BossActor.Archetype.XIAHOU_DUN:
		aura_color = Color(0.76, 0.29, 0.16)
		spark_color = Color(1.0, 0.70, 0.30)
	elif boss.archetype == BossActor.Archetype.LV_BU:
		aura_color = Color(0.78, 0.12, 0.16)
		spark_color = Color(1.0, 0.74, 0.30)
	var ground := at + Vector2(0, 20)
	var pulse := 0.66 + 0.20 * (sin(visual_time * 2.8) + 1.0) * 0.5
	for index in range(4):
		var start_angle := -visual_time * 0.56 + TAU * float(index) / 4.0 + 0.12
		var end_angle := start_angle + 0.84
		var radius := Vector2(46.0 + float(index % 2) * 2.5, 14.0 + float(index % 2) * 0.8)
		_draw_ellipse_arc(ground, radius, start_angle, end_angle, 7, Color(aura_color.r, aura_color.g, aura_color.b, pulse * windup_boost), 2.6)
	for index in range(7):
		var side := -1.0 if index % 2 == 0 else 1.0
		var offset := 8.0 + float(index) * 5.0
		var flutter := sin(visual_time * 4.2 + float(index) * 0.92) * 4.0
		var root := at - direction * (4.0 + float(index) * 1.6) + perpendicular * (side * offset + flutter) + Vector2(0, -24)
		var tip := root - direction * (15.0 + float(index) * 3.3) + perpendicular * side * (3.0 + float(index) * 0.5)
		var color := Color(aura_color.r * 0.78, aura_color.g * 0.78, aura_color.b * 0.78, phase_boost * windup_boost * (0.32 + float(index) * 0.035))
		draw_line(root, tip, color, 2.0)
		if index % 2 == 0:
			draw_line(tip, tip - direction * 5.0, Color(spark_color.r, spark_color.g, spark_color.b, color.a * 0.82), 1.2)

func _draw_cast_invulnerability_marker(at: Vector2, direction: Vector2, scale: float, action: String) -> void:
	var center := at + Vector2(0.0, -28.0 * scale)
	var pulse := 0.72 + 0.22 * (sin(visual_time * 9.0) + 1.0) * 0.5
	var color := Color("7bd8ff")
	var accent := Color("d9f5ff")
	if action in ["oil_fire", "fire_lines", "fire_charge"]:
		color = Color("f08b45")
		accent = Color("ffe0a3")
	elif action in ["earth_blade", "arrow_rain", "spear_wall", "three_thrust"]:
		color = Color("a9b8ff")
		accent = Color("e5e9ff")
	var radius := (25.0 + sin(visual_time * 6.0) * 2.0) * scale
	var shield := PackedVector2Array([
		center + Vector2(0.0, -radius),
		center + Vector2(radius * 0.78, -radius * 0.30),
		center + Vector2(radius * 0.62, radius * 0.66),
		center + Vector2(0.0, radius),
		center + Vector2(-radius * 0.62, radius * 0.66),
		center + Vector2(-radius * 0.78, -radius * 0.30),
		center + Vector2(0.0, -radius),
	])
	draw_polyline(shield, Color(color.r, color.g, color.b, pulse * 0.86), 2.4 * scale, false)
	for index in range(4):
		var angle := visual_time * 1.7 + TAU * float(index) / 4.0
		var orbit := center + Vector2.from_angle(angle) * (radius + 7.0 * scale)
		var pixel := _pixel_snap(orbit)
		draw_rect(Rect2(pixel - Vector2(3.0, 3.0) * scale, Vector2(6.0, 6.0) * scale), Color(accent.r, accent.g, accent.b, pulse * 0.82))
	var lock_center := center + Vector2(0.0, 1.0 * scale)
	draw_rect(Rect2(lock_center - Vector2(5.0, 2.0) * scale, Vector2(10.0, 8.0) * scale), Color(color.r, color.g, color.b, pulse * 0.64))
	draw_arc(lock_center + Vector2(0.0, -2.0) * scale, 4.0 * scale, PI, TAU, 8, Color(accent.r, accent.g, accent.b, pulse * 0.88), 1.8 * scale)
	draw_string(ThemeDB.fallback_font, at + Vector2(-22.0 * scale, -58.0 * scale), "免伤施法", HORIZONTAL_ALIGNMENT_LEFT, -1, int(12.0 * scale), Color(accent.r, accent.g, accent.b, pulse * 0.90))

func _draw_elite_attack_vfx(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	if elite.state not in [EliteActor.State.WINDUP, EliteActor.State.DASH, EliteActor.State.RECOVER]:
		return
	var progress := elite.attack_animation_progress() if elite.state == EliteActor.State.WINDUP else 1.0
	var alpha := _elite_attack_vfx_alpha(elite)
	if alpha <= 0.01:
		return
	var facing := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	match elite.archetype:
		EliteActor.Archetype.XIAHOU_EN:
			match elite.current_action:
				"sweep":
					_draw_named_sweep_vfx(at + facing * 6.0, facing, 176.0, deg_to_rad(76.0), progress, alpha, Color("f3e5bf"), Color("d99a3b"), 14.0, 5)
				"drag":
					_draw_named_sweep_vfx(at + facing * 12.0, facing, 194.0, deg_to_rad(66.0), progress, alpha, Color("fff0c7"), Color("d77a32"), 20.0, 7)
					_draw_named_ground_dust(at, facing, alpha * 0.58, 6, 32.0)
				"lunge":
					_draw_named_thrust_vfx(at + Vector2(0, -10), facing, 236.0, progress, alpha, Color("fff1c9"), Color("d77835"), 10.0)
					_draw_named_dash_vfx(at, facing, alpha, Color("d47d3d"), 3)
		EliteActor.Archetype.CHUNYU_DAO:
			match elite.current_action:
				"crush":
					_draw_named_sweep_vfx(at + facing * 8.0, facing, 226.0, deg_to_rad(34.0), progress, alpha, Color("ffd49a"), Color("c95d32"), 24.0, 3)
					_draw_named_ground_dust(at + facing * 54.0, facing, alpha * 0.72, 8, 46.0)
				"execute":
					_draw_named_sweep_vfx(at + facing * 6.0, facing.rotated(-0.16), 138.0, deg_to_rad(48.0), progress, alpha, Color("ffe2a8"), Color("d75f33"), 16.0, 3)
					_draw_named_sweep_vfx(at + facing * 10.0, facing.rotated(0.18), 148.0, deg_to_rad(42.0), progress * 0.88 + 0.12, alpha * 0.74, Color("fff0c4"), Color("bd4b2e"), 12.0, 3)
				"rupture":
					_draw_named_thrust_vfx(at + Vector2(0, -8), facing, 280.0, progress, alpha, Color("ffe0a1"), Color("c75134"), 16.0)
					_draw_named_dash_vfx(at, facing, alpha, Color("a94a30"), 4)
					_draw_named_ground_dust(at, facing, alpha * 0.62, 7, 38.0)

func _elite_attack_vfx_alpha(elite: EliteActor) -> float:
	match elite.state:
		EliteActor.State.WINDUP:
			return clampf((elite.attack_animation_progress() - 0.10) * 1.18, 0.0, 1.0)
		EliteActor.State.DASH:
			return 0.92
		EliteActor.State.RECOVER:
			return clampf(elite.state_timer / 0.74, 0.0, 0.72)
	return 0.0

func _draw_zhang_he_attack_vfx(at: Vector2, direction: Vector2) -> void:
	if boss.state not in [BossActor.State.WINDUP, BossActor.State.DASH, BossActor.State.RECOVER]:
		return
	var progress := boss.attack_animation_progress() if boss.state == BossActor.State.WINDUP else 1.0
	var alpha := _zhang_he_attack_vfx_alpha()
	if alpha <= 0.01:
		return
	var facing := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	var phase_scale := 1.0 + float(boss.phase - 1) * 0.12
	var steel := Color("c8efff")
	var azure := Color("5ab8ed")
	match boss.current_action:
		"sweep":
			_draw_named_sweep_vfx(at + facing * 8.0, facing, 164.0 * phase_scale, deg_to_rad(60.0), progress, alpha, steel, azure, 15.0, 4)
		"thrust":
			_draw_named_thrust_vfx(at + Vector2(0, -11), facing, 310.0 * phase_scale, progress, alpha, steel, azure, 7.0)
		"pursuit":
			_draw_named_thrust_vfx(at + Vector2(0, -11), facing, 238.0 * phase_scale, progress, alpha, Color("e4f7ff"), azure, 10.0)
			_draw_named_dash_vfx(at, facing, alpha, Color("70c8f2"), 4)
		"spear_wall":
			_draw_named_spear_wall_vfx(at, facing, 240.0 * phase_scale, progress, alpha, steel, azure)
		"whirl":
			_draw_named_whirl_vfx(at, facing, progress, alpha, steel, azure)
		"three_thrust":
			_draw_named_triple_thrust_vfx(at + Vector2(0, -10), facing, 302.0 * phase_scale, progress, alpha, steel, azure)
		"summon":
			_draw_named_summon_vfx(at, progress, alpha, Color("b2dfff"), Color("755ad0"))

func _draw_lv_bu_attack_vfx(at: Vector2, direction: Vector2) -> void:
	if boss.state not in [BossActor.State.WINDUP, BossActor.State.DASH, BossActor.State.RECOVER]:
		return
	var progress := boss.attack_animation_progress() if boss.state == BossActor.State.WINDUP else 1.0
	var alpha := _lv_bu_attack_vfx_alpha()
	if alpha <= 0.01:
		return
	var facing := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	if boss.current_action == "lvbu_glaive_return" and boss.thrust_sequence.is_empty():
		facing = -facing
	var textures: Array = LV_BU_ATTACK_1_VFX_TEXTURES
	var source_anchor := LV_BU_ATTACK_1_VFX_SOURCE_ANCHOR
	var texture_scale := 0.38
	if boss.current_action in ["lvbu_sweep", "lvbu_slow_sweep", "lvbu_whirl", "lvbu_rush", "lvbu_glaive_return"]:
		textures = LV_BU_ATTACK_2_VFX_TEXTURES
		source_anchor = LV_BU_ATTACK_2_VFX_SOURCE_ANCHOR
		texture_scale = 0.42
	var frame_index := mini(int(clampf(progress, 0.0, 1.0) * textures.size()), textures.size() - 1)
	if boss.state == BossActor.State.WINDUP:
		frame_index = mini(int(boss.action_animation_elapsed / LV_BU_ATTACK_VFX_FRAME_DURATION), textures.size() - 1)
	var frame_data := _lv_bu_frame_data()
	var body_anchor: Vector2 = frame_data.get("anchor", Vector2(64.0, 66.0))
	var source_tip: Vector2 = frame_data.get("weapon_tip", BOSS_LV_BU_DEFAULT_WEAPON_TIP)
	var sprite_scale := BOSS_LV_BU_SPRITE_SCALE * float(frame_data.get("scale", 1.0))
	var sprite_facing_scale := -sprite_scale if direction.x < -0.05 else sprite_scale
	var local_tip := source_tip - body_anchor
	var effect_position := at + Vector2(0.0, 14.0) + Vector2(local_tip.x * sprite_facing_scale, local_tip.y * sprite_scale)
	var effect_alpha := alpha * 0.90
	draw_set_transform(effect_position, facing.angle(), Vector2(texture_scale, texture_scale))
	draw_texture(textures[frame_index], -source_anchor, Color(1.0, 1.0, 1.0, effect_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_lv_bu_rush_trail(at: Vector2, direction: Vector2) -> void:
	if boss.current_action != "lvbu_rush" or boss.state != BossActor.State.DASH:
		return
	var facing := direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	var side := Vector2(-facing.y, facing.x)
	for index in range(3):
		var distance := 22.0 + float(index) * 24.0
		var alpha := 0.34 - float(index) * 0.08
		var root := at - facing * distance
		draw_line(root - side * 8.0, root + facing * 28.0 + side * 8.0, Color(0.88, 0.20, 0.14, alpha), 4.0 - float(index) * 0.7)
		draw_line(root - side * 3.0, root + facing * 22.0 + side * 3.0, Color(1.0, 0.72, 0.30, alpha * 0.84), 1.3)

func _lv_bu_attack_vfx_alpha() -> float:
	match boss.state:
		BossActor.State.WINDUP:
			return clampf((boss.attack_animation_progress() - 0.08) * 1.20, 0.0, 1.0)
		BossActor.State.DASH:
			return 0.96
	return 0.0

func _zhang_he_attack_vfx_alpha() -> float:
	match boss.state:
		BossActor.State.WINDUP:
			return clampf((boss.attack_animation_progress() - 0.08) * 1.16, 0.0, 1.0)
		BossActor.State.DASH:
			return 0.94
		BossActor.State.RECOVER:
			return clampf(boss.state_timer / 0.82, 0.0, 0.70)
	return 0.0

func _draw_named_sweep_vfx(origin: Vector2, direction: Vector2, reach: float, half_angle: float, progress: float, alpha: float, core: Color, edge: Color, thickness: float, segments: int) -> void:
	var swing_progress := clampf((progress - 0.12) * 1.14, 0.0, 1.0)
	var radius := reach * lerpf(0.34, 0.96, swing_progress)
	var start_angle := direction.angle() - half_angle
	var end_angle := direction.angle() + half_angle
	_draw_broken_sweep_band(origin, start_angle, end_angle, radius, thickness, Color(core.r, core.g, core.b, alpha * 0.76), alpha, segments + 3, segments)
	_draw_broken_sweep_band(origin, start_angle + 0.05, end_angle - 0.05, maxf(22.0, radius - thickness * 0.72), thickness * 0.30, Color(edge.r, edge.g, edge.b, alpha * 0.90), alpha, segments + 9, maxi(2, segments - 1))
	var tip_direction := Vector2.from_angle(end_angle)
	_draw_named_impact_star(origin + tip_direction * radius, tip_direction, alpha * swing_progress, core, 4, thickness * 0.38)

func _draw_named_thrust_vfx(origin: Vector2, direction: Vector2, reach: float, progress: float, alpha: float, core: Color, edge: Color, width: float) -> void:
	var thrust_progress := clampf((progress - 0.14) * 1.16, 0.0, 1.0)
	var start := origin + direction * 12.0
	var end := origin + direction * (reach * lerpf(0.20, 0.98, thrust_progress))
	var perpendicular := Vector2(-direction.y, direction.x)
	draw_line(start, end, Color(core.r, core.g, core.b, alpha * 0.34), width)
	draw_line(start + perpendicular * (width * 0.12), end + perpendicular * (width * 0.12), Color(edge.r, edge.g, edge.b, alpha * 0.92), maxf(1.6, width * 0.22))
	draw_line(start - perpendicular * (width * 0.18), end - perpendicular * (width * 0.18), Color(1.0, 1.0, 1.0, alpha * 0.72), maxf(1.2, width * 0.12))
	_draw_named_impact_star(end, direction, alpha * thrust_progress, core, 5, width * 0.62)

func _draw_named_dash_vfx(at: Vector2, direction: Vector2, alpha: float, color: Color, count: int) -> void:
	var perpendicular := Vector2(-direction.y, direction.x)
	for index in range(count):
		var behind := 22.0 + float(index) * 18.0
		var lateral := (float(index % 2) - 0.5) * 10.0
		var start := at - direction * behind + perpendicular * lateral + Vector2(0, -7.0)
		var end := start - direction * (20.0 + float(index) * 5.0)
		draw_line(start, end, Color(color.r, color.g, color.b, alpha * (0.52 - float(index) * 0.10)), 5.0 - float(index) * 0.72)
	_draw_named_ground_dust(at, direction, alpha * 0.48, count + 2, 28.0)

func _draw_named_ground_dust(at: Vector2, direction: Vector2, alpha: float, count: int, spread: float) -> void:
	if alpha <= 0.01:
		return
	var ground := at + Vector2(0, 19.0)
	var perpendicular := Vector2(-direction.y, direction.x)
	for index in range(count):
		var amount := (float(index) + 0.45) / float(count)
		var lateral := (amount - 0.5) * spread * 2.0
		var forward := 8.0 + amount * spread * 0.48
		var center := ground + perpendicular * lateral + direction * forward
		var radius := 2.0 + float(index % 3) * 1.2
		draw_circle(center, radius, Color(0.71, 0.55, 0.34, alpha * (0.38 - amount * 0.17)))

func _draw_named_impact_star(center: Vector2, direction: Vector2, alpha: float, color: Color, rays: int, radius: float) -> void:
	if alpha <= 0.01:
		return
	var base_angle := direction.angle()
	for index in range(rays):
		var angle := base_angle + (float(index) - float(rays - 1) * 0.5) * 0.34
		var ray_direction := Vector2.from_angle(angle)
		draw_line(center - ray_direction * radius * 0.18, center + ray_direction * radius, Color(color.r, color.g, color.b, alpha * (0.74 - float(index % 2) * 0.14)), 1.6)
	draw_circle(center, maxf(1.8, radius * 0.16), Color(1.0, 0.96, 0.78, alpha * 0.88))

func _draw_named_spear_wall_vfx(at: Vector2, direction: Vector2, reach: float, progress: float, alpha: float, core: Color, edge: Color) -> void:
	var perpendicular := Vector2(-direction.y, direction.x)
	for index in range(3):
		var offset := (float(index) - 1.0) * 18.0
		_draw_named_thrust_vfx(at + perpendicular * offset + Vector2(0, -9.0), direction, reach, progress * (0.84 + float(index) * 0.08), alpha * (0.74 + float(index) * 0.08), core, edge, 5.0)

func _draw_named_whirl_vfx(at: Vector2, direction: Vector2, progress: float, alpha: float, core: Color, edge: Color) -> void:
	var center := at + Vector2(0, -4.0)
	var rotation := direction.angle() + progress * TAU * 1.35
	for index in range(3):
		var radius := 46.0 + float(index) * 22.0
		var start_angle := rotation + float(index) * 1.42
		var end_angle := start_angle + 1.72
		draw_arc(center, radius, start_angle, end_angle, 16, Color(core.r, core.g, core.b, alpha * (0.68 - float(index) * 0.12)), 4.0 - float(index) * 0.68)
		draw_arc(center, radius - 5.0, start_angle + 0.12, end_angle - 0.12, 12, Color(edge.r, edge.g, edge.b, alpha * 0.76), 1.6)
	_draw_named_ground_dust(at, direction, alpha * 0.44, 7, 42.0)

func _draw_named_triple_thrust_vfx(origin: Vector2, direction: Vector2, reach: float, progress: float, alpha: float, core: Color, edge: Color) -> void:
	var step := clampi(int(progress * 3.0), 0, 2)
	var perpendicular := Vector2(-direction.y, direction.x)
	for index in range(3):
		var local_alpha := alpha * (1.0 if index <= step else 0.34)
		var offset := (float(index) - 1.0) * 10.0
		_draw_named_thrust_vfx(origin + perpendicular * offset, direction.rotated((float(index) - 1.0) * 0.035), reach * (0.82 + float(index) * 0.08), progress * (0.72 + float(index) * 0.10), local_alpha, core, edge, 4.5)

func _draw_named_summon_vfx(at: Vector2, progress: float, alpha: float, core: Color, edge: Color) -> void:
	var center := at + Vector2(0, 7.0)
	var radius := lerpf(24.0, 78.0, clampf(progress, 0.0, 1.0))
	for index in range(3):
		var start_angle := visual_time * 1.8 + TAU * float(index) / 3.0
		draw_arc(center, radius - float(index) * 9.0, start_angle, start_angle + 1.26, 12, Color(core.r, core.g, core.b, alpha * (0.70 - float(index) * 0.12)), 2.4)
	for index in range(4):
		var direction := Vector2.from_angle(TAU * float(index) / 4.0 + visual_time * 1.2)
		draw_line(center + direction * (radius * 0.30), center + direction * (radius * 0.74), Color(edge.r, edge.g, edge.b, alpha * 0.72), 2.0)

func _draw_telegraphs() -> void:
	for telegraph in telegraphs:
		var colors := _telegraph_colors(telegraph)
		var fill: Color = colors.fill
		var outline: Color = colors.outline
		var progress := _telegraph_progress(telegraph)
		_draw_pixel_telegraph_fill(telegraph, fill, progress)
		_draw_special_telegraph_visual(telegraph, progress, outline)
		match telegraph.shape:
			Telegraph.Shape.CIRCLE:
				_draw_pixel_circle_telegraph(telegraph, outline, progress)
			Telegraph.Shape.LINE:
				_draw_pixel_line_telegraph(telegraph, outline, progress)
			Telegraph.Shape.FAN:
				_draw_pixel_fan_telegraph(telegraph, outline, progress)
		_draw_telegraph_threat_marker(telegraph, outline)

func _draw_special_telegraph_visual(telegraph: Telegraph, progress: float, outline: Color) -> void:
	if telegraph.visual_kind == "":
		return
	match telegraph.visual_kind:
		"arrow_rain":
			_draw_arrow_rain_telegraph(telegraph, progress, outline)
		"oil_fire":
			_draw_oil_fire_telegraph(telegraph, progress, outline)
		"earth_blade":
			_draw_earth_blade_telegraph(telegraph, progress, outline)
		"lvbu_skyfall":
			_draw_lv_bu_skyfall_marker(telegraph.origin, progress, telegraph.remaining <= 0.0)

func _draw_arrow_rain_telegraph(telegraph: Telegraph, progress: float, outline: Color) -> void:
	var center := _pixel_snap(telegraph.origin + Vector2(0.0, 8.0))
	var radius := maxf(32.0, telegraph.range)
	var rain_progress := clampf(progress * 1.18, 0.0, 1.0)
	var seed := int(absf(telegraph.origin.x * 0.17 + telegraph.origin.y * 0.11))
	for index in range(9):
		var angle := float(index) * 2.39996323 + float(seed % 7) * 0.08
		var distance := sqrt((float(index) + 0.5) / 9.0) * radius * 0.82
		var target := center + Vector2.from_angle(angle) * distance
		var x_offset := float((index * 17 + seed) % 11 - 5) * 5.0
		var top := center + Vector2(x_offset, -238.0 - float(index % 3) * 20.0)
		var stagger := float((index + seed) % 4) * 0.055
		var arrow_progress := clampf(rain_progress - stagger, 0.0, 1.0)
		var tip := top.lerp(target, arrow_progress)
		var flight := (target - top).normalized()
		var perpendicular := Vector2(-flight.y, flight.x)
		var tail := tip - flight * (15.0 + float(index % 3) * 3.0)
		var alpha := 0.26 + rain_progress * 0.54
		draw_line(_pixel_snap(tail), _pixel_snap(tip), Color(0.89, 0.78, 0.48, alpha), 1.8, false)
		draw_line(_pixel_snap(tip - flight * 7.0 + perpendicular * 3.0), _pixel_snap(tip), Color(1.0, 0.91, 0.66, alpha), 1.1, false)
		draw_line(_pixel_snap(tip - flight * 7.0 - perpendicular * 3.0), _pixel_snap(tip), Color(1.0, 0.91, 0.66, alpha), 1.1, false)
		if arrow_progress >= 0.92:
			var burst := clampf((arrow_progress - 0.92) / 0.08, 0.0, 1.0)
			draw_rect(Rect2(_pixel_snap(target) - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), Color(1.0, 0.86, 0.48, alpha * (1.0 - burst * 0.55)))
	var pulse := radius * (0.22 + 0.78 * progress)
	_draw_pixel_dotted_ring(center, pulse, Color(outline.r, outline.g, outline.b, outline.a * 0.72), 24, 1.8)

func _draw_oil_fire_telegraph(telegraph: Telegraph, progress: float, outline: Color) -> void:
	var center := _pixel_snap(telegraph.origin + Vector2(0.0, 8.0))
	var pulse := 0.64 + 0.24 * (sin(visual_time * 12.0 + telegraph.origin.x * 0.03) + 1.0) * 0.5
	var radius := maxf(24.0, telegraph.range)
	var oil_color := Color(0.18, 0.12, 0.08, 0.34 + progress * 0.12)
	draw_circle(center, radius * 0.74, oil_color)
	_draw_ellipse_arc(center, Vector2(radius * 0.78, radius * 0.34), 0.0, TAU, 14, Color(0.24, 0.16, 0.09, pulse * 0.72), 2.0)
	for index in range(7):
		var phase := visual_time * (3.4 + float(index % 3) * 0.5) + float(index) * 1.71 + telegraph.origin.y * 0.02
		var angle := TAU * float(index) / 7.0 + sin(phase * 0.7) * 0.18
		var flame_center := center + Vector2.from_angle(angle) * (radius * (0.30 + float(index % 3) * 0.06)) + Vector2(0.0, -5.0)
		var flame_height := 5.0 + (sin(phase) + 1.0) * 3.0 + progress * 2.0
		var flame_color := Color(1.0, 0.48, 0.16, pulse * (0.42 + float(index % 2) * 0.14))
		draw_rect(Rect2(_pixel_snap(flame_center + Vector2(-2.0, -flame_height)), Vector2(4.0, flame_height)), flame_color)
		draw_rect(Rect2(_pixel_snap(flame_center + Vector2(0.0, -flame_height - 3.0)), Vector2(2.0, 3.0)), Color(1.0, 0.78, 0.30, flame_color.a * 0.86))

func _draw_earth_blade_telegraph(telegraph: Telegraph, progress: float, outline: Color) -> void:
	var direction := telegraph.direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	var visible_range := telegraph.range * (0.18 + progress * 0.82)
	var start := telegraph.origin + direction * 6.0
	var end := telegraph.origin + direction * visible_range
	for lane in [-1.0, 1.0]:
		var lane_offset: Vector2 = perpendicular * lane * 5.0
		var previous: Vector2 = start + lane_offset
		for index in range(8):
			var amount := minf(1.0, float(index + 1) / 8.0)
			var point: Vector2 = start.lerp(end, amount) + perpendicular * sin(float(index) * 2.4 + telegraph.origin.x * 0.02) * 4.0 + lane_offset
			if index % 3 != 1:
				draw_line(_pixel_snap(previous), _pixel_snap(point), Color(0.70, 0.78, 1.0, outline.a * 0.72), 2.0, false)
			previous = point
	for index in range(5):
		var amount := (float(index) + 0.35) / 5.0
		var crack_center := start.lerp(end, amount)
		var crack_direction := perpendicular * (1.0 if index % 2 == 0 else -1.0)
		draw_line(_pixel_snap(crack_center), _pixel_snap(crack_center + crack_direction * (8.0 + float(index % 3) * 4.0)), Color(0.85, 0.90, 1.0, outline.a * 0.60), 1.4, false)

func _telegraph_progress(telegraph: Telegraph) -> float:
	var total_duration := maxf(0.01, telegraph.duration)
	return clampf(1.0 - telegraph.remaining / total_duration, 0.0, 1.0)

func _telegraph_pixel_color(color: Color, alpha: float) -> Color:
	var muted := color.lerp(Color("b5a47b"), 0.28)
	return Color(muted.r, muted.g, muted.b, alpha)

func _draw_pixel_telegraph_fill(telegraph: Telegraph, fill: Color, progress: float) -> void:
	var color := _telegraph_pixel_color(fill, fill.a)
	match telegraph.shape:
		Telegraph.Shape.CIRCLE:
			_draw_pixel_circle_telegraph_fill(telegraph.origin, telegraph.range, color, progress)
		Telegraph.Shape.LINE:
			_draw_pixel_line_telegraph_fill(telegraph, color, progress)
		Telegraph.Shape.FAN:
			_draw_pixel_fan_telegraph_fill(telegraph, color, progress)

func _draw_pixel_circle_telegraph_fill(center: Vector2, radius: float, color: Color, progress: float) -> void:
	var reveal_radius := radius * (0.26 + progress * 0.74)
	if reveal_radius <= 1.0:
		return
	var soft_fill := Color(color.r, color.g, color.b, color.a * 0.42)
	draw_circle(_pixel_snap(center), reveal_radius, soft_fill)
	var spacing := clampf(reveal_radius / 3.6, 16.0, 28.0)
	var cell_radius := int(ceilf(reveal_radius / spacing))
	var phase := int(floor(progress * 4.0))
	for row in range(-cell_radius, cell_radius + 1):
		for column in range(-cell_radius, cell_radius + 1):
			if posmod(column * 3 + row * 5 + phase, 4) >= 2:
				continue
			var offset := Vector2(float(column) * spacing + float(row & 1) * spacing * 0.5, float(row) * spacing)
			if offset.length_squared() > pow(reveal_radius - 5.0, 2.0):
				continue
			var point := _pixel_snap(center + offset)
			draw_rect(Rect2(point - Vector2(3.0, 2.0), Vector2(6.0, 4.0)), Color(color.r, color.g, color.b, color.a * 0.82))

func _draw_pixel_line_telegraph_fill(telegraph: Telegraph, color: Color, progress: float) -> void:
	var direction := telegraph.direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	var half_width := maxf(8.0, telegraph.width * 0.5)
	var visible_range := telegraph.range * (0.22 + progress * 0.78)
	if visible_range <= 1.0:
		return
	var end := telegraph.origin + direction * visible_range
	var points := PackedVector2Array([
		_pixel_snap(telegraph.origin - perpendicular * half_width),
		_pixel_snap(end - perpendicular * half_width),
		_pixel_snap(end + perpendicular * half_width),
		_pixel_snap(telegraph.origin + perpendicular * half_width),
	])
	draw_colored_polygon(points, Color(color.r, color.g, color.b, color.a * 0.38))
	var spacing := clampf(maxf(visible_range / 9.0, half_width * 0.7), 16.0, 30.0)
	var length_cells := int(ceilf(visible_range / spacing))
	var width_cells := int(ceilf(half_width / spacing))
	var phase := int(floor(progress * 4.0))
	for length_index in range(length_cells + 1):
		for width_index in range(-width_cells, width_cells + 1):
			if posmod(length_index * 5 + width_index * 3 + phase, 4) >= 2:
				continue
			var local_point := direction * minf(visible_range - 4.0, float(length_index) * spacing + 8.0) + perpendicular * float(width_index) * spacing
			if absf(local_point.dot(perpendicular)) > half_width - 4.0:
				continue
			var point := _pixel_snap(telegraph.origin + local_point)
			draw_rect(Rect2(point - Vector2(3.0, 2.0), Vector2(6.0, 4.0)), Color(color.r, color.g, color.b, color.a * 0.80))

func _draw_pixel_fan_telegraph_fill(telegraph: Telegraph, color: Color, progress: float) -> void:
	var center_angle := telegraph.direction.angle()
	var start_angle := center_angle - telegraph.half_angle
	var end_angle := center_angle + telegraph.half_angle
	var reveal_radius := telegraph.range * (0.24 + progress * 0.76)
	if reveal_radius <= 1.0:
		return
	var points := PackedVector2Array([_pixel_snap(telegraph.origin)])
	for index in range(13):
		var angle := lerpf(start_angle, end_angle, float(index) / 12.0)
		points.append(_pixel_snap(telegraph.origin + Vector2.from_angle(angle) * reveal_radius))
	draw_colored_polygon(points, Color(color.r, color.g, color.b, color.a * 0.40))
	var spacing := clampf(reveal_radius / 4.2, 16.0, 28.0)
	var radial_cells := int(ceilf(reveal_radius / spacing))
	var angular_cells := clampi(int(ceilf(reveal_radius * absf(end_angle - start_angle) / spacing)), 3, 11)
	var phase := int(floor(progress * 4.0))
	for radial_index in range(radial_cells):
		var local_radius := (float(radial_index) + 0.65) * spacing
		if local_radius > reveal_radius - 4.0:
			continue
		for angular_index in range(angular_cells + 1):
			if posmod(radial_index * 5 + angular_index * 3 + phase, 4) >= 2:
				continue
			var angle := lerpf(start_angle, end_angle, float(angular_index) / float(angular_cells))
			var point := _pixel_snap(telegraph.origin + Vector2.from_angle(angle) * local_radius)
			draw_rect(Rect2(point - Vector2(3.0, 2.0), Vector2(6.0, 4.0)), Color(color.r, color.g, color.b, color.a * 0.84))

func _draw_pixel_circle_telegraph(telegraph: Telegraph, outline: Color, progress: float) -> void:
	var base := _telegraph_pixel_color(outline, 0.58)
	_draw_pixel_dotted_ring(telegraph.origin, telegraph.range, base, 24, 2.0)
	if progress <= 0.0:
		return
	var wave_radius := telegraph.range * progress
	var wave := _telegraph_pixel_color(outline.lightened(0.12), 0.82)
	_draw_pixel_dotted_ring(telegraph.origin, wave_radius, wave, 20, 3.0)
	var pulse_index := int(floor(progress * 12.0))
	for index in range(4):
		var angle := TAU * float(index) / 4.0 + float(pulse_index % 2) * 0.12
		var point := _pixel_snap(telegraph.origin + Vector2.from_angle(angle) * wave_radius)
		draw_rect(Rect2(point - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), wave)

func _draw_pixel_line_telegraph(telegraph: Telegraph, outline: Color, progress: float) -> void:
	var direction := telegraph.direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	var base := _telegraph_pixel_color(outline, 0.54)
	var half_width := maxf(8.0, telegraph.width * 0.5)
	_draw_pixel_dashed_line(telegraph.origin - perpendicular * half_width, telegraph.origin + direction * telegraph.range - perpendicular * half_width, base, 12.0, 2.0)
	_draw_pixel_dashed_line(telegraph.origin + perpendicular * half_width, telegraph.origin + direction * telegraph.range + perpendicular * half_width, base, 12.0, 2.0)
	if progress <= 0.0:
		return
	var wave_distance := telegraph.range * progress
	var wave_center := _pixel_snap(telegraph.origin + direction * wave_distance)
	var wave := _telegraph_pixel_color(outline.lightened(0.12), 0.84)
	draw_line(wave_center - perpendicular * (half_width + 3.0), wave_center + perpendicular * (half_width + 3.0), wave, 3.0, false)
	draw_rect(Rect2(wave_center - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), wave)

func _draw_pixel_fan_telegraph(telegraph: Telegraph, outline: Color, progress: float) -> void:
	var center_angle := telegraph.direction.angle()
	var start_angle := center_angle - telegraph.half_angle
	var end_angle := center_angle + telegraph.half_angle
	var base := _telegraph_pixel_color(outline, 0.58)
	_draw_pixel_dashed_line(telegraph.origin, telegraph.origin + Vector2.from_angle(start_angle) * telegraph.range, base, 12.0, 2.0)
	_draw_pixel_dashed_line(telegraph.origin, telegraph.origin + Vector2.from_angle(end_angle) * telegraph.range, base, 12.0, 2.0)
	_draw_pixel_dotted_arc(telegraph.origin, telegraph.range, start_angle, end_angle, base, 18, 2.0)
	if progress <= 0.0:
		return
	var wave_radius := telegraph.range * progress
	var wave := _telegraph_pixel_color(outline.lightened(0.12), 0.82)
	_draw_pixel_dotted_arc(telegraph.origin, wave_radius, start_angle, end_angle, wave, 14, 3.0)
	var center_point := _pixel_snap(telegraph.origin + telegraph.direction.normalized() * wave_radius)
	draw_rect(Rect2(center_point - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), wave)

func _draw_pixel_dotted_ring(center: Vector2, radius: float, color: Color, segment_count: int, width: float) -> void:
	if radius <= 1.0:
		return
	for index in range(segment_count):
		if index % 2 == 1:
			continue
		var start_angle := TAU * float(index) / float(segment_count)
		var end_angle := TAU * float(index + 1) / float(segment_count)
		var points := PackedVector2Array()
		for step in range(3):
			var amount := float(step) / 2.0
			points.append(_pixel_snap(center + Vector2.from_angle(lerpf(start_angle, end_angle, amount)) * radius))
		draw_polyline(points, color, width, false)

func _draw_pixel_dotted_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, color: Color, segment_count: int, width: float) -> void:
	if radius <= 1.0:
		return
	for index in range(segment_count):
		if index % 2 == 1:
			continue
		var start := lerpf(start_angle, end_angle, float(index) / float(segment_count))
		var finish := lerpf(start_angle, end_angle, float(index + 1) / float(segment_count))
		var points := PackedVector2Array()
		for step in range(3):
			var amount := float(step) / 2.0
			points.append(_pixel_snap(center + Vector2.from_angle(lerpf(start, finish, amount)) * radius))
		draw_polyline(points, color, width, false)

func _draw_pixel_dashed_line(start: Vector2, finish: Vector2, color: Color, dash_length: float, width: float) -> void:
	var delta := finish - start
	var length := delta.length()
	if length <= 0.01:
		return
	var direction := delta / length
	var cursor := 0.0
	while cursor < length:
		var segment_end := minf(cursor + dash_length * 0.62, length)
		draw_line(_pixel_snap(start + direction * cursor), _pixel_snap(start + direction * segment_end), color, width, false)
		cursor += dash_length

func _pixel_snap(point: Vector2) -> Vector2:
	return Vector2(roundf(point.x / 2.0) * 2.0, roundf(point.y / 2.0) * 2.0)

func _draw_telegraph_threat_marker(telegraph: Telegraph, color: Color) -> void:
	if telegraph.threat_kind == Telegraph.ThreatKind.BASIC:
		return
	var marker_position := telegraph.origin + telegraph.direction.normalized() * minf(48.0, telegraph.range * 0.32)
	if telegraph.threat_kind == Telegraph.ThreatKind.ACTIVE:
		var diamond := PackedVector2Array([
			marker_position + Vector2(0, -8), marker_position + Vector2(8, 0),
			marker_position + Vector2(0, 8), marker_position + Vector2(-8, 0),
			marker_position + Vector2(0, -8),
		])
		draw_polyline(diamond, color, 2.0, false)
		return
	var cross_color := Color(1.0, 0.42, 0.38, maxf(0.74, color.a))
	draw_line(marker_position + Vector2(-7, -7), marker_position + Vector2(7, 7), cross_color, 2.4)
	draw_line(marker_position + Vector2(-7, 7), marker_position + Vector2(7, -7), cross_color, 2.4)

func _draw_shield_breaks() -> void:
	for mark in shield_break_marks:
		var alpha := clampf(mark.remaining / 0.24, 0.0, 1.0)
		var spread := (1.0 - alpha) * 34.0
		for index in range(6):
			var direction := Vector2.from_angle(TAU * index / 6.0 + 0.22)
			var start: Vector2 = mark.position + direction * (20.0 + spread)
			var end: Vector2 = start + direction * (10.0 + 14.0 * (1.0 - alpha))
			draw_line(start, end, Color(0.72, 0.95, 1.0, alpha), 2.0)

func _draw_flashes() -> void:
	for flash in flashes:
		var request: AttackRequest = flash.request
		var duration := float(flash.get("duration", FLASH_DURATION))
		var alpha := clampf(flash.remaining / duration, 0.0, 1.0)
		var progress := 1.0 - alpha
		var variant := int(flash.get("variant", 0))
		match request.label:
			"青龙横江":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.22, 0.88, 0.62, 0.88), 13.0, 3)
			"压阵斩":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.36, 0.94, 0.70, 0.92), 16.0, 3)
			"拖刀断阵":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.94, 0.74, 0.27, 0.96), 21.0, 4)
			"拖刀斩浪":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.96, 0.72, 0.24, 0.98), 25.0, 5)
			"拖刀刀浪":
				pass
			"青龙断浪":
				pass
			"青龙破阵":
				_draw_guan_line_cut(request, alpha, progress, Color(0.36, 0.96, 0.68, 0.74), 12.0)
			"武圣刀浪":
				pass
			"武圣震阵", "武圣拖刀震阵", "万夫莫开·怒喝震阵":
				_draw_wushuang_impact_wave(request, progress)
			"威震华夏·横江":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.28, 0.98, 0.72, 0.96), 27.0, 5)
			"威震华夏·断岳":
				_draw_guan_line_cut(request, alpha, progress, Color(0.94, 0.77, 0.30, 0.96), 30.0)
			"威震华夏·斩将":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.99, 0.80, 0.33, 0.98), 34.0, 5)
				_draw_guan_blade_sweep(request, alpha * 0.64, progress * 0.86, variant + 3, Color(0.26, 0.96, 0.67, 0.92), 17.0, 4)
			"扫阵横击", "蛇矛挑阵", "据水断桥·掀阵":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.94, 0.48, 0.22, 0.92), 16.0, 4)
			"丈八跃砸", "据水断桥·跃砸":
				_draw_zhang_fei_landing_effect(request, alpha, progress)
			"丈八跃砸·前震":
				_draw_zhang_fei_forward_impact(request, alpha, progress, variant)
			"断阵横掷", "万夫莫开·横扫":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(1.0, 0.66, 0.24, 0.96), 25.0, 5)
			"万夫莫开·掀阵", "万夫莫开·断阵":
				_draw_thrust_flash(request, alpha, progress, variant, 12.0, Color(1.0, 0.66, 0.24, 0.94))
			"银枪点阵", "踏阵突刺", "西凉破阵", "银枪奔雷":
				_draw_thrust_flash(request, alpha, progress, variant, 6.0, Color(0.74, 0.90, 1.0, 0.66))
			"流星横挑":
				_draw_sweep_flash(request, alpha, progress, variant, Color(0.72, 0.90, 1.0, 0.90))
			"连珠箭", "蓄力穿云", "贯星矢", "定军连珠":
				_draw_thrust_flash(request, alpha, progress, variant, 3.6, Color(1.0, 0.80, 0.34, 0.78))
			"断弦横斩", "回身断阵", "返弦斩":
				_draw_guan_blade_sweep(request, alpha, progress, variant, Color(0.98, 0.72, 0.30, 0.90), 14.0, 3)
			"点刺":
				_draw_thrust_flash(request, alpha, progress, variant, 4.0, Color(0.48, 0.86, 1.0, 0.52))
			"枪势震退":
				_draw_first_strike_shockwave(request, alpha, progress)
			"穿阵挑刺", "破军枪影":
				_draw_thrust_flash(request, alpha, progress, variant, 7.0, Color(0.38, 0.84, 1.0, 0.58))
			"横扫":
				_draw_sweep_flash(request, alpha, progress, variant, Color(0.44, 0.86, 1.0, 0.88))
			"破军":
				_draw_sweep_flash(request, alpha, progress, variant, Color(0.62, 0.94, 1.0, 0.92))
			"七进七出":
				_draw_thrust_flash(request, alpha, progress, variant, 5.0, Color(0.70, 0.95, 1.0, 0.60))
			"七进七出·收势":
				_draw_ultimate_landing_burst(request, alpha, progress)
			"哪吒火轮":
				_draw_firewheel_flash(request, alpha, progress)
			"乾坤掷轮":
				_draw_firewheel_projectile_flash(request, alpha, progress)
			_:
				_draw_thrust_flash(request, alpha, progress, variant, 4.0, Color(0.70, 0.95, 1.0, 0.44))
		if request.empowered_knockback_active:
			_draw_breakout_gust(request, alpha, progress)

func _draw_guan_blade_sweep(request: AttackRequest, alpha: float, progress: float, variant: int, color: Color, thickness: float, segments: int) -> void:
	var start_angle := request.direction.angle() - request.half_angle
	var end_angle := request.direction.angle() + request.half_angle
	var radius := request.range * lerpf(0.40, 0.93, clampf(progress / 0.26, 0.0, 1.0))
	_draw_broken_sweep_band(request.origin, start_angle, end_angle, radius, thickness, color, alpha, variant, segments)
	_draw_broken_sweep_band(request.origin, start_angle + 0.07, end_angle - 0.07, radius - thickness * 0.68, thickness * 0.34, Color(0.86, 1.0, 0.80, 0.84), alpha * 0.86, variant + 4, maxi(2, segments - 1))
	var span := end_angle - start_angle
	for index in range(4):
		var amount := (float(index) + 0.65) / 4.8
		var angle := start_angle + span * amount + sin(float(variant + index) * 1.43) * 0.035
		var radial := Vector2.from_angle(angle)
		var tangent := Vector2(-radial.y, radial.x)
		var center := request.origin + radial * (radius + 4.0 + float(index) * 3.0)
		var shard := PackedVector2Array([
			center - tangent * 3.0 - radial * 4.0,
			center + tangent * 4.0,
			center + radial * (13.0 + float(index) * 2.0),
		])
		draw_colored_polygon(shard, Color(0.90, 1.0, 0.72, alpha * (0.48 - float(index) * 0.06)))

func _draw_guan_line_cut(request: AttackRequest, alpha: float, progress: float, color: Color, width_bonus: float) -> void:
	var direction := request.direction.normalized()
	var perpendicular := Vector2(-direction.y, direction.x)
	var length := request.range * lerpf(0.28, 0.98, clampf(progress / 0.24, 0.0, 1.0))
	var root := request.origin + direction * 10.0
	var tip := root + direction * length
	var half_width := request.width * 0.5 + width_bonus
	var blade := PackedVector2Array([
		root - perpendicular * (half_width * 0.35), root + direction * (length * 0.28) - perpendicular * half_width,
		tip - perpendicular * (half_width * 0.18), tip + perpendicular * (half_width * 0.18),
		root + direction * (length * 0.28) + perpendicular * half_width, root + perpendicular * (half_width * 0.35),
	])
	draw_colored_polygon(blade, Color(color.r, color.g, color.b, alpha * 0.54))
	draw_line(root + direction * 8.0, tip, Color(0.92, 1.0, 0.76, alpha * 0.94), 4.0)
	for index in range(5):
		var side := -1.0 if index % 2 == 0 else 1.0
		var shard_center := root + direction * (length * (0.34 + float(index) * 0.12)) + perpendicular * side * (half_width * 0.82)
		draw_line(shard_center, shard_center + direction * (16.0 + float(index) * 3.0), Color(color.r, color.g, color.b, alpha * 0.54), 2.2)

func _draw_zhang_fei_landing_effect(request: AttackRequest, _alpha: float, progress: float) -> void:
	var first_frame_ratio := ZHANG_FEI_LANDING_FRAME_DURATIONS[0] / (ZHANG_FEI_LANDING_FRAME_DURATIONS[0] + ZHANG_FEI_LANDING_FRAME_DURATIONS[1])
	var frame_index := 0 if progress < first_frame_ratio else 1
	var texture: Texture2D = ZHANG_FEI_LANDING_TEXTURES[frame_index]
	var effect_alpha := 1.0 if frame_index == 0 else 1.0 - clampf((progress - first_frame_ratio) / (1.0 - first_frame_ratio), 0.0, 1.0)
	var scale := clampf(request.range / 200.0, 0.42, 0.90)
	var center := request.origin + ZHANG_FEI_WORLD_FOOT_OFFSET
	draw_set_transform(center, 0.0, Vector2(scale, scale))
	draw_texture(texture, -ZHANG_FEI_LANDING_SOURCE_ANCHOR, Color(1.0, 1.0, 1.0, effect_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_zhang_fei_forward_impact(request: AttackRequest, alpha: float, progress: float, variant: int) -> void:
	var start_angle := request.direction.angle() - request.half_angle
	var end_angle := request.direction.angle() + request.half_angle
	var radius := lerpf(request.inner_radius + 10.0, request.range, clampf(progress * 1.28, 0.0, 1.0))
	_draw_broken_sweep_band(request.origin, start_angle, end_angle, radius, 13.0, Color(1.0, 0.48, 0.20, alpha * 0.82), alpha, variant + 2, 4)
	_draw_broken_sweep_band(request.origin, start_angle + 0.08, end_angle - 0.08, maxf(request.inner_radius + 6.0, radius - 11.0), 3.6, Color(1.0, 0.82, 0.42, alpha * 0.76), alpha, variant + 5, 3)

func _draw_wushuang_impact_wave(request: AttackRequest, progress: float) -> void:
	var frame_count := WUSHUANG_IMPACT_TEXTURES.size()
	var frame_index := mini(int(floor(progress * float(frame_count))), frame_count - 1)
	var texture: Texture2D = WUSHUANG_IMPACT_TEXTURES[frame_index]
	# Frame 4 is the peak; fade only once frame 5 begins.
	var fade_start := 5.0 / float(frame_count)
	var effect_alpha := 1.0 if progress < fade_start else 1.0 - clampf((progress - fade_start) / (1.0 - fade_start), 0.0, 1.0)
	var scale := clampf(request.range / 212.0, 0.58, 1.24)
	var center := request.origin + Vector2(0.0, 13.0)
	draw_set_transform(center, 0.0, Vector2(scale, scale))
	draw_texture(texture, -WUSHUANG_IMPACT_SOURCE_ANCHOR, Color(1.0, 1.0, 1.0, effect_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_wusheng_pulse(request: AttackRequest, alpha: float, progress: float) -> void:
	var radius := request.range * (0.20 + progress * 0.80)
	draw_arc(request.origin, radius, 0.0, TAU, 28, Color(0.96, 0.76, 0.28, alpha * 0.90), 3.0)
	draw_arc(request.origin, maxf(8.0, radius - 14.0), 0.0, TAU, 24, Color(0.34, 0.96, 0.66, alpha * 0.72), 1.8)
	for index in range(8):
		var direction := Vector2.from_angle(TAU * float(index) / 8.0 + progress * 0.24)
		var inner := request.origin + direction * radius * 0.42
		var tip := request.origin + direction * radius
		draw_line(inner, tip, Color(0.98, 0.83, 0.38, alpha * 0.62), 2.0)

func _draw_ultimate_landing_burst(request: AttackRequest, alpha: float, progress: float) -> void:
	var radius := request.range * (0.28 + progress * 0.72)
	var ring_color := Color(0.82, 0.97, 1.0, alpha * 0.72)
	draw_arc(request.origin, radius, 0.0, TAU, 24, ring_color, 2.6)
	for index in range(10):
		var direction := Vector2.from_angle(TAU * float(index) / 10.0 + progress * 0.16)
		var perpendicular := Vector2(-direction.y, direction.x)
		var inner := request.origin + direction * radius * 0.26
		var tip := request.origin + direction * radius
		var shard := PackedVector2Array([
			inner - perpendicular * 3.5,
			tip,
			inner + perpendicular * 3.5,
		])
		draw_colored_polygon(shard, Color(0.62, 0.91, 1.0, alpha * 0.54))

func _draw_firewheel_flash(request: AttackRequest, alpha: float, progress: float) -> void:
	var radius := request.range * (0.34 + progress * 0.66)
	_draw_firewheel_texture(request.origin, radius / 64.0, -(visual_time * 10.0 + progress * TAU), Color(1.0, 1.0, 1.0, alpha * 0.88))

func _draw_firewheel_projectile_flash(request: AttackRequest, alpha: float, progress: float) -> void:
	var direction := request.direction.normalized()
	var travel_distance := request.range * progress
	var center := request.origin + direction * travel_distance
	var size_multiplier := request.visual_scale
	_draw_firewheel_texture(center, 0.18 * size_multiplier, -(visual_time * 20.0 + progress * 2.4), Color(1.0, 1.0, 1.0, alpha))

func _draw_firewheel_rings() -> void:
	for ring in firewheel_rings:
		var center: Vector2 = ring.get("position", Vector2.ZERO)
		_draw_firewheel_texture(center, FIREWHEEL_RING_RADIUS / 64.0, -visual_time * 16.0, Color.WHITE)
		_draw_firewheel_texture(center, FIREWHEEL_RING_RADIUS / 128.0, -visual_time * 40.0, Color(1.0, 1.0, 1.0, 0.92))

func _draw_guan_blade_waves() -> void:
	for wave in guan_blade_waves:
		var origin: Vector2 = wave.get("origin", Vector2.ZERO)
		var direction: Vector2 = wave.get("direction", Vector2.RIGHT)
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		direction = direction.normalized()
		var frame_max := clampi(int(wave.get("frame_max", 4)), 0, 13)
		var expansion_frames := _guan_knife_wave_expansion_frames(frame_max)
		var elapsed := maxf(0.0, float(wave.get("elapsed", 0.0)))
		var expansion_duration := maxf(0.01, float(wave.get("expansion_duration", GUAN_KNIFE_WAVE_FRAME_DURATION)))
		var hold_duration := maxf(0.0, float(wave.get("hold_duration", 0.0)))
		var frame_number := expansion_frames[expansion_frames.size() - 1]
		var alpha := 1.0
		var scale := float(wave.get("scale", 0.60))
		if elapsed < expansion_duration:
			var frame_index := mini(expansion_frames.size() - 1, int(floor(elapsed / expansion_duration * float(expansion_frames.size()))))
			frame_number = expansion_frames[frame_index]
		elif elapsed < expansion_duration + hold_duration:
			# The peak frame keeps one fixed size during the brief infinite-range hold.
			pass
		else:
			var fade_progress := clampf((elapsed - expansion_duration - hold_duration) / GUAN_KNIFE_WAVE_FADE_DURATION, 0.0, 1.0)
			var fade_index := mini(GUAN_KNIFE_WAVE_FADE_FRAMES.size() - 1, int(floor(fade_progress * float(GUAN_KNIFE_WAVE_FADE_FRAMES.size()))))
			frame_number = GUAN_KNIFE_WAVE_FADE_FRAMES[fade_index]
			alpha = 1.0 - fade_progress
		if alpha <= 0.01:
			continue
		_draw_guan_blade_wave_frame(origin, direction, frame_number, scale, alpha)

func _guan_knife_wave_display_scale(frame_max: int, base_scale: float, travel_distance: float, infinite: bool) -> float:
	if infinite:
		return maxf(base_scale, GUAN_KNIFE_WUSHENG_FIXED_SCALE)
	var peak_texture := _guan_knife_wave_texture(frame_max)
	if peak_texture == null:
		return base_scale
	var source_forward_extent := maxf(1.0, peak_texture.get_width() - GUAN_KNIFE_WAVE_SOURCE_ANCHOR.x)
	var fitted_scale := (travel_distance + GUAN_KNIFE_WAVE_FIT_PADDING) / source_forward_extent
	return maxf(base_scale, fitted_scale)

func _guan_knife_wave_expansion_frames(frame_max: int) -> Array[int]:
	var frames: Array[int] = []
	for frame_number in GUAN_KNIFE_WAVE_EXPANSION_FRAMES:
		if frame_number <= frame_max:
			frames.append(frame_number)
	if frames.is_empty():
		frames.append(0)
	return frames

func _guan_knife_wave_texture(frame_number: int) -> Texture2D:
	if guan_knife_wave_frames.has(frame_number):
		return guan_knife_wave_frames[frame_number] as Texture2D
	var fallback := frame_number
	while fallback > 0:
		fallback -= 1
		if guan_knife_wave_frames.has(fallback):
			return guan_knife_wave_frames[fallback] as Texture2D
	return null

func _draw_guan_blade_wave_frame(center: Vector2, direction: Vector2, frame_number: int, scale: float, alpha: float) -> void:
	var texture := _guan_knife_wave_texture(frame_number)
	if texture == null:
		return
	var transform_scale := Vector2(scale, scale)
	var rotation := direction.angle()
	if direction.x < -0.08:
		# Mirror left-facing waves so the ground contact remains upright instead of turning upside down.
		rotation -= PI
		transform_scale.x = -scale
	draw_set_transform(center, rotation, transform_scale)
	draw_texture(texture, -GUAN_KNIFE_WAVE_SOURCE_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_firewheel_texture(center: Vector2, scale: float, rotation: float, color: Color) -> void:
	draw_set_transform(center, rotation, Vector2(scale, scale))
	draw_texture(FIREWHEEL_TEXTURE, Vector2(-64, -64), color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_first_strike_shockwave(request: AttackRequest, alpha: float, progress: float) -> void:
	var radius := request.range * (0.30 + progress * 0.70)
	for index in range(8):
		var direction := Vector2.from_angle(TAU * float(index) / 8.0 + progress * 0.18)
		var perpendicular := Vector2(-direction.y, direction.x)
		var root := request.origin + direction * radius * 0.24
		var tip := request.origin + direction * radius
		var shard := PackedVector2Array([
			root - perpendicular * 2.8,
			tip,
			root + perpendicular * 2.8,
		])
		draw_colored_polygon(shard, Color(0.56, 0.91, 1.0, alpha * 0.62))
		if index % 2 == 0:
			draw_line(root - direction * 7.0, tip - direction * 5.0, Color(0.84, 0.98, 1.0, alpha * 0.68), 1.4)
	for index in range(4):
		var start_angle := TAU * float(index) / 4.0 + progress * 0.24
		draw_arc(request.origin, radius * 0.76, start_angle, start_angle + 0.46, 6, Color(0.66, 0.94, 1.0, alpha * 0.56), 1.6)

func _draw_zhang_landing_shockwave(request: AttackRequest, alpha: float, progress: float) -> void:
	var impact_ratio := clampf(progress / 0.26, 0.0, 1.0)
	var radius := request.range * lerpf(0.24, 1.0, impact_ratio)
	var pulse_alpha := alpha * (0.88 if progress < 0.20 else 0.62)
	draw_circle(request.origin, radius * 0.22, Color(1.0, 0.70, 0.27, pulse_alpha * 0.36))
	draw_arc(request.origin, radius * 0.42, 0.0, TAU, 24, Color(1.0, 0.90, 0.52, pulse_alpha * 0.82), 3.0)
	draw_arc(request.origin, radius, 0.0, TAU, 36, Color(1.0, 0.48, 0.17, pulse_alpha * 0.92), 3.2)
	for index in range(12):
		var direction := Vector2.from_angle(TAU * float(index) / 12.0 + progress * 0.18)
		var perpendicular := Vector2(-direction.y, direction.x)
		var root := request.origin + direction * radius * 0.34
		var tip := request.origin + direction * radius * (0.92 + float(index % 3) * 0.025)
		var shard := PackedVector2Array([
			root - perpendicular * (2.5 + progress * 3.0),
			tip,
			root + perpendicular * (2.5 + progress * 3.0),
		])
		draw_colored_polygon(shard, Color(1.0, 0.62, 0.22, pulse_alpha * (0.52 if index % 2 == 0 else 0.32)))
		if index % 2 == 0:
			draw_line(root, tip - direction * 5.0, Color(1.0, 0.92, 0.58, pulse_alpha * 0.76), 1.6)

func _draw_breakout_gust(request: AttackRequest, alpha: float, progress: float) -> void:
	var direction := request.direction
	var perpendicular := Vector2(-direction.y, direction.x)
	var root := request.origin + SPEAR_VFX_HEIGHT_OFFSET + direction * 18.0
	var reach := minf(request.range, 118.0) * (0.66 + progress * 0.34)
	for side in [-1.0, 1.0]:
		var side_sign: float = float(side)
		var center: Vector2 = root + direction * (reach * 0.48) + perpendicular * side_sign * (18.0 + progress * 9.0)
		var gust := PackedVector2Array([
			root + perpendicular * side_sign * 6.0,
			center - direction * (reach * 0.18) + perpendicular * side_sign * 15.0,
			root + direction * reach + perpendicular * side_sign * (30.0 + progress * 15.0),
			center + direction * (reach * 0.20) + perpendicular * side_sign * 7.0,
		])
		draw_colored_polygon(gust, Color(0.76, 0.96, 1.0, alpha * 0.34))

func _draw_thrust_flash(request: AttackRequest, alpha: float, progress: float, variant: int, half_width: float, outer_color: Color) -> void:
	var direction := request.direction
	var perpendicular := Vector2(-direction.y, direction.x)
	var burst := clampf(progress / 0.28, 0.0, 1.0)
	var length := maxf(10.0, request.range * lerpf(0.40, 0.93, burst) - 7.0)
	var root := request.origin + direction * 7.0
	var tip := root + direction * length
	var side := -1.0 if variant % 2 == 0 else 1.0
	var collision_half_width := request.width * 0.5
	var effect_half_width := maxf(half_width, collision_half_width * 0.32) if request.label in ["点刺", "穿阵挑刺"] else half_width
	var width := effect_half_width * (1.55 + 0.08 * float(variant % 3))
	var outer := PackedVector2Array([
		root - perpendicular * (width * 1.20),
		root + direction * (length * 0.21) - perpendicular * (width * 1.62),
		root + direction * (length * 0.57) - perpendicular * (width * 0.66),
		tip,
		root + direction * (length * 0.64) + perpendicular * (width * 0.42),
		root + direction * (length * 0.26) + perpendicular * (width * 1.16),
	])
	draw_colored_polygon(outer, Color(outer_color.r, outer_color.g, outer_color.b, outer_color.a * alpha))
	var inner_root := root + direction * maxf(5.0, length * 0.10)
	var inner := PackedVector2Array([
		inner_root - perpendicular * (width * 0.66),
		root + direction * (length * 0.43) - perpendicular * (width * 0.82),
		tip - direction * maxf(2.0, length * 0.025),
		root + direction * (length * 0.54) + perpendicular * (width * 0.32),
		inner_root + perpendicular * (width * 0.52),
	])
	draw_colored_polygon(inner, Color(0.70, 0.95, 1.0, alpha * 0.68))
	var side_root := root + direction * (length * 0.16) + perpendicular * side * (width * 0.76)
	var side_tip := root + direction * (length * (0.76 + 0.03 * float(variant % 2))) + perpendicular * side * (width * (1.36 + progress * 0.72))
	var side_wind := PackedVector2Array([
		side_root - direction * (length * 0.08) - perpendicular * side * (width * 0.58),
		side_root + perpendicular * side * (width * 0.74),
		side_tip,
		side_root + direction * (length * 0.28) + perpendicular * side * (width * 0.38),
	])
	draw_colored_polygon(side_wind, Color(0.40, 0.82, 1.0, alpha * 0.42))
	var scatter := 3.0 + progress * 14.0
	for index in range(3):
		var fragment_side := side if index % 2 == 0 else -side
		var distance := length * (0.42 + 0.14 * float(index)) + float(variant - 2) * 1.6
		var center := root + direction * distance + perpendicular * fragment_side * (width + scatter + float(index) * 2.5)
		var fragment_length := 7.0 + float(index) * 2.0
		var fragment_width := 1.8 + float((variant + index) % 2)
		var shard := PackedVector2Array([
			center - direction * (fragment_length * 0.45) - perpendicular * fragment_width,
			center - direction * (fragment_length * 0.32) + perpendicular * fragment_width,
			center + direction * fragment_length,
		])
		draw_colored_polygon(shard, Color(0.58, 0.91, 1.0, alpha * (0.36 - float(index) * 0.05)))

func _draw_sweep_flash(request: AttackRequest, alpha: float, progress: float, variant: int, color: Color) -> void:
	var start_angle := request.direction.angle() - request.half_angle
	var end_angle := request.direction.angle() + request.half_angle
	var burst := clampf(progress / 0.30, 0.0, 1.0)
	var center := request.origin
	var radius := request.range * lerpf(0.52, 0.86, burst)
	_draw_broken_sweep_band(center, start_angle, end_angle, radius, 15.0, color, alpha, variant, 3)
	_draw_broken_sweep_band(center, start_angle + 0.08, end_angle - 0.12, radius - 11.0, 8.0, Color(0.70, 0.95, 1.0, 0.70), alpha * 0.78, variant + 3, 2)
	var span := end_angle - start_angle
	for index in range(4):
		var shard_angle := start_angle + span * (0.17 + 0.19 * float(index)) + float((variant + index) % 3 - 1) * 0.035
		var radial := Vector2.from_angle(shard_angle)
		var tangent := Vector2(-radial.y, radial.x)
		var shard_radius := minf(request.range * 0.90, radius + 4.0 + progress * 6.0 + float(index) * 1.5)
		var shard_center := center + radial * shard_radius
		var shard_length := 7.0 + float(index % 2) * 3.0
		var shard := PackedVector2Array([
			shard_center - tangent * (shard_length * 0.55) - radial * 1.8,
			shard_center - tangent * (shard_length * 0.20) + radial * 2.4,
			shard_center + tangent * shard_length + radial * 3.0,
		])
		draw_colored_polygon(shard, Color(0.56, 0.91, 1.0, alpha * (0.44 - float(index) * 0.06)))

func _draw_broken_sweep_band(center: Vector2, start_angle: float, end_angle: float, outer_radius: float, thickness: float, color: Color, alpha: float, variant: int, segment_count: int) -> void:
	var span := end_angle - start_angle
	var slice := span / float(segment_count)
	var gap := minf(0.10, slice * 0.22)
	for segment_index in range(segment_count):
		var segment_start := start_angle + slice * float(segment_index) + gap * 0.50
		var segment_end := start_angle + slice * float(segment_index + 1) - gap * 0.50
		if segment_end <= segment_start:
			continue
		var points := PackedVector2Array()
		for step in range(6):
			var amount := float(step) / 5.0
			var angle := lerpf(segment_start, segment_end, amount)
			var edge_noise := sin(float(step + segment_index * 3 + variant) * 1.71) * 2.2
			points.append(center + Vector2.from_angle(angle) * (outer_radius + edge_noise))
		for step in range(5, -1, -1):
			var amount := float(step) / 5.0
			var angle := lerpf(segment_start, segment_end, amount)
			var edge_noise := sin(float(step + segment_index * 3 + variant) * 1.71) * 1.4
			points.append(center + Vector2.from_angle(angle) * (outer_radius - thickness + edge_noise))
		draw_colored_polygon(points, Color(color.r, color.g, color.b, color.a * alpha * (0.42 + 0.10 * float(segment_index % 2))))

func _draw_ultimate_dash_wind(at: Vector2) -> void:
	var direction := player.ultimate_dash_direction
	var perpendicular := Vector2(-direction.y, direction.x)
	var side := -1.0 if int(visual_time * 12.0) % 2 == 0 else 1.0
	var root := at + SPEAR_VFX_HEIGHT_OFFSET - direction * 34.0
	var tip := at + SPEAR_VFX_HEIGHT_OFFSET + direction * 54.0
	var outer := PackedVector2Array([
		root - perpendicular * 18.0,
		root + direction * 22.0 - perpendicular * 25.0,
		root + direction * 64.0 - perpendicular * 7.0,
		tip,
		root + direction * 67.0 + perpendicular * 6.0,
		root + direction * 19.0 + perpendicular * 17.0,
	])
	draw_colored_polygon(outer, Color(0.42, 0.86, 1.0, 0.46))
	var core := PackedVector2Array([
		root + direction * 9.0 - perpendicular * 6.0,
		root + direction * 38.0 - perpendicular * 7.0,
		tip - direction * 3.0,
		root + direction * 43.0 + perpendicular * 3.0,
		root + direction * 11.0 + perpendicular * 5.0,
	])
	draw_colored_polygon(core, Color(0.72, 0.96, 1.0, 0.72))
	for index in range(5):
		var shard_side := side if index % 2 == 0 else -side
		var shard_center := root + direction * (20.0 + float(index) * 12.0) + perpendicular * shard_side * (14.0 + float(index) * 5.0)
		var shard := PackedVector2Array([
			shard_center - direction * 6.0 - perpendicular * 2.5,
			shard_center + perpendicular * 3.0,
			shard_center + direction * (11.0 + float(index) * 2.0),
		])
		draw_colored_polygon(shard, Color(0.56, 0.91, 1.0, 0.42 - float(index) * 0.05))
	_draw_ultimate_shock_ring(at + SPEAR_VFX_HEIGHT_OFFSET, direction, 0.82)

func _draw_ultimate_shock_ring(center: Vector2, direction: Vector2, alpha: float) -> void:
	var base_angle := direction.angle()
	for segment in range(3):
		var start_angle := base_angle + PI * (0.24 + float(segment) * 0.46)
		var end_angle := start_angle + 0.58
		var radius := 28.0 + float(segment) * 7.0
		var points := PackedVector2Array()
		for step in range(5):
			var amount := float(step) / 4.0
			var angle := lerpf(start_angle, end_angle, amount)
			var noise := sin(float(step + segment * 5) * 1.83 + visual_time * 11.0) * 2.2
			points.append(center + Vector2.from_angle(angle) * (radius + noise))
		for step in range(4, -1, -1):
			var amount := float(step) / 4.0
			var angle := lerpf(start_angle, end_angle, amount)
			var noise := sin(float(step + segment * 5) * 1.83 + visual_time * 11.0) * 1.5
			points.append(center + Vector2.from_angle(angle) * (radius - 4.5 + noise))
		draw_colored_polygon(points, Color(0.64, 0.94, 1.0, alpha * (0.30 - float(segment) * 0.05)))

func _draw_pickups() -> void:
	if loot != null:
		for drop in loot.drops:
			var at: Vector2 = drop.get("position", Vector2.ZERO)
			var pulse := 0.78 + 0.22 * (sin(visual_time * 7.0 + at.x * 0.03) + 1.0) * 0.5
			var coin_size := LOOT_COIN_DISPLAY_SIZE * (0.94 + pulse * 0.08)
			var coin_rect := Rect2(at - coin_size * 0.5, coin_size)
			draw_circle(at + Vector2(0.0, 1.0), 8.0, Color(0.95, 0.72, 0.28, 0.10 * pulse))
			draw_texture_rect_region(LOOT_COIN_TEXTURE, coin_rect, LOOT_COIN_SOURCE_RECT, Color(1.0, 0.94, 0.72, 0.62 + pulse * 0.16))
	for pickup in pickup_marks:
		var alpha := clampf(pickup.remaining / 0.45, 0.0, 1.0)
		draw_circle(pickup.position, 6.0, Color(0.95, 0.78, 0.26, alpha))

func _draw_tianji_marks() -> void:
	for mark in tianji_marks:
		var skill_id := str(mark.get("id", ""))
		var phase := str(mark.get("phase", "windup"))
		var duration := maxf(0.01, float(mark.get("duration", 0.4)))
		var alpha := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var progress := 1.0 - alpha
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		if skill_id == "seven_star_lightning":
			_draw_tianji_lightning(center, alpha, progress, phase, int(mark.get("rank", 1)), float(mark.get("radius", 72.0)), int(mark.get("seed", 0)))
		elif skill_id == "xun_wind_break" and phase == "windup":
			_draw_tianji_wind(center, direction, alpha, progress, phase, float(mark.get("range", 206.0)), float(mark.get("width", 86.0)))
		elif skill_id == "fire_rain_burning":
			_draw_tianji_fire_rain(center, alpha, progress, phase)
		elif skill_id == "arrow_support_volley":
			_draw_tianji_arrow_volley(center, alpha, progress, phase, float(mark.get("radius", TIANJI_ARROW_VOLLEY_RADIUS)))

func _draw_tianji_lightning(center: Vector2, alpha: float, progress: float, phase: String, rank: int, radius: float, seed: int) -> void:
	rank = clampi(rank, 1, 5)
	radius = maxf(1.0, radius)
	var pale := Color(0.55, 0.80, 1.0, alpha * 0.56)
	if phase == "windup":
		var pulse_radius := radius * (0.28 + progress * 0.72)
		for index in range(12):
			if index % 2 == 1:
				continue
			var angle := TAU * float(index) / 12.0 + visual_time * 0.42
			var direction := Vector2.from_angle(angle)
			draw_line(center + direction * (pulse_radius - 8.0), center + direction * pulse_radius, pale, 2.0)
		draw_arc(center, pulse_radius, 0.0, TAU, 18, Color(0.42, 0.66, 0.94, alpha * 0.46), 1.4)
		var strike_warning := clampf((progress - 0.72) / 0.28, 0.0, 1.0)
		if strike_warning > 0.0:
			var warning_radius := radius * (0.16 + strike_warning * 0.10)
			draw_circle(center, warning_radius, Color(0.62, 0.84, 1.0, strike_warning * 0.18))
			draw_arc(center, warning_radius, 0.0, TAU, 18, Color(0.82, 0.94, 1.0, strike_warning * 0.72), 1.8)
		return
	var sequence: Array = TIANJI_LIGHTNING_FRAME_SEQUENCES.get(rank, TIANJI_LIGHTNING_FRAME_SEQUENCES[1]) as Array
	var frame_index := mini(int(floor(progress * float(sequence.size()))), sequence.size() - 1)
	var texture: Texture2D = TIANJI_LIGHTNING_TEXTURES.get(str(sequence[frame_index])) as Texture2D
	if texture == null:
		return
	var fade_progress := clampf((progress - 0.72) / 0.28, 0.0, 1.0)
	var effect_alpha := 1.0 - fade_progress * 0.65
	var scale := maxf(0.12, radius / 570.0)
	_draw_tianji_lightning_sky_entry(center, rank, scale, effect_alpha, progress, seed)
	draw_set_transform(center, 0.0, Vector2(scale, scale))
	draw_texture(texture, -TIANJI_LIGHTNING_SOURCE_IMPACT_ANCHOR, Color(1.0, 1.0, 1.0, effect_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tianji_lightning_sky_entry(center: Vector2, rank: int, scale: float, alpha: float, progress: float, seed: int) -> void:
	var visible_rect := _visible_battle_rect()
	var entry := center + (TIANJI_LIGHTNING_SOURCE_ENTRY_ANCHOR - TIANJI_LIGHTNING_SOURCE_IMPACT_ANCHOR) * scale
	var root := Vector2(entry.x, visible_rect.position.y + TIANJI_LIGHTNING_SKY_EDGE_OFFSET)
	if entry.y <= root.y + 4.0:
		return
	var seed_value := float(seed)
	root.x += sin(seed_value * 0.013 + floor(visual_time * 20.0) * 1.7) * 12.0
	root.x = clampf(root.x, visible_rect.position.x + 12.0, visible_rect.end.x - 12.0)
	var segment_count := clampi(int(ceili(root.distance_to(entry) / 46.0)), 3, 10)
	var points := PackedVector2Array([root])
	for step in range(1, segment_count):
		var fraction := float(step) / float(segment_count)
		var base := root.lerp(entry, fraction)
		var jitter := sin(seed_value * 0.021 + float(step) * 2.37 + floor(visual_time * 24.0) * 0.91) * (6.0 + float(rank) * 0.75)
		points.append(base + Vector2(jitter, 0.0))
	points.append(entry)
	var entry_alpha := alpha * (0.78 + 0.22 * sin(progress * PI))
	draw_polyline(points, Color(0.26, 0.58, 1.0, entry_alpha * 0.30), 7.0 + float(rank) * 0.45, true)
	draw_polyline(points, Color(0.80, 0.92, 1.0, entry_alpha * 0.90), 2.0 + float(rank) * 0.12, true)
	draw_circle(root, 8.0 + float(rank) * 1.3, Color(0.56, 0.78, 1.0, entry_alpha * 0.28))

func _visible_battle_rect() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	if battle_camera != null and is_instance_valid(battle_camera) and viewport_size.x > 0.0 and viewport_size.y > 0.0:
		var zoom := battle_camera.zoom
		var visible_size := Vector2(
			viewport_size.x / maxf(0.01, zoom.x),
			viewport_size.y / maxf(0.01, zoom.y)
		)
		return Rect2(battle_camera.get_screen_center_position() - visible_size * 0.5, visible_size)
	var fallback_center := player.position if player != null else bounds.get_center()
	var fallback_size := viewport_size if viewport_size.x > 0.0 and viewport_size.y > 0.0 else Vector2(1280.0, 720.0)
	return Rect2(fallback_center - fallback_size * 0.5, fallback_size)

func _draw_tianji_wind(origin: Vector2, direction: Vector2, alpha: float, progress: float, phase: String, requested_range: float, requested_width: float) -> void:
	var forward := direction.normalized()
	if forward.length_squared() <= 0.01:
		forward = Vector2.RIGHT
	var perpendicular := Vector2(-forward.y, forward.x)
	var range := requested_range if requested_range > 0.0 else 206.0
	var width := requested_width if requested_width > 0.0 else 86.0
	if phase != "windup" and requested_range > 0.0:
		origin += forward * ((range + width * 2.0) * progress - width)
	var spread := range * (progress if phase == "windup" else 1.0)
	for index in range(5):
		var lane := float(index - 2) * width * 0.18
		var start := origin + perpendicular * lane + forward * (12.0 + float(index % 2) * 14.0)
		var end := origin + perpendicular * lane + forward * maxf(20.0, spread - float(index % 2) * 16.0)
		var stripe_alpha := alpha * (0.28 + float(index % 3) * 0.10)
		draw_line(start, end, Color(0.58, 0.88, 0.72, stripe_alpha), 2.0 + float(index % 2))
		var tip := end
		draw_line(tip - forward * 10.0 + perpendicular * 5.0, tip, Color(0.82, 0.96, 0.78, stripe_alpha), 1.6)
		draw_line(tip - forward * 10.0 - perpendicular * 5.0, tip, Color(0.82, 0.96, 0.78, stripe_alpha), 1.6)
	if phase != "windup":
		var edge_alpha := alpha * 0.55
		draw_line(origin + perpendicular * width * 0.5, origin + forward * range + perpendicular * width * 0.30, Color(0.44, 0.76, 0.62, edge_alpha), 1.5)
		draw_line(origin - perpendicular * width * 0.5, origin + forward * range - perpendicular * width * 0.30, Color(0.44, 0.76, 0.62, edge_alpha), 1.5)

func _draw_tianji_wind_marks() -> void:
	for mark in tianji_wind_marks:
		var duration := maxf(0.01, float(mark.get("duration", 0.42)))
		var elapsed := maxf(0.0, float(mark.get("elapsed", 0.0)))
		var progress := clampf(elapsed / duration, 0.0, 1.0)
		var formation_duration := float(TIANJI_WIND_FORMATION_FRAMES.size()) * TIANJI_WIND_FORMATION_FRAME_DURATION
		var collapse_duration := float(TIANJI_WIND_COLLAPSE_FRAMES.size()) * TIANJI_WIND_COLLAPSE_FRAME_DURATION
		var collapse_start := maxf(formation_duration, duration - collapse_duration)
		var frame_index := 0
		var texture: Texture2D
		var alpha := 1.0
		if elapsed < formation_duration:
			frame_index = mini(int(floor(elapsed / TIANJI_WIND_FORMATION_FRAME_DURATION)), TIANJI_WIND_FORMATION_FRAMES.size() - 1)
			texture = TIANJI_WIND_TEXTURES[TIANJI_WIND_FORMATION_FRAMES[frame_index]]
		elif elapsed >= collapse_start:
			var collapse_elapsed := elapsed - collapse_start
			frame_index = mini(int(floor(collapse_elapsed / TIANJI_WIND_COLLAPSE_FRAME_DURATION)), TIANJI_WIND_COLLAPSE_FRAMES.size() - 1)
			texture = TIANJI_WIND_TEXTURES[TIANJI_WIND_COLLAPSE_FRAMES[frame_index]]
			alpha = clampf(1.0 - collapse_elapsed / collapse_duration * 0.12, 0.0, 1.0)
		else:
			var core_elapsed := elapsed - formation_duration
			frame_index = int(floor(core_elapsed / TIANJI_WIND_CORE_FRAME_DURATION)) % TIANJI_WIND_CORE_FRAMES.size()
			texture = TIANJI_WIND_TEXTURES[TIANJI_WIND_CORE_FRAMES[frame_index]]
		if texture == null:
			continue
		var origin: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		direction = direction.normalized()
		var travel_distance := maxf(1.0, float(mark.get("travel_distance", 1.0)))
		var current_origin := origin + direction * travel_distance * progress
		var width := maxf(48.0, float(mark.get("width", 86.0)))
		var scale := clampf(width / 220.0, 0.28, 1.32)
		draw_set_transform(current_origin, 0.0, Vector2(scale, scale))
		draw_texture(texture, -TIANJI_WIND_SOURCE_ANCHOR, Color(1.0, 1.0, 1.0, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tianji_water_marks() -> void:
	for mark in tianji_water_marks:
		var elapsed := maxf(0.0, float(mark.get("elapsed", 0.0)))
		var origin: Vector2 = mark.get("origin", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		direction = direction.normalized()
		var travel_distance := maxf(1.0, float(mark.get("travel_distance", 340.0)))
		var width := maxf(96.0, float(mark.get("width", 124.0)))
		var rank := clampi(int(mark.get("rank", 1)), 1, 5)
		var surge_duration := maxf(0.60, float(mark.get("surge_duration", 1.55)))
		var reflux_delay := maxf(0.0, float(mark.get("reflux_delay", 0.16 if rank >= 5 else 0.0)))
		var reflux_duration := maxf(0.0, float(mark.get("reflux_duration", 0.72 if rank >= 5 else 0.0)))
		var layer_count := clampi(int(mark.get("layer_count", _tianji_water_layer_count(rank))), 3, 5)
		var layer_stagger := maxf(0.18, float(mark.get("layer_stagger", _tianji_water_layer_stagger(layer_count))))
		var layer_duration := surge_duration + (reflux_delay + reflux_duration if rank >= 5 else 0.0)
		var perpendicular := Vector2(-direction.y, direction.x)
		for layer in range(layer_count - 1, -1, -1):
			var local_elapsed := elapsed - float(layer) * layer_stagger
			if local_elapsed < 0.0 or local_elapsed > layer_duration + 0.18:
				continue
			var profile_index := clampi(layer, 0, TIANJI_WATER_LAYER_SIZE_RATIOS.size() - 1)
			var layer_width := width * float(TIANJI_WATER_LAYER_SIZE_RATIOS[profile_index])
			var layer_alpha := float(TIANJI_WATER_LAYER_ALPHAS[profile_index])
			var layer_offset := perpendicular * width * float(TIANJI_WATER_LAYER_Y_RATIOS[profile_index])
			var life_alpha := 1.0
			if local_elapsed > layer_duration:
				life_alpha = clampf(1.0 - (local_elapsed - layer_duration) / 0.18, 0.0, 1.0)
			layer_alpha *= life_alpha
			var frame_offset := int(TIANJI_WATER_LAYER_FRAME_OFFSETS[profile_index])
			var animation_speed := float(TIANJI_WATER_LAYER_SPEEDS[profile_index])
			if local_elapsed <= surge_duration:
				var progress := clampf(local_elapsed / surge_duration, 0.0, 1.0)
				var current := origin + direction * travel_distance * progress + layer_offset
				_draw_tianji_water_wave(current, direction, layer_width, rank, progress, layer_alpha, surge_duration, frame_offset, animation_speed)
			elif rank >= 5 and reflux_duration > 0.0 and local_elapsed > surge_duration + reflux_delay:
				var reflux_progress := clampf((local_elapsed - surge_duration - reflux_delay) / reflux_duration, 0.0, 1.0)
				var end := origin + direction * travel_distance
				var current := end.lerp(origin, reflux_progress) + layer_offset
				_draw_tianji_water_wave(current, -direction, layer_width * 0.88, rank, reflux_progress, layer_alpha * 0.76, reflux_duration, frame_offset + 1, animation_speed * 1.06)

func _tianji_water_layer_count(rank: int) -> int:
	return clampi(2 + ceili(float(clampi(rank, 1, 5)) / 2.0), 3, 5)

func _tianji_water_layer_stagger(layer_count: int) -> float:
	return clampf(0.18 + float(clampi(layer_count, 3, 5) - 3) * 0.04, 0.18, 0.26)

func _draw_tianji_water_wave(center: Vector2, direction: Vector2, width: float, rank: int, progress: float, alpha: float, wave_duration: float = 1.55, frame_offset: int = 0, animation_speed: float = 1.0) -> void:
	wave_duration = maxf(0.35, wave_duration)
	var formation_duration := 0.30
	var collapse_duration := minf(0.52, wave_duration * 0.34)
	var collapse_start := 1.0 - collapse_duration / wave_duration
	var frame_index := 0
	var frame_alpha := alpha
	var animated_elapsed := clampf(progress * wave_duration * maxf(0.75, animation_speed) + float(frame_offset) * TIANJI_WATER_PEAK_FRAME_DURATION, 0.0, wave_duration)
	var animated_progress := animated_elapsed / wave_duration
	if animated_progress < formation_duration / wave_duration:
		frame_index = clampi(int(floor(animated_elapsed / TIANJI_WATER_FORMATION_FRAME_DURATION)), 0, 5)
	elif animated_progress >= collapse_start:
		var collapse_progress := clampf((animated_progress - collapse_start) / (1.0 - collapse_start), 0.0, 1.0)
		frame_index = 14 + clampi(int(floor(collapse_progress * 10.0)), 0, 9)
		frame_alpha *= 1.0 - collapse_progress * 0.55
	else:
		var core_elapsed := animated_elapsed - formation_duration
		frame_index = 6 + (int(floor(core_elapsed / TIANJI_WATER_PEAK_FRAME_DURATION)) % 8)
	var texture: Texture2D = TIANJI_WATER_TEXTURES[clampi(frame_index, 0, TIANJI_WATER_TEXTURES.size() - 1)]
	var middle_texture: Texture2D = TIANJI_WATER_TEXTURES[clampi(frame_index + 1, 0, TIANJI_WATER_TEXTURES.size() - 1)]
	var scale := clampf(width / 255.0, 0.58, 1.28)
	var horizontal_scale := 1.16 + float(rank) * 0.10
	var rotation := direction.angle()
	var perpendicular := Vector2(-direction.y, direction.x)
	var wake_alpha := frame_alpha * 0.20
	_draw_ellipse_arc(center - direction * (width * 0.12) + Vector2(0.0, 11.0), Vector2(width * 0.62, width * 0.18), rotation, rotation + PI, 18, Color(0.27, 0.75, 0.88, wake_alpha), 3.0)
	# Three restrained texture layers create depth without turning the flood into
	# a particle swarm: rear wake, offset middle swell, and the readable crest.
	var trail_center := center - direction * (width * 0.56) + perpendicular * sin(progress * PI) * width * 0.06
	draw_set_transform(trail_center + Vector2(0.0, -8.0), rotation, Vector2(scale * horizontal_scale * 0.92, scale * 0.84))
	draw_texture(texture, -TIANJI_WATER_SOURCE_ANCHOR, Color(0.70, 0.91, 0.98, frame_alpha * 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var middle_center := center - direction * (width * 0.22) + perpendicular * sin(progress * PI + 1.2) * width * 0.045
	draw_set_transform(middle_center + Vector2(0.0, -12.0), rotation, Vector2(scale * horizontal_scale * 1.04, scale * 0.78))
	draw_texture(middle_texture, -TIANJI_WATER_SOURCE_ANCHOR, Color(0.76, 0.94, 1.0, frame_alpha * 0.38))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_set_transform(center + Vector2(0.0, -8.0), rotation, Vector2(scale * horizontal_scale, scale * 0.82))
	draw_texture(texture, -TIANJI_WATER_SOURCE_ANCHOR, Color(0.82, 0.96, 1.0, frame_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tianji_fire_rain(center: Vector2, alpha: float, progress: float, phase: String) -> void:
	if phase == "windup":
		for index in range(5):
			var x_offset := float(index - 2) * 9.0
			draw_line(center + Vector2(x_offset, -60.0 - progress * 34.0), center + Vector2(x_offset * 0.45, -24.0), Color(1.0, 0.72, 0.34, alpha * 0.34), 1.4)
		return
	var ground_center := center + Vector2(0.0, 11.0)
	var flame_alpha := alpha * (0.60 + sin(visual_time * 15.0 + center.x * 0.04) * 0.12)
	if progress < 0.18:
		var meteor_top := center + Vector2(-8.0, -166.0 + progress * 520.0)
		draw_line(meteor_top, center + Vector2(2.0, -4.0), Color(1.0, 0.86, 0.50, alpha * 0.80), 3.0)
		draw_line(meteor_top + Vector2(5.0, -12.0), center + Vector2(6.0, -4.0), Color(0.90, 0.28, 0.12, alpha * 0.64), 1.4)
	for index in range(6):
		var phase_offset := visual_time * (3.0 + float(index % 3)) + float(index) * 1.73 + center.x * 0.02
		var ember_position := ground_center + Vector2(sin(phase_offset) * (12.0 + float(index % 3) * 7.0), -4.0 - fmod(phase_offset * 14.0, 28.0))
		draw_rect(Rect2(ember_position, Vector2(3.0, 3.0)), Color(1.0, 0.72, 0.25, flame_alpha * (0.44 + float(index % 2) * 0.18)))

func _draw_tianji_arrow_volley(center: Vector2, alpha: float, progress: float, phase: String, radius: float) -> void:
	var ground_center := center + Vector2(0.0, 9.0)
	var outer_radius := maxf(48.0, radius)
	if phase != "windup":
		return
	var pulse_radius := outer_radius * progress
	draw_arc(ground_center, outer_radius, 0.0, TAU, 24, Color(0.73, 0.62, 0.34, alpha * 0.38), 1.4)
	draw_arc(ground_center, pulse_radius, 0.0, TAU, 20, Color(0.88, 0.76, 0.43, alpha * 0.62), 2.0)
	for index in range(16):
		if index % 2 != 0:
			continue
		var angle := TAU * float(index) / 16.0
		var radial := Vector2.from_angle(angle)
		draw_line(ground_center + radial * (outer_radius - 8.0), ground_center + radial * outer_radius, Color(0.82, 0.70, 0.39, alpha * 0.48), 2.0)

func _draw_tianji_arrow_marks() -> void:
	for volley in tianji_arrow_marks:
		var elapsed := float(volley.get("elapsed", 0.0))
		var center: Vector2 = volley.get("center", Vector2.ZERO)
		var radius := float(volley.get("radius", TIANJI_ARROW_VOLLEY_RADIUS))
		var arrows: Array = volley.get("arrows", []) as Array
		if bool(volley.get("show_ground_ring", true)):
			_draw_tianji_arrow_ground_ring(center, radius, elapsed)
		for arrow_value in arrows:
			var arrow: Dictionary = arrow_value as Dictionary
			_draw_tianji_arrow(arrow, elapsed)

func _draw_tianji_fire_rain_marks() -> void:
	var visible_rect := _visible_battle_rect()
	for index in range(tianji_fire_rain_marks.size()):
		var meteor: Dictionary = tianji_fire_rain_marks[index] as Dictionary
		var elapsed := float(meteor.get("elapsed", 0.0))
		var final_meteor := bool(meteor.get("final", false))
		var frame_duration := maxf(0.01, float(meteor.get("frame_duration", 0.035)))
		var flight_duration := TIANJI_FIRE_RAIN_FINAL_FLIGHT_DURATION if final_meteor else 0.34
		var feedback_elapsed := flight_duration + (frame_duration * float(TIANJI_FIRE_RAIN_FINAL_LANDING_FRAME) if final_meteor else 0.0)
		if elapsed >= feedback_elapsed and not bool(meteor.get("impact_feedback_played", false)):
			meteor["impact_feedback_played"] = true
			if final_meteor:
				var final_rank := int(meteor.get("rank", 1))
				shake_remaining = maxf(shake_remaining, 0.70 if final_rank >= 5 else 0.48)
				shake_strength = maxf(shake_strength, 32.0 if final_rank >= 5 else 22.0)
			elif bool(meteor.get("wave_last", false)):
				shake_remaining = maxf(shake_remaining, 0.18)
				shake_strength = maxf(shake_strength, 8.0)
			else:
				shake_remaining = maxf(shake_remaining, 0.09)
				shake_strength = maxf(shake_strength, 5.0)
			tianji_fire_rain_marks[index] = meteor
		var frame_count := int(meteor.get("frame_count", 1))
		var animation_duration := float(frame_count) * frame_duration
		var target: Vector2 = meteor.get("target", Vector2.ZERO)
		var scale := float(meteor.get("scale", 0.46))
		var sky_distance := float(meteor.get("sky_distance", 220.0))
		if elapsed < 0.0:
			continue
		var impact_elapsed := maxf(0.0, elapsed - flight_duration)
		var position := target
		var rotation := 0.0
		var alpha := 1.0
		if elapsed < flight_duration:
			var progress := clampf(elapsed / flight_duration, 0.0, 1.0)
			var fall_progress := progress * progress * (3.0 - 2.0 * progress)
			position = Vector2(target.x, visible_rect.position.y - sky_distance).lerp(target + Vector2(0.0, -12.0), fall_progress)
			rotation = lerpf(-0.18, 0.10, progress)
			var trail_end := position + Vector2(0.0, -58.0 - progress * 34.0).rotated(rotation)
			draw_line(position + Vector2(0.0, 18.0), trail_end, Color(1.0, 0.68, 0.25, 0.32), 5.0 if final_meteor else 2.8)
			draw_line(position + Vector2(0.0, 10.0), trail_end, Color(1.0, 0.92, 0.64, 0.58), 1.4 if final_meteor else 0.9)
		else:
			if impact_elapsed > animation_duration:
				alpha = clampf(1.0 - (impact_elapsed - animation_duration) / 0.28, 0.0, 1.0)
			if alpha <= 0.0:
				continue
		var frame_index := clampi(int(floor(maxf(0.0, impact_elapsed) / frame_duration)), 0, frame_count - 1)
		var textures: Array[Texture2D] = TIANJI_FIRE_RAIN_FINAL_TEXTURES if final_meteor else TIANJI_FIRE_RAIN_METEOR_TEXTURES
		var texture: Texture2D = textures[frame_index]
		if texture == null:
			continue
		# The source sequence has a fixed canvas and its impact point sits near the lower centre.
		var anchor_ratio := TIANJI_FIRE_RAIN_FINAL_ANCHOR_RATIO if final_meteor else Vector2(0.5, 0.72)
		var anchor := Vector2(texture.get_width() * anchor_ratio.x, texture.get_height() * anchor_ratio.y)
		if final_meteor:
			_draw_tianji_fire_rain_ground_ring(target, float(meteor.get("radius", 0.0)), elapsed, flight_duration, impact_elapsed, alpha)
		draw_set_transform(position, rotation, Vector2(scale, scale))
		draw_texture(texture, -anchor, Color(1.0, 1.0, 1.0, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tianji_fire_rain_ground_ring(center: Vector2, radius: float, elapsed: float, flight_duration: float, impact_elapsed: float, alpha: float) -> void:
	if radius <= 1.0 or elapsed < -0.10:
		return
	var anticipation := clampf((elapsed + 0.10) / 0.24, 0.0, 1.0)
	var fade := alpha
	if impact_elapsed > 0.0:
		fade *= clampf(1.0 - impact_elapsed / 1.15, 0.0, 1.0)
	var pulse := 0.94 + 0.06 * sin(visual_time * 10.0)
	var ring_radius := radius * (0.96 + 0.025 * pulse)
	var ring_alpha := fade * (0.20 + anticipation * 0.24)
	draw_circle(center, radius * 0.78, Color(1.0, 0.30, 0.08, ring_alpha * 0.07))
	draw_arc(center, ring_radius, 0.0, TAU, 40, Color(1.0, 0.68, 0.24, ring_alpha), 2.0, true)
	if elapsed < flight_duration:
		var marker_progress := clampf(elapsed / maxf(0.01, flight_duration), 0.0, 1.0)
		var marker_radius := lerpf(radius * 0.20, radius * 0.86, marker_progress)
		draw_arc(center, marker_radius, 0.0, TAU, 28, Color(1.0, 0.90, 0.54, ring_alpha * 0.72), 1.2, true)

func _draw_tianji_arrow_ground_ring(center: Vector2, radius: float, elapsed: float) -> void:
	var fade := clampf(1.0 - elapsed / 0.42, 0.0, 1.0)
	if fade <= 0.0:
		return
	var pulse := (0.18 + sin(elapsed * 8.0) * 0.04) * fade
	draw_arc(center, maxf(48.0, radius), 0.0, TAU, 24, Color(0.71, 0.58, 0.30, pulse), 1.0)

func _draw_tianji_arrow(arrow: Dictionary, elapsed: float) -> void:
	var delay := float(arrow.get("delay", 0.0))
	var local_time := elapsed - delay
	if local_time < 0.0:
		return
	var origin: Vector2 = arrow.get("origin", Vector2.ZERO)
	var target: Vector2 = arrow.get("target", origin)
	var flight_duration := maxf(0.12, float(arrow.get("flight_duration", TIANJI_ARROW_FLIGHT_DURATION)))
	if local_time < flight_duration:
		var progress := clampf(local_time / flight_duration, 0.0, 1.0)
		# The arrow is already moving as it crosses the top of the screen, then
		# accelerates into the ground to make each impact read as a heavy volley.
		var fall_progress := progress * (0.42 + 0.58 * progress)
		var position := origin.lerp(target, fall_progress)
		var tangent := (target - origin).normalized()
		if tangent.length_squared() <= 0.01:
			tangent = Vector2.DOWN
		var perpendicular := Vector2(-tangent.y, tangent.x)
		var arrow_tip := position + tangent * 12.0
		var arrow_tail := arrow_tip - tangent * 46.0
		var trail_length := TIANJI_ARROW_TRAIL_LENGTH * (0.78 + progress * 0.22)
		var trail_alpha := 0.18 + progress * 0.24
		var trail_start := arrow_tail + tangent * 3.0
		var trail_mid := trail_start - tangent * trail_length * 0.42
		var trail_end := trail_start - tangent * trail_length
		# Layered white strokes make the long tail fade into the sky without
		# becoming an opaque cone that hides the physical arrow silhouette.
		draw_line(trail_start, trail_mid, Color(0.94, 0.97, 1.0, trail_alpha), 2.8)
		draw_line(trail_mid, trail_end, Color(0.94, 0.97, 1.0, trail_alpha * 0.42), 1.6)
		draw_line(trail_start, trail_mid, Color(1.0, 1.0, 1.0, trail_alpha * 0.88), 1.1)
		draw_set_transform(position, tangent.angle(), Vector2(TIANJI_ARROW_TEXTURE_SCALE, TIANJI_ARROW_TEXTURE_SCALE))
		draw_texture(ARCHER_PROJECTILE_TEXTURE, -TIANJI_ARROW_SOURCE_ANCHOR, Color(1.0, 0.95, 0.80, 0.98))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_draw_tianji_arrow_silhouette(arrow_tip, tangent, 0.98, 46.0, true)
		return
	var lodged_time := local_time - flight_duration
	if lodged_time >= TIANJI_ARROW_LODGED_DURATION:
		return
	var fade_start := TIANJI_ARROW_LODGED_DURATION - 0.24
	var lodged_alpha := 0.78 if lodged_time < fade_start else 0.78 * (1.0 - (lodged_time - fade_start) / 0.24)
	var lodged_direction: Vector2 = arrow.get("lodged_direction", Vector2.DOWN)
	var perpendicular := Vector2(-lodged_direction.y, lodged_direction.x)
	_draw_ellipse_arc(target + Vector2(0.0, 2.0), Vector2(10.0, 3.2), 0.0, TAU, 10, Color(0.18, 0.12, 0.07, lodged_alpha * 0.48), 1.3)
	if lodged_time < 0.12:
		var impact_alpha := (1.0 - lodged_time / 0.12) * lodged_alpha
		_draw_ellipse_arc(target + Vector2(0.0, 2.0), Vector2(20.0, 6.0), 0.0, TAU, 14, Color(0.72, 0.54, 0.28, impact_alpha * 0.58), 1.5)
		draw_line(target - perpendicular * 10.0, target + perpendicular * 4.0, Color(0.82, 0.62, 0.34, impact_alpha * 0.72), 1.6)
		draw_line(target + perpendicular * 8.0, target - perpendicular * 3.0, Color(0.74, 0.56, 0.31, impact_alpha * 0.58), 1.2)
	draw_line(target + perpendicular * 2.0, target + lodged_direction * 7.0 + perpendicular * 2.0, Color(0.49, 0.34, 0.18, lodged_alpha * 0.60), 1.2)
	draw_set_transform(target, lodged_direction.angle(), Vector2(TIANJI_ARROW_TEXTURE_SCALE, TIANJI_ARROW_TEXTURE_SCALE))
	var source_size := TIANJI_ARROW_SOURCE_EXPOSED.size
	var destination := Rect2(Vector2(-source_size.x, -source_size.y * 0.5), source_size)
	draw_texture_rect_region(ARCHER_PROJECTILE_TEXTURE, destination, TIANJI_ARROW_SOURCE_EXPOSED, Color(1.0, 0.91, 0.67, lodged_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_tianji_arrow_silhouette(target + lodged_direction * 4.0, lodged_direction, lodged_alpha, 34.0, false)

func _draw_tianji_arrow_silhouette(tip: Vector2, direction: Vector2, alpha: float, exposed_length: float, draw_head: bool) -> void:
	var forward := direction.normalized()
	if forward.length_squared() <= 0.01:
		forward = Vector2.DOWN
	var side := Vector2(-forward.y, forward.x)
	var tail := tip - forward * exposed_length
	var shaft_end := tip - forward * (3.5 if draw_head else 0.0)
	# The existing projectile texture is intentionally retained, but its very thin
	# source art needs this readable shaft, head, and fletching at battle scale.
	draw_line(tail, shaft_end, Color(0.16, 0.12, 0.08, alpha * 0.98), 2.7)
	draw_line(tail + forward * 3.0, shaft_end - forward * 5.0, Color(0.78, 0.67, 0.45, alpha * 0.78), 0.9)
	var feather_base := tail + forward * 6.0
	draw_line(feather_base + side * 4.2, tail - forward * 5.5 + side * 1.2, Color(0.58, 0.50, 0.34, alpha * 0.90), 1.7)
	draw_line(feather_base - side * 4.2, tail - forward * 5.5 - side * 1.2, Color(0.58, 0.50, 0.34, alpha * 0.90), 1.7)
	if not draw_head:
		return
	var head_base := tip - forward * 10.0
	var head := PackedVector2Array([tip, head_base + side * 5.0, head_base - side * 5.0])
	draw_colored_polygon(head, Color(0.20, 0.22, 0.23, alpha * 0.98))
	var head_highlight := PackedVector2Array([tip - forward * 1.5, head_base + side * 1.6, head_base - side * 0.8])
	draw_colored_polygon(head_highlight, Color(0.78, 0.80, 0.76, alpha * 0.54))


func _draw_impacts() -> void:
	for impact in impact_marks:
		var heavy_hit: bool = impact.label in ["穿阵挑刺", "破军", "破军收势", "七进七出", "七进七出·收势", "哪吒火轮"]
		var duration := 0.18 if heavy_hit else 0.13
		var alpha := clampf(impact.remaining / duration, 0.0, 1.0)
		var radius := 18.0 + float(impact.hits) * 2.5 + (1.0 - alpha) * (28.0 if heavy_hit else 18.0)
		var color := Color(0.72, 0.94, 1.0, alpha) if heavy_hit else Color(1.0, 0.88, 0.52, alpha)
		var ray_count := mini(8, 4 + int(impact.hits))
		for index in range(ray_count):
			var angle := 0.18 + TAU * float(index) / float(ray_count)
			var direction := Vector2.from_angle(angle)
			draw_line(impact.position + direction * 5.0, impact.position + direction * radius, color, 3.0 if heavy_hit else 2.5)
		if heavy_hit:
			draw_arc(impact.position, radius * (0.46 + (1.0 - alpha) * 0.22), 0.0, TAU, 18, Color(color.r, color.g, color.b, alpha * 0.62), 2.0)

func _draw_named_hit_feedback() -> void:
	for mark in named_hit_marks:
		var duration := maxf(0.01, float(mark.get("duration", 0.24)))
		var alpha := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var progress := 1.0 - alpha
		var strength := float(mark.get("strength", 0.5))
		var emphasized := bool(mark.get("emphasized", false))
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		var perpendicular := Vector2(-direction.y, direction.x)
		var seed := int(mark.get("seed", 0))
		var burst := sin(clampf(progress, 0.0, 1.0) * PI)
		var base_color := Color("f4d17a") if emphasized else Color("b9e6ed")
		var ring_radius := 12.0 + progress * (34.0 if emphasized else 27.0)
		var ring_alpha := alpha * (0.72 + burst * 0.28)
		_draw_ellipse_arc(center + Vector2(0.0, 16.0), Vector2(ring_radius, ring_radius * 0.28), 0.0, TAU, 18, Color(base_color.r, base_color.g, base_color.b, ring_alpha * 0.82), 2.0 if emphasized else 1.5)
		if progress < 0.24:
			var flash_alpha := (1.0 - progress / 0.24) * (0.46 if emphasized else 0.28)
			draw_circle(center + Vector2(0.0, -14.0), 10.0 + strength * 8.0, Color(1.0, 0.96, 0.78, flash_alpha))
		var shard_count := 7 if emphasized else 5
		for index in range(shard_count):
			var angle := direction.angle() + (float(index) - float(shard_count - 1) * 0.5) * 0.42 + float((seed + index * 13) % 7 - 3) * 0.035
			var shard_direction := Vector2.from_angle(angle)
			var travel := 8.0 + progress * (38.0 + float((seed + index * 5) % 9))
			var shard_center := center + shard_direction * travel + Vector2(0.0, -8.0 + float(index % 3) * 4.0)
			var shard_length := 5.0 + float((seed + index * 7) % 4)
			var shard_width := 1.2 if index % 2 == 0 else 1.8
			var shard_color := Color(base_color.r, base_color.g, base_color.b, alpha * (0.62 - float(index) * 0.045))
			draw_line(shard_center - shard_direction * shard_length, shard_center + shard_direction * shard_length, shard_color, shard_width)
			if index % 2 == 0:
				draw_rect(Rect2(shard_center - Vector2(1.5, 1.5), Vector2(3.0, 3.0)), Color(1.0, 0.90, 0.58, alpha * 0.62))
		for index in range(3):
			var dust_side := -1.0 if (seed + index) % 2 == 0 else 1.0
			var dust_center := center + Vector2(0.0, 19.0) + perpendicular * dust_side * (8.0 + progress * 16.0) + direction * (progress * 10.0)
			var dust_size := 2.0 + float(index % 2)
			draw_rect(Rect2(dust_center - Vector2(dust_size, dust_size * 0.5), Vector2(dust_size * 2.0, dust_size)), Color(0.76, 0.67, 0.48, alpha * (0.28 - float(index) * 0.05)))

func _draw_weapon_clashes() -> void:
	for mark in weapon_clash_marks:
		var duration := maxf(0.01, float(mark.get("duration", 0.30)))
		var alpha := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var perfect := bool(mark.get("perfect", false))
		var skill_clash := bool(mark.get("skill", false))
		var minor := bool(mark.get("minor", false))
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var ray_count := 9 if minor else (24 if perfect else (20 if skill_clash else 15))
		var seed := int(mark.get("seed", 0))
		var radius := lerpf(14.0, 34.0 if minor else (78.0 if perfect else (66.0 if skill_clash else 52.0)), 1.0 - alpha)
		var core_color := Color(0.76, 0.96, 1.0, alpha) if skill_clash else Color(1.0, 0.92, 0.60, alpha)
		var spark_color := Color(0.96, 0.72, 0.22, alpha)
		var hot_color := Color(1.0, 0.98, 0.82, alpha * 0.96)
		for index in range(ray_count):
			var angle := TAU * float(index) / float(ray_count) + float(seed) * 0.37 + sin(float(index) * 1.71 + float(seed)) * 0.12
			var direction := Vector2.from_angle(angle)
			var length_scale := 0.54 + float((index * 7 + seed) % 6) * 0.10
			var start := center + direction * (4.0 + float(index % 3) * 2.0)
			var end := center + direction * radius * length_scale
			draw_line(start, end, spark_color if index % 3 != 0 else core_color, 1.8 if minor else (2.8 if index % 4 == 0 else 1.8))
			if index % 2 == 0:
				var ember_size := 2.0 if index % 4 == 0 else 1.5
				draw_rect(Rect2(end - Vector2.ONE * ember_size, Vector2.ONE * ember_size * 2.0), hot_color)
		var cross_radius := radius * (0.30 + (1.0 - alpha) * 0.14)
		for direction in [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]:
			draw_line(center + direction * 4.0, center + direction * cross_radius, hot_color, 1.6 if minor else (3.0 if perfect else 2.4))
		draw_circle(center, 4.0 + (1.0 - alpha) * (5.0 if minor else (10.0 if perfect else 7.0)), Color(1.0, 0.98, 0.82, alpha))
		draw_circle(center, 2.0 + (1.0 - alpha) * (3.0 if minor else 5.0), core_color)
		if perfect or skill_clash:
			var ring_color := Color(1.0, 0.82, 0.34, alpha * 0.88) if perfect else Color(0.56, 0.94, 1.0, alpha * 0.82)
			draw_arc(center, radius * 0.56, 0.0, TAU, 18, ring_color, 2.8)
			draw_arc(center, radius * 0.34, 0.25, TAU + 0.25, 14, Color(1.0, 0.94, 0.66, alpha * 0.74), 1.8)

func _draw_guard_feedback() -> void:
	for mark in guard_feedback_marks:
		var duration := maxf(0.01, float(mark.get("duration", 0.32)))
		var alpha := clampf(float(mark.get("remaining", 0.0)) / duration, 0.0, 1.0)
		var progress := 1.0 - alpha
		var perfect := bool(mark.get("perfect", false))
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var direction: Vector2 = mark.get("direction", Vector2.RIGHT)
		var angle := direction.angle()
		var radius := lerpf(18.0, 62.0 if perfect else 50.0, progress)
		var color := Color(1.0, 0.86, 0.34, alpha * 0.92) if perfect else Color(0.72, 0.94, 1.0, alpha * 0.86)
		draw_arc(center, radius, angle - 0.92, angle + 0.92, 14, color, 3.2 if perfect else 2.4, true)
		draw_arc(center, radius * 0.72, angle - 0.66, angle + 0.66, 10, Color(1.0, 0.98, 0.80, alpha * 0.82), 1.5, true)
		var shard_count := 7 if perfect else 5
		for index in range(shard_count):
			var shard_angle := angle + (float(index) - float(shard_count - 1) * 0.5) * 0.22
			var shard_direction := Vector2.from_angle(shard_angle)
			var start := center + shard_direction * (8.0 + progress * 6.0)
			var end := start + shard_direction * (12.0 + progress * (22.0 if perfect else 16.0))
			draw_line(start, end, color, 2.2 if perfect else 1.6)
		if progress < 0.24:
			draw_circle(center + direction * 5.0, 11.0 + (1.0 - progress) * 8.0, Color(1.0, 0.98, 0.82, (1.0 - progress / 0.24) * (0.52 if perfect else 0.34)))

func _draw_stance_breaks() -> void:
	for mark in stance_break_marks:
		var alpha := clampf(float(mark.get("remaining", 0.0)) / 0.48, 0.0, 1.0)
		var center: Vector2 = mark.get("position", Vector2.ZERO)
		var radius := lerpf(20.0, 74.0, 1.0 - alpha)
		draw_arc(center, radius, 0.0, TAU, 18, Color(1.0, 0.77, 0.28, alpha * 0.88), 2.6)
		for index in range(5):
			var direction := Vector2.from_angle(TAU * float(index) / 5.0 + 0.22)
			draw_line(center + direction * 8.0, center + direction * radius * 0.72, Color(0.60, 0.92, 1.0, alpha * 0.76), 2.0)

func _draw_named_stance_break_marker(at: Vector2, scale: float) -> void:
	var pulse := 0.80 + 0.20 * (sin(visual_time * 14.0) + 1.0) * 0.5
	var radius := 38.0 * scale * pulse
	for index in range(3):
		var start_angle := -1.02 + float(index) * 2.10
		draw_arc(at, radius, start_angle, start_angle + 0.68, 8, Color(1.0, 0.76, 0.24, 0.90), 2.3)
	draw_string(ThemeDB.fallback_font, at + Vector2(-16.0, -68.0 * scale), "破势", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffe2a0"))

func _draw_named_vulnerable_marker(at: Vector2, scale: float, remaining_ratio: float) -> void:
	var pulse := 0.78 + 0.22 * (sin(visual_time * 8.0) + 1.0) * 0.5
	var center := at + Vector2(0.0, -108.0 * scale)
	var radius := 24.0 * scale * pulse
	var color := Color("ff9a4a")
	draw_circle(center, radius * 0.72, Color(0.22, 0.06, 0.03, 0.72))
	draw_arc(center, radius, -PI * 0.5, TAU - PI * 0.5, 22, Color(0.20, 0.07, 0.04, 0.94), 3.4 * scale, true)
	draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * clampf(remaining_ratio, 0.0, 1.0), 22, Color(color.r, color.g, color.b, pulse), 3.4 * scale, true)
	draw_string(ThemeDB.fallback_font, center + Vector2(-22.0 * scale, 5.0 * scale), "虚弱", HORIZONTAL_ALIGNMENT_CENTER, 44.0 * scale, int(15.0 * scale), Color("fff1c6"))

func _enemy_color(enemy_type: int) -> Color:
	match enemy_type:
		EnemySimulation.EnemyType.ARCHER: return Color("705451")
		EnemySimulation.EnemyType.CROSSBOW: return Color("684a3c")
		EnemySimulation.EnemyType.HALBERD: return Color("574d60")
		EnemySimulation.EnemyType.SHIELD: return Color("53616a")
		EnemySimulation.EnemyType.SPEAR: return Color("536f5b")
		EnemySimulation.EnemyType.BANNER: return Color("7e4039")
		EnemySimulation.EnemyType.CAVALRY: return Color("5d4435")
		EnemySimulation.EnemyType.ELITE: return Color("8d343d")
		EnemySimulation.EnemyType.GUARD: return Color("794349")
		_: return Color("4e555d")

func _telegraph_colors(telegraph: Telegraph) -> Dictionary:
	var named_attack := _uses_named_attack_vfx(telegraph)
	var fill_alpha := 0.16 if named_attack else 0.22
	var outline_alpha := 0.80 if named_attack else 0.94
	match telegraph.threat_kind:
		Telegraph.ThreatKind.ACTIVE:
			return {"fill": Color(0.62, 0.20, 0.78, fill_alpha), "outline": Color(0.88, 0.52, 1.0, outline_alpha)}
		Telegraph.ThreatKind.UNBLOCKABLE:
			return {"fill": Color(0.82, 0.10, 0.16, fill_alpha), "outline": Color(1.0, 0.34, 0.30, outline_alpha)}
		_:
			return {"fill": Color(0.94, 0.58, 0.12, fill_alpha), "outline": Color(1.0, 0.78, 0.30, outline_alpha)}

func _uses_named_attack_vfx(telegraph: Telegraph) -> bool:
	if telegraph.source == "boss":
		return boss != null and boss.archetype in [BossActor.Archetype.ZHANG_HE, BossActor.Archetype.LV_BU]
	if not telegraph.source.begins_with("elite:"):
		return false
	for elite in elites:
		if not is_instance_valid(elite) or elite.telegraph_source != telegraph.source:
			continue
		return elite.archetype == EliteActor.Archetype.XIAHOU_EN or elite.archetype == EliteActor.Archetype.CHUNYU_DAO
	return false
