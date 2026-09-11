class_name PlayerActor
extends HeroActor

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

const ULTIMATE_COST := 60.0
const ULTIMATE_SEGMENTS := 7
const ULTIMATE_DASH_DURATION := 0.18
const ULTIMATE_PAUSE_DURATION := 0.12
const ULTIMATE_FINAL_RECOVERY := 0.20
const ULTIMATE_DASH_DISTANCE := 185.0
const ULTIMATE_FINAL_DASH_DISTANCE := 220.0
const ULTIMATE_DASH_WIDTH := 88.0
const ULTIMATE_FINAL_DASH_WIDTH := 104.0
const ULTIMATE_FINAL_SHOCKWAVE_RANGE := 124.0
const ULTIMATE_FINAL_SHOCKWAVE_KNOCKBACK := 840.0
const THIRD_DASH_DISTANCE := 132.0
const THIRD_DASH_DURATION := 0.14
const THIRD_DASH_WIDTH := 144.0
const THIRD_DASH_KNOCKBACK := 460.0
const THIRD_DASH_FORCED_DISPLACEMENT := 60.0
# The third-strike flare reaches well beyond Zhao Yun's body. Keep the moving
# line hitbox broad enough to cover the visible spear sweep, especially on X.
const THIRD_DASH_FRONT_REACH := 158.0
const BASIC_STRIKE_RANGE := 144.0
const BASIC_SWEEP_RADIUS := 120.0
const ACTIVE_DASH_DISTANCE := 230.0
const ACTIVE_DASH_DURATION := 0.24
const ACTIVE_DASH_WIDTH := 78.0
const FIRST_STRIKE_SHOCKWAVE_RANGE := 76.0
const FIRST_STRIKE_SHOCKWAVE_KNOCKBACK := 460.0
const DRAGON_PROGRESS_THRESHOLD := 15
const DRAGON_PROGRESS_PER_ENEMY_DEFEAT := 1
const DRAGON_PROGRESS_PER_ELITE_HIT := 3
const DRAGON_PROGRESS_PER_BOSS_HIT := 5
const DRAGON_MAX_STACKS := 3
const DRAGON_BASE_DURATION := 5.0
const DRAGON_EXTRA_STACK_SPEED := 0.08
const DRAGON_BASE_SPEED_BONUS := 0.15
const DRAGON_SPEED_BONUS_CAP := 1.20
const DRAGON_SHIELD_INVULNERABILITY_DURATION := 5.0
const PROJECTILE_GUARD_SMALL_HALF_ANGLE := deg_to_rad(35.0)
const PROJECTILE_GUARD_LARGE_HALF_ANGLE := deg_to_rad(70.0)
const PROJECTILE_GUARD_BLOCK_LIMIT := 3
const FIREWHEEL_STARTUP_DURATION := 0.32
const FIREWHEEL_SPIN_DURATION := 0.48
const FIREWHEEL_RECOVERY_DURATION := 0.18
const FIREWHEEL_COOLDOWN_DURATION := 5.0
const FIREWHEEL_DURATION_UPGRADE_BONUS := 0.5
const FIREWHEEL_RANGE := 112.0
const FIREWHEEL_PULSE_TIMES := [0.36, 0.60]
const FIREWHEEL_EXTENDED_PULSE_TIME := 0.88
const FIREWHEEL_PROJECTILE_BATCH_COUNT := 4
const FIREWHEEL_PROJECTILES_PER_BATCH := 3
const FIREWHEEL_PROJECTILE_START_TIME := 0.36
const FIREWHEEL_PROJECTILE_BATCH_INTERVAL := 0.12
const FIREWHEEL_PROJECTILE_STAGGER_INTERVAL := 0.04
const FIREWHEEL_PROJECTILE_RANGE := 620.0
const FIREWHEEL_PROJECTILE_WIDTH := 28.0
const FIREWHEEL_PROJECTILE_DAMAGE_MULTIPLIER := 0.35
const FIREWHEEL_PROJECTILE_KNOCKBACK := 180.0
const FIREWHEEL_CAPSTONE_SPIN_END_TIME := 3.0
const FIREWHEEL_CAPSTONE_PROJECTILE_BATCH_TIMES := [0.42, 0.96, 1.50, 2.04, 2.58]
const FIREWHEEL_CAPSTONE_PULSE_TIMES := [0.36, 0.84, 1.32, 1.80, 2.28, 2.76]
const FIREWHEEL_CAPSTONE_PULSE_DAMAGE_MULTIPLIERS := [0.66, 0.70, 0.74, 0.78, 0.82, 0.86]
const FIREWHEEL_CAPSTONE_PROJECTILES_PER_BATCH := 6
const FIREWHEEL_CAPSTONE_PROJECTILE_SIZE_MULTIPLIER := 4.0
const FIREWHEEL_CAPSTONE_PROJECTILE_DAMAGE_MULTIPLIER := 0.14
const FIREWHEEL_FINISHER_DURATION := 0.65
const FIREWHEEL_FINISHER_RELEASE_TIME := 0.50
const FIREWHEEL_RING_SPEED := 420.0
const FIREWHEEL_RING_HIT_RADIUS := 68.0
const FIREWHEEL_RING_DAMAGE_MULTIPLIER := 2.50
const FIREWHEEL_RING_KNOCKBACK := 440.0
const FIREWHEEL_CAPSTONE_PULSE_RADIUS := 180.0
const FIREWHEEL_CAPSTONE_PULSE_SHAKE_STRENGTH := 6.0
const BASIC_COMBO_STAGES := 3
const WEAPON_CLASH_ACTIVE_DURATION := 0.18
const WEAPON_CLASH_REACH := 168.0

enum UltimateState { INACTIVE, DASH, PAUSE, RECOVERY }

var combo_window := 0.0
var ultimate_state := UltimateState.INACTIVE
var ultimate_phase_remaining := 0.0
var ultimate_dash_remaining_distance := 0.0
var ultimate_dash_speed := 0.0
var active_dash_direction := Vector2.RIGHT
var dragon_timer := 0.0
var dragon_progress := 0
var dragon_progress_threshold := DRAGON_PROGRESS_THRESHOLD
var dragon_stacks := 0
var dragon_scale_regen_rank := 0
var dragon_stride_double_enabled := false
var dragon_stride_three_stack_duration_enabled := false
var dragon_shield_charge_bonus := 0
var dragon_shield_invulnerability_enabled := false
var dragon_shield_invulnerable_remaining := 0.0
var projectile_guard_level := 0
var projectile_guard_blocks_remaining := 0
var attack_lock_remaining := 0.0
var hit_delay_remaining := 0.0
var pending_attack: AttackRequest
var pending_first_strike_shockwave: AttackRequest
var pending_lunge_distance := 0.0
var path_dash_remaining := 0.0
var path_dash_duration := 0.0
var path_dash_distance := 0.0
var path_dash_travel_remaining := 0.0
var path_dash_speed := 0.0
var path_dash_direction := Vector2.RIGHT
var path_dash_front_reach := 12.0
var path_dash_request: AttackRequest
var path_dash_finish: AttackRequest
var path_dash_recovery_duration := 0.0
var path_dash_recovery_multiplier := 0.0
var has_buffered_basic := false
var buffered_basic_direction := Vector2.ZERO
var current_move_direction := Vector2.ZERO
var movement_recovery_remaining := 0.0
var movement_recovery_multiplier := 0.0
var breakout_guard_remaining := 0.0
var breakout_guard_charges := 0
var weapon_clash_remaining := 0.0
var weapon_clash_direction := Vector2.RIGHT
var weapon_clash_type := Telegraph.ClashKind.NONE
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
var firewheel_enabled := false
var firewheel_duration_bonus := 0.0
var firewheel_projectiles_enabled := false
var firewheel_capstone_enabled := false
var firewheel_cooldown_remaining := 0.0
var firewheel_triggered_for_current_dragon := false
var firewheel_elapsed := 0.0
var firewheel_pulse_count := 0
var firewheel_projectile_batch_count := 0
var firewheel_pending_projectiles: Array[Dictionary] = []
var ultimate_firewheel_pending_projectiles: Array[Dictionary] = []
var firewheel_finisher_elapsed := 0.0
var firewheel_finisher_released := false
var firewheel_ring_position := Vector2.ZERO
var firewheel_ring_direction := Vector2.RIGHT
var firewheel_ring_remaining := 0.0
var firewheel_ring_attack: AttackRequest

func _ready() -> void:
	health_component = %HealthComponent
	health_component.died.connect(_on_died)
	health_component.shield_broken.connect(_on_protection_broken)

func reset_for_run(world_bounds: Rect2) -> void:
	bounds = world_bounds
	var base_stats: Dictionary = HERO_CATALOG.definition_for(hero_id).get("stats", {})
	# Start near the playable field's center so the opening view is readable and
	# does not pin the hero to the lower map edge. RunScene still applies obstacle
	# and mode-specific boundary correction after reset.
	position = bounds.get_center()
	base_attack = float(base_stats.get("attack", 14.0))
	base_defense = float(base_stats.get("defense", 0.0))
	attack_bonus = 0.0
	defense_bonus = 0.0
	defense_ratio_bonus = 0.0
	speed = float(base_stats.get("move_speed", 250.0))
	combo_stage = 0
	combo_window = 0.0
	active_cooldown = 0.0
	active_charge_capacity = 1
	active_charge_count = 1
	ultimate_energy = 0.0
	ultimate_time = 0.0
	ultimate_state = UltimateState.INACTIVE
	ultimate_segment_index = 0
	ultimate_phase_remaining = 0.0
	ultimate_dash_direction = Vector2.RIGHT
	reset_guard_state()
	ultimate_dash_remaining_distance = 0.0
	ultimate_dash_speed = 0.0
	active_dash_direction = Vector2.RIGHT
	last_attack_direction = Vector2.RIGHT
	dragon_timer = 0.0
	dragon_progress = 0
	dragon_progress_threshold = DRAGON_PROGRESS_THRESHOLD
	dragon_stacks = 0
	dragon_scale_regen_rank = 0
	dragon_stride_double_enabled = false
	dragon_stride_three_stack_duration_enabled = false
	dragon_shield_charge_bonus = 0
	dragon_shield_invulnerability_enabled = false
	dragon_shield_invulnerable_remaining = 0.0
	projectile_guard_level = 0
	projectile_guard_blocks_remaining = 0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	pending_attack = null
	pending_first_strike_shockwave = null
	pending_lunge_distance = 0.0
	path_dash_remaining = 0.0
	path_dash_duration = 0.0
	path_dash_distance = 0.0
	path_dash_travel_remaining = 0.0
	path_dash_speed = 0.0
	path_dash_direction = Vector2.RIGHT
	path_dash_front_reach = 12.0
	path_dash_request = null
	path_dash_finish = null
	path_dash_recovery_duration = 0.0
	path_dash_recovery_multiplier = 0.0
	current_action = ""
	clear_basic_attack_movement()
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	current_move_direction = Vector2.ZERO
	movement_recovery_remaining = 0.0
	movement_recovery_multiplier = 0.0
	breakout_guard_remaining = 0.0
	breakout_guard_charges = 0
	weapon_clash_remaining = 0.0
	weapon_clash_direction = Vector2.RIGHT
	weapon_clash_type = Telegraph.ClashKind.NONE
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
	firewheel_enabled = false
	firewheel_duration_bonus = 0.0
	firewheel_projectiles_enabled = false
	firewheel_capstone_enabled = false
	firewheel_cooldown_remaining = 0.0
	firewheel_triggered_for_current_dragon = false
	firewheel_elapsed = 0.0
	firewheel_pulse_count = 0
	firewheel_projectile_batch_count = 0
	firewheel_pending_projectiles.clear()
	ultimate_firewheel_pending_projectiles.clear()
	firewheel_finisher_elapsed = 0.0
	firewheel_finisher_released = false
	firewheel_ring_position = Vector2.ZERO
	firewheel_ring_direction = Vector2.RIGHT
	firewheel_ring_remaining = 0.0
	firewheel_ring_attack = null
	health_component.reset(float(base_stats.get("health", 120.0)))

func revive_from_rewarded_ad(health_ratio: float = 0.35) -> void:
	if health_component == null:
		return
	health_component.current = clampf(health_component.maximum * health_ratio, 1.0, health_component.maximum)
	health_component.health_changed.emit(health_component.current, health_component.maximum)
	current_action = ""
	combo_stage = 0
	combo_window = 0.0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	pending_attack = null
	has_buffered_basic = false
	basic_attack_movement_remaining = 0.0
	ultimate_time = 0.0
	ultimate_segment_index = 0
	ultimate_state = UltimateState.INACTIVE
	reset_guard_state()

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id if HERO_CATALOG.has_hero(selected_hero_id) else "zhao_yun"

func basic_ability_label() -> String:
	return "龙胆枪"

func active_ability_label() -> String:
	return "破军"

func ultimate_ability_label() -> String:
	return "七进"

func tick(delta: float, move_direction: Vector2) -> void:
	if is_defeated():
		return
	tick_movement_slow(delta)
	current_move_direction = move_direction
	_update_buffered_basic_direction()
	tick_active_charge_recovery(delta, _active_cooldown_for_current_state())
	firewheel_cooldown_remaining = maxf(0.0, firewheel_cooldown_remaining - delta)
	combo_window = maxf(0.0, combo_window - delta)
	var was_dragon_active := dragon_timer > 0.0
	dragon_timer = maxf(0.0, dragon_timer - delta)
	dragon_shield_invulnerable_remaining = maxf(0.0, dragon_shield_invulnerable_remaining - delta)
	if was_dragon_active and dragon_timer <= 0.0:
		dragon_stacks = 0
		firewheel_triggered_for_current_dragon = false
		_try_trigger_dragon_from_progress()
	movement_recovery_remaining = maxf(0.0, movement_recovery_remaining - delta)
	breakout_guard_remaining = maxf(0.0, breakout_guard_remaining - delta)
	if breakout_guard_remaining <= 0.0:
		breakout_guard_charges = 0
	weapon_clash_remaining = maxf(0.0, weapon_clash_remaining - delta)
	var was_waiting_for_echo := echo_remaining > 0.0
	echo_remaining = maxf(0.0, echo_remaining - delta)
	if was_waiting_for_echo and echo_remaining <= 0.0 and echo_attack != null:
		attack_requested.emit(echo_attack)
		echo_attack = null
	var was_locked := attack_lock_remaining > 0.0
	attack_lock_remaining = maxf(0.0, attack_lock_remaining - delta)
	var was_waiting_for_hit := hit_delay_remaining > 0.0
	hit_delay_remaining = maxf(0.0, hit_delay_remaining - delta)
	if combo_window <= 0.0 and not (current_action == "basic" and was_locked):
		combo_stage = 0
	if was_waiting_for_hit and hit_delay_remaining <= 0.0:
		_release_pending_attack()
	if ultimate_time <= 0.0 and not is_guard_active():
		var move_multiplier := _dragon_move_multiplier()
		if path_dash_remaining > 0.0:
			_tick_path_dash(delta)
		elif current_action == "basic" and hit_delay_remaining <= 0.0:
			tick_basic_attack_movement(delta, move_direction)
		elif not is_action_locked():
			_update_facing_from_movement(move_direction)
			_move(move_direction, speed * move_multiplier * movement_speed_multiplier() * delta)
		elif movement_recovery_remaining > 0.0:
			_update_facing_from_movement(move_direction)
			_move(move_direction, speed * movement_recovery_multiplier * movement_speed_multiplier() * delta)
	_tick_ultimate(delta, move_direction)
	if current_action == "firewheel":
		_tick_firewheel(delta)
	if is_firewheel_finisher_active():
		_tick_firewheel_finisher(delta)
	if firewheel_ring_attack != null:
		_tick_firewheel_ring(delta)
	_tick_pending_ultimate_firewheel_projectiles(delta)
	if was_locked and attack_lock_remaining <= 0.0:
		_finish_action()

func request_basic(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or ultimate_time > 0.0 or is_guard_active():
		return false
	if is_action_locked():
		if current_action == "basic" and combo_stage < BASIC_COMBO_STAGES and not has_buffered_basic:
			has_buffered_basic = true
			buffered_basic_direction = _eight_way_direction(_current_basic_input(direction), last_attack_direction)
			return true
		return false
	_update_facing_from_movement(_current_basic_input(direction))
	if combo_window <= 0.0:
		combo_stage = 0
	combo_stage = (combo_stage % BASIC_COMBO_STAGES) + 1
	_begin_basic(combo_stage)
	return true

func request_active(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or active_charge_count <= 0 or ultimate_time > 0.0 or is_guard_active():
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	active_dash_direction = _eight_way_direction(direction, active_dash_direction)
	_update_facing_from_movement(active_dash_direction)
	consume_active_charge(_active_cooldown_for_current_state())
	current_action = "active"
	combat_action_started.emit("active")
	attack_lock_remaining = 0.72
	hit_delay_remaining = 0.12
	pending_attack = AttackRequest.line(position, active_dash_direction, ACTIVE_DASH_DISTANCE + active_range_bonus, ACTIVE_DASH_WIDTH, 1.70 + active_damage_bonus, 14 + basic_pierce_bonus + _dragon_pierce(), "破军")
	pending_attack.action_kind = AttackRequest.ActionKind.ACTIVE
	pending_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	pending_attack.dash_kind = HeroActor.DashKind.ACTIVE
	pending_attack.stance_damage = 28.0
	pending_attack.grants_breakout_guard_on_hit = true
	pending_attack.knockback = 450.0 + active_knockback_bonus
	pending_attack.forced_displacement = 78.0
	pending_attack.forced_displacement_duration = 0.12
	active_used.emit()
	return true

func request_ultimate(_direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or ultimate_energy < ULTIMATE_COST or ultimate_time > 0.0 or is_guard_active():
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	ultimate_energy -= ULTIMATE_COST
	ultimate_time = 1.0
	ultimate_state = UltimateState.DASH
	ultimate_segment_index = 0
	ultimate_phase_remaining = 0.0
	ultimate_dash_direction = last_attack_direction
	combat_action_started.emit("ultimate")
	ultimate_started.emit()
	return true

func add_ultimate_energy(value: float) -> void:
	var was_ready := is_ultimate_ready()
	ultimate_energy = clampf(ultimate_energy + value * ultimate_energy_gain_multiplier * military_energy_gain_multiplier, 0.0, 100.0)
	if not was_ready and is_ultimate_ready():
		ultimate_ready.emit()

func apply_upgrade(upgrade_id: String) -> void:
	if apply_common_upgrade(upgrade_id):
		return
	match upgrade_id:
		"spear_reach":
			basic_range_bonus += 28.0
			basic_pierce_bonus += 2
		"sweeping_wind":
			sweep_range_bonus += 10.0
			sweep_angle_bonus += 15.0
			sweep_knockback_bonus += 130.0
		"sweeping_guard":
			projectile_guard_level = maxi(projectile_guard_level, 1)
		"sweeping_guard_large":
			projectile_guard_level = 2
		"dash_echo":
			third_lunge_bonus += 25.0
			third_recovery_bonus += 0.08
		"firewheel":
			firewheel_enabled = true
		"firewheel_duration":
			firewheel_duration_bonus = FIREWHEEL_DURATION_UPGRADE_BONUS
		"firewheel_volley":
			firewheel_projectiles_enabled = true
		"firewheel_capstone":
			firewheel_capstone_enabled = true
		"dragon_focus":
			dragon_progress_threshold = 12 if dragon_progress_threshold >= DRAGON_PROGRESS_THRESHOLD else 9
			_try_trigger_dragon_from_progress()
		"dragon_armor":
			defense_bonus += 8.0
			dragon_damage_reduction = minf(0.55, dragon_damage_reduction + 0.25)
		"dragon_stride":
			dragon_duration_bonus += 1.0
			dragon_speed_bonus += 0.18
		"dragon_stride_double":
			dragon_stride_double_enabled = true
			if has_dragon():
				dragon_timer = _dragon_duration()
		"dragon_stride_threefold":
			dragon_stride_three_stack_duration_enabled = true
			if has_dragon():
				dragon_timer = _dragon_duration()
		"dragon_scale":
			health_component.maximum += 18.0
			health_component.current = minf(health_component.maximum, health_component.current + 18.0)
		"dragon_scale_regen":
			dragon_scale_regen_rank = mini(3, dragon_scale_regen_rank + 1)
		"dragon_focus_guard":
			dragon_shield_charge_bonus = 3
			health_component.set_shield_charge_cap(1 + dragon_shield_charge_bonus)
			if health_component.shield_charges > 0:
				health_component.grant_shield(dragon_shield_charge_bonus)
		"dragon_focus_invulnerable":
			dragon_shield_invulnerability_enabled = true
		"seven_edge":
			active_cooldown_duration = maxf(4.5, active_cooldown_duration - 1.25)
		"snake_spin":
			active_range_bonus += 38.0
			active_damage_bonus += 0.50
			active_knockback_bonus += 150.0
			active_recovery_bonus += 0.14
		"spear_shadow":
			# 枪影随行是单次战法；旧存档即使带有重复计数，运行时也只保留一层。
			spear_shadow_level = mini(1, spear_shadow_level + 1)
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
	return base_defense * (1.0 + defense_ratio_bonus) + defense_bonus

func apply_level_up_benefits() -> void:
	attack_bonus += 0.04
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * 0.06)
	apply_military_level_up_benefits()
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_account_progress(profile: Dictionary) -> void:
	_apply_military_strategy(profile)
	active_cooldown_duration = maxf(4.0, active_cooldown_duration - military_active_cooldown_reduction)
	reset_active_charges()
	basic_pierce_bonus += military_pierce_bonus

func current_stats() -> Dictionary:
	return {
		"attack": total_attack(),
		"defense": total_defense(),
		"health": health_component.current,
		"max_health": health_component.maximum,
		"move_speed": effective_move_speed(),
		"basic_range": BASIC_STRIKE_RANGE + basic_range_bonus,
		"basic_pierce": 2 + basic_pierce_bonus + _dragon_pierce(),
		"active_cooldown": active_cooldown_duration,
		"ultimate_cost": ULTIMATE_COST,
	}

func effective_move_speed() -> float:
	return speed * _dragon_move_multiplier() * movement_speed_multiplier()

func _active_cooldown_for_current_state() -> float:
	return active_cooldown_duration

func has_dragon() -> bool:
	return dragon_timer > 0.0 and dragon_stacks > 0

func dragon_stack_count() -> int:
	return dragon_stacks

func hud_status_effects() -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	var slow_effect := movement_slow_hud_effect()
	if not slow_effect.is_empty():
		effects.append(slow_effect)
	if has_dragon():
		effects.append({
			"id": "dragon",
			"icon": "龙",
			"label": "龙胆",
			"stacks": dragon_stacks,
			"remaining": dragon_timer,
			"duration": _dragon_duration(),
			"color": Color("63b9df"),
		})
	if dragon_shield_invulnerable_remaining > 0.0:
		effects.append({
			"id": "dragon_shield_invulnerability",
			"icon": "甲",
			"label": "龙甲无敌",
			"stacks": 0,
			"remaining": dragon_shield_invulnerable_remaining,
			"duration": DRAGON_SHIELD_INVULNERABILITY_DURATION,
			"color": Color("f3ca54"),
		})
	elif not common_shield_hud_effect().is_empty():
		effects.append(common_shield_hud_effect())
	return effects

func add_dragon_progress(value: int) -> void:
	if value <= 0:
		return
	dragon_progress += value
	_try_trigger_dragon_from_progress()

func ultimate_cost() -> float:
	return ULTIMATE_COST

func is_ultimate_ready() -> bool:
	return ultimate_energy >= ULTIMATE_COST

func is_action_locked() -> bool:
	return attack_lock_remaining > 0.0

func is_attacking() -> bool:
	return current_action == "basic" or current_action == "active" or current_action == "firewheel" or current_action == "firewheel_finisher"

func open_weapon_clash_window(request: AttackRequest, clash_type: int) -> void:
	if clash_type == Telegraph.ClashKind.NONE:
		return
	weapon_clash_remaining = WEAPON_CLASH_ACTIVE_DURATION
	weapon_clash_direction = request.direction.normalized()
	weapon_clash_type = clash_type
	if weapon_clash_direction.length_squared() <= 0.01:
		weapon_clash_direction = last_attack_direction

func is_weapon_clash_active() -> bool:
	return weapon_clash_remaining > 0.0

func current_weapon_clash_type() -> int:
	return weapon_clash_type if is_weapon_clash_active() else Telegraph.ClashKind.NONE

func can_weapon_clash_target(target_position: Vector2) -> bool:
	if not is_weapon_clash_active():
		return false
	var toward_target := target_position - position
	if toward_target.length_squared() <= 0.01:
		return true
	return toward_target.length() <= WEAPON_CLASH_REACH and weapon_clash_direction.dot(toward_target.normalized()) >= -0.10

func consume_weapon_clash_window() -> void:
	weapon_clash_remaining = 0.0
	weapon_clash_type = Telegraph.ClashKind.NONE

func is_firewheel_active() -> bool:
	return current_action == "firewheel" or (current_action == "firewheel_finisher" and not firewheel_finisher_released)

func has_firewheel_talent() -> bool:
	return firewheel_enabled

func firewheel_cooldown_ratio() -> float:
	return clampf(firewheel_cooldown_remaining / FIREWHEEL_COOLDOWN_DURATION, 0.0, 1.0)

func is_firewheel_finisher_active() -> bool:
	return current_action == "firewheel_finisher"

func is_firewheel_invulnerable() -> bool:
	return is_firewheel_active() and firewheel_elapsed < firewheel_spin_end_time()

func firewheel_animation_time() -> float:
	return firewheel_elapsed

func firewheel_spin_end_time() -> float:
	if firewheel_capstone_enabled:
		return FIREWHEEL_CAPSTONE_SPIN_END_TIME
	return FIREWHEEL_STARTUP_DURATION + FIREWHEEL_SPIN_DURATION + firewheel_duration_bonus

func is_ultimate_dashing() -> bool:
	return ultimate_state == UltimateState.DASH and ultimate_phase_remaining > 0.0

func is_path_dashing() -> bool:
	return path_dash_remaining > 0.0

func path_dash_visual_origin() -> Vector2:
	return path_dash_request.origin if path_dash_request != null else position

func path_dash_visual_range() -> float:
	return path_dash_request.range if path_dash_request != null else 0.0

func path_dash_visual_width() -> float:
	return path_dash_request.width if path_dash_request != null else THIRD_DASH_WIDTH

func path_dash_visual_direction() -> Vector2:
	return path_dash_direction

func path_dash_progress() -> float:
	if path_dash_duration <= 0.0:
		return 0.0
	return clampf(1.0 - path_dash_remaining / path_dash_duration, 0.0, 1.0)

func grant_breakout_guard() -> void:
	breakout_guard_remaining = 0.60
	breakout_guard_charges = 1

func has_breakout_guard() -> bool:
	return breakout_guard_remaining > 0.0 and breakout_guard_charges > 0

func receive_damage(amount: float, source: String, _attack_origin: Vector2 = Vector2.ZERO) -> float:
	if is_defeated():
		return 0.0
	if dragon_shield_invulnerable_remaining > 0.0:
		return 0.0
	if is_firewheel_invulnerable():
		return 0.0
	# 七进七出期间对所有伤害来源免疫，包括领主攻击。
	if ultimate_state != UltimateState.INACTIVE:
		return 0.0
	if source != "boss" and has_breakout_guard():
		breakout_guard_charges -= 1
		protection_broken.emit()
		return 0.0
	var reduced_amount := CombatMath.mitigate_damage(amount, total_defense()) * incoming_damage_multiplier(_attack_origin)
	if dragon_timer > 0.0 and dragon_damage_reduction > 0.0:
		reduced_amount *= 1.0 - dragon_damage_reduction
	var applied_damage := health_component.take_damage(reduced_amount)
	if applied_damage > 0.0:
		damaged.emit(applied_damage)
	return applied_damage

func interrupt_basic_attack() -> void:
	if current_action == "basic" or combo_stage > 0 or combo_window > 0.0:
		_cancel_basic_for_skill()

func on_enemy_defeated(enemy_type: int, allow_recovery: bool = true, _action_kind: int = AttackRequest.ActionKind.NONE) -> void:
	add_dragon_progress(DRAGON_PROGRESS_PER_ENEMY_DEFEAT)
	apply_military_enemy_defeat_reward(enemy_type, allow_recovery)
	var restored_health := false
	if allow_recovery and dragon_scale_regen_rank > 0 and enemy_type != EnemySimulation.EnemyType.ELITE and randf() < 0.05 + float(dragon_scale_regen_rank) * 0.03:
		health_component.current = minf(health_component.maximum, health_component.current + float(dragon_scale_regen_rank))
		restored_health = true
	if allow_recovery and triumph_enabled and enemy_type == EnemySimulation.EnemyType.ELITE:
		health_component.current = minf(health_component.maximum, health_component.current + 18.0)
		restored_health = true
	if triumph_enabled and enemy_type == EnemySimulation.EnemyType.ELITE:
		add_ultimate_energy(12.0)
	if restored_health:
		health_component.health_changed.emit(health_component.current, health_component.maximum)

func force_idle_state() -> void:
	super.force_idle_state()
	combo_window = 0.0
	combo_stage = 0
	ultimate_state = UltimateState.INACTIVE
	ultimate_time = 0.0
	ultimate_phase_remaining = 0.0
	ultimate_dash_remaining_distance = 0.0
	pending_attack = null
	pending_first_strike_shockwave = null
	path_dash_remaining = 0.0
	path_dash_request = null
	path_dash_finish = null
	has_buffered_basic = false
	movement_recovery_remaining = 0.0

func on_named_target_hit(target_kind: int, request: AttackRequest, damage: float) -> void:
	if damage <= 0.0 or not request.grants_special_target_dragon_progress:
		return
	if target_kind == HeroActor.NamedTargetKind.ELITE:
		add_dragon_progress(DRAGON_PROGRESS_PER_ELITE_HIT)
	elif target_kind == HeroActor.NamedTargetKind.BOSS:
		add_dragon_progress(DRAGON_PROGRESS_PER_BOSS_HIT)

func on_weapon_clash_success(perfect: bool, skill_clash: bool) -> void:
	super.on_weapon_clash_success(perfect, skill_clash)
	_grant_clash_dragon_stack()
	active_cooldown = maxf(0.0, active_cooldown - active_cooldown_duration * 0.20)

func trigger_dragon() -> void:
	if dragon_stacks <= 0:
		firewheel_triggered_for_current_dragon = false
	dragon_stacks = mini(DRAGON_MAX_STACKS, dragon_stacks + 1)
	dragon_timer = _dragon_duration()
	if dragon_stacks == 1:
		_grant_dragon_shield()

func _grant_clash_dragon_stack() -> void:
	if dragon_stacks >= DRAGON_MAX_STACKS:
		dragon_timer = _dragon_duration()
		return
	dragon_stacks += 1
	dragon_timer = _dragon_duration()
	if dragon_stacks == 1:
		_grant_dragon_shield()

func _grant_dragon_shield() -> void:
	if health_component.shield_charges > 0:
		return
	health_component.grant_shield(1 + dragon_shield_charge_bonus)
	if dragon_shield_invulnerability_enabled:
		dragon_shield_invulnerable_remaining = DRAGON_SHIELD_INVULNERABILITY_DURATION

func try_block_frontal_projectile(origin: Vector2) -> bool:
	if projectile_guard_level <= 0 or current_action != "basic" or attack_lock_remaining <= 0.0:
		return false
	if projectile_guard_blocks_remaining <= 0:
		return false
	var incoming_origin := origin - position
	if incoming_origin.length_squared() <= 0.01:
		return false
	var facing := last_attack_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = Vector2.RIGHT
	var half_angle := PROJECTILE_GUARD_LARGE_HALF_ANGLE if projectile_guard_level >= 2 else PROJECTILE_GUARD_SMALL_HALF_ANGLE
	if facing.dot(incoming_origin.normalized()) < cos(half_angle):
		return false
	projectile_guard_blocks_remaining -= 1
	return true

func add_elite_hit_dragon_progress() -> void:
	add_dragon_progress(DRAGON_PROGRESS_PER_ELITE_HIT)

func add_boss_hit_dragon_progress() -> void:
	add_dragon_progress(DRAGON_PROGRESS_PER_BOSS_HIT)

func _try_trigger_dragon_from_progress() -> void:
	if dragon_progress < dragon_progress_threshold or dragon_stacks >= DRAGON_MAX_STACKS:
		return
	dragon_progress -= dragon_progress_threshold
	trigger_dragon()

func _tick_ultimate(delta: float, move_direction: Vector2) -> void:
	if ultimate_state == UltimateState.INACTIVE:
		return
	match ultimate_state:
		UltimateState.DASH:
			if ultimate_phase_remaining <= 0.0:
				_begin_ultimate_dash(move_direction)
			var dash_delta := minf(delta, ultimate_phase_remaining)
			var travel_distance := minf(ultimate_dash_speed * dash_delta, ultimate_dash_remaining_distance)
			_move(ultimate_dash_direction, travel_distance)
			ultimate_dash_remaining_distance = maxf(0.0, ultimate_dash_remaining_distance - travel_distance)
			ultimate_phase_remaining = ultimate_dash_remaining_distance / maxf(0.01, ultimate_dash_speed)
			if ultimate_dash_remaining_distance <= 0.01:
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
				combat_action_finished.emit("ultimate")

func _begin_ultimate_dash(move_direction: Vector2) -> void:
	if move_direction.length() > 0.1:
		ultimate_dash_direction = move_direction.normalized()
	_update_facing_from_movement(ultimate_dash_direction)
	var dash_origin := position
	var dash_distance := _ultimate_dash_distance()
	ultimate_dash_remaining_distance = dash_distance
	ultimate_dash_speed = dash_distance / ULTIMATE_DASH_DURATION
	ultimate_phase_remaining = ULTIMATE_DASH_DURATION
	var is_final_dash := ultimate_segment_index == ULTIMATE_SEGMENTS - 1
	var dash_width := ULTIMATE_FINAL_DASH_WIDTH if is_final_dash else ULTIMATE_DASH_WIDTH
	var multiplier := 6.40 if is_final_dash else 4.20
	var request := AttackRequest.line(dash_origin, ultimate_dash_direction, dash_distance, dash_width, multiplier + ultimate_damage_bonus, 12 + basic_pierce_bonus + _dragon_pierce(), "七进七出")
	request.action_kind = AttackRequest.ActionKind.ULTIMATE
	request.dash_kind = HeroActor.DashKind.ULTIMATE
	request.stance_damage = 22.0
	request.knockback = 620.0 if is_final_dash else 380.0
	request.forced_displacement = 72.0 if is_final_dash else 56.0
	request.forced_displacement_duration = 0.10
	request.grants_boss_ultimate_energy = false
	attack_requested.emit(request)
	_queue_ultimate_firewheel_projectile_batch(dash_origin + ultimate_dash_direction * 34.0)

func _emit_ultimate_final_shockwave() -> void:
	var request := AttackRequest.circle(position, ULTIMATE_FINAL_SHOCKWAVE_RANGE, 1.15 + ultimate_damage_bonus, 18 + basic_pierce_bonus + _dragon_pierce(), "七进七出·收势")
	request.action_kind = AttackRequest.ActionKind.ULTIMATE
	request.stance_damage = 34.0
	request.knockback = ULTIMATE_FINAL_SHOCKWAVE_KNOCKBACK
	request.ignore_knockback_resistance = true
	request.grants_boss_ultimate_energy = false
	attack_requested.emit(request)

func _ultimate_dash_distance() -> float:
	var base_distance := ULTIMATE_FINAL_DASH_DISTANCE if ultimate_segment_index == ULTIMATE_SEGMENTS - 1 else ULTIMATE_DASH_DISTANCE
	return base_distance + ultimate_dash_distance_bonus

func _begin_basic(stage: int) -> void:
	if stage == 4:
		_begin_firewheel()
		return
	current_action = "basic"
	begin_basic_attack_movement()
	projectile_guard_blocks_remaining = PROJECTILE_GUARD_BLOCK_LIMIT if projectile_guard_level > 0 else 0
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	pending_first_strike_shockwave = null
	combat_action_started.emit("basic_%d" % stage)
	var request: AttackRequest
	match stage:
		1:
			attack_lock_remaining = 0.30
			hit_delay_remaining = 0.10
			request = AttackRequest.line(position, last_attack_direction, BASIC_STRIKE_RANGE + basic_range_bonus, 56.0, 1.0, 2 + basic_pierce_bonus + _dragon_pierce(), "点刺")
			request.stance_damage = 10.0
			request.knockback = 130.0
			pending_first_strike_shockwave = AttackRequest.circle(position, FIRST_STRIKE_SHOCKWAVE_RANGE, 0.28, 12, "枪势震退")
			pending_first_strike_shockwave.action_kind = AttackRequest.ActionKind.PASSIVE
			pending_first_strike_shockwave.knockback = FIRST_STRIKE_SHOCKWAVE_KNOCKBACK
			pending_first_strike_shockwave.prevent_elite_knockback = true
			pending_first_strike_shockwave.suppress_impact_feedback = true
		2:
			attack_lock_remaining = 0.40
			hit_delay_remaining = 0.16
			request = AttackRequest.fan(position, last_attack_direction, BASIC_SWEEP_RADIUS + basic_range_bonus + sweep_range_bonus, deg_to_rad(120.0 + sweep_angle_bonus), 1.1, 5 + basic_pierce_bonus + _dragon_pierce(), "横扫")
			request.stance_damage = 15.0
			request.knockback = 260.0 + sweep_knockback_bonus
			_configure_breakout_knockback(request, 3, 3.0)
		3:
			attack_lock_remaining = 0.54
			hit_delay_remaining = 0.18
			request = AttackRequest.line(position, last_attack_direction, THIRD_DASH_DISTANCE + third_lunge_bonus, THIRD_DASH_WIDTH, 1.5, 6 + basic_pierce_bonus + _dragon_pierce(), "穿阵挑刺")
			request.stance_damage = 24.0
			request.dash_kind = HeroActor.DashKind.BASIC
			request.knockback = THIRD_DASH_KNOCKBACK
			request.forced_displacement = THIRD_DASH_FORCED_DISPLACEMENT
			request.forced_displacement_duration = 0.10
			_configure_dragon_breakout_knockback(request)
	request.action_kind = AttackRequest.ActionKind.BASIC
	request.clash_kind = Telegraph.ClashKind.BASIC
	pending_attack = request

func _begin_firewheel() -> void:
	firewheel_triggered_for_current_dragon = true
	current_action = "firewheel"
	combo_stage = 4
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	combat_action_started.emit("firewheel")
	pending_attack = null
	pending_first_strike_shockwave = null
	firewheel_elapsed = 0.0
	firewheel_pulse_count = 0
	firewheel_projectile_batch_count = 0
	firewheel_pending_projectiles.clear()
	firewheel_finisher_elapsed = 0.0
	firewheel_finisher_released = false
	attack_lock_remaining = firewheel_spin_end_time() + (0.0 if firewheel_capstone_enabled else FIREWHEEL_RECOVERY_DURATION)
	hit_delay_remaining = 0.0

func _tick_firewheel(delta: float) -> void:
	firewheel_elapsed += delta
	var pulse_times: Array[float] = []
	var configured_pulse_times: Array = FIREWHEEL_CAPSTONE_PULSE_TIMES if firewheel_capstone_enabled else FIREWHEEL_PULSE_TIMES
	for pulse_time in configured_pulse_times:
		pulse_times.append(float(pulse_time))
	if not firewheel_capstone_enabled and firewheel_duration_bonus > 0.0:
		pulse_times.append(FIREWHEEL_EXTENDED_PULSE_TIME)
	while firewheel_pulse_count < pulse_times.size() and firewheel_elapsed >= pulse_times[firewheel_pulse_count]:
		_emit_firewheel_pulse(firewheel_pulse_count, firewheel_capstone_enabled)
		firewheel_pulse_count += 1
	var projectile_batch_limit := FIREWHEEL_CAPSTONE_PROJECTILE_BATCH_TIMES.size() if firewheel_capstone_enabled else FIREWHEEL_PROJECTILE_BATCH_COUNT
	while firewheel_projectiles_enabled and firewheel_projectile_batch_count < projectile_batch_limit and firewheel_elapsed >= _firewheel_projectile_batch_time(firewheel_projectile_batch_count):
		_queue_firewheel_projectile_batch()
		firewheel_projectile_batch_count += 1
	_tick_pending_firewheel_projectiles(delta)

func _emit_firewheel_pulse(pulse_index: int, capstone: bool = false) -> void:
	var multiplier := 1.20 if pulse_index == 0 else (1.45 if pulse_index == 1 else 1.60)
	var radius := FIREWHEEL_RANGE
	var label := "哪吒火轮"
	if capstone:
		multiplier = float(FIREWHEEL_CAPSTONE_PULSE_DAMAGE_MULTIPLIERS[mini(pulse_index, FIREWHEEL_CAPSTONE_PULSE_DAMAGE_MULTIPLIERS.size() - 1)])
		radius = FIREWHEEL_CAPSTONE_PULSE_RADIUS
		label = "风火贯阵·旋枪"
	var request := AttackRequest.circle(position, radius, multiplier, 18 + basic_pierce_bonus + _dragon_pierce(), label)
	request.action_kind = AttackRequest.ActionKind.PASSIVE
	request.stance_damage = 8.0 if capstone else 5.0
	request.direction = last_attack_direction
	request.knockback = 320.0 if capstone else 680.0
	request.forced_displacement = 44.0 if capstone else 84.0
	request.forced_displacement_duration = 0.12
	request.prevent_elite_knockback = true
	attack_requested.emit(request)
	if capstone and request.total_hits > 0:
		camera_shake_requested.emit(FIREWHEEL_CAPSTONE_PULSE_SHAKE_STRENGTH)

func _queue_firewheel_projectile_batch() -> void:
	var projectile_count := FIREWHEEL_CAPSTONE_PROJECTILES_PER_BATCH if firewheel_capstone_enabled else FIREWHEEL_PROJECTILES_PER_BATCH
	var size_multiplier := FIREWHEEL_CAPSTONE_PROJECTILE_SIZE_MULTIPLIER if firewheel_capstone_enabled else 1.0
	var damage_multiplier := FIREWHEEL_CAPSTONE_PROJECTILE_DAMAGE_MULTIPLIER if firewheel_capstone_enabled else FIREWHEEL_PROJECTILE_DAMAGE_MULTIPLIER
	var used_angles: Array[float] = []
	for index in range(projectile_count):
		var angle := _random_firewheel_projectile_angle(used_angles)
		used_angles.append(angle)
		firewheel_pending_projectiles.append({
			"remaining": FIREWHEEL_PROJECTILE_STAGGER_INTERVAL * float(index),
			"direction": Vector2.from_angle(angle),
			"size_multiplier": size_multiplier,
			"damage_multiplier": damage_multiplier,
		})

func _queue_ultimate_firewheel_projectile_batch(origin: Vector2) -> void:
	if not firewheel_projectiles_enabled:
		return
	var projectile_count := FIREWHEEL_CAPSTONE_PROJECTILES_PER_BATCH if firewheel_capstone_enabled else FIREWHEEL_PROJECTILES_PER_BATCH
	var size_multiplier := FIREWHEEL_CAPSTONE_PROJECTILE_SIZE_MULTIPLIER if firewheel_capstone_enabled else 1.0
	var damage_multiplier := FIREWHEEL_CAPSTONE_PROJECTILE_DAMAGE_MULTIPLIER if firewheel_capstone_enabled else FIREWHEEL_PROJECTILE_DAMAGE_MULTIPLIER
	var used_angles: Array[float] = []
	for index in range(projectile_count):
		var angle := _random_firewheel_projectile_angle(used_angles)
		used_angles.append(angle)
		ultimate_firewheel_pending_projectiles.append({
			"remaining": FIREWHEEL_PROJECTILE_STAGGER_INTERVAL * float(index),
			"direction": Vector2.from_angle(angle),
			"size_multiplier": size_multiplier,
			"damage_multiplier": damage_multiplier,
			"origin": origin,
		})

func _tick_pending_firewheel_projectiles(delta: float) -> void:
	for index in range(firewheel_pending_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = firewheel_pending_projectiles[index]
		projectile["remaining"] = float(projectile.get("remaining", 0.0)) - delta
		if float(projectile.get("remaining", 0.0)) <= 0.0:
			_emit_firewheel_projectile(projectile)
			firewheel_pending_projectiles.remove_at(index)
		else:
			firewheel_pending_projectiles[index] = projectile

func _tick_pending_ultimate_firewheel_projectiles(delta: float) -> void:
	for index in range(ultimate_firewheel_pending_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = ultimate_firewheel_pending_projectiles[index]
		projectile["remaining"] = float(projectile.get("remaining", 0.0)) - delta
		if float(projectile.get("remaining", 0.0)) <= 0.0:
			_emit_firewheel_projectile(projectile)
			ultimate_firewheel_pending_projectiles.remove_at(index)
		else:
			ultimate_firewheel_pending_projectiles[index] = projectile

func _emit_firewheel_projectile(projectile: Dictionary) -> void:
	var direction: Vector2 = projectile.get("direction", Vector2.RIGHT)
	var size_multiplier := float(projectile.get("size_multiplier", 1.0))
	var damage_multiplier := float(projectile.get("damage_multiplier", FIREWHEEL_PROJECTILE_DAMAGE_MULTIPLIER))
	var origin: Vector2 = projectile.get("origin", position)
	var request := AttackRequest.line(origin, direction, FIREWHEEL_PROJECTILE_RANGE, FIREWHEEL_PROJECTILE_WIDTH * size_multiplier, damage_multiplier, EnemySimulation.CAPACITY, "乾坤掷轮")
	request.action_kind = AttackRequest.ActionKind.PROJECTILE
	request.stance_damage = 3.0
	request.knockback = FIREWHEEL_PROJECTILE_KNOCKBACK
	request.forced_displacement = 24.0
	request.forced_displacement_duration = 0.08
	request.visual_scale = size_multiplier
	request.grants_boss_ultimate_energy = false
	request.grants_special_target_dragon_progress = false
	request.suppress_impact_feedback = true
	attack_requested.emit(request)

func _random_firewheel_projectile_angle(used_angles: Array[float]) -> float:
	var angle := randf_range(0.0, TAU)
	for _attempt in range(8):
		angle = randf_range(0.0, TAU)
		var has_clearance := true
		for existing_angle in used_angles:
			if absf(wrapf(angle - existing_angle, -PI, PI)) < deg_to_rad(18.0):
				has_clearance = false
				break
		if has_clearance:
			return angle
	return angle

func _firewheel_projectile_batch_time(batch_index: int) -> float:
	if firewheel_capstone_enabled:
		return float(FIREWHEEL_CAPSTONE_PROJECTILE_BATCH_TIMES[batch_index])
	return FIREWHEEL_PROJECTILE_START_TIME + FIREWHEEL_PROJECTILE_BATCH_INTERVAL * float(batch_index)

func _begin_firewheel_finisher() -> void:
	current_action = "firewheel_finisher"
	combo_stage = 5
	firewheel_finisher_elapsed = 0.0
	firewheel_finisher_released = false
	attack_lock_remaining = FIREWHEEL_FINISHER_DURATION
	hit_delay_remaining = 0.0

func _tick_firewheel_finisher(delta: float) -> void:
	firewheel_finisher_elapsed += delta
	if not firewheel_finisher_released and firewheel_finisher_elapsed >= FIREWHEEL_FINISHER_RELEASE_TIME:
		firewheel_finisher_released = true
		_launch_firewheel_ring()

func _launch_firewheel_ring() -> void:
	_start_firewheel_cooldown()
	trigger_dragon()
	var direction := last_attack_direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var origin := position + direction * 42.0
	var travel_distance := _distance_to_world_edge(origin, direction)
	if travel_distance <= 0.0:
		return
	firewheel_ring_position = origin
	firewheel_ring_direction = direction
	firewheel_ring_remaining = travel_distance
	firewheel_ring_attack = AttackRequest.circle(origin, FIREWHEEL_RING_HIT_RADIUS, FIREWHEEL_RING_DAMAGE_MULTIPLIER, EnemySimulation.CAPACITY, "风火贯阵")
	firewheel_ring_attack.action_kind = AttackRequest.ActionKind.PASSIVE
	firewheel_ring_attack.stance_damage = 20.0
	firewheel_ring_attack.direction = direction
	firewheel_ring_attack.one_hit_per_target = true
	firewheel_ring_attack.knockback = FIREWHEEL_RING_KNOCKBACK
	firewheel_ring_attack.forced_displacement = 48.0
	firewheel_ring_attack.forced_displacement_duration = 0.10
	firewheel_ring_attack.visual_emitted = true
	firewheel_ring_attack.suppress_impact_feedback = true
	visual_effect_started.emit("firewheel_ring", origin, direction, travel_distance, {})

func _tick_firewheel_ring(delta: float) -> void:
	var travel_distance := minf(FIREWHEEL_RING_SPEED * delta, firewheel_ring_remaining)
	firewheel_ring_position += firewheel_ring_direction * travel_distance
	firewheel_ring_remaining = maxf(0.0, firewheel_ring_remaining - travel_distance)
	firewheel_ring_attack.origin = firewheel_ring_position
	attack_requested.emit(firewheel_ring_attack)
	if firewheel_ring_remaining <= 0.0:
		firewheel_ring_attack = null

func _distance_to_world_edge(origin: Vector2, direction: Vector2) -> float:
	var distance := INF
	if direction.x > 0.001:
		distance = minf(distance, (bounds.end.x - origin.x) / direction.x)
	elif direction.x < -0.001:
		distance = minf(distance, (bounds.position.x - origin.x) / direction.x)
	if direction.y > 0.001:
		distance = minf(distance, (bounds.end.y - origin.y) / direction.y)
	elif direction.y < -0.001:
		distance = minf(distance, (bounds.position.y - origin.y) / direction.y)
	return maxf(0.0, distance)

func _start_firewheel_cooldown() -> void:
	firewheel_cooldown_remaining = FIREWHEEL_COOLDOWN_DURATION

func _release_pending_attack() -> void:
	if pending_attack == null:
		return
	if pending_attack.dash_kind == HeroActor.DashKind.BASIC:
		_begin_path_dash(pending_attack, THIRD_DASH_DISTANCE + third_lunge_bonus, THIRD_DASH_DURATION, 0.14 + third_recovery_bonus, 0.75, null, Vector2.ZERO, THIRD_DASH_FRONT_REACH)
		pending_attack = null
		return
	if pending_attack.dash_kind == HeroActor.DashKind.ACTIVE:
		var finish := AttackRequest.fan(Vector2.ZERO, pending_attack.direction, 126.0 + active_range_bonus, deg_to_rad(150.0), 1.20 + active_damage_bonus, 12 + basic_pierce_bonus + _dragon_pierce(), "破军收势")
		finish.action_kind = AttackRequest.ActionKind.ACTIVE
		finish.clash_kind = Telegraph.ClashKind.ACTIVE
		finish.stance_damage = 28.0
		finish.knockback = 520.0 + active_knockback_bonus
		_begin_path_dash(pending_attack, ACTIVE_DASH_DISTANCE + active_range_bonus, ACTIVE_DASH_DURATION, 0.28 + active_recovery_bonus, 0.70, finish, pending_attack.direction)
		pending_attack = null
		return
	pending_attack.origin = position
	attack_requested.emit(pending_attack)
	if pending_first_strike_shockwave != null:
		pending_first_strike_shockwave.origin = position
		attack_requested.emit(pending_first_strike_shockwave)
		pending_first_strike_shockwave = null
	pending_attack = null

func _begin_path_dash(request: AttackRequest, distance: float, duration: float, recovery_duration: float, recovery_multiplier: float, finish_attack: AttackRequest = null, direction: Vector2 = Vector2.ZERO, front_reach: float = 12.0) -> void:
	path_dash_remaining = duration
	path_dash_duration = duration
	path_dash_distance = distance
	path_dash_travel_remaining = distance
	path_dash_speed = distance / maxf(0.01, duration)
	path_dash_direction = direction.normalized() if direction.length_squared() > 0.01 else last_attack_direction
	path_dash_front_reach = front_reach
	path_dash_request = request
	path_dash_request.origin = position
	path_dash_request.direction = path_dash_direction
	path_dash_request.one_hit_per_target = true
	path_dash_request.is_path_attack = true
	path_dash_finish = finish_attack
	path_dash_recovery_duration = recovery_duration
	path_dash_recovery_multiplier = recovery_multiplier

func _cancel_basic_for_skill() -> void:
	var cancelled_stage := combo_stage
	pending_attack = null
	pending_first_strike_shockwave = null
	hit_delay_remaining = 0.0
	path_dash_remaining = 0.0
	path_dash_duration = 0.0
	path_dash_distance = 0.0
	path_dash_travel_remaining = 0.0
	path_dash_speed = 0.0
	path_dash_request = null
	path_dash_finish = null
	attack_lock_remaining = 0.0
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	clear_basic_attack_movement()
	current_action = ""
	combo_stage = 0
	combat_action_finished.emit("basic_%d" % cancelled_stage)

func _tick_path_dash(delta: float) -> void:
	if path_dash_request == null or path_dash_duration <= 0.0:
		path_dash_remaining = 0.0
		return
	var dash_delta := minf(delta, path_dash_remaining)
	var travel_distance := minf(path_dash_speed * dash_delta, path_dash_travel_remaining)
	var start := position
	_move(path_dash_direction, travel_distance)
	path_dash_travel_remaining = maxf(0.0, path_dash_travel_remaining - travel_distance)
	path_dash_remaining = path_dash_travel_remaining / maxf(0.01, path_dash_speed)
	path_dash_request.origin = start
	path_dash_request.direction = path_dash_direction
	path_dash_request.range = travel_distance + path_dash_front_reach
	attack_requested.emit(path_dash_request)
	if path_dash_travel_remaining > 0.01:
		return
	if path_dash_finish != null:
		path_dash_finish.origin = position
		path_dash_finish.direction = path_dash_direction
		attack_requested.emit(path_dash_finish)
		if path_dash_request.dash_kind == HeroActor.DashKind.ACTIVE:
			_schedule_spear_shadow()
	_open_movement_recovery(path_dash_recovery_duration, path_dash_recovery_multiplier)
	path_dash_request = null
	path_dash_finish = null
func _finish_action() -> void:
	if current_action == "firewheel":
		if firewheel_capstone_enabled:
			_begin_firewheel_finisher()
			return
		_start_firewheel_cooldown()
		combat_action_finished.emit("firewheel")
		current_action = ""
		return
	if current_action == "firewheel_finisher":
		combat_action_finished.emit("firewheel")
		current_action = ""
		return
	if current_action == "basic":
		combat_action_finished.emit("basic_%d" % combo_stage)
	if current_action == "basic" and combo_stage == BASIC_COMBO_STAGES and firewheel_enabled and not firewheel_triggered_for_current_dragon and firewheel_cooldown_remaining <= 0.0 and has_dragon():
		has_buffered_basic = false
		clear_basic_attack_movement()
		_begin_firewheel()
		return
	if current_action == "basic" and has_buffered_basic:
		var next_direction := buffered_basic_direction
		has_buffered_basic = false
		buffered_basic_direction = Vector2.ZERO
		_update_facing_from_movement(next_direction)
		combo_stage = (combo_stage % BASIC_COMBO_STAGES) + 1
		_begin_basic(combo_stage)
		return
	if current_action == "basic":
		# Only input buffered during the preceding animation may continue a
		# physical attack chain. The HUD hit-combo counter is independent.
		combo_stage = 0
		combo_window = 0.0
	clear_basic_attack_movement()
	if current_action == "active":
		combat_action_finished.emit("active")
	current_action = ""

func _move(direction: Vector2, distance: float) -> void:
	if is_defeated() or is_guard_active():
		return
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
	echo_attack.action_kind = AttackRequest.ActionKind.PROJECTILE
	echo_attack.stance_damage = 8.0
	echo_attack.knockback = 180.0

func _configure_breakout_knockback(request: AttackRequest, target_limit: int, distance_multiplier: float) -> void:
	request.fan_knockback = true
	if randf() > 0.5:
		return
	request.empowered_knockback_active = true
	request.empowered_knockback_target_limit = target_limit
	request.empowered_knockback_multiplier = distance_multiplier

func _configure_dragon_breakout_knockback(request: AttackRequest) -> void:
	if not has_dragon():
		return
	request.fan_knockback = true
	request.empowered_knockback_active = true
	request.empowered_knockback_target_limit = 3
	request.empowered_knockback_multiplier = 2.5

func _update_facing_from_movement(move_direction: Vector2) -> void:
	if is_guard_active():
		return
	if absf(move_direction.x) > 0.1:
		last_attack_direction = Vector2.LEFT if move_direction.x < 0.0 else Vector2.RIGHT

func _update_buffered_basic_direction() -> void:
	if current_action != "basic" or not has_buffered_basic:
		return
	var live_input := _current_basic_input()
	if live_input.length_squared() <= 0.01:
		return
	buffered_basic_direction = _eight_way_direction(live_input, buffered_basic_direction if buffered_basic_direction.length_squared() > 0.01 else last_attack_direction)

func _current_basic_input(explicit_direction: Vector2 = Vector2.ZERO) -> Vector2:
	return explicit_direction if explicit_direction.length_squared() > 0.01 else current_move_direction

func _eight_way_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	if direction.length_squared() <= 0.01:
		return fallback.normalized() if fallback.length_squared() > 0.01 else Vector2.RIGHT
	var snapped_angle := snappedf(direction.angle(), PI * 0.25)
	return Vector2.from_angle(snapped_angle)

func _dragon_pierce() -> int:
	return 0

func _dragon_move_multiplier() -> float:
	if not has_dragon():
		return 1.0
	var speed_bonus := DRAGON_BASE_SPEED_BONUS + dragon_speed_bonus + float(maxi(0, dragon_stacks - 1)) * DRAGON_EXTRA_STACK_SPEED
	if dragon_stride_double_enabled:
		speed_bonus *= 2.0
	return 1.0 + minf(DRAGON_SPEED_BONUS_CAP, speed_bonus)

func _dragon_duration() -> float:
	var duration := DRAGON_BASE_DURATION + dragon_duration_bonus
	if dragon_stride_double_enabled:
		duration *= 2.0
	if dragon_stride_three_stack_duration_enabled and dragon_stacks >= DRAGON_MAX_STACKS:
		duration *= 2.0
	return duration

func _on_died() -> void:
	died.emit()

func _on_protection_broken() -> void:
	protection_broken.emit()
