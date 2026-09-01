class_name EnemySimulation
extends Node

const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")

signal enemy_died(enemy_id: int, enemy_type: int, at: Vector2, experience: int, ultimate_energy: float)
signal enemy_attack_requested(enemy_id: int, origin: Vector2, target: Vector2, enemy_type: int, damage: float, windup: float, attack_kind: String)
signal enemy_attack_cancelled(enemy_id: int)
signal enemy_death_collision(at: Vector2, direction: Vector2)
signal banner_command_requested(enemy_id: int, at: Vector2)

enum EnemyType { SWORD, HALBERD, ARCHER, SHIELD, ELITE, GUARD, SPEAR, CROSSBOW, BANNER, CAVALRY }
enum AttackState { APPROACH, WINDUP, RECOVER }
enum DeathState { NONE, FALLING, LAUNCHED }
enum EngagementLayer { ENGAGE, PRESSURE, ATMOSPHERE }
enum DuelRole { NONE, SHIELD_RING, SPEAR_RING, RANGED_RING }
enum DuelPhase { NONE, ASSEMBLING, SEALED }

const CAPACITY := 400
const DEATH_DISPLAY_DURATION := 0.72
const DEATH_ANIMATION_DURATION := 0.45
const DEATH_FADE_DELAY := 0.42
const DEATH_LAUNCH_CHANCE := 0.20
const DEATH_LAUNCH_SPEED := 980.0
const DEATH_LAUNCH_DECELERATION := 2600.0
const DEATH_COLLISION_DAMAGE := 5.0
const DEATH_COLLISION_KNOCKBACK := 520.0
const DEATH_COLLISION_RADIUS := 25.0
const DEATH_COLLISION_MAX_TARGETS := 2
const LAUNCH_COLLISION_RADIUS := 29.0
const LAUNCH_DECELERATION := 2100.0
const LAUNCH_MIN_SPEED := 170.0
const FORMATION_SQUAD_SIZE := 6
const FORMATION_SLOT_ANGLE_STEP := 0.0959931
const FORMATION_SECTOR_ANGLES := [-PI * 0.5, PI, 0.0]
const FORMATION_ARRIVAL_DISTANCE := 10.0
const ATTACK_KIND_DEFAULT := "default"
const ATTACK_KIND_ARCHER_DIRECT := "archer_direct"
const ATTACK_KIND_ARCHER_LEAD := "archer_lead"
const ATTACK_KIND_ARCHER_VOLLEY := "archer_volley"
const ATTACK_KIND_HALBERD_SWEEP := "halberd_sweep"
const ATTACK_KIND_HALBERD_BRACE := "halberd_brace"
const ATTACK_KIND_SPEAR_THRUST_1 := "spear_thrust_1"
const ATTACK_KIND_SPEAR_THRUST_2 := "spear_thrust_2"
const ATTACK_KIND_SPEAR_FORMATION := "spear_formation"
const ATTACK_KIND_DUEL_SPEAR_THRUST := "duel_spear_thrust"
const ATTACK_KIND_CROSSBOW_DIRECT := "crossbow_direct"
const ATTACK_KIND_CROSSBOW_VOLLEY := "crossbow_volley"
const ATTACK_KIND_DUEL_SHIELD_PUSH := "duel_shield_push"
const ATTACK_KIND_BANNER_COMMAND := "banner_command"
const ATTACK_KIND_CAVALRY_STAB := "cavalry_stab"
const ATTACK_KIND_CAVALRY_CHARGE := "cavalry_charge"
const ARCHER_LEAD_SPEED_THRESHOLD := 42.0
const ARCHER_VOLLEY_STORY_TIME := 80.0
const ARCHER_VOLLEY_COOLDOWN := 6.0
const ARCHER_VOLLEY_ENDLESS_COOLDOWN := 5.2
const CROSSBOW_VOLLEY_STORY_TIME := 118.0
const CROSSBOW_VOLLEY_COOLDOWN := 7.2
const CROSSBOW_VOLLEY_ENDLESS_COOLDOWN := 6.2
const CROSSBOW_VOLLEY_MIN_MEMBERS := 3
const BANNER_AURA_RADIUS := 168.0
const BANNER_COMMAND_RADIUS := 202.0
const BANNER_COMMAND_DURATION := 2.8
const BANNER_DAMAGE_MULTIPLIER := 1.10
const BANNER_SPEED_MULTIPLIER := 1.08
const BANNER_COMMAND_DAMAGE_MULTIPLIER := 1.24
const BANNER_COMMAND_SPEED_MULTIPLIER := 1.22
const CAVALRY_LINE_HALF_WIDTH := 38.0
const CAVALRY_CHARGE_DISTANCE := 184.0
const CAVALRY_CHARGE_START_DELAY := 0.40
const CAVALRY_CHARGE_SPEED := 780.0
const CAVALRY_CHARGE_COOLDOWN := 5.6
const CAVALRY_CLASH_COOLDOWN := 2.4
const CAVALRY_CLASH_HURT_DURATION := 0.22
const CAVALRY_CLASH_KNOCKBACK := 560.0
const HALBERD_SWEEP_RANGE := 68.0
const HALBERD_BRACE_MIN_DISTANCE := 72.0
const HALBERD_BRACE_MAX_DISTANCE := 110.0
const HALBERD_BRACE_APPROACH_SPEED := 78.0
const SPEAR_LINE_HALF_WIDTH := 36.0
const SPEAR_FORMATION_MIN_MEMBERS := 3
const SPEAR_FORMATION_COOLDOWN := 6.0
const SPEAR_CLASH_COOLDOWN := 2.7
const SPEAR_CLASH_HURT_DURATION := 0.24
const SPEAR_CLASH_KNOCKBACK := 520.0
const SPATIAL_CELL_SIZE := 64.0
const MAX_SEPARATION_NEIGHBORS := 8
const PRESSURE_SEPARATION_REFRESH_INTERVAL := 0.10
const ATMOSPHERE_SEPARATION_REFRESH_INTERVAL := 0.24
const LAYER_REFRESH_INTERVAL := 0.55
const NAVIGATION_REPLAN_INTERVAL := 0.28
const NAVIGATION_TARGET_SHIFT := 46.0
const NAVIGATION_WAYPOINT_ARRIVAL := 18.0
const ENGAGE_MELEE_LIMIT := 10
const ENGAGE_HALBERD_LIMIT := 3
const ENGAGE_ARCHER_LIMIT := 5
const ENGAGE_ELITE_LIMIT := 1
const ENGAGE_SPEAR_LIMIT := 4
const ENGAGE_CROSSBOW_LIMIT := 3
const ENGAGE_BANNER_LIMIT := 1
const ENGAGE_CAVALRY_LIMIT := 3
const DUEL_SHIELD_SLOTS := 36
const DUEL_SPEAR_SLOTS := 24
const DUEL_RANGED_SLOTS := 16
const DUEL_SHIELD_RADIUS := Vector2(346.0, 229.0)
const DUEL_SPEAR_RADIUS := Vector2(424.0, 282.0)
const DUEL_RANGED_RADIUS := Vector2(510.0, 339.0)
const DUEL_SOFT_BOUNDARY_RADIUS := Vector2(386.0, 257.0)
const DUEL_PLAYER_MAX_OVERSTEP := 44.0
const DUEL_SLOT_ARRIVAL_DISTANCE := 34.0
const DUEL_SHIELD_SEAL_REQUIREMENT := 30
const DUEL_SHIELD_PUSH_ATTACKERS := 2
const DUEL_SPEAR_ATTACKERS := 1
const DUEL_RANGED_ATTACKERS := 1
const DUEL_FORMATION_DAMAGE_MULTIPLIER := 0.20
const DUEL_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER := 0.35
const DUEL_REINFORCEMENT_DELAY_MIN := 0.70
const DUEL_REINFORCEMENT_DELAY_MAX := 1.15
const DUEL_REINFORCEMENT_SPAWN_INTERVAL := 0.18
const DUEL_RANGED_ATTACK_COOLDOWN_MIN := 4.2
const DUEL_RANGED_ATTACK_COOLDOWN_MAX := 6.2
const THREAT_HEALTH_MULTIPLIERS := [1.0, 1.35, 1.80, 2.35, 3.00, 3.70, 4.50, 5.40]
const THREAT_DAMAGE_MULTIPLIERS := [1.0, 1.12, 1.28, 1.48, 1.72, 1.92, 2.14, 2.38]
const THREAT_ARMOR_BONUSES := [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0]

var bounds := Rect2(80, 100, 1120, 500)
var positions: Array[Vector2] = []
var hit_points := PackedFloat32Array()
var max_hit_points := PackedFloat32Array()
var armor := PackedFloat32Array()
var move_speeds := PackedFloat32Array()
var damage_multipliers := PackedFloat32Array()
var cooldowns := PackedFloat32Array()
var hurt_timers := PackedFloat32Array()
var attack_states := PackedInt32Array()
var attack_timers := PackedFloat32Array()
var types := PackedInt32Array()
var active := PackedByteArray()
var tianji_lifted := PackedByteArray()
var knockback_velocities: Array[Vector2] = []
var recoil_timers := PackedFloat32Array()
var recoil_velocities: Array[Vector2] = []
var facing_directions: Array[Vector2] = []
var boss_guard_flags := PackedByteArray()
var death_states := PackedByteArray()
var death_timers := PackedFloat32Array()
var death_velocities: Array[Vector2] = []
var death_impact_charges := PackedByteArray()
var launch_timers := PackedFloat32Array()
var launch_durations := PackedFloat32Array()
var launch_velocities: Array[Vector2] = []
var launch_collision_damages := PackedFloat32Array()
var launch_collision_knockbacks := PackedFloat32Array()
var launch_collision_charges := PackedByteArray()
var launch_relay_charges := PackedByteArray()
var launch_hit_targets: Array[Dictionary] = []
var forced_displacement_timers := PackedFloat32Array()
var forced_displacement_velocities: Array[Vector2] = []
var hit_feedback_timers := PackedFloat32Array()
var hit_feedback_durations := PackedFloat32Array()
var hit_feedback_strengths := PackedFloat32Array()
var slow_timers := PackedFloat32Array()
var slow_multipliers := PackedFloat32Array()
var behavior_layers := PackedByteArray()
var desired_behavior_layers := PackedByteArray()
var decision_timers := PackedFloat32Array()
var decision_cycles := PackedInt32Array()
var movement_targets: Array[Vector2] = []
var spawn_anchors: Array[Vector2] = []
var patrol_offsets: Array[Vector2] = []
var attack_wait_times := PackedFloat32Array()
var attack_turn_grants := PackedByteArray()
var spear_combo_stages := PackedByteArray()
var spear_combo_timers := PackedFloat32Array()
var command_aura_strengths := PackedFloat32Array()
var command_surge_timers := PackedFloat32Array()
var separation_vectors: Array[Vector2] = []
var separation_refresh_timers := PackedFloat32Array()
var duel_roles := PackedByteArray()
var duel_slots := PackedInt32Array()
var cavalry_charge_cooldowns := PackedFloat32Array()
var cavalry_charge_distances := PackedFloat32Array()
var cavalry_charge_directions: Array[Vector2] = []
var current_attack_kinds: Array[String] = []
var free_ids: Array[int] = []
var active_count := 0
var boss_guard_count := 0
var spatial_cells: Dictionary = {}
var layer_refresh_remaining := 0.0
var threat_tier := 0
var battle_mode := "story"
var battle_elapsed := 0.0
var difficulty_ramp := 1.0
var formation_time := 0.0
var last_player_position := Vector2.ZERO
var player_velocity := Vector2.ZERO
var has_player_position := false
var archer_volley_cooldown := 0.0
var spear_formation_cooldown := 0.0
var crossbow_volley_cooldown := 0.0
var navigation_obstacles: Array[Rect2] = []
var navigation_waypoints: Array[Vector2] = []
var navigation_targets: Array[Vector2] = []
var navigation_replan_timers := PackedFloat32Array()
var navigation_waypoint_active := PackedByteArray()
var navigation_preferred_sides := PackedInt32Array()
var duel_phase := DuelPhase.NONE
var duel_center := Vector2.ZERO
var duel_slot_refill_timers := PackedFloat32Array()
var duel_fodder_death_ids: Dictionary = {}
var duel_maintenance_remaining := 0.0
var duel_reinforcement_spawn_remaining := 0.0
var duel_ranged_attack_cooldown := 0.0

func _ready() -> void:
	positions.resize(CAPACITY)
	hit_points.resize(CAPACITY)
	max_hit_points.resize(CAPACITY)
	armor.resize(CAPACITY)
	move_speeds.resize(CAPACITY)
	damage_multipliers.resize(CAPACITY)
	cooldowns.resize(CAPACITY)
	hurt_timers.resize(CAPACITY)
	attack_states.resize(CAPACITY)
	attack_timers.resize(CAPACITY)
	types.resize(CAPACITY)
	active.resize(CAPACITY)
	tianji_lifted.resize(CAPACITY)
	knockback_velocities.resize(CAPACITY)
	recoil_timers.resize(CAPACITY)
	recoil_velocities.resize(CAPACITY)
	facing_directions.resize(CAPACITY)
	boss_guard_flags.resize(CAPACITY)
	death_states.resize(CAPACITY)
	death_timers.resize(CAPACITY)
	death_velocities.resize(CAPACITY)
	death_impact_charges.resize(CAPACITY)
	launch_timers.resize(CAPACITY)
	launch_durations.resize(CAPACITY)
	launch_velocities.resize(CAPACITY)
	launch_collision_damages.resize(CAPACITY)
	launch_collision_knockbacks.resize(CAPACITY)
	launch_collision_charges.resize(CAPACITY)
	launch_relay_charges.resize(CAPACITY)
	launch_hit_targets.resize(CAPACITY)
	forced_displacement_timers.resize(CAPACITY)
	forced_displacement_velocities.resize(CAPACITY)
	hit_feedback_timers.resize(CAPACITY)
	hit_feedback_durations.resize(CAPACITY)
	hit_feedback_strengths.resize(CAPACITY)
	slow_timers.resize(CAPACITY)
	slow_multipliers.resize(CAPACITY)
	behavior_layers.resize(CAPACITY)
	desired_behavior_layers.resize(CAPACITY)
	decision_timers.resize(CAPACITY)
	decision_cycles.resize(CAPACITY)
	movement_targets.resize(CAPACITY)
	spawn_anchors.resize(CAPACITY)
	patrol_offsets.resize(CAPACITY)
	attack_wait_times.resize(CAPACITY)
	attack_turn_grants.resize(CAPACITY)
	spear_combo_stages.resize(CAPACITY)
	spear_combo_timers.resize(CAPACITY)
	command_aura_strengths.resize(CAPACITY)
	command_surge_timers.resize(CAPACITY)
	separation_vectors.resize(CAPACITY)
	separation_refresh_timers.resize(CAPACITY)
	duel_roles.resize(CAPACITY)
	duel_slots.resize(CAPACITY)
	duel_slot_refill_timers.resize(_duel_total_slot_count())
	cavalry_charge_cooldowns.resize(CAPACITY)
	cavalry_charge_distances.resize(CAPACITY)
	cavalry_charge_directions.resize(CAPACITY)
	current_attack_kinds.resize(CAPACITY)
	for id in range(CAPACITY):
		positions[id] = Vector2.ZERO
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		attack_states[id] = AttackState.APPROACH
		damage_multipliers[id] = 1.0
		attack_timers[id] = 0.0
		boss_guard_flags[id] = 0
		tianji_lifted[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		_clear_launch_state(id)
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		slow_timers[id] = 0.0
		slow_multipliers[id] = 1.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = 0.0
		separation_vectors[id] = Vector2.ZERO
		separation_refresh_timers[id] = 0.0
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
		cavalry_charge_cooldowns[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		current_attack_kinds[id] = ""
		free_ids.append(CAPACITY - id - 1)

func set_threat_tier(value: int) -> void:
	threat_tier = clampi(value, 0, THREAT_HEALTH_MULTIPLIERS.size() - 1)

func set_difficulty_ramp(value: float) -> void:
	difficulty_ramp = clampf(value, 0.70, 1.20)

func reset(world_bounds: Rect2, selected_mode: String = "story") -> void:
	bounds = world_bounds
	battle_mode = selected_mode
	battle_elapsed = 0.0
	difficulty_ramp = 1.0
	formation_time = 0.0
	last_player_position = world_bounds.get_center()
	player_velocity = Vector2.ZERO
	has_player_position = false
	archer_volley_cooldown = 0.0
	spear_formation_cooldown = 0.0
	crossbow_volley_cooldown = 0.0
	duel_phase = DuelPhase.NONE
	duel_center = world_bounds.get_center()
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0
	duel_fodder_death_ids.clear()
	for slot_index in range(duel_slot_refill_timers.size()):
		duel_slot_refill_timers[slot_index] = 0.0
	navigation_waypoints.resize(CAPACITY)
	navigation_targets.resize(CAPACITY)
	navigation_replan_timers.resize(CAPACITY)
	navigation_waypoint_active.resize(CAPACITY)
	navigation_preferred_sides.resize(CAPACITY)
	free_ids.clear()
	spatial_cells.clear()
	active_count = 0
	boss_guard_count = 0
	layer_refresh_remaining = 0.0
	for id in range(CAPACITY):
		active[id] = 0
		tianji_lifted[id] = 0
		hurt_timers[id] = 0.0
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		boss_guard_flags[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		_clear_launch_state(id)
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		slow_timers[id] = 0.0
		slow_multipliers[id] = 1.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = 0.0
		separation_vectors[id] = Vector2.ZERO
		separation_refresh_timers[id] = 0.0
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
		cavalry_charge_cooldowns[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		current_attack_kinds[id] = ""
		navigation_waypoints[id] = Vector2.ZERO
		navigation_targets[id] = Vector2.ZERO
		navigation_replan_timers[id] = 0.0
		navigation_waypoint_active[id] = 0
		navigation_preferred_sides[id] = -1 if id % 2 == 0 else 1
		damage_multipliers[id] = 1.0
		free_ids.append(CAPACITY - id - 1)

func set_navigation_obstacles(value: Array[Rect2]) -> void:
	navigation_obstacles = value.duplicate()
	for id in range(CAPACITY):
		navigation_replan_timers[id] = 0.0
		navigation_waypoint_active[id] = 0

func mark_navigation_blocked(id: int) -> void:
	if id < 0 or id >= CAPACITY:
		return
	navigation_replan_timers[id] = 0.0
	navigation_waypoint_active[id] = 0
	navigation_preferred_sides[id] = -navigation_preferred_sides[id] if navigation_preferred_sides[id] != 0 else 1

func set_battle_elapsed(value: float) -> void:
	battle_elapsed = maxf(0.0, value)

func begin_duel_formation(center: Vector2) -> void:
	clear_duel_formation()
	duel_center = _clamp_duel_center(center)
	duel_phase = DuelPhase.ASSEMBLING
	_assign_duel_role_slots(DuelRole.SHIELD_RING, DUEL_SHIELD_SLOTS)
	_assign_duel_role_slots(DuelRole.SPEAR_RING, DUEL_SPEAR_SLOTS)
	_assign_duel_role_slots(DuelRole.RANGED_RING, DUEL_RANGED_SLOTS)
	layer_refresh_remaining = 0.0
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0

func clear_duel_formation() -> void:
	duel_phase = DuelPhase.NONE
	for id in range(CAPACITY):
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
	layer_refresh_remaining = 0.0
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0
	duel_fodder_death_ids.clear()
	for slot_index in range(duel_slot_refill_timers.size()):
		duel_slot_refill_timers[slot_index] = 0.0

func is_duel_formation_active() -> bool:
	return duel_phase != DuelPhase.NONE

func is_duel_formation_sealed() -> bool:
	return duel_phase == DuelPhase.SEALED

func duel_formation_center() -> Vector2:
	return duel_center

func is_duel_formation_member(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and duel_roles[id] != DuelRole.NONE

func is_duel_shield(id: int) -> bool:
	return is_duel_formation_member(id) and duel_roles[id] == DuelRole.SHIELD_RING

func duel_containment_radii() -> Vector2:
	if not is_duel_formation_active():
		return Vector2.ZERO
	return DUEL_SHIELD_RADIUS

func duel_soft_boundary_radii() -> Vector2:
	if not is_duel_formation_active():
		return Vector2.ZERO
	return DUEL_SOFT_BOUNDARY_RADIUS

func constrain_to_duel_formation(at: Vector2, margin: float = 12.0) -> Vector2:
	if not is_duel_formation_active():
		return at
	var radii := duel_containment_radii() - Vector2.ONE * margin
	radii.x = maxf(48.0, radii.x)
	radii.y = maxf(48.0, radii.y)
	var offset := at - duel_center
	var normalized_distance := sqrt(pow(offset.x / radii.x, 2.0) + pow(offset.y / radii.y, 2.0))
	if normalized_distance <= 1.0:
		return at
	return duel_center + offset / normalized_distance

func apply_duel_player_boundary(origin: Vector2, candidate: Vector2) -> Vector2:
	if not is_duel_formation_active():
		return candidate
	var radii := DUEL_SOFT_BOUNDARY_RADIUS
	var origin_offset := origin - duel_center
	var candidate_offset := candidate - duel_center
	var origin_distance := _duel_normalized_distance(origin, radii)
	var candidate_distance := _duel_normalized_distance(candidate, radii)
	if candidate_distance <= 1.0:
		return candidate
	var resolved := candidate
	var movement := candidate - origin
	var radial_direction := candidate_offset.normalized()
	if origin_distance > 1.0 and movement.dot(radial_direction) > 0.0:
		resolved = origin + movement * 0.10
	elif origin_distance <= 1.0:
		var boundary_point := duel_center + candidate_offset / maxf(0.01, candidate_distance)
		resolved = boundary_point + (candidate - boundary_point) * 0.10
	var max_radii := radii + Vector2.ONE * DUEL_PLAYER_MAX_OVERSTEP
	var resolved_distance := _duel_normalized_distance(resolved, max_radii)
	if resolved_distance > 1.0:
		var resolved_offset := resolved - duel_center
		resolved = duel_center + resolved_offset / resolved_distance
	return resolved

func constrain_named_to_duel_formation(at: Vector2, margin: float = 32.0) -> Vector2:
	if not is_duel_formation_active():
		return at
	var radii := DUEL_SHIELD_RADIUS - Vector2.ONE * margin
	radii.x = maxf(96.0, radii.x)
	radii.y = maxf(72.0, radii.y)
	var offset := at - duel_center
	var normalized_distance := _duel_normalized_distance(at, radii)
	if normalized_distance <= 1.0:
		return at
	return duel_center + offset / normalized_distance

func _duel_normalized_distance(at: Vector2, radii: Vector2) -> float:
	var offset := at - duel_center
	return sqrt(pow(offset.x / maxf(1.0, radii.x), 2.0) + pow(offset.y / maxf(1.0, radii.y), 2.0))

func is_player_near_duel_boundary(at: Vector2, threshold: float = 0.68) -> bool:
	if not is_duel_formation_active():
		return false
	var offset := at - duel_center
	var normalized_distance := sqrt(pow(offset.x / DUEL_SHIELD_RADIUS.x, 2.0) + pow(offset.y / DUEL_SHIELD_RADIUS.y, 2.0))
	return normalized_distance >= threshold

func block_duel_shield_hit(id: int) -> void:
	if not is_duel_shield(id):
		return
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.72)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.11)
	hit_feedback_timers[id] = hit_feedback_durations[id]

func is_duel_formation_fodder(id: int) -> bool:
	return is_duel_formation_member(id) and duel_roles[id] != DuelRole.SHIELD_RING

func duel_damage_multiplier(id: int) -> float:
	if not is_duel_formation_active():
		return 1.0
	if is_duel_shield(id):
		# Shields can still be pressured while the ring is assembling.  They only
		# become fully invulnerable once the formation has actually sealed.
		return 0.0 if is_duel_formation_sealed() else DUEL_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER
	return DUEL_FORMATION_DAMAGE_MULTIPLIER if types[id] != EnemyType.ELITE else 1.0

func consume_duel_fodder_reward(id: int) -> bool:
	if id < 0 or id >= CAPACITY:
		return false
	var was_fodder := bool(duel_fodder_death_ids.get(id, false))
	duel_fodder_death_ids.erase(id)
	return was_fodder

func _assign_duel_role_slots(role: int, slot_count: int) -> void:
	for slot in range(slot_count):
		var assigned_id := _find_duel_member_for_slot(role, slot)
		if assigned_id < 0:
			assigned_id = spawn(_duel_reinforcement_type(role, slot), _duel_reinforcement_position(role, slot))
		if assigned_id < 0:
			continue
		duel_roles[assigned_id] = role
		duel_slots[assigned_id] = slot
		decision_timers[assigned_id] = 0.0

func _find_duel_member_for_slot(role: int, slot: int) -> int:
	var desired_position := _duel_slot_position(role, slot)
	var selected_id := -1
	var selected_distance := INF
	for id in range(CAPACITY):
		if active[id] == 0 or duel_roles[id] != DuelRole.NONE or boss_guard_flags[id] == 1:
			continue
		if not _is_duel_role_type(role, types[id]):
			continue
		var distance := positions[id].distance_squared_to(desired_position)
		if distance < selected_distance:
			selected_id = id
			selected_distance = distance
	return selected_id

func _is_duel_role_type(role: int, enemy_type: int) -> bool:
	match role:
		DuelRole.SHIELD_RING: return enemy_type == EnemyType.SHIELD
		DuelRole.SPEAR_RING: return enemy_type == EnemyType.SPEAR
		DuelRole.RANGED_RING: return enemy_type == EnemyType.ARCHER or enemy_type == EnemyType.CROSSBOW
	return false

func _duel_reinforcement_type(role: int, slot: int) -> int:
	match role:
		DuelRole.SHIELD_RING: return EnemyType.SHIELD
		DuelRole.SPEAR_RING: return EnemyType.SPEAR
		DuelRole.RANGED_RING: return EnemyType.CROSSBOW if slot % 2 == 0 else EnemyType.ARCHER
	return EnemyType.SWORD

func _duel_reinforcement_position(role: int, slot: int) -> Vector2:
	var slot_position := _duel_slot_position(role, slot)
	var outward := (slot_position - duel_center).normalized()
	if outward.length_squared() <= 0.01:
		outward = Vector2.RIGHT
	return _clamp_point(duel_center + outward * 460.0)

func _duel_slot_position(role: int, slot: int) -> Vector2:
	var slot_count := _duel_slot_count(role)
	if slot_count <= 0:
		return duel_center
	var angle := TAU * (float(slot) + 0.5) / float(slot_count)
	var radii := _duel_role_radius(role)
	return _clamp_point(duel_center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))

func _clamp_duel_center(center: Vector2) -> Vector2:
	var edge_margin := DUEL_RANGED_RADIUS + Vector2(12.0, 12.0)
	return Vector2(
		clampf(center.x, bounds.position.x + edge_margin.x, bounds.end.x - edge_margin.x),
		clampf(center.y, bounds.position.y + edge_margin.y, bounds.end.y - edge_margin.y)
	)

func _duel_slot_count(role: int) -> int:
	match role:
		DuelRole.SHIELD_RING: return DUEL_SHIELD_SLOTS
		DuelRole.SPEAR_RING: return DUEL_SPEAR_SLOTS
		DuelRole.RANGED_RING: return DUEL_RANGED_SLOTS
	return 0

func _duel_total_slot_count() -> int:
	return DUEL_SHIELD_SLOTS + DUEL_SPEAR_SLOTS + DUEL_RANGED_SLOTS

func _duel_slot_key(role: int, slot: int) -> int:
	match role:
		DuelRole.SHIELD_RING:
			return slot
		DuelRole.SPEAR_RING:
			return DUEL_SHIELD_SLOTS + slot
		DuelRole.RANGED_RING:
			return DUEL_SHIELD_SLOTS + DUEL_SPEAR_SLOTS + slot
	return -1

func _duel_member_for_slot(role: int, slot: int) -> int:
	for id in range(CAPACITY):
		if active[id] == 1 and duel_roles[id] == role and duel_slots[id] == slot:
			return id
	return -1

func _duel_role_radius(role: int) -> Vector2:
	match role:
		DuelRole.SHIELD_RING: return DUEL_SHIELD_RADIUS
		DuelRole.SPEAR_RING: return DUEL_SPEAR_RADIUS
		DuelRole.RANGED_RING: return DUEL_RANGED_RADIUS
	return Vector2.ZERO

func _is_duel_member_in_position(id: int) -> bool:
	if not is_duel_formation_member(id):
		return false
	return positions[id].distance_squared_to(_duel_slot_position(duel_roles[id], duel_slots[id])) <= DUEL_SLOT_ARRIVAL_DISTANCE * DUEL_SLOT_ARRIVAL_DISTANCE

func _duel_shields_in_position() -> int:
	if not is_duel_formation_active():
		return 0
	var count := 0
	for id in range(CAPACITY):
		if is_duel_shield(id) and _is_duel_member_in_position(id):
			count += 1
	return count

func _refresh_duel_phase() -> void:
	if duel_phase != DuelPhase.ASSEMBLING:
		return
	if _duel_shields_in_position() >= DUEL_SHIELD_SEAL_REQUIREMENT:
		duel_phase = DuelPhase.SEALED

func spawn(enemy_type: int, at: Vector2, is_boss_guard: bool = false) -> int:
	if free_ids.is_empty():
		return -1
	var id: int = free_ids.pop_back()
	var stats: Dictionary = _stats(enemy_type)
	var health_multiplier := _threat_health_multiplier() * difficulty_ramp
	positions[id] = at
	types[id] = enemy_type
	hit_points[id] = float(stats.hp) * health_multiplier
	max_hit_points[id] = hit_points[id]
	armor[id] = (float(stats.armor) + _threat_armor_bonus()) * difficulty_ramp
	move_speeds[id] = stats.speed
	damage_multipliers[id] = _threat_damage_multiplier() * difficulty_ramp
	cooldowns[id] = randf_range(1.2, 1.8)
	hurt_timers[id] = 0.0
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	knockback_velocities[id] = Vector2.ZERO
	recoil_timers[id] = 0.0
	recoil_velocities[id] = Vector2.ZERO
	facing_directions[id] = Vector2.DOWN
	boss_guard_flags[id] = 1 if is_boss_guard else 0
	tianji_lifted[id] = 0
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	_clear_launch_state(id)
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	hit_feedback_timers[id] = 0.0
	hit_feedback_durations[id] = 0.0
	hit_feedback_strengths[id] = 0.0
	slow_timers[id] = 0.0
	slow_multipliers[id] = 1.0
	behavior_layers[id] = EngagementLayer.ENGAGE
	desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
	decision_timers[id] = 0.0
	decision_cycles[id] = 0
	movement_targets[id] = at
	spawn_anchors[id] = at
	patrol_offsets[id] = Vector2.ZERO
	navigation_waypoints[id] = Vector2.ZERO
	navigation_targets[id] = Vector2.ZERO
	navigation_replan_timers[id] = 0.0
	navigation_waypoint_active[id] = 0
	navigation_preferred_sides[id] = -1 if id % 2 == 0 else 1
	attack_wait_times[id] = float((id * 29) % 10) * 0.03
	attack_turn_grants[id] = 0
	spear_combo_stages[id] = 0
	spear_combo_timers[id] = 0.0
	command_aura_strengths[id] = 0.0
	command_surge_timers[id] = 0.0
	separation_vectors[id] = Vector2.ZERO
	separation_refresh_timers[id] = 0.0
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	cavalry_charge_cooldowns[id] = 1.4 + float(id % 4) * 0.15 if enemy_type == EnemyType.CAVALRY else 0.0
	cavalry_charge_distances[id] = 0.0
	cavalry_charge_directions[id] = Vector2.ZERO
	current_attack_kinds[id] = ""
	active[id] = 1
	active_count += 1
	layer_refresh_remaining = 0.0
	if is_boss_guard:
		boss_guard_count += 1
	return id

func tick(delta: float, player_position: Vector2) -> void:
	formation_time += delta
	_track_player_motion(delta, player_position)
	archer_volley_cooldown = maxf(0.0, archer_volley_cooldown - delta)
	spear_formation_cooldown = maxf(0.0, spear_formation_cooldown - delta)
	crossbow_volley_cooldown = maxf(0.0, crossbow_volley_cooldown - delta)
	duel_ranged_attack_cooldown = maxf(0.0, duel_ranged_attack_cooldown - delta)
	if is_duel_formation_active():
		duel_maintenance_remaining = maxf(0.0, duel_maintenance_remaining - delta)
		duel_reinforcement_spawn_remaining = maxf(0.0, duel_reinforcement_spawn_remaining - delta)
		if duel_maintenance_remaining <= 0.0:
			_maintain_duel_formation(delta)
			duel_maintenance_remaining = 0.12
	_refresh_banner_commands(delta)
	layer_refresh_remaining = maxf(0.0, layer_refresh_remaining - delta)
	if layer_refresh_remaining <= 0.0:
		_assign_desired_behavior_layers(player_position)
		layer_refresh_remaining = LAYER_REFRESH_INTERVAL
	_update_attack_wait_times(delta)
	_assign_attack_turns(player_position)
	_rebuild_spatial_cells()
	for id in range(CAPACITY):
		if active[id] == 0:
			if death_states[id] != DeathState.NONE:
				_tick_dying(id, delta)
			continue
		if tianji_lifted[id] == 1:
			continue
		if launch_timers[id] > 0.0:
			_tick_enemy_launch(id, delta)
			continue
		cooldowns[id] -= delta
		if types[id] == EnemyType.CAVALRY:
			cavalry_charge_cooldowns[id] = maxf(0.0, cavalry_charge_cooldowns[id] - delta)
		if types[id] == EnemyType.SPEAR:
			spear_combo_timers[id] = maxf(0.0, spear_combo_timers[id] - delta)
			if spear_combo_timers[id] <= 0.0:
				spear_combo_stages[id] = 0
		hit_feedback_timers[id] = maxf(0.0, hit_feedback_timers[id] - delta)
		slow_timers[id] = maxf(0.0, slow_timers[id] - delta)
		if slow_timers[id] <= 0.0:
			slow_multipliers[id] = 1.0
		if recoil_timers[id] > 0.0:
			var recoil_delta := minf(delta, recoil_timers[id])
			positions[id] += recoil_velocities[id] * recoil_delta
			recoil_timers[id] = maxf(0.0, recoil_timers[id] - delta)
			if recoil_timers[id] <= 0.0:
				recoil_velocities[id] = Vector2.ZERO
			_clamp_position(id)
		if hurt_timers[id] > 0.0:
			hurt_timers[id] = maxf(0.0, hurt_timers[id] - delta)
			var forced_delta := minf(delta, forced_displacement_timers[id])
			if forced_delta > 0.0:
				positions[id] += forced_displacement_velocities[id] * forced_delta
				forced_displacement_timers[id] = maxf(0.0, forced_displacement_timers[id] - delta)
				if forced_displacement_timers[id] <= 0.0:
					forced_displacement_velocities[id] = Vector2.ZERO
			positions[id] += knockback_velocities[id] * delta
			knockback_velocities[id] = knockback_velocities[id].move_toward(Vector2.ZERO, 2200.0 * delta)
			_clamp_position(id)
			continue
		# A normal hit uses the hurt window; pure guard recoil is handled independently above.
		knockback_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		if attack_states[id] != AttackState.APPROACH:
			_tick_special_attack_motion(id, delta)
			attack_timers[id] = maxf(0.0, attack_timers[id] - delta)
			if attack_timers[id] <= 0.0:
				if attack_states[id] == AttackState.WINDUP:
					if types[id] == EnemyType.BANNER and current_attack_kinds[id] == ATTACK_KIND_BANNER_COMMAND:
						banner_command_requested.emit(id, positions[id])
					attack_states[id] = AttackState.RECOVER
					attack_timers[id] = _attack_recovery(types[id])
				else:
					attack_states[id] = AttackState.APPROACH
					current_attack_kinds[id] = ""
			continue
		decision_timers[id] = maxf(0.0, decision_timers[id] - delta)
		if decision_timers[id] <= 0.0:
			_refresh_movement_decision(id, player_position)
		navigation_replan_timers[id] = maxf(0.0, navigation_replan_timers[id] - delta)
		var to_player := player_position - positions[id]
		var distance := to_player.length()
		var formation_target := movement_targets[id]
		var to_formation_target := formation_target - positions[id]
		var formation_direction := to_formation_target.normalized() if to_formation_target.length_squared() > FORMATION_ARRIVAL_DISTANCE * FORMATION_ARRIVAL_DISTANCE else Vector2.ZERO
		var formation_strength := clampf(to_formation_target.length() / 42.0, 0.0, 1.0)
		var navigation_direction := _navigation_direction_for(id, formation_target)
		separation_refresh_timers[id] = maxf(0.0, separation_refresh_timers[id] - delta)
		if separation_refresh_timers[id] <= 0.0:
			separation_vectors[id] = _separation_vector(id)
			separation_refresh_timers[id] = _separation_refresh_interval(behavior_layers[id])
		var separation := separation_vectors[id]
		var move_intent := navigation_direction * formation_strength + separation * 1.35
		if move_intent.length_squared() > 0.01:
			var slow_multiplier := slow_multipliers[id] if slow_timers[id] > 0.0 else 1.0
			positions[id] += move_intent.limit_length(1.0) * move_speeds[id] * _layer_speed_multiplier(behavior_layers[id]) * _command_speed_multiplier(id) * slow_multiplier * delta
		_clamp_position(id)
		if attack_turn_grants[id] == 1 and cooldowns[id] <= 0.0 and _can_trigger_attack(id, player_position, distance):
			var attack_kind := _choose_attack_kind(id, player_position, distance)
			cooldowns[id] = _attack_cooldown_for_kind(types[id], attack_kind)
			attack_wait_times[id] = 0.0
			attack_states[id] = AttackState.WINDUP
			attack_timers[id] = _attack_windup_for_kind(types[id], attack_kind)
			var attack_target := _attack_target_for_kind(id, attack_kind, player_position)
			current_attack_kinds[id] = attack_kind
			if types[id] == EnemyType.HALBERD:
				facing_directions[id] = _halberd_horizontal_direction(id, attack_target)
			if attack_kind == ATTACK_KIND_CAVALRY_CHARGE:
				_start_cavalry_charge(id, attack_target)
			enemy_attack_requested.emit(id, positions[id], attack_target, types[id], _damage(types[id]) * damage_multipliers[id] * _command_damage_multiplier(id), attack_timers[id], attack_kind)
	_refresh_duel_phase()

func freeze_for_cinematic() -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		_clear_launch_state(id)
		hurt_timers[id] = 0.0
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		movement_targets[id] = positions[id]
		decision_timers[id] = INF
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		command_surge_timers[id] = 0.0

func unfreeze_for_cinematic() -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		if attack_states[id] != AttackState.APPROACH:
			attack_states[id] = AttackState.APPROACH
			attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		decision_timers[id] = randf_range(0.05, 0.25)
		attack_wait_times[id] = 0.0

func defeat_for_victory_cinematic(maximum_count: int) -> int:
	var defeated_count := 0
	for id in range(CAPACITY):
		if defeated_count >= maximum_count:
			break
		if active[id] == 0:
			continue
		_begin_victory_cinematic_death(id)
		defeated_count += 1
	return defeated_count

func tick_cinematic_deaths(delta: float) -> void:
	for id in range(CAPACITY):
		if active[id] == 0 and death_states[id] != DeathState.NONE:
			_tick_dying(id, delta)

func _begin_victory_cinematic_death(id: int) -> void:
	active[id] = 0
	tianji_lifted[id] = 0
	active_count = maxi(0, active_count - 1)
	if boss_guard_flags[id] == 1:
		boss_guard_flags[id] = 0
		boss_guard_count = maxi(0, boss_guard_count - 1)
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	current_attack_kinds[id] = ""
	knockback_velocities[id] = Vector2.ZERO
	recoil_timers[id] = 0.0
	recoil_velocities[id] = Vector2.ZERO
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	_clear_launch_state(id)
	hurt_timers[id] = 0.0
	hit_feedback_timers[id] = 0.0
	hit_feedback_durations[id] = 0.0
	hit_feedback_strengths[id] = 0.0
	decision_timers[id] = INF
	movement_targets[id] = positions[id]
	death_states[id] = DeathState.FALLING
	death_timers[id] = DEATH_DISPLAY_DURATION
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0

func query(request: AttackRequest) -> Array[int]:
	var results: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		if request.one_hit_per_target and request.hit_targets.has(id):
			continue
		if _request_hits_point(request, positions[id]):
			results.append(id)
	results.sort_custom(func(first_id: int, second_id: int) -> bool:
		var first_priority := _request_target_priority(request, first_id)
		var second_priority := _request_target_priority(request, second_id)
		if is_equal_approx(first_priority, second_priority):
			return first_id < second_id
		return first_priority < second_priority
	)
	if results.size() > request.pierce:
		results.resize(request.pierce)
	return results

func _request_target_priority(request: AttackRequest, id: int) -> float:
	var offset := positions[id] - request.origin
	if request.shape == AttackRequest.Shape.LINE:
		return maxf(0.0, offset.dot(request.direction))
	return offset.length_squared()

func apply_damage(id: int, value: float) -> bool:
	return apply_hit(id, value, Vector2.ZERO, 0.0)

func apply_knockback_only(id: int, direction: Vector2, knockback: float, ignore_knockback_resistance: bool = false, forced_displacement: float = 0.0, forced_displacement_duration: float = 0.0) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1 or direction.length_squared() <= 0.01:
		return
	if is_duel_shield(id) and is_duel_formation_sealed():
		block_duel_shield_hit(id)
		return
	var normalized_direction := direction.normalized()
	var resistance := 1.0 if ignore_knockback_resistance else _knockback_resistance(types[id])
	if is_duel_formation_fodder(id):
		resistance *= 0.20
	var duration := maxf(0.11, forced_displacement_duration)
	var distance := maxf(forced_displacement, knockback * duration * 0.52)
	distance *= resistance
	if distance <= 0.01:
		return
	recoil_timers[id] = maxf(recoil_timers[id], duration)
	recoil_velocities[id] = normalized_direction * distance / duration
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.72)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.085)
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0

func apply_slow(id: int, multiplier: float, duration: float) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1 or duration <= 0.0:
		return
	slow_timers[id] = maxf(slow_timers[id], duration)
	slow_multipliers[id] = minf(slow_multipliers[id], clampf(multiplier, 0.15, 1.0))

func count_active_within(at: Vector2, radius: float) -> int:
	var count := 0
	var radius_squared := radius * radius
	for id in range(CAPACITY):
		if active[id] == 1 and tianji_lifted[id] == 0 and positions[id].distance_squared_to(at) <= radius_squared:
			count += 1
	return count

func apply_hit(id: int, value: float, direction: Vector2, knockback: float, ignore_knockback_resistance: bool = false, forced_displacement: float = 0.0, forced_displacement_duration: float = 0.0) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1:
		return false
	if is_duel_shield(id) and is_duel_formation_sealed():
		block_duel_shield_hit(id)
		return false
	value *= duel_damage_multiplier(id)
	hit_points[id] -= value
	if hit_points[id] > 0.0:
		if attack_states[id] == AttackState.WINDUP:
			_cancel_attack(id, 0.35)
			enemy_attack_cancelled.emit(id)
		var resistance := 1.0 if ignore_knockback_resistance else _knockback_resistance(types[id])
		if knockback > 0.0 and direction.length_squared() > 0.01:
			knockback_velocities[id] = direction.normalized() * knockback * resistance
		if forced_displacement > 0.0 and forced_displacement_duration > 0.0 and direction.length_squared() > 0.01:
			var forced_resistance := 1.0 if ignore_knockback_resistance else _forced_displacement_resistance(types[id])
			forced_displacement_timers[id] = forced_displacement_duration
			forced_displacement_velocities[id] = direction.normalized() * forced_displacement * forced_resistance / forced_displacement_duration
		var hurt_duration := _hurt_duration(types[id])
		if knockback >= 500.0:
			hurt_duration = maxf(hurt_duration, _break_duration(types[id]))
		hurt_duration = maxf(hurt_duration, forced_displacement_duration)
		hurt_timers[id] = hurt_duration
		hit_feedback_strengths[id] = 1.0 + clampf((knockback + forced_displacement * 7.0) / 700.0, 0.0, 0.95)
		hit_feedback_durations[id] = 0.075 + hit_feedback_strengths[id] * 0.045
		hit_feedback_timers[id] = hit_feedback_durations[id]
		desired_behavior_layers[id] = EngagementLayer.ENGAGE
		decision_timers[id] = 0.0
		return false
	_begin_death(id, direction)
	return true

func set_tianji_lifted(id: int, lifted: bool) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	tianji_lifted[id] = 1 if lifted else 0
	if lifted:
		_cancel_attack(id, 0.0)
		enemy_attack_cancelled.emit(id)
		attack_turn_grants[id] = 0
		attack_wait_times[id] = 0.0
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hurt_timers[id] = 0.0
		movement_targets[id] = positions[id]
		decision_timers[id] = INF
	else:
		movement_targets[id] = positions[id]
		decision_timers[id] = 0.0
	return true

func update_tianji_position(id: int, at: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 0:
		return false
	positions[id] = at
	movement_targets[id] = at
	return true

func is_tianji_lifted(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and tianji_lifted[id] == 1

func launch_enemy(id: int, direction: Vector2, speed: float, duration: float, collision_damage: float, collision_knockback: float, collision_targets: int, relay_count: int = 0) -> bool:
	if id < 0 or id >= CAPACITY or (active[id] == 0 and death_states[id] == DeathState.NONE):
		return false
	if not _can_be_launched(id) or direction.length_squared() <= 0.01:
		return false
	if speed <= 0.0 or duration <= 0.0 or collision_targets <= 0:
		return false
	var normalized_direction := direction.normalized()
	launch_timers[id] = duration
	launch_durations[id] = duration
	launch_velocities[id] = normalized_direction * speed
	launch_collision_damages[id] = maxf(1.0, collision_damage)
	launch_collision_knockbacks[id] = maxf(0.0, collision_knockback)
	launch_collision_charges[id] = clampi(collision_targets, 1, 8)
	launch_relay_charges[id] = clampi(relay_count, 0, 1)
	launch_hit_targets[id].clear()
	facing_directions[id] = normalized_direction
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	current_attack_kinds[id] = ""
	knockback_velocities[id] = Vector2.ZERO
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	hurt_timers[id] = maxf(hurt_timers[id], duration)
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 1.65)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.14)
	hit_feedback_timers[id] = hit_feedback_durations[id]
	return true

func is_enemy_launched(id: int) -> bool:
	return id >= 0 and id < CAPACITY and launch_timers[id] > 0.0

func launch_visual_offset(id: int) -> Vector2:
	if not is_enemy_launched(id) or launch_durations[id] <= 0.0:
		return Vector2.ZERO
	var progress := clampf(1.0 - launch_timers[id] / launch_durations[id], 0.0, 1.0)
	return Vector2.UP * sin(progress * PI) * 38.0

func _tick_enemy_launch(id: int, delta: float) -> void:
	launch_timers[id] = maxf(0.0, launch_timers[id] - delta)
	var velocity := launch_velocities[id]
	var direction := velocity.normalized()
	if direction.length_squared() > 0.01:
		var start_position := positions[id]
		positions[id] += velocity * delta
		launch_velocities[id] = velocity.move_toward(Vector2.ZERO, LAUNCH_DECELERATION * delta)
		_clamp_position(id)
		_apply_launch_collision(id, direction, start_position, positions[id])
	if launch_timers[id] <= 0.0 or launch_velocities[id].length() < LAUNCH_MIN_SPEED:
		_stop_enemy_launch(id)

func _apply_launch_collision(source_id: int, direction: Vector2, start_position: Vector2, end_position: Vector2) -> void:
	if launch_collision_charges[source_id] <= 0:
		return
	var target_id := -1
	var nearest_travel := INF
	var travel_distance := start_position.distance_to(end_position)
	for candidate_id in range(CAPACITY):
		if candidate_id == source_id or active[candidate_id] == 0 or launch_hit_targets[source_id].has(candidate_id):
			continue
		var offset := positions[candidate_id] - start_position
		var forward_travel := offset.dot(direction)
		if forward_travel < -LAUNCH_COLLISION_RADIUS or forward_travel > travel_distance + LAUNCH_COLLISION_RADIUS:
			continue
		var closest_position := start_position + direction * clampf(forward_travel, 0.0, travel_distance)
		if positions[candidate_id].distance_squared_to(closest_position) > LAUNCH_COLLISION_RADIUS * LAUNCH_COLLISION_RADIUS or forward_travel >= nearest_travel:
			continue
		target_id = candidate_id
		nearest_travel = forward_travel
	if target_id < 0:
		return
	launch_hit_targets[source_id][target_id] = true
	launch_collision_charges[source_id] -= 1
	var target_defeated := apply_hit(target_id, launch_collision_damages[source_id], direction, launch_collision_knockbacks[source_id], true, 48.0, 0.10)
	enemy_death_collision.emit(positions[target_id], direction)
	if target_defeated and launch_relay_charges[source_id] > 0:
		var inherited_speed := maxf(LAUNCH_MIN_SPEED, launch_velocities[source_id].length() * 0.78)
		var inherited_duration := maxf(0.22, launch_timers[source_id] * 0.82)
		var inherited_targets := mini(2, launch_collision_charges[source_id] + 1)
		launch_relay_charges[source_id] = 0
		if launch_enemy(target_id, direction, inherited_speed, inherited_duration, launch_collision_damages[source_id] * 0.85, launch_collision_knockbacks[source_id] * 0.82, inherited_targets, 0):
			_stop_enemy_launch(source_id)

func _stop_enemy_launch(id: int) -> void:
	var was_active := active[id] == 1
	_clear_launch_state(id)
	if was_active:
		hurt_timers[id] = maxf(hurt_timers[id], 0.12)
		decision_timers[id] = 0.0

func _can_be_launched(id: int) -> bool:
	return types[id] not in [EnemyType.SHIELD, EnemyType.ELITE, EnemyType.GUARD, EnemyType.CAVALRY]

func _clear_launch_state(id: int) -> void:
	launch_timers[id] = 0.0
	launch_durations[id] = 0.0
	launch_velocities[id] = Vector2.ZERO
	launch_collision_damages[id] = 0.0
	launch_collision_knockbacks[id] = 0.0
	launch_collision_charges[id] = 0
	launch_relay_charges[id] = 0
	launch_hit_targets[id] = {}

func get_armor(id: int) -> float:
	return armor[id]

func get_type(id: int) -> int:
	return types[id]

func is_active(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1

func is_dying(id: int) -> bool:
	return id >= 0 and id < CAPACITY and death_states[id] != DeathState.NONE

func death_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	return clampf(1.0 - death_timers[id] / DEATH_DISPLAY_DURATION, 0.0, 1.0)

func death_animation_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	var elapsed := DEATH_DISPLAY_DURATION - death_timers[id]
	return clampf(elapsed / DEATH_ANIMATION_DURATION, 0.0, 1.0)

func death_fade_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	var elapsed := DEATH_DISPLAY_DURATION - death_timers[id]
	return clampf((elapsed - DEATH_FADE_DELAY) / (DEATH_DISPLAY_DURATION - DEATH_FADE_DELAY), 0.0, 1.0)

func is_death_launched(id: int) -> bool:
	return is_dying(id) and death_states[id] == DeathState.LAUNCHED

func get_hurt_timer(id: int) -> float:
	return hurt_timers[id] if id >= 0 and id < CAPACITY else 0.0

func get_hit_feedback_ratio(id: int) -> float:
	if id < 0 or id >= CAPACITY or hit_feedback_durations[id] <= 0.0:
		return 0.0
	return clampf(hit_feedback_timers[id] / hit_feedback_durations[id], 0.0, 1.0)

func get_hit_feedback_strength(id: int) -> float:
	return hit_feedback_strengths[id] if id >= 0 and id < CAPACITY else 0.0

func get_behavior_layer(id: int) -> int:
	return behavior_layers[id] if id >= 0 and id < CAPACITY else EngagementLayer.ATMOSPHERE

func has_movement_intent(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	if launch_timers[id] > 0.0:
		return false
	if attack_states[id] != AttackState.APPROACH or hurt_timers[id] > 0.0:
		return false
	return movement_targets[id].distance_squared_to(positions[id]) > 4.0

func is_being_displaced(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	return launch_timers[id] > 0.0 or recoil_timers[id] > 0.0 or forced_displacement_timers[id] > 0.0 or knockback_velocities[id].length_squared() > 16.0

func get_knockback_direction(id: int) -> Vector2:
	if id < 0 or id >= CAPACITY:
		return Vector2.ZERO
	if launch_timers[id] > 0.0:
		return launch_velocities[id].normalized()
	if forced_displacement_timers[id] > 0.0:
		return forced_displacement_velocities[id].normalized()
	if recoil_timers[id] > 0.0:
		return recoil_velocities[id].normalized()
	return knockback_velocities[id].normalized()

func get_attack_state(id: int) -> int:
	return attack_states[id] if id >= 0 and id < CAPACITY else AttackState.APPROACH

func get_attack_remaining(id: int) -> float:
	return attack_timers[id] if id >= 0 and id < CAPACITY else 0.0

func cancel_attack(id: int) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return
	_cancel_attack(id, 0.35)

func resolve_spear_clash(id: int, direction: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.SPEAR:
		return false
	_cancel_attack(id, SPEAR_CLASH_COOLDOWN)
	spear_combo_stages[id] = 0
	spear_combo_timers[id] = 0.0
	var recoil_direction := direction.normalized()
	if recoil_direction.length_squared() <= 0.01:
		recoil_direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	knockback_velocities[id] = recoil_direction * SPEAR_CLASH_KNOCKBACK
	hurt_timers[id] = SPEAR_CLASH_HURT_DURATION
	hit_feedback_strengths[id] = 1.35
	hit_feedback_durations[id] = 0.12
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0
	enemy_attack_cancelled.emit(id)
	return true

func resolve_cavalry_clash(id: int, direction: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.CAVALRY:
		return false
	_cancel_attack(id, CAVALRY_CLASH_COOLDOWN)
	var recoil_direction := direction.normalized()
	if recoil_direction.length_squared() <= 0.01:
		recoil_direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	knockback_velocities[id] = recoil_direction * CAVALRY_CLASH_KNOCKBACK
	hurt_timers[id] = CAVALRY_CLASH_HURT_DURATION
	hit_feedback_strengths[id] = 1.48
	hit_feedback_durations[id] = 0.13
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0
	enemy_attack_cancelled.emit(id)
	return true

func issue_banner_command(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.BANNER:
		return false
	var affected := false
	for target_id in range(CAPACITY):
		if active[target_id] == 0 or types[target_id] == EnemyType.BANNER:
			continue
		if positions[target_id].distance_squared_to(positions[id]) > BANNER_COMMAND_RADIUS * BANNER_COMMAND_RADIUS:
			continue
		command_surge_timers[target_id] = maxf(command_surge_timers[target_id], BANNER_COMMAND_DURATION)
		affected = true
	return affected

func command_aura_ratio(id: int) -> float:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return 0.0
	if command_surge_timers[id] > 0.0:
		return 1.0
	return command_aura_strengths[id] * 0.58

func is_banner_commanding(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and types[id] == EnemyType.BANNER and attack_states[id] == AttackState.WINDUP and current_attack_kinds[id] == ATTACK_KIND_BANNER_COMMAND

func is_cavalry_charging(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and cavalry_charge_distances[id] > 0.01

func get_facing_direction(id: int) -> Vector2:
	return facing_directions[id] if id >= 0 and id < CAPACITY else Vector2.DOWN

func get_boss_guard_count() -> int:
	return boss_guard_count

func attack_telegraph_limit(enemy_type: int) -> int:
	var group := _attack_group_for_type(enemy_type)
	if group == "archer":
		return _archer_attack_slots()
	if group == "crossbow":
		return _crossbow_attack_slots()
	if group == "halberd":
		return _halberd_attack_slots()
	if group == "spear":
		return _spear_attack_slots()
	if group == "banner":
		return _banner_attack_slots()
	if group == "cavalry":
		return _cavalry_attack_slots()
	return _frontline_attack_slots()

func gold_reward(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.BANNER: return 0
		EnemyType.ELITE: return 60
		EnemyType.SWORD, EnemyType.ARCHER:
			return 1 if randf() <= 0.12 else 0
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY:
			return 2 if randf() <= 0.16 else 0
		_: return 0

func _begin_death(id: int, direction: Vector2) -> void:
	var type := types[id]
	var at := positions[id]
	var duel_role := duel_roles[id]
	var duel_slot := duel_slots[id]
	tianji_lifted[id] = 0
	if duel_role != DuelRole.NONE:
		duel_fodder_death_ids[id] = true
		var slot_key := _duel_slot_key(duel_role, duel_slot)
		if slot_key >= 0 and slot_key < duel_slot_refill_timers.size():
			duel_slot_refill_timers[slot_key] = randf_range(DUEL_REINFORCEMENT_DELAY_MIN, DUEL_REINFORCEMENT_DELAY_MAX)
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
	var preserves_launch := launch_timers[id] > 0.0
	active[id] = 0
	active_count -= 1
	if boss_guard_flags[id] == 1:
		boss_guard_flags[id] = 0
		boss_guard_count -= 1
	death_states[id] = DeathState.LAUNCHED if preserves_launch else DeathState.FALLING
	death_timers[id] = DEATH_DISPLAY_DURATION
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	if not preserves_launch and direction.length_squared() > 0.01 and randf() <= DEATH_LAUNCH_CHANCE:
		death_states[id] = DeathState.LAUNCHED
		death_velocities[id] = direction.normalized() * DEATH_LAUNCH_SPEED
		death_impact_charges[id] = DEATH_COLLISION_MAX_TARGETS
	enemy_died.emit(id, type, at, _experience(type), _ultimate_energy(type))

func _tick_dying(id: int, delta: float) -> void:
	death_timers[id] = maxf(0.0, death_timers[id] - delta)
	if launch_timers[id] > 0.0:
		_tick_enemy_launch(id, delta)
	elif death_states[id] == DeathState.LAUNCHED:
		var direction := death_velocities[id].normalized()
		positions[id] += death_velocities[id] * delta
		death_velocities[id] = death_velocities[id].move_toward(Vector2.ZERO, DEATH_LAUNCH_DECELERATION * delta)
		_clamp_position(id)
		if direction.length_squared() > 0.01:
			_apply_death_launch_collision(id, direction)
	if death_timers[id] <= 0.0:
		_recycle_dead(id)

func _apply_death_launch_collision(source_id: int, direction: Vector2) -> void:
	if death_impact_charges[source_id] <= 0:
		return
	for target_id in range(CAPACITY):
		if active[target_id] == 0:
			continue
		if positions[source_id].distance_squared_to(positions[target_id]) > DEATH_COLLISION_RADIUS * DEATH_COLLISION_RADIUS:
			continue
		death_impact_charges[source_id] -= 1
		apply_hit(target_id, DEATH_COLLISION_DAMAGE, direction, DEATH_COLLISION_KNOCKBACK)
		enemy_death_collision.emit(positions[target_id], direction)
		return

func _recycle_dead(id: int) -> void:
	tianji_lifted[id] = 0
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	_clear_launch_state(id)
	free_ids.append(id)

func _maintain_duel_formation(delta: float) -> void:
	if not is_duel_formation_active() or free_ids.is_empty():
		return
	# Fill the open slots nearest the player's current approach first.  Each
	# reinforcement still spawns on that slot's outward radial line, so the
	# replacement visibly comes from the side of the actual gap.
	var missing_slots: Array[Dictionary] = []
	for role in [DuelRole.SHIELD_RING, DuelRole.SPEAR_RING, DuelRole.RANGED_RING]:
		var slot_count := _duel_slot_count(role)
		for slot in range(slot_count):
			var slot_key := _duel_slot_key(role, slot)
			if slot_key < 0 or slot_key >= duel_slot_refill_timers.size():
				continue
			if _duel_member_for_slot(role, slot) >= 0:
				duel_slot_refill_timers[slot_key] = 0.0
				continue
			missing_slots.append({"role": role, "slot": slot, "key": slot_key})
	missing_slots.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_position := _duel_slot_position(int(first["role"]), int(first["slot"]))
		var second_position := _duel_slot_position(int(second["role"]), int(second["slot"]))
		return first_position.distance_squared_to(last_player_position) < second_position.distance_squared_to(last_player_position)
	)
	var spawned := 0
	for missing in missing_slots:
		if spawned >= 2 or duel_reinforcement_spawn_remaining > 0.0:
			break
		var role := int(missing["role"])
		var slot := int(missing["slot"])
		var slot_key := int(missing["key"])
		if duel_slot_refill_timers[slot_key] > 0.0:
			duel_slot_refill_timers[slot_key] = maxf(0.0, duel_slot_refill_timers[slot_key] - delta)
			continue
		var id := spawn(_duel_reinforcement_type(role, slot), _duel_reinforcement_position(role, slot))
		if id < 0:
			return
		duel_roles[id] = role
		duel_slots[id] = slot
		decision_timers[id] = 0.0
		duel_slot_refill_timers[slot_key] = 0.0
		duel_reinforcement_spawn_remaining = DUEL_REINFORCEMENT_SPAWN_INTERVAL
		spawned += 1

func _rebuild_spatial_cells() -> void:
	spatial_cells.clear()
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		var cell := _spatial_cell_for(positions[id])
		var members: Array = spatial_cells.get(cell, [])
		members.append(id)
		spatial_cells[cell] = members

func _separation_vector(id: int) -> Vector2:
	var cell := _spatial_cell_for(positions[id])
	var separation := Vector2.ZERO
	var neighbor_count := 0
	for offset_y in range(-1, 2):
		for offset_x in range(-1, 2):
			var members: Array = spatial_cells.get(cell + Vector2i(offset_x, offset_y), [])
			for other_id in members:
				if other_id == id or active[other_id] == 0 or tianji_lifted[other_id] == 1:
					continue
				var offset := positions[id] - positions[other_id]
				var distance := offset.length()
				var personal_space := maxf(_personal_space(types[id]), _personal_space(types[other_id]))
				if distance >= personal_space:
					continue
				var direction: Vector2
				if distance > 0.01:
					direction = offset / distance
				else:
					var fallback_angle := deg_to_rad(float((id * 37 + other_id * 17) % 360))
					direction = Vector2.from_angle(fallback_angle)
				separation += direction * (1.0 - distance / personal_space)
				neighbor_count += 1
				if neighbor_count >= MAX_SEPARATION_NEIGHBORS:
					return (separation / float(neighbor_count)).limit_length(1.0)
	if neighbor_count == 0:
		return Vector2.ZERO
	return (separation / float(neighbor_count)).limit_length(1.0)

func _separation_refresh_interval(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return PRESSURE_SEPARATION_REFRESH_INTERVAL
		EngagementLayer.ATMOSPHERE: return ATMOSPHERE_SEPARATION_REFRESH_INTERVAL
		_: return 0.0

func _assign_desired_behavior_layers(player_position: Vector2) -> void:
	if is_duel_formation_active():
		for id in range(CAPACITY):
			if active[id] == 0 or tianji_lifted[id] == 1:
				continue
			desired_behavior_layers[id] = EngagementLayer.ENGAGE if duel_roles[id] != DuelRole.NONE else EngagementLayer.ATMOSPHERE
		return
	var melee_ids: Array[int] = []
	var halberd_ids: Array[int] = []
	var archer_ids: Array[int] = []
	var elite_ids: Array[int] = []
	var spear_ids: Array[int] = []
	var crossbow_ids: Array[int] = []
	var banner_ids: Array[int] = []
	var cavalry_ids: Array[int] = []
	var active_count := 0
	var nearby_pressure_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		active_count += 1
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		match types[id]:
			EnemyType.ARCHER:
				archer_ids.append(id)
			EnemyType.HALBERD:
				halberd_ids.append(id)
			EnemyType.ELITE:
				elite_ids.append(id)
			EnemyType.SPEAR:
				spear_ids.append(id)
			EnemyType.CROSSBOW:
				crossbow_ids.append(id)
			EnemyType.BANNER:
				banner_ids.append(id)
			EnemyType.CAVALRY:
				cavalry_ids.append(id)
			_:
				melee_ids.append(id)
	_assign_nearest_layer(melee_ids, _engage_melee_limit(), player_position)
	_assign_nearest_layer(halberd_ids, ENGAGE_HALBERD_LIMIT, player_position)
	_assign_nearest_layer(archer_ids, _engage_archer_limit(), player_position)
	_assign_nearest_layer(elite_ids, ENGAGE_ELITE_LIMIT, player_position)
	_assign_nearest_layer(spear_ids, _engage_spear_limit(), player_position)
	_assign_nearest_layer(crossbow_ids, _engage_crossbow_limit(), player_position)
	_assign_nearest_layer(banner_ids, ENGAGE_BANNER_LIMIT, player_position)
	_assign_nearest_layer(cavalry_ids, _engage_cavalry_limit(), player_position)
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or desired_behavior_layers[id] == EngagementLayer.ENGAGE:
			continue
		var pressure_radius := _desired_range(types[id]) + 205.0
		if positions[id].distance_to(player_position) <= pressure_radius:
			if types[id] in [EnemyType.SWORD, EnemyType.SHIELD, EnemyType.SPEAR, EnemyType.HALBERD, EnemyType.CAVALRY]:
				nearby_pressure_ids.append(id)
			else:
				desired_behavior_layers[id] = EngagementLayer.PRESSURE
	nearby_pressure_ids.sort_custom(func(first: int, second: int) -> bool:
		return positions[first].distance_squared_to(player_position) < positions[second].distance_squared_to(player_position)
	)
	# Once the field is populated, rotate a few nearby pressure units into the
	# frontline. This creates an encirclement without allowing every soldier to
	# attack at once; attack-turn slots still control actual swings.
	var extra_engage_budget := mini(4, maxi(0, int(floor(float(active_count - 12) / 12.0))))
	if battle_mode == "story" and battle_elapsed < 180.0:
		extra_engage_budget = mini(4, extra_engage_budget + 1)
	for index in range(mini(extra_engage_budget, nearby_pressure_ids.size())):
		desired_behavior_layers[nearby_pressure_ids[index]] = EngagementLayer.ENGAGE
	for id in nearby_pressure_ids:
		if desired_behavior_layers[id] == EngagementLayer.ATMOSPHERE:
			desired_behavior_layers[id] = EngagementLayer.PRESSURE

func _update_attack_wait_times(delta: float) -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		if behavior_layers[id] == EngagementLayer.ENGAGE and attack_states[id] == AttackState.APPROACH and hurt_timers[id] <= 0.0:
			attack_wait_times[id] = minf(8.0, attack_wait_times[id] + delta)

func _assign_attack_turns(player_position: Vector2) -> void:
	var previous_grants := attack_turn_grants.duplicate()
	var frontline_candidates: Array[int] = []
	var archer_candidates: Array[int] = []
	var halberd_candidates: Array[int] = []
	var spear_candidates: Array[int] = []
	var crossbow_candidates: Array[int] = []
	var banner_candidates: Array[int] = []
	var cavalry_candidates: Array[int] = []
	var frontline_occupied := 0
	var archer_occupied := 0
	var halberd_occupied := 0
	var spear_occupied := 0
	var crossbow_occupied := 0
	var banner_occupied := 0
	var cavalry_occupied := 0
	for id in range(CAPACITY):
		attack_turn_grants[id] = 0
		if active[id] == 0 or tianji_lifted[id] == 1 or behavior_layers[id] != EngagementLayer.ENGAGE:
			continue
		var group := _attack_group_for_type(types[id])
		if attack_states[id] != AttackState.APPROACH:
			# Recovery releases the attack position immediately so another soldier can rotate in.
			if attack_states[id] == AttackState.WINDUP:
				if group == "frontline":
					frontline_occupied += 1
				elif group == "archer":
					archer_occupied += 1
				elif group == "crossbow":
					crossbow_occupied += 1
				elif group == "spear":
					spear_occupied += 1
				elif group == "banner":
					banner_occupied += 1
				elif group == "cavalry":
					cavalry_occupied += 1
				else:
					halberd_occupied += 1
			continue
		var within_staging_range := positions[id].distance_to(player_position) <= _attack_staging_range(types[id])
		if is_duel_formation_member(id):
			within_staging_range = true
		if cooldowns[id] > 0.0 or not within_staging_range:
			continue
		if group == "frontline":
			frontline_candidates.append(id)
		elif group == "archer":
			archer_candidates.append(id)
		elif group == "crossbow":
			crossbow_candidates.append(id)
		elif group == "spear":
			spear_candidates.append(id)
		elif group == "banner":
			banner_candidates.append(id)
		elif group == "cavalry":
			cavalry_candidates.append(id)
		else:
			halberd_candidates.append(id)
	_assign_attack_group_grants(frontline_candidates, maxi(0, _frontline_attack_slots() - frontline_occupied), player_position)
	_assign_attack_group_grants(archer_candidates, maxi(0, _archer_attack_slots() - archer_occupied), player_position)
	_assign_attack_group_grants(halberd_candidates, maxi(0, _halberd_attack_slots() - halberd_occupied), player_position)
	_assign_attack_group_grants(spear_candidates, maxi(0, _spear_attack_slots() - spear_occupied), player_position)
	_assign_attack_group_grants(crossbow_candidates, maxi(0, _crossbow_attack_slots() - crossbow_occupied), player_position)
	_assign_attack_group_grants(banner_candidates, maxi(0, _banner_attack_slots() - banner_occupied), player_position)
	_assign_attack_group_grants(cavalry_candidates, maxi(0, _cavalry_attack_slots() - cavalry_occupied), player_position)
	_limit_duel_formation_attack_turns()
	for id in range(CAPACITY):
		if active[id] == 1 and previous_grants[id] != attack_turn_grants[id]:
			decision_timers[id] = 0.0

func _assign_attack_group_grants(candidates: Array[int], available_slots: int, player_position: Vector2) -> void:
	if available_slots <= 0:
		return
	candidates.sort_custom(func(first: int, second: int) -> bool:
		if not is_equal_approx(attack_wait_times[first], attack_wait_times[second]):
			return attack_wait_times[first] > attack_wait_times[second]
		return decision_cycles[first] < decision_cycles[second]
	)
	var granted := 0
	var used_sectors: Dictionary = {}
	for candidate in candidates:
		var sector := _attack_sector(candidate, player_position)
		if used_sectors.has(sector):
			continue
		attack_turn_grants[candidate] = 1
		used_sectors[sector] = true
		granted += 1
		if granted >= available_slots:
			return
	for candidate in candidates:
		if attack_turn_grants[candidate] == 1:
			continue
		attack_turn_grants[candidate] = 1
		granted += 1
		if granted >= available_slots:
			return

func _limit_duel_formation_attack_turns() -> void:
	if not is_duel_formation_active():
		return
	if duel_phase == DuelPhase.ASSEMBLING:
		for id in range(CAPACITY):
			if duel_roles[id] != DuelRole.NONE:
				attack_turn_grants[id] = 0
		return
	var shield_grants := 0
	var spear_grants := 0
	var ranged_grants := 0
	for id in range(CAPACITY):
		if attack_turn_grants[id] == 0 or duel_roles[id] == DuelRole.NONE:
			continue
		match duel_roles[id]:
			DuelRole.SHIELD_RING:
				if shield_grants >= DUEL_SHIELD_PUSH_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					shield_grants += 1
			DuelRole.SPEAR_RING:
				if spear_grants >= DUEL_SPEAR_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					spear_grants += 1
			DuelRole.RANGED_RING:
				if ranged_grants >= DUEL_RANGED_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					ranged_grants += 1

func _attack_sector(id: int, player_position: Vector2) -> int:
	var angle := (positions[id] - player_position).angle() + PI
	return clampi(floori(angle / (TAU * 0.25)), 0, 3)

func _attack_group_for_type(enemy_type: int) -> String:
	if enemy_type == EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemyType.CROSSBOW:
		return "crossbow"
	if enemy_type == EnemyType.HALBERD or enemy_type == EnemyType.ELITE:
		return "halberd"
	if enemy_type == EnemyType.SPEAR:
		return "spear"
	if enemy_type == EnemyType.BANNER:
		return "banner"
	if enemy_type == EnemyType.CAVALRY:
		return "cavalry"
	return "frontline"

func _attack_staging_range(enemy_type: int) -> float:
	if enemy_type == EnemyType.ARCHER:
		return _attack_range(enemy_type) + 70.0
	if enemy_type == EnemyType.CROSSBOW:
		return _attack_range(enemy_type) + 82.0
	if enemy_type == EnemyType.SPEAR:
		return _attack_range(enemy_type) + 48.0
	if enemy_type == EnemyType.BANNER:
		return _attack_range(enemy_type) + 54.0
	if enemy_type == EnemyType.CAVALRY:
		return _attack_range(enemy_type) + 66.0
	return _attack_range(enemy_type) + 145.0

func _assign_nearest_layer(ids: Array[int], limit: int, player_position: Vector2) -> void:
	ids.sort_custom(func(first: int, second: int) -> bool:
		return positions[first].distance_squared_to(player_position) < positions[second].distance_squared_to(player_position)
	)
	for index in range(mini(limit, ids.size())):
		desired_behavior_layers[ids[index]] = EngagementLayer.ENGAGE

func _refresh_movement_decision(id: int, player_position: Vector2) -> void:
	var layer := int(desired_behavior_layers[id])
	behavior_layers[id] = layer
	decision_cycles[id] += 1
	var target := _formation_target(id, player_position, layer)
	var patrol_radius := 0.0 if duel_roles[id] != DuelRole.NONE else _patrol_radius(layer)
	var patrol_angle := deg_to_rad(float((id * 47 + decision_cycles[id] * 29) % 360))
	patrol_offsets[id] = Vector2.from_angle(patrol_angle) * patrol_radius
	movement_targets[id] = _clamp_point(target + patrol_offsets[id])
	var facing_target := player_position if layer == EngagementLayer.ENGAGE else movement_targets[id]
	if duel_roles[id] == DuelRole.SHIELD_RING:
		facing_target = duel_center
	var desired_facing := (facing_target - positions[id]).normalized()
	if desired_facing.length_squared() > 0.01:
		facing_directions[id] = desired_facing
	decision_timers[id] = _reaction_delay(layer, id, decision_cycles[id])

func _navigation_direction_for(id: int, target: Vector2) -> Vector2:
	var direct := target - positions[id]
	if direct.length_squared() <= 0.01:
		navigation_waypoint_active[id] = 0
		return Vector2.ZERO
	if navigation_obstacles.is_empty():
		return direct.normalized()
	if navigation_waypoint_active[id] == 1 and positions[id].distance_to(navigation_waypoints[id]) <= NAVIGATION_WAYPOINT_ARRIVAL:
		navigation_waypoint_active[id] = 0
	if navigation_replan_timers[id] <= 0.0 or not navigation_waypoint_active[id] or navigation_targets[id].distance_to(target) > NAVIGATION_TARGET_SHIFT:
		var waypoint := BATTLEFIELD_LAYOUT.navigation_waypoint_for(
			positions[id],
			target,
			navigation_obstacles,
			_collision_radius_for_navigation(types[id]),
			navigation_preferred_sides[id]
		)
		navigation_waypoints[id] = waypoint
		navigation_targets[id] = target
		navigation_waypoint_active[id] = 1 if waypoint.length_squared() > 0.01 else 0
		navigation_replan_timers[id] = NAVIGATION_REPLAN_INTERVAL
	if navigation_waypoint_active[id] == 1:
		return (navigation_waypoints[id] - positions[id]).normalized()
	return direct.normalized()

func _collision_radius_for_navigation(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.CAVALRY:
			return 28.0
		EnemyType.BANNER:
			return 24.0
		EnemyType.SHIELD, EnemyType.HALBERD:
			return 20.0
		_:
			return 17.0

func _formation_target(id: int, player_position: Vector2, layer: int) -> Vector2:
	if is_duel_formation_active():
		if duel_roles[id] != DuelRole.NONE:
			return _duel_slot_position(duel_roles[id], duel_slots[id])
		var reserve_direction := (positions[id] - duel_center).normalized()
		if reserve_direction.length_squared() <= 0.01:
			reserve_direction = Vector2.from_angle(float(id) * 0.618)
		return duel_center + reserve_direction * 440.0
	var enemy_type := types[id]
	if enemy_type == EnemyType.SPEAR and layer == EngagementLayer.ENGAGE:
		var side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			side = -1.0 if id % 2 == 0 else 1.0
		var lane_offset := float(id % 3 - 1) * 28.0
		var holding_range := _desired_range(enemy_type) + (54.0 if attack_turn_grants[id] == 0 else 0.0)
		return player_position + Vector2(side * holding_range, lane_offset)
	if enemy_type == EnemyType.CAVALRY and layer == EngagementLayer.ENGAGE:
		var cavalry_side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			cavalry_side = -1.0 if id % 2 == 0 else 1.0
		var cavalry_lane_offset := float(id % 3 - 1) * 24.0
		var cavalry_holding_range := _desired_range(enemy_type) + (72.0 if attack_turn_grants[id] == 0 else 0.0)
		return player_position + Vector2(cavalry_side * cavalry_holding_range, cavalry_lane_offset)
	if enemy_type == EnemyType.BANNER and layer == EngagementLayer.ENGAGE:
		var banner_side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			banner_side = -1.0 if id % 2 == 0 else 1.0
		return player_position + Vector2(banner_side * _desired_range(enemy_type), float(id % 3 - 1) * 42.0)
	var squad_index := floori(float(id) / float(FORMATION_SQUAD_SIZE))
	var squad_slot := id % FORMATION_SQUAD_SIZE
	var sector_index := squad_index % FORMATION_SECTOR_ANGLES.size()
	var ring_index := floori(float(squad_index) / float(FORMATION_SECTOR_ANGLES.size())) % 3
	var battalion_index := floori(float(squad_index) / 9.0)
	var centered_slot := float(squad_slot) - float(FORMATION_SQUAD_SIZE - 1) * 0.5
	var squad_drift := sin(formation_time * 0.22 + float(squad_index) * 1.37) * 0.035
	var angle: float = float(FORMATION_SECTOR_ANGLES[sector_index]) + centered_slot * FORMATION_SLOT_ANGLE_STEP + squad_drift + float(battalion_index) * 0.10
	var radius := _desired_range(enemy_type) + _formation_ring_spacing(enemy_type) * ring_index + float(battalion_index) * 18.0
	if layer == EngagementLayer.ENGAGE and attack_turn_grants[id] == 0:
		radius += 64.0 + float(ring_index) * 12.0
	if layer == EngagementLayer.PRESSURE:
		radius += 108.0 + float(ring_index) * 18.0
	elif layer == EngagementLayer.ATMOSPHERE:
		radius += 178.0 + float(ring_index) * 20.0
	return player_position + Vector2.from_angle(angle) * radius

func _layer_speed_multiplier(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 0.72
		EngagementLayer.ATMOSPHERE: return 0.48
		_: return 1.0

func _patrol_radius(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 12.0
		EngagementLayer.ATMOSPHERE: return 9.0
		_: return 4.0

func _reaction_delay(layer: int, id: int, cycle: int) -> float:
	var jitter := float((id * 37 + cycle * 19) % 100) / 100.0
	match layer:
		EngagementLayer.PRESSURE: return 0.35 + jitter * 0.55
		EngagementLayer.ATMOSPHERE: return 1.0 + jitter * 1.20
		_: return 0.10 + jitter * 0.20

func _track_player_motion(delta: float, player_position: Vector2) -> void:
	if has_player_position:
		var instantaneous_velocity := (player_position - last_player_position) / maxf(0.001, delta)
		player_velocity = player_velocity.lerp(instantaneous_velocity.limit_length(360.0), 0.48)
	else:
		has_player_position = true
	last_player_position = player_position

func _predicted_player_position(lead_time: float) -> Vector2:
	return _clamp_point(last_player_position + player_velocity.limit_length(280.0) * lead_time)

func _attack_trigger_range(id: int, player_position: Vector2) -> float:
	if types[id] == EnemyType.HALBERD and _player_is_rushing_toward(id, player_position):
		return HALBERD_BRACE_MAX_DISTANCE
	return _attack_range(types[id])

func _can_trigger_attack(id: int, player_position: Vector2, distance: float) -> bool:
	if is_duel_formation_active():
		if duel_phase == DuelPhase.ASSEMBLING:
			return false
		match duel_roles[id]:
			DuelRole.SHIELD_RING:
				return is_player_near_duel_boundary(player_position, 0.84) and distance <= 118.0 and randf() <= 0.34
			DuelRole.SPEAR_RING:
				return is_player_near_duel_boundary(player_position, 0.82) and distance <= 240.0 and randf() <= 0.22
			DuelRole.RANGED_RING:
				return duel_phase == DuelPhase.SEALED and duel_ranged_attack_cooldown <= 0.0 and _is_duel_member_in_position(id) and distance <= DUEL_RANGED_RADIUS.x + 80.0
	if types[id] != EnemyType.SPEAR and types[id] != EnemyType.CAVALRY:
		return distance <= _attack_trigger_range(id, player_position)
	var offset := player_position - positions[id]
	var half_width := SPEAR_LINE_HALF_WIDTH if types[id] == EnemyType.SPEAR else CAVALRY_LINE_HALF_WIDTH
	return absf(offset.x) <= _attack_range(types[id]) and absf(offset.y) <= half_width

func _choose_attack_kind(id: int, player_position: Vector2, distance: float) -> String:
	if is_duel_formation_active():
		if duel_roles[id] == DuelRole.SHIELD_RING:
			return ATTACK_KIND_DUEL_SHIELD_PUSH
		if duel_roles[id] == DuelRole.SPEAR_RING:
			return ATTACK_KIND_DUEL_SPEAR_THRUST
		if duel_roles[id] == DuelRole.RANGED_RING:
			duel_ranged_attack_cooldown = randf_range(DUEL_RANGED_ATTACK_COOLDOWN_MIN, DUEL_RANGED_ATTACK_COOLDOWN_MAX)
			return ATTACK_KIND_CROSSBOW_DIRECT if types[id] == EnemyType.CROSSBOW else ATTACK_KIND_ARCHER_DIRECT
	match types[id]:
		EnemyType.ARCHER:
			if _can_start_archer_volley():
				archer_volley_cooldown = ARCHER_VOLLEY_ENDLESS_COOLDOWN if battle_mode == "endless" else ARCHER_VOLLEY_COOLDOWN
				return ATTACK_KIND_ARCHER_VOLLEY
			if player_velocity.length() >= ARCHER_LEAD_SPEED_THRESHOLD:
				return ATTACK_KIND_ARCHER_LEAD
			return ATTACK_KIND_ARCHER_DIRECT
		EnemyType.HALBERD:
			if _player_is_rushing_toward(id, player_position):
				return ATTACK_KIND_HALBERD_BRACE
			return ATTACK_KIND_HALBERD_SWEEP
		EnemyType.SPEAR:
			if spear_combo_stages[id] == 1:
				spear_combo_stages[id] = 0
				spear_combo_timers[id] = 0.0
				return ATTACK_KIND_SPEAR_THRUST_2
			if _can_start_spear_formation():
				spear_formation_cooldown = SPEAR_FORMATION_COOLDOWN
				return ATTACK_KIND_SPEAR_FORMATION
			spear_combo_stages[id] = 1
			spear_combo_timers[id] = 1.25
			return ATTACK_KIND_SPEAR_THRUST_1
		EnemyType.CROSSBOW:
			if _can_start_crossbow_volley():
				crossbow_volley_cooldown = CROSSBOW_VOLLEY_ENDLESS_COOLDOWN if battle_mode == "endless" else CROSSBOW_VOLLEY_COOLDOWN
				return ATTACK_KIND_CROSSBOW_VOLLEY
			return ATTACK_KIND_CROSSBOW_DIRECT
		EnemyType.BANNER:
			return ATTACK_KIND_BANNER_COMMAND
		EnemyType.CAVALRY:
			var horizontal_distance := absf(player_position.x - positions[id].x)
			if cavalry_charge_cooldowns[id] <= 0.0 and horizontal_distance >= 84.0:
				cavalry_charge_cooldowns[id] = CAVALRY_CHARGE_COOLDOWN
				return ATTACK_KIND_CAVALRY_CHARGE
			return ATTACK_KIND_CAVALRY_STAB
	return ATTACK_KIND_DEFAULT

func _attack_target_for_kind(id: int, attack_kind: String, player_position: Vector2) -> Vector2:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH:
			return player_position
		ATTACK_KIND_DUEL_SPEAR_THRUST:
			return player_position
		ATTACK_KIND_ARCHER_LEAD:
			return _predicted_player_position(0.24)
		ATTACK_KIND_ARCHER_VOLLEY:
			return _predicted_player_position(0.30)
		ATTACK_KIND_CROSSBOW_DIRECT:
			return _predicted_player_position(0.16)
		ATTACK_KIND_CROSSBOW_VOLLEY:
			return _predicted_player_position(0.26)
		ATTACK_KIND_HALBERD_SWEEP:
			return positions[id] + _halberd_horizontal_direction(id, player_position) * HALBERD_SWEEP_RANGE
		ATTACK_KIND_HALBERD_BRACE:
			var brace_target := _predicted_player_position(0.16)
			return positions[id] + _halberd_horizontal_direction(id, brace_target) * HALBERD_BRACE_MAX_DISTANCE
		ATTACK_KIND_SPEAR_THRUST_1, ATTACK_KIND_SPEAR_THRUST_2, ATTACK_KIND_SPEAR_FORMATION:
			return positions[id] + _spear_horizontal_direction(id, player_position) * _attack_range(EnemyType.SPEAR)
		ATTACK_KIND_CAVALRY_STAB:
			return positions[id] + _spear_horizontal_direction(id, player_position) * 104.0
		ATTACK_KIND_CAVALRY_CHARGE:
			return positions[id] + _spear_horizontal_direction(id, player_position) * CAVALRY_CHARGE_DISTANCE
	return player_position

func _can_start_archer_volley() -> bool:
	if archer_volley_cooldown > 0.0:
		return false
	if battle_mode != "endless" and (battle_mode != "story" or battle_elapsed < ARCHER_VOLLEY_STORY_TIME):
		return false
	var engaged_archers := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.ARCHER and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_archers += 1
			if engaged_archers >= 3:
				return true
	return false

func _can_start_spear_formation() -> bool:
	if spear_formation_cooldown > 0.0:
		return false
	var engaged_spears := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.SPEAR and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_spears += 1
			if engaged_spears >= SPEAR_FORMATION_MIN_MEMBERS:
				return true
	return false

func _can_start_crossbow_volley() -> bool:
	if crossbow_volley_cooldown > 0.0:
		return false
	if battle_mode != "endless" and (battle_mode != "story" or battle_elapsed < CROSSBOW_VOLLEY_STORY_TIME):
		return false
	var engaged_crossbows := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.CROSSBOW and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_crossbows += 1
			if engaged_crossbows >= CROSSBOW_VOLLEY_MIN_MEMBERS:
				return true
	return false

func _spear_horizontal_direction(id: int, player_position: Vector2) -> Vector2:
	var horizontal_delta := player_position.x - positions[id].x
	if absf(horizontal_delta) > 0.01:
		return Vector2.RIGHT if horizontal_delta > 0.0 else Vector2.LEFT
	if absf(facing_directions[id].x) > 0.01:
		return Vector2.RIGHT if facing_directions[id].x > 0.0 else Vector2.LEFT
	return Vector2.RIGHT if id % 2 == 0 else Vector2.LEFT

func _halberd_horizontal_direction(id: int, target: Vector2) -> Vector2:
	var horizontal_delta := target.x - positions[id].x
	if absf(horizontal_delta) > 0.01:
		return Vector2.RIGHT if horizontal_delta > 0.0 else Vector2.LEFT
	if absf(facing_directions[id].x) > 0.01:
		return Vector2.RIGHT if facing_directions[id].x > 0.0 else Vector2.LEFT
	return Vector2.RIGHT if id % 2 == 0 else Vector2.LEFT

func _player_is_rushing_toward(id: int, player_position: Vector2) -> bool:
	var speed := player_velocity.length()
	if speed < HALBERD_BRACE_APPROACH_SPEED:
		return false
	var to_halberd := positions[id] - player_position
	var distance := to_halberd.length()
	if distance < HALBERD_BRACE_MIN_DISTANCE or distance > HALBERD_BRACE_MAX_DISTANCE:
		return false
	return player_velocity.normalized().dot(to_halberd.normalized()) >= 0.58

func _attack_windup_for_kind(enemy_type: int, attack_kind: String) -> float:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH: return 0.46
		ATTACK_KIND_DUEL_SPEAR_THRUST: return 0.54
		ATTACK_KIND_ARCHER_VOLLEY: return 0.96
		ATTACK_KIND_CROSSBOW_VOLLEY: return 0.96
		ATTACK_KIND_BANNER_COMMAND: return 0.68
		ATTACK_KIND_CAVALRY_CHARGE: return 0.70
		ATTACK_KIND_CAVALRY_STAB: return 0.52
		ATTACK_KIND_HALBERD_SWEEP: return 0.64
		ATTACK_KIND_HALBERD_BRACE: return 0.78
		ATTACK_KIND_SPEAR_THRUST_2: return 0.68
		ATTACK_KIND_SPEAR_FORMATION: return 1.14
	return _attack_windup(enemy_type)

func _attack_cooldown_for_kind(enemy_type: int, attack_kind: String) -> float:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH: return 1.55
		ATTACK_KIND_DUEL_SPEAR_THRUST: return 1.75
		ATTACK_KIND_HALBERD_SWEEP: return 1.55
		ATTACK_KIND_HALBERD_BRACE: return 2.25
		ATTACK_KIND_SPEAR_THRUST_1: return 0.44
		ATTACK_KIND_SPEAR_THRUST_2: return 1.60
		ATTACK_KIND_SPEAR_FORMATION: return 5.20
		ATTACK_KIND_CROSSBOW_VOLLEY: return 2.60
		ATTACK_KIND_BANNER_COMMAND: return 6.20
		ATTACK_KIND_CAVALRY_CHARGE: return 1.65
		ATTACK_KIND_CAVALRY_STAB: return 1.35
	return _attack_cooldown(enemy_type)

func _engage_melee_limit() -> int:
	if battle_mode == "endless":
		return ENGAGE_MELEE_LIMIT
	if battle_mode == "story":
		if battle_elapsed >= 120.0:
			return 12
		if battle_elapsed >= 45.0:
			return 10
		return 9
	return ENGAGE_MELEE_LIMIT

func _engage_archer_limit() -> int:
	if battle_mode == "endless":
		return ENGAGE_ARCHER_LIMIT
	if battle_mode == "story":
		if battle_elapsed >= 130.0:
			return 6
		if battle_elapsed >= 70.0:
			return 5
		return 4
	return ENGAGE_ARCHER_LIMIT

func _engage_spear_limit() -> int:
	if battle_mode == "endless":
		return ENGAGE_SPEAR_LIMIT
	return 4 if battle_elapsed < 240.0 else 5

func _engage_crossbow_limit() -> int:
	if battle_mode == "endless":
		return ENGAGE_CROSSBOW_LIMIT
	return 3 if battle_elapsed < 180.0 else 4

func _engage_cavalry_limit() -> int:
	if battle_mode == "endless":
		return ENGAGE_CAVALRY_LIMIT
	return 3 if battle_elapsed < 240.0 else 4

func _frontline_attack_slots() -> int:
	if battle_mode == "endless":
		return 5
	return 5 if battle_mode == "story" and battle_elapsed >= 120.0 else 4

func _archer_attack_slots() -> int:
	if battle_mode == "endless":
		return 4
	return 4 if battle_mode == "story" and battle_elapsed >= 160.0 else 3

func _crossbow_attack_slots() -> int:
	if battle_mode == "endless":
		return 3
	return 3 if battle_elapsed >= 180.0 else 2

func _halberd_attack_slots() -> int:
	if battle_mode == "endless":
		return 2
	return 2 if battle_mode == "story" and battle_elapsed >= 240.0 else 1

func _spear_attack_slots() -> int:
	return 2

func _banner_attack_slots() -> int:
	return 1

func _cavalry_attack_slots() -> int:
	return 2

func _clamp_point(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, bounds.position.x + 8.0, bounds.end.x - 8.0),
		clampf(point.y, bounds.position.y + 8.0, bounds.end.y - 8.0)
	)

func _spatial_cell_for(at: Vector2) -> Vector2i:
	return Vector2i(floori(at.x / SPATIAL_CELL_SIZE), floori(at.y / SPATIAL_CELL_SIZE))

func _personal_space(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 38.0
		EnemyType.SHIELD: return 36.0
		EnemyType.SPEAR: return 34.0
		EnemyType.GUARD: return 34.0
		EnemyType.HALBERD: return 32.0
		EnemyType.ARCHER: return 30.0
		EnemyType.CROSSBOW: return 31.0
		EnemyType.BANNER: return 36.0
		EnemyType.CAVALRY: return 39.0
		_: return 28.0

func _forced_displacement_resistance(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.50
		EnemyType.SHIELD: return 0.65
		EnemyType.GUARD: return 0.75
		_: return 1.0

func _formation_ring_spacing(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE, EnemyType.SHIELD: return 32.0
		EnemyType.SPEAR: return 30.0
		EnemyType.ARCHER: return 28.0
		EnemyType.CROSSBOW: return 30.0
		EnemyType.BANNER: return 38.0
		EnemyType.CAVALRY: return 42.0
		_: return 26.0

func _clamp_position(id: int) -> void:
	positions[id].x = clampf(positions[id].x, bounds.position.x + 8.0, bounds.end.x - 8.0)
	positions[id].y = clampf(positions[id].y, bounds.position.y + 8.0, bounds.end.y - 8.0)

func _refresh_banner_commands(delta: float) -> void:
	for id in range(CAPACITY):
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = maxf(0.0, command_surge_timers[id] - delta)
	for banner_id in range(CAPACITY):
		if active[banner_id] == 0 or types[banner_id] != EnemyType.BANNER:
			continue
		for target_id in range(CAPACITY):
			if active[target_id] == 0 or types[target_id] == EnemyType.BANNER:
				continue
			if positions[target_id].distance_squared_to(positions[banner_id]) <= BANNER_AURA_RADIUS * BANNER_AURA_RADIUS:
				command_aura_strengths[target_id] = 1.0

func _command_speed_multiplier(id: int) -> float:
	if command_surge_timers[id] > 0.0:
		return BANNER_COMMAND_SPEED_MULTIPLIER
	return BANNER_SPEED_MULTIPLIER if command_aura_strengths[id] > 0.0 else 1.0

func _command_damage_multiplier(id: int) -> float:
	if command_surge_timers[id] > 0.0:
		return BANNER_COMMAND_DAMAGE_MULTIPLIER
	return BANNER_DAMAGE_MULTIPLIER if command_aura_strengths[id] > 0.0 else 1.0

func _start_cavalry_charge(id: int, target: Vector2) -> void:
	var direction := (target - positions[id]).normalized()
	if absf(direction.x) <= 0.01:
		direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	direction = Vector2.RIGHT if direction.x >= 0.0 else Vector2.LEFT
	cavalry_charge_directions[id] = direction
	cavalry_charge_distances[id] = CAVALRY_CHARGE_DISTANCE
	facing_directions[id] = direction

func _tick_special_attack_motion(id: int, delta: float) -> void:
	if types[id] != EnemyType.CAVALRY or attack_states[id] != AttackState.WINDUP or current_attack_kinds[id] != ATTACK_KIND_CAVALRY_CHARGE:
		return
	var charge_start_remaining := _attack_windup_for_kind(EnemyType.CAVALRY, ATTACK_KIND_CAVALRY_CHARGE) - CAVALRY_CHARGE_START_DELAY
	var motion_delta := delta
	if attack_timers[id] > charge_start_remaining:
		motion_delta = maxf(0.0, delta - (attack_timers[id] - charge_start_remaining))
	if motion_delta <= 0.0:
		return
	if cavalry_charge_distances[id] <= 0.0:
		return
	var travel := minf(cavalry_charge_distances[id], CAVALRY_CHARGE_SPEED * motion_delta)
	positions[id] += cavalry_charge_directions[id] * travel
	cavalry_charge_distances[id] = maxf(0.0, cavalry_charge_distances[id] - travel)
	_clamp_position(id)

func _request_hits_point(request: AttackRequest, point: Vector2) -> bool:
	var offset := point - request.origin
	match request.shape:
		AttackRequest.Shape.CIRCLE:
			return offset.length_squared() <= request.range * request.range
		AttackRequest.Shape.FAN:
			var distance_squared := offset.length_squared()
			if distance_squared < request.inner_radius * request.inner_radius or distance_squared > request.range * request.range:
				return false
			return absf(request.direction.angle_to(offset.normalized())) <= request.half_angle
		AttackRequest.Shape.LINE:
			var projected := offset.dot(request.direction)
			if projected < 0.0 or projected > request.range:
				return false
			var perpendicular := absf(offset.cross(request.direction))
			return perpendicular <= request.width * 0.5
	return false

func _stats(enemy_type: int) -> Dictionary:
	match enemy_type:
		EnemyType.HALBERD:
			return {"hp": 42.0, "armor": 4.0, "speed": 85.0}
		EnemyType.ARCHER:
			return {"hp": 22.0, "armor": 0.0, "speed": 72.0}
		EnemyType.SHIELD:
			return {"hp": 55.0, "armor": 12.0, "speed": 75.0}
		EnemyType.SPEAR:
			return {"hp": 36.0, "armor": 3.0, "speed": 84.0}
		EnemyType.CROSSBOW:
			return {"hp": 26.0, "armor": 1.0, "speed": 68.0}
		EnemyType.BANNER:
			return {"hp": 34.0, "armor": 4.0, "speed": 78.0}
		EnemyType.CAVALRY:
			return {"hp": 32.0, "armor": 2.0, "speed": 142.0}
		EnemyType.ELITE:
			return {"hp": 260.0, "armor": 18.0, "speed": 78.0}
		EnemyType.GUARD:
			return {"hp": 70.0, "armor": 8.0, "speed": 76.0}
		_:
			return {"hp": 24.0, "armor": 0.0, "speed": 105.0}

func _threat_health_multiplier() -> float:
	return float(THREAT_HEALTH_MULTIPLIERS[threat_tier])

func _threat_damage_multiplier() -> float:
	return float(THREAT_DAMAGE_MULTIPLIERS[threat_tier])

func _threat_armor_bonus() -> float:
	return float(THREAT_ARMOR_BONUSES[threat_tier])

func _desired_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 230.0
		EnemyType.CROSSBOW: return 276.0
		EnemyType.BANNER: return 232.0
		EnemyType.CAVALRY: return 152.0
		EnemyType.HALBERD: return 68.0
		EnemyType.ELITE: return 135.0
		EnemyType.SPEAR: return 142.0
		EnemyType.SHIELD: return 56.0
		_: return 42.0

func _attack_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 280.0
		EnemyType.CROSSBOW: return 340.0
		EnemyType.BANNER: return 252.0
		EnemyType.CAVALRY: return 228.0
		EnemyType.HALBERD: return 68.0
		EnemyType.ELITE: return 155.0
		EnemyType.SPEAR: return 170.0
		EnemyType.SHIELD: return 64.0
		_: return 50.0

func _attack_cooldown(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 2.1
		EnemyType.CROSSBOW: return 2.35
		EnemyType.BANNER: return 6.20
		EnemyType.CAVALRY: return 1.45
		EnemyType.HALBERD, EnemyType.ELITE: return 1.7
		EnemyType.SPEAR: return 1.55
		_: return 1.35

func _attack_windup(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.85
		EnemyType.CROSSBOW: return 0.72
		EnemyType.BANNER: return 0.68
		EnemyType.CAVALRY: return 0.52
		EnemyType.HALBERD, EnemyType.ELITE: return 0.75
		EnemyType.SHIELD: return 0.70
		EnemyType.SPEAR: return 0.58
		_: return 0.60

func _attack_recovery(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.75
		EnemyType.CROSSBOW: return 0.68
		EnemyType.BANNER: return 0.52
		EnemyType.CAVALRY: return 0.48
		EnemyType.HALBERD, EnemyType.ELITE: return 0.38
		EnemyType.SHIELD: return 0.45
		EnemyType.SPEAR: return 0.36
		_: return 0.28

func _cancel_attack(id: int, cooldown: float) -> void:
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	cooldowns[id] = maxf(cooldowns[id], cooldown)
	current_attack_kinds[id] = ""
	cavalry_charge_distances[id] = 0.0
	cavalry_charge_directions[id] = Vector2.ZERO

func _damage(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD: return 10.0
		EnemyType.ARCHER: return 8.0
		EnemyType.SHIELD: return 6.0
		EnemyType.SPEAR: return 9.0
		EnemyType.CROSSBOW: return 9.0
		EnemyType.BANNER: return 0.0
		EnemyType.CAVALRY: return 8.0
		EnemyType.ELITE: return 16.0
		EnemyType.GUARD: return 9.0
		_: return 5.0

func _experience(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY: return 2
		EnemyType.BANNER: return 3
		EnemyType.ELITE: return 22
		_: return 1

func _ultimate_energy(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY: return 1.4
		EnemyType.BANNER: return 1.8
		EnemyType.ELITE: return 26.0
		_: return 0.8

func _hurt_duration(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.30
		EnemyType.SHIELD: return 0.45
		EnemyType.GUARD: return 0.45
		_: return 0.68

func _knockback_resistance(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.12
		EnemyType.SHIELD: return 0.42
		EnemyType.GUARD: return 0.62
		_: return 1.0

func _break_duration(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.06
		EnemyType.SHIELD: return 0.12
		EnemyType.GUARD: return 0.14
		_: return 0.20
