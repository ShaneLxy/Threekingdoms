class_name RunDirector
extends Node

signal spawn_requested(enemy_type: int, at: Vector2)
signal elite_requested(elite_id: String, at: Vector2)
signal boss_requested(at: Vector2)
signal level_up(level: int)
signal stage_changed(label: String)

const STORY_DURATION := 600.0
const ENDLESS_DURATION := 1200.0
const ARCHER_INTRO_TIME := 35.0
const SHIELD_BOW_TIME := 80.0
const PINCER_TIME := 130.0
const XIAHOU_EN_TIME := 155.0
const CHUNYU_DAO_TIME := 315.0
const BOSS_TIME := 420.0
const OFFSCREEN_SPAWN_MIN_DISTANCE := 480.0
const OFFSCREEN_SPAWN_MAX_DISTANCE := 610.0

var bounds := Rect2(0, 0, 1920, 860)
var elapsed := 0.0
var experience := 0
var level := 1
var next_level_experience := 8
var spawn_accumulator := 0.0
var boss_spawned := false
var xiahou_en_spawned := false
var chunyu_dao_spawned := false
var shield_bow_deployed := false
var pincer_deployed := false
var stage_index := 0
var rng := RandomNumberGenerator.new()
var spawn_focus := Vector2.ZERO
var mode := "story"
var duration := STORY_DURATION

func reset(world_bounds: Rect2, selected_mode: String = "story") -> void:
	bounds = world_bounds
	mode = selected_mode
	duration = ENDLESS_DURATION if mode == "endless" else STORY_DURATION
	elapsed = 0.0
	experience = 0
	level = 1
	next_level_experience = 8
	spawn_accumulator = 0.0
	boss_spawned = false
	xiahou_en_spawned = false
	chunyu_dao_spawned = false
	shield_bow_deployed = false
	pincer_deployed = false
	stage_index = 0
	spawn_focus = bounds.get_center()
	rng.seed = 20260712
	stage_changed.emit("无尽兵海：守住阵线" if mode == "endless" else "乱军初起：击破刀兵")

func tick(delta: float, active_enemy_count: int, player_position: Vector2 = Vector2.INF) -> void:
	if player_position.is_finite():
		spawn_focus = player_position
	elapsed += delta
	_advance_encounter_events()
	if boss_spawned and mode != "endless":
		return
	spawn_accumulator += delta
	var profile := _spawn_profile()
	var soft_capacity := int(profile.soft_capacity)
	var hard_capacity := int(profile.hard_capacity)
	if active_enemy_count >= hard_capacity:
		return
	var spawn_interval := float(profile.interval)
	var burst := int(profile.burst)
	if active_enemy_count >= soft_capacity:
		spawn_interval *= 2.4
		burst = 1
	if spawn_accumulator < spawn_interval:
		return
	spawn_accumulator = fmod(spawn_accumulator, spawn_interval)
	var burst_count := mini(burst, hard_capacity - active_enemy_count)
	for _index in range(maxi(0, burst_count)):
		spawn_requested.emit(_choose_enemy(), _choose_spawn())

func add_experience(value: int) -> void:
	experience += value
	while experience >= next_level_experience:
		experience -= next_level_experience
		level += 1
		next_level_experience = ceili(9.0 * pow(1.22, level - 1))
		level_up.emit(level)

func progress() -> float:
	return float(experience) / maxf(1.0, float(next_level_experience))

func remaining_time() -> float:
	return maxf(0.0, duration - elapsed)

func is_time_over() -> bool:
	return elapsed >= duration

func _choose_enemy() -> int:
	if mode == "endless":
		var tier := int(elapsed / 120.0)
		var roll := rng.randf()
		if tier >= 5 and roll < 0.08:
			return EnemySimulation.EnemyType.GUARD
		if tier >= 3 and roll < 0.30:
			return EnemySimulation.EnemyType.HALBERD
		if tier >= 2 and roll < 0.48:
			return EnemySimulation.EnemyType.SHIELD
		if tier >= 1 and roll < 0.70:
			return EnemySimulation.EnemyType.ARCHER
		return EnemySimulation.EnemyType.SWORD
	if elapsed < ARCHER_INTRO_TIME:
		return EnemySimulation.EnemyType.SWORD
	if elapsed < SHIELD_BOW_TIME:
		return EnemySimulation.EnemyType.ARCHER if rng.randf() < 0.28 else EnemySimulation.EnemyType.SWORD
	if elapsed < PINCER_TIME:
		var roll := rng.randf()
		return EnemySimulation.EnemyType.SHIELD if roll < 0.30 else (EnemySimulation.EnemyType.ARCHER if roll < 0.62 else EnemySimulation.EnemyType.SWORD)
	var pincer_roll := rng.randf()
	return EnemySimulation.EnemyType.HALBERD if pincer_roll < 0.42 else (EnemySimulation.EnemyType.SHIELD if pincer_roll < 0.62 else EnemySimulation.EnemyType.SWORD)

func _spawn_profile() -> Dictionary:
	if mode == "endless":
		var tier := int(elapsed / 120.0)
		return {"interval": maxf(0.22, 0.62 - 0.05 * tier), "soft_capacity": mini(70, 26 + tier * 8), "hard_capacity": mini(88, 40 + tier * 10), "burst": mini(4, 2 + tier / 3)}
	if elapsed < ARCHER_INTRO_TIME:
		return {"interval": 0.65, "soft_capacity": 18, "hard_capacity": 26, "burst": 2}
	if elapsed < SHIELD_BOW_TIME:
		return {"interval": 0.48, "soft_capacity": 30, "hard_capacity": 40, "burst": 2}
	if elapsed < PINCER_TIME:
		return {"interval": 0.38, "soft_capacity": 46, "hard_capacity": 60, "burst": 2}
	return {"interval": 0.30, "soft_capacity": 60, "hard_capacity": 78, "burst": 3}

func _advance_encounter_events() -> void:
	if stage_index == 0 and elapsed >= ARCHER_INTRO_TIME:
		stage_index = 1
		stage_changed.emit("乱箭逼近：注意黄色落点")
	if stage_index == 1 and elapsed >= SHIELD_BOW_TIME:
		stage_index = 2
		stage_changed.emit("拒阵：盾弓阵推进")
	if not shield_bow_deployed and elapsed >= SHIELD_BOW_TIME + 5.0:
		shield_bow_deployed = true
		_deploy_shield_bow()
	if stage_index == 2 and elapsed >= PINCER_TIME:
		stage_index = 3
		stage_changed.emit("戟卫夹击：选择突破方向")
	if not pincer_deployed and elapsed >= PINCER_TIME + 3.0:
		pincer_deployed = true
		_deploy_halberd_pincer()
	if mode != "endless" and not xiahou_en_spawned and elapsed >= XIAHOU_EN_TIME:
		xiahou_en_spawned = true
		elite_requested.emit("xiahou_en", _north_spawn())
		stage_changed.emit("夏侯恩持偃月刀拦路")
	if mode != "endless" and not chunyu_dao_spawned and elapsed >= CHUNYU_DAO_TIME:
		chunyu_dao_spawned = true
		elite_requested.emit("chunyu_dao", _north_spawn() + Vector2(92.0, 34.0))
		stage_changed.emit("淳于导提刀压阵")
	if mode != "endless" and not boss_spawned and elapsed >= BOSS_TIME:
		boss_spawned = true
		boss_requested.emit(Vector2(bounds.get_center().x, bounds.position.y + 90.0))
		stage_changed.emit("敌将现身：张郃")

func _deploy_shield_bow() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-110.0, 110.0), bounds.position.y + 95.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front)
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(-62.0, -38.0))
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(62.0, -38.0))

func _deploy_halberd_pincer() -> void:
	var center_y := bounds.get_center().y
	spawn_requested.emit(EnemySimulation.EnemyType.HALBERD, Vector2(bounds.position.x + 24.0, center_y - 64.0))
	spawn_requested.emit(EnemySimulation.EnemyType.HALBERD, Vector2(bounds.end.x - 24.0, center_y + 64.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SWORD, Vector2(bounds.get_center().x - 38.0, bounds.position.y + 50.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SWORD, Vector2(bounds.get_center().x + 38.0, bounds.position.y + 50.0))

func _choose_spawn() -> Vector2:
	var spawn_area := bounds.grow(-24.0)
	for attempt in range(8):
		var direction := Vector2.from_angle(rng.randf_range(0.0, TAU))
		var distance := rng.randf_range(OFFSCREEN_SPAWN_MIN_DISTANCE, OFFSCREEN_SPAWN_MAX_DISTANCE)
		var candidate := spawn_focus + direction * distance
		if spawn_area.has_point(candidate):
			return candidate
	return _choose_edge_spawn()

func _choose_edge_spawn() -> Vector2:
	var edge := rng.randi_range(0, 3)
	match edge:
		0: return _north_spawn()
		1: return Vector2(bounds.position.x + 12.0, rng.randf_range(bounds.position.y + 40.0, bounds.end.y - 70.0))
		2: return Vector2(bounds.end.x - 12.0, rng.randf_range(bounds.position.y + 40.0, bounds.end.y - 70.0))
		_: return Vector2(rng.randf_range(bounds.position.x + 80.0, bounds.end.x - 80.0), bounds.end.y - 12.0)

func _north_spawn() -> Vector2:
	return Vector2(rng.randf_range(bounds.position.x + 80.0, bounds.end.x - 80.0), bounds.position.y + 14.0)
