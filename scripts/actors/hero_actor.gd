class_name HeroActor
extends Node2D

const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const COMMON_ATTACK_BONUS := 5.0
const COMMON_DEFENSE_BONUS := 3.0
const COMMON_SPEED_BONUS := 8.0
const COMMON_HEAL_RATIO := 0.10
const BASIC_ATTACK_MOVEMENT_DISTANCE := 18.0
const BASIC_ATTACK_MOVEMENT_SPEED_RATIO := 0.42
const GUARD_ACTIVE_DURATION := 0.30
const GUARD_COOLDOWN_DURATION := 1.00
const GUARD_FRONT_HALF_ANGLE := deg_to_rad(90.0)
const GUARD_TIME_EPSILON := 0.00001
const DAMAGE_FALLOFF_START_DISTANCE := 180.0
const DAMAGE_FALLOFF_END_DISTANCE := 720.0

# Shared contract for every playable hero. Individual heroes own their combo,
# passive, skill state, and presentation while the battle scene consumes this API.
enum DashKind { NONE, BASIC, ACTIVE, ULTIMATE }
enum NamedTargetKind { ELITE, BOSS }

signal attack_requested(request: AttackRequest)
signal active_used()
signal ultimate_started()
signal ultimate_ready()
signal died()
signal protection_broken()
signal damaged(amount: float)
signal visual_effect_started(effect_id: String, origin: Vector2, direction: Vector2, travel_distance: float, metadata: Dictionary)
signal camera_shake_requested(strength: float)
signal combat_action_started(action_id: String)
signal combat_action_finished(action_id: String)

var bounds := Rect2(80, 100, 1120, 500)
var hero_id := ""
var base_attack := 0.0
var base_defense := 0.0
var attack_bonus := 0.0
var defense_bonus := 0.0
var defense_ratio_bonus := 0.0
var speed := 0.0
var active_cooldown := 0.0
var active_charge_count := 1
var active_charge_capacity := 1
var ultimate_energy := 0.0
var ultimate_time := 0.0
var ultimate_segment_index := 0
var ultimate_dash_direction := Vector2.RIGHT
var last_attack_direction := Vector2.RIGHT
var combo_stage := 0
var current_action := ""
var health_component: HealthComponent
var military_named_damage_ratio := 0.0
var military_pierce_bonus := 0
var military_elite_heal_ratio := 0.0
var military_level_heal_ratio := 0.0
var military_energy_gain_multiplier := 1.0
var military_elite_energy_bonus := 0.0
var military_gold_multiplier := 1.0
var military_active_cooldown_reduction := 0.0
var basic_attack_movement_remaining := 0.0
var basic_attack_movement_direction := Vector2.RIGHT
var guard_active_remaining := 0.0
var guard_cooldown_remaining := 0.0
var guard_direction := Vector2.RIGHT
var guard_cooldown_refresh_pending := false
var movement_slow_remaining := 0.0
var movement_slow_multiplier := 1.0
var movement_slow_duration := 0.0

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id

func reset_for_run(_world_bounds: Rect2) -> void:
	pass

func reset_guard_state() -> void:
	guard_active_remaining = 0.0
	guard_cooldown_remaining = 0.0
	guard_direction = Vector2.RIGHT
	guard_cooldown_refresh_pending = false
	reset_movement_slow_state()

func reset_movement_slow_state() -> void:
	movement_slow_remaining = 0.0
	movement_slow_multiplier = 1.0
	movement_slow_duration = 0.0

func tick_movement_slow(delta: float) -> void:
	movement_slow_remaining = maxf(0.0, movement_slow_remaining - delta)
	if movement_slow_remaining <= 0.0:
		movement_slow_multiplier = 1.0
		movement_slow_duration = 0.0

func apply_movement_slow(multiplier: float, duration: float) -> void:
	if duration <= 0.0:
		return
	var clamped_duration := maxf(0.0, duration)
	if clamped_duration >= movement_slow_remaining:
		movement_slow_duration = clamped_duration
	movement_slow_remaining = maxf(movement_slow_remaining, clamped_duration)
	movement_slow_multiplier = minf(movement_slow_multiplier, clampf(multiplier, 0.30, 1.0))

func movement_speed_multiplier() -> float:
	return movement_slow_multiplier if movement_slow_remaining > 0.0 else 1.0

func tick_guard(delta: float) -> void:
	if is_defeated():
		guard_active_remaining = 0.0
		guard_cooldown_remaining = 0.0
		return
	# Treat sub-frame floating point residue as elapsed. This matters for the
	# exact 0.30s/1.00s boundaries when callers advance the simulation in
	# multiple decimal-sized steps (for example 0.29 + 0.01).
	var was_active := guard_active_remaining > GUARD_TIME_EPSILON
	var next_active_remaining := guard_active_remaining - delta
	if was_active and next_active_remaining <= GUARD_TIME_EPSILON:
		guard_active_remaining = 0.0
		# A simulation step can cross the end of the protection window. Carry
		# that overflow into the cooldown so its clock starts at the exact
		# 0.30s boundary instead of waiting for the next frame.
		var cooldown_elapsed := maxf(0.0, -next_active_remaining)
		if guard_cooldown_refresh_pending:
			# A named-enemy guard reward makes the button available as soon as
			# the current 0.3 second protection window has ended.
			guard_cooldown_remaining = 0.0
			guard_cooldown_refresh_pending = false
		else:
			# The cooldown starts after the invulnerability window, so the full
			# button-to-button cycle is 1.3 seconds.
			guard_cooldown_remaining = maxf(0.0, GUARD_COOLDOWN_DURATION - cooldown_elapsed)
	elif not was_active:
		guard_active_remaining = 0.0
		var next_cooldown_remaining := guard_cooldown_remaining - delta
		guard_cooldown_remaining = 0.0 if next_cooldown_remaining <= GUARD_TIME_EPSILON else next_cooldown_remaining
	else:
		guard_active_remaining = next_active_remaining

func request_guard(direction: Vector2 = Vector2.ZERO) -> bool:
	if not can_use_guard() or (ultimate_time > 0.0 and not allows_guard_during_ultimate()):
		return false
	if is_action_locked() and current_action != "basic" and current_action != "drag_charge":
		return false
	if current_action == "basic" or combo_stage > 0:
		interrupt_basic_attack()
	if current_action == "drag_charge" and has_method("_cancel_drag_charge"):
		call("_cancel_drag_charge")
	var facing := direction.normalized() if direction.length_squared() > 0.01 else last_attack_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = Vector2.RIGHT
	guard_direction = facing
	# Guarding is a committed stance: retain the facing used for its front arc.
	last_attack_direction = guard_direction
	guard_active_remaining = GUARD_ACTIVE_DURATION
	guard_cooldown_remaining = 0.0
	guard_cooldown_refresh_pending = false
	return true

func can_use_guard() -> bool:
	return guard_active_remaining <= 0.0 and guard_cooldown_remaining <= 0.0 and (ultimate_time <= 0.0 or allows_guard_during_ultimate()) and (health_component == null or health_component.current > 0.0)

func allows_guard_during_ultimate() -> bool:
	return false

func is_guard_active() -> bool:
	return guard_active_remaining > 0.0

func is_defeated() -> bool:
	return health_component != null and health_component.current <= 0.0

func incoming_damage_multiplier(attack_origin: Vector2) -> float:
	if attack_origin.length_squared() <= 0.01:
		return 1.0
	var distance := position.distance_to(attack_origin)
	var progress := clampf(inverse_lerp(DAMAGE_FALLOFF_START_DISTANCE, DAMAGE_FALLOFF_END_DISTANCE, distance), 0.0, 1.0)
	# Smoothstep keeps nearby hits readable while preserving a meaningful 10%
	# floor for attacks that land near the edge of the arena.
	return lerpf(1.0, 0.10, progress * progress * (3.0 - 2.0 * progress))

func incoming_knockback_multiplier(attack_origin: Vector2) -> float:
	return incoming_damage_multiplier(attack_origin)

func guard_elapsed() -> float:
	return GUARD_ACTIVE_DURATION - guard_active_remaining

func can_guard_attack(attack_origin: Vector2) -> bool:
	if not is_guard_active():
		return false
	var incoming := attack_origin - position
	if incoming.length_squared() <= 0.01:
		return true
	return guard_direction.dot(incoming.normalized()) >= cos(GUARD_FRONT_HALF_ANGLE)

func guard_cooldown_ratio() -> float:
	return clampf(guard_cooldown_remaining / GUARD_COOLDOWN_DURATION, 0.0, 1.0)

func refresh_guard_cooldown_after_named_block() -> void:
	if is_guard_active():
		guard_cooldown_refresh_pending = true
	else:
		guard_cooldown_remaining = 0.0

func tick(_delta: float, _move_direction: Vector2) -> void:
	pass

func movement_input_direction() -> Vector2:
	return Vector2.ZERO

func request_basic(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func interrupt_basic_attack() -> void:
	pass

func supports_basic_hold() -> bool:
	return false

func begin_basic_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func release_basic_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func supports_active_hold() -> bool:
	return false

func begin_active_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func release_active_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func cancel_active_hold() -> void:
	pass

func is_active_hold_charging() -> bool:
	return false

func active_hold_ratio() -> float:
	return 0.0

func request_active(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func can_use_active() -> bool:
	return not is_defeated() and active_charge_count > 0 and ultimate_time <= 0.0 and (not is_action_locked() or current_action == "basic")

func active_charges_label() -> String:
	return "%d/%d" % [active_charge_count, active_charge_capacity]

func reset_active_charges() -> void:
	active_charge_count = active_charge_capacity
	active_cooldown = 0.0

func begin_basic_attack_movement(direction: Vector2 = last_attack_direction) -> void:
	basic_attack_movement_remaining = BASIC_ATTACK_MOVEMENT_DISTANCE
	basic_attack_movement_direction = direction.normalized() if direction.length_squared() > 0.01 else last_attack_direction.normalized()
	if basic_attack_movement_direction.length_squared() <= 0.01:
		basic_attack_movement_direction = Vector2.RIGHT

func clear_basic_attack_movement() -> void:
	basic_attack_movement_remaining = 0.0

func tick_basic_attack_movement(delta: float, _move_direction: Vector2) -> void:
	if is_guard_active() or current_action not in ["basic", "drag_release"] or basic_attack_movement_remaining <= 0.0:
		return
	var travel_distance := minf(effective_move_speed() * BASIC_ATTACK_MOVEMENT_SPEED_RATIO * delta, basic_attack_movement_remaining)
	if travel_distance <= 0.0:
		return
	position += basic_attack_movement_direction * travel_distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)
	basic_attack_movement_remaining = maxf(0.0, basic_attack_movement_remaining - travel_distance)

func effective_move_speed() -> float:
	return speed * movement_speed_multiplier()

func apply_duel_push(direction: Vector2, distance: float) -> void:
	if direction.length_squared() <= 0.01 or distance <= 0.0:
		return
	position += direction.normalized() * distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)

func consume_active_charge(cooldown_duration: float) -> bool:
	if active_charge_count <= 0:
		return false
	active_charge_count -= 1
	if active_charge_count < active_charge_capacity and active_cooldown <= 0.0:
		active_cooldown = cooldown_duration
	return true

func tick_active_charge_recovery(delta: float, cooldown_duration: float) -> void:
	if active_charge_count >= active_charge_capacity:
		active_charge_count = active_charge_capacity
		active_cooldown = 0.0
		return
	active_cooldown = maxf(0.0, active_cooldown - delta)
	if active_cooldown > 0.0:
		return
	active_charge_count = mini(active_charge_capacity, active_charge_count + 1)
	if active_charge_count < active_charge_capacity:
		active_cooldown = cooldown_duration

func request_ultimate(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func apply_level_up_benefits() -> void:
	pass

func apply_account_progress(profile: Dictionary) -> void:
	_apply_military_strategy(profile)

func _apply_military_strategy(profile: Dictionary) -> void:
	var effects := MILITARY_STRATEGY.effects_for_profile(profile)
	# Permanent arsenal upgrades are flat points so their impact is readable on
	# the small base attack values used by the heroes.
	base_attack += float(effects.get("attack_bonus", 0.0))
	defense_bonus += float(effects.get("defense_bonus", 0.0))
	speed *= 1.0 + float(effects.get("move_speed_ratio", 0.0))
	military_active_cooldown_reduction = float(effects.get("active_cooldown_reduction", 0.0))
	active_charge_capacity = maxi(1, int(effects.get("active_charge_capacity", 1)))
	military_named_damage_ratio = float(effects.get("named_damage_ratio", 0.0))
	military_pierce_bonus = int(effects.get("pierce_bonus", 0))
	military_elite_heal_ratio = float(effects.get("elite_heal_ratio", 0.0))
	military_level_heal_ratio = float(effects.get("level_heal_ratio", 0.0))
	military_energy_gain_multiplier = float(effects.get("ultimate_energy_ratio", 1.0))
	military_elite_energy_bonus = float(effects.get("elite_ultimate_energy", 0.0))
	military_gold_multiplier = float(effects.get("gold_ratio", 0.0)) + 1.0
	if health_component != null:
		var health_ratio := float(effects.get("max_health_ratio", 0.0))
		if health_ratio > 0.0:
			health_component.maximum *= 1.0 + health_ratio
			health_component.current = health_component.maximum
		if bool(effects.get("starting_shield", false)):
			health_component.grant_shield()
		health_component.health_changed.emit(health_component.current, health_component.maximum)
	var starting_energy := float(effects.get("starting_ultimate_energy", 0.0))
	if starting_energy > 0.0:
		ultimate_energy = clampf(ultimate_energy + starting_energy, 0.0, 100.0)

func apply_military_level_up_benefits() -> void:
	if military_level_heal_ratio <= 0.0 or health_component == null:
		return
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * military_level_heal_ratio)
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_military_enemy_defeat_reward(enemy_type: int, allow_recovery: bool = true) -> void:
	if enemy_type != EnemySimulation.EnemyType.ELITE:
		return
	if allow_recovery and military_elite_heal_ratio > 0.0 and health_component != null:
		health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * military_elite_heal_ratio)
		health_component.health_changed.emit(health_component.current, health_component.maximum)
	if military_elite_energy_bonus > 0.0:
		add_ultimate_energy(military_elite_energy_bonus)

func apply_military_boss_defeat_reward(allow_recovery: bool = true) -> void:
	if allow_recovery and military_elite_heal_ratio > 0.0 and health_component != null:
		health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * military_elite_heal_ratio)
		health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_boss_trial_defeat_recovery() -> float:
	if health_component == null:
		return 0.0
	var missing_health := maxf(0.0, health_component.maximum - health_component.current)
	if missing_health <= 0.0:
		return 0.0
	# Recover half of the missing health, with a minimum of 10% max health
	# whenever the hero has at least that much damage to recover.
	var recovery := maxf(missing_health * 0.50, health_component.maximum * 0.10)
	var before := health_component.current
	health_component.current = minf(health_component.maximum, health_component.current + recovery)
	health_component.health_changed.emit(health_component.current, health_component.maximum)
	return health_component.current - before

func apply_upgrade(_upgrade_id: String) -> void:
	apply_common_upgrade(_upgrade_id)

func apply_common_upgrade(upgrade_id: String) -> bool:
	match upgrade_id:
		"common_attack":
			base_attack += COMMON_ATTACK_BONUS
		"common_defense":
			defense_bonus += COMMON_DEFENSE_BONUS
		"common_speed":
			speed += COMMON_SPEED_BONUS
		"common_heal":
			if health_component == null:
				return true
			var heal_amount := health_component.maximum * COMMON_HEAL_RATIO
			var before := health_component.current
			health_component.current = minf(health_component.maximum, before + heal_amount)
			if before + heal_amount > health_component.maximum:
				health_component.grant_shield()
			health_component.health_changed.emit(health_component.current, health_component.maximum)
		_:
			return false
	return true

func total_attack() -> float:
	return base_attack * (1.0 + attack_bonus)

func total_defense() -> float:
	return base_defense * (1.0 + defense_ratio_bonus) + defense_bonus

func current_stats() -> Dictionary:
	return {
		"attack": total_attack(),
		"defense": total_defense(),
		"health": health_component.current if health_component != null else 0.0,
		"max_health": health_component.maximum if health_component != null else 0.0,
		"move_speed": effective_move_speed(),
		"basic_pierce": military_pierce_bonus,
		"ultimate_cost": ultimate_cost(),
	}

func add_ultimate_energy(_value: float) -> void:
	pass

func add_fixed_ultimate_energy(value: float) -> void:
	if value <= 0.0:
		return
	var was_ready := is_ultimate_ready()
	ultimate_energy = clampf(ultimate_energy + value * military_energy_gain_multiplier, 0.0, 100.0)
	if not was_ready and is_ultimate_ready():
		ultimate_ready.emit()

func on_weapon_clash_success(perfect: bool, _skill_clash: bool) -> void:
	add_fixed_ultimate_energy(20.0 if perfect else 10.0)

func on_light_weapon_clash_success() -> void:
	pass

func on_enemy_defeated(_enemy_type: int, _allow_recovery: bool = true, _action_kind: int = AttackRequest.ActionKind.NONE) -> void:
	pass

func force_idle_state() -> void:
	# Victory presentation must not leave a gameplay attack frame on screen.
	current_action = ""
	clear_basic_attack_movement()

func on_named_target_hit(_target_kind: int, _request: AttackRequest, _damage: float) -> void:
	pass

func modify_named_target_damage(_target_kind: int, _target_key: String, _request: AttackRequest, damage: float) -> float:
	return damage * (1.0 + military_named_damage_ratio)

func record_named_target_combat_hit(_target_kind: int, _target_key: String, _request: AttackRequest, _damage: float) -> void:
	pass

func set_nearby_enemy_count(_count: int) -> void:
	pass

func nearby_enemy_radius() -> float:
	return 184.0

func receive_damage(_amount: float, _source: String, _attack_origin: Vector2 = Vector2.ZERO) -> float:
	return 0.0

func revive_from_rewarded_ad(health_ratio: float = 0.35) -> void:
	if health_component == null:
		return
	health_component.current = clampf(health_component.maximum * health_ratio, 1.0, health_component.maximum)
	health_component.health_changed.emit(health_component.current, health_component.maximum)
	current_action = ""
	combo_stage = 0
	basic_attack_movement_remaining = 0.0
	ultimate_time = 0.0
	ultimate_segment_index = 0
	reset_guard_state()

func ultimate_cost() -> float:
	return 0.0

func is_ultimate_ready() -> bool:
	return false

func is_action_locked() -> bool:
	return false

func is_attacking() -> bool:
	return false

func current_action_clash_kind() -> int:
	match current_action:
		"basic", "drag_release", "firewheel", "firewheel_finisher":
			return Telegraph.ClashKind.BASIC
		"active", "ultimate":
			return Telegraph.ClashKind.ACTIVE
	return Telegraph.ClashKind.NONE

func current_action_clash_request() -> AttackRequest:
	var clash_kind := current_action_clash_kind()
	if clash_kind == Telegraph.ClashKind.NONE:
		return null
	var direction := last_attack_direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var request := AttackRequest.line(position, direction, 220.0, 96.0, 0.0, 0, "action_clash")
	request.clash_kind = clash_kind
	return request

func is_drag_charging() -> bool:
	return false

func drag_charge_ratio() -> float:
	return 0.0

func is_wusheng_active() -> bool:
	return false

func is_zhang_fei_ultimate_active() -> bool:
	return false

func try_block_frontal_projectile(_origin: Vector2) -> bool:
	return false

func projectile_guard_block_message() -> String:
	return "攻击拦下弹道"

func open_weapon_clash_window(_request: AttackRequest, _clash_type: int) -> void:
	pass

func current_weapon_clash_type() -> int:
	return Telegraph.ClashKind.NONE

func can_weapon_clash_target(_target_position: Vector2) -> bool:
	return false

func consume_weapon_clash_window() -> void:
	pass

func grant_breakout_guard() -> void:
	pass

func basic_ability_label() -> String:
	return "普攻"

func active_ability_label() -> String:
	return "主动"

func ultimate_ability_label() -> String:
	return "无双"

# Only Huang Zhong currently exposes a fourth combat control.  Keeping this
# optional on the shared hero contract lets later heroes opt in without
# coupling the input and HUD layers to a concrete actor type.
func supports_weapon_stance() -> bool:
	return false

func weapon_stance_label() -> String:
	return ""

func request_weapon_stance_toggle() -> bool:
	return false

func is_bow_stance() -> bool:
	return false

func momentum_ratio() -> float:
	return 0.0

func presentation_id() -> String:
	return hero_id

func is_path_dashing() -> bool:
	return false

func path_dash_visual_direction() -> Vector2:
	return last_attack_direction

func is_firewheel_active() -> bool:
	return false

func is_firewheel_finisher_active() -> bool:
	return false

func is_firewheel_invulnerable() -> bool:
	return false

func firewheel_animation_time() -> float:
	return 0.0

func firewheel_spin_end_time() -> float:
	return 0.0

func firewheel_cooldown_ratio() -> float:
	return 0.0

func has_firewheel_talent() -> bool:
	return false

func has_breakout_guard() -> bool:
	return false

func has_dragon() -> bool:
	return false

func dragon_stack_count() -> int:
	return 0

func hud_status_effects() -> Array[Dictionary]:
	return []

func common_shield_hud_effect() -> Dictionary:
	if health_component == null or health_component.shield_charges <= 0:
		return {}
	return {
		"id": "dragon_shield",
		"icon": "护",
		"label": "护体",
		"stacks": health_component.shield_charges,
		"timed": false,
		"color": Color("76d6ed"),
	}

func movement_slow_hud_effect() -> Dictionary:
	if movement_slow_remaining <= 0.0:
		return {}
	return {
		"id": "movement_slow",
		"icon": "迟",
		"label": "迟滞",
		"stacks": 0,
		"stack_text": "-%d%%" % int(round((1.0 - movement_slow_multiplier) * 100.0)),
		"remaining": movement_slow_remaining,
		"duration": maxf(0.1, movement_slow_duration),
		"color": Color("d47b62"),
	}

func is_ultimate_dashing() -> bool:
	return false
