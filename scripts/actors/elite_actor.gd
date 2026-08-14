class_name EliteActor
extends Node2D

signal telegraph_requested(telegraph: Telegraph)
signal skill_impact_requested(strength: float)
signal defeated(elite: EliteActor)

enum Archetype { XIAHOU_EN, CHUNYU_DAO, XIAHOU_LAN, HAN_HAO }
enum State { INACTIVE, APPROACH, WINDUP, DASH, RECOVER, REPOSITION }

const HEALTH_LAYER_CAPACITY := 65.0
const XIAHOU_EN_DEATH_ANIMATION_DURATION := 0.56
const CHUNYU_DAO_DEATH_ANIMATION_DURATION := 0.62
const XIAHOU_LAN_DEATH_ANIMATION_DURATION := 0.58
const HAN_HAO_DEATH_ANIMATION_DURATION := 0.68
const ENGAGE_DELAY := 0.24
const XIAHOU_EN_BASE_HEALTH := 960.0
const CHUNYU_DAO_BASE_HEALTH := 920.0
const XIAHOU_LAN_BASE_HEALTH := 1020.0
const HAN_HAO_BASE_HEALTH := 1100.0
const XIAHOU_EN_BASE_ARMOR := 25.0
const CHUNYU_DAO_BASE_ARMOR := 21.0
const XIAHOU_LAN_BASE_ARMOR := 23.0
const HAN_HAO_BASE_ARMOR := 30.0
const THREAT_HEALTH_MULTIPLIERS := [1.0, 1.35, 1.80, 2.35, 3.00]
const THREAT_DAMAGE_MULTIPLIERS := [1.0, 1.12, 1.28, 1.48, 1.72]
const XIAHOU_EN_APPROACH_SPEED := 92.0
const CHUNYU_DAO_APPROACH_SPEED := 102.0
const XIAHOU_LAN_APPROACH_SPEED := 108.0
const HAN_HAO_APPROACH_SPEED := 78.0
const STANCE_MAX := 100.0
const STANCE_BREAK_DURATION := 3.9
const STANCE_BREAK_DAMAGE_MULTIPLIER := 1.10
const STANCE_BREAK_KNOCKBACK_BUDGET := 110.0
const STANCE_BREAK_MAX_HIT_KNOCKBACK := 45.0
const STANCE_BREAK_RECOIL_DURATION := 0.18
const DRAG_COOLDOWN := 2.4
const LUNGE_COOLDOWN := 4.4
const EXECUTE_COOLDOWN := 3.8
const RUPTURE_COOLDOWN := 5.2
const SCOUT_LUNGE_COOLDOWN := 5.8
const SHIELD_PUSH_COOLDOWN := 6.6
const EARTH_BLADE_COOLDOWN := 9.2
const OIL_FIRE_COOLDOWN := 10.5
const COUNTERATTACK_DURATION := 4.0
const COUNTERATTACK_DAMAGE_MULTIPLIER := 1.30
const REPOSITION_COOLDOWN := 2.8
const REPOSITION_DURATION := 0.42
const REPOSITION_SPEED := 176.0
const PLAYER_STATIONARY_SPEED := 34.0

@onready var health_component: HealthComponent = %HealthComponent

var archetype: Archetype = Archetype.XIAHOU_EN
var active := false
var state: State = State.INACTIVE
var state_timer := 0.0
var action_index := 0
var current_direction := Vector2.DOWN
var queued_followup := ""
var hurt_remaining := 0.0
var knockback_visual_remaining := 0.0
var knockback_visual_duration := 0.0
var knockback_visual_displacement := 0.0
var knockback_visual_direction := Vector2.RIGHT
var knockback_visual_intensity := 0.0
var telegraph_source := ""
var moving := false
var attack_animation_elapsed := 0.0
var dying := false
var death_animation_elapsed := 0.0
var threat_tier := 0
var last_player_position := Vector2.ZERO
var player_velocity := Vector2.ZERO
var has_player_position := false
var pending_dash_target := Vector2.ZERO
var pending_dash_duration := 0.0
var pending_dash_recovery := 0.0
var dash_target := Vector2.ZERO
var dash_speed := 0.0
var dash_recovery := 0.0
var pending_shake_strength := 0.0
var stance := STANCE_MAX
var stance_break_remaining := 0.0
var stance_knockback_remaining := 0.0
var current_action := ""
var action_cooldowns: Dictionary = {}
var high_risk_skill_allowed := true
var cast_invulnerable := false
var combo_steps: Array[String] = []
var last_combo_id := ""
var counterattack_remaining := 0.0
var counterattack_action_multiplier := 1.0
var slow_remaining := 0.0
var slow_multiplier := 1.0
var tactical_reposition_cooldown := 0.0
var reposition_target := Vector2.ZERO
var player_is_attacking := false
var navigation_waypoint := Vector2.ZERO

func _ready() -> void:
	health_component.died.connect(_on_died)
	visible = false

func activate(new_archetype: Archetype, at: Vector2, new_threat_tier: int = 0) -> void:
	archetype = new_archetype
	threat_tier = clampi(new_threat_tier, 0, THREAT_HEALTH_MULTIPLIERS.size() - 1)
	position = at
	active = true
	visible = false
	state = State.APPROACH
	state_timer = ENGAGE_DELAY
	action_index = 0
	queued_followup = ""
	hurt_remaining = 0.0
	knockback_visual_remaining = 0.0
	knockback_visual_duration = 0.0
	knockback_visual_displacement = 0.0
	knockback_visual_direction = Vector2.RIGHT
	knockback_visual_intensity = 0.0
	moving = false
	attack_animation_elapsed = 0.0
	dying = false
	death_animation_elapsed = 0.0
	telegraph_source = "elite:%d" % get_instance_id()
	last_player_position = at
	player_velocity = Vector2.ZERO
	has_player_position = false
	player_is_attacking = false
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	dash_target = Vector2.ZERO
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_shake_strength = 0.0
	cast_invulnerable = false
	stance = STANCE_MAX
	stance_break_remaining = 0.0
	stance_knockback_remaining = 0.0
	current_action = ""
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
	navigation_waypoint = Vector2.ZERO
	health_component.reset(max_health())

func set_navigation_waypoint(value: Vector2) -> void:
	navigation_waypoint = value

func tick(delta: float, player_position: Vector2, player_attacking: bool = false) -> void:
	if dying:
		death_animation_elapsed += delta
		if death_animation_elapsed >= death_animation_duration():
			dying = false
			defeated.emit(self)
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
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	knockback_visual_remaining = maxf(0.0, knockback_visual_remaining - delta)
	var was_stance_broken := stance_break_remaining > 0.0
	stance_break_remaining = maxf(0.0, stance_break_remaining - delta)
	if was_stance_broken and stance_break_remaining <= 0.0:
		stance = STANCE_MAX
		stance_knockback_remaining = 0.0
	if state == State.WINDUP:
		attack_animation_elapsed += delta
	match state:
		State.APPROACH:
			if _approach_player(delta, player_position):
				state_timer = maxf(0.0, state_timer - delta)
				if state_timer <= 0.0:
					_issue_next_action(player_position)
			else:
				state_timer = ENGAGE_DELAY
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
			position = position.move_toward(reposition_target, REPOSITION_SPEED * slow_multiplier * delta)
			moving = position.distance_squared_to(reposition_target) > 4.0
			if state_timer <= 0.0 or not moving:
				state = State.APPROACH
				state_timer = ENGAGE_DELAY
				moving = false

func freeze_for_cinematic() -> void:
	if not active or dying:
		return
	state = State.APPROACH
	state_timer = 0.0
	action_index = 0
	queued_followup = ""
	moving = false
	attack_animation_elapsed = 0.0
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	dash_target = position
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_shake_strength = 0.0
	cast_invulnerable = false
	current_action = ""
	hurt_remaining = 0.0
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
	hurt_remaining = 0.14
	return {"damage": health_component.take_damage(actual), "stance_broken": false}

func apply_slow(multiplier: float, duration: float) -> void:
	if not active or duration <= 0.0:
		return
	slow_remaining = maxf(slow_remaining, duration)
	slow_multiplier = minf(slow_multiplier, clampf(multiplier, 0.35, 1.0))

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
	var scaled_force := maxf(force * 0.14, forced_displacement * 0.62)
	var displacement := clampf(scaled_force, 9.0, STANCE_BREAK_MAX_HIT_KNOCKBACK)
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
	var displacement := clampf(maxf(force * 0.035, forced_displacement * 0.38), 3.0, 14.0)
	var normalized_direction := direction.normalized()
	position += normalized_direction * displacement
	knockback_visual_direction = normalized_direction
	knockback_visual_displacement = displacement
	knockback_visual_duration = 0.13
	knockback_visual_remaining = knockback_visual_duration
	knockback_visual_intensity = clampf(displacement / 14.0, 0.25, 0.70)
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
	queued_followup = ""
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	dash_target = position
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_shake_strength = 0.0
	current_action = ""
	attack_animation_elapsed = 0.0
	moving = false
	state = State.APPROACH
	state_timer = ENGAGE_DELAY
	return true

func stance_ratio() -> float:
	return stance / STANCE_MAX

func is_stance_broken() -> bool:
	return active and stance_break_remaining > 0.0

func health_ratio() -> float:
	return health_component.current / maxf(1.0, health_component.maximum)

func max_health() -> float:
	var base_health := XIAHOU_EN_BASE_HEALTH
	match archetype:
		Archetype.CHUNYU_DAO:
			base_health = CHUNYU_DAO_BASE_HEALTH
		Archetype.XIAHOU_LAN:
			base_health = XIAHOU_LAN_BASE_HEALTH
		Archetype.HAN_HAO:
			base_health = HAN_HAO_BASE_HEALTH
	return base_health * float(THREAT_HEALTH_MULTIPLIERS[threat_tier])

func armor() -> float:
	var base_armor := XIAHOU_EN_BASE_ARMOR
	match archetype:
		Archetype.CHUNYU_DAO:
			base_armor = CHUNYU_DAO_BASE_ARMOR
		Archetype.XIAHOU_LAN:
			base_armor = XIAHOU_LAN_BASE_ARMOR
		Archetype.HAN_HAO:
			base_armor = HAN_HAO_BASE_ARMOR
	return base_armor + float(threat_tier) * 2.0

func display_name() -> String:
	match archetype:
		Archetype.XIAHOU_EN: return "夏侯恩"
		Archetype.CHUNYU_DAO: return "淳于导"
		Archetype.XIAHOU_LAN: return "夏侯兰"
		Archetype.HAN_HAO: return "韩浩"
	return "夏侯恩"

func weapon_title() -> String:
	match archetype:
		Archetype.XIAHOU_EN: return "偃月刀"
		Archetype.CHUNYU_DAO: return "大砍刀"
		Archetype.XIAHOU_LAN: return "长枪"
		Archetype.HAN_HAO: return "盾刀"
	return "偃月刀"

func hud_color() -> Color:
	match archetype:
		Archetype.XIAHOU_EN: return Color("d64e32")
		Archetype.CHUNYU_DAO: return Color("d07a32")
		Archetype.XIAHOU_LAN: return Color("d88d3b")
		Archetype.HAN_HAO: return Color("b86542")
	return Color("d64e32")

func is_recovering() -> bool:
	return active and state == State.RECOVER

func is_moving() -> bool:
	return active and moving

func set_high_risk_skill_allowed(value: bool) -> void:
	high_risk_skill_allowed = value

func _player_is_stationary() -> bool:
	return player_velocity.length() <= PLAYER_STATIONARY_SPEED

func _should_reposition_after_combo(player_position: Vector2) -> bool:
	if not combo_steps.is_empty() or tactical_reposition_cooldown > 0.0:
		return false
	var distance := position.distance_to(player_position)
	if distance > 260.0:
		return false
	var chance := 0.22
	if _player_is_stationary():
		chance += 0.24
	if player_is_attacking:
		chance += 0.22
	if distance < 132.0:
		chance += 0.10
	return randf() < chance

func _begin_reposition(player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length_squared() <= 0.01:
		to_player = current_direction
	var radial := to_player.normalized()
	var lateral := Vector2(-radial.y, radial.x)
	var side := -1.0 if (action_index + int(get_instance_id())) % 2 == 0 else 1.0
	var radial_offset := -24.0 if _player_is_stationary() else 18.0
	if player_is_attacking:
		radial_offset += 18.0
	reposition_target = position + lateral * side * 68.0 + radial * radial_offset
	tactical_reposition_cooldown = REPOSITION_COOLDOWN
	state = State.REPOSITION
	state_timer = REPOSITION_DURATION
	moving = true
	action_index += 1

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

func is_dying() -> bool:
	return dying

func attack_animation_progress() -> float:
	if state != State.WINDUP or state_timer <= 0.0:
		return 1.0
	return clampf(attack_animation_elapsed / maxf(0.01, attack_animation_elapsed + state_timer), 0.0, 1.0)

func death_animation_progress() -> float:
	return clampf(death_animation_elapsed / death_animation_duration(), 0.0, 1.0)

func death_animation_duration() -> float:
	match archetype:
		Archetype.XIAHOU_EN: return XIAHOU_EN_DEATH_ANIMATION_DURATION
		Archetype.CHUNYU_DAO: return CHUNYU_DAO_DEATH_ANIMATION_DURATION
		Archetype.XIAHOU_LAN: return XIAHOU_LAN_DEATH_ANIMATION_DURATION
		Archetype.HAN_HAO: return HAN_HAO_DEATH_ANIMATION_DURATION
	return XIAHOU_EN_DEATH_ANIMATION_DURATION

func _approach_player(delta: float, player_position: Vector2) -> bool:
	moving = false
	var to_player := player_position - position
	var desired_range := 142.0
	var approach_speed := XIAHOU_EN_APPROACH_SPEED
	match archetype:
		Archetype.CHUNYU_DAO:
			desired_range = 118.0
			approach_speed = CHUNYU_DAO_APPROACH_SPEED
		Archetype.XIAHOU_LAN:
			desired_range = 138.0
			approach_speed = XIAHOU_LAN_APPROACH_SPEED
		Archetype.HAN_HAO:
			desired_range = 94.0
			approach_speed = HAN_HAO_APPROACH_SPEED
	if navigation_waypoint.length_squared() > 0.01:
		var to_waypoint := navigation_waypoint - position
		if to_waypoint.length() > 14.0:
			current_direction = to_waypoint.normalized()
			position += current_direction * approach_speed * slow_multiplier * delta
			moving = true
			return false
		navigation_waypoint = Vector2.ZERO
	if to_player.length() > desired_range:
		var movement_target := navigation_waypoint if navigation_waypoint.length_squared() > 0.01 else player_position
		var movement_direction := movement_target - position
		if movement_direction.length_squared() > 0.01:
			current_direction = movement_direction.normalized()
			position += current_direction * approach_speed * slow_multiplier * delta
		moving = true
		return false
	return true

func _issue_next_action(player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length_squared() > 0.01:
		current_direction = _horizontal_direction_to(player_position) if _uses_horizontal_attack_profile() else to_player.normalized()
	if combo_steps.is_empty():
		_queue_next_combo()
	var action: String = str(combo_steps.pop_front())
	_start_action_cooldown(action)
	_prepare_counterattack_for(action)
	current_action = action
	state = State.WINDUP
	queued_followup = ""
	moving = false
	attack_animation_elapsed = 0.0
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_shake_strength = 0.0
	match action:
		"sweep":
			_emit_attack_telegraph(Telegraph.fan(position, current_direction, 178.0, deg_to_rad(150.0), 0.85, _threat_damage(20.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.85
			queued_followup = "recover:0.68"
			pending_shake_strength = 5.5
		"drag":
			_emit_attack_telegraph(Telegraph.fan(position + current_direction * 18.0, current_direction, 192.0, deg_to_rad(128.0), 0.76, _threat_damage(22.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.76
			queued_followup = "recover:0.74"
			pending_shake_strength = 6.2
		"lunge":
			var predicted := _predicted_player_position(0.24)
			current_direction = _direction_to(predicted)
			var dash_distance := clampf(position.distance_to(predicted) - 52.0, 92.0, 228.0)
			pending_dash_target = position + current_direction * dash_distance
			pending_dash_duration = 0.16
			pending_dash_recovery = 0.58
			_emit_attack_telegraph(Telegraph.line(position, current_direction, dash_distance + 68.0, 66.0, 0.40, _threat_damage(30.0), telegraph_source), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.40
			queued_followup = "dash"
			pending_shake_strength = 8.0
		"crush":
			_emit_attack_telegraph(Telegraph.line(position, current_direction, 232.0, 42.0, 0.90, _threat_damage(24.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.90
			queued_followup = "recover:0.82"
			pending_shake_strength = 6.5
		"execute":
			_emit_attack_telegraph(Telegraph.fan(position, current_direction, 122.0, deg_to_rad(82.0), 0.52, _threat_damage(15.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.52
			queued_followup = "execute_followup"
			pending_shake_strength = 5.2
		"rupture":
			current_direction = _direction_to(_predicted_player_position(0.20))
			var rupture_distance := clampf(position.distance_to(_predicted_player_position(0.20)) - 48.0, 74.0, 168.0)
			pending_dash_target = position + current_direction * rupture_distance
			pending_dash_duration = 0.30
			pending_dash_recovery = 0.76
			_emit_attack_telegraph(Telegraph.line(position, current_direction, rupture_distance + 82.0, 82.0, 0.70, _threat_damage(31.0), telegraph_source), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.70
			queued_followup = "dash"
			pending_shake_strength = 7.8
		"probe":
			_emit_attack_telegraph(Telegraph.line(position, current_direction, 184.0, 34.0, 0.58, _threat_damage(18.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.58
			queued_followup = "recover:0.42"
			pending_shake_strength = 4.8
		"lan_sweep":
			_emit_attack_telegraph(Telegraph.fan(position + current_direction * 10.0, current_direction, 138.0, deg_to_rad(104.0), 0.66, _threat_damage(20.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.66
			queued_followup = "recover:0.54"
			pending_shake_strength = 5.2
		"scout_lunge":
			var predicted_position := _predicted_player_position(0.24)
			current_direction = _horizontal_direction_to(predicted_position)
			var scout_distance := clampf(absf(predicted_position.x - position.x) - 52.0, 78.0, 176.0)
			pending_dash_target = position + current_direction * scout_distance
			pending_dash_duration = 0.42
			pending_dash_recovery = 0.72
			_emit_attack_telegraph(Telegraph.line(position, current_direction, scout_distance + 74.0, 58.0, 0.58, _threat_damage(29.0), telegraph_source), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.58
			queued_followup = "dash"
			pending_shake_strength = 7.2
		"shield_bash":
			_emit_attack_telegraph(Telegraph.fan(position + current_direction * 8.0, current_direction, 92.0, deg_to_rad(84.0), 0.64, _threat_damage(22.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.64
			queued_followup = "recover:0.46"
			pending_shake_strength = 5.8
		"shield_slash":
			_emit_attack_telegraph(Telegraph.fan(position + current_direction * 8.0, current_direction, 132.0, deg_to_rad(108.0), 0.72, _threat_damage(25.0), telegraph_source), Telegraph.ClashKind.BASIC)
			state_timer = 0.72
			queued_followup = "recover:0.66"
			pending_shake_strength = 6.4
		"shield_push":
			var push_distance := clampf(absf(player_position.x - position.x) - 38.0, 96.0, 148.0)
			pending_dash_target = position + current_direction * push_distance
			pending_dash_duration = 0.72
			pending_dash_recovery = 0.84
			_emit_attack_telegraph(Telegraph.line(position, current_direction, push_distance + 78.0, 78.0, 0.76, _threat_damage(32.0), telegraph_source), Telegraph.ClashKind.ACTIVE)
			state_timer = 0.76
			queued_followup = "dash"
			pending_shake_strength = 8.4
		"earth_blade":
			cast_invulnerable = true
			var blade_target := _predicted_player_position(0.34)
			var blade_direction := _direction_to(blade_target)
			var blade_perpendicular := Vector2(-blade_direction.y, blade_direction.x)
			for lane_offset in [-24.0, 24.0]:
				var blade_telegraph := Telegraph.line(position + blade_perpendicular * lane_offset, blade_direction, 318.0, 38.0, 0.98, _threat_damage(30.0), telegraph_source)
				blade_telegraph.visual_kind = "earth_blade"
				_emit_unblockable_telegraph(blade_telegraph)
			state_timer = 0.98
			queued_followup = "recover:0.78"
			pending_shake_strength = 9.0
		"oil_fire":
			cast_invulnerable = true
			var oil_target := _predicted_player_position(0.32)
			var oil_direction := _direction_to(oil_target)
			var oil_perpendicular := Vector2(-oil_direction.y, oil_direction.x)
			for index in range(3):
				var oil_center := oil_target + oil_perpendicular * (float(index) - 1.0) * 62.0
				var oil_telegraph := Telegraph.circle(oil_center, 46.0, 1.04 + float(index) * 0.10, _threat_damage(25.0), telegraph_source)
				oil_telegraph.visual_kind = "oil_fire"
				_emit_unblockable_telegraph(oil_telegraph)
			state_timer = 1.24
			queued_followup = "recover:0.86"
			pending_shake_strength = 8.8

func _queue_next_combo() -> void:
	var options: Array[String] = []
	match archetype:
		Archetype.XIAHOU_EN:
			options.append("moon_sweep")
			if _is_action_ready("earth_blade") and high_risk_skill_allowed:
				options.append("earth_blade_chain")
				if _player_is_stationary() or player_is_attacking:
					options.append("earth_blade_chain")
			if _is_action_ready("drag"):
				options.append("drag_chain")
			if _is_action_ready("lunge") and high_risk_skill_allowed:
				options.append("lunge_chain")
				if _player_is_stationary() or player_is_attacking:
					options.append("lunge_chain")
		Archetype.CHUNYU_DAO:
			options.append("cleave_chain")
			if _is_action_ready("oil_fire") and high_risk_skill_allowed:
				options.append("oil_fire_chain")
				if _player_is_stationary() or player_is_attacking:
					options.append("oil_fire_chain")
			if _is_action_ready("execute") and high_risk_skill_allowed:
				options.append("execute_chain")
				if player_is_attacking:
					options.append("execute_chain")
			if _is_action_ready("rupture") and high_risk_skill_allowed:
				options.append("rupture_chain")
				if _player_is_stationary() or player_is_attacking:
					options.append("rupture_chain")
		Archetype.XIAHOU_LAN:
			options.append("lan_patrol_chain")
			if _is_action_ready("scout_lunge") and high_risk_skill_allowed:
				options.append("lan_lunge_chain")
				if _player_is_stationary() or player_velocity.length() > PLAYER_STATIONARY_SPEED * 2.0:
					options.append("lan_lunge_chain")
		Archetype.HAN_HAO:
			options.append("shield_press_chain")
			if _is_action_ready("shield_push") and high_risk_skill_allowed:
				options.append("shield_push_chain")
				if _player_is_stationary() or player_is_attacking:
					options.append("shield_push_chain")
	if options.size() > 1 and options.has(last_combo_id):
		options.erase(last_combo_id)
	var combo_id: String = str(options.pick_random())
	last_combo_id = combo_id
	match combo_id:
		"drag_chain":
			combo_steps = ["sweep", "drag"]
		"lunge_chain":
			combo_steps = ["sweep", "lunge"]
		"execute_chain":
			combo_steps = ["crush", "execute"]
		"rupture_chain":
			combo_steps = ["crush", "rupture"]
		"moon_sweep":
			combo_steps = ["sweep", "sweep"]
		"lan_patrol_chain":
			combo_steps = ["probe", "lan_sweep", "probe"]
		"lan_lunge_chain":
			combo_steps = ["probe", "scout_lunge"]
		"shield_press_chain":
			combo_steps = ["shield_bash", "shield_slash"]
		"shield_push_chain":
			combo_steps = ["shield_bash", "shield_push"]
		"earth_blade_chain":
			combo_steps = ["earth_blade"]
		"oil_fire_chain":
			combo_steps = ["oil_fire"]
		_:
			combo_steps = ["crush", "crush"]

func _prepare_counterattack_for(action: String) -> void:
	counterattack_action_multiplier = 1.0
	if not has_counterattack() or not _is_counterattack_eligible(action):
		return
	counterattack_action_multiplier = COUNTERATTACK_DAMAGE_MULTIPLIER
	counterattack_remaining = 0.0

func _is_counterattack_eligible(action: String) -> bool:
	return action in ["sweep", "drag", "lunge", "crush", "execute", "rupture", "probe", "lan_sweep", "shield_bash", "shield_slash"]

func _is_special_action(action: String) -> bool:
	return action in ["drag", "lunge", "execute", "rupture", "scout_lunge", "shield_push", "earth_blade", "oil_fire"]

func _is_high_risk_action(action: String) -> bool:
	return action in ["lunge", "execute", "rupture", "scout_lunge", "shield_push", "earth_blade", "oil_fire"]

func _is_action_ready(action: String) -> bool:
	return float(action_cooldowns.get(action, 0.0)) <= 0.0

func _start_action_cooldown(action: String) -> void:
	var duration := _action_cooldown_duration(action)
	if duration > 0.0:
		action_cooldowns[action] = duration

func _action_cooldown_duration(action: String) -> float:
	match action:
		"drag": return DRAG_COOLDOWN
		"lunge": return LUNGE_COOLDOWN
		"execute": return EXECUTE_COOLDOWN
		"rupture": return RUPTURE_COOLDOWN
		"scout_lunge": return SCOUT_LUNGE_COOLDOWN
		"shield_push": return SHIELD_PUSH_COOLDOWN
		"earth_blade": return EARTH_BLADE_COOLDOWN
		"oil_fire": return OIL_FIRE_COOLDOWN
		_: return 0.0

func _tick_action_cooldowns(delta: float) -> void:
	for action in action_cooldowns.keys():
		var remaining := maxf(0.0, float(action_cooldowns[action]) - delta)
		if remaining <= 0.0:
			action_cooldowns.erase(action)
		else:
			action_cooldowns[action] = remaining

func _finish_windup() -> void:
	if queued_followup == "dash":
		_emit_skill_impact()
		_begin_dash()
		return
	if queued_followup == "execute_followup":
		cast_invulnerable = false
		_emit_skill_impact()
		_emit_attack_telegraph(Telegraph.fan(position, current_direction, 142.0, deg_to_rad(118.0), 0.50, _threat_damage(18.0), telegraph_source), Telegraph.ClashKind.BASIC)
		state_timer = 0.50
		queued_followup = "recover:0.58"
		pending_shake_strength = 6.0
		return
	cast_invulnerable = false
	_emit_skill_impact()
	var recovery := 0.55
	if queued_followup.begins_with("recover:"):
		recovery = float(queued_followup.trim_prefix("recover:"))
	state = State.RECOVER
	state_timer = recovery
	queued_followup = ""
	moving = false

func _begin_dash() -> void:
	dash_target = pending_dash_target
	dash_recovery = pending_dash_recovery
	state = State.DASH
	state_timer = maxf(0.01, pending_dash_duration)
	dash_speed = position.distance_to(dash_target) / state_timer
	queued_followup = ""
	moving = true

func _tick_dash(delta: float) -> void:
	position = position.move_toward(dash_target, dash_speed * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0 and position.distance_squared_to(dash_target) > 1.0:
		return
	position = dash_target
	moving = false
	state = State.RECOVER
	state_timer = dash_recovery

func _track_player_motion(delta: float, player_position: Vector2) -> void:
	if has_player_position:
		var instantaneous_velocity := (player_position - last_player_position) / maxf(0.001, delta)
		player_velocity = player_velocity.lerp(instantaneous_velocity.limit_length(260.0), 0.55)
	else:
		has_player_position = true
	last_player_position = player_position

func _predicted_player_position(lead_time: float) -> Vector2:
	return last_player_position + player_velocity.limit_length(220.0) * lead_time

func _direction_to(target: Vector2) -> Vector2:
	var direction := target - position
	if direction.length_squared() <= 0.01:
		return current_direction
	return direction.normalized()

func _horizontal_direction_to(target: Vector2) -> Vector2:
	if absf(target.x - position.x) <= 0.01:
		return Vector2.LEFT if current_direction.x < 0.0 else Vector2.RIGHT
	return Vector2.LEFT if target.x < position.x else Vector2.RIGHT

func _uses_horizontal_attack_profile() -> bool:
	return archetype == Archetype.XIAHOU_LAN or archetype == Archetype.HAN_HAO

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
	if not active:
		return
	active = false
	visible = false
	state = State.INACTIVE
	moving = false
	attack_animation_elapsed = 0.0
	current_action = ""
	combo_steps.clear()
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
	dying = true
	death_animation_elapsed = 0.0
