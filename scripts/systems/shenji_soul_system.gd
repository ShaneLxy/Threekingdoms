class_name ShenjiSoulSystem
extends RefCounted

const DURATION := 20.0
const RANGE := 200.0
const TURN_DEADZONE := deg_to_rad(5.0)
const TURN_SPEED := 12.0
const ARROW_SPEED := 720.0
const ARROW_LIFETIME := 1.2
const FIRE_INTERVALS := [1.0, 0.6, 0.3, 0.3]

var active := false
var rank := 0
var remaining := 0.0
var fire_remaining := 0.0
var damage_snapshot := 0.0
var facing := Vector2.RIGHT
var target_id := -1
var target_kind := ""
var arrows: Array[Dictionary] = []
var query_targets: Callable
var damage_target: Callable
var visual_event: Callable

func configure(target_query: Callable, damage_callback: Callable, visual_callback: Callable) -> void:
	query_targets = target_query
	damage_target = damage_callback
	visual_event = visual_callback

func reset() -> void:
	clear()

func activate(next_rank: int, snapshot_attack: float, duration: float = DURATION) -> void:
	rank = clampi(next_rank, 0, 3)
	remaining = maxf(0.0, duration)
	damage_snapshot = maxf(0.0, snapshot_attack * 0.5)
	fire_remaining = 0.0
	active = true
	arrows.clear()
	target_id = -1
	target_kind = ""

func clear() -> void:
	active = false
	remaining = 0.0
	fire_remaining = 0.0
	target_id = -1
	target_kind = ""
	arrows.clear()

func tick(delta: float, hero_position: Vector2, paused: bool = false, dead: bool = false) -> void:
	if paused or dead:
		return
	_tick_arrows(delta)
	if not active:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.0:
		clear()
		return
	var candidates := _valid_targets(hero_position)
	var selected := _nearest_target(candidates, hero_position)
	if selected.is_empty():
		target_id = -1
		target_kind = ""
		fire_remaining = 0.0
		return
	target_id = int(selected.get("id", -1))
	target_kind = str(selected.get("kind", ""))
	var bow_position := hero_position + Vector2(-24.0, -52.0)
	var desired: Vector2 = (selected.get("position", hero_position) as Vector2) - bow_position
	if desired.length_squared() > 0.01:
		var desired_angle := desired.angle()
		var angle_delta := angle_difference(facing.angle(), desired_angle)
		if absf(angle_delta) > TURN_DEADZONE:
			facing = Vector2.from_angle(facing.angle() + clampf(angle_delta, -TURN_SPEED * delta, TURN_SPEED * delta))
		if visual_event.is_valid():
			visual_event.call("aim", bow_position, facing)
		if absf(angle_delta) <= TURN_DEADZONE and fire_remaining <= 0.0:
			_fire(hero_position, selected)
			fire_remaining = FIRE_INTERVALS[rank]
	fire_remaining = maxf(0.0, fire_remaining - delta)

func _valid_targets(hero_position: Vector2) -> Array[Dictionary]:
	var valid: Array[Dictionary] = []
	if not query_targets.is_valid():
		return valid
	for item_variant in query_targets.call(hero_position, RANGE):
		var item: Dictionary = item_variant as Dictionary
		if item.is_empty() or bool(item.get("dead", false)) or bool(item.get("invulnerable", false)):
			continue
		var position: Vector2 = item.get("position", hero_position)
		if position.distance_squared_to(hero_position) <= RANGE * RANGE:
			valid.append(item)
	return valid

func _nearest_target(candidates: Array[Dictionary], hero_position: Vector2) -> Dictionary:
	var nearest := {}
	var nearest_distance := INF
	for candidate in candidates:
		var distance := hero_position.distance_squared_to(candidate.get("position", hero_position))
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest

func _fire(hero_position: Vector2, target: Dictionary) -> void:
	var direction := facing.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	var origin := hero_position + Vector2(-24.0, -52.0)
	var arrow := {
		"origin": origin,
		"position": origin,
		"direction": direction,
		"target_id": int(target.get("id", -1)),
		"target_kind": str(target.get("kind", "")),
		"remaining": ARROW_LIFETIME,
		"distance": 0.0,
	}
	arrows.append(arrow)
	if visual_event.is_valid():
		visual_event.call("fire", origin, direction)

func _tick_arrows(delta: float) -> void:
	for index in range(arrows.size() - 1, -1, -1):
		var arrow: Dictionary = arrows[index]
		var old_position: Vector2 = arrow.get("position", Vector2.ZERO)
		var direction: Vector2 = arrow.get("direction", Vector2.RIGHT)
		var travel := ARROW_SPEED * delta
		var new_position := old_position + direction * travel
		arrow["position"] = new_position
		arrow["distance"] = float(arrow.get("distance", 0.0)) + travel
		arrow["remaining"] = float(arrow.get("remaining", 0.0)) - delta
		var hit := _collision_target(arrow, old_position, new_position)
		if not hit.is_empty():
			_resolve_hit(hit)
			if visual_event.is_valid():
				visual_event.call("impact", new_position, direction)
			arrows.remove_at(index)
		elif float(arrow.get("remaining", 0.0)) <= 0.0:
			arrows.remove_at(index)
		else:
			arrows[index] = arrow

func _collision_target(arrow: Dictionary, from: Vector2, to: Vector2) -> Dictionary:
	if not query_targets.is_valid():
		return {}
	var arrow_id := int(arrow.get("target_id", -1))
	var arrow_kind := str(arrow.get("target_kind", ""))
	for item_variant in query_targets.call(from, RANGE + 400.0):
		var item: Dictionary = item_variant as Dictionary
		if int(item.get("id", -2)) != arrow_id or str(item.get("kind", "")) != arrow_kind:
			continue
		if bool(item.get("dead", false)) or bool(item.get("invulnerable", false)):
			return {}
		var position: Vector2 = item.get("position", to)
		if _distance_to_segment(position, from, to) <= 18.0:
			return item
	return {}

func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.01:
		return point.distance_to(start)
	var progress := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * progress)

func _resolve_hit(target: Dictionary) -> void:
	if not damage_target.is_valid():
		return
	damage_target.call(target, damage_snapshot, rank >= 3)
