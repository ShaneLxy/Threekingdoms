class_name TianjiSystem
extends Node

const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const TARGET_SCAN_RANGE := 720.0
const MAX_FIRE_ZONES := 18
# Every visible impact creates a gameplay zone.  Keeping the visual and gameplay
# point sets identical prevents enemies from walking through an apparent impact
# with no feedback.  The multiplier expands coverage around the visible ground
# impact without changing the meteor's target positions.
const FIRE_RAIN_DAMAGE_RADIUS_MULTIPLIER := 1.52
const FIRE_RAIN_DAMAGE_RADIUS_CAP := 140.0
const FIRE_RAIN_DAMAGE_INITIAL_RATIO := 0.78
const FIRE_RAIN_DAMAGE_BURN_RATIO := 0.22
const FIRE_RAIN_FINAL_FLIGHT_DURATION := 0.46
const FIRE_RAIN_FINAL_FRAME_DURATION := 0.085
const FIRE_RAIN_FINAL_LANDING_FRAME := 9
const WIND_REPLACEMENT_DELAY_MIN := 0.10
const WIND_REPLACEMENT_DELAY_MAX := 0.20
const WATER_WAVE_DAMAGE_RATIO := 0.16
const WATER_WAVE_SIZE_RATIOS: Array[float] = [1.0, 0.84, 0.74, 0.90, 1.06]
const WATER_WAVE_Y_RATIOS: Array[float] = [0.0, -0.12, 0.10, -0.06, 0.16]

signal skill_windup_started(skill_id: String, center: Vector2, direction: Vector2, definition: Dictionary, rank: int, radius: float)
signal skill_impacted(skill_id: String, center: Vector2, direction: Vector2, hit_count: int, active_duration: float, rank: int, radius: float)
signal damage_applied(hit_count: int)
signal fire_rain_meteor_started(center: Vector2, rank: int, final_meteor: bool, delay: float, radius: float, wave_index: int, wave_last: bool)

var player: HeroActor
var enemies: EnemySimulation
var elites: Array[EliteActor] = []
var boss: BossActor
var battle_camera: Camera2D
var skill_states: Dictionary = {}
var slot_order: Array[String] = []
var fire_zones: Array[Dictionary] = []
var pending_fire_meteors: Array[Dictionary] = []
var pending_lightning_strikes: Array[Dictionary] = []
var max_active_per_run := TIANJI_CATALOG.MAX_ACTIVE_PER_RUN

func configure(player_actor: HeroActor, enemy_simulation: EnemySimulation, elite_actors: Array[EliteActor], boss_actor: BossActor, camera: Camera2D = null, slot_capacity: int = TIANJI_CATALOG.MAX_ACTIVE_PER_RUN) -> void:
	player = player_actor
	enemies = enemy_simulation
	elites = elite_actors
	boss = boss_actor
	battle_camera = camera
	max_active_per_run = maxi(1, slot_capacity)
	skill_states.clear()
	slot_order.clear()
	fire_zones.clear()
	pending_fire_meteors.clear()
	pending_lightning_strikes.clear()

func active_skill_ids() -> Array[String]:
	return slot_order.duplicate()

func can_activate(skill_id: String) -> bool:
	return not TIANJI_CATALOG.definition_for(skill_id).is_empty() and SaveService.tianji_rank(skill_id) > 0 and not skill_states.has(skill_id) and slot_order.size() < max_active_per_run

func activate_skill(skill_id: String) -> bool:
	if not can_activate(skill_id):
		return false
	slot_order.append(skill_id)
	skill_states[skill_id] = {
		"rank": SaveService.tianji_rank(skill_id),
		"cooldown_remaining": 1.35,
		"cooldown_started": true,
		"effect_finished": true,
		"windup_remaining": 0.0,
		"active_remaining": 0.0,
		"next_tick": 0.0,
		"center": player.position if player != null else Vector2.ZERO,
		"direction": Vector2.RIGHT,
		"cooldown_bonus": 0.0,
		"damage_bonus": 0.0,
		"target_bonus": 0,
		"slow_bonus": 0.0,
		"knockback_bonus": 0.0,
		"radius_ratio": 1.0,
		"duration_bonus": 0.0,
		"strike_bonus": 0,
		"volley_bonus": 0,
		"fire_seed": randf_range(0.0, TAU),
		"fire_wave_centers": [],
		"wind_position": Vector2.ZERO,
		"wind_previous_x": 0.0,
		"wind_direction": Vector2.RIGHT,
		"wind_path_y": 0.0,
		"wind_width": 0.0,
		"wind_lifted": [],
		"wind_pending_pickups": [],
		"wind_claimed": {},
		"wind_immune": {},
		"wind_hit_elites": {},
		"wind_hit_boss": false,
		"wind_replacement_remaining": 0.0,
		"water_phase": "",
		"water_elapsed": 0.0,
		"water_origin": Vector2.ZERO,
		"water_position": Vector2.ZERO,
		"water_travel_distance": 0.0,
		"water_width": 0.0,
		"water_wave_passes": [],
	}
	return true

func apply_run_upgrade(upgrade_id: String) -> bool:
	var skill_id := _skill_for_upgrade(upgrade_id)
	if skill_id.is_empty() or not skill_states.has(skill_id):
		return false
	var state: Dictionary = skill_states[skill_id] as Dictionary
	match upgrade_id:
		"tianji_lightning_cooldown", "tianji_wind_cooldown", "tianji_fire_cooldown", "tianji_arrow_cooldown": state["cooldown_bonus"] = minf(0.18, float(state.get("cooldown_bonus", 0.0)) + 0.06)
		"tianji_lightning_damage", "tianji_fire_damage", "tianji_arrow_damage": state["damage_bonus"] = minf(0.75, float(state.get("damage_bonus", 0.0)) + 0.20)
		"tianji_lightning_targets": state["target_bonus"] = mini(2, int(state.get("target_bonus", 0)) + 1)
		"tianji_wind_slow", "tianji_water_slow": state["slow_bonus"] = minf(0.30, float(state.get("slow_bonus", 0.0)) + 0.08)
		"tianji_wind_knockback": state["knockback_bonus"] = minf(0.75, float(state.get("knockback_bonus", 0.0)) + 0.20)
		"tianji_water_duration": state["duration_bonus"] = minf(1.8, float(state.get("duration_bonus", 0.0)) + 0.60)
		"tianji_water_radius": state["radius_ratio"] = minf(1.42, float(state.get("radius_ratio", 1.0)) + 0.12)
		"tianji_fire_spread": state["strike_bonus"] = mini(2, int(state.get("strike_bonus", 0)) + 1)
		"tianji_arrow_volley": state["volley_bonus"] = mini(2, int(state.get("volley_bonus", 0)) + 1)
		_: return false
	skill_states[skill_id] = state
	return true

func tick(delta: float) -> void:
	if player == null or enemies == null:
		return
	# Resolve queued impacts and lingering burn zones before advancing state
	# transitions, so cooldown cannot begin while an effect is still presenting.
	_tick_fire_zones(delta)
	_tick_pending_fire_meteors(delta)
	_tick_pending_lightning_strikes(delta)
	for raw_skill_id in skill_states.keys():
		var skill_id := str(raw_skill_id)
		var state: Dictionary = skill_states[skill_id] as Dictionary
		if float(state.get("windup_remaining", 0.0)) > 0.0:
			state["windup_remaining"] = maxf(0.0, float(state["windup_remaining"]) - delta)
			if float(state["windup_remaining"]) <= 0.0:
				_resolve_skill(skill_id, state)
			skill_states[skill_id] = state
			continue
		if float(state.get("active_remaining", 0.0)) > 0.0:
			_tick_active_skill(skill_id, state, delta)
			if float(state.get("active_remaining", 0.0)) <= 0.0 and _effect_fully_finished(skill_id, state):
				_start_cooldown(state, skill_id)
			skill_states[skill_id] = state
			continue
		if not bool(state.get("effect_finished", true)):
			var kind := str(TIANJI_CATALOG.definition_for(skill_id).get("kind", ""))
			# Wind and water keep simulation state after their presentation timer
			# reaches zero (for example when a frame advances across a phase
			# boundary), so let their final phase drain instead of deadlocking.
			if kind == "wind" or kind == "water":
				_tick_active_skill(skill_id, state, delta)
			if _effect_fully_finished(skill_id, state):
				_start_cooldown(state, skill_id)
			skill_states[skill_id] = state
			continue
		state["cooldown_remaining"] = maxf(0.0, float(state.get("cooldown_remaining", 0.0)) - delta)
		if float(state["cooldown_remaining"]) <= 0.0:
			_begin_skill(skill_id, state)
		skill_states[skill_id] = state

func hud_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for skill_id in slot_order:
		if not skill_states.has(skill_id):
			continue
		var state: Dictionary = skill_states[skill_id] as Dictionary
		var definition := TIANJI_CATALOG.definition_for(skill_id)
		var rank := int(state.get("rank", 1))
		slots.append({
			"id": skill_id,
			"title": TIANJI_CATALOG.title_for(skill_id),
			"icon": TIANJI_CATALOG.icon_for(skill_id),
			"rank": rank,
			"color": definition.get("color", Color.WHITE),
			"cooldown": _cooldown_for(skill_id, state),
			"cooldown_remaining": float(state.get("cooldown_remaining", 0.0)),
			"windup_remaining": float(state.get("windup_remaining", 0.0)),
			"active_remaining": float(state.get("active_remaining", 0.0)),
			"active_duration": _duration_for(definition, state),
		})
	return slots

func sound_duration_for(skill_id: String) -> float:
	if not skill_states.has(skill_id):
		return 0.0
	var state: Dictionary = skill_states[skill_id] as Dictionary
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	match str(definition.get("kind", "")):
		"lightning":
			# The secondary strikes are delayed independently, so keep the loop alive
			# through the longest possible secondary impact and its animation.
			var frame_counts := [5, 6, 6, 8, 9]
			var rank := clampi(int(state.get("rank", 1)), 1, frame_counts.size())
			return 0.05 * float(frame_counts[rank - 1]) + float(state.get("lightning_extra_delay", 0.0)) + 0.12
		"fire_rain":
			return maxf(0.0, float(state.get("active_remaining", 0.0)))
		"wind", "water":
			return maxf(0.0, float(state.get("active_remaining", 0.0)))
		"arrow_volley":
			var volley_count := maxi(1, int(definition.get("volley_count", 3)) + int(state.get("volley_bonus", 0)))
			var volley_interval := float(definition.get("volley_interval", 0.30))
			# Include the lodged-arrow tail so the sound does not cut off while
			# the last volley is still visible on the battlefield.
			return float(volley_count - 1) * volley_interval + 1.54
	return 0.0

func _begin_skill(skill_id: String, state: Dictionary) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	var rank := int(state.get("rank", 1))
	var target := _select_target(skill_id, definition, rank)
	if not bool(target.get("valid", false)):
		state["cooldown_remaining"] = 0.50
		return
	var center: Vector2 = target.get("center", player.position)
	var direction: Vector2 = target.get("direction", Vector2.RIGHT)
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	if str(definition.get("kind", "")) == "wind":
		# Pick once at cast start so the windup preview, gameplay sweep, and
		# impact renderer all share the same direction.
		direction = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT
	state["center"] = center
	state["direction"] = direction.normalized()
	state["wind_direction"] = direction.normalized()
	state["cooldown_started"] = false
	state["effect_finished"] = false
	state["cooldown_remaining"] = 0.0
	state["windup_remaining"] = float(definition.get("precast", 0.5))
	skill_windup_started.emit(skill_id, center, direction, definition, rank, TIANJI_CATALOG.radius_for(skill_id, rank))

func _resolve_skill(skill_id: String, state: Dictionary) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	var center: Vector2 = state.get("center", player.position)
	var direction: Vector2 = state.get("direction", Vector2.RIGHT)
	var rank := int(state.get("rank", 1))
	# Publish the in-flight state before emitting presentation signals. RunScene
	# uses it to keep the matching阵法音效 alive for the full effect window.
	skill_states[skill_id] = state
	var damage := player.total_attack() * _damage_ratio_for(skill_id, state)
	var effect_radius := TIANJI_CATALOG.radius_for(skill_id, rank)
	var hit_count := 0
	var emit_primary_impact := true
	match str(definition.get("kind", "")):
		"lightning":
			var radius := effect_radius * float(state.get("radius_ratio", 1.0))
			var slow_multiplier := _slow_multiplier(definition, state)
			hit_count = _apply_circle(center, radius, damage, slow_multiplier, float(definition.get("slow_duration", 0.0)))
			_schedule_extra_lightning(center, radius, state, definition)
			var frame_counts := [5, 6, 6, 8, 9]
			var lightning_rank := clampi(rank, 1, frame_counts.size())
			state["active_remaining"] = maxf(
				0.26,
				0.05 * float(frame_counts[lightning_rank - 1])
				+ float(state.get("lightning_extra_delay", 0.0))
				+ 0.12
			)
			state["next_tick"] = INF
		"wind":
			_start_wind_tornado(state, definition, center)
			var wind_direction: Vector2 = state.get("wind_direction", direction)
			skill_impacted.emit(skill_id, state.get("wind_position", center), wind_direction, 0, float(state.get("active_remaining", 0.0)), rank, float(state.get("wind_width", effect_radius)))
			emit_primary_impact = false
		"water":
			_start_water_flood(state, definition, center, direction)
			skill_impacted.emit(skill_id, state.get("water_origin", center), direction, 0, float(state.get("active_remaining", 0.0)), rank, float(state.get("water_width", effect_radius)))
			emit_primary_impact = false
		"fire_rain":
			var wave_count := maxi(1, int(definition.get("wave_count", 3)))
			var wave_interval := float(definition.get("wave_interval", 0.24))
			var final_enabled := rank >= int(definition.get("final_meteor_rank", 5))
			var visual_duration := float(definition.get("visual_duration", 3.40))
			var final_visual_duration := float(definition.get("final_visual_duration", 2.80))
			var final_delay := _fire_rain_final_delay(definition)
			state["wave_index"] = 1
			state["fire_final_started"] = false
			state["fire_wave_centers"] = []
			state["active_remaining"] = float(wave_count - 1) * wave_interval + (final_delay + final_visual_duration if final_enabled else visual_duration)
			state["next_tick"] = wave_interval
			hit_count = _execute_fire_rain_wave(center, definition, state, damage, 0)
			emit_primary_impact = false
		"arrow_volley":
			state["volley_index"] = 1
			var volley_count := maxi(1, int(definition.get("volley_count", 3)) + int(state.get("volley_bonus", 0)))
			var volley_interval := float(definition.get("volley_interval", 0.30))
			state["active_remaining"] = float(volley_count - 1) * volley_interval + 1.54
			state["next_tick"] = float(definition.get("volley_interval", 0.30))
			hit_count = _execute_arrow_volley(center, direction, definition, state, damage, 0)
			emit_primary_impact = false
	if emit_primary_impact:
		skill_impacted.emit(skill_id, center, direction, hit_count, float(state.get("active_remaining", 0.0)), rank, effect_radius)

func _tick_active_skill(skill_id: String, state: Dictionary, delta: float) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	state["active_remaining"] = maxf(0.0, float(state["active_remaining"]) - delta)
	if str(definition.get("kind", "")) == "wind":
		_tick_wind_tornado(state, definition, player.total_attack() * _damage_ratio_for(skill_id, state), delta)
		return
	if str(definition.get("kind", "")) == "water":
		_tick_water_flood(state, definition, player.total_attack() * _damage_ratio_for(skill_id, state), delta)
		return
	state["next_tick"] = float(state["next_tick"]) - delta
	if float(state["next_tick"]) > 0.0:
		return
	var damage := player.total_attack() * _damage_ratio_for(skill_id, state)
	var center: Vector2 = state.get("center", player.position)
	match str(definition.get("kind", "")):
		"fire_rain":
			var wave_index := int(state.get("wave_index", 0))
			var wave_count := int(definition.get("wave_count", 3))
			if wave_index < wave_count:
				_execute_fire_rain_wave(center, definition, state, damage, wave_index)
				state["wave_index"] = wave_index + 1
				if wave_index + 1 >= wave_count and int(state.get("rank", 1)) >= int(definition.get("final_meteor_rank", 5)):
					state["next_tick"] = _fire_rain_final_delay(definition)
				else:
					state["next_tick"] = float(definition.get("wave_interval", 0.24))
			elif not bool(state.get("fire_final_started", false)) and int(state.get("rank", 1)) >= int(definition.get("final_meteor_rank", 5)):
				_execute_final_fire_meteor(center, definition, state, damage)
				state["fire_final_started"] = true
				state["next_tick"] = INF
			else:
				state["next_tick"] = INF
		"arrow_volley":
			var volley_index := int(state.get("volley_index", 0))
			var volley_count := int(definition.get("volley_count", 3)) + int(state.get("volley_bonus", 0))
			if volley_index < volley_count:
				_execute_arrow_volley(center, state.get("direction", Vector2.RIGHT), definition, state, damage, volley_index)
				state["volley_index"] = volley_index + 1
				state["next_tick"] = float(definition.get("volley_interval", 0.30))
			else:
				state["next_tick"] = INF

func _select_target(skill_id: String, definition: Dictionary, rank: int, density_radius_override: float = -1.0) -> Dictionary:
	var selection_range := TARGET_SCAN_RANGE
	var radius := TIANJI_CATALOG.radius_for(skill_id, rank)
	if radius <= 0.0:
		radius = float(definition.get("width", 86.0))
	if density_radius_override > 0.0:
		radius = density_radius_override
	# Selecting a center must only require that the target itself is visible.  Do
	# not inset by the skill radius: that incorrectly rejects targets near a
	# camera boundary, including the boss trial's bottom-edge duel space.
	var target_rect := _visible_target_rect()
	var best_position := _highest_priority_named_target(selection_range, target_rect)
	var has_target := best_position != Vector2.ZERO
	var best_score := -INF
	if not has_target:
		for id in range(EnemySimulation.CAPACITY):
			if not enemies.is_active(id) or enemies.is_tianji_lifted(id):
				continue
			var candidate := enemies.positions[id]
			if not target_rect.has_point(candidate):
				continue
			var distance := candidate.distance_to(player.position)
			if distance > selection_range:
				continue
			var density := enemies.count_active_within(candidate, radius)
			var score := float(density) * 120.0 - distance * 0.16
			if score > best_score:
				best_score = score
				best_position = candidate
				has_target = true
	var direction := (best_position - player.position).normalized()
	if direction.length_squared() <= 0.01:
		direction = player.last_attack_direction.normalized()
	if str(definition.get("kind", "")) == "wind":
		direction = Vector2.RIGHT
	return {"valid": has_target, "center": best_position, "direction": direction}

func _highest_priority_named_target(max_distance: float, target_rect: Rect2) -> Vector2:
	if boss != null and boss.active and target_rect.has_point(boss.position) and boss.position.distance_to(player.position) <= max_distance:
		return boss.position
	var best_position := Vector2.ZERO
	var best_distance := max_distance
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or not target_rect.has_point(elite.position):
			continue
		var distance := elite.position.distance_to(player.position)
		if distance < best_distance:
			best_distance = distance
			best_position = elite.position
	return best_position

func _apply_circle(center: Vector2, radius: float, damage: float, slow_multiplier: float, slow_duration: float) -> int:
	var hit_count := 0
	var radius_squared := radius * radius
	var target_rect := _visible_target_rect()
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.is_tianji_lifted(id) or not target_rect.has_point(enemies.positions[id]) or enemies.positions[id].distance_squared_to(center) > radius_squared:
			continue
		enemies.apply_damage(id, CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id)))
		if slow_duration > 0.0:
			enemies.apply_slow(id, slow_multiplier, slow_duration)
		hit_count += 1
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or not target_rect.has_point(elite.position) or elite.position.distance_squared_to(center) > radius_squared:
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		if slow_duration > 0.0:
			elite.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if boss != null and boss.active and target_rect.has_point(boss.position) and boss.position.distance_squared_to(center) <= radius_squared:
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()), BossActor.VULNERABLE_DEFAULT_STANCE_DAMAGE)
		if slow_duration > 0.0:
			boss.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if hit_count > 0:
		damage_applied.emit(hit_count)
	return hit_count

func _start_water_flood(state: Dictionary, definition: Dictionary, center: Vector2, direction: Vector2) -> void:
	var rank := clampi(int(state.get("rank", 1)), 1, 5)
	# Water is a horizontal battlefield surge. Capture the visible world bounds at
	# cast time so camera movement after the cast never drags the wave path along.
	var normalized_direction := Vector2.RIGHT
	var width := _water_rank_value(definition, "flood_widths", rank, float(definition.get("radius", 144.0))) * float(state.get("radius_ratio", 1.0))
	var visible_rect := _visible_target_rect()
	var path_y := clampf(center.y, visible_rect.position.y + width * 0.32, visible_rect.end.y - width * 0.32)
	var start_x := visible_rect.position.x - width
	var end_x := visible_rect.end.x + width
	var travel_distance := maxf(_water_rank_value(definition, "travel_distances", rank, 560.0), end_x - start_x)
	var surge_duration := maxf(0.60, _duration_for(definition, state))
	var has_reflux := rank >= 5
	var wave_count := _water_wave_count(rank)
	var wave_stagger := _water_wave_stagger(wave_count)
	var wave_passes: Array = []
	for wave_index in range(wave_count):
		var profile_index := clampi(wave_index, 0, WATER_WAVE_SIZE_RATIOS.size() - 1)
		wave_passes.append({
			"delay": float(wave_index) * wave_stagger,
			"width_ratio": WATER_WAVE_SIZE_RATIOS[profile_index],
			"offset_ratio": WATER_WAVE_Y_RATIOS[profile_index],
		})
	var wave_duration := surge_duration
	if has_reflux:
		wave_duration += float(definition.get("reflux_delay", 0.16)) + float(definition.get("reflux_duration", 0.72))
	var total_duration := wave_duration + float(wave_count - 1) * wave_stagger
	var origin := Vector2(start_x, path_y)
	state["water_phase"] = "surge"
	state["water_elapsed"] = 0.0
	state["water_origin"] = origin
	state["water_position"] = origin
	state["water_travel_distance"] = travel_distance
	state["water_width"] = width
	state["water_surge_duration"] = surge_duration
	state["water_active_direction"] = normalized_direction
	state["water_wave_passes"] = wave_passes
	state["water_total_duration"] = total_duration
	state["active_remaining"] = total_duration

func _tick_water_flood(state: Dictionary, definition: Dictionary, damage: float, delta: float) -> void:
	var phase := str(state.get("water_phase", ""))
	if phase.is_empty() or phase == "done":
		return
	var rank := clampi(int(state.get("rank", 1)), 1, 5)
	var direction: Vector2 = state.get("water_active_direction", Vector2.RIGHT)
	var travel_distance := float(state.get("water_travel_distance", 340.0))
	var width := float(state.get("water_width", 124.0))
	var origin: Vector2 = state.get("water_origin", Vector2.ZERO)
	var surge_duration := maxf(0.60, float(state.get("water_surge_duration", 1.55)))
	var previous_elapsed := float(state.get("water_elapsed", 0.0))
	var total_duration := maxf(surge_duration, float(state.get("water_total_duration", surge_duration)))
	var elapsed := minf(total_duration, previous_elapsed + maxf(0.0, delta))
	state["water_elapsed"] = elapsed
	var reflux_delay := float(definition.get("reflux_delay", 0.16)) if rank >= 5 else 0.0
	var reflux_duration := maxf(0.35, float(definition.get("reflux_duration", 0.72))) if rank >= 5 else 0.0
	var wave_passes: Array = state.get("water_wave_passes", []) as Array
	var wave_damage := damage * WATER_WAVE_DAMAGE_RATIO
	var damage_half_height := _water_rank_value(definition, "damage_half_heights", rank, width * 0.78) * float(state.get("radius_ratio", 1.0))
	for wave_index in range(wave_passes.size()):
		var wave_pass: Dictionary = wave_passes[wave_index] as Dictionary
		var pass_delay := float(wave_pass.get("delay", 0.0))
		var previous_local := maxf(0.0, previous_elapsed - pass_delay)
		var current_local := maxf(0.0, elapsed - pass_delay)
		if current_local <= 0.0 or current_local <= previous_local:
			continue
		# Offset and width remain visual-only. Gameplay uses one fixed path and
		# vertical band per rank so staggered crests cannot create blind spots.
		var wave_origin := origin
		var previous_surge := clampf(previous_local, 0.0, surge_duration)
		var current_surge := clampf(current_local, 0.0, surge_duration)
		if current_surge > previous_surge:
			var previous_front := wave_origin + direction * travel_distance * (previous_surge / surge_duration)
			var front := wave_origin + direction * travel_distance * (current_surge / surge_duration)
			_apply_water_wave(state, definition, wave_damage, previous_front, front, wave_origin, direction, damage_half_height, false)
			if wave_index == 0:
				state["water_position"] = front
		if rank >= 5 and current_local > surge_duration + reflux_delay:
			var previous_reflux := clampf((previous_local - surge_duration - reflux_delay) / reflux_duration, 0.0, 1.0)
			var current_reflux := clampf((current_local - surge_duration - reflux_delay) / reflux_duration, 0.0, 1.0)
			if current_reflux > previous_reflux:
				var end := wave_origin + direction * travel_distance
				var previous_front := end.lerp(wave_origin, previous_reflux)
				var front := end.lerp(wave_origin, current_reflux)
				_apply_water_wave(state, definition, wave_damage * float(definition.get("reflux_damage_ratio", 0.36)), previous_front, front, end, -direction, damage_half_height, true)
				if wave_index == 0:
					state["water_position"] = front
	if elapsed >= total_duration:
		state["water_phase"] = "done"
	elif rank >= 5 and elapsed > surge_duration + reflux_delay:
		state["water_phase"] = "reflux"
	else:
		state["water_phase"] = "surge"

func _apply_water_wave(state: Dictionary, definition: Dictionary, damage: float, previous_front: Vector2, front: Vector2, start: Vector2, direction: Vector2, half_height: float, reflux: bool) -> int:
	var hit_count := 0
	var travel_distance := float(state.get("water_travel_distance", 340.0))
	# Each crest resolves once as its shared front passes a target. The width
	# argument is the fixed per-rank vertical half-height of the gameplay
	# band; visual crest dimensions are intentionally decoupled from damage.
	var wave_half_height := maxf(28.0, half_height)
	var target_rect := _visible_target_rect()
	var slow_multiplier := _slow_multiplier(definition, state)
	var slow_duration := float(definition.get("slow_duration", 1.35)) + (0.25 if reflux else 0.0)
	var knockback := _water_rank_value(definition, "knockbacks", int(state.get("rank", 1)), 150.0) * (0.72 if reflux else 1.0)
	var protect_duel_formation := _duel_formation_blocks_regular_enemy_displacement()
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.is_tianji_lifted(id) or not target_rect.has_point(enemies.positions[id]):
			continue
		if not _point_crossed_by_water_wave(enemies.positions[id], previous_front, front, start, direction, travel_distance, wave_half_height):
			continue
		var final_damage := CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id))
		var enemy_knockback := knockback
		if protect_duel_formation and enemies.get_type(id) != EnemySimulation.EnemyType.ELITE:
			enemy_knockback = 0.0
		enemies.apply_hit(id, final_damage, direction, enemy_knockback)
		enemies.apply_slow(id, slow_multiplier, slow_duration)
		hit_count += 1
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or not target_rect.has_point(elite.position):
			continue
		if not _point_crossed_by_water_wave(elite.position, previous_front, front, start, direction, travel_distance, wave_half_height):
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		elite.apply_guard_knockback(direction, knockback, knockback * 0.025)
		elite.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if boss != null and boss.active and target_rect.has_point(boss.position) and _point_crossed_by_water_wave(boss.position, previous_front, front, start, direction, travel_distance, wave_half_height):
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()), BossActor.VULNERABLE_DEFAULT_STANCE_DAMAGE)
		boss.apply_guard_knockback(direction, knockback, knockback * 0.018)
		boss.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if hit_count > 0:
		damage_applied.emit(hit_count)
	return hit_count

func _point_crossed_by_water_wave(point: Vector2, previous_front: Vector2, front: Vector2, start: Vector2, direction: Vector2, travel_distance: float, half_height: float) -> bool:
	var offset := point - start
	var projected := offset.dot(direction)
	if projected < 0.0 or projected > travel_distance:
		return false
	var previous_distance := (previous_front - start).dot(direction)
	var front_distance := (front - start).dot(direction)
	return projected > minf(previous_distance, front_distance) and projected <= maxf(previous_distance, front_distance) and absf(offset.cross(direction)) <= half_height

func _water_wave_count(rank: int) -> int:
	return clampi(2 + ceili(float(clampi(rank, 1, 5)) / 2.0), 3, 5)

func _water_wave_stagger(wave_count: int) -> float:
	return clampf(0.18 + float(clampi(wave_count, 3, 5) - 3) * 0.04, 0.18, 0.26)

func _water_rank_value(definition: Dictionary, key: String, rank: int, fallback: float) -> float:
	var values: Array = definition.get(key, []) as Array
	if values.is_empty():
		return fallback
	var index := clampi(rank - 1, 0, values.size() - 1)
	return float(values[index])

func _execute_fire_rain_wave(anchor: Vector2, definition: Dictionary, state: Dictionary, damage: float, wave_index: int) -> int:
	var strike_count := int(definition.get("strike_count", 5)) + int(state.get("strike_bonus", 0))
	var visual_strike_count := mini(strike_count, maxi(1, int(definition.get("visual_strike_count", strike_count))))
	var fire_radius := _fire_rain_radius(definition, state)
	var strike_positions: Array[Vector2] = []
	var strike_delays: Array[float] = []
	for strike_index in range(strike_count):
		strike_positions.append(_fire_strike_position(anchor, wave_index, strike_index, strike_count, state))
		strike_delays.append(randf_range(0.05, 0.12))
	var wave_centers: Array = state.get("fire_wave_centers", []) as Array
	if not strike_positions.is_empty():
		var wave_center := Vector2.ZERO
		for strike_position in strike_positions:
			wave_center += strike_position
		wave_centers.append(wave_center / float(strike_positions.size()))
		state["fire_wave_centers"] = wave_centers
	# The damage set deliberately matches the visible set.  Earlier versions
	# selected only two random points, which left obvious no-damage gaps in the
	# fire animation.  All points still use one hit plus a lingering burn zone, so
	# this changes coverage rather than introducing repeated direct hits.
	var damage_zone_indices := _choose_fire_rain_damage_indices(strike_count)
	for strike_index in range(strike_count):
		var strike_position := strike_positions[strike_index]
		var delay := strike_delays[strike_index]
		# Keep the visual marker and its gameplay zone paired.  The fallback branches
		# still preserve the configured minimum visual count for future variants.
		var show_visual := visual_strike_count >= strike_count or damage_zone_indices.has(strike_index)
		if visual_strike_count == 1:
			show_visual = show_visual or strike_index == int(floor(float(strike_count - 1) * 0.5))
		elif visual_strike_count < strike_count:
			show_visual = show_visual or strike_index == 0 or strike_index == strike_count - 1
		if show_visual:
			fire_rain_meteor_started.emit(strike_position, int(state.get("rank", 1)), false, delay, fire_radius, wave_index, strike_index == strike_count - 1)
		if damage_zone_indices.has(strike_index):
			_schedule_fire_rain_meteor(
				strike_position,
				definition,
				state,
				damage,
				delay,
				false,
				fire_radius * FIRE_RAIN_DAMAGE_RADIUS_MULTIPLIER,
				FIRE_RAIN_DAMAGE_INITIAL_RATIO,
				FIRE_RAIN_DAMAGE_BURN_RATIO
			)
	return 0

func _choose_fire_rain_damage_indices(strike_count: int) -> Array[int]:
	var selected: Array[int] = []
	for strike_index in range(strike_count):
		selected.append(strike_index)
	return selected

func _execute_final_fire_meteor(anchor: Vector2, definition: Dictionary, state: Dictionary, damage: float) -> int:
	var rank := int(state.get("rank", 1))
	var final_radius := _fire_rain_radius(definition, state) * float(definition.get("final_meteor_radius_ratio", 2.25))
	var final_center := anchor
	# Re-evaluate the battlefield after the three regular waves.  The original
	# cast center is only a fallback; otherwise the final meteor should follow
	# the same named-target and dense-cluster selection used at cast time.
	var final_target := _select_target("fire_rain_burning", definition, rank, final_radius)
	if bool(final_target.get("valid", false)):
		var selected_center: Vector2 = final_target.get("center", anchor)
		final_center = selected_center
	else:
		var wave_centers: Array = state.get("fire_wave_centers", []) as Array
		if not wave_centers.is_empty():
			for wave_center_value in wave_centers:
				final_center += (wave_center_value as Vector2) - anchor
			final_center = anchor + (final_center - anchor) / float(wave_centers.size())
	fire_rain_meteor_started.emit(final_center, rank, true, 0.0, final_radius, -1, true)
	_schedule_fire_rain_meteor(final_center, definition, state, damage, 0.0, true)
	return 0

func _fire_rain_final_delay(definition: Dictionary) -> float:
	# The final meteor waits until the last normal wave is almost finished,
	# while retaining a small configurable pause for the finishing-beat feel.
	var configured_delay := float(definition.get("final_meteor_delay", 0.66))
	var wave_count := maxi(1, int(definition.get("wave_count", 3)))
	var wave_interval := float(definition.get("wave_interval", 0.24))
	var visual_duration := float(definition.get("visual_duration", 3.40))
	var last_wave_tail := maxf(0.0, visual_duration - float(wave_count - 1) * wave_interval - 0.42)
	return maxf(configured_delay, last_wave_tail)

func _schedule_fire_rain_meteor(center: Vector2, definition: Dictionary, state: Dictionary, damage: float, delay: float, final_meteor: bool, damage_radius: float = -1.0, initial_damage_ratio: float = 0.94, burn_damage_ratio: float = 0.28) -> void:
	var radius := _fire_rain_radius(definition, state)
	if final_meteor:
		radius *= float(definition.get("final_meteor_radius_ratio", 2.25))
	elif damage_radius > 0.0:
		radius = damage_radius
	if not final_meteor:
		radius = minf(radius, FIRE_RAIN_DAMAGE_RADIUS_CAP)
	# The final meteor deals damage exactly when its explosion frame first appears,
	# rather than at the end of the sky-to-ground travel.
	var impact_delay := 0.34
	if final_meteor:
		impact_delay = FIRE_RAIN_FINAL_FLIGHT_DURATION + FIRE_RAIN_FINAL_FRAME_DURATION * float(FIRE_RAIN_FINAL_LANDING_FRAME)
	pending_fire_meteors.append({
		"center": center,
		"remaining": maxf(0.0, delay) + impact_delay,
		"radius": radius,
		"initial_damage": damage * (float(definition.get("final_meteor_damage_ratio", 2.40)) if final_meteor else initial_damage_ratio),
		"duration": _duration_for(definition, state),
		"tick_interval": float(definition.get("tick_interval", 0.48)),
		"burn_damage": damage * (float(definition.get("burn_tick_ratio", 0.28)) if final_meteor else burn_damage_ratio),
		"rank": int(state.get("rank", 1)),
		"final": final_meteor,
	})

func _tick_pending_fire_meteors(delta: float) -> void:
	for index in range(pending_fire_meteors.size() - 1, -1, -1):
		var meteor: Dictionary = pending_fire_meteors[index] as Dictionary
		meteor["remaining"] = float(meteor.get("remaining", 0.0)) - delta
		if float(meteor.get("remaining", 0.0)) > 0.0:
			pending_fire_meteors[index] = meteor
			continue
		var center: Vector2 = meteor.get("center", Vector2.ZERO)
		var radius := float(meteor.get("radius", 52.0))
		var hit_count := _apply_circle(center, radius, float(meteor.get("initial_damage", 0.0)), 1.0, 0.0)
		if bool(meteor.get("final", false)):
			skill_impacted.emit("fire_rain_final", center, Vector2.DOWN, hit_count, 0.0, int(meteor.get("rank", 1)), radius)
		else:
			_start_fire_zone(center, radius, float(meteor.get("duration", 2.30)), float(meteor.get("tick_interval", 0.48)), float(meteor.get("burn_damage", 0.0)), int(meteor.get("rank", 1)), hit_count)
		pending_fire_meteors.remove_at(index)

func _fire_strike_position(anchor: Vector2, wave_index: int, strike_index: int, strike_count: int, state: Dictionary) -> Vector2:
	var angle := float(state.get("fire_seed", 0.0)) + float(wave_index) * 0.76 + TAU * float(strike_index) / float(maxi(1, strike_count))
	var distance_ratio := 0.46 + 0.54 * (sin(float(wave_index * 17 + strike_index * 11) * 0.73 + angle) + 1.0) * 0.5
	var distance := 28.0 + 122.0 * distance_ratio
	return anchor + Vector2.from_angle(angle) * distance

func _spawn_fire_zone(center: Vector2, definition: Dictionary, state: Dictionary, damage: float) -> int:
	var radius := _fire_rain_radius(definition, state)
	var hit_count := _apply_circle(center, radius, damage * 0.94, 1.0, 0.0)
	var duration := _duration_for(definition, state)
	_start_fire_zone(center, radius, duration, float(definition.get("tick_interval", 0.48)), damage * float(definition.get("burn_tick_ratio", 0.28)), int(state.get("rank", 1)), hit_count)
	return hit_count

func _fire_rain_radius(definition: Dictionary, state: Dictionary) -> float:
	var rank := int(state.get("rank", 1))
	return TIANJI_CATALOG.radius_for("fire_rain_burning", rank) * float(state.get("radius_ratio", 1.0))

func _start_fire_zone(center: Vector2, radius: float, duration: float, tick_interval: float, burn_damage: float, rank: int, hit_count: int) -> void:
	if fire_zones.size() >= MAX_FIRE_ZONES:
		fire_zones.pop_front()
	fire_zones.append({
		"center": center,
		"radius": radius,
		"remaining": duration,
		"next_tick": tick_interval,
		"tick_interval": tick_interval,
		"damage": burn_damage,
	})
	skill_impacted.emit("fire_rain_burning", center, Vector2.DOWN, hit_count, duration, rank, radius)

func _tick_fire_zones(delta: float) -> void:
	for index in range(fire_zones.size() - 1, -1, -1):
		var zone: Dictionary = fire_zones[index] as Dictionary
		zone["remaining"] = maxf(0.0, float(zone.get("remaining", 0.0)) - delta)
		if float(zone["remaining"]) <= 0.0:
			fire_zones.remove_at(index)
			continue
		zone["next_tick"] = float(zone.get("next_tick", 0.0)) - delta
		if float(zone["next_tick"]) <= 0.0:
			_apply_circle(zone.get("center", Vector2.ZERO), float(zone.get("radius", 52.0)), float(zone.get("damage", 0.0)), 1.0, 0.0)
			zone["next_tick"] = float(zone.get("tick_interval", 0.48))
		fire_zones[index] = zone

func _start_wind_tornado(state: Dictionary, definition: Dictionary, center: Vector2) -> void:
	var rank := clampi(int(state.get("rank", 1)), 1, 5)
	var visible_rect := _visible_target_rect()
	var width := _wind_rank_value(definition, "wind_widths", rank, float(definition.get("width", 86.0)))
	var speed := _wind_rank_value(definition, "wind_speeds", rank, 320.0)
	var path_y := clampf(center.y, visible_rect.position.y + width * 0.30, visible_rect.end.y - width * 0.30)
	var wind_direction: Vector2 = state.get("wind_direction", Vector2.RIGHT)
	if wind_direction.length_squared() <= 0.01:
		wind_direction = Vector2.RIGHT
	wind_direction = wind_direction.normalized()
	var start_x := visible_rect.end.x + width if wind_direction.x < 0.0 else visible_rect.position.x - width
	var end_x := visible_rect.position.x - width if wind_direction.x < 0.0 else visible_rect.end.x + width
	var travel_distance := maxf(width * 2.0, absf(end_x - start_x))
	state["wind_position"] = Vector2(start_x, path_y)
	state["wind_previous_x"] = start_x
	state["wind_direction"] = wind_direction
	state["wind_path_y"] = path_y
	state["wind_width"] = width
	state["wind_speed"] = speed
	state["wind_end_x"] = end_x
	state["wind_lifted"] = []
	state["wind_pending_pickups"] = []
	state["wind_claimed"] = {}
	state["wind_immune"] = {}
	state["wind_hit_elites"] = {}
	state["wind_hit_boss"] = false
	state["wind_replacement_remaining"] = 0.0
	state["active_remaining"] = travel_distance / maxf(1.0, speed)
	state["next_tick"] = INF

func _tick_wind_tornado(state: Dictionary, definition: Dictionary, damage: float, delta: float) -> void:
	var wind_position: Vector2 = state.get("wind_position", Vector2.ZERO)
	var previous_x := float(state.get("wind_previous_x", wind_position.x))
	var speed := float(state.get("wind_speed", 320.0))
	var end_x := float(state.get("wind_end_x", wind_position.x))
	var current_x := move_toward(wind_position.x, end_x, speed * maxf(0.0, delta))
	wind_position.x = current_x
	state["wind_previous_x"] = previous_x
	state["wind_position"] = wind_position
	_tick_wind_immune(state, delta)
	_tick_wind_lifted_units(state, definition, damage, delta)
	_tick_wind_pending_pickups(state, definition, damage, delta)
	_collect_wind_targets(state, definition, damage, previous_x, current_x)
	if float(state.get("active_remaining", 0.0)) <= 0.0:
		_finish_wind_tornado(state, definition, damage)
		return

func _tick_wind_immune(state: Dictionary, delta: float) -> void:
	var immune: Dictionary = state.get("wind_immune", {}) as Dictionary
	for key in immune.keys():
		immune[key] = float(immune[key]) - delta
		if float(immune[key]) <= 0.0:
			immune.erase(key)
	state["wind_immune"] = immune

func _tick_wind_lifted_units(state: Dictionary, definition: Dictionary, damage: float, delta: float) -> void:
	var lifted: Array = state.get("wind_lifted", []) as Array
	var wind_position: Vector2 = state.get("wind_position", Vector2.ZERO)
	var width := float(state.get("wind_width", definition.get("width", 86.0)))
	var rise_height := _wind_rank_value(definition, "wind_rise_heights", int(state.get("rank", 1)), 48.0)
	for index in range(lifted.size() - 1, -1, -1):
		var unit: Dictionary = lifted[index] as Dictionary
		var id := int(unit.get("id", -1))
		if not enemies.is_tianji_lifted(id):
			var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
			claimed.erase(id)
			state["wind_claimed"] = claimed
			lifted.remove_at(index)
			continue
		if _duel_formation_blocks_regular_enemy_displacement() and enemies.get_type(id) != EnemySimulation.EnemyType.ELITE:
			_release_wind_unit(state, definition, unit, damage)
			lifted.remove_at(index)
			continue
		unit["elapsed"] = float(unit.get("elapsed", 0.0)) + delta
		var elapsed := float(unit.get("elapsed", 0.0))
		var air_duration := float(unit.get("air_duration", 0.80))
		if elapsed >= air_duration:
			_release_wind_unit(state, definition, unit, damage)
			lifted.remove_at(index)
			continue
		var rise_progress := clampf(elapsed / 0.18, 0.0, 1.0)
		var rise := -rise_height * rise_progress
		var phase := float(unit.get("phase", 0.0))
		var float_y := sin(elapsed * 6.0 + phase) * minf(14.0, width * 0.12)
		var float_x := sin(elapsed * 4.6 + phase * 1.7) * minf(18.0, width * 0.16)
		var offset_x := float(unit.get("offset_x", 0.0))
		var base_y := float(unit.get("base_y", wind_position.y))
		var position := Vector2(wind_position.x + offset_x + float_x, base_y + rise + float_y)
		enemies.update_tianji_position(id, position)
		lifted[index] = unit
	state["wind_lifted"] = lifted

func _tick_wind_pending_pickups(state: Dictionary, definition: Dictionary, damage: float, delta: float) -> void:
	var pending: Array = state.get("wind_pending_pickups", []) as Array
	var replacement_remaining := maxf(0.0, float(state.get("wind_replacement_remaining", 0.0)) - delta)
	state["wind_replacement_remaining"] = replacement_remaining
	if _duel_formation_blocks_regular_enemy_displacement():
		var protected_claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
		for pickup_value in pending:
			var protected_id := int((pickup_value as Dictionary).get("id", -1))
			if enemies.is_active(protected_id) and enemies.get_type(protected_id) != EnemySimulation.EnemyType.ELITE:
				_apply_wind_direct_hit(state, definition, damage, protected_id)
			protected_claimed.erase(protected_id)
		state["wind_claimed"] = protected_claimed
		state["wind_pending_pickups"] = []
		state["wind_replacement_remaining"] = 0.0
		return
	var limit := _wind_lift_limit(definition, int(state.get("rank", 1)))
	var lifted: Array = state.get("wind_lifted", []) as Array
	while replacement_remaining <= 0.0 and lifted.size() < limit and not pending.is_empty():
		var pickup: Dictionary = pending.pop_front() as Dictionary
		var id := int(pickup.get("id", -1))
		if enemies.is_active(id) and not _wind_is_immune(state, id):
			_enqueue_wind_unit(state, definition, id)
			lifted = state.get("wind_lifted", []) as Array
		else:
			var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
			claimed.erase(id)
			state["wind_claimed"] = claimed
		if lifted.size() >= limit:
			break
	state["wind_pending_pickups"] = pending

func _collect_wind_targets(state: Dictionary, definition: Dictionary, damage: float, previous_x: float, current_x: float) -> void:
	var path_y := float(state.get("wind_path_y", 0.0))
	var width := float(state.get("wind_width", definition.get("width", 86.0)))
	var lower_x := minf(previous_x, current_x) - width * 0.50
	var upper_x := maxf(previous_x, current_x) + width * 0.50
	var limit := _wind_lift_limit(definition, int(state.get("rank", 1)))
	var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
	var protect_duel_formation := _duel_formation_blocks_regular_enemy_displacement()
	var wind_direction: Vector2 = state.get("wind_direction", Vector2.RIGHT)
	var travel_sign := -1.0 if wind_direction.x < 0.0 else 1.0
	var candidates: Array[int] = []
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.is_tianji_lifted(id) or not _is_wind_liftable_enemy(enemies.get_type(id)):
			continue
		var enemy_position := enemies.positions[id]
		if enemy_position.x < lower_x or enemy_position.x > upper_x or absf(enemy_position.y - path_y) > width * 0.50:
			continue
		if _wind_is_claimed(state, id) or _wind_is_immune(state, id):
			continue
		candidates.append(id)
	candidates.sort_custom(func(first_id: int, second_id: int) -> bool:
		var first_position := enemies.positions[first_id]
		var second_position := enemies.positions[second_id]
		if is_equal_approx(first_position.x, second_position.x):
			return first_id < second_id
		return first_position.x < second_position.x if travel_sign > 0.0 else first_position.x > second_position.x
	)
	for id in candidates:
		if protect_duel_formation and enemies.get_type(id) != EnemySimulation.EnemyType.ELITE:
			_apply_wind_direct_hit(state, definition, damage, id)
			claimed[id] = true
			continue
		var pending: Array = state.get("wind_pending_pickups", []) as Array
		if (state.get("wind_lifted", []) as Array).size() >= limit:
			var lifted: Array = state.get("wind_lifted", []) as Array
			if not lifted.is_empty():
				var oldest: Dictionary = lifted.pop_front() as Dictionary
				_release_wind_unit(state, definition, oldest, damage)
				state["wind_lifted"] = lifted
				state["wind_replacement_remaining"] = _wind_replacement_delay(definition)
			else:
				continue
			claimed[id] = true
			pending.append({"id": id})
			state["wind_pending_pickups"] = pending
			continue
		if float(state.get("wind_replacement_remaining", 0.0)) > 0.0 or not pending.is_empty():
			claimed[id] = true
			pending.append({"id": id})
			state["wind_pending_pickups"] = pending
			continue
		_enqueue_wind_unit(state, definition, id)
	state["wind_claimed"] = claimed
	_collect_wind_named_targets(state, definition, damage, lower_x, upper_x, path_y, width)

func _apply_wind_direct_hit(state: Dictionary, definition: Dictionary, damage: float, id: int) -> void:
	if not enemies.is_active(id):
		return
	var slow_multiplier := _slow_multiplier(definition, state)
	var slow_duration := float(definition.get("slow_duration", 1.65))
	var final_damage := CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id))
	enemies.apply_damage(id, final_damage)
	enemies.apply_slow(id, slow_multiplier, slow_duration)
	damage_applied.emit(1)

func _collect_wind_named_targets(state: Dictionary, definition: Dictionary, damage: float, lower_x: float, upper_x: float, path_y: float, width: float) -> void:
	var slow_multiplier := _slow_multiplier(definition, state)
	var slow_duration := float(definition.get("slow_duration", 1.65))
	var hit_count := 0
	var hit_elites: Dictionary = state.get("wind_hit_elites", {}) as Dictionary
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active:
			continue
		if elite.position.x < lower_x or elite.position.x > upper_x or absf(elite.position.y - path_y) > width * 0.50:
			continue
		var elite_key := elite.get_instance_id()
		if hit_elites.has(elite_key):
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		elite.apply_slow(slow_multiplier, slow_duration)
		hit_elites[elite_key] = true
		hit_count += 1
	state["wind_hit_elites"] = hit_elites
	if boss != null and boss.active and not bool(state.get("wind_hit_boss", false)) and boss.position.x >= lower_x and boss.position.x <= upper_x and absf(boss.position.y - path_y) <= width * 0.50:
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()), BossActor.VULNERABLE_DEFAULT_STANCE_DAMAGE)
		boss.apply_slow(slow_multiplier, slow_duration)
		state["wind_hit_boss"] = true
		hit_count += 1
	if hit_count > 0:
		damage_applied.emit(hit_count)

func _enqueue_wind_unit(state: Dictionary, definition: Dictionary, id: int) -> void:
	if not enemies.set_tianji_lifted(id, true):
		return
	var position := enemies.positions[id]
	var rank := int(state.get("rank", 1))
	var air_duration := _wind_rank_value(definition, "wind_air_durations", rank, 0.82)
	var width := float(state.get("wind_width", definition.get("width", 86.0)))
	var wind_position: Vector2 = state.get("wind_position", position)
	var unit := {
		"id": id,
		"elapsed": 0.0,
		"air_duration": air_duration,
		"offset_x": clampf(position.x - wind_position.x, -width * 0.42, width * 0.42),
		"base_y": position.y,
		"origin_position": position,
		"phase": randf_range(0.0, TAU),
	}
	var lifted: Array = state.get("wind_lifted", []) as Array
	lifted.append(unit)
	state["wind_lifted"] = lifted
	var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
	claimed[id] = true
	state["wind_claimed"] = claimed

func _release_wind_unit(state: Dictionary, definition: Dictionary, unit: Dictionary, damage: float) -> void:
	var id := int(unit.get("id", -1))
	if not enemies.is_tianji_lifted(id):
		return
	var was_active := enemies.is_active(id)
	var protect_duel_formation := _duel_formation_blocks_regular_enemy_displacement() and enemies.get_type(id) != EnemySimulation.EnemyType.ELITE
	if protect_duel_formation and unit.has("origin_position"):
		enemies.update_tianji_position(id, unit.get("origin_position", enemies.positions[id]))
	enemies.set_tianji_lifted(id, false)
	var final_damage := CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id))
	var defeated := enemies.apply_damage(id, final_damage)
	if was_active:
		damage_applied.emit(1)
	if not defeated and enemies.is_active(id) and not protect_duel_formation:
		var fling_direction := Vector2.from_angle(randf_range(0.0, TAU))
		var rank := clampi(int(state.get("rank", 1)), 1, 5)
		var configured_distance := _wind_rank_value(definition, "wind_fling_distance", rank, 92.0)
		var fling_distance := configured_distance * randf_range(0.88, 1.12)
		enemies.apply_knockback_only(id, fling_direction, 270.0, false, fling_distance, 0.30)
	var immune: Dictionary = state.get("wind_immune", {}) as Dictionary
	immune[id] = float(definition.get("wind_immune_duration", 1.05))
	state["wind_immune"] = immune
	state["wind_replacement_remaining"] = maxf(float(state.get("wind_replacement_remaining", 0.0)), _wind_replacement_delay(definition))
	var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
	claimed.erase(id)
	state["wind_claimed"] = claimed

func _finish_wind_tornado(state: Dictionary, definition: Dictionary, damage: float) -> void:
	var lifted: Array = state.get("wind_lifted", []) as Array
	while not lifted.is_empty():
		var unit: Dictionary = lifted.pop_front() as Dictionary
		_release_wind_unit(state, definition, unit, damage)
	state["wind_lifted"] = lifted
	# Waiting units were never lifted. Release their queue claims before the state
	# is discarded so a future tornado can consider them normally again.
	var pending: Array = state.get("wind_pending_pickups", []) as Array
	var claimed: Dictionary = state.get("wind_claimed", {}) as Dictionary
	for pickup_value in pending:
		var pickup: Dictionary = pickup_value as Dictionary
		claimed.erase(int(pickup.get("id", -1)))
	state["wind_pending_pickups"] = []
	state["wind_claimed"] = claimed
	state["wind_replacement_remaining"] = 0.0

func _wind_is_claimed(state: Dictionary, id: int) -> bool:
	return (state.get("wind_claimed", {}) as Dictionary).has(id)

func _wind_is_immune(state: Dictionary, id: int) -> bool:
	return float((state.get("wind_immune", {}) as Dictionary).get(id, 0.0)) > 0.0

func _wind_replacement_delay(definition: Dictionary) -> float:
	var configured_delay := maxf(0.02, float(definition.get("wind_replacement_delay", 0.14)))
	return clampf(randf_range(configured_delay * 0.75, configured_delay * 1.25), WIND_REPLACEMENT_DELAY_MIN, WIND_REPLACEMENT_DELAY_MAX)

func _is_wind_liftable_enemy(enemy_type: int) -> bool:
	return enemy_type != EnemySimulation.EnemyType.ELITE

func _duel_formation_blocks_regular_enemy_displacement() -> bool:
	return enemies != null and enemies.is_duel_formation_active()

func _wind_rank_value(definition: Dictionary, key: String, rank: int, fallback: float) -> float:
	var values: Array = definition.get(key, []) as Array
	if values.is_empty():
		return fallback
	return float(values[clampi(rank - 1, 0, values.size() - 1)])

func _wind_lift_limit(definition: Dictionary, rank: int) -> int:
	var values: Array = definition.get("wind_lift_limits", []) as Array
	if values.is_empty():
		return 4
	return maxi(1, int(values[clampi(rank - 1, 0, values.size() - 1)]))

func _execute_arrow_volley(anchor: Vector2, _direction: Vector2, definition: Dictionary, _state: Dictionary, damage: float, _volley_index: int) -> int:
	var radius := float(definition.get("radius", 230.0))
	var hit_count := _apply_circle(anchor, radius, damage, 1.0, 0.0)
	skill_impacted.emit("arrow_support_volley", anchor, Vector2.DOWN, hit_count, 0.0, int(_state.get("rank", 1)), radius)
	return hit_count

func _apply_wind(direction: Vector2, damage: float, definition: Dictionary, state: Dictionary) -> int:
	var normalized_direction := direction.normalized()
	var range := float(definition.get("range", 206.0))
	var width := float(definition.get("width", 86.0))
	var slow_multiplier := _slow_multiplier(definition, state)
	var slow_duration := float(definition.get("slow_duration", 1.65))
	var knockback := float(definition.get("knockback", 210.0)) * (1.0 + float(state.get("knockback_bonus", 0.0)))
	var protect_duel_formation := _duel_formation_blocks_regular_enemy_displacement()
	var hit_count := 0
	var target_rect := _visible_target_rect()
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.is_tianji_lifted(id) or not target_rect.has_point(enemies.positions[id]) or not _point_in_wind_path(enemies.positions[id], normalized_direction, range, width):
			continue
		var final_damage := CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id))
		var enemy_knockback := knockback
		if protect_duel_formation and enemies.get_type(id) != EnemySimulation.EnemyType.ELITE:
			enemy_knockback = 0.0
		enemies.apply_hit(id, final_damage, normalized_direction, enemy_knockback)
		enemies.apply_slow(id, slow_multiplier, slow_duration)
		hit_count += 1
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or not target_rect.has_point(elite.position) or not _point_in_wind_path(elite.position, normalized_direction, range, width):
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		elite.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if boss != null and boss.active and target_rect.has_point(boss.position) and _point_in_wind_path(boss.position, normalized_direction, range, width):
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()), BossActor.VULNERABLE_DEFAULT_STANCE_DAMAGE)
		boss.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if hit_count > 0:
		damage_applied.emit(hit_count)
	return hit_count

func _point_in_wind_path(point: Vector2, direction: Vector2, range: float, width: float) -> bool:
	var offset := point - player.position
	var projected := offset.dot(direction)
	return projected >= 0.0 and projected <= range and absf(offset.cross(direction)) <= width * 0.5

func _skill_for_upgrade(upgrade_id: String) -> String:
	if upgrade_id.begins_with("tianji_lightning"):
		return "seven_star_lightning"
	if upgrade_id.begins_with("tianji_wind"):
		return "xun_wind_break"
	if upgrade_id.begins_with("tianji_water"):
		return "eight_trigram_tide"
	return ""

func _start_cooldown(state: Dictionary, skill_id: String) -> void:
	if bool(state.get("cooldown_started", false)) and bool(state.get("effect_finished", true)):
		return
	state["effect_finished"] = true
	state["cooldown_started"] = true
	state["cooldown_remaining"] = _cooldown_for(skill_id, state)

func _effect_fully_finished(skill_id: String, state: Dictionary) -> bool:
	if float(state.get("active_remaining", 0.0)) > 0.0:
		return false
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	match str(definition.get("kind", "")):
		"lightning":
			return pending_lightning_strikes.is_empty()
		"fire_rain":
			return pending_fire_meteors.is_empty() and fire_zones.is_empty()
		"wind":
			return (state.get("wind_lifted", []) as Array).is_empty() and (state.get("wind_pending_pickups", []) as Array).is_empty()
		"water":
			return str(state.get("water_phase", "")) == "done"
	return true

func _cooldown_for(skill_id: String, state: Dictionary) -> float:
	var rank := int(state.get("rank", 1))
	return maxf(2.8, TIANJI_CATALOG.cooldown_for(skill_id, rank) * (1.0 - float(state.get("cooldown_bonus", 0.0))))

func _damage_ratio_for(skill_id: String, state: Dictionary) -> float:
	return TIANJI_CATALOG.damage_ratio_for(skill_id, int(state.get("rank", 1))) * (1.0 + float(state.get("damage_bonus", 0.0)))

func _slow_multiplier(definition: Dictionary, state: Dictionary) -> float:
	return maxf(0.22, float(definition.get("slow_multiplier", 1.0)) - float(state.get("slow_bonus", 0.0)))

func _duration_for(definition: Dictionary, state: Dictionary) -> float:
	return float(definition.get("duration", 0.0)) + float(state.get("duration_bonus", 0.0))

func _schedule_extra_lightning(center: Vector2, primary_radius: float, state: Dictionary, definition: Dictionary) -> void:
	var extra_count := int(state.get("target_bonus", 0))
	var primary_rank := int(state.get("rank", 1))
	if extra_count <= 0 or primary_rank <= 1:
		return
	var used_ids: Array[int] = []
	var target_rect := _visible_target_rect()
	var used_elites: Array[EliteActor] = []
	var boss_reserved := false
	var fallback_positions: Array[Vector2] = []
	var accumulated_delay := 0.0
	state["lightning_extra_delay"] = 0.0
	for index in range(extra_count):
		var secondary_rank := randi_range(1, primary_rank - 1)
		var secondary_radius := TIANJI_CATALOG.radius_for("seven_star_lightning", secondary_rank) * 0.70
		var target := _secondary_lightning_target(center, primary_radius, target_rect, used_ids, used_elites, boss_reserved)
		if not bool(target.get("valid", false)):
			var fallback_position := _fallback_lightning_position(center, secondary_radius, target_rect, fallback_positions)
			fallback_positions.append(fallback_position)
			target = {"valid": true, "position": fallback_position}
		boss_reserved = boss_reserved or bool(target.get("boss", false))
		var enemy_id := int(target.get("enemy_id", -1))
		if enemy_id >= 0:
			used_ids.append(enemy_id)
		var elite := target.get("elite") as EliteActor
		if elite != null:
			used_elites.append(elite)
		accumulated_delay += randf_range(0.20, 0.50) if index == 0 else randf_range(0.15, 0.40)
		pending_lightning_strikes.append({
			"remaining": accumulated_delay,
			"center": target.get("position", center),
			"rank": secondary_rank,
			"radius": secondary_radius,
			"damage_ratio": TIANJI_CATALOG.damage_ratio_for("seven_star_lightning", secondary_rank) * (1.0 + float(state.get("damage_bonus", 0.0))) * 0.62,
			"slow_multiplier": _slow_multiplier(definition, state),
			"slow_duration": float(definition.get("slow_duration", 0.0)),
		})
	state["lightning_extra_delay"] = accumulated_delay

func _secondary_lightning_target(center: Vector2, primary_radius: float, target_rect: Rect2, used_ids: Array[int], used_elites: Array[EliteActor], boss_reserved: bool) -> Dictionary:
	var minimum_distance_squared := primary_radius * primary_radius
	if not boss_reserved and boss != null and boss.active and target_rect.has_point(boss.position) and boss.position.distance_squared_to(center) > minimum_distance_squared:
		return {"valid": true, "position": boss.position, "boss": true}
	var best_elite: EliteActor = null
	var best_elite_distance := INF
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or used_elites.has(elite) or not target_rect.has_point(elite.position):
			continue
		var elite_distance := elite.position.distance_squared_to(center)
		if elite_distance <= minimum_distance_squared or elite_distance >= best_elite_distance:
			continue
		best_elite = elite
		best_elite_distance = elite_distance
	if best_elite != null:
		return {"valid": true, "position": best_elite.position, "elite": best_elite}
	var best_id := -1
	var best_distance := INF
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.is_tianji_lifted(id) or used_ids.has(id) or not target_rect.has_point(enemies.positions[id]):
			continue
		var distance := enemies.positions[id].distance_squared_to(center)
		if distance <= minimum_distance_squared or distance >= best_distance:
			continue
		best_id = id
		best_distance = distance
	if best_id >= 0:
		return {"valid": true, "position": enemies.positions[best_id], "enemy_id": best_id}
	return {"valid": false}

func _fallback_lightning_position(center: Vector2, secondary_radius: float, target_rect: Rect2, used_positions: Array[Vector2]) -> Vector2:
	# A chain upgrade must remain visible even when the primary strike already
	# covers every available target. Keep the offset inside the secondary radius
	# so a lone boss can still be hit without stacked impact visuals.
	var maximum_offset := clampf(secondary_radius * 0.42, 18.0, 42.0)
	var minimum_offset := minf(14.0, maximum_offset * 0.65)
	var inset := minf(maximum_offset, minf(target_rect.size.x, target_rect.size.y) * 0.18)
	var safe_rect := target_rect.grow(-inset)
	if safe_rect.size.x <= 0.0 or safe_rect.size.y <= 0.0:
		safe_rect = target_rect
	var minimum_separation := maximum_offset * 0.70
	for _attempt in range(8):
		var offset := Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(minimum_offset, maximum_offset)
		var candidate := center + offset
		candidate = Vector2(
			clampf(candidate.x, safe_rect.position.x, safe_rect.end.x),
			clampf(candidate.y, safe_rect.position.y, safe_rect.end.y)
		)
		var separated := true
		for used_position in used_positions:
			if candidate.distance_squared_to(used_position) < minimum_separation * minimum_separation:
				separated = false
				break
		if separated:
			return candidate
	var final_candidate := center + Vector2.from_angle(randf_range(0.0, TAU)) * minimum_offset
	return Vector2(
		clampf(final_candidate.x, safe_rect.position.x, safe_rect.end.x),
		clampf(final_candidate.y, safe_rect.position.y, safe_rect.end.y)
	)

func _tick_pending_lightning_strikes(delta: float) -> void:
	for index in range(pending_lightning_strikes.size()):
		var strike: Dictionary = pending_lightning_strikes[index] as Dictionary
		strike["remaining"] = float(strike.get("remaining", 0.0)) - delta
		pending_lightning_strikes[index] = strike
	while not pending_lightning_strikes.is_empty() and float((pending_lightning_strikes[0] as Dictionary).get("remaining", 0.0)) <= 0.0:
		var strike: Dictionary = pending_lightning_strikes.pop_front() as Dictionary
		var damage := player.total_attack() * float(strike.get("damage_ratio", 0.0))
		var center: Vector2 = strike.get("center", Vector2.ZERO)
		var hit_count := _apply_circle(center, float(strike.get("radius", 0.0)), damage, float(strike.get("slow_multiplier", 1.0)), float(strike.get("slow_duration", 0.0)))
		skill_impacted.emit("seven_star_lightning", center, Vector2.DOWN, hit_count, 0.0, int(strike.get("rank", 1)), float(strike.get("radius", 0.0)))

func _visible_target_rect(inset: float = 0.0) -> Rect2:
	if battle_camera != null and is_instance_valid(battle_camera):
		var viewport_size := get_viewport().get_visible_rect().size
		if viewport_size.x > 0.0 and viewport_size.y > 0.0:
			var zoom := battle_camera.zoom
			var visible_size := Vector2(
				viewport_size.x / maxf(0.01, zoom.x),
				viewport_size.y / maxf(0.01, zoom.y)
			)
			var visible_rect := Rect2(battle_camera.get_screen_center_position() - visible_size * 0.5, visible_size)
			var margin := minf(maxf(0.0, inset), minf(visible_size.x, visible_size.y) * 0.32)
			return visible_rect.grow(-margin)
	var fallback_center := player.position if player != null else Vector2.ZERO
	return Rect2(fallback_center - Vector2.ONE * TARGET_SCAN_RANGE, Vector2.ONE * TARGET_SCAN_RANGE * 2.0)
