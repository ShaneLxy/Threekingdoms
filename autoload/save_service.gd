extends Node

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const UPGRADE_SYSTEM = preload("res://scripts/systems/upgrade_system.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")

const PROFILE_PATH := "user://profile.json"
const PROFILE_BACKUP_PATH := "user://profile.json.bak"
const PROFILE_TEMP_PATH := "user://profile.json.tmp"
const CURRENT_SAVE_VERSION := 9
const DEFAULT_NEW_PROFILE_HEROES := ["guan_yu", "zhang_fei", "zhao_yun"]
const DEFAULT_NEW_PROFILE_TIANJI_SKILLS := {
	"fire_rain_burning": 1,
	"xun_wind_break": 1,
	"arrow_support_volley": 1,
}
const LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS := false

var profile: Dictionary = {
	"save_version": CURRENT_SAVE_VERSION,
	"military_merit": 2000,
	"unlocked_heroes": DEFAULT_NEW_PROFILE_HEROES.duplicate(),
	"completed_chapters": [],
	"completed_boss_trials": [],
	"purchased_upgrades": [],
	"military_strategies": {},
	"tianji_skills": DEFAULT_NEW_PROFILE_TIANJI_SKILLS.duplicate(),
	"hero_talents": {"guan_yu": [], "zhang_fei": [], "zhao_yun": [], "ma_chao": [], "huang_zhong": []},
	"hero_talent_ranks": {"guan_yu": {}, "zhang_fei": {}, "zhao_yun": {}, "ma_chao": {}, "huang_zhong": {}},
	"tutorial_stage": 0,
	"tutorial_completed": false,
	"equipped_hero_id": "guan_yu",
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
		var completed_boss_trial_id := str(result.get("completed_boss_trial", ""))
		var completed_boss_trials: Array = profile.get("completed_boss_trials", [])
		if not completed_boss_trial_id.is_empty() and not completed_boss_trials.has(completed_boss_trial_id):
			completed_boss_trials.append(completed_boss_trial_id)
		profile["completed_boss_trials"] = completed_boss_trials
	save_profile()

func grant_military_merit(amount: int) -> int:
	if amount <= 0:
		return int(profile.get("military_merit", 0))
	profile["military_merit"] = int(profile.get("military_merit", 0)) + amount
	save_profile()
	return int(profile["military_merit"])

func has_completed_chapter(chapter_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("completed_chapters", []) as Array).has(chapter_id)

func has_completed_boss_trial(trial_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("completed_boss_trials", []) as Array).has(trial_id)

func is_story_chapter_unlocked(chapter: int) -> bool:
	if LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS:
		return true
	if chapter <= 1:
		return true
	# The visible route uses internal IDs 1, 3, and 5, but unlocks strictly by
	# the preceding visible chapter.
	var visible_to_internal := [1, 3, 5]
	var visible_index := chapter - 1
	if visible_index >= visible_to_internal.size():
		return false
	var previous_internal_chapter := int(visible_to_internal[visible_index - 1])
	return has_completed_chapter("story_%02d" % previous_internal_chapter)

func is_battlefield_unlocked(battlefield_id: String) -> bool:
	if LOCAL_TEST_UNLOCK_ALL_BATTLEFIELDS:
		return true
	match battlefield_id:
		"changban", "hulao": return has_completed_chapter("story_05")
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
	if not MILITARY_STRATEGY.prerequisite_satisfied_for(profile, strategy_id):
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
	return talent_rank(hero_id, talent_id) > 0

func talent_rank(hero_id: String, talent_id: String) -> int:
	_ensure_profile_shape()
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var ranks: Dictionary = all_ranks.get(hero_id, {}) as Dictionary
	var stored_rank := int(ranks.get(talent_id, 0))
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	var legacy_rank := 1 if (hero_talents.get(hero_id, []) as Array).has(talent_id) else 0
	return clampi(maxi(stored_rank, legacy_rank), 0, talent_max_rank(hero_id, talent_id))

func talent_max_rank(_hero_id: String, talent_id: String) -> int:
	var definition: Dictionary = UPGRADE_SYSTEM.DEFINITIONS.get(talent_id, {}) as Dictionary
	return maxi(1, int(definition.get("shop_max_rank", 1)))

func talent_cost(hero_id: String, talent_id: String, fallback_cost: int = 0) -> int:
	var definition: Dictionary = UPGRADE_SYSTEM.DEFINITIONS.get(talent_id, {}) as Dictionary
	var costs: Array = definition.get("shop_costs", []) as Array
	var current_rank := talent_rank(hero_id, talent_id)
	if current_rank >= 0 and current_rank < costs.size():
		return int(costs[current_rank])
	return fallback_cost

func is_talent_maxed(hero_id: String, talent_id: String) -> bool:
	return talent_rank(hero_id, talent_id) >= talent_max_rank(hero_id, talent_id)

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

func talent_prerequisite_satisfied_for_purchase(hero_id: String, talent_id: String) -> bool:
	var definition: Dictionary = UPGRADE_SYSTEM.DEFINITIONS.get(talent_id, {}) as Dictionary
	var prerequisite_id := str(definition.get("requires", ""))
	if prerequisite_id.is_empty():
		return true
	if not is_talent_unlocked_for_purchase(hero_id, prerequisite_id):
		return false
	var required_rank := maxi(1, int(definition.get("requires_stacks", 1)))
	if required_rank <= 1:
		return true
	# Core talents have no permanent ranks; their stack requirement is enforced
	# only during the current battle's upgrade draft.
	if not has_talent(hero_id, prerequisite_id):
		return true
	return talent_rank(hero_id, prerequisite_id) >= required_rank

func purchase_talent(hero_id: String, talent_id: String, cost: int) -> bool:
	_ensure_profile_shape()
	var definition: Dictionary = UPGRADE_SYSTEM.DEFINITIONS.get(talent_id, {}) as Dictionary
	var current_rank := talent_rank(hero_id, talent_id)
	var max_rank := talent_max_rank(hero_id, talent_id)
	var next_cost := talent_cost(hero_id, talent_id, cost)
	if definition.is_empty() or next_cost <= 0 or not has_hero(hero_id) or current_rank >= max_rank or int(profile.get("military_merit", 0)) < next_cost:
		return false
	if current_rank <= 0 and is_talent_unlocked_for_purchase(hero_id, talent_id):
		return false
	if not talent_prerequisite_satisfied_for_purchase(hero_id, talent_id):
		return false
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	var talents: Array = hero_talents.get(hero_id, [])
	if not talents.has(talent_id):
		talents.append(talent_id)
	hero_talents[hero_id] = talents
	profile["hero_talents"] = hero_talents
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var ranks: Dictionary = all_ranks.get(hero_id, {}) as Dictionary
	ranks[talent_id] = current_rank + 1
	all_ranks[hero_id] = ranks
	profile["hero_talent_ranks"] = all_ranks
	profile["military_merit"] = int(profile.get("military_merit", 0)) - next_cost
	save_profile()
	return true

func has_hero(hero_id: String) -> bool:
	_ensure_profile_shape()
	return (profile.get("unlocked_heroes", []) as Array).has(hero_id)

func purchase_hero(hero_id: String, cost: int) -> bool:
	_ensure_profile_shape()
	var hero_definition := HERO_CATALOG.definition_for(hero_id)
	var required_cost := int(hero_definition.get("unlock_cost", cost))
	if required_cost <= 0 or not HERO_CATALOG.has_hero(hero_id) or not bool(hero_definition.get("shop_available", true)) or not HERO_CATALOG.is_playable(hero_id) or has_hero(hero_id) or int(profile.get("military_merit", 0)) < required_cost:
		return false
	var heroes: Array = profile.get("unlocked_heroes", [])
	heroes.append(hero_id)
	profile["unlocked_heroes"] = heroes
	profile["military_merit"] = int(profile.get("military_merit", 0)) - required_cost
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
	return str(profile.get("equipped_hero_id", "guan_yu"))

func equip_hero(hero_id: String) -> bool:
	_ensure_profile_shape()
	var unlocked: Array = profile.get("unlocked_heroes", [])
	if not HERO_CATALOG.is_playable(hero_id) or not unlocked.has(hero_id):
		return false
	profile["equipped_hero_id"] = hero_id
	save_profile()
	return true

func tutorial_stage() -> int:
	_ensure_profile_shape()
	return maxi(0, int(profile.get("tutorial_stage", 0)))

func tutorial_completed() -> bool:
	_ensure_profile_shape()
	return bool(profile.get("tutorial_completed", false))

func set_tutorial_stage(stage: int) -> void:
	_ensure_profile_shape()
	profile["tutorial_stage"] = maxi(0, stage)
	save_profile()

func complete_tutorial() -> void:
	_ensure_profile_shape()
	profile["tutorial_completed"] = true
	profile["tutorial_stage"] = 20
	save_profile()

func restart_tutorial() -> void:
	_ensure_profile_shape()
	profile["tutorial_completed"] = false
	profile["tutorial_stage"] = 0
	save_profile()

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
	if save_version < 3:
		changed = _migrate_to_version_3() or changed
		save_version = 3
	if save_version < 4:
		changed = _migrate_to_version_4() or changed
		save_version = 4
	if save_version < 5:
		changed = _migrate_to_version_5() or changed
		save_version = 5
	if save_version < 6:
		changed = _migrate_to_version_6() or changed
		save_version = 6
	if save_version < 7:
		changed = _migrate_to_version_7() or changed
		save_version = 7
	if save_version < 8:
		changed = _migrate_to_version_8() or changed
		save_version = 8
	if save_version < 9:
		changed = _migrate_to_version_9() or changed
		save_version = 9
	if save_version != stored_version:
		profile["save_version"] = save_version
		changed = true
	var shape_changed := _ensure_profile_shape()
	# Builds before the tutorial completion fix could leave a profile at the
	# Five Tiger selection stages after the player had already entered battle.
	# The selection page is now the completion point, so repair those saves on
	# the next load.
	if not bool(profile.get("tutorial_completed", false)) and int(profile.get("tutorial_stage", 0)) >= 18:
		profile["tutorial_completed"] = true
		profile["tutorial_stage"] = 20
		changed = true
	return changed or shape_changed

func _migrate_to_version_1() -> bool:
	var changed := false
	var heroes: Array = profile.get("unlocked_heroes", []) as Array
	if heroes.is_empty():
		heroes = DEFAULT_NEW_PROFILE_HEROES.duplicate()
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

func _migrate_to_version_3() -> bool:
	var changed := false
	if not profile.has("hero_talent_ranks"):
		profile["hero_talent_ranks"] = {}
		changed = true
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var hero_talents: Dictionary = profile.get("hero_talents", {}) as Dictionary
	for hero_id_variant in HERO_CATALOG.all_ids():
		var hero_id := str(hero_id_variant)
		var ranks: Dictionary = all_ranks.get(hero_id, {}) as Dictionary
		var talents: Array = hero_talents.get(hero_id, []) as Array
		for talent_id_variant in talents:
			var talent_id := str(talent_id_variant)
			if int(ranks.get(talent_id, 0)) <= 0:
				ranks[talent_id] = 1
				changed = true
		all_ranks[hero_id] = ranks
	profile["hero_talent_ranks"] = all_ranks
	return changed

func _migrate_to_version_4() -> bool:
	var changed := false
	var hero_talents: Dictionary = profile.get("hero_talents", {}) as Dictionary
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var legacy_talents: Array = hero_talents.get("zhang_fei", []) as Array
	var legacy_ranks: Dictionary = all_ranks.get("zhang_fei", {}) as Dictionary
	var legacy_level := maxi(int(legacy_ranks.get("zhang_leaping_slam", 0)), 1 if legacy_talents.has("zhang_leaping_slam") else 0)
	if legacy_level > 0:
		var migrated_ids := ["zhang_slam_range", "zhang_slam_leap", "zhang_slam_mastery"]
		var zhang_talents: Array = hero_talents.get("zhang_fei", []) as Array
		var zhang_ranks: Dictionary = all_ranks.get("zhang_fei", {}) as Dictionary
		for index in range(mini(legacy_level, migrated_ids.size())):
			var talent_id := str(migrated_ids[index])
			if int(zhang_ranks.get(talent_id, 0)) <= 0:
				zhang_ranks[talent_id] = 1
				changed = true
			if not zhang_talents.has(talent_id):
				zhang_talents.append(talent_id)
				changed = true
		hero_talents["zhang_fei"] = zhang_talents
		all_ranks["zhang_fei"] = zhang_ranks
	profile["hero_talents"] = hero_talents
	profile["hero_talent_ranks"] = all_ranks
	return changed

func _migrate_to_version_5() -> bool:
	# "震域" was removed from Zhang Fei's public tree.  Give owners the new
	# first purchasable node so their prior military merit remains represented.
	var changed := false
	var hero_talents: Dictionary = profile.get("hero_talents", {}) as Dictionary
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var zhang_talents: Array = hero_talents.get("zhang_fei", []) as Array
	var zhang_ranks: Dictionary = all_ranks.get("zhang_fei", {}) as Dictionary
	var owned_legacy_range := zhang_talents.has("zhang_slam_range") or int(zhang_ranks.get("zhang_slam_range", 0)) > 0
	if not owned_legacy_range:
		return false
	if int(zhang_ranks.get("zhang_slam_leap", 0)) <= 0:
		zhang_ranks["zhang_slam_leap"] = 1
		changed = true
	if not zhang_talents.has("zhang_slam_leap"):
		zhang_talents.append("zhang_slam_leap")
		changed = true
	hero_talents["zhang_fei"] = zhang_talents
	all_ranks["zhang_fei"] = zhang_ranks
	profile["hero_talents"] = hero_talents
	profile["hero_talent_ranks"] = all_ranks
	return changed

func _migrate_to_version_6() -> bool:
	if profile.has("completed_boss_trials"):
		return false
	profile["completed_boss_trials"] = []
	return true

func _migrate_to_version_7() -> bool:
	var changed := false
	var heroes: Array = profile.get("unlocked_heroes", []) as Array
	for hero_id in ["zhang_fei", "zhao_yun"]:
		if not heroes.has(hero_id):
			heroes.append(hero_id)
			changed = true
	profile["unlocked_heroes"] = heroes
	if int(profile.get("military_merit", 0)) < 2000:
		profile["military_merit"] = 2000
		changed = true
	return changed

func _migrate_to_version_8() -> bool:
	if profile.has("tutorial_stage") and profile.has("tutorial_completed"):
		return false
	# Existing profiles with meaningful progress should not be interrupted by a
	# first-install tutorial added in a later build.
	var completed := not (profile.get("completed_chapters", []) as Array).is_empty()
	completed = completed or not (profile.get("purchased_upgrades", []) as Array).is_empty()
	completed = completed or not (profile.get("hero_talents", {}) as Dictionary).is_empty() and _has_any_talent_rank()
	profile["tutorial_completed"] = completed
	profile["tutorial_stage"] = 13 if completed else 0
	return true

func _migrate_to_version_9() -> bool:
	# Expand the first-install tutorial with explicit page-introduction steps.
	# Existing in-progress tutorials are moved to their corresponding new step.
	var old_stage := int(profile.get("tutorial_stage", 0))
	var stage_map := {
		2: 3,
		3: 5,
		4: 6,
		5: 7,
		6: 9,
		7: 10,
		8: 12,
		9: 14,
		10: 15,
		11: 16,
		12: 19,
		13: 20,
	}
	if stage_map.has(old_stage):
		profile["tutorial_stage"] = int(stage_map[old_stage])
		if old_stage >= 13:
			profile["tutorial_completed"] = true
	return true

func _has_any_talent_rank() -> bool:
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	for ranks_variant in all_ranks.values():
		if not (ranks_variant is Dictionary):
			continue
		for rank_variant in (ranks_variant as Dictionary).values():
			if int(rank_variant) > 0:
				return true
	return false

func _ensure_profile_shape() -> bool:
	var changed := false
	if not profile.has("military_merit"):
		profile["military_merit"] = 2000
		changed = true
	if not profile.has("unlocked_heroes"):
		profile["unlocked_heroes"] = DEFAULT_NEW_PROFILE_HEROES.duplicate()
		changed = true
	if not profile.has("completed_chapters"):
		profile["completed_chapters"] = []
		changed = true
	if not profile.has("completed_boss_trials"):
		profile["completed_boss_trials"] = []
		changed = true
	if not profile.has("purchased_upgrades"):
		profile["purchased_upgrades"] = []
		changed = true
	if not profile.has("tutorial_stage"):
		profile["tutorial_stage"] = 0
		changed = true
	if not profile.has("tutorial_completed"):
		profile["tutorial_completed"] = false
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
	var hero_talents: Dictionary = profile.get("hero_talents", {}) as Dictionary
	if not profile.has("hero_talent_ranks"):
		profile["hero_talent_ranks"] = {}
		changed = true
	var all_talent_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	for hero_id_variant in HERO_CATALOG.all_ids():
		var hero_id := str(hero_id_variant)
		if not hero_talents.has(hero_id):
			hero_talents[hero_id] = []
			changed = true
		var ranks: Dictionary = all_talent_ranks.get(hero_id, {}) as Dictionary
		var talents: Array = hero_talents.get(hero_id, []) as Array
		for talent_id_variant in talents:
			var talent_id := str(talent_id_variant)
			if int(ranks.get(talent_id, 0)) <= 0:
				ranks[talent_id] = 1
				changed = true
		all_talent_ranks[hero_id] = ranks
	profile["hero_talents"] = hero_talents
	profile["hero_talent_ranks"] = all_talent_ranks
	if profile.has("unlocked_talents"):
		profile.erase("unlocked_talents")
		changed = true
	if not profile.has("equipped_hero_id"):
		profile["equipped_hero_id"] = "guan_yu"
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
