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
const SPEAR_VFX_HEIGHT_OFFSET := Vector2(0, -12)
const SWEEP_VFX_HEIGHT_OFFSET := Vector2(0, -22)
const FLASH_DURATION := 0.16
const ENEMY_MOVE_ANIMATION_HOLD := 0.12
const PLAYER_ULTIMATE_SOURCE_FOOT_ANCHOR := Vector2(64, 108)
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
const ARCHER_PROJECTILE_LAUNCH_RATIO := 0.25
const ARCHER_PROJECTILE_ARC_HEIGHT := 44.0
const ARCHER_PROJECTILE_SCALE := 0.45
const ARCHER_PROJECTILE_SOURCE_ANCHOR := Vector2(64, 32)
const PLAYER_IDLE_FRAME_ORDER := [0, 1, 2, 3, 2, 1]
const PLAYER_IDLE_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-04.png"),
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
const PLAYER_ULTIMATE_TEXTURE := preload("res://assets/art/characters/zhao_yun/sprites/ultimate_right/zhaoyun-ultimate-right-01.png")
const CHANGBAN_GRASS_TEXTURE := preload("res://assets/art/environment/changban/grass-base-01.png")
const CHANGBAN_DIRT_TEXTURE := preload("res://assets/art/environment/changban/dirt-base-01.png")
const CHANGBAN_GRASS_DIRT_TEXTURE := preload("res://assets/art/environment/changban/grass-dirt-base-01.png")
const CHANGBAN_TRAMPLED_PATCH_01 := preload("res://assets/art/environment/changban/trampled-patch-01.png")
const CHANGBAN_TRAMPLED_PATCH_02 := preload("res://assets/art/environment/changban/trampled-patch-02.png")
const CHANGBAN_SLOPE_TEXTURE := preload("res://assets/art/environment/changban/slope-chunk-01.png")
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
	preload("res://assets/art/enemies/halberd/walk_right/halberd-walk-right-04.png"),
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
const ARCHER_PROJECTILE_TEXTURE := preload("res://assets/art/projectiles/archer-arrow.png")

var bounds := Rect2(0, 0, 2560, 1440)
var enemies: EnemySimulation
var player: PlayerActor
var boss: BossActor
var elites: Array[EliteActor] = []
var telegraphs: Array[Telegraph] = []
var loot
var flashes: Array[Dictionary] = []
var pickup_marks: Array[Dictionary] = []
var impact_marks: Array[Dictionary] = []
var shield_break_marks: Array[Dictionary] = []
var ultimate_wave_marks: Array[Dictionary] = []
var death_collision_marks: Array[Dictionary] = []
var archer_projectiles: Array[Dictionary] = []
var archer_impact_marks: Array[Dictionary] = []
var visual_time := 0.0
var shake_remaining := 0.0
var shake_strength := 0.0
var player_last_position := Vector2.ZERO
var player_is_moving := false
var player_faces_left := false
var player_idle_time := 0.0
var player_walk_time := 0.0
var player_attack_01_time := 0.0
var player_is_playing_attack_01 := false
var player_attack_02_time := 0.0
var player_is_playing_attack_02 := false
var player_attack_03_time := 0.0
var player_is_playing_attack_03 := false
var player_hit_flash_remaining := 0.0
var player_hit_flash_strength := 0.0
var enemy_last_positions: Array[Vector2] = []
var enemy_is_moving := PackedByteArray()
var enemy_move_animation_holds := PackedFloat32Array()

func configure(world_bounds: Rect2, enemy_simulation: EnemySimulation, player_actor: PlayerActor, boss_actor: BossActor, active_telegraphs: Array[Telegraph], loot_system = null, elite_actors: Array[EliteActor] = []) -> void:
	bounds = world_bounds
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemies = enemy_simulation
	player = player_actor
	boss = boss_actor
	elites = elite_actors
	telegraphs = active_telegraphs
	loot = loot_system
	player.protection_broken.connect(_on_player_protection_broken)
	player.damaged.connect(_on_player_damaged)
	position = Vector2.ZERO
	player_last_position = player.position
	player_is_moving = false
	player_faces_left = false
	player_idle_time = 0.0
	player_walk_time = 0.0
	player_attack_01_time = 0.0
	player_is_playing_attack_01 = false
	player_attack_02_time = 0.0
	player_is_playing_attack_02 = false
	player_attack_03_time = 0.0
	player_is_playing_attack_03 = false
	player_hit_flash_remaining = 0.0
	player_hit_flash_strength = 0.0
	archer_projectiles.clear()
	archer_impact_marks.clear()
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

func add_flash(request: AttackRequest) -> void:
	# Keep a small visual seed on creation so the wind shape does not visibly reshuffle every frame.
	flashes.append({"request": _copy_request_for_visual(request), "remaining": FLASH_DURATION, "variant": randi_range(0, 5)})

func add_pickup(at: Vector2) -> void:
	pickup_marks.append({"position": at, "remaining": 0.45})

func add_impact(at: Vector2, attack_label: String, hit_count: int) -> void:
	var heavy_hit: bool = attack_label in ["穿阵挑刺", "破军", "破军收势", "七进七出", "七进七出·收势"]
	impact_marks.append({"position": at, "remaining": 0.18 if heavy_hit else 0.13, "label": attack_label, "hits": hit_count})
	shake_remaining = maxf(shake_remaining, 0.13 if heavy_hit else 0.09)
	var base_strength := 5.0 if heavy_hit else 2.8
	shake_strength = maxf(shake_strength, minf(12.0, base_strength + float(hit_count) * 1.25))

func add_ultimate_dash_wave(at: Vector2, direction: Vector2, distance: float, segment: int) -> void:
	ultimate_wave_marks.append({"position": at, "direction": direction.normalized(), "distance": distance, "segment": segment, "remaining": 0.48})

func add_death_collision(at: Vector2, direction: Vector2) -> void:
	death_collision_marks.append({"position": at, "direction": direction.normalized(), "remaining": 0.22})

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
	player_hit_flash_remaining = 0.08
	player_hit_flash_strength = clampf(0.70 + amount * 0.025, 0.70, 1.0)

func tick_visuals(delta: float) -> void:
	visual_time += delta
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
	for index in range(shield_break_marks.size() - 1, -1, -1):
		shield_break_marks[index].remaining -= delta
		if shield_break_marks[index].remaining <= 0.0:
			shield_break_marks.remove_at(index)
	for index in range(ultimate_wave_marks.size() - 1, -1, -1):
		ultimate_wave_marks[index].remaining -= delta
		if ultimate_wave_marks[index].remaining <= 0.0:
			ultimate_wave_marks.remove_at(index)
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
	shake_remaining = maxf(0.0, shake_remaining - delta)
	if shake_remaining > 0.0:
		position = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	else:
		position = Vector2.ZERO
	queue_redraw()

func _tick_player_animation(delta: float) -> void:
	if player == null:
		return
	var movement := player.position - player_last_position
	var has_moved := movement.length_squared() > 0.25
	player_is_moving = has_moved and not player.is_action_locked() and player.ultimate_time <= 0.0
	player_faces_left = player.last_attack_direction.x < 0.0
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
	if player_is_moving:
		player_walk_time += delta
	else:
		player_idle_time += delta
	player_last_position = player.position

func _tick_enemy_animation(delta: float) -> void:
	if enemies == null:
		return
	for id in range(EnemySimulation.CAPACITY):
		var current_position := enemies.positions[id]
		var moved := enemies.is_active(id) and enemies.has_movement_intent(id) and current_position.distance_squared_to(enemy_last_positions[id]) > 0.0025
		if moved:
			enemy_move_animation_holds[id] = ENEMY_MOVE_ANIMATION_HOLD
		else:
			enemy_move_animation_holds[id] = maxf(0.0, enemy_move_animation_holds[id] - delta)
		enemy_is_moving[id] = 1 if enemy_move_animation_holds[id] > 0.0 else 0
		enemy_last_positions[id] = current_position

func _draw() -> void:
	_draw_background()
	_draw_telegraphs()
	_draw_pickups()
	_draw_enemies()
	_draw_elites()
	_draw_ultimate_waves()
	_draw_boss()
	_draw_player()
	_draw_archer_projectiles()
	_draw_archer_impact_marks()
	_draw_shield_breaks()
	_draw_flashes()
	_draw_impacts()
	_draw_death_collisions()

func _draw_background() -> void:
	draw_rect(bounds.grow(96.0), Color("13130e"))
	draw_texture_rect(CHANGBAN_GRASS_TEXTURE, bounds, true)
	# A subtle all-map blend avoids the visual rhythm of a single repeating grass tile.
	draw_texture_rect(CHANGBAN_GRASS_DIRT_TEXTURE, bounds, true, Color(1.0, 1.0, 1.0, 0.13))
	var churned_center := Rect2(bounds.get_center() - Vector2(720.0, 310.0), Vector2(1440.0, 620.0))
	draw_texture_rect(CHANGBAN_DIRT_TEXTURE, churned_center, true, Color(1.0, 1.0, 1.0, 0.18))
	_draw_ground_patch(CHANGBAN_TRAMPLED_PATCH_01, Rect2(260.0, 560.0, 820.0, 820.0), 0.82)
	_draw_ground_patch(CHANGBAN_TRAMPLED_PATCH_02, Rect2(1090.0, 460.0, 760.0, 760.0), 0.74)
	_draw_ground_patch(CHANGBAN_TRAMPLED_PATCH_01, Rect2(1760.0, 620.0, 620.0, 620.0), 0.70)
	_draw_boundary_slope(Rect2(-360.0, -280.0, 560.0, 500.0), false)
	_draw_boundary_slope(Rect2(bounds.end.x - 220.0, -250.0, 560.0, 500.0), true)
	_draw_boundary_slope(Rect2(-330.0, bounds.end.y - 210.0, 520.0, 470.0), false)
	_draw_boundary_slope(Rect2(bounds.end.x - 210.0, bounds.end.y - 190.0, 520.0, 470.0), true)

func _draw_ground_patch(texture: Texture2D, rect: Rect2, opacity: float) -> void:
	draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, opacity))

func _draw_boundary_slope(rect: Rect2, flip_horizontally: bool) -> void:
	if not flip_horizontally:
		draw_texture_rect(CHANGBAN_SLOPE_TEXTURE, rect, false)
		return
	draw_set_transform(rect.get_center(), 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(CHANGBAN_SLOPE_TEXTURE, Rect2(-rect.size * 0.5, rect.size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_enemies() -> void:
	if enemies == null:
		return
	for id in range(EnemySimulation.CAPACITY):
		if enemies.is_dying(id):
			_draw_enemy_death(id)
			continue
		if not enemies.is_active(id):
			continue
		var at := enemies.positions[id]
		var enemy_type := enemies.get_type(id)
		var facing := enemies.get_facing_direction(id)
		var color := _enemy_color(enemy_type)
		var hurt_ratio := enemies.get_hit_feedback_ratio(id)
		var hit_strength := enemies.get_hit_feedback_strength(id)
		color = color.lerp(Color.WHITE, hurt_ratio * 0.82)
		var size := 12.0 if enemy_type != EnemySimulation.EnemyType.ELITE else 20.0
		var uses_enemy_sprite := enemy_type == EnemySimulation.EnemyType.SWORD or enemy_type == EnemySimulation.EnemyType.SHIELD or enemy_type == EnemySimulation.EnemyType.ARCHER or enemy_type == EnemySimulation.EnemyType.HALBERD
		var shadow_horizontal := 22.0 if uses_enemy_sprite else size * 1.05
		var shadow_vertical := 6.5 if uses_enemy_sprite else size * 0.34
		_draw_ground_shadow(at + Vector2(0, size * 0.55), shadow_horizontal, shadow_vertical, Color(0.0, 0.0, 0.0, 0.28))
		if enemy_type == EnemySimulation.EnemyType.SWORD:
			_draw_sword_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1)
		elif enemy_type == EnemySimulation.EnemyType.SHIELD:
			_draw_shield_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1)
		elif enemy_type == EnemySimulation.EnemyType.ARCHER:
			_draw_archer_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1)
		elif enemy_type == EnemySimulation.EnemyType.HALBERD:
			_draw_halberd_enemy_sprite(at, facing, hurt_ratio, hit_strength, enemies.get_attack_state(id), enemies.get_attack_remaining(id), enemy_is_moving[id] == 1)
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

func _draw_enemy_death(id: int) -> void:
	var at := enemies.positions[id]
	var enemy_type := enemies.get_type(id)
	var progress := enemies.death_animation_progress(id)
	var fade_progress := enemies.death_fade_progress(id)
	var alpha := clampf(1.0 - fade_progress, 0.0, 1.0)
	var facing := enemies.get_facing_direction(id)
	var tilt := lerpf(0.10, 0.62, progress) * (-1.0 if facing.x < 0.0 else 1.0)
	var shadow_scale := 1.0 + progress * 0.28
	_draw_ground_shadow(at + Vector2(0, 15), 18.0 * shadow_scale, 5.8 * shadow_scale, Color(0.0, 0.0, 0.0, 0.24 * alpha))
	if enemies.is_death_launched(id):
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
	_draw_ground_shadow(at + Vector2(0, 14), 27.0, 7.5, Color(0.0, 0.0, 0.0, 0.34))
	if player.is_ultimate_ready():
		_draw_ultimate_ready_burst(at)
	_draw_player_status_aura(at)
	_draw_player_sprite(at)
	_draw_player_hit_marker(at)
	_draw_attack_03_spear_flare(at)
	if player.ultimate_time > 0.0:
		if player.is_ultimate_dashing():
			_draw_ultimate_dash_wind(at)
		else:
			draw_arc(at, 30.0, 0.0, TAU, 24, Color(0.78, 0.94, 1.0, 0.58), 2.0)

func _draw_player_status_aura(at: Vector2) -> void:
	var has_dragon_shield := player.health_component.shield_charges > 0
	var has_breakout_shield := player.has_breakout_guard()
	if player.has_dragon():
		_draw_dragon_state_marker(at)
	if has_dragon_shield:
		_draw_dragon_shield(at)
	if has_breakout_shield:
		_draw_breakout_guard(at)

func _draw_dragon_state_marker(at: Vector2) -> void:
	var center := at + Vector2(0, 13)
	var pulse := 0.68 + 0.22 * (sin(visual_time * 7.0) + 1.0) * 0.5
	var ring_color := Color(0.42, 0.84, 1.0, 0.72 * pulse)
	var segments := [
		PackedVector2Array([center + Vector2(-13, -9), center + Vector2(-7, -12), center + Vector2(0, -13), center + Vector2(7, -12), center + Vector2(13, -9)]),
		PackedVector2Array([center + Vector2(-23, -1), center + Vector2(-20, 5), center + Vector2(-14, 9), center + Vector2(-8, 11)]),
		PackedVector2Array([center + Vector2(-5, 12), center + Vector2(0, 13), center + Vector2(5, 12)]),
		PackedVector2Array([center + Vector2(8, 11), center + Vector2(14, 9), center + Vector2(20, 5), center + Vector2(23, -1)]),
	]
	for segment in segments:
		draw_polyline(segment, ring_color, 1.5, false)
		draw_rect(Rect2(segment[0] - Vector2(1.5, 1.5), Vector2(3.0, 3.0)), Color(0.70, 0.94, 1.0, 0.86 * pulse))
		draw_rect(Rect2(segment[segment.size() - 1] - Vector2(1.5, 1.5), Vector2(3.0, 3.0)), Color(0.70, 0.94, 1.0, 0.86 * pulse))

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
	var seal_center := center + Vector2(0, -55)
	draw_rect(Rect2(seal_center - Vector2(4, 4), Vector2(8, 8)), Color(0.70, 0.94, 1.0, 0.86 * pulse))
	draw_rect(Rect2(seal_center - Vector2(2, 2), Vector2(4, 4)), Color(1.0, 1.0, 1.0, 0.96 * pulse))

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
	var origin := at + Vector2(0, 12)
	var directions := [
		Vector2(-0.72, -0.70), Vector2(-0.36, -0.93), Vector2.UP,
		Vector2(0.36, -0.93), Vector2(0.72, -0.70),
	]
	var base_lengths := [70.0, 85.0, 100.0, 85.0, 70.0]
	var widths := [9.0, 10.0, 12.0, 10.0, 9.0]
	var pulse := 0.78 + 0.18 * (sin(visual_time * 5.0) + 1.0) * 0.5
	for index in range(directions.size()):
		var direction: Vector2 = directions[index]
		var flicker := sin(visual_time * 8.0 + float(index) * 1.37) * 3.0
		var root := origin + Vector2(float(index - 2) * 3.0, 0)
		var outer_points := _pixel_aura_spike_points(root, direction, base_lengths[index] + flicker, widths[index])
		var core_points := _pixel_aura_spike_points(root + direction * 4.0, direction, base_lengths[index] * 0.62 + flicker * 0.4, widths[index] * 0.42)
		draw_colored_polygon(outer_points, Color(0.94, 0.55, 0.10, 0.54 * pulse))
		draw_polyline(outer_points, Color(1.0, 0.79, 0.30, 0.86 * pulse), 1.0, true)
		draw_colored_polygon(core_points, Color(1.0, 0.88, 0.40, 0.58 * pulse))

func _pixel_aura_spike_points(root: Vector2, direction: Vector2, length: float, width: float) -> PackedVector2Array:
	var side := Vector2(-direction.y, direction.x)
	var points := PackedVector2Array([
		root - side * width,
		root + direction * (length * 0.30) - side * width,
		root + direction * (length * 0.30) - side * width * 0.62,
		root + direction * (length * 0.58) - side * width * 0.62,
		root + direction * (length * 0.58) - side * width * 0.30,
		root + direction * length,
		root + direction * (length * 0.58) + side * width * 0.30,
		root + direction * (length * 0.58) + side * width * 0.62,
		root + direction * (length * 0.30) + side * width * 0.62,
		root + direction * (length * 0.30) + side * width,
		root + side * width,
	])
	for index in range(points.size()):
		points[index] = points[index].snapped(Vector2(2.0, 2.0))
	return points

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
		var flash_ratio := clampf(player_hit_flash_remaining / 0.08, 0.0, 1.0) * player_hit_flash_strength
		draw_texture(texture, -source_anchor, Color(1.0, 1.0, 1.0, flash_ratio * 0.72))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_player_hit_marker(at: Vector2) -> void:
	if player_hit_flash_remaining <= 0.0:
		return
	var flash_ratio := clampf(player_hit_flash_remaining / 0.08, 0.0, 1.0) * player_hit_flash_strength
	var color := Color(1.0, 0.56, 0.42, flash_ratio * 0.78)
	draw_arc(at + Vector2(0, -6), 30.0 + (1.0 - flash_ratio) * 8.0, 0.0, TAU, 16, color, 1.8)
	for index in range(4):
		var direction := Vector2.from_angle(TAU * float(index) / 4.0 + 0.25)
		draw_line(at + Vector2(0, -6) + direction * 12.0, at + Vector2(0, -6) + direction * 24.0, color, 2.0)

func _draw_sword_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool) -> void:
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
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_shield_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool) -> void:
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
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_archer_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool) -> void:
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
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_halberd_enemy_sprite(at: Vector2, facing: Vector2, hurt_ratio: float, hit_strength: float, attack_state: int, attack_remaining: float, moving: bool) -> void:
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
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_attack_03_spear_flare(at: Vector2) -> void:
	if not player_is_playing_attack_03:
		return
	var frame_index := _attack_03_frame_index()
	if frame_index < 2:
		return
	var direction := player.last_attack_direction
	var perpendicular := Vector2(-direction.y, direction.x)
	var flare_step := frame_index - 2
	var lengths := [23.0, 35.0, 29.0, 21.0]
	var widths := [3.5, 5.0, 4.0, 2.5]
	var alphas := [0.76, 1.0, 0.82, 0.58]
	var tip := at + SPEAR_VFX_HEIGHT_OFFSET + direction * 45.0
	var length: float = lengths[flare_step]
	var width: float = widths[flare_step]
	var alpha: float = alphas[flare_step]
	var root := tip - direction * 12.0
	var spear_tip := tip + direction * length
	# The final stab gets a ragged, two-layer spear wind rather than a perfect geometric triangle.
	var outer := PackedVector2Array([
		root - perpendicular * (width * 1.7),
		root + direction * (length * 0.24) - perpendicular * (width * 2.05),
		root + direction * (length * 0.60) - perpendicular * (width * 0.68),
		spear_tip,
		root + direction * (length * 0.67) + perpendicular * (width * 0.50),
		root + direction * (length * 0.22) + perpendicular * (width * 1.32),
	])
	draw_colored_polygon(outer, Color(0.38, 0.82, 1.0, alpha * 0.48))
	var inner := PackedVector2Array([
		root + direction * 4.0 - perpendicular * width,
		root + direction * (length * 0.42) - perpendicular * (width * 0.78),
		spear_tip - direction * 2.0,
		root + direction * (length * 0.48) + perpendicular * (width * 0.45),
		root + direction * 5.0 + perpendicular * (width * 0.75),
	])
	draw_colored_polygon(inner, Color(0.72, 0.95, 1.0, alpha * 0.62))
	var shard_center := root + direction * (length * 0.56) - perpendicular * (width * 2.2)
	var shard := PackedVector2Array([shard_center - direction * 4.0, shard_center + perpendicular * 2.2, shard_center + direction * 8.0])
	draw_colored_polygon(shard, Color(0.60, 0.91, 1.0, alpha * 0.46))
	if player.is_path_dashing():
		_draw_third_dash_wind(at, direction, perpendicular)

func _draw_third_dash_wind(at: Vector2, direction: Vector2, perpendicular: Vector2) -> void:
	var progress := player.path_dash_progress()
	var root := at + SPEAR_VFX_HEIGHT_OFFSET + direction * 24.0
	var length := 64.0 + progress * 22.0
	var tip := root + direction * length
	var outer := PackedVector2Array([
		root - perpendicular * 9.0,
		root + direction * (length * 0.28) - perpendicular * 12.0,
		root + direction * (length * 0.63) - perpendicular * 4.0,
		tip,
		root + direction * (length * 0.67) + perpendicular * 3.0,
		root + direction * (length * 0.22) + perpendicular * 8.0,
	])
	draw_colored_polygon(outer, Color(0.34, 0.82, 1.0, 0.58))
	var core := PackedVector2Array([
		root + direction * 6.0 - perpendicular * 3.8,
		root + direction * (length * 0.48) - perpendicular * 4.5,
		tip - direction * 1.5,
		root + direction * (length * 0.54) + perpendicular * 2.0,
		root + direction * 7.0 + perpendicular * 3.0,
	])
	draw_colored_polygon(core, Color(0.76, 0.97, 1.0, 0.74))
	var shard_center := root + direction * (length * 0.58) - perpendicular * (12.0 + progress * 8.0)
	var shard := PackedVector2Array([shard_center - direction * 5.0, shard_center + perpendicular * 3.0, shard_center + direction * 12.0])
	draw_colored_polygon(shard, Color(0.58, 0.91, 1.0, 0.52))

func _copy_request_for_visual(source: AttackRequest) -> AttackRequest:
	var copy := AttackRequest.new()
	copy.shape = source.shape
	copy.origin = source.origin
	copy.direction = source.direction
	copy.range = source.range
	copy.width = source.width
	copy.half_angle = source.half_angle
	copy.multiplier = source.multiplier
	copy.pierce = source.pierce
	copy.knockback = source.knockback
	copy.ignore_knockback_resistance = source.ignore_knockback_resistance
	copy.forced_displacement = source.forced_displacement
	copy.forced_displacement_duration = source.forced_displacement_duration
	copy.label = source.label
	copy.fan_knockback = source.fan_knockback
	copy.empowered_knockback_active = source.empowered_knockback_active
	copy.empowered_knockback_target_limit = source.empowered_knockback_target_limit
	copy.empowered_knockback_multiplier = source.empowered_knockback_multiplier
	return copy

func _current_player_texture() -> Texture2D:
	if player_is_playing_attack_01:
		var attack_frame := mini(int(player_attack_01_time / PLAYER_ATTACK_01_FRAME_DURATION), PLAYER_ATTACK_01_TEXTURES.size() - 1)
		return PLAYER_ATTACK_01_TEXTURES[attack_frame]
	if player_is_playing_attack_02:
		return PLAYER_ATTACK_02_TEXTURES[_attack_02_frame_index()]
	if player_is_playing_attack_03:
		return PLAYER_ATTACK_03_TEXTURES[_attack_03_frame_index()]
	if player_is_moving:
		var walk_frame := int(player_walk_time / PLAYER_WALK_FRAME_DURATION) % PLAYER_WALK_TEXTURES.size()
		return PLAYER_WALK_TEXTURES[walk_frame]
	var idle_step := int(player_idle_time / PLAYER_IDLE_FRAME_DURATION) % PLAYER_IDLE_FRAME_ORDER.size()
	return PLAYER_IDLE_TEXTURES[PLAYER_IDLE_FRAME_ORDER[idle_step]]

func _current_player_source_foot_anchor() -> Vector2:
	if player_is_playing_attack_02:
		return PLAYER_ATTACK_02_FOOT_ANCHORS[_attack_02_frame_index()]
	return PLAYER_SOURCE_FOOT_ANCHOR

func _attack_02_frame_index() -> int:
	return mini(int(player_attack_02_time / PLAYER_ATTACK_02_FRAME_DURATION), PLAYER_ATTACK_02_TEXTURES.size() - 1)

func _attack_03_frame_index() -> int:
	return mini(int(player_attack_03_time / PLAYER_ATTACK_03_FRAME_DURATION), PLAYER_ATTACK_03_TEXTURES.size() - 1)

func _draw_boss() -> void:
	if boss == null or not boss.active:
		return
	var at := boss.position
	var spear_direction := boss.facing_direction if boss.facing_direction.length_squared() > 0.01 else Vector2.DOWN
	_draw_ground_shadow(at + Vector2(0, 23), 40.0, 11.5, Color(0.0, 0.0, 0.0, 0.38))
	_draw_boss_aura(at, spear_direction)
	draw_set_transform(at, 0.0, Vector2(1.10, 1.10))
	draw_rect(Rect2(-25, -34, 50, 58), Color("282d38"))
	draw_rect(Rect2(-30, -11, 60, 20), Color("712b42"))
	draw_rect(Rect2(-18, -36, 36, 7), Color("6e5d74"))
	draw_circle(Vector2(0, -40), 15.0, Color("dec8af"))
	draw_line(Vector2(8, 3), spear_direction * 54.0 + Vector2(0, -28), Color("c8d9ec"), 5.0)
	draw_line(spear_direction * 44.0 + Vector2(0, -24), spear_direction * 58.0 + Vector2(0, -31), Color("e4d9b4"), 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if boss.is_recovering():
		for index in range(3):
			var start_angle := -1.02 + float(index) * 2.10
			draw_arc(at, 49.0, start_angle, start_angle + 0.68, 8, Color("ffd16c"), 2.5)
		draw_string(ThemeDB.fallback_font, at + Vector2(-16, -68), "破绽", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffe2a0"))

func _draw_elites() -> void:
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active:
			continue
		var at := elite.position
		var direction := elite.current_direction if elite.current_direction.length_squared() > 0.01 else Vector2.DOWN
		_draw_ground_shadow(at + Vector2(0, 21), 29.0, 8.0, Color(0.0, 0.0, 0.0, 0.34))
		_draw_elite_aura(elite, at, direction)
		_draw_elite_body(elite, at)

func _draw_elite_aura(elite: EliteActor, at: Vector2, direction: Vector2) -> void:
	var perpendicular := Vector2(-direction.y, direction.x)
	var pulse: float = 0.64 + 0.24 * (sin(visual_time * 4.6) + 1.0) * 0.5
	var action_boost: float = 1.35 if elite.state == EliteActor.State.WINDUP else 1.0
	var color := Color("b94635") if elite.archetype == EliteActor.Archetype.XIAHOU_EN else Color("b87935")
	for index in range(5):
		var side := -1.0 if index % 2 == 0 else 1.0
		var spread := 10.0 + float(index) * 4.2
		var drift := sin(visual_time * 5.0 + float(index) * 1.37) * 3.0
		var root := at - direction * (6.0 + float(index) * 2.0) + perpendicular * (side * spread + drift) + Vector2(0, -13)
		var tip := root - direction * (10.0 + float(index) * 3.0) + perpendicular * side * 3.0
		if elite.archetype == EliteActor.Archetype.XIAHOU_EN:
			draw_line(root, tip, Color(color.r, color.g, color.b, pulse * action_boost * 0.72), 2.2)
			draw_line(tip, tip - direction * 5.0 - perpendicular * side * 2.0, Color(0.98, 0.64, 0.33, pulse * 0.44), 1.1)
		else:
			var shard := PackedVector2Array([root - perpendicular * 2.4, root + direction * 5.0, root + perpendicular * 2.0])
			draw_colored_polygon(shard, Color(color.r, color.g, color.b, pulse * action_boost * 0.68))
	if elite.is_recovering():
		for index in range(3):
			var mark_direction := Vector2.from_angle(visual_time * 2.0 + TAU * float(index) / 3.0)
			draw_line(at + mark_direction * 26.0, at + mark_direction * 34.0, Color("ffd16c"), 2.0)

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
	for index in range(7):
		var side := -1.0 if index % 2 == 0 else 1.0
		var offset := 8.0 + float(index) * 5.0
		var flutter := sin(visual_time * 4.2 + float(index) * 0.92) * 4.0
		var root := at - direction * (4.0 + float(index) * 1.6) + perpendicular * (side * offset + flutter) + Vector2(0, -24)
		var tip := root - direction * (15.0 + float(index) * 3.3) + perpendicular * side * (3.0 + float(index) * 0.5)
		var color := Color(0.47, 0.40, 0.78, phase_boost * windup_boost * (0.32 + float(index) * 0.035))
		draw_line(root, tip, color, 2.0)
		if index % 2 == 0:
			draw_line(tip, tip - direction * 5.0, Color(0.82, 0.71, 0.38, color.a * 0.82), 1.2)

func _draw_telegraphs() -> void:
	for telegraph in telegraphs:
		var colors := _telegraph_colors(telegraph.source)
		var color: Color = colors.fill
		var outline: Color = colors.outline
		match telegraph.shape:
			Telegraph.Shape.CIRCLE:
				draw_circle(telegraph.origin, telegraph.range, color)
				draw_arc(telegraph.origin, telegraph.range, 0.0, TAU, 32, outline, 2.0)
			Telegraph.Shape.LINE:
				draw_line(telegraph.origin, telegraph.origin + telegraph.direction * telegraph.range, color, telegraph.width)
				draw_line(telegraph.origin, telegraph.origin + telegraph.direction * telegraph.range, outline, 2.0)
			Telegraph.Shape.FAN:
				var points := PackedVector2Array([telegraph.origin])
				for step in range(13):
					var angle := telegraph.direction.angle() - telegraph.half_angle + (telegraph.half_angle * 2.0 * step / 12.0)
					points.append(telegraph.origin + Vector2.from_angle(angle) * telegraph.range)
				draw_colored_polygon(points, color)
				draw_arc(telegraph.origin, telegraph.range, telegraph.direction.angle() - telegraph.half_angle, telegraph.direction.angle() + telegraph.half_angle, 16, outline, 2.0)

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
		var alpha := clampf(flash.remaining / FLASH_DURATION, 0.0, 1.0)
		var progress := 1.0 - alpha
		var variant := int(flash.get("variant", 0))
		match request.label:
			"点刺":
				_draw_thrust_flash(request, alpha, progress, variant, 4.0, Color(0.48, 0.86, 1.0, 0.52))
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
			_:
				_draw_thrust_flash(request, alpha, progress, variant, 4.0, Color(0.70, 0.95, 1.0, 0.44))
		if request.empowered_knockback_active:
			_draw_breakout_gust(request, alpha, progress)

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
	var length := request.range * lerpf(0.42, 1.08, burst)
	var root := request.origin + SPEAR_VFX_HEIGHT_OFFSET + direction * 7.0
	var tip := root + direction * length
	var side := -1.0 if variant % 2 == 0 else 1.0
	var width := half_width * (1.55 + 0.08 * float(variant % 3))
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
	var center := request.origin + SWEEP_VFX_HEIGHT_OFFSET + request.direction * 6.0
	var radius := request.range * lerpf(0.54, 0.90, burst)
	_draw_broken_sweep_band(center, start_angle, end_angle, radius, 15.0, color, alpha, variant, 3)
	_draw_broken_sweep_band(center, start_angle + 0.08, end_angle - 0.12, radius - 11.0, 8.0, Color(0.70, 0.95, 1.0, 0.70), alpha * 0.78, variant + 3, 2)
	var span := end_angle - start_angle
	for index in range(4):
		var shard_angle := start_angle + span * (0.17 + 0.19 * float(index)) + float((variant + index) % 3 - 1) * 0.035
		var radial := Vector2.from_angle(shard_angle)
		var tangent := Vector2(-radial.y, radial.x)
		var shard_center := center + radial * (radius + 4.0 + progress * 13.0 + float(index) * 2.5)
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
			draw_circle(at + Vector2(-4, 0), 5.0, Color(0.42, 0.90, 1.0, pulse))
			draw_circle(at + Vector2(4, 0), 5.0, Color(0.95, 0.76, 0.25, pulse))
			draw_arc(at, 8.0, 0.0, TAU, 12, Color(0.86, 0.96, 1.0, pulse), 1.0)
	for pickup in pickup_marks:
		var alpha := clampf(pickup.remaining / 0.45, 0.0, 1.0)
		draw_circle(pickup.position, 6.0, Color(0.95, 0.78, 0.26, alpha))

func _draw_impacts() -> void:
	for impact in impact_marks:
		var heavy_hit: bool = impact.label in ["穿阵挑刺", "破军", "破军收势", "七进七出", "七进七出·收势"]
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

func _enemy_color(enemy_type: int) -> Color:
	match enemy_type:
		EnemySimulation.EnemyType.ARCHER: return Color("705451")
		EnemySimulation.EnemyType.HALBERD: return Color("574d60")
		EnemySimulation.EnemyType.SHIELD: return Color("53616a")
		EnemySimulation.EnemyType.ELITE: return Color("8d343d")
		EnemySimulation.EnemyType.GUARD: return Color("794349")
		_: return Color("4e555d")

func _telegraph_colors(source: String) -> Dictionary:
	if source.begins_with("elite:"):
		return {"fill": Color(0.92, 0.34, 0.15, 0.24), "outline": Color(1.0, 0.62, 0.24, 0.92)}
	match source:
		"archer": return {"fill": Color(0.86, 0.68, 0.20, 0.20), "outline": Color(1.0, 0.82, 0.30, 0.90)}
		"halberd": return {"fill": Color(0.89, 0.34, 0.18, 0.25), "outline": Color(1.0, 0.48, 0.22, 0.90)}
		"shield": return {"fill": Color(0.38, 0.61, 0.75, 0.20), "outline": Color(0.55, 0.82, 1.0, 0.90)}
		"boss_preview": return {"fill": Color(0.90, 0.14, 0.12, 0.12), "outline": Color(1.0, 0.54, 0.26, 0.58)}
		"boss": return {"fill": Color(0.94, 0.12, 0.12, 0.32), "outline": Color(1.0, 0.48, 0.20, 1.0)}
		_: return {"fill": Color(0.90, 0.19, 0.16, 0.28), "outline": Color(1.0, 0.35, 0.25, 0.85)}
