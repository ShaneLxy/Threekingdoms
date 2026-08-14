class_name PrototypeHeroActor
extends HeroActor

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

const ULTIMATE_COST := 40.0
const WEAPON_CLASH_DURATION := 0.22
const WEAPON_CLASH_REACH := 220.0

@export var prototype_hero_id := "zhang_fei"

enum UltimateState { INACTIVE, WINDUP, EXECUTING, RECOVERY }

var combo_window := 0.0
var attack_lock_remaining := 0.0
var hit_delay_remaining := 0.0
var action_elapsed := 0.0
var action_duration := 0.0
var pending_attack: AttackRequest
var has_buffered_basic := false
var active_direction := Vector2.RIGHT
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
var rage_hits := 0
var rage_remaining := 0.0
var guard_remaining := 0.0
var guard_charges := 0
var momentum := 0.0
var previous_move_direction := Vector2.ZERO
var bow_stance := true
var basic_range_bonus := 0.0
var damage_bonus := 0.0
var knockback_bonus := 0.0
var stance_bonus := 0.0
var active_range_bonus := 0.0
var ultimate_bonus := 0.0
var guard_duration_bonus := 0.0
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
	active_cooldown = 0.0
	active_direction = Vector2.RIGHT
	ultimate_energy = 0.0
	ultimate_time = 0.0
	ultimate_segment_index = 0
	ultimate_dash_direction = Vector2.RIGHT
	last_attack_direction = Vector2.RIGHT
	current_action = ""
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
	rage_hits = 0
	rage_remaining = 0.0
	guard_remaining = 0.0
	guard_charges = 0
	momentum = 0.0
	previous_move_direction = Vector2.ZERO
	bow_stance = true
	basic_range_bonus = 0.0
	damage_bonus = 0.0
	knockback_bonus = 0.0
	stance_bonus = 0.0
	active_range_bonus = 0.0
	ultimate_bonus = 0.0
	guard_duration_bonus = 0.0
	projectile_pierce_bonus = 0
	return_to_bow_on_release = false
	health_component.reset(float(base_stats.get("health", 140.0)))

func tick(delta: float, move_direction: Vector2) -> void:
	active_cooldown = maxf(0.0, active_cooldown - delta)
	combo_window = maxf(0.0, combo_window - delta)
	weapon_clash_remaining = maxf(0.0, weapon_clash_remaining - delta)
	rage_remaining = maxf(0.0, rage_remaining - delta)
	guard_remaining = maxf(0.0, guard_remaining - delta)
	if guard_remaining <= 0.0:
		guard_charges = 0
	if weapon_clash_remaining <= 0.0:
		weapon_clash_type = Telegraph.ClashKind.NONE
	if combo_window <= 0.0 and not (current_action == "basic" and attack_lock_remaining > 0.0):
		combo_stage = 0
	if hero_id == "ma_chao":
		_tick_momentum(delta, move_direction)
	if is_path_dashing():
		_tick_path_dash(delta)
	if ultimate_state != UltimateState.INACTIVE:
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
		if was_locked and attack_lock_remaining <= 0.0 and not is_path_dashing():
			_finish_action()
	if not is_action_locked():
		_update_facing(move_direction)
		_move(move_direction, speed * delta)

func request_basic(direction: Vector2 = Vector2.ZERO) -> bool:
	if ultimate_state != UltimateState.INACTIVE:
		return false
	if is_action_locked():
		if current_action == "basic" and combo_stage < _basic_stage_count() and not has_buffered_basic:
			has_buffered_basic = true
			return true
		return false
	_update_facing(direction)
	if combo_window <= 0.0:
		combo_stage = 0
	combo_stage = (combo_stage % _basic_stage_count()) + 1
	_begin_basic(combo_stage)
	return true

func request_active(direction: Vector2 = Vector2.ZERO) -> bool:
	if active_cooldown > 0.0 or ultimate_state != UltimateState.INACTIVE:
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	active_direction = _eight_way_direction(direction, last_attack_direction)
	_update_facing(active_direction)
	active_cooldown = active_cooldown_duration
	match hero_id:
		"zhang_fei":
			guard_remaining = 0.70 + guard_duration_bonus
			guard_charges = 1
			_start_action("active", 0.86)
			hit_delay_remaining = 0.26
			pending_attack = AttackRequest.fan(position, active_direction, 230.0 + active_range_bonus, deg_to_rad(154.0), 3.05 + damage_bonus, 28, "据水断桥")
			pending_attack.knockback = 820.0 + knockback_bonus
			pending_attack.forced_displacement = 112.0
			pending_attack.forced_displacement_duration = 0.20
			pending_attack.fan_knockback = true
			pending_attack.stance_damage = 52.0 + stance_bonus
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
	pending_attack.action_kind = AttackRequest.ActionKind.ACTIVE
	pending_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	active_used.emit()
	combat_action_started.emit("active")
	return true

func can_use_active() -> bool:
	return active_cooldown <= 0.0 and ultimate_state == UltimateState.INACTIVE and (not is_action_locked() or current_action == "basic")

func request_ultimate(direction: Vector2 = Vector2.ZERO) -> bool:
	if ultimate_energy < ULTIMATE_COST or ultimate_state != UltimateState.INACTIVE:
		return false
	if is_action_locked() and current_action != "basic":
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	_update_facing(direction)
	ultimate_energy -= ULTIMATE_COST
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
	projectile_pierce_bonus += military_pierce_bonus

func apply_upgrade(upgrade_id: String) -> void:
	if apply_common_upgrade(upgrade_id):
		return
	match upgrade_id:
		"zhang_heavy_roar":
			basic_range_bonus += 18.0
			knockback_bonus += 82.0
		"zhang_iron_hide":
			defense_bonus += 4.0
			guard_duration_bonus += 0.12
		"zhang_rage":
			rage_remaining = maxf(rage_remaining, 2.4)
			damage_bonus += 0.13
		"zhang_earthshaker":
			ultimate_bonus += 0.46
			stance_bonus += 16.0
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
		"move_speed": speed,
		"active_cooldown": active_cooldown_duration,
		"ultimate_cost": ULTIMATE_COST,
	}

func ultimate_cost() -> float:
	return ULTIMATE_COST

func is_ultimate_ready() -> bool:
	return ultimate_energy >= ULTIMATE_COST

func is_action_locked() -> bool:
	return attack_lock_remaining > 0.0 or ultimate_state != UltimateState.INACTIVE or is_path_dashing()

func is_attacking() -> bool:
	return current_action in ["basic", "active", "ultimate"] or is_path_dashing()

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

func receive_damage(amount: float, _source: String) -> float:
	if hero_id == "zhang_fei" and guard_charges > 0 and guard_remaining > 0.0:
		guard_charges -= 1
		protection_broken.emit()
		return 0.0
	var reduced_amount := CombatMath.mitigate_damage(amount, total_defense())
	if hero_id == "zhang_fei" and rage_remaining > 0.0:
		reduced_amount *= 0.82
	var applied_damage := health_component.take_damage(reduced_amount)
	if applied_damage > 0.0:
		damaged.emit(applied_damage)
	return applied_damage

func on_enemy_defeated(_enemy_type: int) -> void:
	apply_military_enemy_defeat_reward(_enemy_type)
	if hero_id != "zhang_fei":
		return
	rage_hits += 1
	if rage_hits < 6:
		return
	rage_hits = 0
	rage_remaining = 3.0

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
		"zhang_fei": return "当阳怒吼"
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

func has_breakout_guard() -> bool:
	return hero_id == "zhang_fei" and guard_charges > 0 and guard_remaining > 0.0

func hud_status_effects() -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	if hero_id == "zhang_fei":
		if guard_remaining > 0.0:
			effects.append({"label": "断桥", "icon": "盾", "stacks": guard_charges, "remaining": guard_remaining, "duration": 0.70 + guard_duration_bonus, "color": Color("de8742")})
		if rage_remaining > 0.0:
			effects.append({"label": "怒势", "icon": "怒", "stacks": 1, "remaining": rage_remaining, "duration": 3.0, "color": Color("d85a3e")})
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
	return path_dash_direction

func _basic_stage_count() -> int:
	return 2 if hero_id == "huang_zhong" else 3

func _begin_basic(stage: int) -> void:
	combo_window = 0.72
	has_buffered_basic = false
	var lock := 0.52
	var hit_delay := 0.20
	var request: AttackRequest
	match hero_id:
		"zhang_fei":
			if stage == 1:
				lock = 0.50
				hit_delay = 0.18
				request = AttackRequest.fan(position, last_attack_direction, 138.0 + basic_range_bonus, deg_to_rad(128.0), 1.45 + damage_bonus, 16, "蛇矛横扫")
				request.knockback = 290.0 + knockback_bonus
				request.forced_displacement = 32.0
				request.stance_damage = 16.0 + stance_bonus
			elif stage == 2:
				lock = 0.58
				hit_delay = 0.22
				request = AttackRequest.fan(position, last_attack_direction, 172.0 + basic_range_bonus, deg_to_rad(158.0), 1.80 + damage_bonus, 22, "横矛断阵")
				request.knockback = 430.0 + knockback_bonus
				request.forced_displacement = 52.0
				request.fan_knockback = true
				request.stance_damage = 27.0 + stance_bonus
			else:
				lock = 0.74
				hit_delay = 0.32
				request = AttackRequest.fan(position, last_attack_direction, 208.0 + basic_range_bonus, deg_to_rad(188.0), 2.45 + damage_bonus, 30, "燕人震退")
				request.knockback = 720.0 + knockback_bonus
				request.forced_displacement = 96.0
				request.forced_displacement_duration = 0.17
				request.fan_knockback = true
				request.stance_damage = 52.0 + stance_bonus
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
	pending_attack = request
	_start_action("basic", lock)
	hit_delay_remaining = hit_delay
	combat_action_started.emit("basic_%d" % stage)

func _release_pending_attack() -> void:
	if pending_attack == null:
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
	return 3 if hero_id == "zhang_fei" else 5

func _emit_ultimate_attack(phase: int) -> void:
	var request: AttackRequest
	match hero_id:
		"zhang_fei":
			if phase == 1:
				request = AttackRequest.fan(position, last_attack_direction, 236.0, deg_to_rad(190.0), 3.15 + ultimate_bonus, 34, "当阳怒吼·横断")
			elif phase == 2:
				request = AttackRequest.circle(position, 202.0, 3.65 + ultimate_bonus, 38, "当阳怒吼·震地")
			else:
				request = AttackRequest.fan(position, last_attack_direction, 268.0, deg_to_rad(208.0), 4.90 + ultimate_bonus, 44, "当阳怒吼·断喝")
			request.knockback = 920.0 + knockback_bonus
			request.forced_displacement = 130.0
			request.forced_displacement_duration = 0.22
			request.fan_knockback = true
			request.stance_damage = 72.0 + stance_bonus + float(phase) * 16.0
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
			has_buffered_basic = false
			combo_stage = (combo_stage % _basic_stage_count()) + 1
			_begin_basic(combo_stage)
			return
	elif current_action == "active":
		combat_action_finished.emit("active")
	current_action = ""
	action_elapsed = 0.0
	action_duration = 0.0

func _cancel_basic_for_skill() -> void:
	var cancelled_stage := combo_stage
	pending_attack = null
	hit_delay_remaining = 0.0
	attack_lock_remaining = 0.0
	path_dash_request = null
	path_dash_distance_remaining = 0.0
	combo_window = 0.0
	has_buffered_basic = false
	combo_stage = 0
	current_action = ""
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
	var normalized := direction.normalized() if direction.length_squared() > 0.01 else Vector2.ZERO
	position += normalized * distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)

func _update_facing(direction: Vector2) -> void:
	if direction.length_squared() > 0.01:
		last_attack_direction = _eight_way_direction(direction, last_attack_direction)

func _eight_way_direction(direction: Vector2, fallback: Vector2) -> Vector2:
	if direction.length_squared() <= 0.01:
		return fallback.normalized() if fallback.length_squared() > 0.01 else Vector2.RIGHT
	return Vector2.from_angle(snappedf(direction.angle(), PI * 0.25))

func _on_protection_broken() -> void:
	protection_broken.emit()

func _on_died() -> void:
	died.emit()
