class_name BattlefieldLayout
extends RefCounted

const EDITOR_SIZE := Vector2(1000.0, 568.0)
const EDITOR_ORDER: Array[String] = ["xinye", "bowangpo", "huoshaoxinye", "xiangyangchetui", "dangyangduanhou", "changban", "hulao"]
const EMBEDDED_MAP_DIRECTORY := "res://data/maps"
# The trial background is rendered at its source size (1672x941). This
# rectangle follows the
# stone border of the central arena in the source artwork and is the only
# area where combat actors are allowed to move.
const BOSS_TRIAL_ARENA_BOUNDS := Rect2(275.0, 211.0, 1123.0, 577.0)

const COMMON_ASSETS: Array[Dictionary] = []

const BATTLEFIELDS := {
	"xinye": {
		"title": "新野练兵",
		"ground_fill": "29321a",
		"ground_path": "res://assets/art/environment/xinye1/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/xinye1/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/xinye1.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"bowangpo": {
		"title": "博望坡火谷",
		"ground_fill": "160f0c",
		"ground_path": "res://assets/art/environment/bowangpo1/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/bowangpo1/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/bowangpo.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"huoshaoxinye": {
		"title": "火烧新野",
		"ground_fill": "21140f",
		"ground_path": "res://assets/art/environment/huoshaoxinye1/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/huoshaoxinye1/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/huoshaoxinye.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"xiangyangchetui": {
		"title": "襄阳撤退",
		"ground_fill": "2b2b22",
		"ground_path": "res://assets/art/environment/xiangyangchetui1/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/xiangyangchetui1/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/xiangyangchetui.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"dangyangduanhou": {
		"title": "当阳断后",
		"ground_fill": "3a2918",
		"ground_path": "res://assets/art/environment/dangyangduanhou/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/dangyangduanhou/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/dangyangduanhou.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"changban": {
		"title": "长坂坡雪夜",
		"ground_fill": "111927",
		"ground_path": "res://assets/art/environment/changbanpo/ground-canvas.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/changbanpo/ground-canvas.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/changban_snow.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
	"hulao": {
		"title": "虎牢关外·斗将台",
		"ground_fill": "3a281b",
		"ground_path": "res://assets/art/environment/shilian/arena.png",
		"ground_layers": [
			{"role": "canvas", "path": "res://assets/art/environment/shilian/arena.png", "opacity": 1.0},
		],
		"baked_scene": true,
		"save_path": "user://map_editor/hulao.json",
		"assets": [],
		"defaults": [],
		"collision_zones": [],
	},
}

static func canonical_id(battlefield_id: String) -> String:
	if battlefield_id == "bowangpo_story":
		return "bowangpo"
	return battlefield_id if BATTLEFIELDS.has(battlefield_id) else "changban"

static func editable_ids() -> Array[String]:
	return EDITOR_ORDER.duplicate()

static func definition_for(battlefield_id: String) -> Dictionary:
	return BATTLEFIELDS.get(canonical_id(battlefield_id), BATTLEFIELDS["changban"]) as Dictionary

static func title_for(battlefield_id: String) -> String:
	return str(definition_for(battlefield_id).get("title", "战场"))

static func ground_path_for(battlefield_id: String) -> String:
	return str(definition_for(battlefield_id).get("ground_path", ""))

static func has_baked_scene_for(battlefield_id: String) -> bool:
	return bool(definition_for(battlefield_id).get("baked_scene", false))

static func ground_fill_color_for(battlefield_id: String) -> Color:
	return Color(str(definition_for(battlefield_id).get("ground_fill", "13130e")))

static func ground_layers_for(battlefield_id: String) -> Array[Dictionary]:
	var layers: Array[Dictionary] = []
	var source_layers: Array = definition_for(battlefield_id).get("ground_layers", []) as Array
	for raw_layer in source_layers:
		if raw_layer is Dictionary:
			layers.append((raw_layer as Dictionary).duplicate(true))
	if not layers.is_empty():
		return layers
	var fallback_path := ground_path_for(battlefield_id)
	if not fallback_path.is_empty():
		layers.append({"role": "base", "path": fallback_path, "opacity": 1.0})
	return layers

static func ground_summary_for(battlefield_id: String) -> String:
	var layers := ground_layers_for(battlefield_id)
	for layer in layers:
		if str(layer.get("role", "")) == "canvas":
			return "固定基础地表画布"
	var layer_count := layers.size()
	return "自动组合（底层 + %d 层副地皮）" % maxi(0, layer_count - 1)

static func save_path_for(battlefield_id: String) -> String:
	return str(definition_for(battlefield_id).get("save_path", "user://map_editor/changban.json"))

static func embedded_map_path_for(battlefield_id: String) -> String:
	return "%s/%s.json" % [EMBEDDED_MAP_DIRECTORY, canonical_id(battlefield_id)]

static func can_publish_default_maps() -> bool:
	return OS.has_feature("editor") or OS.is_debug_build()

static func asset_definitions_for(battlefield_id: String, include_common: bool = true) -> Array[Dictionary]:
	var source: Array = COMMON_ASSETS if include_common else definition_for(battlefield_id).get("assets", []) as Array
	var assets: Array[Dictionary] = []
	for raw_asset in source:
		if raw_asset is Dictionary:
			assets.append((raw_asset as Dictionary).duplicate(true))
	return assets

static func editor_asset_definitions_for(battlefield_id: String, include_common: bool = true) -> Array[Dictionary]:
	var assets: Array[Dictionary] = []
	for asset in asset_definitions_for(battlefield_id, include_common):
		if bool(asset.get("editor_visible", true)):
			assets.append(asset)
	return assets

static func other_battlefield_asset_definitions_for(battlefield_id: String) -> Array[Dictionary]:
	var current_id := canonical_id(battlefield_id)
	var assets: Array[Dictionary] = []
	for source_id in EDITOR_ORDER:
		if source_id == current_id:
			continue
		for raw_asset in editor_asset_definitions_for(source_id, false):
			var asset := raw_asset.duplicate(true)
			var source_asset_id := str(asset.get("id", ""))
			asset["id"] = "%s__%s" % [source_id, source_asset_id]
			asset["source_battlefield_id"] = source_id
			asset["source_asset_id"] = source_asset_id
			asset["label"] = "%s·%s" % [title_for(source_id), str(asset.get("label", "素材"))]
			assets.append(asset)
	return assets

static func asset_definition_for(battlefield_id: String, asset_id: String) -> Dictionary:
	for asset in asset_definitions_for(battlefield_id, false):
		if str(asset.get("id", "")) == asset_id:
			return asset
	for asset in asset_definitions_for(battlefield_id, true):
		if str(asset.get("id", "")) == asset_id:
			return asset
	for asset in other_battlefield_asset_definitions_for(battlefield_id):
		if str(asset.get("id", "")) == asset_id:
			return asset
	return {}

static func is_editor_editable_asset(battlefield_id: String, asset_id: String) -> bool:
	return bool(asset_definition_for(battlefield_id, asset_id).get("editor_visible", true))

static func _code_default_objects_for(battlefield_id: String) -> Array[Dictionary]:
	var defaults: Array = definition_for(battlefield_id).get("defaults", []) as Array
	var objects: Array[Dictionary] = []
	for raw_object in defaults:
		if raw_object is Dictionary:
			objects.append((raw_object as Dictionary).duplicate(true))
	return objects

static func _code_default_collision_zones_for(battlefield_id: String) -> Array[Rect2]:
	var raw_zones = definition_for(battlefield_id).get("collision_zones", [])
	var zones: Array[Rect2] = []
	if not raw_zones is Array:
		return zones
	for raw_zone in raw_zones:
		if not raw_zone is Dictionary:
			continue
		var zone: Dictionary = raw_zone
		var rect := Rect2(
			float(zone.get("x", 0.0)),
			float(zone.get("y", 0.0)),
			float(zone.get("w", 0.0)),
			float(zone.get("h", 0.0))
		)
		if rect.size.x > 1.0 and rect.size.y > 1.0:
			zones.append(_clamp_editor_rect(rect))
	return zones

static func default_objects_for(battlefield_id: String) -> Array[Dictionary]:
	var embedded_layout := _read_layout_file(embedded_map_path_for(battlefield_id))
	if embedded_layout.has("objects") and embedded_layout.get("objects") is Array:
		return _objects_from_layout_data(battlefield_id, embedded_layout)
	return _code_default_objects_for(battlefield_id)

static func default_collision_zones_for(battlefield_id: String) -> Array[Rect2]:
	var embedded_layout := _read_layout_file(embedded_map_path_for(battlefield_id))
	if embedded_layout.has("collision_zones") and embedded_layout.get("collision_zones") is Array:
		return _collision_zones_from_layout_data(embedded_layout)
	return _code_default_collision_zones_for(battlefield_id)

static func _objects_from_layout_data(battlefield_id: String, layout: Dictionary) -> Array[Dictionary]:
	var loaded: Array[Dictionary] = []
	for raw_item in layout.get("objects", []):
		if not raw_item is Dictionary:
			continue
		var item: Dictionary = raw_item
		var asset_id := str(item.get("id", ""))
		if asset_definition_for(battlefield_id, asset_id).is_empty():
			continue
		var position_data: Dictionary = item.get("position", {}) as Dictionary
		loaded.append({
			"id": asset_id,
			"position": Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0))),
			"scale": clampf(float(item.get("scale", 1.0)), 0.35, 2.2),
			"obstacle": bool(item.get("obstacle", false)),
		})
	return loaded

static func _collision_zones_from_layout_data(layout: Dictionary) -> Array[Rect2]:
	var zones: Array[Rect2] = []
	for raw_zone in layout.get("collision_zones", []):
		if not raw_zone is Dictionary:
			continue
		var zone: Dictionary = raw_zone
		var rect := Rect2(
			float(zone.get("x", 0.0)),
			float(zone.get("y", 0.0)),
			float(zone.get("w", 0.0)),
			float(zone.get("h", 0.0))
		)
		if rect.size.x > 1.0 and rect.size.y > 1.0:
			zones.append(_clamp_editor_rect(rect))
	return zones

static func objects_for(battlefield_id: String) -> Array[Dictionary]:
	var local_layout := _read_layout_file(save_path_for(battlefield_id))
	if local_layout.has("objects") and local_layout.get("objects") is Array:
		return _objects_from_layout_data(battlefield_id, local_layout)
	return default_objects_for(battlefield_id)

static func collision_zones_for(battlefield_id: String) -> Array[Rect2]:
	var local_layout := _read_layout_file(save_path_for(battlefield_id))
	if local_layout.has("collision_zones") and local_layout.get("collision_zones") is Array:
		return _collision_zones_from_layout_data(local_layout)
	# Existing object-only layouts receive the independent map defaults once.
	# A saved empty array remains empty and never repopulates itself.
	return default_collision_zones_for(battlefield_id)

static func save_map_for(battlefield_id: String, objects: Array[Dictionary], collision_zones: Array[Rect2]) -> bool:
	return _write_layout_file(save_path_for(battlefield_id), battlefield_id, objects, collision_zones)

static func publish_default_map_for(battlefield_id: String, objects: Array[Dictionary], collision_zones: Array[Rect2]) -> bool:
	if not can_publish_default_maps():
		return false
	return _write_layout_file(embedded_map_path_for(battlefield_id), battlefield_id, objects, collision_zones)

static func _read_layout_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	return (parsed as Dictionary).duplicate(true)

static func _write_layout_file(path: String, battlefield_id: String, objects: Array[Dictionary], collision_zones: Array[Rect2]) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var serializable: Array[Dictionary] = []
	for object in objects:
		var position: Vector2 = object.get("position", Vector2.ZERO) as Vector2
		serializable.append({
			"id": str(object.get("id", "")),
			"position": {"x": position.x, "y": position.y},
			"scale": float(object.get("scale", 1.0)),
			"obstacle": bool(object.get("obstacle", false)),
		})
	var serializable_zones: Array[Dictionary] = []
	for raw_zone in collision_zones:
		var zone := _clamp_editor_rect(raw_zone as Rect2)
		if zone.size.x <= 1.0 or zone.size.y <= 1.0:
			continue
		serializable_zones.append({
			"x": zone.position.x,
			"y": zone.position.y,
			"w": zone.size.x,
			"h": zone.size.y,
		})
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"map_id": canonical_id(battlefield_id),
		"objects": serializable,
		"collision_zones": serializable_zones,
	}, "  "))
	return true

static func obstacle_rects_for(battlefield_id: String, world_bounds: Rect2) -> Array[Rect2]:
	var obstacles: Array[Rect2] = []
	var world_scale := Vector2(world_bounds.size.x / EDITOR_SIZE.x, world_bounds.size.y / EDITOR_SIZE.y)
	for zone in collision_zones_for(battlefield_id):
		obstacles.append(Rect2(
			world_bounds.position + Vector2(zone.position.x * world_scale.x, zone.position.y * world_scale.y),
			Vector2(zone.size.x * world_scale.x, zone.size.y * world_scale.y)
		))
	return obstacles

static func _clamp_editor_rect(rect: Rect2) -> Rect2:
	var normalized := rect.abs()
	var position := Vector2(
		clampf(normalized.position.x, 0.0, EDITOR_SIZE.x),
		clampf(normalized.position.y, 0.0, EDITOR_SIZE.y)
	)
	var end := Vector2(
		clampf(normalized.end.x, 0.0, EDITOR_SIZE.x),
		clampf(normalized.end.y, 0.0, EDITOR_SIZE.y)
	)
	return Rect2(position, end - position)

# Returns the first visible corner on a shortest route around the rectangular zones.
# The caller can ask again after reaching that corner to advance through a second corner.
static func navigation_waypoint_for(start: Vector2, target: Vector2, obstacles: Array[Rect2], radius: float, preferred_side: int = 0) -> Vector2:
	if obstacles.is_empty() or start.distance_squared_to(target) <= 4.0:
		return Vector2.ZERO
	var expanded: Array[Rect2] = []
	for obstacle in obstacles:
		var padded := obstacle.grow(radius + 8.0)
		expanded.append(padded)
	var route_start := _depenetrate_position(start, expanded, 0.5)
	if _navigation_segment_clear(route_start, target, expanded):
		return Vector2.ZERO
	var corners: Array[Vector2] = []
	for obstacle in expanded:
		var margin := 3.0
		corners.append(obstacle.position + Vector2(-margin, -margin))
		corners.append(Vector2(obstacle.end.x + margin, obstacle.position.y - margin))
		corners.append(obstacle.end + Vector2(margin, margin))
		corners.append(Vector2(obstacle.position.x - margin, obstacle.end.y + margin))
	var best_route: Array[Vector2] = []
	var best_cost := INF
	for corner_index in range(corners.size()):
		var corner := corners[corner_index]
		if not _navigation_point_valid(corner, expanded):
			continue
		if not _navigation_segment_clear(route_start, corner, expanded):
			continue
		if _navigation_segment_clear(corner, target, expanded):
			var cost := route_start.distance_to(corner) + corner.distance_to(target)
			cost += _navigation_side_bias(corner, route_start, target, preferred_side)
			if cost < best_cost:
				best_cost = cost
				best_route = [corner]
	for first_index in range(corners.size()):
		var first := corners[first_index]
		if not _navigation_point_valid(first, expanded) or not _navigation_segment_clear(route_start, first, expanded):
			continue
		for second_index in range(corners.size()):
			if first_index == second_index:
				continue
			var second := corners[second_index]
			if not _navigation_point_valid(second, expanded):
				continue
			if not _navigation_segment_clear(first, second, expanded) or not _navigation_segment_clear(second, target, expanded):
				continue
			var two_corner_cost := route_start.distance_to(first) + first.distance_to(second) + second.distance_to(target)
			two_corner_cost += _navigation_side_bias(first, route_start, target, preferred_side)
			if two_corner_cost < best_cost:
				best_cost = two_corner_cost
				best_route = [first, second]
	if not best_route.is_empty():
		return best_route[0]
	# Keep a deterministic tangent fallback for a fully enclosed or over-constrained layout.
	var nearest_corner := Vector2.ZERO
	var nearest_distance := INF
	for corner in corners:
		if not _navigation_point_valid(corner, expanded):
			continue
		var distance := route_start.distance_squared_to(corner)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_corner = corner
	return nearest_corner

static func _navigation_segment_clear(start: Vector2, target: Vector2, obstacles: Array[Rect2]) -> bool:
	if start.distance_squared_to(target) <= 0.01:
		return true
	for obstacle in obstacles:
		if obstacle.has_point(start):
			return false
		if not _sweep_point_against_rect(start, target - start, obstacle).is_empty():
			return false
	return true

static func _navigation_point_valid(point: Vector2, obstacles: Array[Rect2]) -> bool:
	for obstacle in obstacles:
		if obstacle.has_point(point):
			return false
	return true

static func _navigation_side_bias(point: Vector2, start: Vector2, target: Vector2, preferred_side: int) -> float:
	if preferred_side == 0:
		return 0.0
	var travel := target - start
	var lateral := Vector2(-travel.y, travel.x)
	if lateral.length_squared() <= 0.01:
		return 0.0
	var side := signf(lateral.dot(point - start))
	return 0.25 if side == float(preferred_side) else 1.5

static func move_with_obstacles(start: Vector2, destination: Vector2, obstacles: Array[Rect2], radius: float) -> Vector2:
	if obstacles.is_empty():
		return destination
	var current := _depenetrate_position(start, obstacles, radius)
	var remaining := destination - start
	for _iteration in range(3):
		if remaining.length_squared() <= 0.0001:
			break
		var hit := _first_sweep_hit(current, remaining, obstacles, radius)
		if hit.is_empty():
			current += remaining
			break
		var hit_time := clampf(float(hit.get("time", 0.0)), 0.0, 1.0)
		var hit_normal: Vector2 = hit.get("normal", Vector2.ZERO) as Vector2
		current += remaining * maxf(0.0, hit_time - 0.001)
		if hit_normal.length_squared() <= 0.01:
			break
		current += hit_normal * 0.08
		remaining = (remaining * (1.0 - hit_time)).slide(hit_normal)
	return _depenetrate_position(current, obstacles, radius)

static func _first_sweep_hit(start: Vector2, delta: Vector2, obstacles: Array[Rect2], radius: float) -> Dictionary:
	var earliest_time := INF
	var earliest_hit: Dictionary = {}
	for obstacle in obstacles:
		var hit := _sweep_point_against_rect(start, delta, obstacle.grow(radius))
		if hit.is_empty():
			continue
		var hit_time := float(hit.get("time", INF))
		if hit_time < earliest_time:
			earliest_time = hit_time
			earliest_hit = hit
	return earliest_hit

static func _sweep_point_against_rect(start: Vector2, delta: Vector2, rect: Rect2) -> Dictionary:
	if rect.has_point(start):
		return {}
	var enter_time := 0.0
	var exit_time := 1.0
	var enter_normal := Vector2.ZERO
	for axis in range(2):
		var origin := start.x if axis == 0 else start.y
		var distance := delta.x if axis == 0 else delta.y
		var minimum := rect.position.x if axis == 0 else rect.position.y
		var maximum := rect.end.x if axis == 0 else rect.end.y
		if absf(distance) <= 0.00001:
			if origin < minimum or origin > maximum:
				return {}
			continue
		var entry := (minimum - origin) / distance
		var exit := (maximum - origin) / distance
		var normal := Vector2(-signf(distance), 0.0) if axis == 0 else Vector2(0.0, -signf(distance))
		if entry > exit:
			var temporary := entry
			entry = exit
			exit = temporary
			normal = -normal
		if entry > enter_time:
			enter_time = entry
			enter_normal = normal
		exit_time = minf(exit_time, exit)
		if enter_time > exit_time:
			return {}
	if enter_time < 0.0 or enter_time > 1.0:
		return {}
	return {"time": enter_time, "normal": enter_normal}

static func _depenetrate_position(candidate: Vector2, obstacles: Array[Rect2], radius: float) -> Vector2:
	var resolved := candidate
	for _iteration in range(3):
		var adjusted := false
		for obstacle in obstacles:
			var padded := obstacle.grow(radius)
			if not padded.has_point(resolved):
				continue
			var left_distance := absf(resolved.x - padded.position.x)
			var right_distance := absf(padded.end.x - resolved.x)
			var top_distance := absf(resolved.y - padded.position.y)
			var bottom_distance := absf(padded.end.y - resolved.y)
			var nearest := minf(minf(left_distance, right_distance), minf(top_distance, bottom_distance))
			if is_equal_approx(nearest, left_distance):
				resolved.x = padded.position.x - 0.08
			elif is_equal_approx(nearest, right_distance):
				resolved.x = padded.end.x + 0.08
			elif is_equal_approx(nearest, top_distance):
				resolved.y = padded.position.y - 0.08
			else:
				resolved.y = padded.end.y + 0.08
			adjusted = true
			break
		if not adjusted:
			break
	return resolved
