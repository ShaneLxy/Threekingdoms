extends Node

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const UPGRADE_SYSTEM = preload("res://scripts/systems/upgrade_system.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")

const PROFILE_PATH := "user://profile.json"
const PROFILE_BACKUP_PATH := "user://profile.json.bak"
const PROFILE_TEMP_PATH := "user://profile.json.tmp"
const CURRENT_SAVE_VERSION := 2
const PROTOTYPE_HERO_GRANT := ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"]
const LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS := true

var profile: Dictionary = {
	"save_version": CURRENT_SAVE_VERSION,
	"military_merit": 0,
	"unlocked_heroes": ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"],
	"completed_chapters": [],
	"purchased_upgrades": [],
	"military_strategies": {},
	"tianji_skills": {"seven_star_lightning": 1},
	"hero_talents": {"guan_yu": [], "zhang_fei": [], "zhao_yun": [], "ma_chao": [], "huang_zhong": []},
	"equipped_hero_id": "zhao_yun",
	"settings": {"sound_enabled": true, "vibration_enabled": true, "music_volume": 1.0, "sfx_volume": 1.0, "weather_mode": "auto"},
}

func load_profile() -> Dictionary:
	var loaded_profile: Dictionary = _read_profile_file(PROFILE_PATH)
	var recovered_from_backup := false
	if loaded_profile.is_empty():
		loaded_profile = _read_profile_file(PROFILE_BACKUP_PATH)
		recovered_from_backup = not loaded_profile.is_empty()
	if not loaded_profile.is_empty():
		profile = loaded_profile
	var migrated := _migrate_profile()
	if recovered_from_backup:
		_write_profile_safely(false)
	elif migrated:
		_write_profile_safely(true)
	return profile.duplicate(true)

func apply_result(result: Dictionary) -> void:
	profile["military_merit"] = int(profile.get("military_merit", 0)) + int(result.get("military_merit", 0))
	if bool(result.get("victory", false)):
		var completed_chapter_id := str(result.get("completed_chapter", ""))
		var completed: Array = profile.get("completed_chapters", [])
		if not completed_chapter_id.is_empty() and not completed.has(completed_chapter_id):
			completed.append(completed_chapter_id)
		profile["completed_chapters"] = completed
	save_profile()

func has_completed_chapter(chapter_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("completed_chapters", []) as Array).has(chapter_id)

func is_story_chapter_unlocked(chapter: int) -> bool:
	if LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS:
		return true
	if chapter <= 1:
		return true
	if chapter == 2 and has_completed_chapter("changban"):
		return true
	return has_completed_chapter("story_%02d" % (chapter - 1))

func is_battlefield_unlocked(battlefield_id: String) -> bool:
	if LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS:
		return true
	match battlefield_id:
		"changban", "hulao": return true
		"bowangpo": return has_completed_chapter("changban") or has_completed_chapter("story_01")
		_: return false

func save_profile() -> bool:
	_ensure_profile_shape()
	return _write_profile_safely(true)

func has_upgrade(upgrade_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("purchased_upgrades", []) as Array).has(upgrade_id)

func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	_ensure_profile_shape()
	if has_upgrade(upgrade_id) or int(profile.get("military_merit", 0)) < cost:
		return false
	var upgrades: Array = profile.get("purchased_upgrades", [])
	upgrades.append(upgrade_id)
	profile["purchased_upgrades"] = upgrades
	profile["military_merit"] = int(profile.get("military_merit", 0)) - cost
	save_profile()
	return true

func strategy_rank(strategy_id: String) -> int:
	_ensure_profile_shape()
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	return clampi(int(ranks.get(strategy_id, 0)), 0, MILITARY_STRATEGY.max_rank_for(strategy_id))

func strategy_cost(strategy_id: String) -> int:
	return MILITARY_STRATEGY.cost_for(strategy_id, strategy_rank(strategy_id))

func can_purchase_strategy(strategy_id: String) -> bool:
	_ensure_profile_shape()
	var definition := MILITARY_STRATEGY.definition_for(strategy_id)
	var current_rank := strategy_rank(strategy_id)
	if definition.is_empty() or current_rank >= int(definition.get("max_rank", 0)):
		return false
	var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
	if not prerequisite_id.is_empty() and strategy_rank(prerequisite_id) <= 0:
		return false
	return int(profile.get("military_merit", 0)) >= MILITARY_STRATEGY.cost_for(strategy_id, current_rank)

func purchase_strategy(strategy_id: String) -> bool:
	if not can_purchase_strategy(strategy_id):
		return false
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	var current_rank := strategy_rank(strategy_id)
	ranks[strategy_id] = current_rank + 1
	profile["military_strategies"] = ranks
	profile["military_merit"] = int(profile.get("military_merit", 0)) - MILITARY_STRATEGY.cost_for(strategy_id, current_rank)
	save_profile()
	return true

func tianji_rank(skill_id: String) -> int:
	_ensure_profile_shape()
	var ranks: Dictionary = profile.get("tianji_skills", {}) as Dictionary
	return clampi(int(ranks.get(skill_id, 0)), 0, TIANJI_CATALOG.max_rank_for(skill_id))

func tianji_cost(skill_id: String) -> int:
	return TIANJI_CATALOG.cost_for(skill_id, tianji_rank(skill_id))

func can_purchase_tianji(skill_id: String) -> bool:
	var rank := tianji_rank(skill_id)
	var max_rank := TIANJI_CATALOG.max_rank_for(skill_id)
	return rank < max_rank and int(profile.get("military_merit", 0)) >= TIANJI_CATALOG.cost_for(skill_id, rank)

func purchase_tianji(skill_id: String) -> bool:
	if not can_purchase_tianji(skill_id):
		return false
	var ranks: Dictionary = profile.get("tianji_skills", {}) as Dictionary
	var rank := tianji_rank(skill_id)
	var cost := TIANJI_CATALOG.cost_for(skill_id, rank)
	ranks[skill_id] = rank + 1
	profile["tianji_skills"] = ranks
	profile["military_merit"] = int(profile.get("military_merit", 0)) - cost
	save_profile()
	return true

func unlocked_tianji_ids() -> Array[String]:
	_ensure_profile_shape()
	var result: Array[String] = []
	for skill_id in TIANJI_CATALOG.all_ids():
		if tianji_rank(skill_id) > 0:
			result.append(skill_id)
	return result

func has_talent(hero_id: String, talent_id: String) -> bool:
	_ensure_profile_shape()
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	return (hero_talents.get(hero_id, []) as Array).has(talent_id)

func is_talent_unlocked_for_purchase(hero_id: String, talent_id: String) -> bool:
	if has_talent(hero_id, talent_id):
		return true
	var hero_definition := HERO_CATALOG.definition_for(hero_id)
	var branches: Array = hero_definition.get("talent_tree", []) as Array
	for branch_variant in branches:
		var branch: Dictionary = branch_variant as Dictionary
		var nodes: Array = branch.get("nodes", []) as Array
		for node_variant in nodes:
			var node: Dictionary = node_variant as Dictionary
			if str(node.get("id", "")) == talent_id:
				return bool(node.get("is_core", false))
	return false

func purchase_talent(hero_id: String, talent_id: String, cost: int) -> bool:
	_ensure_profile_shape()
	var definition: Dictionary = UPGRADE_SYSTEM.DEFINITIONS.get(talent_id, {}) as Dictionary
	if definition.is_empty() or cost <= 0 or not has_hero(hero_id) or has_talent(hero_id, talent_id) or int(profile.get("military_merit", 0)) < cost:
		return false
	if is_talent_unlocked_for_purchase(hero_id, talent_id):
		return false
	var prerequisite_id := str(definition.get("requires", ""))
	if not prerequisite_id.is_empty() and not is_talent_unlocked_for_purchase(hero_id, prerequisite_id):
		return false
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	var talents: Array = hero_talents.get(hero_id, [])
	talents.append(talent_id)
	hero_talents[hero_id] = talents
	profile["hero_talents"] = hero_talents
	profile["military_merit"] = int(profile.get("military_merit", 0)) - cost
	save_profile()
	return true

func has_hero(hero_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("unlocked_heroes", []) as Array).has(hero_id)

func purchase_hero(hero_id: String, cost: int) -> bool:
	_ensure_profile_shape()
	if cost <= 0 or not HERO_CATALOG.is_playable(hero_id) or has_hero(hero_id) or int(profile.get("military_merit", 0)) < cost:
		return false
	var heroes: Array = profile.get("unlocked_heroes", [])
	heroes.append(hero_id)
	profile["unlocked_heroes"] = heroes
	profile["military_merit"] = int(profile.get("military_merit", 0)) - cost
	save_profile()
	return true

func setting_enabled(setting_id: String) -> bool:
	_ensure_profile_shape()
	return bool((profile.get("settings", {}) as Dictionary).get(setting_id, false))

func set_setting(setting_id: String, enabled: bool) -> void:
	_ensure_profile_shape()
	var settings: Dictionary = profile.get("settings", {})
	settings[setting_id] = enabled
	profile["settings"] = settings
	save_profile()

func setting_value(setting_id: String, fallback: Variant) -> Variant:
	_ensure_profile_shape()
	return (profile.get("settings", {}) as Dictionary).get(setting_id, fallback)

func set_setting_value(setting_id: String, value: Variant) -> void:
	_ensure_profile_shape()
	var settings: Dictionary = profile.get("settings", {})
	settings[setting_id] = value
	profile["settings"] = settings
	save_profile()

func equipped_hero_id() -> String:
	_ensure_profile_shape()
	return str(profile.get("equipped_hero_id", "zhao_yun"))

func equip_hero(hero_id: String) -> bool:
	_ensure_profile_shape()
	var unlocked: Array = profile.get("unlocked_heroes", [])
	if not HERO_CATALOG.is_playable(hero_id) or not unlocked.has(hero_id):
		return false
	profile["equipped_hero_id"] = hero_id
	save_profile()
	return true

func _migrate_profile() -> bool:
	var changed := false
	var stored_version := int(profile.get("save_version", 0))
	var save_version := stored_version
	if save_version < 1:
		changed = _migrate_to_version_1() or changed
		save_version = 1
	if save_version < 2:
		changed = _migrate_to_version_2() or changed
		save_version = 2
	if save_version != stored_version:
		profile["save_version"] = save_version
		changed = true
	var shape_changed := _ensure_profile_shape()
	return changed or shape_changed

func _migrate_to_version_1() -> bool:
	var changed := false
	var heroes: Array = profile.get("unlocked_heroes", []) as Array
	if heroes.is_empty():
		heroes = ["zhao_yun"]
		changed = true
	if _append_unique_ids(heroes, PROTOTYPE_HERO_GRANT):
		changed = true
	profile["unlocked_heroes"] = heroes
	return changed

func _migrate_to_version_2() -> bool:
	var changed := false
	if not profile.has("military_strategies"):
		profile["military_strategies"] = {}
		changed = true
	if not profile.has("tianji_skills"):
		profile["tianji_skills"] = {"seven_star_lightning": 1}
		changed = true
	var tianji_skills: Dictionary = profile.get("tianji_skills", {}) as Dictionary
	if not tianji_skills.has("seven_star_lightning"):
		tianji_skills["seven_star_lightning"] = 1
		profile["tianji_skills"] = tianji_skills
		changed = true
	for obsolete_key in ["tianji_seals", "tianji_slots", "tianji_pity", "tianji_free_spin_used"]:
		if profile.has(obsolete_key):
			profile.erase(obsolete_key)
			changed = true
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	var legacy_upgrades: Array = profile.get("purchased_upgrades", []) as Array
	if legacy_upgrades.has("dragon_tactics") and int(ranks.get("arsenal_refine", 0)) < 3:
		ranks["arsenal_refine"] = 3
		changed = true
	if legacy_upgrades.has("seven_drill") and int(ranks.get("command_manual", 0)) < 2:
		ranks["command_manual"] = 2
		changed = true
	profile["military_strategies"] = ranks
	return changed

func _ensure_profile_shape() -> bool:
	var changed := false
	if not profile.has("military_merit"):
		profile["military_merit"] = 0
		changed = true
	if not profile.has("unlocked_heroes"):
		profile["unlocked_heroes"] = ["zhao_yun"]
		changed = true
	if not profile.has("completed_chapters"):
		profile["completed_chapters"] = []
		changed = true
	if not profile.has("purchased_upgrades"):
		profile["purchased_upgrades"] = []
		changed = true
	if not profile.has("military_strategies"):
		profile["military_strategies"] = {}
		changed = true
	for obsolete_key in ["tianji_seals", "tianji_slots", "tianji_pity", "tianji_free_spin_used"]:
		if profile.has(obsolete_key):
			profile.erase(obsolete_key)
			changed = true
	if not profile.has("hero_talents"):
		var legacy_talents: Array = profile.get("unlocked_talents", [])
		profile["hero_talents"] = {"zhao_yun": legacy_talents.duplicate()}
		changed = true
	if profile.has("unlocked_talents"):
		profile.erase("unlocked_talents")
		changed = true
	if not profile.has("equipped_hero_id"):
		profile["equipped_hero_id"] = "zhao_yun"
		changed = true
	if not profile.has("settings"):
		profile["settings"] = {}
		changed = true
	var settings: Dictionary = profile.get("settings", {})
	if not settings.has("sound_enabled"):
		settings["sound_enabled"] = true
		changed = true
	if not settings.has("vibration_enabled"):
		settings["vibration_enabled"] = true
		changed = true
	if not settings.has("music_volume"):
		settings["music_volume"] = 1.0
		changed = true
	if not settings.has("sfx_volume"):
		settings["sfx_volume"] = 1.0
		changed = true
	if not settings.has("weather_mode"):
		settings["weather_mode"] = "auto"
		changed = true
	elif settings["weather_mode"] == "ash":
		settings["weather_mode"] = "auto"
		changed = true
	profile["settings"] = settings
	return changed

func _read_profile_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var parsed_profile: Dictionary = parsed as Dictionary
	return parsed_profile.duplicate(true)

func _write_profile_safely(rotate_backup: bool) -> bool:
	var serialized_profile := JSON.stringify(profile)
	if not _write_text_file(PROFILE_TEMP_PATH, serialized_profile):
		return false
	if rotate_backup and FileAccess.file_exists(PROFILE_PATH):
		if not _copy_file(PROFILE_PATH, PROFILE_BACKUP_PATH):
			DirAccess.remove_absolute(PROFILE_TEMP_PATH)
			return false
	var rename_error := DirAccess.rename_absolute(PROFILE_TEMP_PATH, PROFILE_PATH)
	if rename_error == OK:
		return true
	# Some platforms do not replace an existing destination during rename.
	if FileAccess.file_exists(PROFILE_PATH):
		DirAccess.remove_absolute(PROFILE_PATH)
		rename_error = DirAccess.rename_absolute(PROFILE_TEMP_PATH, PROFILE_PATH)
	if rename_error != OK:
		push_error("Failed to write local profile: %s" % error_string(rename_error))
		return false
	return true

func _write_text_file(path: String, contents: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(contents)
	file.flush()
	return file.get_error() == OK

func _copy_file(source_path: String, destination_path: String) -> bool:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(source_path)
	if bytes.is_empty():
		return false
	var destination := FileAccess.open(destination_path, FileAccess.WRITE)
	if destination == null:
		return false
	destination.store_buffer(bytes)
	destination.flush()
	return destination.get_error() == OK

func _append_unique_ids(target: Array, ids: Array) -> bool:
	var changed := false
	for raw_id in ids:
		var id := str(raw_id)
		if target.has(id):
			continue
		target.append(id)
		changed = true
	return changed
