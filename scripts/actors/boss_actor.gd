class_name BossActor
extends Node2D

signal telegraph_requested(telegraph: Telegraph)
signal summon_requested(phase: int)
signal phase_changed(phase: int)
signal skill_impact_requested(strength: float)
signal defeated()

enum State { APPROACH, WINDUP, DASH, RECOVER, PHASE_TRANSITION, REPOSITION }
enum Archetype { ZHANG_HE, XIAHOU_DUN }

const HEALTH_LAYER_CAPACITY := 500.0
const BOSS_ENERGY_DAMAGE_PER_POINT := 50.0
const BOSS_ENERGY_PER_PHASE_CAP := 10.0
const ENGAGE_DELAY := 0.24
const BASE_HEALTH := 3600.0
const BASE_ARMOR := 24.0
const XIAHOU_DUN_BASE_HEALTH := 4400.0
const XIAHOU_DUN_BASE_ARMOR := 28.0
const XIAHOU_DUN_MOVE_SPEED := 88.0
const THREAT_HEALTH_MULTIPLIERS := [1.0, 1.35, 1.80, 2.35, 3.00]
const THREAT_DAMAGE_MULTIPLIERS := [1.0, 1.12, 1.28, 1.48, 1.72]
const STANCE_MAX := 160.0
const STANCE_BREAK_DURATION := 4.8
const STANCE_BREAK_DAMAGE_MULTIPLIER := 1.20
const STANCE_BREAK_KNOCKBACK_BUDGET := 75.0
const STANCE_BREAK_MAX_HIT_KNOCKBACK := 32.0
const STANCE_BREAK_RECOIL_DURATION := 0.20
const DEATH_ANIMATION_DURATION := 0.64
const PURSUIT_COOLDOWN := 7.5
const PURSUIT_DASH_DURATION := 0.45
const PURSUIT_DASH_RECOVERY := 0.78
const SPEAR_WALL_COOLDOWN := 6.5
const WHIRL_COOLDOWN := 6.0
const THREE_THRUST_COOLDOWN := 7.0
const SUMMON_COOLDOWN := 8.0
const FIRE_CHARGE_COOLDOWN := 7.8
const FIRE_LINES_COOLDOWN := 9.6
const ARROW_RAIN_COOLDOWN := 9.8
const IDEAL_ENGAGE_MIN_RANGE := 126.0
const IDEAL_ENGAGE_MAX_RANGE := 194.0
const HORIZONTAL_LANE_TOLERANCE := 42.0
const CLOSE_QUARTERS_WHIRL_CHANCE := 0.28
const COUNTERATTACK_DURATION := 4.0
const COUNTERATTACK_DAMAGE_MULTIPLIER := 1.30
const REPOSITION_COOLDOWN := 2.4
const REPOSITION_DURATION := 0.48
const REPOSITION_SPEED := 188.0
const PLAYER_STATIONARY_SPEED := 34.0

@onready var health_component: HealthComponent = %HealthComponent

var active := false
var archetype: Archetype = Archetype.ZHANG_HE
var dying := false
var death_animation_elapsed := 0.0
var phase := 1
var state := State.APPROACH
var state_timer := 0.0
var pending_recovery := 0.0
var phase_summon_pending := false
var move_speed := 135.0
var facing_direction := Vector2.DOWN
var thrust_sequence: Array[float] = []
var thrust_sequence_direction := Vector2.DOWN
var phase_energy_granted := 0.0
var phase_energy_progress := 0.0
var threat_tier := 0
var last_player_position := Vector2.ZERO
var player_velocity := Vector2.ZERO
var has_player_position := false
var pending_dash_target := Vector2.ZERO
var pending_dash_duration := 0.0
var pending_dash_recovery := 0.0
var pending_dash_active := false
var dash_target := Vector2.ZERO
var dash_speed := 0.0
var dash_recovery := 0.0
var pending_shake_strength := 0.0
var current_action := ""
var action_animation_elapsed := 0.0
var moving := false
var stance := STANCE_MAX
var stance_break_remaining := 0.0
var stance_knockback_remaining := 0.0
var knockback_visual_remaining := 0.0
var knockback_visual_duration := 0.0
var knockback_visual_displacement := 0.0
var knockback_visual_direction := Vector2.RIGHT
var knockback_visual_intensity := 0.0
var action_cooldowns: Dictionary = {}
var high_risk_skill_allowed := true
var cast_invulnerable := false
var combo_steps: Array[String] = []
var last_combo_id := ""
var counterattack_remaining := 0.0
var counterattack_action_multiplier := 1.0
var movement_bounds := Rect2()
var has_movement_bounds := false
var slow_remaining := 0.0
var slow_multiplier := 1.0
var tactical_reposition_cooldown := 0.0
var reposition_target := Vector2.ZERO
var reposition_step := 0
var player_is_attacking := false
var navigation_waypoint := Vector2.ZERO

func _ready() -> void:
	health_component.died.connect(_on_died)

func set_movement_bounds(bounds: Rect2) -> void:
	movement_bounds = bounds
	has_movement_bounds = bounds.size.x > 0.0 and bounds.size.y > 0.0
	position = _clamp_to_movement_bounds(position)

func set_archetype(new_archetype: Archetype) -> void:
	archetype = new_archetype

func activate(at: Vector2, new_threat_tier: int = 0) -> void:
	active = true
	dying = false
	death_animation_elapsed = 0.0
	visible = true
	position = _clamp_to_movement_bounds(at)
	threat_tier = clampi(new_threat_tier, 0, THREAT_HEALTH_MULTIPLIERS.size() - 1)
	phase = 1
	state = State.APPROACH
	state_timer = ENGAGE_DELAY
	pending_recovery = 0.0
	phase_summon_pending = false
	facing_direction = Vector2.DOWN
	thrust_sequence.clear()
	thrust_sequence_direction = Vector2.DOWN
	phase_energy_granted = 0.0
	phase_energy_progress = 0.0
	last_player_position = at
	player_velocity = Vector2.ZERO
	has_player_position = false
	player_is_attacking = false
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	dash_target = Vector2.ZERO
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_shake_strength = 0.0
	cast_invulnerable = false
	current_action = ""
	action_animation_elapsed = 0.0
	moving = false
	stance = STANCE_MAX
	stance_break_remaining = 0.0
	stance_knockback_remaining = 0.0
	knockback_visual_remaining = 0.0
	knockback_visual_duration = 0.0
	knockback_visual_displacement = 0.0
	knockback_visual_direction = Vector2.RIGHT
	knockback_visual_intensity = 0.0
	action_cooldowns.clear()
	high_risk_skill_allowed = true
	combo_steps.clear()
	last_combo_id = ""
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
	slow_remaining = 0.0
	slow_multiplier = 1.0
	tactical_reposition_cooldown = 0.0
	reposition_target = position
	reposition_step = 0
	navigation_waypoint = Vector2.ZERO
	health_component.reset(max_health())

func set_navigation_waypoint(value: Vector2) -> void:
	navigation_waypoint = value

func tick(delta: float, player_position: Vector2, player_attacking: bool = false) -> void:
	if dying:
		death_animation_elapsed += delta
		if death_animation_elapsed >= DEATH_ANIMATION_DURATION:
			dying = false
			visible = false
			defeated.emit()
		return
	if not active:
		return
	_track_player_motion(delta, player_position)
	player_is_attacking = player_attacking
	_tick_action_cooldowns(delta)
	tactical_reposition_cooldown = maxf(0.0, tactical_reposition_cooldown - delta)
	counterattack_remaining = maxf(0.0, counterattack_remaining - delta)
	slow_remaining = maxf(0.0, slow_remaining - delta)
	if slow_remaining <= 0.0:
		slow_multiplier = 1.0
	var was_stance_broken := stance_break_remaining > 0.0
	stance_break_remaining = maxf(0.0, stance_break_remaining - delta)
	knockback_visual_remaining = maxf(0.0, knockback_visual_remaining - delta)
	if was_stance_broken and stance_break_remaining <= 0.0:
		stance = STANCE_MAX
		stance_knockback_remaining = 0.0
	if state == State.WINDUP:
		action_animation_elapsed += delta
	if _begin_phase_transition_if_needed():
		return
	match state:
		State.PHASE_TRANSITION:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				if phase_summon_pending:
					phase_summon_pending = false
					summon_requested.emit(phase)
				_enter_recovery(0.45)
		State.WINDUP:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_finish_windup()
		State.DASH:
			_tick_dash(delta)
		State.RECOVER:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				if _should_reposition_after_combo(player_position):
					_begin_reposition(player_position)
				else:
					state = State.APPROACH
					state_timer = ENGAGE_DELAY
		State.REPOSITION:
			state_timer = maxf(0.0, state_timer - delta)
			position = _clamp_to_movement_bounds(position.move_toward(reposition_target, REPOSITION_SPEED * slow_multiplier * delta))
			moving = position.distance_squared_to(reposition_target) > 4.0
			if state_timer <= 0.0 or not moving:
				state = State.APPROACH
				state_timer = ENGAGE_DELAY
				moving = false
		State.APPROACH:
			if _approach_player(delta, player_position):
				state_timer = maxf(0.0, state_timer - delta)
				if state_timer <= 0.0:
					_issue_next_action(player_position)
			else:
				state_timer = ENGAGE_DELAY
	position = _clamp_to_movement_bounds(position)

func freeze_for_cinematic() -> void:
	if not active or dying:
		return
	state = State.APPROACH
	state_timer = 0.0
	pending_recovery = 0.0
	phase_summon_pending = false
	thrust_sequence.clear()
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	dash_target = position
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_shake_strength = 0.0
	cast_invulnerable = false
	current_action = ""
	action_animation_elapsed = 0.0
	moving = false
	knockback_visual_remaining = 0.0
	knockback_visual_duration = 0.0
	knockback_visual_displacement = 0.0
	knockback_visual_direction = Vector2.RIGHT
	knockback_visual_intensity = 0.0
	combo_steps.clear()
	reposition_target = position

func receive_player_hit(amount: float) -> Dictionary:
	if not active:
		return {"damage": 0.0, "stance_broken": false}
	if cast_invulnerable:
		return {"damage": 0.0, "stance_broken": false, "invulnerable": true}
	var actual := amount * (STANCE_BREAK_DAMAGE_MULTIPLIER if is_stance_broken() else 1.0)
	return {"damage": health_component.take_damage(actual), "stance_broken": false}

func apply_slow(multiplier: float, duration: float) -> void:
	if not active or duration <= 0.0:
		return
	slow_remaining = maxf(slow_remaining, duration)
	slow_multiplier = minf(slow_multiplier, clampf(multiplier, 0.45, 1.0))

func add_stance_damage(amount: float) -> bool:
	if not active or is_stance_broken() or amount <= 0.0:
		return false
	stance = maxf(0.0, stance - amount)
	if stance > 0.0:
		return false
	stance_break_remaining = STANCE_BREAK_DURATION
	stance_knockback_remaining = STANCE_BREAK_KNOCKBACK_BUDGET
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
	return true

func apply_stance_break_knockback(direction: Vector2, force: float, forced_displacement: float = 0.0) -> float:
	if not is_stance_broken() or direction.length_squared() <= 0.01 or stance_knockback_remaining <= 0.0:
		return 0.0
	var scaled_force := maxf(force * 0.11, forced_displacement * 0.52)
	var displacement := clampf(scaled_force, 7.0, STANCE_BREAK_MAX_HIT_KNOCKBACK)
	displacement = minf(displacement, stance_knockback_remaining)
	stance_knockback_remaining -= displacement
	var normalized_direction := direction.normalized()
	position += normalized_direction * displacement
	knockback_visual_direction = normalized_direction
	knockback_visual_displacement = displacement
	knockback_visual_duration = STANCE_BREAK_RECOIL_DURATION
	knockback_visual_remaining = STANCE_BREAK_RECOIL_DURATION
	knockback_visual_intensity = clampf(displacement / STANCE_BREAK_MAX_HIT_KNOCKBACK, 0.35, 1.0)
	return displacement

func apply_guard_knockback(direction: Vector2, force: float, forced_displacement: float = 0.0) -> float:
	if not active or direction.length_squared() <= 0.01:
		return 0.0
	var displacement := clampf(maxf(force * 0.025, forced_displacement * 0.28), 2.0, 9.0)
	var normalized_direction := direction.normalized()
	position = _clamp_to_movement_bounds(position + normalized_direction * displacement)
	knockback_visual_direction = normalized_direction
	knockback_visual_displacement = displacement
	knockback_visual_duration = 0.14
	knockback_visual_remaining = knockback_visual_duration
	knockback_visual_intensity = clampf(displacement / 9.0, 0.20, 0.55)
	return displacement

func is_knockback_visual_active() -> bool:
	return active and knockback_visual_remaining > 0.0

func knockback_visual_progress() -> float:
	if knockback_visual_duration <= 0.0:
		return 1.0
	return clampf(1.0 - knockback_visual_remaining / knockback_visual_duration, 0.0, 1.0)

func knockback_visual_offset() -> Vector2:
	var progress := knockback_visual_progress()
	var eased_progress := 1.0 - pow(1.0 - progress, 2.35)
	return -knockback_visual_direction * knockback_visual_displacement * (1.0 - eased_progress)

func knockback_visual_strength() -> float:
	return knockback_visual_intensity

func interrupt_action_for_knockback() -> bool:
	if not active or state not in [State.WINDUP, State.DASH]:
		return false
	thrust_sequence.clear()
	thrust_sequence_direction = facing_direction
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	dash_target = position
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_recovery = 0.0
	pending_shake_strength = 0.0
	current_action = ""
	action_animation_elapsed = 0.0
	moving = false
	state = State.APPROACH
	state_timer = ENGAGE_DELAY
	return true

func stance_ratio() -> float:
	return stance / STANCE_MAX

func is_stance_broken() -> bool:
	return active and stance_break_remaining > 0.0

func convert_damage_to_ultimate_energy(actual_damage: float) -> float:
	if actual_damage <= 0.0 or phase_energy_granted >= BOSS_ENERGY_PER_PHASE_CAP:
		return 0.0
	phase_energy_progress += actual_damage / BOSS_ENERGY_DAMAGE_PER_POINT
	var whole_points := floorf(phase_energy_progress)
	if whole_points <= 0.0:
		return 0.0
	var granted := minf(whole_points, BOSS_ENERGY_PER_PHASE_CAP - phase_energy_granted)
	phase_energy_granted += granted
	if phase_energy_granted >= BOSS_ENERGY_PER_PHASE_CAP:
		phase_energy_progress = 0.0
	else:
		phase_energy_progress -= granted
	return granted

func health_ratio() -> float:
	return health_component.current / maxf(1.0, health_component.maximum)

func max_health() -> float:
	var base_health := XIAHOU_DUN_BASE_HEALTH if archetype == Archetype.XIAHOU_DUN else BASE_HEALTH
	return base_health * float(THREAT_HEALTH_MULTIPLIERS[threat_tier])

func is_recovering() -> bool:
	return state == State.RECOVER

func is_moving() -> bool:
	return active and moving

func is_dying() -> bool:
	return dying

func death_animation_progress() -> float:
	return clampf(death_animation_elapsed / DEATH_ANIMATION_DURATION, 0.0, 1.0)

func set_high_risk_skill_allowed(value: bool) -> void:
	high_risk_skill_allowed = value

func _player_is_stationary() -> bool:
	return player_velocity.length() <= PLAYER_STATIONARY_SPEED

func _should_reposition_after_combo(player_position: Vector2) -> bool:
	if not combo_steps.is_empty() or tactical_reposition_cooldown > 0.0:
		return false
	var distance := position.distance_to(player_position)
	if distance > 300.0:
		return false
	var chance := 0.20 + float(phase - 1) * 0.05
	if _player_is_stationary():
		chance += 0.22
	if player_is_attacking:
		chance += 0.20
	if distance < IDEAL_ENGAGE_MIN_RANGE:
		chance += 0.12
	return randf() < chance

func _begin_reposition(player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length_squared() <= 0.01:
		to_player = facing_direction
	var radial := to_player.normalized()
	var lateral := Vector2(-radial.y, radial.x)
	var side := -1.0 if reposition_step % 2 == 0 else 1.0
	var radial_offset := -36.0 if _player_is_stationary() else 22.0
	if player_is_attacking:
		radial_offset += 20.0
	reposition_target = _clamp_to_movement_bounds(position + lateral * side * 82.0 + radial * radial_offset)
	tactical_reposition_cooldown = REPOSITION_COOLDOWN
	reposition_step += 1
	state = State.REPOSITION
	state_timer = REPOSITION_DURATION
	moving = true

func is_high_risk_action_active() -> bool:
	return active and state in [State.WINDUP, State.DASH] and _is_high_risk_action(current_action)

func is_cast_invulnerable() -> bool:
	return active and cast_invulnerable

func grant_counterattack() -> void:
	if not active or is_stance_broken():
		return
	counterattack_remaining = COUNTERATTACK_DURATION

func has_counterattack() -> bool:
	return active and counterattack_remaining > 0.0

func attack_animation_progress() -> float:
	if state != State.WINDUP or state_timer <= 0.0:
		return 1.0
	return clampf(action_animation_elapsed / maxf(0.01, action_animation_elapsed + state_timer), 0.0, 1.0)

func display_name() -> String:
	return "夏侯惇" if archetype == Archetype.XIAHOU_DUN else "张郃"

func weapon_title() -> String:
	return "重枪" if archetype == Archetype.XIAHOU_DUN else "雁翎枪"

func health_layer_capacity() -> float:
	return HEALTH_LAYER_CAPACITY

func armor() -> float:
	var base_armor := XIAHOU_DUN_BASE_ARMOR if archetype == Archetype.XIAHOU_DUN else BASE_ARMOR
	return base_armor + float(threat_tier) * 2.0

func _approach_player(delta: float, player_position: Vector2) -> bool:
	moving = false
	var to_player := player_position - position
	var direction := _horizontal_direction_to(player_position)
	facing_direction = direction
	var ideal_min_range := IDEAL_ENGAGE_MIN_RANGE
	var ideal_max_range := IDEAL_ENGAGE_MAX_RANGE
	var phase_speed_bonus := float(phase - 1) * 16.0
	var walk_speed := move_speed + phase_speed_bonus
	if archetype == Archetype.XIAHOU_DUN:
		ideal_min_range = 118.0
		ideal_max_range = 184.0
		phase_speed_bonus = float(phase - 1) * 7.0
		walk_speed = XIAHOU_DUN_MOVE_SPEED + phase_speed_bonus
	if navigation_waypoint.length_squared() > 0.01:
		var to_waypoint := navigation_waypoint - position
		if to_waypoint.length() > 14.0:
			facing_direction = _horizontal_direction_to(player_position)
			position = _clamp_to_movement_bounds(position + to_waypoint.normalized() * walk_speed * slow_multiplier * delta)
			moving = true
			return false
		navigation_waypoint = Vector2.ZERO
	if absf(to_player.y) > HORIZONTAL_LANE_TOLERANCE:
		var vertical_direction := Vector2(0.0, signf(to_player.y))
		position = _clamp_to_movement_bounds(position + vertical_direction * walk_speed * slow_multiplier * delta)
		moving = true
		return false
	var horizontal_distance := absf(to_player.x)
	if horizontal_distance > ideal_max_range:
		position = _clamp_to_movement_bounds(position + direction * walk_speed * slow_multiplier * delta)
		moving = true
		return false
	if horizontal_distance < ideal_min_range:
		if archetype == Archetype.ZHANG_HE:
			return true
		position = _clamp_to_movement_bounds(position - direction * walk_speed * 0.66 * slow_multiplier * delta)
		moving = true
		return false
	return true

func _begin_phase_transition_if_needed() -> bool:
	var new_phase := 1
	if health_ratio() <= 0.35:
		new_phase = 3
	elif health_ratio() <= 0.70:
		new_phase = 2
	if new_phase == phase:
		return false
	phase = new_phase
	state = State.PHASE_TRANSITION
	state_timer = 1.0
	moving = false
	thrust_sequence.clear()
	phase_summon_pending = true
	combo_steps.clear()
	phase_energy_granted = 0.0
	phase_energy_progress = 0.0
	phase_changed.emit(phase)
	return true

func _issue_next_action(player_position: Vector2) -> void:
	if archetype == Archetype.XIAHOU_DUN:
		_issue_xiahou_dun_action(player_position)
		return
	if _is_zhang_he_in_close_quarters(player_position):
		combo_steps.clear()
		_queue_zhang_he_close_action()
	elif combo_steps.is_empty():
		_queue_next_combo()
	var action: String = str(combo_steps.pop_front())
	_start_action_cooldown(action)
	_prepare_counterattack_for(action)
	current_action = action
	action_animation_elapsed = 0.0
	var direction := _horizontal_direction_to(player_position)
	facing_direction = direction
	state = State.WINDUP
	moving = false
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	pending_shake_strength = 0.0
	match action:
		"sweep":
			_emit_attack_telegraph(Telegraph.fan(position, direction, 160.0, deg_to_rad(120.0), 0.72, _threat_damage(24.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.72
			pending_recovery = 0.58
			pending_shake_strength = 7.0
		"thrust":
			_emit_attack_telegraph(Telegraph.line(position, direction, 310.0, 34.0, 0.90, _threat_damage(30.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.90
			pending_recovery = 1.10
			pending_shake_strength = 8.0
		"pursuit":
			var dash_distance := clampf(absf(player_position.x - position.x) - 54.0, 68.0, 156.0)
			pending_dash_target = _clamp_to_movement_bounds(position + direction * dash_distance)
			pending_dash_duration = 0.36
			pending_dash_recovery = PURSUIT_DASH_RECOVERY
			pending_dash_active = true
			_emit_attack_telegraph(Telegraph.line(position, direction, dash_distance + 82.0, 62.0, 0.52, _threat_damage(36.0), "boss"), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.52
			pending_shake_strength = 10.0
		"spear_wall":
			var wall_origin := player_position - direction * 136.0
			var wall_direction := direction
			_emit_unblockable_telegraph(Telegraph.line(wall_origin, wall_direction, 272.0, 50.0, 0.74, _threat_damage(32.0), "boss"))
			state_timer = 0.74
			pending_recovery = 0.72
			pending_shake_strength = 8.5
		"whirl":
			_emit_unblockable_telegraph(Telegraph.circle(position, 165.0, 1.0, _threat_damage(28.0), "boss"))
			state_timer = 1.0
			pending_recovery = 0.80
			pending_shake_strength = 9.0
		"three_thrust":
			for offset in [0.0, 0.0, 0.0]:
				_emit_unblockable_telegraph(Telegraph.line(position, direction, 300.0, 32.0, 0.88, 0.0, "boss_preview"))
			thrust_sequence = [0.0, 0.0, 0.0]
			thrust_sequence_direction = direction
			state_timer = 0.88
			pending_recovery = 1.00
			pending_shake_strength = 8.5
		"arrow_rain":
			cast_invulnerable = true
			var rain_center := _clamp_to_movement_bounds(_predicted_player_position(0.36))
			var rain_lateral := Vector2(-direction.y, direction.x)
			for index in range(3):
				var impact_center := _clamp_to_movement_bounds(rain_center + rain_lateral * (float(index) - 1.0) * 72.0)
				var arrow_telegraph := Telegraph.circle(impact_center, 48.0, 1.08 + float(index) * 0.12, _threat_damage(30.0), "boss")
				arrow_telegraph.visual_kind = "arrow_rain"
				_emit_unblockable_telegraph(arrow_telegraph)
			state_timer = 1.34
			pending_recovery = 0.94
			pending_shake_strength = 10.5
		"summon":
			summon_requested.emit(phase)
			state_timer = 0.80
			pending_recovery = 0.80
			pending_shake_strength = 6.5
	if phase == 3 and action != "three_thrust":
		pending_recovery *= 0.82

func _issue_xiahou_dun_action(player_position: Vector2) -> void:
	if combo_steps.is_empty():
		_queue_xiahou_dun_combo()
	var action: String = str(combo_steps.pop_front())
	_start_action_cooldown(action)
	_prepare_counterattack_for(action)
	current_action = action
	action_animation_elapsed = 0.0
	facing_direction = _horizontal_direction_to(player_position)
	state = State.WINDUP
	moving = false
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	pending_shake_strength = 0.0
	match action:
		"command_sweep":
			_emit_attack_telegraph(Telegraph.fan(position, facing_direction, 178.0, deg_to_rad(128.0), 0.76, _threat_damage(26.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.76
			pending_recovery = 0.64
			pending_shake_strength = 7.6
		"command_thrust":
			_emit_attack_telegraph(Telegraph.line(position, facing_direction, 248.0, 46.0, 0.86, _threat_damage(30.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.86
			pending_recovery = 0.92
			pending_shake_strength = 8.4
		"fire_charge":
			var charge_distance := clampf(absf(player_position.x - position.x) - 46.0, 92.0, 218.0)
			pending_dash_target = _clamp_to_movement_bounds(position + facing_direction * charge_distance)
			pending_dash_duration = 0.56
			pending_dash_recovery = 0.96
			pending_dash_active = true
			_emit_attack_telegraph(Telegraph.line(position, facing_direction, charge_distance + 86.0, 70.0, 0.64, _threat_damage(38.0), "boss"), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.64
			pending_shake_strength = 10.4
		"fire_lines":
			var fire_center_x := clampf(player_position.x - 180.0, movement_bounds.position.x + 36.0, movement_bounds.end.x - 396.0)
			for lane_offset in [-68.0, 68.0]:
				var fire_y := clampf(player_position.y + lane_offset, movement_bounds.position.y + 34.0, movement_bounds.end.y - 34.0)
				_emit_unblockable_telegraph(Telegraph.line(Vector2(fire_center_x, fire_y), Vector2.RIGHT, 360.0, 30.0, 1.04, _threat_damage(28.0), "boss"))
			state_timer = 1.04
			pending_recovery = 0.96
			pending_shake_strength = 9.2
	if phase == 3 and action != "fire_lines":
		pending_recovery *= 0.86

func _queue_xiahou_dun_combo() -> void:
	var options: Array[String] = ["command_chain", "heavy_chain"]
	if _is_action_ready("fire_charge") and high_risk_skill_allowed:
		options.append("charge_chain")
		if _player_is_stationary() or player_is_attacking:
			options.append("charge_chain")
	if phase >= 2 and _is_action_ready("fire_lines") and high_risk_skill_allowed:
		options.append("fire_line_chain")
		if _player_is_stationary():
			options.append("fire_line_chain")
	if options.size() > 1 and options.has(last_combo_id):
		options.erase(last_combo_id)
	var combo_id: String = str(options.pick_random())
	last_combo_id = combo_id
	match combo_id:
		"heavy_chain":
			combo_steps = ["command_sweep", "command_sweep", "command_thrust"]
		"charge_chain":
			combo_steps = ["command_sweep", "fire_charge"]
		"fire_line_chain":
			combo_steps = ["command_thrust", "fire_lines"]
		_:
			combo_steps = ["command_sweep", "command_thrust"]

func _queue_next_combo() -> void:
	var options: Array[String] = ["double_sweep", "sweep_thrust"]
	if _is_action_ready("pursuit") and high_risk_skill_allowed:
		options.append("pursuit_chain")
		if _player_is_stationary() or player_velocity.length() > PLAYER_STATIONARY_SPEED * 2.0:
			options.append("pursuit_chain")
	if phase >= 2:
		if _is_action_ready("spear_wall") and high_risk_skill_allowed:
			options.append("spear_wall_chain")
			if _player_is_stationary():
				options.append("spear_wall_chain")
		if _is_action_ready("whirl") and high_risk_skill_allowed:
			options.append("whirl_chain")
			if player_is_attacking:
				options.append("whirl_chain")
		if _is_action_ready("summon"):
			options.append("summon_chain")
		if _is_action_ready("arrow_rain") and high_risk_skill_allowed:
			options.append("arrow_rain_chain")
			if _player_is_stationary() or player_is_attacking:
				options.append("arrow_rain_chain")
	if phase >= 3 and _is_action_ready("three_thrust") and high_risk_skill_allowed:
		options.append("three_thrust_chain")
	if options.size() > 1 and options.has(last_combo_id):
		options.erase(last_combo_id)
	var combo_id: String = str(options.pick_random())
	last_combo_id = combo_id
	match combo_id:
		"sweep_thrust":
			combo_steps = ["sweep", "thrust"]
		"pursuit_chain":
			combo_steps = ["sweep", "thrust", "pursuit"]
		"spear_wall_chain":
			combo_steps = ["thrust", "spear_wall"]
		"whirl_chain":
			combo_steps = ["sweep", "whirl"]
		"summon_chain":
			combo_steps = ["sweep", "summon"]
		"three_thrust_chain":
			combo_steps = ["sweep", "three_thrust"]
		"arrow_rain_chain":
			combo_steps = ["sweep", "arrow_rain"]
		_:
			combo_steps = ["sweep", "sweep"]

func _queue_zhang_he_close_action() -> void:
	var whirl_chance := CLOSE_QUARTERS_WHIRL_CHANCE
	if _player_is_stationary():
		whirl_chance += 0.18
	if player_is_attacking:
		whirl_chance += 0.16
	if phase >= 2 and high_risk_skill_allowed and _is_action_ready("whirl") and randf() < whirl_chance:
		combo_steps = ["whirl"]
		return
	combo_steps = ["sweep"]

func _is_zhang_he_in_close_quarters(player_position: Vector2) -> bool:
	return absf(player_position.x - position.x) < IDEAL_ENGAGE_MIN_RANGE

func _prepare_counterattack_for(action: String) -> void:
	counterattack_action_multiplier = 1.0
	if not has_counterattack() or not _is_counterattack_eligible(action):
		return
	counterattack_action_multiplier = COUNTERATTACK_DAMAGE_MULTIPLIER
	counterattack_remaining = 0.0

func _is_counterattack_eligible(action: String) -> bool:
	return action in ["sweep", "thrust", "pursuit", "command_sweep", "command_thrust"]

func _is_special_action(action: String) -> bool:
	return action in ["pursuit", "spear_wall", "whirl", "three_thrust", "arrow_rain", "summon", "fire_charge", "fire_lines"]

func _is_high_risk_action(action: String) -> bool:
	return action in ["pursuit", "spear_wall", "whirl", "three_thrust", "arrow_rain", "fire_charge", "fire_lines"]

func _is_action_ready(action: String) -> bool:
	return float(action_cooldowns.get(action, 0.0)) <= 0.0

func _start_action_cooldown(action: String) -> void:
	var duration := _action_cooldown_duration(action)
	if duration > 0.0:
		action_cooldowns[action] = duration

func _action_cooldown_duration(action: String) -> float:
	match action:
		"pursuit": return PURSUIT_COOLDOWN
		"spear_wall": return SPEAR_WALL_COOLDOWN
		"whirl": return WHIRL_COOLDOWN
		"three_thrust": return THREE_THRUST_COOLDOWN
		"summon": return SUMMON_COOLDOWN
		"fire_charge": return FIRE_CHARGE_COOLDOWN
		"fire_lines": return FIRE_LINES_COOLDOWN
		"arrow_rain": return ARROW_RAIN_COOLDOWN
		_: return 0.0

func _tick_action_cooldowns(delta: float) -> void:
	for action in action_cooldowns.keys():
		var remaining := maxf(0.0, float(action_cooldowns[action]) - delta)
		if remaining <= 0.0:
			action_cooldowns.erase(action)
		else:
			action_cooldowns[action] = remaining

func _finish_windup() -> void:
	if not thrust_sequence.is_empty():
		var angle: float = float(thrust_sequence.pop_front())
		facing_direction = thrust_sequence_direction
		_emit_unblockable_telegraph(Telegraph.line(position, facing_direction.rotated(angle), 300.0, 36.0, 0.34, _threat_damage(16.0), "boss"))
		state_timer = 0.34
		_emit_skill_impact()
		return
	if pending_dash_active:
		_emit_skill_impact()
		_begin_dash()
		return
	cast_invulnerable = false
	_emit_skill_impact()
	_enter_recovery(pending_recovery)

func _enter_recovery(duration: float) -> void:
	state = State.RECOVER
	state_timer = duration
	moving = false

func _begin_dash() -> void:
	dash_target = _clamp_to_movement_bounds(pending_dash_target)
	dash_recovery = pending_dash_recovery
	state = State.DASH
	state_timer = maxf(0.01, pending_dash_duration)
	dash_speed = position.distance_to(dash_target) / state_timer
	pending_dash_active = false
	moving = true

func _tick_dash(delta: float) -> void:
	position = _clamp_to_movement_bounds(position.move_toward(dash_target, dash_speed * delta))
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0 and position.distance_squared_to(dash_target) > 1.0:
		return
	position = _clamp_to_movement_bounds(dash_target)
	_enter_recovery(dash_recovery)

func _track_player_motion(delta: float, player_position: Vector2) -> void:
	if has_player_position:
		var instantaneous_velocity := (player_position - last_player_position) / maxf(0.001, delta)
		player_velocity = player_velocity.lerp(instantaneous_velocity.limit_length(260.0), 0.55)
	else:
		has_player_position = true
	last_player_position = player_position

func _predicted_player_position(lead_time: float) -> Vector2:
	return last_player_position + player_velocity.limit_length(230.0) * lead_time

func _clamp_to_movement_bounds(candidate: Vector2) -> Vector2:
	if not has_movement_bounds:
		return candidate
	return Vector2(
		clampf(candidate.x, movement_bounds.position.x, movement_bounds.end.x),
		clampf(candidate.y, movement_bounds.position.y, movement_bounds.end.y)
	)

func _direction_to(target: Vector2) -> Vector2:
	var direction := target - position
	if direction.length_squared() <= 0.01:
		return facing_direction
	return direction.normalized()

func _horizontal_direction_to(target: Vector2) -> Vector2:
	if absf(target.x - position.x) <= 0.01:
		return Vector2.LEFT if facing_direction.x < 0.0 else Vector2.RIGHT
	return Vector2.LEFT if target.x < position.x else Vector2.RIGHT

func _emit_skill_impact() -> void:
	if pending_shake_strength <= 0.0:
		return
	skill_impact_requested.emit(pending_shake_strength)
	pending_shake_strength = 0.0

func _emit_attack_telegraph(telegraph: Telegraph, clash_kind: Telegraph.ClashKind = Telegraph.ClashKind.NONE) -> void:
	telegraph.clash_kind = clash_kind
	telegraph.clashable = clash_kind != Telegraph.ClashKind.NONE
	telegraph.threat_kind = Telegraph.ThreatKind.ACTIVE if clash_kind == Telegraph.ClashKind.ACTIVE else Telegraph.ThreatKind.BASIC
	telegraph_requested.emit(telegraph)

func _emit_unblockable_telegraph(telegraph: Telegraph) -> void:
	telegraph.threat_kind = Telegraph.ThreatKind.UNBLOCKABLE
	telegraph_requested.emit(telegraph)

func _threat_damage(base_damage: float) -> float:
	return base_damage * float(THREAT_DAMAGE_MULTIPLIERS[threat_tier]) * counterattack_action_multiplier

func _on_died() -> void:
	active = false
	dying = true
	death_animation_elapsed = 0.0
	moving = false
	pending_dash_active = false
	thrust_sequence_direction = facing_direction
	thrust_sequence.clear()
	combo_steps.clear()
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
