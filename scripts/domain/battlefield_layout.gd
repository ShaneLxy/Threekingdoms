class_name BattlefieldLayout
extends RefCounted

const EDITOR_SIZE := Vector2(1000.0, 568.0)
const EDITOR_ORDER: Array[String] = ["xinye", "bowangpo", "changban", "hulao"]
const EMBEDDED_MAP_DIRECTORY := "res://data/maps"

const COMMON_ASSETS: Array[Dictionary] = [
	{"id": "common_fence", "label": "旧军营木栅栏", "path": "res://assets/art/environment/common1/1.png", "default_scale": 1.0},
	{"id": "common_slope", "label": "土坡地形", "path": "res://assets/art/environment/common1/3.png", "default_scale": 1.0},
	{"id": "common_track_01", "label": "战场痕迹 01", "path": "res://assets/art/environment/common1/4.png", "default_scale": 0.9},
	{"id": "common_track_02", "label": "战场痕迹 02", "path": "res://assets/art/environment/common1/5.png", "default_scale": 0.9},
	{"id": "common_track_03", "label": "战场痕迹 03", "path": "res://assets/art/environment/common1/7.png", "default_scale": 0.9},
	{"id": "common_track_04", "label": "战场痕迹 04", "path": "res://assets/art/environment/common1/8.png", "default_scale": 0.9},
	{"id": "common_track_05", "label": "战场痕迹 05", "path": "res://assets/art/environment/common1/9.png", "default_scale": 0.9},
	{"id": "common_track_06", "label": "战场痕迹 06", "path": "res://assets/art/environment/common1/10.png", "default_scale": 0.9},
	{"id": "common_track_07", "label": "战场痕迹 07", "path": "res://assets/art/environment/common1/11.png", "default_scale": 0.9},
	{"id": "common_track_08", "label": "战场痕迹 08", "path": "res://assets/art/environment/common1/12.png", "default_scale": 0.9},
	{"id": "common_track_09", "label": "战场痕迹 09", "path": "res://assets/art/environment/common1/13.png", "default_scale": 0.9},
	{"id": "common_track_10", "label": "战场痕迹 10", "path": "res://assets/art/environment/common1/14.png", "default_scale": 0.9},
	{"id": "common_track_11", "label": "战场痕迹 11", "path": "res://assets/art/environment/common1/15.png", "default_scale": 0.9},
	{"id": "common_track_12", "label": "战场痕迹 12", "path": "res://assets/art/environment/common1/16.png", "default_scale": 0.9},
	{"id": "common_flag_01", "label": "蜀军战旗 A", "path": "res://assets/art/environment/common1/flag1.png", "default_scale": 0.8},
	{"id": "common_flag_02", "label": "蜀军战旗 B", "path": "res://assets/art/environment/common1/flag2.png", "default_scale": 0.8},
	{"id": "common_flag_03", "label": "蜀军战旗 C", "path": "res://assets/art/environment/common1/flag3.png", "default_scale": 0.8},
]

# Legacy footprint metadata kept for old serialized object data and compatibility helpers.
# Runtime movement uses collision_zones only; visual sprites never create blockers.
const COLLISION_PRESETS := {
	"common_fence": Rect2(0.10, 0.58, 0.80, 0.20),
	"common_slope": Rect2(0.06, 0.46, 0.88, 0.30),
	"common_track_01": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_02": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_03": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_04": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_05": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_06": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_07": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_08": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_09": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_10": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_11": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_track_12": Rect2(0.18, 0.58, 0.64, 0.22),
	"common_flag_01": Rect2(0.38, 0.62, 0.24, 0.18),
	"common_flag_02": Rect2(0.38, 0.62, 0.24, 0.18),
	"common_flag_03": Rect2(0.38, 0.62, 0.24, 0.18),
	"platform": Rect2(0.16, 0.58, 0.68, 0.24),
	"targets": Rect2(0.20, 0.60, 0.60, 0.20),
	"tent": Rect2(0.18, 0.62, 0.64, 0.18),
	"fence": Rect2(0.10, 0.58, 0.80, 0.20),
	"flags": Rect2(0.38, 0.62, 0.24, 0.18),
	"spears": Rect2(0.12, 0.60, 0.76, 0.20),
	"rock_platform": Rect2(0.10, 0.56, 0.80, 0.26),
	"burnt_log": Rect2(0.14, 0.60, 0.72, 0.20),
	"dead_log": Rect2(0.12, 0.60, 0.76, 0.18),
	"dead_tree": Rect2(0.22, 0.52, 0.56, 0.26),
	"fire_path": Rect2(0.08, 0.46, 0.84, 0.32),
	"dirt_patch": Rect2(0.12, 0.58, 0.76, 0.22),
	"grass_dirt_patch": Rect2(0.12, 0.58, 0.76, 0.22),
	"trampled_patch_01": Rect2(0.14, 0.60, 0.72, 0.20),
	"trampled_patch_02": Rect2(0.14, 0.60, 0.72, 0.20),
	"trampled_patch": Rect2(0.14, 0.60, 0.72, 0.20),
	"slope": Rect2(0.06, 0.46, 0.88, 0.30),
}

const BATTLEFIELDS := {
	"xinye": {
		"title": "新野练兵",
		"ground_fill": "29321a",
		"ground_path": "res://assets/art/environment/xinye1/1.png",
		"ground_layers": [
			{"role": "base", "path": "res://assets/art/environment/xinye1/1.png", "opacity": 0.97},
			{"role": "blend", "path": "res://assets/art/environment/changban/grass-dirt-base-01.png", "opacity": 0.12, "tint": "d8c78d"},
			{"role": "patch", "path": "res://assets/art/environment/changban/dirt-base-01.png", "opacity": 0.17, "tint": "d4b878", "regions": [Rect2(0.12, 0.17, 0.46, 0.32), Rect2(0.47, 0.48, 0.42, 0.30)]},
		],
		"save_path": "user://map_editor/xinye1.json",
		"assets": [
			{"id": "platform", "label": "练兵台", "path": "res://assets/art/environment/xinye1/2.png", "default_scale": 1.0},
			{"id": "targets", "label": "靶场组", "path": "res://assets/art/environment/xinye1/3.png", "default_scale": 1.0},
			{"id": "tent", "label": "军帐", "path": "res://assets/art/environment/xinye1/4.png", "default_scale": 1.0},
			{"id": "fence", "label": "木栅栏", "path": "res://assets/art/environment/xinye1/5_1.png", "default_scale": 1.0},
			{"id": "flags", "label": "战旗组", "path": "res://assets/art/environment/xinye1/5_2.png", "default_scale": 1.0},
			{"id": "spears", "label": "拒马枪阵", "path": "res://assets/art/environment/xinye1/5_3.png", "default_scale": 1.0},
		],
		"defaults": [
			{"id": "platform", "position": Vector2(828.0, 420.0), "scale": 0.85, "obstacle": true},
			{"id": "tent", "position": Vector2(232.0, 178.0), "scale": 0.72, "obstacle": true},
			{"id": "targets", "position": Vector2(478.0, 166.0), "scale": 0.68, "obstacle": false},
			{"id": "fence", "position": Vector2(380.0, 424.0), "scale": 0.90, "obstacle": true},
			{"id": "flags", "position": Vector2(744.0, 196.0), "scale": 0.72, "obstacle": false},
			{"id": "spears", "position": Vector2(622.0, 410.0), "scale": 0.82, "obstacle": true},
		],
		"collision_zones": [
			{"x": 756.0, "y": 368.0, "w": 144.0, "h": 82.0},
			{"x": 164.0, "y": 128.0, "w": 138.0, "h": 92.0},
			{"x": 292.0, "y": 394.0, "w": 176.0, "h": 58.0},
			{"x": 554.0, "y": 366.0, "w": 142.0, "h": 76.0},
		],
	},
	"bowangpo": {
		"title": "博望坡火谷",
		"ground_fill": "160f0c",
		"ground_path": "res://assets/art/environment/bowangpo1/1.png",
		"ground_layers": [
			{"role": "base", "path": "res://assets/art/environment/bowangpo1/1.png", "opacity": 0.96, "tint": "e6dbc7"},
			{"role": "blend", "path": "res://assets/art/environment/changban/dirt-base-01.png", "opacity": 0.07, "tint": "5a4430"},
			{"role": "patch", "path": "res://assets/art/environment/changban/grass-dirt-base-01.png", "opacity": 0.05, "tint": "493d2b", "regions": [Rect2(0.08, 0.18, 0.38, 0.26), Rect2(0.57, 0.54, 0.34, 0.25)]},
		],
		"save_path": "user://map_editor/bowangpo.json",
		"assets": [
			{"id": "rock_platform", "label": "山岩台地", "path": "res://assets/art/environment/bowangpo1/2.png", "default_scale": 1.0},
			{"id": "burnt_log", "label": "焦木堆", "path": "res://assets/art/environment/bowangpo1/3_1.png", "default_scale": 0.9},
			{"id": "dead_log", "label": "枯木横障", "path": "res://assets/art/environment/bowangpo1/3_2.png", "default_scale": 0.9},
			{"id": "dead_tree", "label": "焦枯树", "path": "res://assets/art/environment/bowangpo1/3_3.png", "default_scale": 0.9},
			{"id": "fire_path", "label": "火痕地带", "path": "res://assets/art/environment/bowangpo1/4.png", "default_scale": 1.0, "editor_visible": false},
		],
		"defaults": [
			{"id": "rock_platform", "position": Vector2(178.0, 124.0), "scale": 0.92, "obstacle": true},
			{"id": "rock_platform", "position": Vector2(830.0, 458.0), "scale": 0.86, "obstacle": true},
			{"id": "fire_path", "position": Vector2(504.0, 280.0), "scale": 1.14, "obstacle": false},
			{"id": "dead_tree", "position": Vector2(160.0, 372.0), "scale": 0.78, "obstacle": true},
			{"id": "burnt_log", "position": Vector2(814.0, 236.0), "scale": 0.76, "obstacle": true},
			{"id": "dead_log", "position": Vector2(312.0, 474.0), "scale": 0.78, "obstacle": true},
		],
		"collision_zones": [
			{"x": 112.0, "y": 76.0, "w": 134.0, "h": 100.0},
			{"x": 768.0, "y": 404.0, "w": 142.0, "h": 86.0},
			{"x": 106.0, "y": 326.0, "w": 108.0, "h": 94.0},
			{"x": 740.0, "y": 188.0, "w": 142.0, "h": 76.0},
			{"x": 240.0, "y": 438.0, "w": 148.0, "h": 62.0},
		],
	},
	"changban": {
		"title": "长坂坡雪夜",
		"ground_fill": "13130e",
		"ground_path": "res://assets/art/environment/changban/grass-base-01.png",
		"ground_layers": [
			{"role": "base", "path": "res://assets/art/environment/changban/grass-base-01.png", "opacity": 1.0},
			{"role": "blend", "path": "res://assets/art/environment/changban/grass-dirt-base-01.png", "opacity": 0.16, "tint": "d1c283"},
			{"role": "patch", "path": "res://assets/art/environment/changban/dirt-base-01.png", "opacity": 0.19, "tint": "d9bd7a", "regions": [Rect2(0.19, 0.27, 0.58, 0.39), Rect2(0.66, 0.08, 0.24, 0.21)]},
		],
		"save_path": "user://map_editor/changban.json",
		"assets": [
			{"id": "dirt_patch", "label": "泥土地块", "path": "res://assets/art/environment/changban/dirt-base-01.png", "default_scale": 1.0, "editor_visible": false},
			{"id": "grass_dirt_patch", "label": "草泥过渡地", "path": "res://assets/art/environment/changban/grass-dirt-base-01.png", "default_scale": 1.0, "editor_visible": false},
			{"id": "trampled_patch_01", "label": "践踏痕迹 A", "path": "res://assets/art/environment/changban/trampled-patch-01.png", "default_scale": 0.9, "editor_visible": false},
			{"id": "trampled_patch_02", "label": "践踏痕迹 B", "path": "res://assets/art/environment/changban/trampled-patch-02.png", "default_scale": 0.9, "editor_visible": false},
			{"id": "slope", "label": "山坡边界", "path": "res://assets/art/environment/changban/slope-chunk-01.png", "default_scale": 1.0},
		],
		"defaults": [
			{"id": "trampled_patch_01", "position": Vector2(274.0, 412.0), "scale": 0.82, "obstacle": false},
			{"id": "trampled_patch_02", "position": Vector2(580.0, 348.0), "scale": 0.74, "obstacle": false},
			{"id": "trampled_patch_01", "position": Vector2(830.0, 420.0), "scale": 0.70, "obstacle": false},
			{"id": "slope", "position": Vector2(84.0, 114.0), "scale": 0.88, "obstacle": true},
			{"id": "slope", "position": Vector2(916.0, 446.0), "scale": 0.88, "obstacle": true},
		],
		"collision_zones": [
			{"x": 0.0, "y": 54.0, "w": 180.0, "h": 124.0},
			{"x": 820.0, "y": 382.0, "w": 180.0, "h": 124.0},
		],
	},
	"hulao": {
		"title": "虎牢关外·斗将台",
		"ground_fill": "211a12",
		"ground_path": "res://assets/art/environment/changban/dirt-base-01.png",
		"ground_layers": [
			{"role": "base", "path": "res://assets/art/environment/changban/dirt-base-01.png", "opacity": 0.96, "tint": "e0d1ad"},
			{"role": "blend", "path": "res://assets/art/environment/changban/grass-dirt-base-01.png", "opacity": 0.11, "tint": "978a5d"},
			{"role": "patch", "path": "res://assets/art/environment/xinye1/1.png", "opacity": 0.05, "tint": "957b4d", "regions": [Rect2(0.05, 0.08, 0.31, 0.23), Rect2(0.67, 0.66, 0.27, 0.22)]},
		],
		"save_path": "user://map_editor/hulao.json",
		"assets": [
			{"id": "dirt_patch", "label": "斗将场泥地", "path": "res://assets/art/environment/changban/dirt-base-01.png", "default_scale": 1.0, "editor_visible": false},
			{"id": "slope", "label": "石土边坡", "path": "res://assets/art/environment/changban/slope-chunk-01.png", "default_scale": 1.0},
			{"id": "trampled_patch", "label": "斗将践踏痕", "path": "res://assets/art/environment/changban/trampled-patch-02.png", "default_scale": 0.9, "editor_visible": false},
		],
		"defaults": [
			{"id": "trampled_patch", "position": Vector2(500.0, 284.0), "scale": 1.05, "obstacle": false},
			{"id": "slope", "position": Vector2(96.0, 284.0), "scale": 0.82, "obstacle": true},
			{"id": "slope", "position": Vector2(904.0, 284.0), "scale": 0.82, "obstacle": true},
		],
		"collision_zones": [
			{"x": 0.0, "y": 226.0, "w": 172.0, "h": 116.0},
			{"x": 828.0, "y": 226.0, "w": 172.0, "h": 116.0},
		],
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
	var layer_count := ground_layers_for(battlefield_id).size()
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

static func asset_path_for(battlefield_id: String, asset_id: String) -> String:
	return str(asset_definition_for(battlefield_id, asset_id).get("path", ""))

static func is_editor_editable_asset(battlefield_id: String, asset_id: String) -> bool:
	return bool(asset_definition_for(battlefield_id, asset_id).get("editor_visible", true))

static func collision_normalized_for(asset_id: String) -> Rect2:
	return COLLISION_PRESETS.get(asset_id, Rect2(0.16, 0.58, 0.68, 0.22)) as Rect2

static func collision_rect_for_visual(visual_rect: Rect2, asset_id: String) -> Rect2:
	var normalized := collision_normalized_for(asset_id)
	return Rect2(
		visual_rect.position + Vector2(visual_rect.size.x * normalized.position.x, visual_rect.size.y * normalized.position.y),
		Vector2(visual_rect.size.x * normalized.size.x, visual_rect.size.y * normalized.size.y)
	)

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

static func save_objects_for(battlefield_id: String, objects: Array[Dictionary]) -> bool:
	return save_map_for(battlefield_id, objects, collision_zones_for(battlefield_id))

static func world_objects(battlefield_id: String, world_bounds: Rect2) -> Array[Dictionary]:
	var world_scale := Vector2(world_bounds.size.x / EDITOR_SIZE.x, world_bounds.size.y / EDITOR_SIZE.y)
	var resolved: Array[Dictionary] = []
	for object in objects_for(battlefield_id):
		var asset_id := str(object.get("id", ""))
		var texture := load(asset_path_for(battlefield_id, asset_id)) as Texture2D
		if texture == null:
			continue
		var source_size := texture.get_size()
		var source_max := maxf(1.0, maxf(source_size.x, source_size.y))
		var local_size := source_size * (190.0 / source_max) * float(object.get("scale", 1.0))
		var world_size := Vector2(local_size.x * world_scale.x, local_size.y * world_scale.y)
		var local_position: Vector2 = object.get("position", Vector2.ZERO) as Vector2
		var center := world_bounds.position + Vector2(local_position.x * world_scale.x, local_position.y * world_scale.y)
		var visual_rect := Rect2(center - world_size * 0.5, world_size)
		resolved.append({
			"id": asset_id,
			"texture": texture,
			"rect": visual_rect,
			"collision_rect": collision_rect_for_visual(visual_rect, asset_id),
			"obstacle": bool(object.get("obstacle", false)),
		})
	return resolved

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
