class_name PrototypeHeroActor
extends HeroActor

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

const ULTIMATE_COST := 60.0
const ZHANG_FEI_ULTIMATE_DURATION := 10.0
const WEAPON_CLASH_DURATION := 0.22
const WEAPON_CLASH_REACH := 220.0
const ZHANG_FEI_BASIC_JUMP_DISTANCE := 156.0
const ZHANG_FEI_BASIC_SHORT_JUMP_DISTANCE := 76.0
const ZHANG_FEI_BASIC_JUMP_DURATION := 0.29
const ZHANG_FEI_BASIC_JUMP_HEIGHT := 58.0
const ZHANG_FEI_ACTIVE_JUMP_DISTANCE := 238.0
const ZHANG_FEI_ACTIVE_SHORT_JUMP_DISTANCE := 80.0
const ZHANG_FEI_ACTIVE_HOLD_MAX_DURATION := 0.75
const ZHANG_FEI_ACTIVE_HOLD_UPGRADED_DURATION := 0.56
const ZHANG_FEI_ACTIVE_UPGRADED_JUMP_DISTANCE := 272.0
const ZHANG_FEI_ACTIVE_JUMP_DURATION := 0.46
const ZHANG_FEI_ACTIVE_JUMP_HEIGHT := 82.0
const ZHANG_FEI_ULTIMATE_MOVE_SPEED_RATIO := 1.25
const ZHANG_RAGE_MAX_STACKS := 4
const ZHANG_RAGE_BASE_KILL_REQUIREMENT := 15
const ZHANG_RAGE_BASE_DURATION := 8.0
const ZHANG_RAGE_ATTACK_SPEED_PER_STACK := 0.04
const ZHANG_RAGE_REAR_DAMAGE_REDUCTION := 0.18
const ZHANG_RAGE_FRONT_HALF_ANGLE := deg_to_rad(60.0)

@export var prototype_hero_id := "zhang_fei"

enum UltimateState { INACTIVE, WINDUP, EXECUTING, RECOVERY }

var combo_window := 0.0
var attack_lock_remaining := 0.0
var hit_delay_remaining := 0.0
var action_elapsed := 0.0
var action_duration := 0.0
var pending_attack: AttackRequest
var has_buffered_basic := false
var buffered_basic_direction := Vector2.ZERO
var buffered_basic_has_direction := false
var active_direction := Vector2.RIGHT
var zhang_active_hold_pending := false
var zhang_active_hold_elapsed := 0.0
var zhang_active_jump_distance := ZHANG_FEI_ACTIVE_SHORT_JUMP_DISTANCE
var zhang_active_charge_level := 0
var active_cooldown_duration := 7.0
var weapon_clash_remaining := 0.0
var weapon_clash_direction := Vector2.RIGHT
var weapon_clash_type := Telegraph.ClashKind.NONE
var ultimate_state := UltimateState.INACTIVE
var ultimate_phase_remaining := 0.0
var ultimate_phase := 0
var ultimate_dash_remaining := 0.0
var ultimate_dash_speed := 0.0
var ultimate_path_attack: AttackRequest
var path_dash_remaining := 0.0
var path_dash_speed := 0.0
var path_dash_distance_remaining := 0.0
var path_dash_direction := Vector2.RIGHT
var path_dash_request: AttackRequest
var zhang_jump_remaining := 0.0
var zhang_jump_duration := 0.0
var zhang_jump_speed := 0.0
var zhang_jump_distance_remaining := 0.0
var zhang_jump_total_distance := 0.0
var zhang_jump_peak_height := 0.0
var zhang_jump_direction := Vector2.RIGHT
var zhang_jump_request: AttackRequest
var zhang_basic_jump_has_direction := false
var rage_hits := 0
var rage_stacks := 0
var rage_remaining := 0.0
var zhang_rage_kill_requirement := ZHANG_RAGE_BASE_KILL_REQUIREMENT
var zhang_rage_duration := ZHANG_RAGE_BASE_DURATION
var zhang_rage_move_speed_ratio := 0.0
var zhang_rage_collision_damage_bonus := 0.0
var zhang_rage_launch_speed_bonus := 0.0
var zhang_rage_collision_target_bonus := 0
var zhang_active_damage_bonus := 0.0
var zhang_active_knockback_bonus := 0.0
var zhang_active_displacement_bonus := 0.0
var zhang_active_displacement_duration_bonus := 0.0
var zhang_active_center_damage_bonus := 0.0
var zhang_ultimate_duration_bonus := 0.0
var zhang_ultimate_heal_level := 0
var zhang_ultimate_damage_reduction := 0.0
var zhang_ultimate_move_speed_bonus := 0.0
var zhang_ultimate_shockwave_range_bonus := 0.0
var zhang_ultimate_shockwave_knockback_bonus := 0.0
var zhang_ultimate_slam_range_bonus := 0.0
var momentum := 0.0
var previous_move_direction := Vector2.ZERO
var current_move_direction := Vector2.ZERO
var bow_stance := true
var basic_range_bonus := 0.0
var damage_bonus := 0.0
var knockback_bonus := 0.0
var stance_bonus := 0.0
var active_range_bonus := 0.0
var ultimate_bonus := 0.0
var zhang_leaping_slam_level := 0
var projectile_pierce_bonus := 0
var return_to_bow_on_release := false

func _ready() -> void:
	health_component = %HealthComponent
	health_component.died.connect(_on_died)
	health_component.shield_broken.connect(_on_protection_broken)

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id if selected_hero_id == prototype_hero_id else prototype_hero_id

func reset_for_run(world_bounds: Rect2) -> void:
	bounds = world_bounds
	var base_stats: Dictionary = HERO_CATALOG.definition_for(hero_id).get("stats", {})
	position = Vector2(bounds.get_center().x, bounds.end.y - 70.0)
	base_attack = float(base_stats.get("attack", 18.0))
	base_defense = float(base_stats.get("defense", 14.0))
	speed = float(base_stats.get("move_speed", 100.0))
	active_cooldown_duration = float(base_stats.get("active_cooldown", 7.0))
	attack_bonus = 0.0
	defense_bonus = 0.0
	defense_ratio_bonus = 0.0
	combo_stage = 0
	combo_window = 0.0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	action_elapsed = 0.0
	action_duration = 0.0
	pending_attack = null
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	buffered_basic_has_direction = false
	active_cooldown = 0.0
	active_charge_count = 1
	active_charge_capacity = 1
	active_direction = Vector2.RIGHT
	zhang_active_hold_pending = false
	zhang_active_hold_elapsed = 0.0
	zhang_active_jump_distance = ZHANG_FEI_ACTIVE_SHORT_JUMP_DISTANCE
	zhang_active_charge_level = 0
	ultimate_energy = 0.0
	ultimate_time = 0.0
	ultimate_segment_index = 0
	ultimate_dash_direction = Vector2.RIGHT
	reset_guard_state()
	last_attack_direction = Vector2.RIGHT
	current_action = ""
	clear_basic_attack_movement()
	weapon_clash_remaining = 0.0
	weapon_clash_direction = Vector2.RIGHT
	weapon_clash_type = Telegraph.ClashKind.NONE
	ultimate_state = UltimateState.INACTIVE
	ultimate_phase_remaining = 0.0
	ultimate_phase = 0
	ultimate_dash_remaining = 0.0
	ultimate_dash_speed = 0.0
	ultimate_path_attack = null
	path_dash_remaining = 0.0
	path_dash_speed = 0.0
	path_dash_distance_remaining = 0.0
	path_dash_direction = Vector2.RIGHT
	path_dash_request = null
	zhang_jump_remaining = 0.0
	zhang_jump_duration = 0.0
	zhang_jump_speed = 0.0
	zhang_jump_distance_remaining = 0.0
	zhang_jump_total_distance = 0.0
	zhang_jump_peak_height = 0.0
	zhang_jump_direction = Vector2.RIGHT
	zhang_jump_request = null
	zhang_basic_jump_has_direction = false
	rage_hits = 0
	rage_stacks = 0
	rage_remaining = 0.0
	zhang_rage_kill_requirement = ZHANG_RAGE_BASE_KILL_REQUIREMENT
	zhang_rage_duration = ZHANG_RAGE_BASE_DURATION
	zhang_rage_move_speed_ratio = 0.0
	zhang_rage_collision_damage_bonus = 0.0
	zhang_rage_launch_speed_bonus = 0.0
	zhang_rage_collision_target_bonus = 0
	zhang_active_damage_bonus = 0.0
	zhang_active_knockback_bonus = 0.0
	zhang_active_displacement_bonus = 0.0
	zhang_active_displacement_duration_bonus = 0.0
	zhang_active_center_damage_bonus = 0.0
	zhang_ultimate_duration_bonus = 0.0
	zhang_ultimate_heal_level = 0
	zhang_ultimate_damage_reduction = 0.0
	zhang_ultimate_move_speed_bonus = 0.0
	zhang_ultimate_shockwave_range_bonus = 0.0
	zhang_ultimate_shockwave_knockback_bonus = 0.0
	zhang_ultimate_slam_range_bonus = 0.0
	momentum = 0.0
	previous_move_direction = Vector2.ZERO
	current_move_direction = Vector2.ZERO
	bow_stance = true
	basic_range_bonus = 0.0
	damage_bonus = 0.0
	knockback_bonus = 0.0
	stance_bonus = 0.0
	active_range_bonus = 0.0
	ultimate_bonus = 0.0
	zhang_leaping_slam_level = 0
	projectile_pierce_bonus = 0
	return_to_bow_on_release = false
	health_component.reset(float(base_stats.get("health", 140.0)))

func tick(delta: float, move_direction: Vector2) -> void:
	if is_defeated():
		return
	tick_movement_slow(delta)
	current_move_direction = move_direction
	if zhang_active_hold_pending:
		zhang_active_hold_elapsed = minf(_zhang_active_hold_max_duration(), zhang_active_hold_elapsed + delta)
		if zhang_active_hold_elapsed >= _zhang_active_hold_max_duration():
			release_active_hold(current_move_direction)
	_update_buffered_basic_direction()
	tick_active_charge_recovery(delta, active_cooldown_duration)
	combo_window = maxf(0.0, combo_window - delta)
	weapon_clash_remaining = maxf(0.0, weapon_clash_remaining - delta)
	var rage_was_active := rage_remaining > 0.0
	rage_remaining = maxf(0.0, rage_remaining - delta)
	if rage_was_active and rage_remaining <= 0.0:
		_decay_zhang_rage()
	if weapon_clash_remaining <= 0.0:
		weapon_clash_type = Telegraph.ClashKind.NONE
	if combo_window <= 0.0 and not (current_action == "basic" and attack_lock_remaining > 0.0):
		combo_stage = 0
	if hero_id == "ma_chao":
		_tick_momentum(delta, move_direction)
	var was_path_dashing := is_path_dashing()
	var was_zhang_fei_jumping := is_zhang_fei_jumping()
	if was_path_dashing:
		_tick_path_dash(delta)
	if was_zhang_fei_jumping:
		_tick_zhang_fei_jump(delta)
	if hero_id == "zhang_fei" and is_zhang_fei_ultimate_active():
		_tick_zhang_fei_ultimate(delta)
	elif ultimate_state != UltimateState.INACTIVE:
		_tick_ultimate(delta, move_direction)
		return
	if not current_action.is_empty():
		action_elapsed += delta
		var was_waiting_for_hit := hit_delay_remaining > 0.0
		hit_delay_remaining = maxf(0.0, hit_delay_remaining - delta)
		if was_waiting_for_hit and hit_delay_remaining <= 0.0:
			_release_pending_attack()
		var was_locked := attack_lock_remaining > 0.0
		attack_lock_remaining = maxf(0.0, attack_lock_remaining - delta)
		if was_locked and attack_lock_remaining <= 0.0 and not is_path_dashing() and not is_zhang_fei_jumping():
			_finish_action()
	if current_action == "basic" and hit_delay_remaining <= 0.0 and not is_path_dashing() and not is_zhang_fei_jumping() and not _is_zhang_fei_slam_action() and is_action_locked():
		tick_basic_attack_movement(delta, move_direction)
	elif not is_guard_active() and not is_action_locked():
		_update_facing(move_direction)
		_move(move_direction, effective_move_speed() * delta)

func request_basic(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or zhang_active_hold_pending or is_guard_active():
		return false
	if ultimate_state != UltimateState.INACTIVE and not is_zhang_fei_ultimate_active():
		return false
	if is_action_locked():
		if current_action == "basic" and combo_stage < _basic_stage_count() and not has_buffered_basic:
			has_buffered_basic = true
			var next_stage := (combo_stage % _basic_stage_count()) + 1
			var basic_input := _current_basic_input(direction)
			buffered_basic_direction = _direction_for_basic_stage(next_stage, basic_input, last_attack_direction)
			buffered_basic_has_direction = _is_zhang_directional_jump_input(next_stage, basic_input)
			return true
		return false
	if combo_window <= 0.0:
		combo_stage = 0
	combo_stage = (combo_stage % _basic_stage_count()) + 1
	var basic_input := _current_basic_input(direction)
	zhang_basic_jump_has_direction = _is_zhang_directional_jump_input(combo_stage, basic_input)
	_update_facing(_direction_for_basic_stage(combo_stage, basic_input, last_attack_direction))
	_begin_basic(combo_stage)
	return true

func request_active(direction: Vector2 = Vector2.ZERO) -> bool:
	return _request_active(direction, 0.0 if hero_id == "zhang_fei" else 1.0)

func supports_active_hold() -> bool:
	return hero_id == "zhang_fei"

func begin_active_hold(_direction: Vector2 = Vector2.ZERO) -> bool:
	if not supports_active_hold() or not can_use_active():
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	zhang_active_hold_pending = true
	zhang_active_hold_elapsed = 0.0
	return true

func release_active_hold(direction: Vector2 = Vector2.ZERO) -> bool:
	if not zhang_active_hold_pending:
		return false
	var charge_ratio := clampf(zhang_active_hold_elapsed / _zhang_active_hold_max_duration(), 0.0, 1.0)
	zhang_active_hold_pending = false
	zhang_active_hold_elapsed = 0.0
	return _request_active(direction, charge_ratio)

func cancel_active_hold() -> void:
	zhang_active_hold_pending = false
	zhang_active_hold_elapsed = 0.0

func is_active_hold_charging() -> bool:
	return zhang_active_hold_pending

func active_hold_ratio() -> float:
	return clampf(zhang_active_hold_elapsed / _zhang_active_hold_max_duration(), 0.0, 1.0) if zhang_active_hold_pending else 0.0

func _request_active(direction: Vector2, charge_ratio: float) -> bool:
	if is_defeated() or active_charge_count <= 0 or is_guard_active() or (ultimate_state != UltimateState.INACTIVE and not is_zhang_fei_ultimate_active()):
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	active_direction = _eight_way_direction(direction, last_attack_direction)
	_update_facing(active_direction)
	if hero_id == "zhang_fei":
		zhang_active_jump_distance = _zhang_active_jump_distance_for_charge(charge_ratio)
	consume_active_charge(active_cooldown_duration)
	match hero_id:
		"zhang_fei":
			_start_action("active", 1.02)
			hit_delay_remaining = 0.20
			pending_attack = AttackRequest.circle(position, 126.0 + active_range_bonus, 3.55 + damage_bonus + zhang_active_damage_bonus, 24, "据水断桥·跃砸")
			pending_attack.dash_kind = HeroActor.DashKind.ACTIVE
			pending_attack.knockback = 920.0 + knockback_bonus + zhang_active_knockback_bonus
			pending_attack.forced_displacement = 128.0 + zhang_active_displacement_bonus
			pending_attack.forced_displacement_duration = 0.22 + zhang_active_displacement_duration_bonus
			pending_attack.stance_damage = 68.0 + stance_bonus
			if zhang_active_center_damage_bonus > 0.0:
				pending_attack.center_damage_radius = pending_attack.range * 0.46
				pending_attack.center_damage_multiplier = 1.0 + zhang_active_center_damage_bonus
			_configure_zhang_launch(pending_attack, 1120.0, 0.74, 1.66, 980.0, 5, 4, 1)
		"ma_chao":
			_start_action("active", 0.92)
			hit_delay_remaining = 0.14
			pending_attack = AttackRequest.line(position, active_direction, 82.0, 76.0, 2.95 + damage_bonus + momentum * 0.42, 28, "西凉破阵")
			pending_attack.dash_kind = HeroActor.DashKind.ACTIVE
			pending_attack.knockback = 620.0 + knockback_bonus + momentum * 160.0
			pending_attack.forced_displacement = 86.0 + momentum * 30.0
			pending_attack.forced_displacement_duration = 0.16
			pending_attack.stance_damage = 46.0 + stance_bonus + momentum * 16.0
		"huang_zhong":
			_start_action("active", 0.76)
			hit_delay_remaining = 0.24
			if bow_stance:
				pending_attack = AttackRequest.line(position, active_direction, 500.0 + active_range_bonus, 40.0, 3.35 + damage_bonus, 99, "贯星矢")
				pending_attack.knockback = 450.0 + knockback_bonus
				pending_attack.forced_displacement = 62.0
				pending_attack.forced_displacement_duration = 0.12
				pending_attack.stance_damage = 40.0 + stance_bonus
			else:
				pending_attack = AttackRequest.fan(position, active_direction, 176.0 + active_range_bonus, deg_to_rad(176.0), 2.45 + damage_bonus, 22, "返弦斩")
				pending_attack.knockback = 680.0 + knockback_bonus
				pending_attack.forced_displacement = 90.0
				pending_attack.forced_displacement_duration = 0.16
				pending_attack.fan_knockback = true
				pending_attack.stance_damage = 34.0 + stance_bonus
				return_to_bow_on_release = true
	pending_attack.direction = active_direction
	pending_attack.action_kind = AttackRequest.ActionKind.ACTIVE
	pending_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	active_used.emit()
	combat_action_started.emit("active")
	return true

func can_use_active() -> bool:
	return active_charge_count > 0 and (ultimate_state == UltimateState.INACTIVE or is_zhang_fei_ultimate_active()) and (not is_action_locked() or current_action == "basic")

func request_ultimate(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or ultimate_energy < ULTIMATE_COST or ultimate_state != UltimateState.INACTIVE or is_guard_active():
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	var ultimate_input := direction
	if hero_id == "zhang_fei" and ultimate_input.length_squared() <= 0.01:
		ultimate_input = current_move_direction
	_update_facing(ultimate_input)
	ultimate_energy -= ULTIMATE_COST
	if hero_id == "zhang_fei":
		ultimate_time = _zhang_ultimate_duration()
		ultimate_state = UltimateState.EXECUTING
		ultimate_phase_remaining = 0.0
		ultimate_phase = 1
		ultimate_segment_index = 1
		combat_action_started.emit("ultimate")
		ultimate_started.emit()
		_emit_zhang_fei_ultimate_shockwave()
		return true
	ultimate_time = 1.0
	ultimate_state = UltimateState.WINDUP
	ultimate_phase_remaining = 0.22
	ultimate_phase = 0
	ultimate_segment_index = 0
	ultimate_dash_direction = last_attack_direction
	_start_action("ultimate", 9.0)
	combat_action_started.emit("ultimate")
	ultimate_started.emit()
	return true

func add_ultimate_energy(value: float) -> void:
	var was_ready := is_ultimate_ready()
	ultimate_energy = clampf(ultimate_energy + value * military_energy_gain_multiplier, 0.0, 100.0)
	if not was_ready and is_ultimate_ready():
		ultimate_ready.emit()

func apply_level_up_benefits() -> void:
	attack_bonus += 0.045
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * 0.065)
	apply_military_level_up_benefits()
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_account_progress(profile: Dictionary) -> void:
	_apply_military_strategy(profile)
	active_cooldown_duration = maxf(4.2, active_cooldown_duration - military_active_cooldown_reduction)
	reset_active_charges()
	projectile_pierce_bonus += military_pierce_bonus

func apply_upgrade(upgrade_id: String) -> void:
	if apply_common_upgrade(upgrade_id):
		return
	match upgrade_id:
		"zhang_heavy_roar":
			basic_range_bonus += 18.0
			knockback_bonus += 82.0
		"zhang_slam_range":
			zhang_leaping_slam_level = maxi(zhang_leaping_slam_level, 1)
		"zhang_slam_leap":
			zhang_leaping_slam_level = maxi(zhang_leaping_slam_level, 2)
			projectile_pierce_bonus += 2  # 丈八跃砸·跃步：穿透+2
		"zhang_slam_mastery":
			zhang_leaping_slam_level = maxi(zhang_leaping_slam_level, 3)
		"zhang_leaping_slam":
			# Legacy run upgrade id kept for old replay data.
			zhang_leaping_slam_level = mini(3, zhang_leaping_slam_level + 1)
		"zhang_iron_hide":
			defense_bonus += 4.0
			active_range_bonus += 12.0
			stance_bonus += 10.0
		"zhang_rage":
			_grant_zhang_rage_stack()
			damage_bonus += 0.13
		"zhang_rage_hunt":
			zhang_rage_kill_requirement = maxi(9, zhang_rage_kill_requirement - 3)
		"zhang_rage_fervor":
			zhang_rage_duration += 2.0
			zhang_rage_move_speed_ratio += 0.07
		"zhang_rage_overwhelm":
			zhang_rage_collision_damage_bonus += 0.28
			zhang_rage_launch_speed_bonus += 110.0
			zhang_rage_collision_target_bonus += 1
		"zhang_bridge_breaker":
			active_range_bonus += 18.0
			zhang_active_damage_bonus += 0.22
		"zhang_active_charge":
			zhang_active_charge_level = 1
		"zhang_bridge_repel":
			zhang_active_knockback_bonus += 120.0
			zhang_active_displacement_bonus += 22.0
			zhang_active_displacement_duration_bonus += 0.05
		"zhang_bridge_shockwave":
			zhang_active_center_damage_bonus += 0.30
		"zhang_earthshaker":
			ultimate_bonus += 0.46
			stance_bonus += 16.0
		"zhang_immovable":
			zhang_ultimate_damage_reduction = minf(0.18, zhang_ultimate_damage_reduction + 0.07)
		"zhang_battle_cry":
			zhang_ultimate_duration_bonus += 5.0
		"zhang_ultimate_bloodlust":
			zhang_ultimate_heal_level = mini(3, zhang_ultimate_heal_level + 1)
		"zhang_war_stomp":
			zhang_ultimate_shockwave_range_bonus += 34.0
			zhang_ultimate_shockwave_knockback_bonus += 160.0
			zhang_ultimate_slam_range_bonus += 16.0
			ultimate_bonus += 0.28
		"ma_long_stride":
			basic_range_bonus += 22.0
			momentum = minf(1.0, momentum + 0.22)
		"ma_iron_hoof":
			damage_bonus += 0.14
			knockback_bonus += 72.0
		"ma_storm_charge":
			active_cooldown_duration = maxf(4.6, active_cooldown_duration - 0.72)
			active_range_bonus += 42.0
		"ma_silver_afterimage":
			ultimate_bonus += 0.44
			stance_bonus += 14.0
		"huang_draw_strength":
			damage_bonus += 0.15
			projectile_pierce_bonus += 2
		"huang_hawk_eye":
			basic_range_bonus += 38.0
			active_range_bonus += 52.0
		"huang_blade_return":
			knockback_bonus += 110.0
			defense_bonus += 3.0
		"huang_dingjun_volley":
			ultimate_bonus += 0.42
			stance_bonus += 15.0
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func current_stats() -> Dictionary:
	return {
		"attack": total_attack(),
		"defense": total_defense(),
		"health": health_component.current,
		"max_health": health_component.maximum,
		"move_speed": effective_move_speed(),
		"basic_pierce": _basic_pierce(),
		"active_cooldown": active_cooldown_duration,
		"ultimate_cost": ULTIMATE_COST,
	}

func _basic_pierce() -> int:
	var pierce := 3 + projectile_pierce_bonus if hero_id == "zhang_fei" else 12 + projectile_pierce_bonus
	# 张飞无双期间穿透+7
	if hero_id == "zhang_fei" and is_zhang_fei_ultimate_active():
		pierce += 7
	return pierce

func revive_from_rewarded_ad(health_ratio: float = 0.35) -> void:
	super.revive_from_rewarded_ad(health_ratio)
	# Clear all subclass-owned action state so the revive cannot resume a stale
	# combo, jump, dash, or weapon-clash window.
	combo_window = 0.0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	action_elapsed = 0.0
	action_duration = 0.0
	pending_attack = null
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	buffered_basic_has_direction = false
	zhang_basic_jump_has_direction = false
	current_action = ""
	clear_basic_attack_movement()
	weapon_clash_remaining = 0.0
	weapon_clash_direction = Vector2.RIGHT
	weapon_clash_type = Telegraph.ClashKind.NONE
	zhang_active_hold_pending = false
	zhang_active_hold_elapsed = 0.0
	path_dash_remaining = 0.0
	path_dash_speed = 0.0
	path_dash_distance_remaining = 0.0
	path_dash_request = null
	zhang_jump_remaining = 0.0
	zhang_jump_duration = 0.0
	zhang_jump_speed = 0.0
	zhang_jump_distance_remaining = 0.0
	zhang_jump_request = null
	ultimate_state = UltimateState.INACTIVE
	ultimate_time = 0.0
	ultimate_phase_remaining = 0.0
	ultimate_phase = 0
	ultimate_dash_remaining = 0.0
	ultimate_dash_speed = 0.0
	ultimate_path_attack = null

func ultimate_cost() -> float:
	return ULTIMATE_COST

func allows_guard_during_ultimate() -> bool:
	return hero_id == "zhang_fei" and is_zhang_fei_ultimate_active()

func is_ultimate_ready() -> bool:
	return ultimate_energy >= ULTIMATE_COST

func is_action_locked() -> bool:
	return attack_lock_remaining > 0.0 or (ultimate_state != UltimateState.INACTIVE and not is_zhang_fei_ultimate_active()) or is_path_dashing() or is_zhang_fei_jumping()

func is_attacking() -> bool:
	return current_action in ["basic", "active", "ultimate"] or is_path_dashing() or is_zhang_fei_jumping()

func open_weapon_clash_window(request: AttackRequest, clash_type: int) -> void:
	if clash_type == Telegraph.ClashKind.NONE:
		return
	weapon_clash_remaining = WEAPON_CLASH_DURATION
	weapon_clash_type = clash_type
	weapon_clash_direction = request.direction.normalized()
	if weapon_clash_direction.length_squared() <= 0.01:
		weapon_clash_direction = last_attack_direction

func current_weapon_clash_type() -> int:
	return weapon_clash_type if weapon_clash_remaining > 0.0 else Telegraph.ClashKind.NONE

func can_weapon_clash_target(target_position: Vector2) -> bool:
	if weapon_clash_remaining <= 0.0:
		return false
	var toward_target := target_position - position
	if toward_target.length_squared() <= 0.01:
		return true
	return toward_target.length() <= WEAPON_CLASH_REACH and weapon_clash_direction.dot(toward_target.normalized()) >= -0.16

func consume_weapon_clash_window() -> void:
	weapon_clash_remaining = 0.0
	weapon_clash_type = Telegraph.ClashKind.NONE

func receive_damage(amount: float, _source: String, attack_origin: Vector2 = Vector2.ZERO) -> float:
	if is_defeated() or is_zhang_fei_jumping():
		return 0.0
	var reduced_amount := CombatMath.mitigate_damage(amount, total_defense()) * incoming_damage_multiplier(attack_origin)
	if hero_id == "zhang_fei" and is_zhang_fei_ultimate_active():
		reduced_amount *= maxf(0.60, 0.82 - zhang_ultimate_damage_reduction)
	if hero_id == "zhang_fei":
		reduced_amount *= _zhang_rage_side_rear_damage_multiplier(attack_origin)
	var applied_damage := health_component.take_damage(reduced_amount)
	if applied_damage > 0.0:
		damaged.emit(applied_damage)
	return applied_damage

func interrupt_basic_attack() -> void:
	if current_action == "basic" or combo_stage > 0 or combo_window > 0.0:
		_cancel_basic_for_skill()

func on_weapon_clash_success(perfect: bool, skill_clash: bool) -> void:
	super.on_weapon_clash_success(perfect, skill_clash)
	if hero_id == "zhang_fei":
		_add_zhang_rage_progress(4 if perfect else 3)

func on_light_weapon_clash_success() -> void:
	if hero_id == "zhang_fei":
		_add_zhang_rage_progress(3)

func on_enemy_defeated(_enemy_type: int, allow_recovery: bool = true, action_kind: int = AttackRequest.ActionKind.NONE) -> void:
	apply_military_enemy_defeat_reward(_enemy_type, allow_recovery)
	if hero_id != "zhang_fei":
		return
	_add_zhang_rage_progress(1)
	if allow_recovery and is_zhang_fei_ultimate_active() and action_kind == AttackRequest.ActionKind.BASIC and zhang_ultimate_heal_level > 0:
		var chance: float = float([0.0, 0.08, 0.10, 0.15][zhang_ultimate_heal_level])
		if randf() < chance:
			var recovered := minf(health_component.maximum, health_component.current + float(zhang_ultimate_heal_level))
			if recovered > health_component.current:
				health_component.current = recovered
				health_component.health_changed.emit(health_component.current, health_component.maximum)

func force_idle_state() -> void:
	super.force_idle_state()
	combo_window = 0.0
	combo_stage = 0
	pending_attack = null
	has_buffered_basic = false
	zhang_active_hold_pending = false
	path_dash_remaining = 0.0
	path_dash_request = null
	zhang_jump_remaining = 0.0
	zhang_jump_request = null
	ultimate_state = UltimateState.INACTIVE
	ultimate_phase_remaining = 0.0
	ultimate_dash_remaining = 0.0
	ultimate_path_attack = null

func on_named_target_hit(_target_kind: int, _request: AttackRequest, _damage: float) -> void:
	pass

func basic_ability_label() -> String:
	match hero_id:
		"zhang_fei": return "丈八三式"
		"ma_chao": return "西凉连骑"
		"huang_zhong": return "连珠箭" if bow_stance else "断弦刀"
	return "普攻"

func active_ability_label() -> String:
	match hero_id:
		"zhang_fei": return "据水断桥"
		"ma_chao": return "西凉破阵"
		"huang_zhong": return "贯星矢" if bow_stance else "返弦斩"
	return "主动"

func ultimate_ability_label() -> String:
	match hero_id:
		"zhang_fei": return "万夫莫开"
		"ma_chao": return "银枪奔雷"
		"huang_zhong": return "定军连珠"
	return "无双"

func presentation_id() -> String:
	return hero_id

func supports_weapon_stance() -> bool:
	return hero_id == "huang_zhong"

func weapon_stance_label() -> String:
	if hero_id != "huang_zhong":
		return ""
	return "弓" if bow_stance else "刀"

func request_weapon_stance_toggle() -> bool:
	if hero_id != "huang_zhong" or is_action_locked():
		return false
	bow_stance = not bow_stance
	combo_stage = 0
	combo_window = 0.0
	return true

func is_bow_stance() -> bool:
	return hero_id == "huang_zhong" and bow_stance

func momentum_ratio() -> float:
	return momentum if hero_id == "ma_chao" else 0.0

func is_zhang_fei_ultimate_active() -> bool:
	return hero_id == "zhang_fei" and ultimate_state == UltimateState.EXECUTING and ultimate_time > 0.0

func hud_status_effects() -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	var slow_effect := movement_slow_hud_effect()
	if not slow_effect.is_empty():
		effects.append(slow_effect)
	var shield_effect := common_shield_hud_effect()
	if not shield_effect.is_empty():
		effects.append(shield_effect)
	if hero_id == "zhang_fei":
		if is_zhang_fei_ultimate_active():
			effects.append({"label": "万夫", "icon": "震", "stacks": 1, "remaining": ultimate_time, "duration": _zhang_ultimate_duration(), "color": Color("e0673e")})
		if _has_zhang_rage():
			effects.append({"label": "怒势", "icon": "怒", "stacks": rage_stacks, "stack_text": "%d/%d" % [rage_stacks, ZHANG_RAGE_MAX_STACKS], "remaining": rage_remaining, "duration": zhang_rage_duration, "color": Color("d85a3e")})
		elif rage_hits > 0:
			effects.append({"label": "怒势", "icon": "怒", "stacks": 0, "stack_text": "%d/%d" % [rage_hits, zhang_rage_kill_requirement], "timed": false, "color": Color("d85a3e")})
	elif hero_id == "ma_chao" and momentum > 0.04:
		effects.append({"label": "奔势", "icon": "势", "stacks": maxi(1, ceili(momentum * 3.0)), "remaining": momentum, "duration": 1.0, "color": Color("7ab7e8")})
	elif hero_id == "huang_zhong":
		effects.append({"label": "弓势" if bow_stance else "刀势", "icon": "弓" if bow_stance else "刀", "stacks": 1, "remaining": 1.0, "duration": 1.0, "color": Color("e3b45c")})
	return effects

func is_ultimate_dashing() -> bool:
	return hero_id == "ma_chao" and ultimate_state == UltimateState.EXECUTING and ultimate_dash_remaining > 0.0

func visual_action_progress() -> float:
	return clampf(action_elapsed / maxf(0.01, action_duration), 0.0, 1.0)

func is_path_dashing() -> bool:
	return path_dash_distance_remaining > 0.0 and path_dash_request != null

func path_dash_visual_direction() -> Vector2:
	return zhang_jump_direction if is_zhang_fei_jumping() else path_dash_direction

func is_zhang_fei_jumping() -> bool:
	return hero_id == "zhang_fei" and zhang_jump_request != null and zhang_jump_remaining > 0.0

func zhang_fei_jump_visual_height() -> float:
	if not is_zhang_fei_jumping() or zhang_jump_duration <= 0.01:
		return 0.0
	var progress := clampf(1.0 - zhang_jump_remaining / zhang_jump_duration, 0.0, 1.0)
	return zhang_jump_peak_height * sin(progress * PI)

func _basic_stage_count() -> int:
	return 2 if hero_id == "huang_zhong" else 3

func _begin_basic(stage: int) -> void:
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	begin_basic_attack_movement()
	var lock := 0.52
	var hit_delay := 0.20
	var request: AttackRequest
	match hero_id:
		"zhang_fei":
			if stage == 1:
				lock = 0.50
				hit_delay = 0.18
				request = AttackRequest.fan(position, last_attack_direction, 142.0 + basic_range_bonus, deg_to_rad(118.0), 1.25 + damage_bonus, _basic_pierce(), "扫阵横击")
				request.knockback = 250.0 + knockback_bonus
				request.forced_displacement = 32.0
				request.stance_damage = 16.0 + stance_bonus
				_configure_zhang_launch(request, 560.0, 0.28, 0.72, 460.0, 1, 1, 0)
			elif stage == 2:
				lock = 0.58
				hit_delay = 0.22
				request = AttackRequest.fan(position, last_attack_direction, 164.0 + basic_range_bonus, deg_to_rad(138.0), 1.58 + damage_bonus, _basic_pierce(), "蛇矛挑阵")
				request.knockback = 480.0 + knockback_bonus
				request.forced_displacement = 52.0
				request.fan_knockback = true
				request.stance_damage = 27.0 + stance_bonus
				_configure_zhang_launch(request, 720.0, 0.42, 1.04, 620.0, 2, 2, 0)
			else:
				lock = 0.92
				hit_delay = 0.20
				var slam_level := _effective_zhang_leaping_slam_level()
				var slam_range := 94.0
				var slam_multiplier := 1.62
				request = AttackRequest.circle(position, slam_range + basic_range_bonus * 0.40, slam_multiplier + damage_bonus, _basic_pierce(), "丈八跃砸")
				request.dash_kind = HeroActor.DashKind.BASIC
				match slam_level:
					1:
						request.range = 108.0 + basic_range_bonus * 0.40
						request.multiplier = 2.02 + damage_bonus
						request.center_damage_radius = request.range * 0.42
						request.center_damage_multiplier = 1.25
					2:
						request.range = 120.0 + basic_range_bonus * 0.40
						request.multiplier = 2.16 + damage_bonus
						request.center_damage_radius = request.range * 0.42
						request.center_damage_multiplier = 1.25
					_:
						if slam_level >= 3:
							request.range = 132.0 + basic_range_bonus * 0.40
							request.multiplier = 2.38 + damage_bonus
							request.center_damage_radius = request.range * 0.44
							request.center_damage_multiplier = 1.30
				if is_zhang_fei_ultimate_active():
					request.range += 26.0 + zhang_ultimate_slam_range_bonus
					request.multiplier += 0.28
				match slam_level:
					0:
						request.knockback = 520.0 + knockback_bonus
						request.forced_displacement = 52.0
						request.forced_displacement_duration = 0.13
						request.stance_damage = 32.0 + stance_bonus
						_configure_zhang_launch(request, 620.0, 0.30, 0.72, 460.0, 1, 2, 0)
					1:
						request.knockback = 580.0 + knockback_bonus
						request.forced_displacement = 64.0
						request.forced_displacement_duration = 0.15
						request.stance_damage = 40.0 + stance_bonus
						_configure_zhang_launch(request, 700.0, 0.38, 0.92, 560.0, 2, 2, 0)
					2:
						request.knockback = 820.0 + knockback_bonus
						request.forced_displacement = 104.0
						request.forced_displacement_duration = 0.23
						request.stance_damage = 50.0 + stance_bonus
						_configure_zhang_launch(request, 900.0, 0.54, 1.28, 760.0, 3, 3, 1)
					_:
						request.knockback = 900.0 + knockback_bonus
						request.forced_displacement = 118.0
						request.forced_displacement_duration = 0.24
						request.stance_damage = 58.0 + stance_bonus
						_configure_zhang_launch(request, 980.0, 0.62, 1.46, 840.0, 4, 4, 1)
		"ma_chao":
			if stage == 1:
				lock = 0.42
				hit_delay = 0.15
				request = AttackRequest.line(position, last_attack_direction, 154.0 + basic_range_bonus, 42.0, 1.32 + damage_bonus + momentum * 0.18, 12 + projectile_pierce_bonus, "银枪点阵")
				request.knockback = 190.0 + knockback_bonus
				request.stance_damage = 14.0 + stance_bonus
			elif stage == 2:
				lock = 0.50
				hit_delay = 0.20
				request = AttackRequest.fan(position, last_attack_direction, 162.0 + basic_range_bonus, deg_to_rad(126.0), 1.70 + damage_bonus + momentum * 0.22, 18 + projectile_pierce_bonus, "流星横挑")
				request.knockback = 360.0 + knockback_bonus
				request.forced_displacement = 44.0
				request.fan_knockback = true
				request.stance_damage = 24.0 + stance_bonus
			else:
				lock = 0.82
				hit_delay = 0.20
				request = AttackRequest.line(position, last_attack_direction, 88.0, 68.0, 2.10 + damage_bonus + momentum * 0.32, 24 + projectile_pierce_bonus, "踏阵突刺")
				request.dash_kind = HeroActor.DashKind.BASIC
				request.knockback = 520.0 + knockback_bonus
				request.forced_displacement = 72.0
				request.forced_displacement_duration = 0.13
				request.stance_damage = 38.0 + stance_bonus
		"huang_zhong":
			if bow_stance:
				lock = 0.48 if stage == 1 else 0.68
				hit_delay = 0.18 if stage == 1 else 0.34
				var bow_range := (326.0 if stage == 1 else 438.0) + basic_range_bonus
				var bow_damage := (1.30 if stage == 1 else 2.18) + damage_bonus
				request = AttackRequest.line(position, last_attack_direction, bow_range, 34.0 if stage == 1 else 44.0, bow_damage, 8 + projectile_pierce_bonus, "连珠箭" if stage == 1 else "蓄力穿云")
				request.knockback = 150.0 + knockback_bonus if stage == 1 else 430.0 + knockback_bonus
				request.forced_displacement = 18.0 if stage == 1 else 56.0
				request.stance_damage = 12.0 + stance_bonus if stage == 1 else 32.0 + stance_bonus
			else:
				lock = 0.46 if stage == 1 else 0.62
				hit_delay = 0.17 if stage == 1 else 0.26
				request = AttackRequest.fan(position, last_attack_direction, (132.0 if stage == 1 else 174.0) + basic_range_bonus, deg_to_rad(138.0 if stage == 1 else 172.0), (1.32 if stage == 1 else 1.92) + damage_bonus, 14 + projectile_pierce_bonus, "断弦横斩" if stage == 1 else "回身断阵")
				request.knockback = (320.0 if stage == 1 else 580.0) + knockback_bonus
				request.forced_displacement = 36.0 if stage == 1 else 76.0
				request.fan_knockback = true
				request.stance_damage = 18.0 + stance_bonus if stage == 1 else 34.0 + stance_bonus
	request.action_kind = AttackRequest.ActionKind.BASIC
	request.clash_kind = Telegraph.ClashKind.BASIC
	request.direction = last_attack_direction
	pending_attack = request
	if hero_id == "zhang_fei":
		var rage_attack_speed := _zhang_rage_attack_speed_multiplier()
		lock /= rage_attack_speed
		hit_delay /= rage_attack_speed
	_start_action("basic", lock)
	hit_delay_remaining = hit_delay
	combat_action_started.emit("basic_%d" % stage)

func _release_pending_attack() -> void:
	if pending_attack == null:
		return
	if hero_id == "zhang_fei" and pending_attack.dash_kind in [HeroActor.DashKind.BASIC, HeroActor.DashKind.ACTIVE]:
		var jump_distance := _zhang_basic_jump_distance() if pending_attack.dash_kind == HeroActor.DashKind.BASIC else zhang_active_jump_distance
		var jump_duration := _zhang_basic_jump_duration() if pending_attack.dash_kind == HeroActor.DashKind.BASIC else ZHANG_FEI_ACTIVE_JUMP_DURATION
		pending_attack.direction = _eight_way_direction(pending_attack.direction, last_attack_direction)
		pending_attack.origin = position
		_begin_zhang_fei_jump(pending_attack, jump_distance, jump_duration)
		pending_attack = null
		return
	if hero_id == "ma_chao" and pending_attack.dash_kind in [HeroActor.DashKind.BASIC, HeroActor.DashKind.ACTIVE]:
		var dash_distance := 108.0 + momentum * 94.0 if pending_attack.dash_kind == HeroActor.DashKind.BASIC else 258.0 + momentum * 156.0 + active_range_bonus
		var dash_duration := 0.30 if pending_attack.dash_kind == HeroActor.DashKind.BASIC else 0.58
		_begin_path_dash(pending_attack, dash_distance, dash_duration)
		pending_attack = null
		return
	pending_attack.origin = position
	pending_attack.direction = last_attack_direction
	attack_requested.emit(pending_attack)
	pending_attack = null
	if return_to_bow_on_release:
		return_to_bow_on_release = false
		bow_stance = true

func _begin_zhang_fei_jump(request: AttackRequest, distance: float, duration: float) -> void:
	zhang_jump_direction = request.direction.normalized()
	if zhang_jump_direction.length_squared() <= 0.01:
		zhang_jump_direction = last_attack_direction
	zhang_jump_distance_remaining = distance
	zhang_jump_speed = distance / maxf(0.01, duration)
	zhang_jump_remaining = duration
	zhang_jump_duration = duration
	zhang_jump_total_distance = distance
	zhang_jump_peak_height = _zhang_basic_jump_height() if request.dash_kind == HeroActor.DashKind.BASIC else ZHANG_FEI_ACTIVE_JUMP_HEIGHT
	zhang_jump_request = request
	zhang_jump_request.one_hit_per_target = true

func _tick_zhang_fei_jump(delta: float) -> void:
	if zhang_jump_request == null:
		zhang_jump_remaining = 0.0
		zhang_jump_duration = 0.0
		zhang_jump_distance_remaining = 0.0
		return
	var jump_delta := minf(delta, zhang_jump_remaining)
	var travel := minf(zhang_jump_speed * jump_delta, zhang_jump_distance_remaining)
	if travel > 0.0:
		_move(zhang_jump_direction, travel)
		zhang_jump_distance_remaining = maxf(0.0, zhang_jump_distance_remaining - travel)
	zhang_jump_remaining = maxf(0.0, zhang_jump_remaining - jump_delta)
	if zhang_jump_remaining > 0.0:
		return
	var landing_request := zhang_jump_request
	landing_request.origin = position
	landing_request.direction = zhang_jump_direction
	attack_requested.emit(landing_request)
	if landing_request.label == "丈八跃砸":
		var forward_impact := AttackRequest.fan(landing_request.origin, landing_request.direction, landing_request.range + _zhang_slam_forward_extension(), deg_to_rad(104.0), landing_request.multiplier * 0.70, landing_request.pierce, "丈八跃砸·前震")
		forward_impact.inner_radius = landing_request.range
		forward_impact.knockback = landing_request.knockback * 0.72
		forward_impact.forced_displacement = landing_request.forced_displacement * 0.68
		forward_impact.forced_displacement_duration = landing_request.forced_displacement_duration
		forward_impact.stance_damage = landing_request.stance_damage * 0.62
		forward_impact.action_kind = AttackRequest.ActionKind.BASIC
		attack_requested.emit(forward_impact)
	zhang_jump_request = null
	zhang_jump_remaining = 0.0
	zhang_jump_duration = 0.0
	zhang_jump_speed = 0.0
	zhang_jump_distance_remaining = 0.0
	zhang_jump_total_distance = 0.0
	zhang_jump_peak_height = 0.0

func _begin_path_dash(request: AttackRequest, distance: float, duration: float) -> void:
	path_dash_direction = request.direction.normalized()
	if path_dash_direction.length_squared() <= 0.01:
		path_dash_direction = last_attack_direction
	path_dash_distance_remaining = distance
	path_dash_speed = distance / maxf(0.01, duration)
	path_dash_remaining = duration
	path_dash_request = request
	path_dash_request.one_hit_per_target = true
	path_dash_request.is_path_attack = true

func _tick_path_dash(delta: float) -> void:
	if path_dash_request == null:
		path_dash_distance_remaining = 0.0
		return
	var travel := minf(path_dash_speed * delta, path_dash_distance_remaining)
	var start := position
	_move(path_dash_direction, travel)
	path_dash_distance_remaining = maxf(0.0, path_dash_distance_remaining - travel)
	path_dash_remaining = path_dash_distance_remaining / maxf(0.01, path_dash_speed)
	path_dash_request.origin = start
	path_dash_request.direction = path_dash_direction
	path_dash_request.range = travel + 68.0
	attack_requested.emit(path_dash_request)
	if path_dash_distance_remaining <= 0.01:
		path_dash_request = null
		if attack_lock_remaining <= 0.0 and ultimate_state == UltimateState.INACTIVE:
			_finish_action()

func _configure_zhang_launch(request: AttackRequest, speed_value: float, duration: float, collision_multiplier: float, collision_knockback: float, collision_targets: int, target_limit: int, relay_count: int) -> void:
	request.launches_enemies = true
	request.launch_speed = speed_value + knockback_bonus * 0.34
	request.launch_duration = duration
	request.launch_collision_damage_multiplier = collision_multiplier
	request.launch_collision_knockback = collision_knockback + knockback_bonus
	request.launch_collision_max_targets = collision_targets
	request.launch_target_limit = target_limit
	request.launch_relay_count = relay_count
	if _has_zhang_rage() or is_zhang_fei_ultimate_active():
		request.launch_speed += 120.0
		request.launch_collision_damage_multiplier += 0.24
		request.launch_collision_max_targets += 1
	if _has_zhang_rage():
		request.launch_collision_damage_multiplier += zhang_rage_collision_damage_bonus
		request.launch_speed += zhang_rage_launch_speed_bonus
		request.launch_collision_max_targets += zhang_rage_collision_target_bonus
		request.launch_target_limit += zhang_rage_collision_target_bonus
	if is_zhang_fei_ultimate_active():
		request.launch_collision_max_targets += 1
		request.launch_relay_count += 1

func _tick_zhang_fei_ultimate(delta: float) -> void:
	ultimate_time = maxf(0.0, ultimate_time - delta)
	if ultimate_time > 0.0:
		return
	ultimate_state = UltimateState.INACTIVE
	ultimate_phase = 0
	ultimate_segment_index = 0
	combat_action_finished.emit("ultimate")

func _tick_ultimate(delta: float, move_direction: Vector2) -> void:
	ultimate_phase_remaining = maxf(0.0, ultimate_phase_remaining - delta)
	if hero_id == "ma_chao" and ultimate_state == UltimateState.EXECUTING and ultimate_dash_remaining > 0.0:
		_tick_ma_ultimate_dash(delta, move_direction)
		return
	if ultimate_phase_remaining > 0.0:
		return
	match ultimate_state:
		UltimateState.WINDUP:
			ultimate_state = UltimateState.EXECUTING
			ultimate_phase = 1
			ultimate_segment_index = 1
			if hero_id == "ma_chao":
				_begin_ma_ultimate_segment(move_direction)
			else:
				_emit_ultimate_attack(ultimate_phase)
				ultimate_phase_remaining = 0.22
		UltimateState.EXECUTING:
			ultimate_phase += 1
			ultimate_segment_index = ultimate_phase
			if ultimate_phase > _ultimate_phase_count():
				ultimate_state = UltimateState.RECOVERY
				ultimate_phase_remaining = 0.26
			else:
				_emit_ultimate_attack(ultimate_phase)
				ultimate_phase_remaining = 0.22
		UltimateState.RECOVERY:
			ultimate_state = UltimateState.INACTIVE
			ultimate_time = 0.0
			ultimate_segment_index = 0
			current_action = ""
			attack_lock_remaining = 0.0
			combat_action_finished.emit("ultimate")

func _ultimate_phase_count() -> int:
	return 5

func _emit_zhang_fei_ultimate_shockwave() -> void:
	var request := AttackRequest.fan(position, last_attack_direction, 238.0 + active_range_bonus * 0.35 + zhang_ultimate_shockwave_range_bonus, deg_to_rad(142.0), 3.30 + ultimate_bonus, 22, "万夫莫开·怒喝震阵")
	request.fan_knockback = true
	request.knockback = 920.0 + knockback_bonus + zhang_ultimate_shockwave_knockback_bonus
	request.forced_displacement = 132.0
	request.forced_displacement_duration = 0.22
	request.stance_damage = 76.0 + stance_bonus
	_configure_zhang_launch(request, 1080.0, 0.74, 1.76, 980.0, 5, 4, 1)
	request.action_kind = AttackRequest.ActionKind.ULTIMATE
	request.clash_kind = Telegraph.ClashKind.ACTIVE
	request.grants_boss_ultimate_energy = false
	attack_requested.emit(request)

func _emit_ultimate_attack(phase: int) -> void:
	var request: AttackRequest
	match hero_id:
		"huang_zhong":
			var spread := deg_to_rad((float(phase) - 3.0) * 13.0)
			var direction := last_attack_direction.rotated(spread)
			request = AttackRequest.line(position, direction, 510.0 + active_range_bonus, 44.0, 3.05 + ultimate_bonus, 99, "定军连珠")
			request.knockback = 510.0 + knockback_bonus
			request.forced_displacement = 68.0
			request.forced_displacement_duration = 0.12
			request.stance_damage = 46.0 + stance_bonus
	request.action_kind = AttackRequest.ActionKind.ULTIMATE
	request.clash_kind = Telegraph.ClashKind.ACTIVE
	request.grants_boss_ultimate_energy = false
	attack_requested.emit(request)

func _begin_ma_ultimate_segment(move_direction: Vector2) -> void:
	var desired := _eight_way_direction(move_direction, ultimate_dash_direction)
	var turn_angle := clampf(wrapf(desired.angle() - ultimate_dash_direction.angle(), -PI, PI), -PI * 0.25, PI * 0.25)
	ultimate_dash_direction = ultimate_dash_direction.rotated(turn_angle).normalized()
	var distance := 230.0 + momentum * 108.0 + active_range_bonus * 0.45
	ultimate_dash_remaining = distance
	ultimate_dash_speed = 590.0
	ultimate_phase_remaining = distance / ultimate_dash_speed
	ultimate_path_attack = AttackRequest.line(position, ultimate_dash_direction, 82.0, 82.0, 3.25 + ultimate_bonus + momentum * 0.40, 36, "银枪奔雷")
	ultimate_path_attack.action_kind = AttackRequest.ActionKind.ULTIMATE
	ultimate_path_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	ultimate_path_attack.one_hit_per_target = true
	ultimate_path_attack.is_path_attack = true
	ultimate_path_attack.knockback = 720.0 + knockback_bonus
	ultimate_path_attack.forced_displacement = 102.0
	ultimate_path_attack.forced_displacement_duration = 0.18
	ultimate_path_attack.stance_damage = 62.0 + stance_bonus

func _tick_ma_ultimate_dash(delta: float, move_direction: Vector2) -> void:
	var desired := _eight_way_direction(move_direction, ultimate_dash_direction)
	var turn_angle := clampf(wrapf(desired.angle() - ultimate_dash_direction.angle(), -PI, PI), -PI * 0.25 * delta * 3.0, PI * 0.25 * delta * 3.0)
	ultimate_dash_direction = ultimate_dash_direction.rotated(turn_angle).normalized()
	var travel := minf(ultimate_dash_speed * delta, ultimate_dash_remaining)
	var start := position
	_move(ultimate_dash_direction, travel)
	ultimate_dash_remaining = maxf(0.0, ultimate_dash_remaining - travel)
	ultimate_phase_remaining = ultimate_dash_remaining / ultimate_dash_speed
	if ultimate_path_attack != null:
		ultimate_path_attack.origin = start
		ultimate_path_attack.direction = ultimate_dash_direction
		ultimate_path_attack.range = travel + 82.0
		attack_requested.emit(ultimate_path_attack)
	if ultimate_dash_remaining > 0.01:
		return
	ultimate_path_attack = null
	ultimate_phase += 1
	ultimate_segment_index = ultimate_phase
	if ultimate_phase > _ultimate_phase_count():
		ultimate_state = UltimateState.RECOVERY
		ultimate_phase_remaining = 0.26
	else:
		_begin_ma_ultimate_segment(move_direction)

func _start_action(action_id: String, duration: float) -> void:
	current_action = action_id
	attack_lock_remaining = duration
	action_elapsed = 0.0
	action_duration = duration

func _finish_action() -> void:
	if current_action == "basic":
		combat_action_finished.emit("basic_%d" % combo_stage)
		if has_buffered_basic:
			var next_direction := buffered_basic_direction
			var next_has_direction := buffered_basic_has_direction
			has_buffered_basic = false
			combo_stage = (combo_stage % _basic_stage_count()) + 1
			zhang_basic_jump_has_direction = next_has_direction
			_update_facing(_direction_for_basic_stage(combo_stage, next_direction, last_attack_direction))
			buffered_basic_direction = Vector2.ZERO
			buffered_basic_has_direction = false
			_begin_basic(combo_stage)
			return
		# Do not preserve a physical attack stage after the hero returns to idle.
		# BattleHud owns the separate hit-combo timeout.
		combo_stage = 0
		combo_window = 0.0
		zhang_basic_jump_has_direction = false
	elif current_action == "active":
		combat_action_finished.emit("active")
	clear_basic_attack_movement()
	current_action = ""
	action_elapsed = 0.0
	action_duration = 0.0

func _cancel_basic_for_skill() -> void:
	var cancelled_stage := combo_stage
	pending_attack = null
	hit_delay_remaining = 0.0
	attack_lock_remaining = 0.0
	path_dash_request = null
	path_dash_remaining = 0.0
	path_dash_speed = 0.0
	path_dash_distance_remaining = 0.0
	zhang_jump_request = null
	zhang_jump_remaining = 0.0
	zhang_jump_duration = 0.0
	zhang_jump_speed = 0.0
	zhang_jump_distance_remaining = 0.0
	zhang_jump_total_distance = 0.0
	zhang_jump_peak_height = 0.0
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	buffered_basic_has_direction = false
	combo_stage = 0
	zhang_basic_jump_has_direction = false
	current_action = ""
	clear_basic_attack_movement()
	action_elapsed = 0.0
	action_duration = 0.0
	combat_action_finished.emit("basic_%d" % cancelled_stage)

func _tick_momentum(delta: float, move_direction: Vector2) -> void:
	if move_direction.length_squared() <= 0.01 or is_action_locked():
		momentum = maxf(0.0, momentum - delta * 0.62)
		return
	var direction := move_direction.normalized()
	if previous_move_direction.length_squared() > 0.01 and previous_move_direction.dot(direction) < 0.58:
		momentum = minf(momentum, 0.22)
	momentum = minf(1.0, momentum + delta * 0.50)
	previous_move_direction = direction

func _move(direction: Vector2, distance: float) -> void:
	if is_defeated() or is_guard_active():
		return
	var normalized := direction.normalized() if direction.length_squared() > 0.01 else Vector2.ZERO
	position += normalized * distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)

func _update_facing(direction: Vector2) -> void:
	if is_guard_active():
		return
	if direction.length_squared() > 0.01:
		last_attack_direction = _eight_way_direction(direction, last_attack_direction)

func _update_buffered_basic_direction() -> void:
	if current_action != "basic" or not has_buffered_basic:
		return
	var live_input := _current_basic_input()
	var next_stage := (combo_stage % _basic_stage_count()) + 1
	if live_input.length_squared() <= 0.01:
		buffered_basic_has_direction = _is_zhang_directional_jump_input(next_stage, live_input)
		return
	var fallback := buffered_basic_direction if buffered_basic_direction.length_squared() > 0.01 else last_attack_direction
	buffered_basic_direction = _direction_for_basic_stage(next_stage, live_input, fallback)
	buffered_basic_has_direction = _is_zhang_directional_jump_input(next_stage, live_input)

func _direction_for_basic_stage(stage: int, direction: Vector2, fallback: Vector2) -> Vector2:
	if hero_id != "zhang_fei":
		return _eight_way_direction(direction, fallback)
	if stage >= 3:
		var slam_level := _effective_zhang_leaping_slam_level()
		if slam_level >= 3:
			return _eight_way_direction(direction, fallback)
		if slam_level >= 2:
			return _limited_zhang_jump_direction(direction, fallback)
	if is_zhang_fei_ultimate_active():
		return _eight_way_direction(direction, fallback)
	var horizontal_source := direction if absf(direction.x) > 0.01 else fallback
	return Vector2.LEFT if horizontal_source.x < 0.0 else Vector2.RIGHT

func _effective_zhang_leaping_slam_level() -> int:
	return 3 if is_zhang_fei_ultimate_active() else zhang_leaping_slam_level

func _is_zhang_directional_jump_input(stage: int, direction: Vector2) -> bool:
	return hero_id == "zhang_fei" and stage >= 3 and _effective_zhang_leaping_slam_level() >= 3 and direction.length_squared() > 0.01

func _is_zhang_fei_slam_action() -> bool:
	return hero_id == "zhang_fei" and current_action == "basic" and combo_stage == 3

func _limited_zhang_jump_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	var forward := fallback.normalized() if fallback.length_squared() > 0.01 else Vector2.RIGHT
	var desired := _eight_way_direction(direction, forward)
	var turn_angle := clampf(wrapf(desired.angle() - forward.angle(), -PI, PI), -PI * 0.25, PI * 0.25)
	return forward.rotated(turn_angle).normalized()

func _zhang_basic_jump_distance() -> float:
	match _effective_zhang_leaping_slam_level():
		2: return ZHANG_FEI_BASIC_SHORT_JUMP_DISTANCE
		3: return ZHANG_FEI_BASIC_JUMP_DISTANCE if zhang_basic_jump_has_direction else ZHANG_FEI_BASIC_SHORT_JUMP_DISTANCE
	return 0.0

func _zhang_active_jump_distance_for_charge(charge_ratio: float) -> float:
	var ratio := clampf(charge_ratio, 0.0, 1.0)
	var eased_ratio := ratio * ratio * (3.0 - 2.0 * ratio)
	var maximum_distance := ZHANG_FEI_ACTIVE_UPGRADED_JUMP_DISTANCE if zhang_active_charge_level > 0 else ZHANG_FEI_ACTIVE_JUMP_DISTANCE
	return lerpf(ZHANG_FEI_ACTIVE_SHORT_JUMP_DISTANCE, maximum_distance, eased_ratio)

func _zhang_active_hold_max_duration() -> float:
	return ZHANG_FEI_ACTIVE_HOLD_UPGRADED_DURATION if zhang_active_charge_level > 0 else ZHANG_FEI_ACTIVE_HOLD_MAX_DURATION

func _zhang_slam_forward_extension() -> float:
	match _effective_zhang_leaping_slam_level():
		1: return 66.0
		2: return 74.0
		3: return 82.0
	return 58.0

func _zhang_basic_jump_duration() -> float:
	match _effective_zhang_leaping_slam_level():
		2: return 0.25
		3: return ZHANG_FEI_BASIC_JUMP_DURATION
	return 0.26

func _zhang_basic_jump_height() -> float:
	match _effective_zhang_leaping_slam_level():
		1: return 30.0
		2: return 44.0
		3: return ZHANG_FEI_BASIC_JUMP_HEIGHT
	return 24.0

func effective_move_speed() -> float:
	if hero_id == "zhang_fei" and is_zhang_fei_ultimate_active():
		return speed * (ZHANG_FEI_ULTIMATE_MOVE_SPEED_RATIO + zhang_ultimate_move_speed_bonus) * movement_speed_multiplier()
	if hero_id == "zhang_fei" and rage_remaining > 0.0:
		return speed * (1.0 + zhang_rage_move_speed_ratio) * movement_speed_multiplier()
	return speed * movement_speed_multiplier()

func _has_zhang_rage() -> bool:
	return hero_id == "zhang_fei" and rage_stacks > 0 and rage_remaining > 0.0

func _grant_zhang_rage_stack() -> void:
	if hero_id != "zhang_fei":
		return
	rage_stacks = mini(ZHANG_RAGE_MAX_STACKS, rage_stacks + 1)
	rage_remaining = zhang_rage_duration

func _add_zhang_rage_progress(value: int) -> void:
	if hero_id != "zhang_fei" or value <= 0:
		return
	# Kills and successful clashes share one meter. A single clash callback can
	# only add one packet, so repeated telegraph checks cannot double-count it.
	rage_hits += value
	while rage_hits >= zhang_rage_kill_requirement and rage_stacks < ZHANG_RAGE_MAX_STACKS:
		rage_hits -= zhang_rage_kill_requirement
		_grant_zhang_rage_stack()
	if rage_stacks >= ZHANG_RAGE_MAX_STACKS:
		rage_remaining = zhang_rage_duration
		rage_hits = mini(rage_hits, maxi(0, zhang_rage_kill_requirement - 1))

func _decay_zhang_rage() -> void:
	if hero_id != "zhang_fei" or rage_stacks <= 0:
		rage_remaining = 0.0
		return
	rage_stacks = maxi(0, rage_stacks - 1)
	rage_remaining = zhang_rage_duration if rage_stacks > 0 else 0.0

func _zhang_rage_attack_speed_multiplier() -> float:
	return 1.0 + float(rage_stacks) * ZHANG_RAGE_ATTACK_SPEED_PER_STACK if hero_id == "zhang_fei" else 1.0

func _zhang_rage_side_rear_damage_multiplier(attack_origin: Vector2) -> float:
	if not _has_zhang_rage() or attack_origin.length_squared() <= 0.01:
		return 1.0
	var incoming := attack_origin - position
	if incoming.length_squared() <= 0.01:
		return 1.0
	var facing := last_attack_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = Vector2.RIGHT
	if absf(facing.angle_to(incoming.normalized())) <= ZHANG_RAGE_FRONT_HALF_ANGLE:
		return 1.0
	return pow(1.0 - ZHANG_RAGE_REAR_DAMAGE_REDUCTION, rage_stacks)

func _zhang_ultimate_duration() -> float:
	return ZHANG_FEI_ULTIMATE_DURATION + zhang_ultimate_duration_bonus

func _current_basic_input(explicit_direction: Vector2 = Vector2.ZERO) -> Vector2:
	return explicit_direction if explicit_direction.length_squared() > 0.01 else current_move_direction

func _eight_way_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	if direction.length_squared() <= 0.01:
		return fallback.normalized() if fallback.length_squared() > 0.01 else Vector2.RIGHT
	return Vector2.from_angle(snappedf(direction.angle(), PI * 0.25))

func _on_protection_broken() -> void:
	protection_broken.emit()

func _on_died() -> void:
	died.emit()
