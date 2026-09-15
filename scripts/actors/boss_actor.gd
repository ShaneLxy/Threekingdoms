class_name BossActor
extends Node2D

signal telegraph_requested(telegraph: Telegraph)
signal summon_requested(phase: int)
signal phase_changed(phase: int)
signal skill_impact_requested(strength: float)
signal rush_started(at: Vector2, direction: Vector2, segment: int)
signal defeated()
signal attack_effect_requested(effect_type: String, at: Vector2, scale_multiplier: float)
signal attack_sound_requested(sound_type: String)

enum State { APPROACH, WINDUP, DASH, RECOVER, VULNERABLE, PHASE_TRANSITION, REPOSITION, ULTIMATE_AIRBORNE, ULTIMATE_LANDING }
enum Archetype { ZHANG_HE, XIAHOU_DUN, LV_BU }

const HEALTH_LAYER_CAPACITY := 750.0
const BOSS_ENERGY_DAMAGE_PER_POINT := 50.0
const BOSS_ENERGY_PER_PHASE_CAP := 10.0
const ENGAGE_DELAY := 0.24
const BASE_HEALTH := 3600.0
const BASE_ARMOR := 24.0
const XIAHOU_DUN_BASE_HEALTH := 4400.0
const XIAHOU_DUN_BASE_ARMOR := 28.0
const XIAHOU_DUN_MOVE_SPEED := 88.0
const LV_BU_BASE_HEALTH := 4650.0
const LV_BU_BASE_ARMOR := 36.0
const LV_BU_MOVE_SPEED := 150.0
const LV_BU_PHASE_MOVE_SPEED_BONUS := 15.0
const THREAT_HEALTH_MULTIPLIERS := [1.0, 1.35, 1.80, 2.35, 3.00]
const THREAT_DAMAGE_MULTIPLIERS := [1.0, 1.12, 1.28, 1.48, 1.72]
const STANCE_MAX := 120.0
const LV_BU_STANCE_MAX := 130.0
const STANCE_BREAK_DURATION := 4.8
const STANCE_BREAK_DAMAGE_MULTIPLIER := 1.40
const STANCE_BREAK_MAX_HIT_KNOCKBACK := 32.0
const STANCE_BREAK_RECOIL_DURATION := 0.20
const GUARD_REACTION_DISTANCE := 110.0
const PERFECT_GUARD_REACTION_DISTANCE := 210.0
const GUARD_REACTION_DURATION := 1.0
const PERFECT_GUARD_REACTION_DURATION := 2.0
const DEATH_ANIMATION_DURATION := 0.64
const PURSUIT_COOLDOWN := 7.5
const PURSUIT_DASH_DURATION := 0.45
const PURSUIT_DASH_RECOVERY := 0.78
const ZHANG_HE_RUSH_SEGMENT_COUNT := 3
const ZHANG_HE_RUSH_SEGMENT_WINDUP := 0.46
const ZHANG_HE_RUSH_FOLLOWUP_WINDUP := 0.16
const ZHANG_HE_RUSH_SEGMENT_DURATION := 0.22
const ZHANG_HE_RUSH_SEGMENT_GAP := 0.10
const ZHANG_HE_RUSH_RECOVERY := 0.74
const ZHANG_HE_RUSH_DISTANCE := 84.0
const ZHANG_HE_JAB_WINDUP := 0.58
const ZHANG_HE_JAB_RECOVERY := 0.62
const ZHANG_HE_JAB_RANGE := 188.0
const ZHANG_HE_JAB_WIDTH := 32.0
const ZHANG_HE_RETURNING_SPEAR_COOLDOWN := 5.8
const ZHANG_HE_RETURNING_SPEAR_WINDUP := 0.86
const ZHANG_HE_RETURNING_SPEAR_RECOVERY := 0.82
const ZHANG_HE_PATROL_SPEED := 216.0
const ZHANG_HE_PATROL_DURATION := 1.05
const ZHANG_HE_PATROL_MIN_DISTANCE := 92.0
const ZHANG_HE_PATROL_MAX_DISTANCE := 410.0
const ZHANG_HE_CHASE_SPEED_THRESHOLD := 82.0
const WHIRL_COOLDOWN := 6.0
const THREE_THRUST_COOLDOWN := 7.0
const SUMMON_COOLDOWN := 8.0
const FIRE_CHARGE_COOLDOWN := 7.8
const FIRE_LINES_COOLDOWN := 9.6
const FLAME_SLASH_COMBO_COOLDOWN := 8.0
const FLAME_SLASH_COMBO_WINDUP := 0.6
const FLAME_SLASH_COMBO_WAVE_COUNT := 5
const FLAME_SLASH_COMBO_WAVE_INTERVAL := 0.2
const FLAME_SLASH_COMBO_WAVE_DISTANCE := 50.0
const FLAME_SLASH_COMBO_WAVE_WIDTH := 65.0
const FLAME_SLASH_COMBO_RECOVERY := 0.8
const FLAME_SLASH_COMBO_ANIMATION_DURATION := 1.4
const ARROW_RAIN_COOLDOWN := 9.8
const LV_BU_WHIRL_COOLDOWN := 7.2
const LV_BU_CHARGE_COOLDOWN := 6.4
const LV_BU_GLAIVE_RETURN_COOLDOWN := 8.6
const LV_BU_SLOW_SWEEP_COOLDOWN := 5.8
const LV_BU_RUSH_COOLDOWN := 8.4
const LV_BU_HIGH_RISK_INTERVAL := 8.0
const VULNERABLE_DEFAULT_STANCE_DAMAGE := 6.0
const LV_BU_VULNERABLE_DURATION := 3.0
const LV_BU_CHARGE_DURATION := 0.34
const LV_BU_CHARGE_WINDUP := 0.82
const LV_BU_CHARGE_RECOVERY := 1.32
const LV_BU_WHIRL_WINDUP := 1.12
const LV_BU_WHIRL_AIRBORNE_DURATION := 0.72
const LV_BU_WHIRL_LANDING_DURATION := 0.34
const LV_BU_WHIRL_TELEGRAPH_DURATION := LV_BU_WHIRL_WINDUP + LV_BU_WHIRL_AIRBORNE_DURATION + LV_BU_WHIRL_LANDING_DURATION
const LV_BU_WHIRL_RECOVERY := 1.42
const LV_BU_RETURN_OUTGOING_WINDUP := 0.42
const LV_BU_RETURN_BACKSWING_WINDUP := 0.58
const LV_BU_RETURN_RECOVERY := 1.24
const LV_BU_SLOW_SWEEP_WINDUP := 0.78
const LV_BU_SLOW_SWEEP_RECOVERY := 0.72
const LV_BU_SLOW_SWEEP_RANGE := 236.0
const LV_BU_SLOW_SWEEP_SLOW_MULTIPLIER := 0.58
const LV_BU_SLOW_SWEEP_SLOW_DURATION := 1.20
const LV_BU_CYCLONE_THRUST_COOLDOWN := 7.4
const LV_BU_CYCLONE_THRUST_SEGMENT_COUNT := 8
const LV_BU_CYCLONE_THRUST_INITIAL_DELAY := 0.18
const LV_BU_CYCLONE_THRUST_LAUNCH_INTERVAL := 0.24
const LV_BU_CYCLONE_THRUST_WINDUP := 0.52
const LV_BU_CYCLONE_THRUST_LENGTH := 326.0
const LV_BU_CYCLONE_THRUST_WIDTH := 42.0
const LV_BU_CYCLONE_THRUST_DAMAGE := 24.0
const LV_BU_RUSH_SEGMENT_WINDUP := 1.0
const LV_BU_RUSH_FOLLOWUP_WINDUP := 0.10
const LV_BU_RUSH_SEGMENT_DURATION := 0.36
const LV_BU_RUSH_SEGMENT_GAP := 0.5
const LV_BU_RUSH_RECOVERY := 0.88
const LV_BU_RUSH_DISTANCE := 116.0
const LV_BU_RUSH_SLOW_MULTIPLIER := 0.60
const LV_BU_RUSH_SLOW_DURATION := 3.0
const LV_BU_CHARGE_MIN_DISTANCE := 170.0
const LV_BU_CHARGE_MAX_DISTANCE := 250.0
const LV_BU_COMBO_LINK_RECOVERY := 0.10
const IDEAL_ENGAGE_MIN_RANGE := 126.0
const IDEAL_ENGAGE_MAX_RANGE := 194.0
const HORIZONTAL_LANE_TOLERANCE := 42.0
const CLOSE_QUARTERS_WHIRL_CHANCE := 0.28
const COUNTERATTACK_DURATION := 4.0
const COUNTERATTACK_DAMAGE_MULTIPLIER := 1.30
const REPOSITION_COOLDOWN := 1.9
const REPOSITION_DURATION := 0.58
const REPOSITION_SPEED := 204.0
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
var stance_break_damage_multiplier := STANCE_BREAK_DAMAGE_MULTIPLIER
var guard_reaction_knockback_active := false
var hurt_remaining := 0.0
var knockback_visual_remaining := 0.0
var knockback_visual_duration := 0.0
var knockback_visual_displacement := 0.0
var knockback_visual_direction := Vector2.RIGHT
var knockback_visual_intensity := 0.0
var action_cooldowns: Dictionary = {}
var lv_bu_high_risk_remaining := 0.0
var flame_slash_wave_count := 0
var flame_slash_wave_timer := 0.0
var flame_slash_direction := Vector2.RIGHT
var high_risk_skill_allowed := true
var lv_bu_action_count := 0
var lv_bu_whirl_ready_misses := 0
var cast_invulnerable := false
var combo_steps: Array[String] = []
var last_combo_id := ""
var counterattack_remaining := 0.0
var counterattack_action_multiplier := 1.0
var vulnerable_remaining := 0.0
var lv_bu_ultimate_target := Vector2.ZERO
var lv_bu_ultimate_hit_player := false
var lv_bu_rush_targets: Array[Vector2] = []
var lv_bu_rush_directions: Array[Vector2] = []
var lv_bu_rush_step := 0
var lv_bu_rush_segment_gap_pending := false
var movement_bounds := Rect2()
var has_movement_bounds := false
var slow_remaining := 0.0
var slow_multiplier := 1.0
var tactical_reposition_cooldown := 0.0
var tactical_reposition_allowed := true
var reposition_target := Vector2.ZERO
var reposition_step := 0
var player_is_attacking := false
var navigation_waypoint := Vector2.ZERO
var lv_bu_cyclone_origin := Vector2.ZERO
var lv_bu_cyclone_directions: Array[Vector2] = []
var lv_bu_cyclone_next_index := 0
var zhang_he_rush_targets: Array[Vector2] = []
var zhang_he_rush_directions: Array[Vector2] = []
var zhang_he_rush_step := 0
var zhang_he_rush_segment_gap_pending := false
var zhang_he_rush_ready_misses := 0

func _ready() -> void:
	health_component.died.connect(_on_died)

func set_movement_bounds(bounds: Rect2) -> void:
	movement_bounds = bounds
	has_movement_bounds = bounds.size.x > 0.0 and bounds.size.y > 0.0
	position = _clamp_to_movement_bounds(position)

func set_archetype(new_archetype: Archetype) -> void:
	archetype = new_archetype

func stance_max() -> float:
	return LV_BU_STANCE_MAX if archetype == Archetype.LV_BU else STANCE_MAX

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
	lv_bu_cyclone_origin = position
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	zhang_he_rush_targets.clear()
	zhang_he_rush_directions.clear()
	zhang_he_rush_step = 0
	zhang_he_rush_segment_gap_pending = false
	zhang_he_rush_ready_misses = 0
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
	stance = stance_max()
	stance_break_remaining = 0.0
	stance_knockback_remaining = 0.0
	stance_break_damage_multiplier = STANCE_BREAK_DAMAGE_MULTIPLIER
	guard_reaction_knockback_active = false
	hurt_remaining = 0.0
	knockback_visual_remaining = 0.0
	knockback_visual_duration = 0.0
	knockback_visual_displacement = 0.0
	knockback_visual_direction = Vector2.RIGHT
	knockback_visual_intensity = 0.0
	action_cooldowns.clear()
	lv_bu_high_risk_remaining = 0.0
	high_risk_skill_allowed = true
	lv_bu_action_count = 0
	lv_bu_whirl_ready_misses = 0
	combo_steps.clear()
	last_combo_id = ""
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
	vulnerable_remaining = 0.0
	lv_bu_ultimate_target = position
	lv_bu_ultimate_hit_player = false
	lv_bu_rush_targets.clear()
	lv_bu_rush_directions.clear()
	lv_bu_rush_step = 0
	lv_bu_rush_segment_gap_pending = false
	zhang_he_rush_targets.clear()
	zhang_he_rush_directions.clear()
	zhang_he_rush_step = 0
	zhang_he_rush_segment_gap_pending = false
	zhang_he_rush_ready_misses = 0
	slow_remaining = 0.0
	slow_multiplier = 1.0
	tactical_reposition_cooldown = 0.0
	tactical_reposition_allowed = true
	reposition_target = position
	reposition_step = 0
	navigation_waypoint = Vector2.ZERO
	# 重置烈焰连斩状态
	flame_slash_wave_count = 0
	flame_slash_wave_timer = 0.0
	flame_slash_direction = Vector2.RIGHT
	health_component.reset(max_health())

func set_navigation_waypoint(value: Vector2) -> void:
	navigation_waypoint = value

func set_tactical_reposition_allowed(value: bool) -> void:
	tactical_reposition_allowed = value

func is_tactically_repositioning() -> bool:
	return active and state == State.REPOSITION

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
	lv_bu_high_risk_remaining = maxf(0.0, lv_bu_high_risk_remaining - delta)
	tactical_reposition_cooldown = maxf(0.0, tactical_reposition_cooldown - delta)
	counterattack_remaining = maxf(0.0, counterattack_remaining - delta)
	slow_remaining = maxf(0.0, slow_remaining - delta)
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	if slow_remaining <= 0.0:
		slow_multiplier = 1.0
	var was_stance_broken := stance_break_remaining > 0.0
	stance_break_remaining = maxf(0.0, stance_break_remaining - delta)
	knockback_visual_remaining = maxf(0.0, knockback_visual_remaining - delta)
	if knockback_visual_remaining <= 0.0:
		guard_reaction_knockback_active = false
	if was_stance_broken:
		# Keep the break state active while the stance bar rebuilds from zero.
		var recovery_ratio := 1.0 - stance_break_remaining / STANCE_BREAK_DURATION
		stance = stance_max() * pow(clampf(recovery_ratio, 0.0, 1.0), 1.25)
		if stance_break_remaining <= 0.0:
			stance = stance_max()
			stance_knockback_remaining = 0.0
	if is_guard_knockback_active():
		moving = false
		return
	if state in [State.WINDUP, State.ULTIMATE_AIRBORNE, State.ULTIMATE_LANDING] or (state == State.RECOVER and current_action == "flame_slash_combo" and flame_slash_wave_count < FLAME_SLASH_COMBO_WAVE_COUNT):
		action_animation_elapsed += delta
	if state == State.VULNERABLE:
		vulnerable_remaining = maxf(0.0, vulnerable_remaining - delta)
		state_timer = vulnerable_remaining
		moving = false
		if vulnerable_remaining <= 0.0:
			state = State.APPROACH
			state_timer = ENGAGE_DELAY
			current_action = ""
		return
	if _begin_phase_transition_if_needed():
		return
	match state:
		State.ULTIMATE_AIRBORNE:
			state_timer = maxf(0.0, state_timer - delta)
			moving = false
			if state_timer <= 0.0:
				position = _clamp_to_movement_bounds(lv_bu_ultimate_target)
				state = State.ULTIMATE_LANDING
				state_timer = LV_BU_WHIRL_LANDING_DURATION
				action_animation_elapsed = 0.0
				pending_shake_strength = 18.0
				_emit_skill_impact()
		State.ULTIMATE_LANDING:
			state_timer = maxf(0.0, state_timer - delta)
			moving = false
			position = _clamp_to_movement_bounds(lv_bu_ultimate_target)
			if state_timer <= 0.0:
				if lv_bu_ultimate_hit_player:
					_enter_recovery(LV_BU_WHIRL_RECOVERY)
				else:
					_enter_vulnerable()
		State.PHASE_TRANSITION:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				if phase_summon_pending:
					phase_summon_pending = false
					summon_requested.emit(phase)
				_enter_recovery(0.45)
		State.WINDUP:
			state_timer = maxf(0.0, state_timer - delta)
			if current_action == "lvbu_cyclone_thrust":
				_tick_lv_bu_cyclone_thrust()
			elif state_timer <= 0.0:
				_finish_windup()
		State.DASH:
			_tick_dash(delta)
		State.RECOVER:
			state_timer = maxf(0.0, state_timer - delta)
			# The first wave fires at the end of the windup. Release the remaining
			# waves on fixed intervals, then leave a readable recovery window.
			if current_action == "flame_slash_combo" and flame_slash_wave_count < FLAME_SLASH_COMBO_WAVE_COUNT:
				flame_slash_wave_timer += delta
				while flame_slash_wave_timer >= FLAME_SLASH_COMBO_WAVE_INTERVAL and flame_slash_wave_count < FLAME_SLASH_COMBO_WAVE_COUNT:
					flame_slash_wave_timer -= FLAME_SLASH_COMBO_WAVE_INTERVAL
					_fire_flame_slash_wave()
					flame_slash_wave_count += 1
			if state_timer <= 0.0 and not (current_action == "flame_slash_combo" and flame_slash_wave_count < FLAME_SLASH_COMBO_WAVE_COUNT):
				if zhang_he_rush_segment_gap_pending:
					zhang_he_rush_segment_gap_pending = false
					_prepare_zhang_he_rush_segment()
				elif lv_bu_rush_segment_gap_pending:
					lv_bu_rush_segment_gap_pending = false
					_prepare_lv_bu_rush_segment()
				elif _should_continue_lv_bu_combo():
					_issue_lv_bu_action(player_position)
				elif archetype == Archetype.ZHANG_HE and combo_steps.is_empty() and _begin_zhang_he_patrol(player_position):
					pass
				elif _should_reposition_after_combo(player_position):
					_begin_reposition(player_position)
				else:
					state = State.APPROACH
					state_timer = ENGAGE_DELAY
		State.REPOSITION:
			if archetype == Archetype.ZHANG_HE:
				_tick_zhang_he_patrol(delta, player_position)
			else:
				state_timer = maxf(0.0, state_timer - delta)
				position = _clamp_to_movement_bounds(position.move_toward(reposition_target, REPOSITION_SPEED * slow_multiplier * delta))
				moving = position.distance_squared_to(reposition_target) > 4.0
				if state_timer <= 0.0 or not moving:
					state = State.APPROACH
					state_timer = ENGAGE_DELAY
					moving = false
		State.APPROACH:
			var approach_ready := _approach_zhang_he(delta, player_position) if archetype == Archetype.ZHANG_HE else _approach_player(delta, player_position)
			if approach_ready:
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
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
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
	lv_bu_ultimate_hit_player = false
	lv_bu_rush_targets.clear()
	lv_bu_rush_directions.clear()
	lv_bu_rush_step = 0
	lv_bu_rush_segment_gap_pending = false
	vulnerable_remaining = 0.0
	lv_bu_high_risk_remaining = 0.0
	reposition_target = position

func receive_player_hit(amount: float, vulnerable_stance_damage: float = 0.0) -> Dictionary:
	if not active:
		return {"damage": 0.0, "stance_broken": false}
	if cast_invulnerable and not is_vulnerable():
		return {"damage": 0.0, "stance_broken": false, "invulnerable": true}
	var actual := amount * (stance_break_damage_multiplier if is_stance_broken() else 1.0)
	hurt_remaining = 0.14
	var dealt := health_component.take_damage(actual)
	var stance_broken_now := false
	if dealt > 0.0 and is_vulnerable() and vulnerable_stance_damage > 0.0:
		stance_broken_now = add_stance_damage(vulnerable_stance_damage)
	return {"damage": dealt, "stance_broken": stance_broken_now}

func record_ultimate_hit_player() -> void:
	if archetype != Archetype.LV_BU or current_action != "lvbu_whirl":
		return
	lv_bu_ultimate_hit_player = true
	# The scene resolves telegraphs after ticking named actors. If the landing
	# timer ended in the same frame, the miss path may already have entered
	# vulnerable; convert that state back into the intended post-hit recovery.
	if state == State.VULNERABLE:
		vulnerable_remaining = 0.0
		state = State.RECOVER
		state_timer = LV_BU_WHIRL_RECOVERY
		moving = false
		lv_bu_ultimate_hit_player = false

func record_unblockable_hit_player() -> void:
	if archetype != Archetype.LV_BU or not _is_lv_bu_unblockable_action(current_action):
		return
	lv_bu_ultimate_hit_player = true
	if state == State.VULNERABLE:
		vulnerable_remaining = 0.0
		state = State.RECOVER
		var recovery := LV_BU_CHARGE_RECOVERY
		if current_action == "lvbu_whirl":
			recovery = LV_BU_WHIRL_RECOVERY
		elif current_action == "lvbu_glaive_return":
			recovery = LV_BU_RETURN_RECOVERY
		state_timer = recovery
		moving = false

func apply_slow(multiplier: float, duration: float) -> void:
	if not active or duration <= 0.0:
		return
	slow_remaining = maxf(slow_remaining, duration)
	slow_multiplier = minf(slow_multiplier, clampf(multiplier, 0.45, 1.0))

func add_stance_damage(amount: float, perfect: bool = false) -> bool:
	if not active or is_stance_broken() or amount <= 0.0:
		return false
	stance = maxf(0.0, stance - amount)
	if stance > 0.0:
		return false
	stance_break_remaining = STANCE_BREAK_DURATION
	stance_break_damage_multiplier = STANCE_BREAK_DAMAGE_MULTIPLIER + (0.10 if perfect else 0.0)
	# A successful stance break ends the current string and guarantees a
	# genuine retaliation window instead of allowing queued follow-up hits.
	combo_steps.clear()
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
	if state == State.VULNERABLE:
		vulnerable_remaining = 0.0
		state_timer = STANCE_BREAK_DURATION
		state = State.RECOVER
		current_action = ""
		moving = false
	return true

func apply_stance_break_knockback(direction: Vector2, force: float, forced_displacement: float = 0.0) -> float:
	if not is_stance_broken() or direction.length_squared() <= 0.01:
		return 0.0
	var scaled_force := maxf(force * 0.11, forced_displacement * 0.52)
	var displacement := clampf(scaled_force, 7.0, STANCE_BREAK_MAX_HIT_KNOCKBACK)
	var normalized_direction := direction.normalized()
	position = _clamp_to_movement_bounds(position + normalized_direction * displacement)
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

func apply_guard_reaction_knockback(direction: Vector2, perfect: bool = false, max_displacement: float = INF) -> float:
	if not active or direction.length_squared() <= 0.01:
		return 0.0
	var normalized_direction := direction.normalized()
	var requested_displacement := PERFECT_GUARD_REACTION_DISTANCE if perfect else GUARD_REACTION_DISTANCE
	var displacement := minf(requested_displacement, maxf(0.0, max_displacement))
	if displacement <= 0.0:
		return 0.0
	position = _clamp_to_movement_bounds(position + normalized_direction * displacement)
	knockback_visual_direction = normalized_direction
	knockback_visual_displacement = displacement
	knockback_visual_duration = PERFECT_GUARD_REACTION_DURATION if perfect else GUARD_REACTION_DURATION
	knockback_visual_remaining = knockback_visual_duration
	knockback_visual_intensity = 1.0 if perfect else 0.72
	guard_reaction_knockback_active = true
	return displacement

func is_guard_knockback_active() -> bool:
	return active and guard_reaction_knockback_active and knockback_visual_remaining > 0.0

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
	combo_steps.clear()
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	zhang_he_rush_targets.clear()
	zhang_he_rush_directions.clear()
	zhang_he_rush_step = 0
	zhang_he_rush_segment_gap_pending = false
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
	flame_slash_wave_count = FLAME_SLASH_COMBO_WAVE_COUNT
	flame_slash_wave_timer = 0.0
	state = State.APPROACH
	state_timer = ENGAGE_DELAY
	return true

func stance_ratio() -> float:
	return stance / maxf(1.0, stance_max())

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
	var base_health := BASE_HEALTH
	if archetype == Archetype.XIAHOU_DUN:
		base_health = XIAHOU_DUN_BASE_HEALTH
	elif archetype == Archetype.LV_BU:
		base_health = LV_BU_BASE_HEALTH
	return base_health * float(THREAT_HEALTH_MULTIPLIERS[threat_tier])

func is_recovering() -> bool:
	return state == State.RECOVER

func is_vulnerable() -> bool:
	return active and state == State.VULNERABLE and vulnerable_remaining > 0.0

func vulnerable_ratio() -> float:
	return clampf(vulnerable_remaining / LV_BU_VULNERABLE_DURATION, 0.0, 1.0)

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
	if not tactical_reposition_allowed or not combo_steps.is_empty() or tactical_reposition_cooldown > 0.0:
		return false
	if is_stance_broken():
		return false
	var distance := position.distance_to(player_position)
	if archetype == Archetype.ZHANG_HE:
		return distance >= ZHANG_HE_PATROL_MIN_DISTANCE and distance <= ZHANG_HE_PATROL_MAX_DISTANCE
	if distance < 96.0 or distance > 330.0:
		return false
	# Bosses choose a route only between completed attack strings. This keeps
	# their movement readable and avoids reacting to the player's raw inputs.
	var chance := 0.38 + float(phase - 1) * 0.10
	if _player_is_stationary():
		chance += 0.18
	if player_is_attacking:
		chance += 0.16
	if distance < IDEAL_ENGAGE_MIN_RANGE:
		chance += 0.12
	var to_player := player_position - position
	if to_player.length_squared() > 0.01 and player_velocity.dot(to_player.normalized()) > PLAYER_STATIONARY_SPEED * 1.8:
		chance -= 0.14
	return randf() < clampf(chance, 0.22, 0.84)

func _should_continue_lv_bu_combo() -> bool:
	return archetype == Archetype.LV_BU and not combo_steps.is_empty() and not is_stance_broken()

func _begin_reposition(player_position: Vector2) -> void:
	if archetype == Archetype.ZHANG_HE:
		_begin_zhang_he_patrol(player_position)
		return
	var to_player := player_position - position
	if to_player.length_squared() <= 0.01:
		to_player = facing_direction
	var radial := to_player.normalized()
	var lateral := Vector2(-radial.y, radial.x)
	var side := -1.0 if reposition_step % 2 == 0 else 1.0
	var lateral_distance := 96.0 + float(phase - 1) * 12.0
	var radial_offset := -42.0 if _player_is_stationary() else 18.0
	if archetype == Archetype.XIAHOU_DUN:
		# Xiahou Dun advances behind his guard instead of making wide flanks.
		lateral_distance *= 0.68
		radial_offset += 16.0
	if player_is_attacking:
		radial_offset += 14.0
	var lateral_jitter := lateral_distance * randf_range(0.84, 1.10)
	reposition_target = _clamp_to_movement_bounds(position + lateral * side * lateral_jitter + radial * (radial_offset + randf_range(-12.0, 12.0)))
	tactical_reposition_cooldown = REPOSITION_COOLDOWN
	reposition_step += 1
	state = State.REPOSITION
	state_timer = REPOSITION_DURATION
	moving = true

func _begin_zhang_he_patrol(player_position: Vector2) -> bool:
	if not tactical_reposition_allowed or is_stance_broken():
		return false
	var to_player := player_position - position
	if to_player.length_squared() <= 0.01:
		to_player = facing_direction
	var radial := to_player.normalized()
	var lateral := Vector2(-radial.y, radial.x)
	var side := -1.0 if reposition_step % 2 == 0 else 1.0
	var lateral_distance := randf_range(150.0, 245.0) + float(phase - 1) * 18.0
	var retreat_distance := randf_range(48.0, 112.0)
	var patrol_offset := lateral * side * lateral_distance - radial * retreat_distance
	var candidate := _clamp_to_movement_bounds(position + patrol_offset)
	if candidate.distance_squared_to(position) < 36.0:
		candidate = _clamp_to_movement_bounds(position - radial * 120.0 + lateral * side * 100.0)
	reposition_target = candidate
	reposition_step += 1
	tactical_reposition_cooldown = REPOSITION_COOLDOWN * 0.55
	state = State.REPOSITION
	state_timer = ZHANG_HE_PATROL_DURATION + randf_range(-0.18, 0.30)
	moving = true
	return true

func _tick_zhang_he_patrol(delta: float, player_position: Vector2) -> void:
	var patrol_direction := (reposition_target - position).normalized()
	if patrol_direction.length_squared() <= 0.01:
		patrol_direction = facing_direction
	facing_direction = Vector2.LEFT if patrol_direction.x < 0.0 else Vector2.RIGHT
	# A fast approach from behind turns the escape route into a readable counter.
	if _is_zhang_he_returning_spear_triggered(player_position):
		combo_steps = ["returning_spear"]
		state = State.APPROACH
		state_timer = 0.0
		moving = false
		return
	state_timer = maxf(0.0, state_timer - delta)
	position = _clamp_to_movement_bounds(position.move_toward(reposition_target, ZHANG_HE_PATROL_SPEED * slow_multiplier * delta))
	moving = position.distance_squared_to(reposition_target) > 4.0
	if state_timer <= 0.0 or not moving:
		state = State.APPROACH
		state_timer = ENGAGE_DELAY
		moving = false

func _is_zhang_he_returning_spear_triggered(player_position: Vector2) -> bool:
	if not _is_action_ready("returning_spear"):
		return false
	var to_boss := position - player_position
	var distance := to_boss.length()
	if distance < 96.0 or distance > 278.0 or to_boss.length_squared() <= 0.01:
		return false
	var chase_speed := player_velocity.dot(to_boss.normalized())
	var escape_speed := (reposition_target - position).normalized().dot(to_boss.normalized())
	return chase_speed >= ZHANG_HE_CHASE_SPEED_THRESHOLD and escape_speed >= 0.22

func is_high_risk_action_active() -> bool:
	return active and state in [State.WINDUP, State.DASH, State.ULTIMATE_AIRBORNE, State.ULTIMATE_LANDING] and _is_high_risk_action(current_action)

func is_cast_invulnerable() -> bool:
	return active and cast_invulnerable

func grant_counterattack() -> void:
	if not active or is_stance_broken():
		return
	counterattack_remaining = COUNTERATTACK_DURATION

func has_counterattack() -> bool:
	return active and counterattack_remaining > 0.0

func attack_animation_progress() -> float:
	if state == State.DASH and current_action == "pursuit":
		return clampf(1.0 - state_timer / maxf(0.01, pending_dash_duration), 0.0, 1.0)
	if current_action == "flame_slash_combo" and state in [State.WINDUP, State.RECOVER]:
		return clampf(action_animation_elapsed / FLAME_SLASH_COMBO_ANIMATION_DURATION, 0.0, 1.0)
	if state not in [State.WINDUP, State.ULTIMATE_LANDING] or state_timer <= 0.0:
		return 1.0
	return clampf(action_animation_elapsed / maxf(0.01, action_animation_elapsed + state_timer), 0.0, 1.0)

func is_ultimate_airborne() -> bool:
	return active and state == State.ULTIMATE_AIRBORNE and state_timer > 0.0

func is_ultimate_landing() -> bool:
	return active and state == State.ULTIMATE_LANDING and state_timer > 0.0

func ultimate_target() -> Vector2:
	return lv_bu_ultimate_target

func ultimate_airborne_progress() -> float:
	return clampf(1.0 - state_timer / LV_BU_WHIRL_AIRBORNE_DURATION, 0.0, 1.0) if state == State.ULTIMATE_AIRBORNE else 0.0

func ultimate_landing_progress() -> float:
	return clampf(1.0 - state_timer / LV_BU_WHIRL_LANDING_DURATION, 0.0, 1.0) if state == State.ULTIMATE_LANDING else 0.0

func display_name() -> String:
	match archetype:
		Archetype.XIAHOU_DUN: return "夏侯惇"
		Archetype.LV_BU: return "吕布"
	return "张郃"

func weapon_title() -> String:
	match archetype:
		Archetype.XIAHOU_DUN: return "重枪"
		Archetype.LV_BU: return "方天画戟"
	return "雁翎枪"

func health_layer_capacity() -> float:
	return HEALTH_LAYER_CAPACITY

func armor() -> float:
	var base_armor := BASE_ARMOR
	if archetype == Archetype.XIAHOU_DUN:
		base_armor = XIAHOU_DUN_BASE_ARMOR
	elif archetype == Archetype.LV_BU:
		base_armor = LV_BU_BASE_ARMOR
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
	elif archetype == Archetype.LV_BU:
		ideal_min_range = 132.0
		ideal_max_range = 214.0
		phase_speed_bonus = float(phase - 1) * LV_BU_PHASE_MOVE_SPEED_BONUS
		walk_speed = LV_BU_MOVE_SPEED + phase_speed_bonus
	var horizontal_distance := absf(to_player.x)
	# Xiahou Dun is a close-range pressure boss. Once he has entered his
	# attack lane, discard stale obstacle waypoints and attack in place instead
	# of repeatedly backing away from a player who is hugging his hitbox.
	if archetype == Archetype.XIAHOU_DUN and absf(to_player.y) <= HORIZONTAL_LANE_TOLERANCE and horizontal_distance <= ideal_min_range:
		navigation_waypoint = Vector2.ZERO
		return true
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
	if horizontal_distance > ideal_max_range:
		position = _clamp_to_movement_bounds(position + direction * walk_speed * slow_multiplier * delta)
		moving = true
		return false
	if horizontal_distance < ideal_min_range:
		if archetype in [Archetype.ZHANG_HE, Archetype.LV_BU]:
			return true
		return true
	return true

func _approach_zhang_he(delta: float, player_position: Vector2) -> bool:
	if _is_zhang_he_returning_spear_triggered(player_position):
		combo_steps = ["returning_spear"]
		moving = false
		return true
	var to_player := player_position - position
	var lane_delta := absf(to_player.y)
	var horizontal_distance := absf(to_player.x)
	var walk_speed := ZHANG_HE_PATROL_SPEED + float(phase - 1) * 12.0
	if navigation_waypoint.length_squared() > 0.01:
		var to_waypoint := navigation_waypoint - position
		if to_waypoint.length() > 14.0:
			position = _clamp_to_movement_bounds(position + to_waypoint.normalized() * walk_speed * slow_multiplier * delta)
			facing_direction = Vector2.LEFT if to_waypoint.x < 0.0 else Vector2.RIGHT
			moving = true
			return false
		navigation_waypoint = Vector2.ZERO
	if lane_delta > HORIZONTAL_LANE_TOLERANCE:
		var vertical_direction := Vector2(0.0, signf(to_player.y))
		position = _clamp_to_movement_bounds(position + vertical_direction * walk_speed * 0.72 * slow_multiplier * delta)
		moving = true
		return false
	if horizontal_distance < ZHANG_HE_JAB_RANGE * 0.72:
		return true
	if horizontal_distance > ZHANG_HE_JAB_RANGE:
		# Zhang He closes only enough to establish a horizontal lane, then lets
		# the patrol loop choose the next flank instead of chasing indefinitely.
		position = _clamp_to_movement_bounds(position + _horizontal_direction_to(player_position) * walk_speed * 0.62 * slow_multiplier * delta)
		moving = true
		return false
	return true

func _begin_phase_transition_if_needed() -> bool:
	if state in [State.VULNERABLE, State.ULTIMATE_AIRBORNE, State.ULTIMATE_LANDING]:
		return false
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
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	zhang_he_rush_targets.clear()
	zhang_he_rush_directions.clear()
	zhang_he_rush_step = 0
	zhang_he_rush_segment_gap_pending = false
	phase_summon_pending = true
	combo_steps.clear()
	if current_action == "flame_slash_combo":
		flame_slash_wave_count = FLAME_SLASH_COMBO_WAVE_COUNT
		flame_slash_wave_timer = 0.0
		current_action = ""
	phase_energy_granted = 0.0
	phase_energy_progress = 0.0
	lv_bu_action_count = 0
	lv_bu_whirl_ready_misses = 0
	phase_changed.emit(phase)
	return true

func _issue_next_action(player_position: Vector2) -> void:
	if archetype == Archetype.XIAHOU_DUN:
		_issue_xiahou_dun_action(player_position)
		return
	if archetype == Archetype.LV_BU:
		_issue_lv_bu_action(player_position)
		return
	var forced_zhang_he_action := archetype == Archetype.ZHANG_HE and not combo_steps.is_empty()
	if archetype == Archetype.ZHANG_HE and forced_zhang_he_action:
		pass
	elif _is_zhang_he_in_close_quarters(player_position):
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
		"jab":
			var jab_telegraph := Telegraph.line(position, direction, ZHANG_HE_JAB_RANGE, ZHANG_HE_JAB_WIDTH, ZHANG_HE_JAB_WINDUP, _threat_damage(22.0), "boss")
			jab_telegraph.visual_kind = "zhang_he_jab"
			_emit_attack_telegraph(jab_telegraph, Telegraph.ClashKind.BASIC)
			state_timer = ZHANG_HE_JAB_WINDUP
			pending_recovery = ZHANG_HE_JAB_RECOVERY
			pending_shake_strength = 6.5
		"sweep":
			# Flower-spear sweep: three fixed lanes make the rotating throw readable
			# and let the player clash the lane that is actually approaching them.
			var flower_spear_group := "boss_flower_spear"
			for angle in [-0.38, 0.0, 0.38]:
				var spear_direction := direction.rotated(angle)
				var flower_spear := Telegraph.line(position, spear_direction, 236.0, 30.0, 0.72, _threat_damage(18.0), "boss")
				flower_spear.visual_kind = "zhang_he_flower_spear"
				flower_spear.hit_group = flower_spear_group
				_emit_attack_telegraph(flower_spear, Telegraph.ClashKind.BASIC)
			state_timer = 0.72
			pending_recovery = 0.58
			pending_shake_strength = 7.0
		"thrust":
			_emit_attack_telegraph(Telegraph.line(position, direction, 246.0, 34.0, 0.62, _threat_damage(30.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.62
			pending_recovery = 0.92
			pending_shake_strength = 8.0
		"pursuit":
			_prepare_zhang_he_rush(player_position)
			pending_shake_strength = 10.0
		"returning_spear":
			# The player is approaching from behind; turn into the chase instead of
			# continuing the retreat direction.
			facing_direction = direction
			var return_telegraph := Telegraph.line(position, facing_direction, 254.0, 38.0, ZHANG_HE_RETURNING_SPEAR_WINDUP, _threat_damage(34.0), "boss")
			return_telegraph.visual_kind = "zhang_he_returning_spear"
			_emit_attack_telegraph(return_telegraph, Telegraph.ClashKind.BASIC)
			state_timer = ZHANG_HE_RETURNING_SPEAR_WINDUP
			pending_recovery = ZHANG_HE_RETURNING_SPEAR_RECOVERY
			pending_dash_target = _clamp_to_movement_bounds(position + facing_direction * 34.0)
			pending_dash_duration = 0.16
			pending_dash_recovery = ZHANG_HE_RETURNING_SPEAR_RECOVERY
			pending_dash_active = true
			pending_shake_strength = 9.0
		"whirl":
			var whirl_telegraph := Telegraph.circle(position, 165.0, 1.12, _threat_damage(28.0), "boss")
			whirl_telegraph.visual_kind = "zhang_he_whirl"
			_emit_unblockable_telegraph(whirl_telegraph)
			state_timer = 1.12
			pending_recovery = 0.80
			pending_shake_strength = 9.0
		"three_thrust":
			for offset in [0.0, 0.0, 0.0]:
				var thrust_telegraph := Telegraph.line(position, direction, 300.0, 32.0, 1.08, 0.0, "boss_preview")
				thrust_telegraph.visual_kind = "zhang_he_three_thrust"
				_emit_unblockable_telegraph(thrust_telegraph)
			thrust_sequence = [0.0, 0.0, 0.0]
			thrust_sequence_direction = direction
			state_timer = 1.08
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
		"flame_slash_combo":
			# 烈焰连斩：蓄力后连续发射5波地面冲击波
			facing_direction = _direction_to(player_position)
			state_timer = FLAME_SLASH_COMBO_WINDUP
			pending_recovery = FLAME_SLASH_COMBO_RECOVERY
			pending_shake_strength = 15.0
			# 蓄力阶段可以clash
			_emit_attack_telegraph(Telegraph.line(position, facing_direction, FLAME_SLASH_COMBO_WAVE_DISTANCE * FLAME_SLASH_COMBO_WAVE_COUNT, FLAME_SLASH_COMBO_WAVE_WIDTH, FLAME_SLASH_COMBO_WINDUP, _threat_damage(20.0 * FLAME_SLASH_COMBO_WAVE_COUNT), "boss"), Telegraph.ClashKind.ACTIVE)
			# 播放蓄力音效
			attack_sound_requested.emit("flame_charge")
		"fire_lines":
			var fire_center_x := clampf(player_position.x - 180.0, movement_bounds.position.x + 36.0, movement_bounds.end.x - 396.0)
			for lane_offset in [-68.0, 68.0]:
				var fire_y := clampf(player_position.y + lane_offset, movement_bounds.position.y + 34.0, movement_bounds.end.y - 34.0)
				_emit_unblockable_telegraph(Telegraph.line(Vector2(fire_center_x, fire_y), Vector2.RIGHT, 360.0, 30.0, 1.04, _threat_damage(28.0), "boss"))
			state_timer = 1.04
			pending_recovery = 0.96
			pending_shake_strength = 28.0  # 增强震动
			# 请求播放火焰音效
			attack_sound_requested.emit("fire_blast")
	if phase == 3 and action != "fire_lines":
		pending_recovery *= 0.86

func _issue_lv_bu_action(player_position: Vector2) -> void:
	if combo_steps.is_empty():
		_queue_lv_bu_combo(player_position)
	var action: String = str(combo_steps.pop_front())
	_start_action_cooldown(action)
	lv_bu_action_count += 1
	if _is_high_risk_action(action):
		lv_bu_high_risk_remaining = LV_BU_HIGH_RISK_INTERVAL
	_prepare_counterattack_for(action)
	current_action = action
	action_animation_elapsed = 0.0
	facing_direction = _direction_to(player_position)
	state = State.WINDUP
	moving = false
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	pending_shake_strength = 0.0
	lv_bu_cyclone_origin = position
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	match action:
		"lvbu_charge":
			var predicted_target := _clamp_to_movement_bounds(_predicted_player_position(0.28))
			var charge_direction := _direction_to(predicted_target)
			var charge_distance := clampf(position.distance_to(predicted_target) - 72.0, LV_BU_CHARGE_MIN_DISTANCE, LV_BU_CHARGE_MAX_DISTANCE)
			facing_direction = charge_direction
			pending_dash_target = _clamp_to_movement_bounds(position + charge_direction * charge_distance)
			pending_dash_duration = LV_BU_CHARGE_DURATION
			pending_dash_recovery = _lv_bu_recovery_duration(LV_BU_CHARGE_RECOVERY)
			pending_dash_active = true
			_emit_unblockable_telegraph(Telegraph.line(position, charge_direction, charge_distance + 72.0, 64.0, LV_BU_CHARGE_WINDUP, _threat_damage(78.0), "boss"))
			state_timer = LV_BU_CHARGE_WINDUP
			pending_shake_strength = 45.0  # 增强震动
			# 请求播放冲锋音效
			attack_sound_requested.emit("boss_charge")
		"lvbu_thrust":
			_emit_attack_telegraph(Telegraph.line(position, facing_direction, 344.0, 44.0, 0.68, _threat_damage(44.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.68
			pending_recovery = _lv_bu_recovery_duration(0.72)
			pending_shake_strength = 9.0
		"lvbu_sweep":
			_emit_attack_telegraph(Telegraph.fan(position, facing_direction, 214.0, deg_to_rad(148.0), 0.84, _threat_damage(38.0), "boss"), Telegraph.ClashKind.BASIC)
			state_timer = 0.84
			pending_recovery = _lv_bu_recovery_duration(0.82)
			pending_shake_strength = 10.0
		"lvbu_slow_sweep":
			var slow_sweep := Telegraph.fan(position, facing_direction, LV_BU_SLOW_SWEEP_RANGE, deg_to_rad(112.0), LV_BU_SLOW_SWEEP_WINDUP, _threat_damage(34.0), "boss")
			slow_sweep.movement_slow_multiplier = LV_BU_SLOW_SWEEP_SLOW_MULTIPLIER
			slow_sweep.movement_slow_duration = LV_BU_SLOW_SWEEP_SLOW_DURATION
			_emit_attack_telegraph(slow_sweep, Telegraph.ClashKind.BASIC)
			state_timer = LV_BU_SLOW_SWEEP_WINDUP
			pending_recovery = _lv_bu_recovery_duration(LV_BU_SLOW_SWEEP_RECOVERY)
			pending_shake_strength = 11.0
		"lvbu_cyclone_thrust":
			# Lock a full-circle radial pattern at cast time. Lines launch in a
			# random clockwise or counter-clockwise order and overlap in flight.
			var turn_direction := -1.0 if randf() < 0.5 else 1.0
			var base_angle := facing_direction.angle()
			var angle_step := TAU / float(LV_BU_CYCLONE_THRUST_SEGMENT_COUNT)
			for index in range(LV_BU_CYCLONE_THRUST_SEGMENT_COUNT):
				lv_bu_cyclone_directions.append(Vector2.from_angle(base_angle + turn_direction * float(index) * angle_step))
			state_timer = LV_BU_CYCLONE_THRUST_INITIAL_DELAY
			pending_recovery = _lv_bu_recovery_duration(0.94)
			pending_shake_strength = 9.5
		"lvbu_rush":
			_prepare_lv_bu_rush(player_position)
		"lvbu_whirl":
			lv_bu_ultimate_hit_player = false
			lv_bu_ultimate_target = _clamp_to_movement_bounds(_predicted_player_position(0.52))
			var skyfall_telegraph := Telegraph.circle(lv_bu_ultimate_target, 212.0, LV_BU_WHIRL_TELEGRAPH_DURATION, _threat_damage(88.0), "boss")
			skyfall_telegraph.visual_kind = "lvbu_skyfall"
			skyfall_telegraph.movement_slow_multiplier = 0.52
			skyfall_telegraph.movement_slow_duration = 1.35
			_emit_unblockable_telegraph(skyfall_telegraph)
			state_timer = LV_BU_WHIRL_WINDUP
			pending_recovery = LV_BU_WHIRL_RECOVERY
			pending_shake_strength = 50.0  # 大幅增强震动
			# 请求播放Boss重击音效
			attack_sound_requested.emit("boss_impact")
			# 请求地面冲击波特效（更大规模）
			attack_effect_requested.emit("ground_impact", lv_bu_ultimate_target, 2.5)
		"lvbu_glaive_return":
			# The outgoing swing can be clashed. Its red reverse sweep must be dodged.
			thrust_sequence = [0.0, PI]
			thrust_sequence_direction = facing_direction
			state_timer = 0.62
			pending_recovery = _lv_bu_recovery_duration(LV_BU_RETURN_RECOVERY)
			pending_shake_strength = 12.0
	# The fast phase only shortens safe, clashable strings. Heavy red attacks
	# keep their recovery so a successful dodge always creates an attack window.
	if phase == 3 and action not in ["lvbu_whirl", "lvbu_glaive_return"]:
		pending_recovery *= 0.82

func _queue_lv_bu_combo(player_position: Vector2) -> void:
	# Attack 1 -> attack 2 -> attack 3 is Lu Bu's readable core string. The
	# player can clash the first two blows, then must dodge the red finisher.
	var options: Array[String] = ["two_strike"]
	if _is_action_ready("lvbu_slow_sweep"):
		options.append("slow_strike")
	var distance_to_player := position.distance_to(player_position)
	# The ultimate is available in phase one, but only after Lu Bu has shown a
	# normal attack. This prevents an immediate opener while keeping the skill
	# present throughout the fight.
	var whirl_ready := lv_bu_action_count > 0 and _can_use_lv_bu_high_risk("lvbu_whirl")
	if whirl_ready:
		options.append("warlord_three_strike")
		if phase >= 2:
			options.append("warlord_three_strike")
		if phase >= 3:
			options.append("warlord_three_strike")
	if phase >= 2 and _can_use_lv_bu_high_risk("lvbu_glaive_return"):
		options.append("glaive_return")
		if player_is_attacking or _player_is_stationary():
			options.append("glaive_return")
	if high_risk_skill_allowed and _can_use_lv_bu_high_risk("lvbu_charge") and distance_to_player >= LV_BU_CHARGE_MIN_DISTANCE:
		options.append("charge_three_strike")
		if player_is_attacking or distance_to_player >= IDEAL_ENGAGE_MAX_RANGE + 24.0:
			options.append("charge_three_strike")
	if whirl_ready:
		options.append("sweep_whirl")
		if player_is_attacking or _player_is_stationary():
			options.append("sweep_whirl")
	if _is_action_ready("lvbu_slow_sweep") and whirl_ready:
		options.append("slow_skyfall")
		if player_is_attacking or _player_is_stationary():
			options.append("slow_skyfall")
	if high_risk_skill_allowed and _is_action_ready("lvbu_slow_sweep") and _can_use_lv_bu_high_risk("lvbu_rush"):
		options.append("slow_rush")
		if player_is_attacking or _player_is_stationary():
			options.append("slow_rush")
	# Make Red Hare's staged dash a readable pressure option in its own
	# right. It is favored when the hero is at medium range or retreating, while
	# remaining subject to the same high-risk interval and cooldown as before.
	if high_risk_skill_allowed and _can_use_lv_bu_high_risk("lvbu_rush") and distance_to_player >= IDEAL_ENGAGE_MIN_RANGE + 18.0:
		options.append("rush")
		if distance_to_player >= IDEAL_ENGAGE_MAX_RANGE or player_velocity.length() > 170.0:
			options.append("rush")
	if high_risk_skill_allowed and _can_use_lv_bu_high_risk("lvbu_cyclone_thrust"):
		options.append("cyclone_thrust")
		if player_is_attacking or _player_is_stationary():
			options.append("cyclone_thrust")
	# A ready ultimate cannot be deferred forever by random selection. After two
	# missed combo rolls, force a readable finisher, preferring the slow setup.
	if whirl_ready and lv_bu_whirl_ready_misses >= 2:
		options = ["slow_skyfall" if _is_action_ready("lvbu_slow_sweep") else "warlord_three_strike"]
	else:
		while options.size() > 1 and options.has(last_combo_id):
			options.erase(last_combo_id)
	var combo_id: String = str(options.pick_random())
	last_combo_id = combo_id
	if whirl_ready:
		if combo_id in ["warlord_three_strike", "sweep_whirl", "slow_skyfall"]:
			lv_bu_whirl_ready_misses = 0
		else:
			lv_bu_whirl_ready_misses = mini(lv_bu_whirl_ready_misses + 1, 2)
	else:
		lv_bu_whirl_ready_misses = 0
	match combo_id:
		"charge_three_strike":
			combo_steps = ["lvbu_charge", "lvbu_thrust", "lvbu_sweep"]
		"warlord_three_strike":
			combo_steps = ["lvbu_thrust", "lvbu_sweep", "lvbu_whirl"]
		"sweep_whirl":
			combo_steps = ["lvbu_sweep", "lvbu_whirl"]
		"slow_skyfall":
			combo_steps = ["lvbu_slow_sweep", "lvbu_whirl"]
		"slow_rush":
			combo_steps = ["lvbu_slow_sweep", "lvbu_rush"]
		"rush":
			combo_steps = ["lvbu_rush"]
		"cyclone_thrust":
			combo_steps = ["lvbu_cyclone_thrust"]
		"glaive_return":
			combo_steps = ["lvbu_glaive_return"]
		"slow_strike":
			combo_steps = ["lvbu_slow_sweep", "lvbu_thrust"]
		_:
			combo_steps = ["lvbu_thrust", "lvbu_sweep"]

func _lv_bu_recovery_duration(base_duration: float) -> float:
	# Only the gaps inside a preselected string are shortened. The final hit
	# retains its full recovery, creating a stable attack opportunity.
	if not combo_steps.is_empty():
		return minf(base_duration, LV_BU_COMBO_LINK_RECOVERY)
	return base_duration

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
	# 烈焰连斩：中程距离优先使用
	if _is_action_ready("flame_slash_combo") and high_risk_skill_allowed:
		var distance_to_player := position.distance_to(last_player_position)
		if distance_to_player >= 120.0 and distance_to_player <= 220.0:
			options.append("flame_slash_chain")
			options.append("flame_slash_chain")  # 中程时增加权重
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
		"flame_slash_chain":
			combo_steps = ["command_thrust", "flame_slash_combo"]
		_:
			combo_steps = ["command_sweep", "command_thrust"]

func _queue_next_combo() -> void:
	var options: Array[String] = ["double_sweep", "sweep_jab"]
	var rush_ready := _is_action_ready("pursuit") and high_risk_skill_allowed
	if rush_ready and zhang_he_rush_ready_misses >= 2:
		zhang_he_rush_ready_misses = 0
		last_combo_id = "pursuit_chain"
		combo_steps = ["sweep", "jab", "pursuit"]
		return
	if rush_ready:
		options.append("pursuit_chain")
		if _player_is_stationary() or player_velocity.length() > PLAYER_STATIONARY_SPEED * 2.0:
			options.append("pursuit_chain")
	if phase >= 2:
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
	if combo_id == "pursuit_chain":
		zhang_he_rush_ready_misses = 0
	else:
		zhang_he_rush_ready_misses += 1
	match combo_id:
		"sweep_jab":
			combo_steps = ["sweep", "jab"]
		"pursuit_chain":
			combo_steps = ["sweep", "jab", "pursuit"]
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
	combo_steps = ["jab"]

func _is_zhang_he_in_close_quarters(player_position: Vector2) -> bool:
	return absf(player_position.x - position.x) < IDEAL_ENGAGE_MIN_RANGE

func _prepare_counterattack_for(action: String) -> void:
	counterattack_action_multiplier = 1.0
	if not has_counterattack() or not _is_counterattack_eligible(action):
		return
	counterattack_action_multiplier = COUNTERATTACK_DAMAGE_MULTIPLIER
	counterattack_remaining = 0.0

func _is_counterattack_eligible(action: String) -> bool:
	return action in ["jab", "sweep", "thrust", "pursuit", "returning_spear", "command_sweep", "command_thrust", "lvbu_charge", "lvbu_thrust", "lvbu_sweep", "lvbu_slow_sweep", "lvbu_rush", "lvbu_cyclone_thrust", "lvbu_glaive_return"]

func _is_special_action(action: String) -> bool:
	return action in ["pursuit", "returning_spear", "whirl", "three_thrust", "arrow_rain", "summon", "fire_charge", "fire_lines", "flame_slash_combo", "lvbu_charge", "lvbu_whirl", "lvbu_rush", "lvbu_cyclone_thrust", "lvbu_glaive_return"]

func _is_high_risk_action(action: String) -> bool:
	return action in ["pursuit", "whirl", "three_thrust", "arrow_rain", "summon", "fire_charge", "fire_lines", "flame_slash_combo", "lvbu_charge", "lvbu_whirl", "lvbu_rush", "lvbu_cyclone_thrust", "lvbu_glaive_return"]

func _is_lv_bu_unblockable_action(action: String) -> bool:
	return archetype == Archetype.LV_BU and action in ["lvbu_charge", "lvbu_whirl", "lvbu_glaive_return"]

func _can_use_lv_bu_high_risk(action: String) -> bool:
	return high_risk_skill_allowed and _is_action_ready(action) and lv_bu_high_risk_remaining <= 0.0

func _is_action_ready(action: String) -> bool:
	return float(action_cooldowns.get(action, 0.0)) <= 0.0

func _start_action_cooldown(action: String) -> void:
	var duration := _action_cooldown_duration(action)
	if duration > 0.0:
		action_cooldowns[action] = duration

func _action_cooldown_duration(action: String) -> float:
	match action:
		"pursuit": return PURSUIT_COOLDOWN
		"returning_spear": return ZHANG_HE_RETURNING_SPEAR_COOLDOWN
		"whirl": return WHIRL_COOLDOWN
		"three_thrust": return THREE_THRUST_COOLDOWN
		"summon": return SUMMON_COOLDOWN
		"fire_charge": return FIRE_CHARGE_COOLDOWN
		"fire_lines": return FIRE_LINES_COOLDOWN
		"flame_slash_combo": return FLAME_SLASH_COMBO_COOLDOWN
		"arrow_rain": return ARROW_RAIN_COOLDOWN
		"lvbu_charge": return LV_BU_CHARGE_COOLDOWN
		"lvbu_whirl": return LV_BU_WHIRL_COOLDOWN
		"lvbu_glaive_return": return LV_BU_GLAIVE_RETURN_COOLDOWN
		"lvbu_slow_sweep": return LV_BU_SLOW_SWEEP_COOLDOWN
		"lvbu_rush": return LV_BU_RUSH_COOLDOWN
		"lvbu_cyclone_thrust": return LV_BU_CYCLONE_THRUST_COOLDOWN
		_: return 0.0

func _tick_action_cooldowns(delta: float) -> void:
	for action in action_cooldowns.keys():
		var remaining := maxf(0.0, float(action_cooldowns[action]) - delta)
		if remaining <= 0.0:
			action_cooldowns.erase(action)
		else:
			action_cooldowns[action] = remaining

func _finish_windup() -> void:
	if current_action == "flame_slash_combo":
		# Resolve on the impact frame. This guarantees the cast leaves WINDUP
		# and immediately creates a readable first wave.
		flame_slash_wave_count = 0
		flame_slash_wave_timer = 0.0
		flame_slash_direction = facing_direction
		_enter_recovery(FLAME_SLASH_COMBO_WAVE_INTERVAL * (FLAME_SLASH_COMBO_WAVE_COUNT - 1) + FLAME_SLASH_COMBO_RECOVERY)
		_fire_flame_slash_wave()
		flame_slash_wave_count = 1
		return
	if not thrust_sequence.is_empty():
		var angle: float = float(thrust_sequence.pop_front())
		facing_direction = thrust_sequence_direction
		var strike_direction := facing_direction.rotated(angle)
		if current_action == "lvbu_glaive_return":
			var strike_origin := position
			var is_return_swing := absf(angle) > PI * 0.5
			# The second telegraph begins at the glaive's forward endpoint and
			# travels back through the same lane, creating a genuine return hit.
			if is_return_swing:
				strike_origin = position + facing_direction * 278.0
				_emit_unblockable_telegraph(Telegraph.line(strike_origin, strike_direction, 278.0, 60.0, LV_BU_RETURN_BACKSWING_WINDUP, _threat_damage(72.0), "boss"))
				state_timer = LV_BU_RETURN_BACKSWING_WINDUP
			else:
				_emit_attack_telegraph(Telegraph.line(strike_origin, strike_direction, 278.0, 54.0, LV_BU_RETURN_OUTGOING_WINDUP, _threat_damage(34.0), "boss"), Telegraph.ClashKind.BASIC)
				state_timer = LV_BU_RETURN_OUTGOING_WINDUP
		else:
			if current_action == "lvbu_cyclone_thrust":
				var cyclone_telegraph := Telegraph.line(position, strike_direction, LV_BU_CYCLONE_THRUST_LENGTH, LV_BU_CYCLONE_THRUST_WIDTH, LV_BU_CYCLONE_THRUST_WINDUP, _threat_damage(LV_BU_CYCLONE_THRUST_DAMAGE), "boss")
				cyclone_telegraph.visual_kind = "lvbu_cyclone_thrust"
				_emit_attack_telegraph(cyclone_telegraph, Telegraph.ClashKind.BASIC)
				state_timer = LV_BU_CYCLONE_THRUST_WINDUP
			else:
				_emit_unblockable_telegraph(Telegraph.line(position, strike_direction, 300.0, 36.0, 0.34, _threat_damage(16.0), "boss"))
				state_timer = 0.34
		_emit_skill_impact()
		return
	if current_action == "lvbu_whirl":
		# The body leaves the arena during the leap; the locked landing telegraph
		# remains active so the warning and the eventual damage share one target.
		cast_invulnerable = true
		state = State.ULTIMATE_AIRBORNE
		state_timer = LV_BU_WHIRL_AIRBORNE_DURATION
		action_animation_elapsed = 0.0
		moving = false
		pending_recovery = 0.0
		_emit_skill_impact()
		return
	if pending_dash_active:
		_emit_skill_impact()
		_begin_dash()
		return
	cast_invulnerable = false
	_emit_skill_impact()
	_enter_recovery(pending_recovery)

func _tick_lv_bu_cyclone_thrust() -> void:
	if lv_bu_cyclone_next_index < lv_bu_cyclone_directions.size():
		if state_timer > 0.0:
			return
		var strike_direction: Vector2 = lv_bu_cyclone_directions[lv_bu_cyclone_next_index]
		var cyclone_telegraph := Telegraph.line(lv_bu_cyclone_origin, strike_direction, LV_BU_CYCLONE_THRUST_LENGTH, LV_BU_CYCLONE_THRUST_WIDTH, LV_BU_CYCLONE_THRUST_WINDUP, _threat_damage(LV_BU_CYCLONE_THRUST_DAMAGE), "boss")
		cyclone_telegraph.visual_kind = "lvbu_cyclone_thrust"
		_emit_attack_telegraph(cyclone_telegraph, Telegraph.ClashKind.BASIC)
		facing_direction = strike_direction
		lv_bu_cyclone_next_index += 1
		state_timer = LV_BU_CYCLONE_THRUST_LAUNCH_INTERVAL if lv_bu_cyclone_next_index < lv_bu_cyclone_directions.size() else LV_BU_CYCLONE_THRUST_WINDUP
		return
	if state_timer <= 0.0:
		_finish_windup()

func _enter_recovery(duration: float) -> void:
	var unblockable_hit_player := _is_lv_bu_unblockable_action(current_action) and lv_bu_ultimate_hit_player
	if _is_lv_bu_unblockable_action(current_action) and not unblockable_hit_player:
		_enter_vulnerable()
		return
	if unblockable_hit_player:
		lv_bu_ultimate_hit_player = false
	state = State.RECOVER
	state_timer = duration
	moving = false

func _enter_vulnerable() -> void:
	state = State.VULNERABLE
	vulnerable_remaining = LV_BU_VULNERABLE_DURATION
	state_timer = vulnerable_remaining
	moving = false
	thrust_sequence.clear()
	combo_steps.clear()
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	pending_dash_target = Vector2.ZERO
	pending_dash_duration = 0.0
	pending_dash_recovery = 0.0
	pending_dash_active = false
	dash_target = position
	dash_speed = 0.0
	dash_recovery = 0.0
	pending_recovery = 0.0
	cast_invulnerable = false
	if current_action != "lvbu_whirl":
		current_action = ""
	action_animation_elapsed = 0.0
	counterattack_remaining = 0.0

func _begin_dash() -> void:
	dash_target = _clamp_to_movement_bounds(pending_dash_target)
	dash_recovery = pending_dash_recovery
	state = State.DASH
	state_timer = maxf(0.01, pending_dash_duration)
	dash_speed = position.distance_to(dash_target) / state_timer
	pending_dash_active = false
	moving = true
	if current_action == "lvbu_rush":
		rush_started.emit(position, facing_direction, lv_bu_rush_step)

func _tick_dash(delta: float) -> void:
	position = _clamp_to_movement_bounds(position.move_toward(dash_target, dash_speed * delta))
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0 and position.distance_squared_to(dash_target) > 1.0:
		return
	position = _clamp_to_movement_bounds(dash_target)
	if current_action == "pursuit":
		zhang_he_rush_step += 1
		if zhang_he_rush_step < zhang_he_rush_targets.size():
			zhang_he_rush_segment_gap_pending = true
			state = State.RECOVER
			state_timer = ZHANG_HE_RUSH_SEGMENT_GAP
			moving = false
			return
		_enter_recovery(ZHANG_HE_RUSH_RECOVERY)
		return
	if current_action == "lvbu_rush":
		lv_bu_rush_step += 1
		if lv_bu_rush_step < lv_bu_rush_targets.size():
			lv_bu_rush_segment_gap_pending = true
			state = State.RECOVER
			state_timer = LV_BU_RUSH_SEGMENT_GAP
			moving = false
			return
		_enter_recovery(_lv_bu_recovery_duration(LV_BU_RUSH_RECOVERY))
		return
	_enter_recovery(dash_recovery)

func _prepare_zhang_he_rush(player_position: Vector2) -> void:
	zhang_he_rush_targets.clear()
	zhang_he_rush_directions.clear()
	zhang_he_rush_step = 0
	zhang_he_rush_segment_gap_pending = false
	for index in range(ZHANG_HE_RUSH_SEGMENT_COUNT):
		zhang_he_rush_targets.append(Vector2.ZERO)
	_prepare_zhang_he_rush_segment(player_position)

func _prepare_zhang_he_rush_segment(player_position: Vector2 = Vector2.ZERO) -> void:
	if zhang_he_rush_step >= zhang_he_rush_targets.size():
		return
	var target_position := player_position if player_position.length_squared() > 0.01 else _predicted_player_position(0.12)
	var direction := _direction_to(target_position)
	if direction.length_squared() <= 0.01:
		direction = facing_direction
	var distance := ZHANG_HE_RUSH_DISTANCE + float(phase - 1) * 10.0
	var target := _clamp_to_movement_bounds(position + direction * distance)
	zhang_he_rush_directions.append(direction)
	zhang_he_rush_targets[zhang_he_rush_step] = target
	action_animation_elapsed = 0.0
	facing_direction = direction
	pending_dash_target = target
	pending_dash_duration = ZHANG_HE_RUSH_SEGMENT_DURATION
	pending_dash_recovery = 0.0
	pending_dash_active = true
	var windup := ZHANG_HE_RUSH_SEGMENT_WINDUP if zhang_he_rush_step == 0 else ZHANG_HE_RUSH_FOLLOWUP_WINDUP
	var telegraph_distance := position.distance_to(target)
	var telegraph := Telegraph.line(position, direction, telegraph_distance + 44.0, 40.0, windup, _threat_damage(28.0), "boss")
	telegraph.visual_kind = "zhang_he_rush"
	_emit_attack_telegraph(telegraph, Telegraph.ClashKind.ACTIVE)
	state = State.WINDUP
	state_timer = windup
	pending_shake_strength = 8.0

func _lv_bu_rush_segment_count() -> int:
	match phase:
		1: return 4
		2: return 6
		_: return 8

func _prepare_lv_bu_rush(player_position: Vector2 = Vector2.ZERO) -> void:
	lv_bu_rush_targets.clear()
	lv_bu_rush_directions.clear()
	lv_bu_rush_step = 0
	lv_bu_rush_segment_gap_pending = false
	var segment_count := _lv_bu_rush_segment_count()
	for index in range(segment_count):
		# Targets are resolved one segment at a time. Keeping placeholders here
		# preserves the phase-based segment count without locking future directions.
		lv_bu_rush_targets.append(Vector2.ZERO)
	_prepare_lv_bu_rush_segment()

func _prepare_lv_bu_rush_segment() -> void:
	if lv_bu_rush_step >= lv_bu_rush_targets.size():
		return
	# Re-read the latest player position before every dash. This permits a full
	# 180-degree reversal when the player crosses behind Lu Bu between segments.
	var direction := _direction_to(_predicted_player_position(0.16))
	if direction.length_squared() <= 0.01:
		direction = facing_direction
	var rush_distance := (LV_BU_RUSH_DISTANCE + float(phase - 2) * 10.0 - float(lv_bu_rush_step) * 8.0) * 1.5
	var target := _clamp_to_movement_bounds(position + direction * rush_distance)
	lv_bu_rush_directions.append(direction)
	lv_bu_rush_targets[lv_bu_rush_step] = target
	action_animation_elapsed = 0.0
	facing_direction = direction
	pending_dash_target = target
	pending_dash_duration = LV_BU_RUSH_SEGMENT_DURATION
	pending_dash_recovery = 0.0
	pending_dash_active = true
	var telegraph_distance := position.distance_to(pending_dash_target)
	var windup := LV_BU_RUSH_SEGMENT_WINDUP if lv_bu_rush_step == 0 else LV_BU_RUSH_FOLLOWUP_WINDUP
	var telegraph := Telegraph.line(position, direction, telegraph_distance + 62.0, 54.0, windup, _threat_damage(26.0), "boss")
	telegraph.movement_slow_multiplier = LV_BU_RUSH_SLOW_MULTIPLIER
	telegraph.movement_slow_duration = LV_BU_RUSH_SLOW_DURATION
	_emit_attack_telegraph(telegraph, Telegraph.ClashKind.BASIC)
	state = State.WINDUP
	state_timer = windup
	pending_shake_strength = 8.0

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

func _fire_flame_slash_wave() -> void:
	# 发射一波地面冲击波
	var wave_distance := FLAME_SLASH_COMBO_WAVE_DISTANCE * (flame_slash_wave_count + 1)
	var wave_origin := position + flame_slash_direction * (FLAME_SLASH_COMBO_WAVE_DISTANCE * flame_slash_wave_count)

	# 创建telegraph（不可clash的冲击波）
	_emit_unblockable_telegraph(Telegraph.line(wave_origin, flame_slash_direction, FLAME_SLASH_COMBO_WAVE_DISTANCE, FLAME_SLASH_COMBO_WAVE_WIDTH, 0.15, _threat_damage(20.0), "boss"))

	# The effect is anchored to this same center point by BattleRenderer, so
	# the visual and actual damage strip stay in sync.
	attack_effect_requested.emit("ground_impact", wave_origin + flame_slash_direction * (FLAME_SLASH_COMBO_WAVE_DISTANCE * 0.5), 0.30)

	# 播放冲击波音效
	attack_sound_requested.emit("flame_wave")

	# 屏幕震动（最后一波震动更强）
	if flame_slash_wave_count == FLAME_SLASH_COMBO_WAVE_COUNT - 1:
		pending_shake_strength = 22.0
	else:
		pending_shake_strength = 8.0
	_emit_skill_impact()

func _on_died() -> void:
	active = false
	dying = true
	death_animation_elapsed = 0.0
	moving = false
	pending_dash_active = false
	thrust_sequence_direction = facing_direction
	thrust_sequence.clear()
	combo_steps.clear()
	lv_bu_cyclone_directions.clear()
	lv_bu_cyclone_next_index = 0
	counterattack_remaining = 0.0
	counterattack_action_multiplier = 1.0
