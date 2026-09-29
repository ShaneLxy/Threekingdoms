class_name SummonedAllySystem
extends RefCounted

## 通用召唤队友逻辑。
##
## 本类只维护召唤队友的状态和决策，不依赖具体战斗场景、敌人节点或渲染器。
## 由宿主场景通过 Callable 提供选敌、目标查询、伤害结算和位置修正，
## 因此同一套逻辑可以被马超无双或其他通用技能复用。
##
## 回调约定：
## - target_provider(position, search_radius, ally_id) -> Dictionary
##   返回 {"id": int, "position": Vector2}，无目标返回空字典。
## - target_lookup(target_id) -> Dictionary
##   返回目标最新位置；返回空字典表示目标已死亡或失效。
## - damage_target(ally_id, target_id, raw_damage) -> bool
##   宿主负责敌军护甲、受击、击杀和奖励结算。
## - position_resolver(origin, candidate, ally_id) -> Vector2（可选）
##   宿主可用于碰撞、地图边界或寻路修正。

const COMBAT_MATH = preload("res://scripts/domain/combat_math.gd")

signal ally_spawned(ally: Dictionary)
signal ally_damaged(ally_id: int, amount: float, health: float)
signal ally_died(ally_id: int, at: Vector2)
signal ally_expired(ally_id: int, at: Vector2)
signal ally_attacked(ally_id: int, target_id: int, damage: float, at: Vector2)
signal targeting_changed()

enum AttackState { READY, WINDUP, RECOVERY }

const MAX_SUMMON_COUNT := 24
const DEFAULT_CONFIG := {
	"duration": 20.0,
	"search_radius": 520.0,
	"attack_range": 58.0,
	"attack_interval": 1.35,
	"attack_windup": 0.42,
	"attack_recovery": 0.24,
	"attack_visual_duration": 0.46,
	"attack_multiplier": 1.0,
	"move_speed": 118.0,
	"follow_distance": 96.0,
	"follow_spacing": 34.0,
	"target_refresh_interval": 0.24,
	"target_release_radius": 700.0,
	"separation_radius": 42.0,
	"separation_strength": 72.0,
	"health_mode": "current_as_max",
	"world_bounds": Rect2(),
}

var target_provider: Callable
var target_lookup: Callable
var damage_target: Callable
var position_resolver: Callable

var _next_ally_id := 1
var _allies: Array[Dictionary] = []


func _init(
	target_provider_callback: Callable = Callable(),
	target_lookup_callback: Callable = Callable(),
	damage_target_callback: Callable = Callable(),
	position_resolver_callback: Callable = Callable()
) -> void:
	configure_callbacks(
		target_provider_callback,
		target_lookup_callback,
		damage_target_callback,
		position_resolver_callback
	)


## 更新外部依赖。可在切换战斗场景时复用同一个系统实例。
func configure_callbacks(
	target_provider_callback: Callable = Callable(),
	target_lookup_callback: Callable = Callable(),
	damage_target_callback: Callable = Callable(),
	position_resolver_callback: Callable = Callable()
) -> void:
	target_provider = target_provider_callback
	target_lookup = target_lookup_callback
	damage_target = damage_target_callback
	position_resolver = position_resolver_callback


## 召唤一批队友。
##
## player_snapshot 至少包含 attack、defense、health，可选 max_health。
## 默认 health_mode=current_as_max：召唤时玩家当前生命同时作为队友最大生命，
## 从而严格锁定召唤瞬间的攻、防、血。需要保留玩家最大生命时可传 preserve_max。
func summon(
	player_snapshot: Dictionary,
	count: int,
	config: Dictionary = {},
	origin: Vector2 = Vector2.ZERO
) -> Array[Dictionary]:
	var resolved_config: Dictionary = DEFAULT_CONFIG.duplicate(true)
	for key in config:
		resolved_config[key] = config[key]

	var summon_count := clampi(count, 0, MAX_SUMMON_COUNT)
	if summon_count <= 0:
		return []

	var attack := maxf(0.0, float(player_snapshot.get("attack", 0.0)))
	var defense := maxf(0.0, float(player_snapshot.get("defense", 0.0)))
	var current_health := maxf(0.0, float(player_snapshot.get("health", 0.0)))
	var snapshot_max_health := maxf(current_health, float(player_snapshot.get("max_health", current_health)))
	var health_mode := str(resolved_config.get("health_mode", "current_as_max"))
	var max_health := current_health
	if health_mode == "preserve_max":
		max_health = snapshot_max_health
		current_health = minf(current_health, max_health)
	if max_health <= 0.0:
		return []

	var result: Array[Dictionary] = []
	for slot in range(summon_count):
		var ally_id := _next_ally_id
		_next_ally_id += 1
		var follow_offset := _formation_offset(slot, summon_count, resolved_config)
		var spawn_position := _resolve_position(origin + follow_offset, origin, ally_id, resolved_config)
		var ally: Dictionary = {
			"id": ally_id,
			"slot": slot,
			"position": spawn_position,
			"facing": Vector2.RIGHT,
			"attack": attack,
			"defense": defense,
			"health": current_health,
			"max_health": max_health,
			"remaining_time": maxf(0.0, float(resolved_config.get("duration", 20.0))),
			"target_enemy_id": -1,
			"target_position": Vector2.ZERO,
			"attack_state": AttackState.READY,
			"attack_state_remaining": 0.0,
			"attack_visual_remaining": 0.0,
			"cooldown": 0.0,
			"target_refresh_remaining": 0.0,
			"moving": false,
			"flash": 0.0,
			"follow_offset": follow_offset,
			# 每个队友保存自己的配置快照，保证后续召唤不同批次时互不覆盖。
			"config": resolved_config.duplicate(true),
		}
		_allies.append(ally)
		result.append(ally.duplicate(true))
		ally_spawned.emit(ally.duplicate(true))

	if not result.is_empty():
		targeting_changed.emit()
	return result


## 更新所有队友一帧。建议每帧调用一次，player_position 是玩家当前世界坐标。
func tick(delta: float, player_position: Vector2) -> void:
	if delta <= 0.0 or _allies.is_empty():
		return

	var removed_any := false
	for index in range(_allies.size() - 1, -1, -1):
		var ally: Dictionary = _allies[index]
		var config: Dictionary = ally.get("config", DEFAULT_CONFIG) as Dictionary
		var ally_id := int(ally.get("id", -1))
		ally["remaining_time"] = maxf(0.0, float(ally.get("remaining_time", 0.0)) - delta)
		ally["flash"] = maxf(0.0, float(ally.get("flash", 0.0)) - delta)
		ally["attack_visual_remaining"] = maxf(0.0, float(ally.get("attack_visual_remaining", 0.0)) - delta)
		ally["cooldown"] = maxf(0.0, float(ally.get("cooldown", 0.0)) - delta)
		ally["target_refresh_remaining"] = maxf(0.0, float(ally.get("target_refresh_remaining", 0.0)) - delta)

		if float(ally.get("remaining_time", 0.0)) <= 0.0:
			_allies.remove_at(index)
			ally_expired.emit(ally_id, _vector2(ally.get("position", Vector2.ZERO)))
			removed_any = true
			continue

		if not _has_valid_target(ally, config):
			_clear_target(ally)
			if float(ally.get("target_refresh_remaining", 0.0)) <= 0.0:
				_find_target(ally, config)
				ally["target_refresh_remaining"] = maxf(0.05, float(config.get("target_refresh_interval", 0.24)))

		var target_id := int(ally.get("target_enemy_id", -1))
		if target_id >= 0:
			var target_position := _vector2(ally.get("target_position", Vector2.ZERO))
			_tick_combat(ally, target_position, delta, config)
		else:
			_tick_follow(ally, player_position, delta, config)

		_tick_attack_state(ally, delta, config)
		_allies[index] = ally

	if removed_any:
		targeting_changed.emit()


## 队友受到伤害。实际伤害按队友召唤时锁定的防御力减伤。
func receive_damage(ally_id: int, amount: float) -> bool:
	if amount <= 0.0:
		return false
	for index in range(_allies.size() - 1, -1, -1):
		var ally: Dictionary = _allies[index]
		if int(ally.get("id", -1)) != ally_id:
			continue
		var actual_damage := COMBAT_MATH.mitigate_damage(amount, float(ally.get("defense", 0.0)))
		ally["health"] = maxf(0.0, float(ally.get("health", 0.0)) - actual_damage)
		ally["flash"] = 0.22
		ally_damaged.emit(ally_id, actual_damage, float(ally.get("health", 0.0)))
		if float(ally.get("health", 0.0)) <= 0.0:
			var at := _vector2(ally.get("position", Vector2.ZERO))
			_allies.remove_at(index)
			ally_died.emit(ally_id, at)
			targeting_changed.emit()
		else:
			_allies[index] = ally
		return true
	return false


## 清理全部队友。reason 为 died 时发出死亡信号，否则发出到时退场信号。
func clear(reason: String = "expired") -> void:
	if _allies.is_empty():
		return
	var snapshot := active_allies()
	_allies.clear()
	for ally in snapshot:
		var ally_id := int(ally.get("id", -1))
		var at := _vector2(ally.get("position", Vector2.ZERO))
		if reason == "died":
			ally_died.emit(ally_id, at)
		else:
			ally_expired.emit(ally_id, at)
	targeting_changed.emit()


func active_count() -> int:
	return _allies.size()


func has_ally(ally_id: int) -> bool:
	return _find_ally_index(ally_id) >= 0


## 返回深拷贝，避免外部直接修改系统内部状态。
func ally_state(ally_id: int) -> Dictionary:
	var index := _find_ally_index(ally_id)
	if index < 0:
		return {}
	return _allies[index].duplicate(true)


func active_allies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for ally in _allies:
		result.append(ally.duplicate(true))
	return result


func _tick_combat(ally: Dictionary, target_position: Vector2, delta: float, config: Dictionary) -> void:
	var position := _vector2(ally.get("position", Vector2.ZERO))
	var offset := target_position - position
	var distance := offset.length()
	if distance > 0.01:
		ally["facing"] = offset.normalized()
	var attack_range := maxf(1.0, float(config.get("attack_range", 58.0)))
	if distance > attack_range:
		var desired := target_position - offset.normalized() * attack_range * 0.72
		_move_toward(ally, desired, delta, config)
		return
	ally["moving"] = false
	if int(ally.get("attack_state", AttackState.READY)) != AttackState.READY:
		return
	if float(ally.get("cooldown", 0.0)) > 0.0:
		return
	ally["attack_state"] = AttackState.WINDUP
	ally["attack_state_remaining"] = maxf(0.0, float(config.get("attack_windup", 0.42)))


func _tick_follow(ally: Dictionary, player_position: Vector2, delta: float, config: Dictionary) -> void:
	var follow_offset := _vector2(ally.get("follow_offset", Vector2.ZERO))
	var desired := player_position + follow_offset
	var position := _vector2(ally.get("position", Vector2.ZERO))
	var follow_distance := maxf(0.0, float(config.get("follow_distance", 96.0)))
	if position.distance_to(desired) <= follow_distance:
		ally["moving"] = false
		return
	_move_toward(ally, desired, delta, config)


func _tick_attack_state(ally: Dictionary, delta: float, config: Dictionary) -> void:
	var state := int(ally.get("attack_state", AttackState.READY))
	if state == AttackState.READY:
		return
	var remaining := maxf(0.0, float(ally.get("attack_state_remaining", 0.0)) - delta)
	ally["attack_state_remaining"] = remaining
	if remaining > 0.0:
		return
	if state == AttackState.WINDUP:
		# 蓄力期间目标可能已经死亡或离开攻击距离，出手前必须再次确认。
		if _has_valid_target(ally, config) and _target_in_attack_range(ally, config):
			_perform_attack(ally, config)
		else:
			_clear_target(ally)
		ally["attack_state"] = AttackState.RECOVERY
		ally["attack_state_remaining"] = maxf(0.0, float(config.get("attack_recovery", 0.24)))
		return
	ally["attack_state"] = AttackState.READY
	ally["cooldown"] = maxf(0.0, float(config.get("attack_interval", 1.35)))


func _perform_attack(ally: Dictionary, config: Dictionary) -> void:
	var ally_id := int(ally.get("id", -1))
	var target_id := int(ally.get("target_enemy_id", -1))
	if target_id < 0:
		return
	var damage := maxf(0.0, float(ally.get("attack", 0.0))) * maxf(0.0, float(config.get("attack_multiplier", 1.0)))
	var at := _vector2(ally.get("position", Vector2.ZERO))
	ally["attack_visual_remaining"] = maxf(0.0, float(config.get("attack_visual_duration", 0.46)))
	ally_attacked.emit(ally_id, target_id, damage, at)
	if damage_target.is_valid():
		damage_target.call(ally_id, target_id, damage)


func _find_target(ally: Dictionary, config: Dictionary) -> void:
	if not target_provider.is_valid():
		return
	var ally_id := int(ally.get("id", -1))
	var position := _vector2(ally.get("position", Vector2.ZERO))
	var target_value = target_provider.call(position, float(config.get("search_radius", 520.0)), ally_id)
	if not target_value is Dictionary:
		return
	var target: Dictionary = target_value as Dictionary
	var target_id := int(target.get("id", -1))
	var target_position_value = target.get("position", Vector2.ZERO)
	if target_id < 0 or not target_position_value is Vector2:
		return
	var target_position: Vector2 = target_position_value
	if not target_position.is_finite():
		return
	if target_lookup.is_valid():
		var refreshed = target_lookup.call(target_id)
		if not refreshed is Dictionary:
			return
		var refreshed_target: Dictionary = refreshed as Dictionary
		if int(refreshed_target.get("id", -1)) != target_id:
			return
		var refreshed_position = refreshed_target.get("position", target_position)
		if refreshed_position is Vector2 and (refreshed_position as Vector2).is_finite():
			target_position = refreshed_position as Vector2
	ally["target_enemy_id"] = target_id
	ally["target_position"] = target_position
	targeting_changed.emit()


func _has_valid_target(ally: Dictionary, config: Dictionary) -> bool:
	var target_id := int(ally.get("target_enemy_id", -1))
	if target_id < 0:
		return false
	if target_lookup.is_valid():
		var refreshed = target_lookup.call(target_id)
		if not refreshed is Dictionary:
			return false
		var refreshed_target: Dictionary = refreshed as Dictionary
		if int(refreshed_target.get("id", -1)) != target_id:
			return false
		var refreshed_position = refreshed_target.get("position", Vector2.ZERO)
		if not refreshed_position is Vector2 or not (refreshed_position as Vector2).is_finite():
			return false
		ally["target_position"] = refreshed_position as Vector2
	var target_position := _vector2(ally.get("target_position", Vector2.ZERO))
	if not target_position.is_finite():
		return false
	var release_radius := maxf(float(config.get("target_release_radius", 700.0)), float(config.get("search_radius", 520.0)))
	var position := _vector2(ally.get("position", Vector2.ZERO))
	return position.distance_squared_to(target_position) <= release_radius * release_radius


func _target_in_attack_range(ally: Dictionary, config: Dictionary) -> bool:
	var position := _vector2(ally.get("position", Vector2.ZERO))
	var target_position := _vector2(ally.get("target_position", Vector2.ZERO))
	var attack_range := maxf(1.0, float(config.get("attack_range", 58.0)))
	return position.distance_squared_to(target_position) <= attack_range * attack_range


func _clear_target(ally: Dictionary) -> void:
	ally["target_enemy_id"] = -1
	ally["target_position"] = Vector2.ZERO
	if int(ally.get("attack_state", AttackState.READY)) == AttackState.WINDUP:
		ally["attack_state"] = AttackState.READY
		ally["attack_state_remaining"] = 0.0


func _move_toward(ally: Dictionary, desired: Vector2, delta: float, config: Dictionary) -> void:
	var position := _vector2(ally.get("position", Vector2.ZERO))
	var movement := desired - position
	if movement.length_squared() <= 0.01:
		ally["moving"] = false
		return
	var separation := _separation_force(ally, config)
	var velocity := movement.normalized() * maxf(0.0, float(config.get("move_speed", 118.0))) + separation
	var step := velocity * delta
	if step.length() > movement.length():
		step = movement
	var candidate := position + step
	ally["position"] = _resolve_position(candidate, position, int(ally.get("id", -1)), config)
	ally["moving"] = step.length_squared() > 0.01
	if step.length_squared() > 0.01:
		ally["facing"] = step.normalized()


func _separation_force(ally: Dictionary, config: Dictionary) -> Vector2:
	var force := Vector2.ZERO
	var origin := _vector2(ally.get("position", Vector2.ZERO))
	var radius := maxf(0.0, float(config.get("separation_radius", 42.0)))
	if radius <= 0.0:
		return force
	for other in _allies:
		if int(other.get("id", -1)) == int(ally.get("id", -1)):
			continue
		var offset := origin - _vector2(other.get("position", Vector2.ZERO))
		var distance := offset.length()
		if distance <= 0.01 or distance >= radius:
			continue
		force += offset.normalized() * (1.0 - distance / radius) * float(config.get("separation_strength", 72.0))
	return force


func _resolve_position(candidate: Vector2, fallback: Vector2, ally_id: int, config: Dictionary) -> Vector2:
	if position_resolver.is_valid():
		var resolved = position_resolver.call(fallback, candidate, ally_id)
		if resolved is Vector2 and (resolved as Vector2).is_finite():
			return resolved as Vector2
	var bounds_value = config.get("world_bounds", Rect2())
	if not bounds_value is Rect2:
		return candidate
	var bounds: Rect2 = bounds_value as Rect2
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return candidate
	return Vector2(
		clampf(candidate.x, bounds.position.x, bounds.end.x),
		clampf(candidate.y, bounds.position.y, bounds.end.y)
	)


func _formation_offset(slot: int, count: int, config: Dictionary) -> Vector2:
	var spacing := maxf(0.0, float(config.get("follow_spacing", 34.0)))
	if count <= 1:
		return Vector2.ZERO
	var row := slot / 3
	var column := slot % 3
	var row_width := mini(3, count - row * 3)
	var x := (float(column) - float(row_width - 1) * 0.5) * spacing
	var y := float(row) * spacing
	return Vector2(x, y)


func _vector2(value: Variant, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	if value is Vector2 and (value as Vector2).is_finite():
		return value as Vector2
	return fallback


func _find_ally_index(ally_id: int) -> int:
	for index in range(_allies.size()):
		if int(_allies[index].get("id", -1)) == ally_id:
			return index
	return -1