class_name PlayerActor
extends Node2D

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

const ULTIMATE_COST := 40.0
const ULTIMATE_SEGMENTS := 7
const ULTIMATE_DASH_DURATION := 0.18
const ULTIMATE_PAUSE_DURATION := 0.12
const ULTIMATE_FINAL_RECOVERY := 0.20
const ULTIMATE_DASH_DISTANCE := 185.0
const ULTIMATE_FINAL_DASH_DISTANCE := 220.0
const ULTIMATE_DASH_WIDTH := 54.0
const ULTIMATE_FINAL_SHOCKWAVE_RANGE := 124.0
const ULTIMATE_FINAL_SHOCKWAVE_KNOCKBACK := 840.0
const THIRD_DASH_DISTANCE := 100.0
const THIRD_DASH_DURATION := 0.14
const THIRD_DASH_WIDTH := 44.0
const ACTIVE_DASH_DISTANCE := 230.0
const ACTIVE_DASH_DURATION := 0.24
const ACTIVE_DASH_WIDTH := 78.0

enum UltimateState { INACTIVE, DASH, PAUSE, RECOVERY }

signal attack_requested(request: AttackRequest)
signal active_used()
signal ultimate_started()
signal ultimate_ready()
signal died()
signal protection_broken()
signal damaged(amount: float)

@onready var health_component: HealthComponent = %HealthComponent

var bounds := Rect2(80, 100, 1120, 500)
var hero_id := "zhao_yun"
var base_attack := 14.0
var base_defense := 12.0
var attack_bonus := 0.0
var defense_bonus := 0.0
var speed := 250.0
var combo_stage := 0
var combo_window := 0.0
var active_cooldown := 0.0
var ultimate_energy := 0.0
var ultimate_time := 0.0
var ultimate_state := UltimateState.INACTIVE
var ultimate_segment_index := 0
var ultimate_phase_remaining := 0.0
var ultimate_dash_direction := Vector2.RIGHT
var active_dash_direction := Vector2.RIGHT
var last_attack_direction := Vector2.RIGHT
var dragon_timer := 0.0
var attack_lock_remaining := 0.0
var hit_delay_remaining := 0.0
var pending_attack: AttackRequest
var pending_lunge_distance := 0.0
var path_dash_remaining := 0.0
var path_dash_duration := 0.0
var path_dash_distance := 0.0
var path_dash_direction := Vector2.RIGHT
var path_dash_request: AttackRequest
var path_dash_finish: AttackRequest
var path_dash_recovery_duration := 0.0
var path_dash_recovery_multiplier := 0.0
var current_action := ""
var has_buffered_basic := false
var movement_recovery_remaining := 0.0
var movement_recovery_multiplier := 0.0
var breakout_guard_remaining := 0.0
var breakout_guard_charges := 0
var basic_range_bonus := 0.0
var basic_pierce_bonus := 0
var sweep_range_bonus := 0.0
var sweep_angle_bonus := 0.0
var sweep_knockback_bonus := 0.0
var third_lunge_bonus := 0.0
var third_recovery_bonus := 0.0
var spear_shadow_level := 0
var echo_remaining := 0.0
var echo_attack: AttackRequest
var dragon_duration_bonus := 0.0
var dragon_speed_bonus := 0.0
var dragon_damage_reduction := 0.0
var active_cooldown_duration := 8.0
var active_range_bonus := 0.0
var active_damage_bonus := 0.0
var active_knockback_bonus := 0.0
var active_recovery_bonus := 0.0
var ultimate_dash_distance_bonus := 0.0
var ultimate_damage_bonus := 0.0
var ultimate_energy_gain_multiplier := 1.0
var triumph_enabled := false

func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.shield_broken.connect(_on_protection_broken)

func reset_for_run(world_bounds: Rect2) -> void:
	bounds = world_bounds
	var base_stats: Dictionary = HERO_CATALOG.definition_for(hero_id).get("stats", {})
	position = Vector2(bounds.get_center().x, bounds.end.y - 70.0)
	base_attack = float(base_stats.get("attack", 14.0))
	base_defense = float(base_stats.get("defense", 0.0))
	attack_bonus = 0.0
	defense_bonus = 0.0
	speed = float(base_stats.get("move_speed", 250.0))
	combo_stage = 0
	combo_window = 0.0
	active_cooldown = 0.0
	ultimate_energy = 0.0
	ultimate_time = 0.0
	ultimate_state = UltimateState.INACTIVE
	ultimate_segment_index = 0
	ultimate_phase_remaining = 0.0
	ultimate_dash_direction = Vector2.RIGHT
	active_dash_direction = Vector2.RIGHT
	last_attack_direction = Vector2.RIGHT
	dragon_timer = 0.0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	pending_attack = null
	pending_lunge_distance = 0.0
	path_dash_remaining = 0.0
	path_dash_duration = 0.0
	path_dash_distance = 0.0
	path_dash_direction = Vector2.RIGHT
	path_dash_request = null
	path_dash_finish = null
	path_dash_recovery_duration = 0.0
	path_dash_recovery_multiplier = 0.0
	current_action = ""
	has_buffered_basic = false
	movement_recovery_remaining = 0.0
	movement_recovery_multiplier = 0.0
	breakout_guard_remaining = 0.0
	breakout_guard_charges = 0
	basic_range_bonus = 0.0
	basic_pierce_bonus = 0
	sweep_range_bonus = 0.0
	sweep_angle_bonus = 0.0
	sweep_knockback_bonus = 0.0
	third_lunge_bonus = 0.0
	third_recovery_bonus = 0.0
	spear_shadow_level = 0
	echo_remaining = 0.0
	echo_attack = null
	dragon_duration_bonus = 0.0
	dragon_speed_bonus = 0.0
	dragon_damage_reduction = 0.0
	active_cooldown_duration = float(base_stats.get("active_cooldown", 8.0))
	active_range_bonus = 0.0
	active_damage_bonus = 0.0
	active_knockback_bonus = 0.0
	active_recovery_bonus = 0.0
	ultimate_dash_distance_bonus = 0.0
	ultimate_damage_bonus = 0.0
	ultimate_energy_gain_multiplier = 1.0
	triumph_enabled = false
	health_component.reset(float(base_stats.get("health", 120.0)))

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id if HERO_CATALOG.has_hero(selected_hero_id) else "zhao_yun"

func tick(delta: float, move_direction: Vector2) -> void:
	active_cooldown = maxf(0.0, active_cooldown - delta)
	combo_window = maxf(0.0, combo_window - delta)
	dragon_timer = maxf(0.0, dragon_timer - delta)
	movement_recovery_remaining = maxf(0.0, movement_recovery_remaining - delta)
	breakout_guard_remaining = maxf(0.0, breakout_guard_remaining - delta)
	if breakout_guard_remaining <= 0.0:
		breakout_guard_charges = 0
	var was_waiting_for_echo := echo_remaining > 0.0
	echo_remaining = maxf(0.0, echo_remaining - delta)
	if was_waiting_for_echo and echo_remaining <= 0.0 and echo_attack != null:
		attack_requested.emit(echo_attack)
		echo_attack = null
	var was_locked := attack_lock_remaining > 0.0
	attack_lock_remaining = maxf(0.0, attack_lock_remaining - delta)
	var was_waiting_for_hit := hit_delay_remaining > 0.0
	hit_delay_remaining = maxf(0.0, hit_delay_remaining - delta)
	if combo_window <= 0.0:
		combo_stage = 0
	if was_waiting_for_hit and hit_delay_remaining <= 0.0:
		_release_pending_attack()
	if ultimate_time <= 0.0:
		var move_multiplier := 1.15 + dragon_speed_bonus if dragon_timer > 0.0 else 1.0
		if path_dash_remaining > 0.0:
			_tick_path_dash(delta)
		elif not is_action_locked():
			_update_facing_from_movement(move_direction)
			_move(move_direction, speed * move_multiplier * delta)
		elif movement_recovery_remaining > 0.0:
			_update_facing_from_movement(move_direction)
			_move(move_direction, speed * movement_recovery_multiplier * delta)
	_tick_ultimate(delta, move_direction)
	if was_locked and attack_lock_remaining <= 0.0:
		_finish_action()

func request_basic(_direction: Vector2 = Vector2.ZERO) -> bool:
	if ultimate_time > 0.0:
		return false
	if is_action_locked():
		if current_action == "basic" and combo_stage < 3 and not has_buffered_basic:
			has_buffered_basic = true
			return true
		return false
	if combo_window <= 0.0:
		combo_stage = 0
	combo_stage = (combo_stage % 3) + 1
	_begin_basic(combo_stage)
	return true

func request_active(direction: Vector2 = Vector2.ZERO) -> bool:
	if active_cooldown > 0.0 or is_action_locked() or ultimate_time > 0.0:
		return false
	active_dash_direction = _eight_way_direction(direction, active_dash_direction)
	_update_facing_from_movement(active_dash_direction)
	active_cooldown = active_cooldown_duration
	current_action = "active"
	attack_lock_remaining = 0.72
	hit_delay_remaining = 0.12
	pending_attack = AttackRequest.line(position, active_dash_direction, ACTIVE_DASH_DISTANCE + active_range_bonus, ACTIVE_DASH_WIDTH, 1.70 + active_damage_bonus, 14 + basic_pierce_bonus + _dragon_pierce(), "破军")
	pending_attack.knockback = 450.0 + active_knockback_bonus
	pending_attack.forced_displacement = 78.0
	pending_attack.forced_displacement_duration = 0.12
	active_used.emit()
	return true

func request_ultimate(_direction: Vector2 = Vector2.ZERO) -> bool:
	if ultimate_energy < ULTIMATE_COST or ultimate_time > 0.0 or is_action_locked():
		return false
	ultimate_energy -= ULTIMATE_COST
	ultimate_time = 1.0
	ultimate_state = UltimateState.DASH
	ultimate_segment_index = 0
	ultimate_phase_remaining = 0.0
	ultimate_dash_direction = last_attack_direction
	ultimate_started.emit()
	return true

func add_ultimate_energy(value: float) -> void:
	var was_ready := is_ultimate_ready()
	ultimate_energy = clampf(ultimate_energy + value * ultimate_energy_gain_multiplier, 0.0, 100.0)
	if not was_ready and is_ultimate_ready():
		ultimate_ready.emit()

func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"spear_reach":
			basic_range_bonus += 28.0
			basic_pierce_bonus += 2
		"sweeping_wind":
			sweep_range_bonus += 32.0
			sweep_angle_bonus += 30.0
			sweep_knockback_bonus += 130.0
		"dash_echo":
			third_lunge_bonus += 46.0
			third_recovery_bonus += 0.08
		"dragon_armor":
			defense_bonus += 8.0
			dragon_damage_reduction = minf(0.55, dragon_damage_reduction + 0.25)
		"dragon_stride":
			dragon_duration_bonus += 1.0
			dragon_speed_bonus += 0.18
		"dragon_scale":
			health_component.maximum += 18.0
			health_component.current = minf(health_component.maximum, health_component.current + 18.0)
		"seven_edge":
			active_cooldown_duration = maxf(4.5, active_cooldown_duration - 1.25)
		"snake_spin":
			active_range_bonus += 38.0
			active_damage_bonus += 0.50
			active_knockback_bonus += 150.0
			active_recovery_bonus += 0.14
		"spear_shadow":
			spear_shadow_level += 1
		"white_dragon":
			ultimate_dash_distance_bonus += 24.0
			add_ultimate_energy(30.0)
		"returning_spear":
			ultimate_damage_bonus += 0.45
		"triumph":
			triumph_enabled = true
			ultimate_energy_gain_multiplier = minf(1.8, ultimate_energy_gain_multiplier + 0.20)
			health_component.current = minf(health_component.maximum, health_component.current + 20.0)
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func total_attack() -> float:
	return base_attack * (1.0 + attack_bonus)

func total_defense() -> float:
	return base_defense + defense_bonus

func apply_level_up_benefits() -> void:
	attack_bonus += 0.04
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * 0.06)
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_account_progress(profile: Dictionary) -> void:
	var upgrades: Array = profile.get("purchased_upgrades", [])
	if upgrades.has("dragon_tactics"):
		attack_bonus += 0.05
	if upgrades.has("seven_drill"):
		active_cooldown_duration = maxf(4.0, active_cooldown_duration - 0.50)

func current_stats() -> Dictionary:
	return {
		"attack": total_attack(),
		"defense": total_defense(),
		"health": health_component.current,
		"max_health": health_component.maximum,
		"move_speed": speed,
		"basic_range": 120.0 + basic_range_bonus,
		"basic_pierce": 2 + basic_pierce_bonus + _dragon_pierce(),
		"active_cooldown": active_cooldown_duration,
		"ultimate_cost": ULTIMATE_COST,
	}

func has_dragon() -> bool:
	return dragon_timer > 0.0

func ultimate_cost() -> float:
	return ULTIMATE_COST

func is_ultimate_ready() -> bool:
	return ultimate_energy >= ULTIMATE_COST

func is_action_locked() -> bool:
	return attack_lock_remaining > 0.0

func is_attacking() -> bool:
	return current_action == "basic" or current_action == "active"

func is_ultimate_dashing() -> bool:
	return ultimate_state == UltimateState.DASH and ultimate_phase_remaining > 0.0

func is_path_dashing() -> bool:
	return path_dash_remaining > 0.0

func path_dash_progress() -> float:
	if path_dash_duration <= 0.0:
		return 0.0
	return clampf(1.0 - path_dash_remaining / path_dash_duration, 0.0, 1.0)

func grant_breakout_guard() -> void:
	breakout_guard_remaining = 0.60
	breakout_guard_charges = 1

func has_breakout_guard() -> bool:
	return breakout_guard_remaining > 0.0 and breakout_guard_charges > 0

func receive_damage(amount: float, source: String) -> float:
	if source != "boss" and ultimate_state != UltimateState.INACTIVE:
		return 0.0
	if source != "boss" and has_breakout_guard():
		breakout_guard_charges -= 1
		protection_broken.emit()
		return 0.0
	var reduced_amount := CombatMath.mitigate_damage(amount, total_defense())
	if dragon_timer > 0.0 and dragon_damage_reduction > 0.0:
		reduced_amount *= 1.0 - dragon_damage_reduction
	var applied_damage := health_component.take_damage(reduced_amount)
	if applied_damage > 0.0:
		damaged.emit(applied_damage)
	return applied_damage

func on_enemy_defeated(enemy_type: int) -> void:
	if not triumph_enabled or enemy_type != EnemySimulation.EnemyType.ELITE:
		return
	health_component.current = minf(health_component.maximum, health_component.current + 18.0)
	health_component.health_changed.emit(health_component.current, health_component.maximum)
	add_ultimate_energy(12.0)

func trigger_dragon() -> void:
	var was_active := dragon_timer > 0.0
	dragon_timer = 3.0 + dragon_duration_bonus
	if not was_active and health_component.shield_charges == 0:
		health_component.grant_shield(1)

func _tick_ultimate(delta: float, move_direction: Vector2) -> void:
	if ultimate_state == UltimateState.INACTIVE:
		return
	match ultimate_state:
		UltimateState.DASH:
			if ultimate_phase_remaining <= 0.0:
				_begin_ultimate_dash(move_direction)
			var dash_delta := minf(delta, ultimate_phase_remaining)
			_move(ultimate_dash_direction, _ultimate_dash_distance() * dash_delta / ULTIMATE_DASH_DURATION)
			ultimate_phase_remaining = maxf(0.0, ultimate_phase_remaining - delta)
			if ultimate_phase_remaining <= 0.0:
				ultimate_segment_index += 1
				if ultimate_segment_index >= ULTIMATE_SEGMENTS:
					_emit_ultimate_final_shockwave()
					ultimate_state = UltimateState.RECOVERY
					ultimate_phase_remaining = ULTIMATE_FINAL_RECOVERY
				else:
					ultimate_state = UltimateState.PAUSE
					ultimate_phase_remaining = ULTIMATE_PAUSE_DURATION
		UltimateState.PAUSE:
			ultimate_phase_remaining = maxf(0.0, ultimate_phase_remaining - delta)
			if ultimate_phase_remaining <= 0.0:
				ultimate_state = UltimateState.DASH
		UltimateState.RECOVERY:
			ultimate_phase_remaining = maxf(0.0, ultimate_phase_remaining - delta)
			if ultimate_phase_remaining <= 0.0:
				ultimate_state = UltimateState.INACTIVE
				ultimate_time = 0.0

func _begin_ultimate_dash(move_direction: Vector2) -> void:
	if move_direction.length() > 0.1:
		ultimate_dash_direction = move_direction.normalized()
	_update_facing_from_movement(ultimate_dash_direction)
	ultimate_phase_remaining = ULTIMATE_DASH_DURATION
	var is_final_dash := ultimate_segment_index == ULTIMATE_SEGMENTS - 1
	var multiplier := 6.40 if is_final_dash else 4.20
	var request := AttackRequest.line(position, ultimate_dash_direction, _ultimate_dash_distance(), ULTIMATE_DASH_WIDTH, multiplier + ultimate_damage_bonus, 12 + basic_pierce_bonus + _dragon_pierce(), "七进七出")
	request.knockback = 620.0 if is_final_dash else 380.0
	request.forced_displacement = 72.0 if is_final_dash else 56.0
	request.forced_displacement_duration = 0.10
	attack_requested.emit(request)

func _emit_ultimate_final_shockwave() -> void:
	var request := AttackRequest.circle(position, ULTIMATE_FINAL_SHOCKWAVE_RANGE, 1.15 + ultimate_damage_bonus, 18 + basic_pierce_bonus + _dragon_pierce(), "七进七出·收势")
	request.knockback = ULTIMATE_FINAL_SHOCKWAVE_KNOCKBACK
	request.ignore_knockback_resistance = true
	attack_requested.emit(request)

func _ultimate_dash_distance() -> float:
	var base_distance := ULTIMATE_FINAL_DASH_DISTANCE if ultimate_segment_index == ULTIMATE_SEGMENTS - 1 else ULTIMATE_DASH_DISTANCE
	return base_distance + ultimate_dash_distance_bonus

func _begin_basic(stage: int) -> void:
	current_action = "basic"
	combo_window = 0.58
	has_buffered_basic = false
	var request: AttackRequest
	match stage:
		1:
			attack_lock_remaining = 0.30
			hit_delay_remaining = 0.10
			request = AttackRequest.line(position, last_attack_direction, 120.0 + basic_range_bonus, 30.0, 1.0, 2 + basic_pierce_bonus + _dragon_pierce(), "点刺")
			request.knockback = 130.0
		2:
			attack_lock_remaining = 0.40
			hit_delay_remaining = 0.16
			request = AttackRequest.fan(position, last_attack_direction, 105.0 + basic_range_bonus + sweep_range_bonus, deg_to_rad(120.0 + sweep_angle_bonus), 1.1, 5 + basic_pierce_bonus + _dragon_pierce(), "横扫")
			request.knockback = 260.0 + sweep_knockback_bonus
			_configure_breakout_knockback(request, 3, 3.0)
		3:
			attack_lock_remaining = 0.54
			hit_delay_remaining = 0.18
			request = AttackRequest.line(position, last_attack_direction, THIRD_DASH_DISTANCE + third_lunge_bonus, THIRD_DASH_WIDTH, 1.5, 6 + basic_pierce_bonus + _dragon_pierce(), "穿阵挑刺")
			request.knockback = 380.0
			request.forced_displacement = 46.0
			request.forced_displacement_duration = 0.10
			_configure_breakout_knockback(request, 6, 6.0)
	pending_attack = request

func _release_pending_attack() -> void:
	if pending_attack == null:
		return
	var released_label := pending_attack.label
	if released_label == "穿阵挑刺":
		_begin_path_dash(pending_attack, THIRD_DASH_DISTANCE + third_lunge_bonus, THIRD_DASH_DURATION, 0.14 + third_recovery_bonus, 0.75)
		pending_attack = null
		return
	if released_label == "破军":
		var finish := AttackRequest.fan(Vector2.ZERO, pending_attack.direction, 126.0 + active_range_bonus, deg_to_rad(150.0), 1.20 + active_damage_bonus, 12 + basic_pierce_bonus + _dragon_pierce(), "破军收势")
		finish.knockback = 520.0 + active_knockback_bonus
		_begin_path_dash(pending_attack, ACTIVE_DASH_DISTANCE + active_range_bonus, ACTIVE_DASH_DURATION, 0.28 + active_recovery_bonus, 0.70, finish, pending_attack.direction)
		pending_attack = null
		return
	pending_attack.origin = position
	attack_requested.emit(pending_attack)
	pending_attack = null

func _begin_path_dash(request: AttackRequest, distance: float, duration: float, recovery_duration: float, recovery_multiplier: float, finish_attack: AttackRequest = null, direction: Vector2 = Vector2.ZERO) -> void:
	path_dash_remaining = duration
	path_dash_duration = duration
	path_dash_distance = distance
	path_dash_direction = direction.normalized() if direction.length_squared() > 0.01 else last_attack_direction
	path_dash_request = request
	path_dash_request.origin = position
	path_dash_request.direction = path_dash_direction
	path_dash_request.one_hit_per_target = true
	path_dash_request.is_path_attack = true
	path_dash_finish = finish_attack
	path_dash_recovery_duration = recovery_duration
	path_dash_recovery_multiplier = recovery_multiplier

func _tick_path_dash(delta: float) -> void:
	if path_dash_request == null or path_dash_duration <= 0.0:
		path_dash_remaining = 0.0
		return
	var dash_delta := minf(delta, path_dash_remaining)
	var travel_distance := path_dash_distance * dash_delta / path_dash_duration
	var start := position
	_move(path_dash_direction, travel_distance)
	path_dash_request.origin = start
	path_dash_request.direction = path_dash_direction
	path_dash_request.range = travel_distance + 12.0
	attack_requested.emit(path_dash_request)
	path_dash_remaining = maxf(0.0, path_dash_remaining - delta)
	if path_dash_remaining > 0.0:
		return
	if path_dash_finish != null:
		path_dash_finish.origin = position
		path_dash_finish.direction = path_dash_direction
		attack_requested.emit(path_dash_finish)
		if path_dash_request.label == "破军":
			_schedule_spear_shadow()
	_open_movement_recovery(path_dash_recovery_duration, path_dash_recovery_multiplier)
	path_dash_request = null
	path_dash_finish = null

func _finish_action() -> void:
	if current_action == "basic" and has_buffered_basic:
		has_buffered_basic = false
		combo_stage = (combo_stage % 3) + 1
		_begin_basic(combo_stage)
		return
	current_action = ""

func _move(direction: Vector2, distance: float) -> void:
	var normalized := direction.normalized() if direction.length() > 0.1 else Vector2.ZERO
	position += normalized * distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)

func _open_movement_recovery(duration: float, speed_multiplier: float) -> void:
	movement_recovery_remaining = maxf(movement_recovery_remaining, duration)
	movement_recovery_multiplier = maxf(movement_recovery_multiplier, speed_multiplier)

func _schedule_spear_shadow() -> void:
	if spear_shadow_level <= 0:
		return
	echo_remaining = 0.18
	echo_attack = AttackRequest.line(position, last_attack_direction, 125.0 + active_range_bonus, 50.0, 0.65 + 0.12 * spear_shadow_level, 5 + spear_shadow_level + basic_pierce_bonus, "破军枪影")
	echo_attack.knockback = 180.0

func _configure_breakout_knockback(request: AttackRequest, target_limit: int, distance_multiplier: float) -> void:
	request.fan_knockback = true
	if randf() > 0.5:
		return
	request.empowered_knockback_active = true
	request.empowered_knockback_target_limit = target_limit
	request.empowered_knockback_multiplier = distance_multiplier

func _update_facing_from_movement(move_direction: Vector2) -> void:
	if absf(move_direction.x) > 0.1:
		last_attack_direction = Vector2.LEFT if move_direction.x < 0.0 else Vector2.RIGHT

func _eight_way_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	if direction.length_squared() <= 0.01:
		return fallback.normalized() if fallback.length_squared() > 0.01 else Vector2.RIGHT
	var snapped_angle := snappedf(direction.angle(), PI * 0.25)
	return Vector2.from_angle(snapped_angle)

func _dragon_pierce() -> int:
	return 2 if dragon_timer > 0.0 else 0

func _on_died() -> void:
	died.emit()

func _on_protection_broken() -> void:
	protection_broken.emit()
