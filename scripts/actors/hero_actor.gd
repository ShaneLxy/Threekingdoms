class_name HeroActor
extends Node2D

const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const COMMON_ATTACK_BONUS := 0.05
const COMMON_DEFENSE_BONUS := 0.05
const COMMON_SPEED_BONUS := 0.02
const COMMON_HEAL_RATIO := 0.10
const BASIC_ATTACK_MOVEMENT_DISTANCE := 18.0
const BASIC_ATTACK_MOVEMENT_SPEED_RATIO := 0.42

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
signal visual_effect_started(effect_id: String, origin: Vector2, direction: Vector2, travel_distance: float)
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

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id

func reset_for_run(_world_bounds: Rect2) -> void:
	pass

func tick(_delta: float, _move_direction: Vector2) -> void:
	pass

func movement_input_direction() -> Vector2:
	return Vector2.ZERO

func request_basic(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func supports_basic_hold() -> bool:
	return false

func begin_basic_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func release_basic_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func request_active(_direction: Vector2 = Vector2.ZERO) -> bool:
	return false

func can_use_active() -> bool:
	return active_charge_count > 0 and ultimate_time <= 0.0 and (not is_action_locked() or current_action == "basic")

func active_charges_label() -> String:
	return "%d/%d" % [active_charge_count, active_charge_capacity]

func reset_active_charges() -> void:
	active_charge_count = active_charge_capacity
	active_cooldown = 0.0

func begin_basic_attack_movement() -> void:
	basic_attack_movement_remaining = BASIC_ATTACK_MOVEMENT_DISTANCE

func clear_basic_attack_movement() -> void:
	basic_attack_movement_remaining = 0.0

func tick_basic_attack_movement(delta: float, move_direction: Vector2) -> void:
	if current_action not in ["basic", "drag_release"] or basic_attack_movement_remaining <= 0.0 or move_direction.length_squared() <= 0.01:
		return
	var travel_distance := minf(speed * BASIC_ATTACK_MOVEMENT_SPEED_RATIO * delta, basic_attack_movement_remaining)
	if travel_distance <= 0.0:
		return
	var direction := move_direction.normalized()
	position += direction * travel_distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)
	basic_attack_movement_remaining = maxf(0.0, basic_attack_movement_remaining - travel_distance)

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
	attack_bonus += float(effects.get("attack_ratio", 0.0))
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

func apply_military_enemy_defeat_reward(enemy_type: int) -> void:
	if enemy_type != EnemySimulation.EnemyType.ELITE:
		return
	if military_elite_heal_ratio > 0.0 and health_component != null:
		health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * military_elite_heal_ratio)
		health_component.health_changed.emit(health_component.current, health_component.maximum)
	if military_elite_energy_bonus > 0.0:
		add_ultimate_energy(military_elite_energy_bonus)

func apply_military_boss_defeat_reward() -> void:
	if military_elite_heal_ratio <= 0.0 or health_component == null:
		return
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * military_elite_heal_ratio)
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_upgrade(_upgrade_id: String) -> void:
	apply_common_upgrade(_upgrade_id)

func apply_common_upgrade(upgrade_id: String) -> bool:
	match upgrade_id:
		"common_attack":
			attack_bonus += COMMON_ATTACK_BONUS
		"common_defense":
			defense_ratio_bonus += COMMON_DEFENSE_BONUS
		"common_speed":
			speed *= 1.0 + COMMON_SPEED_BONUS
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
		"move_speed": speed,
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

func on_enemy_defeated(_enemy_type: int) -> void:
	pass

func on_named_target_hit(_target_kind: int, _request: AttackRequest, _damage: float) -> void:
	pass

func modify_named_target_damage(_target_kind: int, _target_key: String, _request: AttackRequest, damage: float) -> float:
	return damage * (1.0 + military_named_damage_ratio)

func record_named_target_combat_hit(_target_kind: int, _target_key: String, _request: AttackRequest, _damage: float) -> void:
	pass

func set_nearby_enemy_count(_count: int) -> void:
	pass

func receive_damage(_amount: float, _source: String) -> float:
	return 0.0

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

func is_ultimate_dashing() -> bool:
	return false
