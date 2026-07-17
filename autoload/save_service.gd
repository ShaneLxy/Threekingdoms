extends Node

const PROFILE_PATH := "user://profile.json"

var profile: Dictionary = {
	"military_merit": 0,
	"unlocked_heroes": ["zhao_yun"],
	"completed_chapters": [],
	"purchased_upgrades": [],
	"equipped_hero_id": "zhao_yun",
	"settings": {"sound_enabled": true, "vibration_enabled": true},
}

func load_profile() -> Dictionary:
	if FileAccess.file_exists(PROFILE_PATH):
		var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			profile = parsed
	_ensure_profile_shape()
	return profile.duplicate(true)

func apply_result(result: Dictionary) -> void:
	profile["military_merit"] = int(profile.get("military_merit", 0)) + int(result.get("military_merit", 0))
	if bool(result.get("victory", false)):
		var completed: Array = profile.get("completed_chapters", [])
		if not completed.has("changban"):
			completed.append("changban")
		profile["completed_chapters"] = completed
	save_profile()

func save_profile() -> void:
	_ensure_profile_shape()
	var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(profile))

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

func setting_enabled(setting_id: String) -> bool:
	_ensure_profile_shape()
	return bool((profile.get("settings", {}) as Dictionary).get(setting_id, false))

func set_setting(setting_id: String, enabled: bool) -> void:
	_ensure_profile_shape()
	var settings: Dictionary = profile.get("settings", {})
	settings[setting_id] = enabled
	profile["settings"] = settings
	save_profile()

func equipped_hero_id() -> String:
	_ensure_profile_shape()
	return str(profile.get("equipped_hero_id", "zhao_yun"))

func equip_hero(hero_id: String) -> bool:
	_ensure_profile_shape()
	var unlocked: Array = profile.get("unlocked_heroes", [])
	if not unlocked.has(hero_id):
		return false
	profile["equipped_hero_id"] = hero_id
	save_profile()
	return true

func _ensure_profile_shape() -> void:
	if not profile.has("military_merit"):
		profile["military_merit"] = 0
	if not profile.has("unlocked_heroes"):
		profile["unlocked_heroes"] = ["zhao_yun"]
	if not profile.has("completed_chapters"):
		profile["completed_chapters"] = []
	if not profile.has("purchased_upgrades"):
		profile["purchased_upgrades"] = []
	if not profile.has("equipped_hero_id"):
		profile["equipped_hero_id"] = "zhao_yun"
	if not profile.has("settings"):
		profile["settings"] = {"sound_enabled": true, "vibration_enabled": true}
