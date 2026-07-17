class_name CombatSystem
extends Node

func resolve_player_attack(request: AttackRequest, player_attack: float, player_bonus: float, enemies: EnemySimulation) -> int:
	var hits := enemies.query(request)
	var empowered_targets := _select_empowered_knockback_targets(request, hits)
	for id in hits:
		var damage := CombatMath.final_damage(player_attack, request.multiplier, player_bonus, enemies.get_armor(id))
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
		if empowered_targets.has(id):
			knockback *= request.empowered_knockback_multiplier
		enemies.apply_hit(id, damage, knockback_direction, knockback, request.ignore_knockback_resistance, request.forced_displacement, request.forced_displacement_duration)
		if request.one_hit_per_target:
			request.hit_targets[id] = true
		request.total_hits += 1
	return hits.size()

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
			return offset.length_squared() <= request.range * request.range and absf(request.direction.angle_to(offset.normalized())) <= request.half_angle
		AttackRequest.Shape.LINE:
			var projected := offset.dot(request.direction)
			return projected >= 0.0 and projected <= request.range and absf(offset.cross(request.direction)) <= request.width * 0.5
	return false
