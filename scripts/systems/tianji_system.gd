class_name TianjiSystem
extends Node

const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const TARGET_SCAN_RANGE := 720.0
const MAX_FIRE_ZONES := 18

signal skill_windup_started(skill_id: String, center: Vector2, direction: Vector2, definition: Dictionary)
signal skill_impacted(skill_id: String, center: Vector2, direction: Vector2, hit_count: int, active_duration: float)

var player: HeroActor
var enemies: EnemySimulation
var elites: Array[EliteActor] = []
var boss: BossActor
var skill_states: Dictionary = {}
var slot_order: Array[String] = []
var fire_zones: Array[Dictionary] = []

func configure(player_actor: HeroActor, enemy_simulation: EnemySimulation, elite_actors: Array[EliteActor], boss_actor: BossActor) -> void:
	player = player_actor
	enemies = enemy_simulation
	elites = elite_actors
	boss = boss_actor
	skill_states.clear()
	slot_order.clear()
	fire_zones.clear()

func active_skill_ids() -> Array[String]:
	return slot_order.duplicate()

func can_activate(skill_id: String) -> bool:
	return not TIANJI_CATALOG.definition_for(skill_id).is_empty() and SaveService.tianji_rank(skill_id) > 0 and not skill_states.has(skill_id) and slot_order.size() < TIANJI_CATALOG.MAX_ACTIVE_PER_RUN

func activate_skill(skill_id: String) -> bool:
	if not can_activate(skill_id):
		return false
	slot_order.append(skill_id)
	skill_states[skill_id] = {
		"rank": SaveService.tianji_rank(skill_id),
		"cooldown_remaining": 1.35,
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
	}
	return true

func apply_run_upgrade(upgrade_id: String) -> bool:
	var skill_id := _skill_for_upgrade(upgrade_id)
	if skill_id.is_empty() or not skill_states.has(skill_id):
		return false
	var state: Dictionary = skill_states[skill_id] as Dictionary
	match upgrade_id:
		"tianji_lightning_cooldown", "tianji_wind_cooldown", "tianji_fire_cooldown", "tianji_arrow_cooldown": state["cooldown_bonus"] = minf(0.36, float(state.get("cooldown_bonus", 0.0)) + 0.12)
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
			skill_states[skill_id] = state
			continue
		state["cooldown_remaining"] = maxf(0.0, float(state.get("cooldown_remaining", 0.0)) - delta)
		if float(state["cooldown_remaining"]) <= 0.0:
			_begin_skill(skill_id, state)
		skill_states[skill_id] = state
	_tick_fire_zones(delta)

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
			"rank": rank,
			"color": definition.get("color", Color.WHITE),
			"cooldown": _cooldown_for(skill_id, state),
			"cooldown_remaining": float(state.get("cooldown_remaining", 0.0)),
			"windup_remaining": float(state.get("windup_remaining", 0.0)),
			"active_remaining": float(state.get("active_remaining", 0.0)),
			"active_duration": _duration_for(definition, state),
		})
	return slots

func _begin_skill(skill_id: String, state: Dictionary) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	var target := _select_target(skill_id, definition)
	if not bool(target.get("valid", false)):
		state["cooldown_remaining"] = 0.50
		return
	var center: Vector2 = target.get("center", player.position)
	var direction: Vector2 = target.get("direction", Vector2.RIGHT)
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	state["center"] = center
	state["direction"] = direction.normalized()
	state["windup_remaining"] = float(definition.get("precast", 0.5))
	skill_windup_started.emit(skill_id, center, direction, definition)

func _resolve_skill(skill_id: String, state: Dictionary) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	var center: Vector2 = state.get("center", player.position)
	var direction: Vector2 = state.get("direction", Vector2.RIGHT)
	var damage := player.total_attack() * _damage_ratio_for(skill_id, state)
	var hit_count := 0
	var emit_primary_impact := true
	match str(definition.get("kind", "")):
		"lightning":
			var radius := float(definition.get("radius", 72.0)) * float(state.get("radius_ratio", 1.0))
			var slow_multiplier := _slow_multiplier(definition, state)
			hit_count = _apply_circle(center, radius, damage, slow_multiplier, float(definition.get("slow_duration", 0.0)))
			hit_count += _apply_extra_lightning(center, radius, damage, slow_multiplier, float(definition.get("slow_duration", 0.0)), int(state.get("target_bonus", 0)))
		"wind":
			hit_count = _apply_wind(direction, damage, definition, state)
		"water":
			var water_radius := float(definition.get("radius", 110.0)) * float(state.get("radius_ratio", 1.0))
			hit_count = _apply_circle(center, water_radius, damage, _slow_multiplier(definition, state), float(definition.get("slow_duration", 0.0)))
			state["active_remaining"] = _duration_for(definition, state)
			state["next_tick"] = float(definition.get("tick_interval", 0.65))
		"fire_rain":
			state["wave_index"] = 1
			state["active_remaining"] = float(maxi(1, int(definition.get("wave_count", 3))) - 1) * float(definition.get("wave_interval", 0.34)) + 0.16
			state["next_tick"] = float(definition.get("wave_interval", 0.34))
			hit_count = _execute_fire_rain_wave(center, definition, state, damage, 0)
			emit_primary_impact = false
		"arrow_volley":
			state["volley_index"] = 1
			state["active_remaining"] = float(maxi(1, int(definition.get("volley_count", 3)) + int(state.get("volley_bonus", 0))) - 1) * float(definition.get("volley_interval", 0.30)) + 0.16
			state["next_tick"] = float(definition.get("volley_interval", 0.30))
			hit_count = _execute_arrow_volley(center, direction, definition, state, damage, 0)
			emit_primary_impact = false
	state["cooldown_remaining"] = _cooldown_for(skill_id, state)
	if emit_primary_impact:
		skill_impacted.emit(skill_id, center, direction, hit_count, float(state.get("active_remaining", 0.0)))

func _tick_active_skill(skill_id: String, state: Dictionary, delta: float) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	state["active_remaining"] = maxf(0.0, float(state["active_remaining"]) - delta)
	state["cooldown_remaining"] = maxf(0.0, float(state.get("cooldown_remaining", 0.0)) - delta)
	state["next_tick"] = float(state["next_tick"]) - delta
	if float(state["next_tick"]) > 0.0:
		return
	var damage := player.total_attack() * _damage_ratio_for(skill_id, state)
	var center: Vector2 = state.get("center", player.position)
	match str(definition.get("kind", "")):
		"water":
			_apply_circle(center, float(definition.get("radius", 110.0)) * float(state.get("radius_ratio", 1.0)), damage, _slow_multiplier(definition, state), float(definition.get("slow_duration", 0.0)))
			state["next_tick"] = float(definition.get("tick_interval", 0.65))
		"fire_rain":
			var wave_index := int(state.get("wave_index", 0))
			var wave_count := int(definition.get("wave_count", 3))
			if wave_index < wave_count:
				_execute_fire_rain_wave(center, definition, state, damage, wave_index)
				state["wave_index"] = wave_index + 1
				state["next_tick"] = float(definition.get("wave_interval", 0.34))
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

func _select_target(skill_id: String, definition: Dictionary) -> Dictionary:
	var selection_range := TARGET_SCAN_RANGE
	var radius := float(definition.get("radius", definition.get("width", 86.0)))
	var best_position := player.position
	var best_score := -INF
	var has_target := false
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id):
			continue
		var candidate := enemies.positions[id]
		var distance := candidate.distance_to(player.position)
		if distance > selection_range:
			continue
		var density := enemies.count_active_within(candidate, radius)
		var score := float(density) * 120.0 - distance * 0.16
		if score > best_score:
			best_score = score
			best_position = candidate
			has_target = true
	if best_score < 0.0:
		var named_target := _nearest_named_target(selection_range)
		if named_target != Vector2.ZERO:
			best_position = named_target
			has_target = true
	var direction := (best_position - player.position).normalized()
	if direction.length_squared() <= 0.01:
		direction = player.last_attack_direction.normalized()
	return {"valid": has_target, "center": player.position if str(definition.get("kind", "")) == "wind" else best_position, "direction": direction}

func _nearest_named_target(max_distance: float) -> Vector2:
	var best_position := Vector2.ZERO
	var best_distance := max_distance
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active:
			continue
		var distance := elite.position.distance_to(player.position)
		if distance < best_distance:
			best_distance = distance
			best_position = elite.position
	if boss != null and boss.active:
		var boss_distance := boss.position.distance_to(player.position)
		if boss_distance < best_distance:
			best_position = boss.position
	return best_position

func _apply_circle(center: Vector2, radius: float, damage: float, slow_multiplier: float, slow_duration: float) -> int:
	var hit_count := 0
	var radius_squared := radius * radius
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or enemies.positions[id].distance_squared_to(center) > radius_squared:
			continue
		enemies.apply_damage(id, CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id)))
		if slow_duration > 0.0:
			enemies.apply_slow(id, slow_multiplier, slow_duration)
		hit_count += 1
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or elite.position.distance_squared_to(center) > radius_squared:
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		if slow_duration > 0.0:
			elite.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if boss != null and boss.active and boss.position.distance_squared_to(center) <= radius_squared:
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()))
		if slow_duration > 0.0:
			boss.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	return hit_count

func _execute_fire_rain_wave(anchor: Vector2, definition: Dictionary, state: Dictionary, damage: float, wave_index: int) -> int:
	var hit_count := 0
	var strike_count := int(definition.get("strike_count", 5)) + int(state.get("strike_bonus", 0))
	for strike_index in range(strike_count):
		var strike_position := _fire_strike_position(anchor, wave_index, strike_index, strike_count, state)
		hit_count += _spawn_fire_zone(strike_position, definition, state, damage)
	return hit_count

func _fire_strike_position(anchor: Vector2, wave_index: int, strike_index: int, strike_count: int, state: Dictionary) -> Vector2:
	var angle := float(state.get("fire_seed", 0.0)) + float(wave_index) * 0.76 + TAU * float(strike_index) / float(maxi(1, strike_count))
	var distance_ratio := 0.46 + 0.54 * (sin(float(wave_index * 17 + strike_index * 11) * 0.73 + angle) + 1.0) * 0.5
	var distance := 28.0 + 122.0 * distance_ratio
	return anchor + Vector2.from_angle(angle) * distance

func _spawn_fire_zone(center: Vector2, definition: Dictionary, state: Dictionary, damage: float) -> int:
	var radius := float(definition.get("radius", 52.0)) * float(state.get("radius_ratio", 1.0))
	var hit_count := _apply_circle(center, radius, damage * 0.62, 1.0, 0.0)
	var duration := _duration_for(definition, state)
	if fire_zones.size() >= MAX_FIRE_ZONES:
		fire_zones.pop_front()
	fire_zones.append({
		"center": center,
		"radius": radius,
		"remaining": duration,
		"next_tick": float(definition.get("tick_interval", 0.48)),
		"tick_interval": float(definition.get("tick_interval", 0.48)),
		"damage": damage * float(definition.get("burn_tick_ratio", 0.28)),
	})
	skill_impacted.emit("fire_rain_burning", center, Vector2.DOWN, hit_count, duration)
	return hit_count

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

func _execute_arrow_volley(anchor: Vector2, _direction: Vector2, definition: Dictionary, _state: Dictionary, damage: float, _volley_index: int) -> int:
	var radius := float(definition.get("radius", 230.0))
	var hit_count := _apply_circle(anchor, radius, damage, 1.0, 0.0)
	skill_impacted.emit("arrow_support_volley", anchor, Vector2.DOWN, hit_count, 0.0)
	return hit_count

func _apply_wind(direction: Vector2, damage: float, definition: Dictionary, state: Dictionary) -> int:
	var normalized_direction := direction.normalized()
	var range := float(definition.get("range", 206.0))
	var width := float(definition.get("width", 86.0))
	var slow_multiplier := _slow_multiplier(definition, state)
	var slow_duration := float(definition.get("slow_duration", 1.65))
	var knockback := float(definition.get("knockback", 210.0)) * (1.0 + float(state.get("knockback_bonus", 0.0)))
	var hit_count := 0
	for id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(id) or not _point_in_wind_path(enemies.positions[id], normalized_direction, range, width):
			continue
		var final_damage := CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(id))
		enemies.apply_hit(id, final_damage, normalized_direction, knockback)
		enemies.apply_slow(id, slow_multiplier, slow_duration)
		hit_count += 1
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active or not _point_in_wind_path(elite.position, normalized_direction, range, width):
			continue
		elite.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, elite.armor()))
		elite.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
	if boss != null and boss.active and _point_in_wind_path(boss.position, normalized_direction, range, width):
		boss.receive_player_hit(CombatMath.final_damage(player.total_attack(), damage / maxf(0.01, player.total_attack()), 0.0, boss.armor()))
		boss.apply_slow(slow_multiplier, slow_duration)
		hit_count += 1
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

func _cooldown_for(skill_id: String, state: Dictionary) -> float:
	var rank := int(state.get("rank", 1))
	return maxf(2.8, TIANJI_CATALOG.cooldown_for(skill_id, rank) * (1.0 - float(state.get("cooldown_bonus", 0.0))))

func _damage_ratio_for(skill_id: String, state: Dictionary) -> float:
	return TIANJI_CATALOG.damage_ratio_for(skill_id, int(state.get("rank", 1))) * (1.0 + float(state.get("damage_bonus", 0.0)))

func _slow_multiplier(definition: Dictionary, state: Dictionary) -> float:
	return maxf(0.22, float(definition.get("slow_multiplier", 1.0)) - float(state.get("slow_bonus", 0.0)))

func _duration_for(definition: Dictionary, state: Dictionary) -> float:
	return float(definition.get("duration", 0.0)) + float(state.get("duration_bonus", 0.0))

func _apply_extra_lightning(center: Vector2, radius: float, damage: float, slow_multiplier: float, slow_duration: float, extra_count: int) -> int:
	var hit_count := 0
	var used_ids: Array[int] = []
	for _index in range(extra_count):
		var best_id := -1
		var best_distance := INF
		for id in range(EnemySimulation.CAPACITY):
			if not enemies.is_active(id) or used_ids.has(id):
				continue
			var distance := enemies.positions[id].distance_squared_to(center)
			if distance <= radius * radius:
				continue
			if distance < best_distance:
				best_distance = distance
				best_id = id
		if best_id < 0:
			break
		used_ids.append(best_id)
		var extra_damage := damage * 0.62
		enemies.apply_damage(best_id, CombatMath.final_damage(player.total_attack(), extra_damage / maxf(0.01, player.total_attack()), 0.0, enemies.get_armor(best_id)))
		if slow_duration > 0.0:
			enemies.apply_slow(best_id, slow_multiplier, slow_duration)
		hit_count += 1
	return hit_count
