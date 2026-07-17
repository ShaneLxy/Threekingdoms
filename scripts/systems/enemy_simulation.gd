class_name EnemySimulation
extends Node

signal enemy_died(enemy_id: int, enemy_type: int, at: Vector2, experience: int, ultimate_energy: float)
signal enemy_attack_requested(enemy_id: int, origin: Vector2, target: Vector2, enemy_type: int, damage: float, windup: float)
signal enemy_attack_cancelled(enemy_id: int)
signal enemy_death_collision(at: Vector2, direction: Vector2)

enum EnemyType { SWORD, HALBERD, ARCHER, SHIELD, ELITE, GUARD }
enum AttackState { APPROACH, WINDUP, RECOVER }
enum DeathState { NONE, FALLING, LAUNCHED }
enum EngagementLayer { ENGAGE, PRESSURE, ATMOSPHERE }

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
const FORMATION_ANGLE_STEP := 2.3999632
const FORMATION_ARRIVAL_DISTANCE := 10.0
const SPATIAL_CELL_SIZE := 64.0
const MAX_SEPARATION_NEIGHBORS := 8
const LAYER_REFRESH_INTERVAL := 0.55
const ENGAGE_MELEE_LIMIT := 10
const ENGAGE_HALBERD_LIMIT := 3
const ENGAGE_ARCHER_LIMIT := 5
const ENGAGE_ELITE_LIMIT := 1
const FRONTLINE_ATTACK_SLOT_COUNT := 4
const ARCHER_ATTACK_SLOT_COUNT := 3
const HALBERD_ATTACK_SLOT_COUNT := 1

var bounds := Rect2(80, 100, 1120, 500)
var positions: Array[Vector2] = []
var hit_points := PackedFloat32Array()
var max_hit_points := PackedFloat32Array()
var armor := PackedFloat32Array()
var move_speeds := PackedFloat32Array()
var cooldowns := PackedFloat32Array()
var hurt_timers := PackedFloat32Array()
var attack_states := PackedInt32Array()
var attack_timers := PackedFloat32Array()
var types := PackedInt32Array()
var active := PackedByteArray()
var knockback_velocities: Array[Vector2] = []
var facing_directions: Array[Vector2] = []
var boss_guard_flags := PackedByteArray()
var death_states := PackedByteArray()
var death_timers := PackedFloat32Array()
var death_velocities: Array[Vector2] = []
var death_impact_charges := PackedByteArray()
var forced_displacement_timers := PackedFloat32Array()
var forced_displacement_velocities: Array[Vector2] = []
var hit_feedback_timers := PackedFloat32Array()
var hit_feedback_durations := PackedFloat32Array()
var hit_feedback_strengths := PackedFloat32Array()
var behavior_layers := PackedByteArray()
var desired_behavior_layers := PackedByteArray()
var decision_timers := PackedFloat32Array()
var decision_cycles := PackedInt32Array()
var movement_targets: Array[Vector2] = []
var spawn_anchors: Array[Vector2] = []
var patrol_offsets: Array[Vector2] = []
var attack_wait_times := PackedFloat32Array()
var attack_turn_grants := PackedByteArray()
var free_ids: Array[int] = []
var active_count := 0
var boss_guard_count := 0
var spatial_cells: Dictionary = {}
var layer_refresh_remaining := 0.0

func _ready() -> void:
	positions.resize(CAPACITY)
	hit_points.resize(CAPACITY)
	max_hit_points.resize(CAPACITY)
	armor.resize(CAPACITY)
	move_speeds.resize(CAPACITY)
	cooldowns.resize(CAPACITY)
	hurt_timers.resize(CAPACITY)
	attack_states.resize(CAPACITY)
	attack_timers.resize(CAPACITY)
	types.resize(CAPACITY)
	active.resize(CAPACITY)
	knockback_velocities.resize(CAPACITY)
	facing_directions.resize(CAPACITY)
	boss_guard_flags.resize(CAPACITY)
	death_states.resize(CAPACITY)
	death_timers.resize(CAPACITY)
	death_velocities.resize(CAPACITY)
	death_impact_charges.resize(CAPACITY)
	forced_displacement_timers.resize(CAPACITY)
	forced_displacement_velocities.resize(CAPACITY)
	hit_feedback_timers.resize(CAPACITY)
	hit_feedback_durations.resize(CAPACITY)
	hit_feedback_strengths.resize(CAPACITY)
	behavior_layers.resize(CAPACITY)
	desired_behavior_layers.resize(CAPACITY)
	decision_timers.resize(CAPACITY)
	decision_cycles.resize(CAPACITY)
	movement_targets.resize(CAPACITY)
	spawn_anchors.resize(CAPACITY)
	patrol_offsets.resize(CAPACITY)
	attack_wait_times.resize(CAPACITY)
	attack_turn_grants.resize(CAPACITY)
	for id in range(CAPACITY):
		positions[id] = Vector2.ZERO
		knockback_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		boss_guard_flags[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		free_ids.append(CAPACITY - id - 1)

func reset(world_bounds: Rect2) -> void:
	bounds = world_bounds
	free_ids.clear()
	spatial_cells.clear()
	active_count = 0
	boss_guard_count = 0
	layer_refresh_remaining = 0.0
	for id in range(CAPACITY):
		active[id] = 0
		hurt_timers[id] = 0.0
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		knockback_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		boss_guard_flags[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		free_ids.append(CAPACITY - id - 1)

func spawn(enemy_type: int, at: Vector2, is_boss_guard: bool = false) -> int:
	if free_ids.is_empty():
		return -1
	var id: int = free_ids.pop_back()
	var stats: Dictionary = _stats(enemy_type)
	positions[id] = at
	types[id] = enemy_type
	hit_points[id] = stats.hp
	max_hit_points[id] = stats.hp
	armor[id] = stats.armor
	move_speeds[id] = stats.speed
	cooldowns[id] = randf_range(1.2, 1.8)
	hurt_timers[id] = 0.0
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	knockback_velocities[id] = Vector2.ZERO
	facing_directions[id] = Vector2.DOWN
	boss_guard_flags[id] = 1 if is_boss_guard else 0
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	hit_feedback_timers[id] = 0.0
	hit_feedback_durations[id] = 0.0
	hit_feedback_strengths[id] = 0.0
	behavior_layers[id] = EngagementLayer.ENGAGE
	desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
	decision_timers[id] = 0.0
	decision_cycles[id] = 0
	movement_targets[id] = at
	spawn_anchors[id] = at
	patrol_offsets[id] = Vector2.ZERO
	attack_wait_times[id] = float((id * 29) % 10) * 0.03
	attack_turn_grants[id] = 0
	active[id] = 1
	active_count += 1
	layer_refresh_remaining = 0.0
	if is_boss_guard:
		boss_guard_count += 1
	return id

func tick(delta: float, player_position: Vector2) -> void:
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
		cooldowns[id] -= delta
		hit_feedback_timers[id] = maxf(0.0, hit_feedback_timers[id] - delta)
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
		if attack_states[id] != AttackState.APPROACH:
			attack_timers[id] = maxf(0.0, attack_timers[id] - delta)
			if attack_timers[id] <= 0.0:
				if attack_states[id] == AttackState.WINDUP:
					attack_states[id] = AttackState.RECOVER
					attack_timers[id] = _attack_recovery(types[id])
				else:
					attack_states[id] = AttackState.APPROACH
			continue
		decision_timers[id] = maxf(0.0, decision_timers[id] - delta)
		if decision_timers[id] <= 0.0:
			_refresh_movement_decision(id, player_position)
		var to_player := player_position - positions[id]
		var distance := to_player.length()
		var formation_target := movement_targets[id]
		var to_formation_target := formation_target - positions[id]
		var formation_direction := to_formation_target.normalized() if to_formation_target.length_squared() > FORMATION_ARRIVAL_DISTANCE * FORMATION_ARRIVAL_DISTANCE else Vector2.ZERO
		var formation_strength := clampf(to_formation_target.length() / 42.0, 0.0, 1.0)
		var separation := _separation_vector(id)
		var move_intent := formation_direction * formation_strength + separation * 1.35
		if move_intent.length_squared() > 0.01:
			positions[id] += move_intent.limit_length(1.0) * move_speeds[id] * _layer_speed_multiplier(behavior_layers[id]) * delta
		_clamp_position(id)
		if attack_turn_grants[id] == 1 and cooldowns[id] <= 0.0 and distance <= _attack_range(types[id]):
			cooldowns[id] = _attack_cooldown(types[id])
			attack_wait_times[id] = 0.0
			attack_states[id] = AttackState.WINDUP
			attack_timers[id] = _attack_windup(types[id])
			enemy_attack_requested.emit(id, positions[id], player_position, types[id], _damage(types[id]), attack_timers[id])

func query(request: AttackRequest) -> Array[int]:
	var results: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0:
			continue
		if request.one_hit_per_target and request.hit_targets.has(id):
			continue
		if _request_hits_point(request, positions[id]):
			results.append(id)
			if results.size() >= request.pierce:
				break
	return results

func apply_damage(id: int, value: float) -> bool:
	return apply_hit(id, value, Vector2.ZERO, 0.0)

func apply_hit(id: int, value: float, direction: Vector2, knockback: float, ignore_knockback_resistance: bool = false, forced_displacement: float = 0.0, forced_displacement_duration: float = 0.0) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
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
	if attack_states[id] != AttackState.APPROACH or hurt_timers[id] > 0.0:
		return false
	return movement_targets[id].distance_squared_to(positions[id]) > 4.0

func get_knockback_direction(id: int) -> Vector2:
	if id < 0 or id >= CAPACITY:
		return Vector2.ZERO
	if forced_displacement_timers[id] > 0.0:
		return forced_displacement_velocities[id].normalized()
	return knockback_velocities[id].normalized()

func get_attack_state(id: int) -> int:
	return attack_states[id] if id >= 0 and id < CAPACITY else AttackState.APPROACH

func get_attack_remaining(id: int) -> float:
	return attack_timers[id] if id >= 0 and id < CAPACITY else 0.0

func cancel_attack(id: int) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return
	_cancel_attack(id, 0.35)

func get_facing_direction(id: int) -> Vector2:
	return facing_directions[id] if id >= 0 and id < CAPACITY else Vector2.DOWN

func get_boss_guard_count() -> int:
	return boss_guard_count

func gold_reward(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD: return 2
		EnemyType.ELITE: return 12
		_: return 1

func _begin_death(id: int, direction: Vector2) -> void:
	var type := types[id]
	var at := positions[id]
	active[id] = 0
	active_count -= 1
	if boss_guard_flags[id] == 1:
		boss_guard_flags[id] = 0
		boss_guard_count -= 1
	death_states[id] = DeathState.FALLING
	death_timers[id] = DEATH_DISPLAY_DURATION
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	if direction.length_squared() > 0.01 and randf() <= DEATH_LAUNCH_CHANCE:
		death_states[id] = DeathState.LAUNCHED
		death_velocities[id] = direction.normalized() * DEATH_LAUNCH_SPEED
		death_impact_charges[id] = DEATH_COLLISION_MAX_TARGETS
	enemy_died.emit(id, type, at, _experience(type), _ultimate_energy(type))

func _tick_dying(id: int, delta: float) -> void:
	death_timers[id] = maxf(0.0, death_timers[id] - delta)
	if death_states[id] == DeathState.LAUNCHED:
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
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	free_ids.append(id)

func _rebuild_spatial_cells() -> void:
	spatial_cells.clear()
	for id in range(CAPACITY):
		if active[id] == 0:
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
				if other_id == id or active[other_id] == 0:
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

func _assign_desired_behavior_layers(player_position: Vector2) -> void:
	var melee_ids: Array[int] = []
	var halberd_ids: Array[int] = []
	var archer_ids: Array[int] = []
	var elite_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0:
			continue
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		match types[id]:
			EnemyType.ARCHER:
				archer_ids.append(id)
			EnemyType.HALBERD:
				halberd_ids.append(id)
			EnemyType.ELITE:
				elite_ids.append(id)
			_:
				melee_ids.append(id)
	_assign_nearest_layer(melee_ids, ENGAGE_MELEE_LIMIT, player_position)
	_assign_nearest_layer(halberd_ids, ENGAGE_HALBERD_LIMIT, player_position)
	_assign_nearest_layer(archer_ids, ENGAGE_ARCHER_LIMIT, player_position)
	_assign_nearest_layer(elite_ids, ENGAGE_ELITE_LIMIT, player_position)
	for id in range(CAPACITY):
		if active[id] == 0 or desired_behavior_layers[id] == EngagementLayer.ENGAGE:
			continue
		var pressure_radius := _desired_range(types[id]) + 205.0
		if positions[id].distance_to(player_position) <= pressure_radius:
			desired_behavior_layers[id] = EngagementLayer.PRESSURE

func _update_attack_wait_times(delta: float) -> void:
	for id in range(CAPACITY):
		if active[id] == 0:
			continue
		if behavior_layers[id] == EngagementLayer.ENGAGE and attack_states[id] == AttackState.APPROACH and hurt_timers[id] <= 0.0:
			attack_wait_times[id] = minf(8.0, attack_wait_times[id] + delta)

func _assign_attack_turns(player_position: Vector2) -> void:
	var previous_grants := attack_turn_grants.duplicate()
	var frontline_candidates: Array[int] = []
	var archer_candidates: Array[int] = []
	var halberd_candidates: Array[int] = []
	var frontline_occupied := 0
	var archer_occupied := 0
	var halberd_occupied := 0
	for id in range(CAPACITY):
		attack_turn_grants[id] = 0
		if active[id] == 0 or behavior_layers[id] != EngagementLayer.ENGAGE:
			continue
		var group := _attack_group_for_type(types[id])
		if attack_states[id] != AttackState.APPROACH:
			if group == "frontline":
				frontline_occupied += 1
			elif group == "archer":
				archer_occupied += 1
			else:
				halberd_occupied += 1
			continue
		if cooldowns[id] > 0.0 or positions[id].distance_to(player_position) > _attack_staging_range(types[id]):
			continue
		if group == "frontline":
			frontline_candidates.append(id)
		elif group == "archer":
			archer_candidates.append(id)
		else:
			halberd_candidates.append(id)
	_assign_attack_group_grants(frontline_candidates, maxi(0, FRONTLINE_ATTACK_SLOT_COUNT - frontline_occupied))
	_assign_attack_group_grants(archer_candidates, maxi(0, ARCHER_ATTACK_SLOT_COUNT - archer_occupied))
	_assign_attack_group_grants(halberd_candidates, maxi(0, HALBERD_ATTACK_SLOT_COUNT - halberd_occupied))
	for id in range(CAPACITY):
		if active[id] == 1 and previous_grants[id] != attack_turn_grants[id]:
			decision_timers[id] = 0.0

func _assign_attack_group_grants(candidates: Array[int], available_slots: int) -> void:
	if available_slots <= 0:
		return
	candidates.sort_custom(func(first: int, second: int) -> bool:
		if not is_equal_approx(attack_wait_times[first], attack_wait_times[second]):
			return attack_wait_times[first] > attack_wait_times[second]
		return decision_cycles[first] < decision_cycles[second]
	)
	for index in range(mini(available_slots, candidates.size())):
		attack_turn_grants[candidates[index]] = 1

func _attack_group_for_type(enemy_type: int) -> String:
	if enemy_type == EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemyType.HALBERD or enemy_type == EnemyType.ELITE:
		return "halberd"
	return "frontline"

func _attack_staging_range(enemy_type: int) -> float:
	if enemy_type == EnemyType.ARCHER:
		return _attack_range(enemy_type) + 70.0
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
	var patrol_radius := _patrol_radius(layer)
	var patrol_angle := deg_to_rad(float((id * 47 + decision_cycles[id] * 29) % 360))
	patrol_offsets[id] = Vector2.from_angle(patrol_angle) * patrol_radius
	movement_targets[id] = _clamp_point(target + patrol_offsets[id])
	var facing_target := player_position if layer == EngagementLayer.ENGAGE else movement_targets[id]
	var desired_facing := (facing_target - positions[id]).normalized()
	if desired_facing.length_squared() > 0.01:
		facing_directions[id] = desired_facing
	decision_timers[id] = _reaction_delay(layer, id, decision_cycles[id])

func _formation_target(id: int, player_position: Vector2, layer: int) -> Vector2:
	var enemy_type := types[id]
	var squad_index := id / 4
	var squad_slot := id % 4
	var angle := fmod(float(squad_index) * FORMATION_ANGLE_STEP + float(enemy_type) * 0.71 + deg_to_rad(float(squad_slot - 1) * 14.0), TAU)
	var ring_index := (squad_index + enemy_type * 5) % 3
	var radius := _desired_range(enemy_type) + _formation_ring_spacing(enemy_type) * ring_index
	if layer == EngagementLayer.ENGAGE and attack_turn_grants[id] == 0:
		radius += 74.0 + float(ring_index) * 18.0
	if layer == EngagementLayer.PRESSURE:
		radius += 112.0 + float(ring_index) * 22.0
	elif layer == EngagementLayer.ATMOSPHERE:
		radius += 182.0 + float(ring_index) * 28.0
		if spawn_anchors[id].distance_to(player_position) <= radius + 72.0:
			return spawn_anchors[id]
	return player_position + Vector2.from_angle(angle) * radius

func _layer_speed_multiplier(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 0.72
		EngagementLayer.ATMOSPHERE: return 0.48
		_: return 1.0

func _patrol_radius(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 24.0
		EngagementLayer.ATMOSPHERE: return 42.0
		_: return 5.0

func _reaction_delay(layer: int, id: int, cycle: int) -> float:
	var jitter := float((id * 37 + cycle * 19) % 100) / 100.0
	match layer:
		EngagementLayer.PRESSURE: return 0.35 + jitter * 0.55
		EngagementLayer.ATMOSPHERE: return 1.0 + jitter * 1.20
		_: return 0.10 + jitter * 0.20

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
		EnemyType.GUARD: return 34.0
		EnemyType.HALBERD: return 32.0
		EnemyType.ARCHER: return 30.0
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
		EnemyType.ARCHER: return 28.0
		_: return 26.0

func _clamp_position(id: int) -> void:
	positions[id].x = clampf(positions[id].x, bounds.position.x + 8.0, bounds.end.x - 8.0)
	positions[id].y = clampf(positions[id].y, bounds.position.y + 8.0, bounds.end.y - 8.0)

func _request_hits_point(request: AttackRequest, point: Vector2) -> bool:
	var offset := point - request.origin
	match request.shape:
		AttackRequest.Shape.CIRCLE:
			return offset.length_squared() <= request.range * request.range
		AttackRequest.Shape.FAN:
			if offset.length_squared() > request.range * request.range:
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
		EnemyType.ELITE:
			return {"hp": 260.0, "armor": 18.0, "speed": 78.0}
		EnemyType.GUARD:
			return {"hp": 70.0, "armor": 8.0, "speed": 76.0}
		_:
			return {"hp": 24.0, "armor": 0.0, "speed": 105.0}

func _desired_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 230.0
		EnemyType.HALBERD, EnemyType.ELITE: return 135.0
		EnemyType.SHIELD: return 56.0
		_: return 42.0

func _attack_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 280.0
		EnemyType.HALBERD, EnemyType.ELITE: return 155.0
		EnemyType.SHIELD: return 64.0
		_: return 50.0

func _attack_cooldown(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 2.1
		EnemyType.HALBERD, EnemyType.ELITE: return 1.7
		_: return 1.35

func _attack_windup(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.85
		EnemyType.HALBERD, EnemyType.ELITE: return 0.75
		EnemyType.SHIELD: return 0.70
		_: return 0.60

func _attack_recovery(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.75
		EnemyType.HALBERD, EnemyType.ELITE: return 0.38
		EnemyType.SHIELD: return 0.45
		_: return 0.28

func _cancel_attack(id: int, cooldown: float) -> void:
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	cooldowns[id] = maxf(cooldowns[id], cooldown)

func _damage(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD: return 10.0
		EnemyType.ARCHER: return 8.0
		EnemyType.SHIELD: return 6.0
		EnemyType.ELITE: return 16.0
		EnemyType.GUARD: return 9.0
		_: return 5.0

func _experience(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD: return 2
		EnemyType.ELITE: return 22
		_: return 1

func _ultimate_energy(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD: return 1.4
		EnemyType.ELITE: return 26.0
		_: return 0.8

func _hurt_duration(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.035
		EnemyType.SHIELD: return 0.055
		EnemyType.GUARD: return 0.07
		_: return 0.10

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
