class_name CombatSystem
extends Node

func resolve_hero_attack(request: AttackRequest, hero_attack: float, hero_bonus: float, enemies: EnemySimulation) -> int:
	var hits := enemies.query(request)
	if request.displacement_only:
		return _resolve_displacement_only(request, hits, enemies)
	var empowered_targets := _select_empowered_knockback_targets(request, hits)
	var resolved_hits := 0
	var launched_targets := 0
	for id in hits:
		if request.excluded_enemy_ids.has(id):
			continue
		if enemies.is_duel_formation_sealed() and enemies.is_duel_shield(id):
			enemies.block_duel_shield_hit(id)
			if request.one_hit_per_target:
				request.hit_targets[id] = true
			continue
		var damage := CombatMath.final_damage(hero_attack, request.damage_multiplier_at(enemies.positions[id]), hero_bonus, enemies.get_armor(id))
		if enemies.get_type(id) == EnemySimulation.EnemyType.SHIELD:
			var attacker_direction := (request.origin - enemies.positions[id]).normalized()
			if enemies.get_facing_direction(id).dot(attacker_direction) >= 0.35:
				damage *= 0.45
		var knockback_direction := request.direction
		if request.shape == AttackRequest.Shape.CIRCLE or request.fan_knockback:
			knockback_direction = enemies.positions[id] - request.origin
		if knockback_direction.length_squared() <= 0.01:
			knockback_direction = request.direction
		var knockback := request.knockback
		if request.prevent_elite_knockback and enemies.get_type(id) == EnemySimulation.EnemyType.ELITE:
			knockback = 0.0
		if empowered_targets.has(id):
			knockback *= request.empowered_knockback_multiplier
		enemies.apply_hit(id, damage, knockback_direction, knockback, request.ignore_knockback_resistance, request.forced_displacement, request.forced_displacement_duration)
		if request.launches_enemies and (request.launch_target_limit <= 0 or launched_targets < request.launch_target_limit):
			if enemies.launch_enemy(
				id,
				knockback_direction,
				request.launch_speed,
				request.launch_duration,
				maxf(1.0, damage * request.launch_collision_damage_multiplier),
				request.launch_collision_knockback,
				request.launch_collision_max_targets,
				request.launch_relay_count
			):
				launched_targets += 1
		if request.slow_duration > 0.0 and request.slow_multiplier < 1.0:
			enemies.apply_slow(id, request.slow_multiplier, request.slow_duration)
		if request.one_hit_per_target:
			request.hit_targets[id] = true
		request.total_hits += 1
		resolved_hits += 1
	return resolved_hits

func _resolve_displacement_only(request: AttackRequest, hits: Array[int], enemies: EnemySimulation) -> int:
	var resolved_hits := 0
	for id in hits:
		if request.excluded_enemy_ids.has(id):
			continue
		if enemies.is_duel_formation_sealed() and enemies.is_duel_shield(id):
			enemies.block_duel_shield_hit(id)
			if request.one_hit_per_target:
				request.hit_targets[id] = true
			continue
		var knockback_direction := request.direction
		if request.shape == AttackRequest.Shape.CIRCLE or request.fan_knockback:
			knockback_direction = enemies.positions[id] - request.origin
		if knockback_direction.length_squared() <= 0.01:
			knockback_direction = request.direction
		enemies.apply_knockback_only(id, knockback_direction, request.knockback, request.ignore_knockback_resistance, request.forced_displacement, request.forced_displacement_duration)
		if request.one_hit_per_target:
			request.hit_targets[id] = true
		request.total_hits += 1
		resolved_hits += 1
	return resolved_hits

func resolve_player_attack(request: AttackRequest, player_attack: float, player_bonus: float, enemies: EnemySimulation) -> int:
	return resolve_hero_attack(request, player_attack, player_bonus, enemies)

func _select_empowered_knockback_targets(request: AttackRequest, hits: Array[int]) -> Dictionary:
	var selected: Dictionary = {}
	if not request.empowered_knockback_active or request.empowered_knockback_target_limit <= 0:
		return selected
	var remaining_slots := request.empowered_knockback_target_limit - request.empowered_knockback_targets.size()
	if remaining_slots <= 0:
		return selected
	var candidates: Array[int] = []
	for id in hits:
		if not request.empowered_knockback_targets.has(id):
			candidates.append(id)
	candidates.shuffle()
	for index in range(mini(remaining_slots, candidates.size())):
		var id := candidates[index]
		selected[id] = true
		request.empowered_knockback_targets[id] = true
	return selected

func request_hits_point(request: AttackRequest, point: Vector2) -> bool:
	var offset := point - request.origin
	match request.shape:
		AttackRequest.Shape.CIRCLE:
			return offset.length_squared() <= request.range * request.range
		AttackRequest.Shape.FAN:
			var distance_squared := offset.length_squared()
			return distance_squared >= request.inner_radius * request.inner_radius and distance_squared <= request.range * request.range and absf(request.direction.angle_to(offset.normalized())) <= request.half_angle
		AttackRequest.Shape.LINE:
			var projected := offset.dot(request.direction)
			return projected >= 0.0 and projected <= request.range and absf(offset.cross(request.direction)) <= request.width * 0.5
	return false
