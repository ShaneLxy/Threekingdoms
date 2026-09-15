class_name GuanYuActor
extends HeroActor

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

const ULTIMATE_COST := 70.0
const BASE_BASIC_COMBO_STAGES := 3
const WEAPON_CLASH_ACTIVE_DURATION := 0.30
const WEAPON_CLASH_REACH := 214.0
const BASE_STANCE_MULTIPLIER := 1.55
const DRAG_CHARGE_DURATION := 1.05
const DRAG_TAP_THRESHOLD := 0.18
const DRAG_MOVE_MULTIPLIER := 0.42
const WUSHENG_DURATION := 15.0
const WUSHENG_PULSE_INTERVAL := 3.0
const WUSHENG_ACTIVE_COOLDOWN_MULTIPLIER := 0.50
const WUSHENG_ACTIVE_COOLDOWN_MINIMUM := 3.5
const ULTIMATE_CAST_ANIMATION_DURATION := 0.56
const NAMED_MARK_DURATION := 6.0
const BLADE_WAVE_HIT_REACH := 48.0
const BLADE_WAVE_HIT_WIDTH := 118.0
const BLADE_WAVE_EXPANDED_WIDTH_MULTIPLIER := 1.20
const WUSHENG_BLADE_WAVE_HIT_REACH := 132.0
const WUSHENG_BLADE_WAVE_HIT_WIDTH := 168.0
const WUSHENG_DRAG_HIT_REACH_MULTIPLIER := 1.18
const WUSHENG_DRAG_HIT_WIDTH_MULTIPLIER := 1.18
const WUSHENG_DRAG_VISUAL_SCALE_MULTIPLIER := 1.18
const BLADE_WAVE_SCREEN_EXIT_PADDING := 240.0
const BLADE_WAVE_EFFECTIVE_LAST_FRAME := 13
const BLADE_WAVE_EXPANSION_DURATION := 0.40
const BLADE_WAVE_INFINITE_PEAK_DURATION := 0.16
const GUAN_KNIFE_WAVE_FOOT_OFFSET := Vector2(0.0, 13.0)
const ACTIVE_SLIDE_DISTANCE := 112.0
const ACTIVE_SLIDE_SPEED := 520.0
const ACTIVE_SLIDE_FRONT_REACH := 18.0
const FOURTH_STRIKE_BASE_DASH_DISTANCE := 58.0
const FOURTH_STRIKE_DASH_DISTANCE_PER_LEVEL := 14.0
const FOURTH_STRIKE_DASH_SPEED := 420.0
const FOURTH_STRIKE_DASH_FRONT_REACH := 14.0
const FOURTH_STRIKE_WAVE_RANGE := 220.0
const WUSHENG_DRAG_PULSE_RADIUS := 132.0
const PROJECTILE_GUARD_SMALL_HALF_ANGLE := deg_to_rad(55.0)
const PROJECTILE_GUARD_LARGE_HALF_ANGLE := deg_to_rad(80.0)
const PROJECTILE_GUARD_SMALL_BLOCK_LIMIT := 3
const PROJECTILE_GUARD_LARGE_BLOCK_LIMIT := 5
const BACK_GUARD_RADIUS := 132.0
const BACK_GUARD_HALF_ANGLE := deg_to_rad(56.0)

const BASIC_LOCKS := [0.50, 0.62, 0.82, 0.84]
const BASIC_HIT_DELAYS := [0.20, 0.27, 0.38, 0.30]

enum UltimateState { INACTIVE, EMPOWERED }

var combo_window := 0.0
var attack_lock_remaining := 0.0
var hit_delay_remaining := 0.0
var action_elapsed := 0.0
var action_duration := 0.0
var pending_attack: AttackRequest
var has_buffered_basic := false
var buffered_basic_direction := Vector2.ZERO
var current_move_direction := Vector2.ZERO
var active_direction := Vector2.RIGHT
var basic_attack_direction := Vector2.RIGHT
var active_cooldown_duration := 7.5
var active_slide_remaining := 0.0
var active_invulnerability_remaining := 0.0
var active_slide_direction := Vector2.RIGHT
var active_slide_attack: AttackRequest
var fourth_dash_remaining := 0.0
var fourth_dash_direction := Vector2.RIGHT
var fourth_dash_attack: AttackRequest
var weapon_clash_remaining := 0.0
var weapon_clash_direction := Vector2.RIGHT
var weapon_clash_type := Telegraph.ClashKind.NONE
var ultimate_state := UltimateState.INACTIVE
var ultimate_pulse_remaining := 0.0
var ultimate_cast_animation_remaining := 0.0
var drag_charging := false
var drag_charge_elapsed := 0.0
var drag_blade_unlocked := false
var drag_steadiness_level := 0
var drag_charge_upgrade_level := 0
var fourth_strike_unlocked := false
var fourth_dash_upgrade_level := 0
var fourth_collision_unlocked := false
var fourth_wave_range_bonus := 0.0
var fourth_wave_damage_bonus := 0.0
var fourth_wave_scale_bonus := 0.0
var fourth_execution_unlocked := false
var nearby_enemy_count := 0
var battlefield_attack_bonus := 0.0
var battlefield_damage_reduction := 0.0
var battlefield_max_count := 8
var battlefield_attack_per_enemy := 0.018
var battlefield_reduction_per_enemy := 0.025
var battlefield_radius_upgrade_level := 0
var battlefield_recovery_per_defeat := 0.0
var named_marks: Dictionary = {}
var action_serial := 0
var basic_range_bonus := 0.0
var basic_pierce_bonus := 0
var basic_damage_bonus := 0.0
var basic_knockback_bonus := 0.0
var basic_displacement_bonus := 0.0
var stance_multiplier := BASE_STANCE_MULTIPLIER
var active_range_bonus := 0.0
var active_damage_bonus := 0.0
var active_knockback_bonus := 0.0
var active_wave_upgrade_level := 0
var active_wave_scale_bonus := 0.0
var active_slide_distance_bonus := 0.0
var active_slide_front_reach_bonus := 0.0
var active_wave_width_bonus := 0.0
var active_slow_multiplier := 0.55
var active_slow_duration := 1.45
var drag_wave_upgrade_level := 0
var drag_wave_range_bonus := 0.0
var drag_wave_scale_bonus := 0.0
var ultimate_damage_bonus := 0.0
var ultimate_stance_bonus := 0.0
var ultimate_energy_gain_multiplier := 1.0
var wusheng_duration_bonus := 0.0
var wusheng_pulse_range_bonus := 0.0
var wusheng_pulse_knockback_bonus := 0.0
var named_mark_duration_bonus := 0.0
var named_damage_per_mark := 0.04
var named_mark_cap := 5
var projectile_guard_level := 0
var projectile_guard_blocks_remaining := 0
var blade_waves: Array[Dictionary] = []

func _ready() -> void:
	health_component = %HealthComponent
	health_component.died.connect(_on_died)
	health_component.shield_broken.connect(_on_protection_broken)

func configure_hero(selected_hero_id: String) -> void:
	hero_id = selected_hero_id if selected_hero_id == "guan_yu" else "guan_yu"

func basic_ability_label() -> String:
	return "青龙三斩"

func active_ability_label() -> String:
	return "青龙断浪"

func ultimate_ability_label() -> String:
	return "武圣"

func reset_for_run(world_bounds: Rect2) -> void:
	bounds = world_bounds
	var base_stats: Dictionary = HERO_CATALOG.definition_for(hero_id).get("stats", {})
	position = Vector2(bounds.get_center().x, bounds.end.y - 70.0)
	base_attack = float(base_stats.get("attack", 20.0))
	base_defense = float(base_stats.get("defense", 16.0))
	attack_bonus = 0.0
	defense_bonus = 0.0
	defense_ratio_bonus = 0.0
	speed = float(base_stats.get("move_speed", 100.0))
	active_cooldown_duration = float(base_stats.get("active_cooldown", 7.5))
	combo_stage = 0
	combo_window = 0.0
	active_cooldown = 0.0
	active_charge_capacity = 1
	active_charge_count = 1
	ultimate_energy = 0.0
	ultimate_time = 0.0
	ultimate_state = UltimateState.INACTIVE
	ultimate_pulse_remaining = 0.0
	ultimate_cast_animation_remaining = 0.0
	ultimate_segment_index = 0
	ultimate_dash_direction = Vector2.RIGHT
	reset_guard_state()
	last_attack_direction = Vector2.RIGHT
	current_action = ""
	clear_basic_attack_movement()
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	action_elapsed = 0.0
	action_duration = 0.0
	pending_attack = null
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	current_move_direction = Vector2.ZERO
	active_direction = Vector2.RIGHT
	basic_attack_direction = Vector2.RIGHT
	active_slide_remaining = 0.0
	active_invulnerability_remaining = 0.0
	active_slide_direction = Vector2.RIGHT
	active_slide_attack = null
	fourth_dash_remaining = 0.0
	fourth_dash_direction = Vector2.RIGHT
	fourth_dash_attack = null
	weapon_clash_remaining = 0.0
	weapon_clash_direction = Vector2.RIGHT
	weapon_clash_type = Telegraph.ClashKind.NONE
	drag_charging = false
	drag_charge_elapsed = 0.0
	drag_blade_unlocked = false
	drag_steadiness_level = 0
	drag_charge_upgrade_level = 0
	fourth_strike_unlocked = false
	fourth_dash_upgrade_level = 0
	fourth_collision_unlocked = false
	fourth_wave_range_bonus = 0.0
	fourth_wave_damage_bonus = 0.0
	fourth_wave_scale_bonus = 0.0
	fourth_execution_unlocked = false
	nearby_enemy_count = 0
	battlefield_attack_bonus = 0.0
	battlefield_damage_reduction = 0.0
	battlefield_max_count = 8
	battlefield_attack_per_enemy = 0.018
	battlefield_reduction_per_enemy = 0.025
	battlefield_radius_upgrade_level = 0
	battlefield_recovery_per_defeat = 0.0
	named_marks.clear()
	action_serial = 0
	basic_range_bonus = 0.0
	basic_pierce_bonus = 0
	basic_damage_bonus = 0.0
	basic_knockback_bonus = 0.0
	basic_displacement_bonus = 0.0
	stance_multiplier = BASE_STANCE_MULTIPLIER
	active_range_bonus = 0.0
	active_damage_bonus = 0.0
	active_knockback_bonus = 0.0
	active_wave_upgrade_level = 0
	active_wave_scale_bonus = 0.0
	active_slide_distance_bonus = 0.0
	active_slide_front_reach_bonus = 0.0
	active_wave_width_bonus = 0.0
	active_slow_multiplier = 0.55
	active_slow_duration = 1.45
	drag_wave_upgrade_level = 0
	drag_wave_range_bonus = 0.0
	drag_wave_scale_bonus = 0.0
	ultimate_damage_bonus = 0.0
	ultimate_stance_bonus = 0.0
	ultimate_energy_gain_multiplier = 1.0
	wusheng_duration_bonus = 0.0
	wusheng_pulse_range_bonus = 0.0
	wusheng_pulse_knockback_bonus = 0.0
	named_mark_duration_bonus = 0.0
	named_damage_per_mark = 0.04
	named_mark_cap = 5
	projectile_guard_level = 0
	projectile_guard_blocks_remaining = 0
	blade_waves.clear()
	health_component.reset(float(base_stats.get("health", 145.0)))

func tick(delta: float, move_direction: Vector2) -> void:
	if is_defeated():
		return
	tick_movement_slow(delta)
	current_move_direction = move_direction
	_update_buffered_basic_direction()
	tick_active_charge_recovery(delta, _active_cooldown_for_current_state())
	combo_window = maxf(0.0, combo_window - delta)
	weapon_clash_remaining = maxf(0.0, weapon_clash_remaining - delta)
	if weapon_clash_remaining <= 0.0:
		weapon_clash_type = Telegraph.ClashKind.NONE
	_tick_named_marks(delta)
	_tick_ultimate(delta)
	_tick_blade_waves(delta)
	ultimate_cast_animation_remaining = maxf(0.0, ultimate_cast_animation_remaining - delta)
	if drag_charging:
		drag_charge_elapsed = minf(_drag_charge_duration(), drag_charge_elapsed + delta)
		_update_facing_from_movement(move_direction)
		_move(move_direction, speed * _drag_move_multiplier() * movement_speed_multiplier() * delta)
		return
	if not current_action.is_empty():
		action_elapsed += delta
	var was_locked := attack_lock_remaining > 0.0
	attack_lock_remaining = maxf(0.0, attack_lock_remaining - delta)
	var was_waiting_for_hit := hit_delay_remaining > 0.0
	hit_delay_remaining = maxf(0.0, hit_delay_remaining - delta)
	_tick_active_slide(delta)
	active_invulnerability_remaining = maxf(0.0, active_invulnerability_remaining - delta)
	_tick_fourth_dash(delta)
	# Keep the active strike's stage through its final frame so a buffered press
	# advances from that stage. An unbuffered strike is reset in _finish_action.
	if combo_window <= 0.0 and current_action != "basic":
		combo_stage = 0
	if was_waiting_for_hit and hit_delay_remaining <= 0.0:
		_release_pending_attack()
	if fourth_dash_remaining > 0.0:
		pass
	elif current_action in ["basic", "drag_release"] and hit_delay_remaining <= 0.0 and is_action_locked():
		tick_basic_attack_movement(delta, move_direction)
	elif not is_guard_active() and ultimate_state == UltimateState.INACTIVE and not is_action_locked():
		_update_facing_from_movement(move_direction)
		_move(move_direction, speed * movement_speed_multiplier() * delta)
	elif not is_guard_active() and ultimate_state == UltimateState.EMPOWERED and not is_action_locked():
		_update_facing_from_movement(move_direction)
		_move(move_direction, speed * 1.72 * movement_speed_multiplier() * delta)
	if was_locked and attack_lock_remaining <= 0.0:
		_finish_action()

func movement_input_direction() -> Vector2:
	return current_move_direction

func supports_basic_hold() -> bool:
	return drag_blade_unlocked

func begin_basic_hold(direction: Vector2 = Vector2.ZERO) -> bool:
	if drag_charging:
		return false
	# A second tap during a basic attack must feed the combo buffer.  Only an
	# idle press begins the drag-charge hold, otherwise touch input loses stages 2-3.
	if is_action_locked() or current_action == "basic":
		return request_basic(direction)
	_lock_basic_attack_direction(_current_basic_input(direction))
	drag_charging = true
	drag_charge_elapsed = 0.0
	combo_stage = 0
	combo_window = 0.0
	current_action = "drag_charge"
	action_elapsed = 0.0
	action_duration = _drag_charge_duration()
	return true

func release_basic_hold(direction: Vector2 = Vector2.ZERO) -> bool:
	if not drag_charging:
		return false
	_lock_basic_attack_direction(_current_basic_input(direction))
	var charge_ratio := drag_charge_ratio()
	drag_charging = false
	current_action = ""
	if charge_ratio < DRAG_TAP_THRESHOLD / _drag_charge_duration():
		request_basic(basic_attack_direction)
		return true
	if charge_ratio < 0.98:
		request_basic(basic_attack_direction)
		return true
	_begin_drag_release()
	return true

func request_basic(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or drag_charging or is_guard_active():
		return false
	if is_action_locked() or current_action == "basic":
		if current_action == "basic" and not has_buffered_basic:
			# Input confirms the next stage, but its direction is read only when that
			# stage starts so the active swing cannot be redirected mid-animation.
			has_buffered_basic = true
			buffered_basic_direction = _eight_way_direction(_current_basic_input(direction), last_attack_direction)
			return true
		return false
	_lock_basic_attack_direction(_current_basic_input(direction))
	if combo_window <= 0.0:
		combo_stage = 0
	combo_stage = (combo_stage % _basic_combo_stage_count()) + 1
	_begin_basic(combo_stage)
	return true

func request_active(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or active_charge_count <= 0 or is_guard_active():
		return false
	if is_action_locked() and current_action not in ["basic", "drag_charge"]:
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	elif drag_charging:
		_cancel_drag_charge()
	active_direction = _eight_way_direction(direction, last_attack_direction)
	_update_facing_from_movement(active_direction)
	consume_active_charge(_active_cooldown_for_current_state())
	active_slide_direction = active_direction
	active_slide_remaining = ACTIVE_SLIDE_DISTANCE + active_slide_distance_bonus
	active_invulnerability_remaining = 0.92
	active_slide_attack = AttackRequest.line(position, active_direction, ACTIVE_SLIDE_FRONT_REACH + active_slide_front_reach_bonus, 70.0, 0.62 + active_damage_bonus * 0.35, 80, "青龙破阵")
	active_slide_attack.action_kind = AttackRequest.ActionKind.ACTIVE
	active_slide_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	active_slide_attack.stance_damage = _stance_damage(16.0)
	active_slide_attack.knockback = 360.0 + active_knockback_bonus * 0.30
	active_slide_attack.prevent_elite_knockback = true
	active_slide_attack.one_hit_per_target = true
	active_slide_attack.is_path_attack = true
	projectile_guard_blocks_remaining = _projectile_guard_block_limit()
	_start_action("active", 0.92)
	combat_action_started.emit("active")
	hit_delay_remaining = 0.30
	pending_attack = AttackRequest.line(position, active_direction, 340.0 + active_range_bonus, 76.0, 3.20 + active_damage_bonus + _wusheng_damage_bonus(), 400, "青龙断浪")
	pending_attack.action_kind = AttackRequest.ActionKind.ACTIVE
	pending_attack.clash_kind = Telegraph.ClashKind.ACTIVE
	pending_attack.stance_damage = _stance_damage(62.0)
	pending_attack.knockback = 720.0 + active_knockback_bonus + _wusheng_knockback_bonus()
	pending_attack.forced_displacement = 96.0 + basic_displacement_bonus
	pending_attack.forced_displacement_duration = 0.18
	pending_attack.slow_multiplier = active_slow_multiplier
	pending_attack.slow_duration = active_slow_duration
	active_used.emit()
	return true

func can_use_active() -> bool:
	return active_charge_count > 0 and (not is_action_locked() or current_action in ["basic", "drag_charge"])

func request_ultimate(direction: Vector2 = Vector2.ZERO) -> bool:
	if is_defeated() or ultimate_energy < ULTIMATE_COST or ultimate_state != UltimateState.INACTIVE or is_guard_active():
		return false
	if is_action_locked() and current_action not in ["basic", "drag_charge"]:
		return false
	if current_action == "basic":
		_cancel_basic_for_skill()
	elif drag_charging:
		_cancel_drag_charge()
	if direction.length_squared() > 0.01:
		_update_facing_from_movement(direction)
	ultimate_energy -= ULTIMATE_COST
	ultimate_time = _wusheng_duration()
	ultimate_state = UltimateState.EMPOWERED
	active_cooldown *= WUSHENG_ACTIVE_COOLDOWN_MULTIPLIER
	ultimate_pulse_remaining = WUSHENG_PULSE_INTERVAL
	ultimate_cast_animation_remaining = ULTIMATE_CAST_ANIMATION_DURATION
	ultimate_segment_index = 1
	combat_action_started.emit("ultimate")
	ultimate_started.emit()
	_emit_wusheng_pulse()
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
		"guan_broad_edge":
			basic_range_bonus += 20.0
			basic_pierce_bonus += 2
		"guan_heavy_blade":
			basic_damage_bonus += 0.16
			basic_knockback_bonus += 90.0
			basic_displacement_bonus += 8.0
		"guan_drag_blade":
			drag_blade_unlocked = true
		"guan_drag_steadiness":
			drag_steadiness_level = mini(3, drag_steadiness_level + 1)
		"guan_drag_charge":
			drag_charge_upgrade_level = mini(3, drag_charge_upgrade_level + 1)
		"guan_drag_waves":
			drag_wave_upgrade_level = mini(2, drag_wave_upgrade_level + 1)
			drag_wave_range_bonus += 56.0
			drag_wave_scale_bonus += 0.07
		"guan_drag_reach":
			drag_wave_range_bonus += 62.0
			drag_wave_scale_bonus += 0.035
		"guan_fourth_strike":
			fourth_strike_unlocked = true
		"guan_fourth_dash":
			fourth_dash_upgrade_level = mini(3, fourth_dash_upgrade_level + 1)
		"guan_fourth_collision":
			fourth_collision_unlocked = true
		"guan_fourth_wave":
			fourth_wave_range_bonus += 38.0
			fourth_wave_damage_bonus += 0.18
			fourth_wave_scale_bonus += 0.06
		"guan_fourth_execution":
			fourth_execution_unlocked = true
		"guan_martial_pressure":
			battlefield_max_count = mini(10, battlefield_max_count + 1)
			battlefield_attack_per_enemy += 0.004
			battlefield_reduction_per_enemy += 0.003
		"guan_battlefield_radius":
			battlefield_radius_upgrade_level = mini(3, battlefield_radius_upgrade_level + 1)
		"guan_iron_guard":
			named_damage_per_mark = minf(0.06, named_damage_per_mark + 0.006)
			named_mark_cap = mini(7, named_mark_cap + 1)
		"guan_pressure_recovery":
			battlefield_recovery_per_defeat += 1.2
		"guan_mark_hunt":
			named_damage_per_mark = minf(0.08, named_damage_per_mark + 0.008)
			named_mark_duration_bonus += 0.90
		"guan_breaking_wave":
			active_cooldown_duration = maxf(4.8, active_cooldown_duration - 0.80)
			active_range_bonus += 22.0
		"guan_rending_tide":
			active_damage_bonus += 0.42
			active_knockback_bonus += 130.0
			active_slow_multiplier = maxf(0.35, active_slow_multiplier - 0.05)
			active_slow_duration += 0.18
		"guan_wave_count":
			active_wave_upgrade_level = mini(2, active_wave_upgrade_level + 1)
			active_range_bonus += 56.0
			active_wave_scale_bonus += 0.07
		"guan_breaking_step":
			active_slide_distance_bonus += 24.0
			active_slide_front_reach_bonus += 8.0
			active_damage_bonus += 0.12
		"guan_river_cleaver":
			active_wave_width_bonus += 24.0
			active_damage_bonus += 0.22
			active_knockback_bonus += 90.0
			active_wave_scale_bonus += 0.08
		"guan_saintly_wrath":
			ultimate_damage_bonus += 0.26
			ultimate_stance_bonus += 0.16
		"guan_war_banner":
			ultimate_energy_gain_multiplier = minf(1.6, ultimate_energy_gain_multiplier + 0.15)
			add_ultimate_energy(12.0)
		"guan_saintly_duration":
			wusheng_duration_bonus += 2.0
		"guan_saintly_warfront":
			wusheng_pulse_range_bonus += 24.0
			wusheng_pulse_knockback_bonus += 120.0
			ultimate_damage_bonus += 0.16
			ultimate_stance_bonus += 0.08
		"guan_sweeping_guard":
			projectile_guard_level = maxi(projectile_guard_level, 1)
		"guan_sweeping_guard_large":
			projectile_guard_level = 2
	_set_battlefield_bonus(nearby_enemy_count)
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_level_up_benefits() -> void:
	attack_bonus += 0.045
	health_component.current = minf(health_component.maximum, health_component.current + health_component.maximum * 0.065)
	apply_military_level_up_benefits()
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func apply_account_progress(profile: Dictionary) -> void:
	_apply_military_strategy(profile)
	active_cooldown_duration = maxf(4.8, active_cooldown_duration - military_active_cooldown_reduction)
	reset_active_charges()
	_basic_pierce_bonus_from_military()

func _basic_pierce_bonus_from_military() -> void:
	basic_pierce_bonus += military_pierce_bonus

func on_enemy_defeated(enemy_type: int, allow_recovery: bool = true, _action_kind: int = AttackRequest.ActionKind.NONE) -> void:
	apply_military_enemy_defeat_reward(enemy_type, allow_recovery)
	if not allow_recovery:
		return
	if nearby_enemy_count <= 0 or battlefield_recovery_per_defeat <= 0.0:
		return
	var recovered_health := minf(health_component.maximum, health_component.current + battlefield_recovery_per_defeat)
	if recovered_health <= health_component.current:
		return
	health_component.current = recovered_health
	health_component.health_changed.emit(health_component.current, health_component.maximum)

func force_idle_state() -> void:
	super.force_idle_state()
	combo_window = 0.0
	combo_stage = 0
	pending_attack = null
	has_buffered_basic = false
	drag_charging = false
	active_slide_remaining = 0.0
	active_invulnerability_remaining = 0.0
	active_slide_attack = null
	fourth_dash_remaining = 0.0
	fourth_dash_attack = null
	ultimate_state = UltimateState.INACTIVE
	ultimate_time = 0.0
	blade_waves.clear()

func current_stats() -> Dictionary:
	return {
		"attack": total_attack(),
		"defense": total_defense(),
		"health": health_component.current,
		"max_health": health_component.maximum,
		"move_speed": speed,
		"basic_range": 164.0 + basic_range_bonus,
		"basic_pierce": _current_pierce(),
		"active_cooldown": active_cooldown_duration,
		"ultimate_cost": ULTIMATE_COST,
	}

func _current_pierce() -> int:
	return 5 + basic_pierce_bonus + (5 if is_wusheng_active() else 0)

func revive_from_rewarded_ad(health_ratio: float = 0.35) -> void:
	super.revive_from_rewarded_ad(health_ratio)
	# A rewarded revive resumes the current run without carrying an interrupted
	# action, clash window, or drag charge into the next input frame.
	combo_window = 0.0
	attack_lock_remaining = 0.0
	hit_delay_remaining = 0.0
	action_elapsed = 0.0
	action_duration = 0.0
	pending_attack = null
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	current_action = ""
	clear_basic_attack_movement()
	active_slide_remaining = 0.0
	active_invulnerability_remaining = 0.0
	active_slide_direction = Vector2.RIGHT
	active_slide_attack = null
	fourth_dash_remaining = 0.0
	fourth_dash_direction = Vector2.RIGHT
	fourth_dash_attack = null
	weapon_clash_remaining = 0.0
	weapon_clash_direction = Vector2.RIGHT
	weapon_clash_type = Telegraph.ClashKind.NONE
	drag_charging = false
	drag_charge_elapsed = 0.0
	blade_waves.clear()
	ultimate_state = UltimateState.INACTIVE
	ultimate_pulse_remaining = 0.0
	ultimate_cast_animation_remaining = 0.0

func ultimate_cost() -> float:
	return ULTIMATE_COST

func allows_guard_during_ultimate() -> bool:
	return ultimate_state == UltimateState.EMPOWERED and ultimate_time > 0.0

func is_ultimate_ready() -> bool:
	return ultimate_energy >= ULTIMATE_COST

func is_action_locked() -> bool:
	return attack_lock_remaining > 0.0 or drag_charging

func is_attacking() -> bool:
	return current_action in ["basic", "active", "drag_release"] or drag_charging

func is_drag_charging() -> bool:
	return drag_charging

func drag_charge_ratio() -> float:
	return clampf(drag_charge_elapsed / _drag_charge_duration(), 0.0, 1.0)

func nearby_enemy_radius() -> float:
	match battlefield_radius_upgrade_level:
		1: return 208.0
		2: return 232.0
		3: return 264.0
		_: return 184.0

func is_wusheng_active() -> bool:
	return ultimate_state == UltimateState.EMPOWERED and ultimate_time > 0.0

func try_block_frontal_projectile(origin: Vector2) -> bool:
	if projectile_guard_level <= 0 or current_action not in ["basic", "active", "drag_release"] or attack_lock_remaining <= 0.0:
		return false
	if projectile_guard_blocks_remaining <= 0:
		return false
	var incoming_origin := origin - position
	if incoming_origin.length_squared() <= 0.01:
		return false
	var facing := active_direction.normalized() if current_action == "active" else basic_attack_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = last_attack_direction.normalized()
	if facing.length_squared() <= 0.01:
		facing = Vector2.RIGHT
	var half_angle := PROJECTILE_GUARD_LARGE_HALF_ANGLE if projectile_guard_level >= 2 else PROJECTILE_GUARD_SMALL_HALF_ANGLE
	if facing.dot(incoming_origin.normalized()) < cos(half_angle):
		return false
	projectile_guard_blocks_remaining -= 1
	return true

func projectile_guard_block_message() -> String:
	if projectile_guard_level <= 0:
		return "偃月拦下箭矢"
	return "偃月拦矢 · 尚可拦截 %d 枚" % projectile_guard_blocks_remaining

func is_ultimate_casting() -> bool:
	return ultimate_cast_animation_remaining > 0.0

func ultimate_cast_animation_progress() -> float:
	return clampf(1.0 - ultimate_cast_animation_remaining / ULTIMATE_CAST_ANIMATION_DURATION, 0.0, 1.0)

func open_weapon_clash_window(request: AttackRequest, clash_type: int) -> void:
	if clash_type == Telegraph.ClashKind.NONE:
		return
	weapon_clash_remaining = WEAPON_CLASH_ACTIVE_DURATION
	weapon_clash_direction = request.direction.normalized()
	weapon_clash_type = clash_type
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
	return toward_target.length() <= WEAPON_CLASH_REACH and weapon_clash_direction.dot(toward_target.normalized()) >= -0.18

func consume_weapon_clash_window() -> void:
	weapon_clash_remaining = 0.0
	weapon_clash_type = Telegraph.ClashKind.NONE

func receive_damage(amount: float, _source: String, _attack_origin: Vector2 = Vector2.ZERO) -> float:
	if is_defeated() or active_invulnerability_remaining > 0.0:
		return 0.0
	var reduced_amount := CombatMath.mitigate_damage(amount, total_defense()) * incoming_damage_multiplier(_attack_origin)
	reduced_amount *= 1.0 - battlefield_damage_reduction
	var applied_damage := health_component.take_damage(reduced_amount)
	if applied_damage > 0.0:
		damaged.emit(applied_damage)
	return applied_damage

func interrupt_basic_attack() -> void:
	if current_action == "basic" or combo_stage > 0 or combo_window > 0.0:
		_cancel_basic_for_skill()

func set_nearby_enemy_count(count: int) -> void:
	nearby_enemy_count = clampi(count, 0, battlefield_max_count)
	_set_battlefield_bonus(nearby_enemy_count)

func modify_named_target_damage(_target_kind: int, target_key: String, request: AttackRequest, damage: float) -> float:
	var mark: Dictionary = named_marks.get(target_key, {}) as Dictionary
	var stacks := int(mark.get("stacks", 0))
	var modified_damage := damage * (1.0 + military_named_damage_ratio + float(stacks) * named_damage_per_mark)
	if fourth_execution_unlocked and request.label == "追锋断浪":
		modified_damage *= 1.30
	return modified_damage

func record_named_target_combat_hit(_target_kind: int, target_key: String, _request: AttackRequest, damage: float) -> void:
	if damage <= 0.0:
		return
	var mark: Dictionary = named_marks.get(target_key, {}) as Dictionary
	if int(mark.get("serial", -1)) == action_serial:
		return
	mark["serial"] = action_serial
	mark["stacks"] = mini(named_mark_cap, int(mark.get("stacks", 0)) + 1)
	mark["remaining"] = _named_mark_duration()
	named_marks[target_key] = mark

func hud_status_effects() -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	var slow_effect := movement_slow_hud_effect()
	if not slow_effect.is_empty():
		effects.append(slow_effect)
	var shield_effect := common_shield_hud_effect()
	if not shield_effect.is_empty():
		effects.append(shield_effect)
	if projectile_guard_level > 0:
		var guard_blocks := projectile_guard_blocks_remaining if is_attacking() else _projectile_guard_block_limit()
		effects.append({"label": "偃月拦矢", "icon": "御", "stacks": guard_blocks, "remaining": 1.0, "duration": 1.0, "timed": false, "color": Color("78cbe0")})
	if is_wusheng_active():
		effects.append({"label": "武圣", "icon": "圣", "stacks": 1, "remaining": ultimate_time, "duration": _wusheng_duration(), "color": Color("e7b84f")})
	if nearby_enemy_count > 0:
		effects.append({"label": "兵势", "icon": "势", "stacks": nearby_enemy_count, "remaining": 1.0, "duration": 1.0, "timed": false, "color": Color("5bc889")})
	var mark_stacks := _highest_named_mark_stacks()
	if mark_stacks > 0:
		effects.append({"label": "斩将", "icon": "斩", "stacks": mark_stacks, "remaining": _highest_named_mark_remaining(), "duration": _named_mark_duration(), "color": Color("dc8d4c")})
	return effects

func visual_action_progress() -> float:
	if drag_charging:
		return drag_charge_ratio()
	return clampf(action_elapsed / maxf(0.01, action_duration), 0.0, 1.0)

func _basic_combo_stage_count() -> int:
	return 4 if fourth_strike_unlocked else BASE_BASIC_COMBO_STAGES

func _wusheng_duration() -> float:
	return WUSHENG_DURATION + wusheng_duration_bonus

func _named_mark_duration() -> float:
	return NAMED_MARK_DURATION + named_mark_duration_bonus

func _drag_charge_duration() -> float:
	match drag_charge_upgrade_level:
		1: return DRAG_CHARGE_DURATION * 0.90
		2: return DRAG_CHARGE_DURATION * 0.70
		3: return DRAG_CHARGE_DURATION * 0.50
		_: return DRAG_CHARGE_DURATION

func _drag_move_multiplier() -> float:
	var slow_reduction := 0.0
	match drag_steadiness_level:
		1: slow_reduction = 0.10
		2: slow_reduction = 0.30
		3: slow_reduction = 0.50
	var base_slow := 1.0 - DRAG_MOVE_MULTIPLIER
	return 1.0 - base_slow * (1.0 - slow_reduction)

func _begin_basic(stage: int) -> void:
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	if stage == 4:
		clear_basic_attack_movement()
		projectile_guard_blocks_remaining = _projectile_guard_block_limit()
		_start_action("basic", BASIC_LOCKS[stage - 1])
		hit_delay_remaining = 0.0
		combat_action_started.emit("basic_%d" % stage)
		_begin_fourth_strike()
		return
	begin_basic_attack_movement()
	projectile_guard_blocks_remaining = _projectile_guard_block_limit()
	_start_action("basic", BASIC_LOCKS[stage - 1])
	hit_delay_remaining = BASIC_HIT_DELAYS[stage - 1]
	combat_action_started.emit("basic_%d" % stage)
	var request: AttackRequest
	var range_bonus := basic_range_bonus + (42.0 if is_wusheng_active() else 0.0)
	match stage:
		1:
			request = AttackRequest.fan(position, basic_attack_direction, 148.0 + range_bonus, deg_to_rad(190.0), 1.38 + basic_damage_bonus + _wusheng_damage_bonus(), _current_pierce(), "青龙横江")
			request.stance_damage = _stance_damage(16.0)
			request.knockback = 250.0 + basic_knockback_bonus * 0.45 + _wusheng_knockback_bonus()
			request.forced_displacement = 28.0 + basic_displacement_bonus * 0.35
			request.forced_displacement_duration = 0.08
		2:
			request = AttackRequest.fan(position, basic_attack_direction, 166.0 + range_bonus, deg_to_rad(205.0), 1.72 + basic_damage_bonus + _wusheng_damage_bonus(), _current_pierce(), "压阵斩")
			request.stance_damage = _stance_damage(26.0)
			request.knockback = 390.0 + basic_knockback_bonus * 0.72 + _wusheng_knockback_bonus()
			request.forced_displacement = 52.0 + basic_displacement_bonus * 0.65
			request.forced_displacement_duration = 0.11
		_:
			request = AttackRequest.fan(position, basic_attack_direction, 196.0 + range_bonus, deg_to_rad(220.0), 2.32 + basic_damage_bonus + _wusheng_damage_bonus(), _current_pierce(), "拖刀断阵")
			request.stance_damage = _stance_damage(50.0)
			request.knockback = 610.0 + basic_knockback_bonus + _wusheng_knockback_bonus()
			request.forced_displacement = 90.0 + basic_displacement_bonus
			request.forced_displacement_duration = 0.18
	request.action_kind = AttackRequest.ActionKind.BASIC
	request.clash_kind = Telegraph.ClashKind.BASIC
	request.fan_knockback = true
	pending_attack = request
	_emit_back_guard(90.0, 10.0, 0.12)

func _begin_fourth_strike() -> void:
	fourth_dash_direction = basic_attack_direction.normalized()
	if fourth_dash_direction.length_squared() <= 0.01:
		fourth_dash_direction = Vector2.RIGHT
	fourth_dash_remaining = FOURTH_STRIKE_BASE_DASH_DISTANCE + float(fourth_dash_upgrade_level) * FOURTH_STRIKE_DASH_DISTANCE_PER_LEVEL
	if not fourth_collision_unlocked:
		fourth_dash_attack = null
		return
	fourth_dash_attack = AttackRequest.line(position, fourth_dash_direction, FOURTH_STRIKE_DASH_FRONT_REACH, 68.0, 0.84 + basic_damage_bonus * 0.25, _current_pierce(), "追锋断浪·冲阵")
	fourth_dash_attack.action_kind = AttackRequest.ActionKind.BASIC
	fourth_dash_attack.clash_kind = Telegraph.ClashKind.BASIC
	fourth_dash_attack.dash_kind = HeroActor.DashKind.BASIC
	fourth_dash_attack.stance_damage = _stance_damage(18.0)
	fourth_dash_attack.knockback = 380.0 + basic_knockback_bonus * 0.42 + _wusheng_knockback_bonus() * 0.45
	fourth_dash_attack.forced_displacement = 52.0 + basic_displacement_bonus * 0.55
	fourth_dash_attack.forced_displacement_duration = 0.10
	fourth_dash_attack.one_hit_per_target = true
	fourth_dash_attack.is_path_attack = true

func _begin_drag_release() -> void:
	combo_stage = 0
	combo_window = 0.0
	begin_basic_attack_movement()
	projectile_guard_blocks_remaining = _projectile_guard_block_limit()
	_start_action("drag_release", 0.64)
	combat_action_started.emit("drag")
	var swing := AttackRequest.fan(position, basic_attack_direction, 214.0 + basic_range_bonus, deg_to_rad(188.0), 2.95 + basic_damage_bonus + _wusheng_damage_bonus(), _current_pierce(), "拖刀斩浪")
	swing.action_kind = AttackRequest.ActionKind.BASIC
	swing.clash_kind = Telegraph.ClashKind.BASIC
	swing.stance_damage = _stance_damage(62.0)
	swing.knockback = 690.0 + basic_knockback_bonus + _wusheng_knockback_bonus()
	swing.forced_displacement = 104.0 + basic_displacement_bonus
	swing.forced_displacement_duration = 0.20
	swing.fan_knockback = true
	attack_requested.emit(swing)
	_emit_back_guard(165.0, 30.0, 0.17)
	if is_wusheng_active():
		_emit_wusheng_drag_assault()
	else:
		_emit_drag_waves()

func _release_pending_attack() -> void:
	if pending_attack == null:
		return
	if pending_attack.label == "青龙断浪":
		_emit_active_waves()
	else:
		pending_attack.origin = position
		pending_attack.direction = basic_attack_direction
		attack_requested.emit(pending_attack)
		_emit_back_guard(_back_guard_force_for_label(pending_attack.label), _back_guard_distance_for_label(pending_attack.label), 0.15)
		if is_wusheng_active() and drag_blade_unlocked and pending_attack.action_kind == AttackRequest.ActionKind.BASIC:
			_emit_wusheng_waves()
	pending_attack = null

func _emit_back_guard(force: float, displacement: float, duration: float) -> void:
	var guard := AttackRequest.fan(position, -basic_attack_direction, BACK_GUARD_RADIUS, BACK_GUARD_HALF_ANGLE * 2.0, 0.0, 400, "偃月护背")
	guard.action_kind = AttackRequest.ActionKind.BASIC
	guard.displacement_only = true
	guard.suppress_visual_feedback = true
	guard.suppress_impact_feedback = true
	guard.knockback = force
	guard.forced_displacement = displacement
	guard.forced_displacement_duration = duration
	guard.fan_knockback = true
	attack_requested.emit(guard)

func _back_guard_force_for_label(label: String) -> float:
	match label:
		"青龙横江": return 90.0
		"压阵斩": return 120.0
		_: return 150.0

func _back_guard_distance_for_label(label: String) -> float:
	match label:
		"青龙横江": return 16.0
		"压阵斩": return 23.0
		_: return 30.0

func _emit_drag_waves() -> void:
	var direction := basic_attack_direction
	var wave := AttackRequest.line(_knife_wave_origin(), direction, 300.0 + drag_wave_range_bonus, BLADE_WAVE_HIT_WIDTH, 2.16 + basic_damage_bonus + _wusheng_damage_bonus(), _current_pierce() + 5, "拖刀刀浪")
	wave.action_kind = AttackRequest.ActionKind.BASIC
	wave.clash_kind = Telegraph.ClashKind.BASIC
	wave.stance_damage = _stance_damage(38.0)
	wave.knockback = 520.0 + basic_knockback_bonus + _wusheng_knockback_bonus()
	wave.forced_displacement = 72.0 + basic_displacement_bonus
	wave.forced_displacement_duration = 0.14
	_launch_blade_wave(wave, "guan_drag_wave", 300.0 + drag_wave_range_bonus)

func _emit_active_waves() -> void:
	var direction := active_direction.normalized()
	var wave := AttackRequest.line(_knife_wave_origin(), direction, 340.0 + active_range_bonus, BLADE_WAVE_HIT_WIDTH + active_wave_width_bonus, 3.20 + active_damage_bonus + _wusheng_damage_bonus(), _current_pierce() + 5, "青龙断浪")
	wave.action_kind = AttackRequest.ActionKind.ACTIVE
	wave.clash_kind = Telegraph.ClashKind.ACTIVE
	wave.stance_damage = _stance_damage(62.0)
	wave.knockback = 720.0 + active_knockback_bonus + _wusheng_knockback_bonus()
	wave.forced_displacement = 96.0 + basic_displacement_bonus
	wave.forced_displacement_duration = 0.18
	wave.slow_multiplier = active_slow_multiplier
	wave.slow_duration = active_slow_duration
	_launch_blade_wave(wave, "guan_active_wave", 340.0 + active_range_bonus)

func _emit_wusheng_waves(infinite_range: bool = false) -> void:
	_emit_wusheng_waves_with_mode(infinite_range, false)

func _emit_wusheng_waves_with_mode(infinite_range: bool, empowered_drag: bool) -> void:
	var direction := basic_attack_direction
	var travel_distance := 388.0 + active_range_bonus * 0.55
	var wave := AttackRequest.line(_knife_wave_origin(), direction, travel_distance, BLADE_WAVE_HIT_WIDTH, 1.18 + basic_damage_bonus * 0.45 + ultimate_damage_bonus, _current_pierce() + 5, "武圣刀浪")
	wave.action_kind = AttackRequest.ActionKind.ULTIMATE
	wave.stance_damage = _stance_damage(34.0, true)
	wave.knockback = 610.0 + basic_knockback_bonus
	wave.forced_displacement = 80.0 + basic_displacement_bonus
	wave.forced_displacement_duration = 0.15
	wave.grants_boss_ultimate_energy = false
	_launch_blade_wave(wave, "guan_wusheng_wave", travel_distance, infinite_range, empowered_drag)

func _emit_wusheng_drag_assault() -> void:
	_emit_wusheng_waves_with_mode(true, true)
	_emit_wusheng_drag_pulse()

func _emit_fourth_strike_wave() -> void:
	if is_wusheng_active():
		_emit_wusheng_waves()
		return
	var wave_range := FOURTH_STRIKE_WAVE_RANGE + basic_range_bonus * 0.35 + fourth_wave_range_bonus
	var wave := AttackRequest.line(_knife_wave_origin(), fourth_dash_direction, wave_range, 88.0 + fourth_wave_range_bonus * 0.22, 1.48 + basic_damage_bonus * 0.55 + fourth_wave_damage_bonus + _wusheng_damage_bonus() * 0.45, _current_pierce() + 5, "追锋断浪")
	wave.action_kind = AttackRequest.ActionKind.BASIC
	wave.clash_kind = Telegraph.ClashKind.BASIC
	wave.stance_damage = _stance_damage(30.0)
	wave.knockback = 430.0 + basic_knockback_bonus * 0.58 + _wusheng_knockback_bonus() * 0.55
	wave.forced_displacement = 62.0 + basic_displacement_bonus * 0.72
	wave.forced_displacement_duration = 0.13
	_launch_blade_wave(wave, "guan_fourth_wave", wave_range)

func _launch_blade_wave(wave: AttackRequest, effect_id: String, travel_distance: float, infinite_range: bool = false, empowered_drag: bool = false) -> void:
	wave.origin = _knife_wave_origin()
	var direction := wave.direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var available_distance := _distance_to_bounds_edge(wave.origin, direction) + BLADE_WAVE_SCREEN_EXIT_PADDING if infinite_range else minf(travel_distance, _distance_to_bounds_edge(wave.origin, direction))
	if available_distance <= 0.01:
		return
	wave.direction = direction
	var hit_reach := WUSHENG_BLADE_WAVE_HIT_REACH if infinite_range else BLADE_WAVE_HIT_REACH
	var hit_width := WUSHENG_BLADE_WAVE_HIT_WIDTH if infinite_range else maxf(BLADE_WAVE_HIT_WIDTH, wave.width)
	if empowered_drag:
		hit_reach *= WUSHENG_DRAG_HIT_REACH_MULTIPLIER
		hit_width *= WUSHENG_DRAG_HIT_WIDTH_MULTIPLIER
	wave.range = hit_reach
	wave.width = hit_width
	wave.one_hit_per_target = true
	wave.visual_emitted = true
	wave.suppress_impact_feedback = false
	var visual_scale := 0.60
	var max_frame := 4
	if effect_id == "guan_drag_wave":
		visual_scale += drag_wave_scale_bonus
		max_frame = _blade_wave_frame_end(drag_wave_upgrade_level)
	elif effect_id == "guan_active_wave":
		visual_scale = 0.68 + active_wave_scale_bonus
		max_frame = _blade_wave_frame_end(active_wave_upgrade_level)
	elif effect_id == "guan_fourth_wave":
		visual_scale = 0.52 + fourth_wave_scale_bonus
		max_frame = 4
	else:
		visual_scale = (1.24 + drag_wave_scale_bonus) if infinite_range else (0.74 + active_wave_scale_bonus)
		if empowered_drag:
			visual_scale *= WUSHENG_DRAG_VISUAL_SCALE_MULTIPLIER
		max_frame = BLADE_WAVE_EFFECTIVE_LAST_FRAME if infinite_range else _blade_wave_frame_end(active_wave_upgrade_level)
	var visual_duration := _blade_wave_visual_duration(max_frame, infinite_range)
	blade_waves.append({
		"attack": wave,
		"origin": wave.origin,
		"remaining": available_distance,
		"travelled": 0.0,
		"total_distance": available_distance,
		"speed": available_distance / visual_duration,
		"hit_reach": hit_reach,
		"hit_width": hit_width,
	})
	visual_effect_started.emit(effect_id, wave.origin, direction, available_distance, {
		"max_frame": max_frame,
		"scale": visual_scale,
		"infinite": infinite_range,
		"travel_duration": visual_duration,
	})

func _tick_blade_waves(delta: float) -> void:
	for index in range(blade_waves.size() - 1, -1, -1):
		var state: Dictionary = blade_waves[index]
		var wave: AttackRequest = state.get("attack", null) as AttackRequest
		if wave == null:
			blade_waves.remove_at(index)
			continue
		var remaining := maxf(0.0, float(state.get("remaining", 0.0)))
		var travel_distance := minf(float(state.get("speed", 0.0)) * delta, remaining)
		var total_distance := maxf(1.0, float(state.get("total_distance", remaining)))
		var travelled := minf(total_distance, float(state.get("travelled", 0.0)) + travel_distance)
		var progress := clampf(travelled / total_distance, 0.0, 1.0)
		var hit_reach := float(state.get("hit_reach", BLADE_WAVE_HIT_REACH))
		var hit_width := float(state.get("hit_width", BLADE_WAVE_HIT_WIDTH))
		# The hit line grows from the release point with the visual wave, rather than leaving a narrow moving gap.
		wave.origin = state.get("origin", wave.origin) as Vector2
		wave.range = travelled + hit_reach
		wave.width = hit_width * lerpf(1.0, BLADE_WAVE_EXPANDED_WIDTH_MULTIPLIER, progress)
		attack_requested.emit(wave)
		remaining = maxf(0.0, remaining - travel_distance)
		if remaining <= 0.0:
			blade_waves.remove_at(index)
		else:
			state["remaining"] = remaining
			state["travelled"] = travelled
			blade_waves[index] = state

func _blade_wave_frame_end(upgrade_level: int) -> int:
	match upgrade_level:
		1: return 10
		2: return BLADE_WAVE_EFFECTIVE_LAST_FRAME
		_: return 4

func _blade_wave_visual_duration(max_frame: int, infinite_range: bool) -> float:
	return BLADE_WAVE_EXPANSION_DURATION + BLADE_WAVE_INFINITE_PEAK_DURATION if infinite_range else BLADE_WAVE_EXPANSION_DURATION

func _lock_basic_attack_direction(direction: Vector2) -> void:
	basic_attack_direction = _basic_direction_for_input(direction, last_attack_direction)
	last_attack_direction = basic_attack_direction

func _basic_direction_for_input(direction: Vector2, fallback: Vector2) -> Vector2:
	if is_wusheng_active():
		return _eight_way_direction(direction, fallback)
	var source_direction := direction
	if absf(source_direction.x) <= 0.01:
		source_direction = fallback
	if absf(source_direction.x) <= 0.01:
		source_direction = basic_attack_direction
	return Vector2.LEFT if source_direction.x < 0.0 else Vector2.RIGHT

func _update_buffered_basic_direction() -> void:
	if current_action != "basic" or not has_buffered_basic:
		return
	var live_input := _current_basic_input()
	if live_input.length_squared() <= 0.01:
		return
	var fallback := buffered_basic_direction if buffered_basic_direction.length_squared() > 0.01 else last_attack_direction
	buffered_basic_direction = _basic_direction_for_input(live_input, fallback)

func _current_basic_input(explicit_direction: Vector2 = Vector2.ZERO) -> Vector2:
	return explicit_direction if explicit_direction.length_squared() > 0.01 else current_move_direction

func _tick_active_slide(delta: float) -> void:
	if active_slide_remaining <= 0.0:
		active_slide_attack = null
		return
	var distance := minf(active_slide_remaining, ACTIVE_SLIDE_SPEED * delta)
	var start := position
	_move(active_slide_direction, distance)
	active_slide_remaining = maxf(0.0, active_slide_remaining - distance)
	if active_slide_attack != null and distance > 0.01:
		active_slide_attack.origin = start
		active_slide_attack.direction = active_slide_direction
		active_slide_attack.range = distance + ACTIVE_SLIDE_FRONT_REACH + active_slide_front_reach_bonus
		attack_requested.emit(active_slide_attack)
	if active_slide_remaining <= 0.0:
		active_slide_attack = null

func _tick_fourth_dash(delta: float) -> void:
	if fourth_dash_remaining <= 0.0:
		return
	var distance := minf(fourth_dash_remaining, FOURTH_STRIKE_DASH_SPEED * delta)
	var start := position
	_move(fourth_dash_direction, distance)
	fourth_dash_remaining = maxf(0.0, fourth_dash_remaining - distance)
	if fourth_dash_attack != null and distance > 0.01:
		fourth_dash_attack.origin = start
		fourth_dash_attack.direction = fourth_dash_direction
		fourth_dash_attack.range = distance + FOURTH_STRIKE_DASH_FRONT_REACH
		attack_requested.emit(fourth_dash_attack)
	if fourth_dash_remaining <= 0.0:
		fourth_dash_attack = null
		_emit_fourth_strike_wave()

func _projectile_guard_block_limit() -> int:
	if projectile_guard_level >= 2:
		return PROJECTILE_GUARD_LARGE_BLOCK_LIMIT
	if projectile_guard_level == 1:
		return PROJECTILE_GUARD_SMALL_BLOCK_LIMIT
	return 0

func _active_cooldown_for_current_state() -> float:
	if is_wusheng_active():
		return maxf(WUSHENG_ACTIVE_COOLDOWN_MINIMUM, active_cooldown_duration * WUSHENG_ACTIVE_COOLDOWN_MULTIPLIER)
	return active_cooldown_duration

func _knife_wave_origin() -> Vector2:
	return position + GUAN_KNIFE_WAVE_FOOT_OFFSET

func _distance_to_bounds_edge(origin: Vector2, direction: Vector2) -> float:
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

func _tick_ultimate(delta: float) -> void:
	if ultimate_state != UltimateState.EMPOWERED:
		return
	ultimate_time = maxf(0.0, ultimate_time - delta)
	ultimate_pulse_remaining = maxf(0.0, ultimate_pulse_remaining - delta)
	if ultimate_time > 0.0 and ultimate_pulse_remaining <= 0.0:
		ultimate_pulse_remaining = WUSHENG_PULSE_INTERVAL
		_emit_wusheng_pulse()
	if ultimate_time <= 0.0:
		ultimate_state = UltimateState.INACTIVE
		ultimate_segment_index = 0
		combat_action_finished.emit("ultimate")

func _emit_wusheng_pulse() -> void:
	action_serial += 1
	var pulse := AttackRequest.circle(position, 184.0 + wusheng_pulse_range_bonus, 2.05 + ultimate_damage_bonus, 400, "武圣震阵")
	pulse.action_kind = AttackRequest.ActionKind.ULTIMATE
	pulse.stance_damage = _stance_damage(82.0, true)
	pulse.knockback = 760.0 + basic_knockback_bonus + wusheng_pulse_knockback_bonus
	pulse.forced_displacement = 112.0 + basic_displacement_bonus
	pulse.forced_displacement_duration = 0.18
	pulse.ignore_knockback_resistance = true
	pulse.grants_boss_ultimate_energy = false
	pulse.clears_projectiles = true
	attack_requested.emit(pulse)

func _emit_wusheng_drag_pulse() -> void:
	var pulse := AttackRequest.circle(position, WUSHENG_DRAG_PULSE_RADIUS, 0.85 + ultimate_damage_bonus * 0.35, 400, "武圣拖刀震阵")
	pulse.action_kind = AttackRequest.ActionKind.ULTIMATE
	pulse.stance_damage = _stance_damage(26.0, true)
	pulse.knockback = 520.0 + basic_knockback_bonus * 0.45
	pulse.forced_displacement = 72.0 + basic_displacement_bonus * 0.55
	pulse.forced_displacement_duration = 0.13
	pulse.grants_boss_ultimate_energy = false
	pulse.clears_projectiles = true
	attack_requested.emit(pulse)

func _start_action(action_id: String, duration: float) -> void:
	action_serial += 1
	current_action = action_id
	attack_lock_remaining = duration
	action_elapsed = 0.0
	action_duration = duration

func _finish_action() -> void:
	if current_action == "basic":
		combat_action_finished.emit("basic_%d" % combo_stage)
		if has_buffered_basic:
			var next_direction := buffered_basic_direction
			has_buffered_basic = false
			buffered_basic_direction = Vector2.ZERO
			combo_stage = (combo_stage % _basic_combo_stage_count()) + 1
			_lock_basic_attack_direction(next_direction)
			_begin_basic(combo_stage)
			return
		# A completed, unbuffered attack ends the physical attack chain. The HUD
		# hit-combo timer is owned separately by BattleHud.
		combo_stage = 0
		combo_window = 0.0
	elif current_action == "active":
		combat_action_finished.emit("active")
	elif current_action == "drag_release":
		combat_action_finished.emit("drag")
	clear_basic_attack_movement()
	current_action = ""
	action_elapsed = 0.0
	action_duration = 0.0

func _cancel_basic_for_skill() -> void:
	var cancelled_stage := combo_stage
	pending_attack = null
	hit_delay_remaining = 0.0
	fourth_dash_remaining = 0.0
	fourth_dash_direction = Vector2.RIGHT
	fourth_dash_attack = null
	attack_lock_remaining = 0.0
	combo_window = 0.0
	has_buffered_basic = false
	buffered_basic_direction = Vector2.ZERO
	combo_stage = 0
	clear_basic_attack_movement()
	current_action = ""
	action_elapsed = 0.0
	action_duration = 0.0
	combat_action_finished.emit("basic_%d" % cancelled_stage)

func _cancel_drag_charge() -> void:
	drag_charging = false
	drag_charge_elapsed = 0.0
	current_action = ""
	action_elapsed = 0.0
	action_duration = 0.0

func _tick_named_marks(delta: float) -> void:
	for key_variant in named_marks.keys():
		var key := str(key_variant)
		var mark: Dictionary = named_marks.get(key, {}) as Dictionary
		var remaining := maxf(0.0, float(mark.get("remaining", 0.0)) - delta)
		if remaining <= 0.0:
			named_marks.erase(key)
			continue
		mark["remaining"] = remaining
		named_marks[key] = mark

func _set_battlefield_bonus(count: int) -> void:
	var next_attack_bonus := float(count) * battlefield_attack_per_enemy
	attack_bonus += next_attack_bonus - battlefield_attack_bonus
	battlefield_attack_bonus = next_attack_bonus
	battlefield_damage_reduction = clampf(float(count) * battlefield_reduction_per_enemy, 0.0, 0.32)

func _highest_named_mark_stacks() -> int:
	var highest := 0
	for mark_variant in named_marks.values():
		var mark: Dictionary = mark_variant as Dictionary
		highest = maxi(highest, int(mark.get("stacks", 0)))
	return highest

func _highest_named_mark_remaining() -> float:
	var highest := 0.0
	for mark_variant in named_marks.values():
		var mark: Dictionary = mark_variant as Dictionary
		highest = maxf(highest, float(mark.get("remaining", 0.0)))
	return highest

func _wusheng_damage_bonus() -> float:
	return 0.58 + ultimate_damage_bonus if is_wusheng_active() else 0.0

func _wusheng_knockback_bonus() -> float:
	return 220.0 if is_wusheng_active() else 0.0

func _stance_damage(base_value: float, ultimate: bool = false) -> float:
	var multiplier := stance_multiplier + (ultimate_stance_bonus if ultimate else 0.0)
	return base_value * multiplier

func _move(direction: Vector2, distance: float) -> void:
	if is_defeated() or is_guard_active():
		return
	var normalized := direction.normalized() if direction.length_squared() > 0.01 else Vector2.ZERO
	position += normalized * distance
	position.x = clampf(position.x, bounds.position.x + 12.0, bounds.end.x - 12.0)
	position.y = clampf(position.y, bounds.position.y + 12.0, bounds.end.y - 12.0)

func _update_facing_from_movement(direction: Vector2) -> void:
	if is_guard_active():
		return
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
