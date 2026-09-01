class_name RunDirector
extends Node

const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")

signal spawn_requested(enemy_type: int, at: Vector2)
signal elite_requested(elite_id: String, at: Vector2)
signal boss_requested(at: Vector2)
signal level_up(level: int)
signal stage_changed(label: String)
signal threat_tier_changed(tier: int)

const STORY_DURATION := 600.0
const ENDLESS_DURATION := 1200.0
const BOSS_TRIAL_MODE := "boss_trial"
const BOSS_TRIAL_START_LEVEL := 5
const EXPERIENCE_BASE_REQUIREMENT := 8.0
const EXPERIENCE_GROWTH_RATE := 1.14
const MAX_EXPERIENCE_REQUIREMENT := 120
const STORY_CHAPTERS := {
	1: {
		"id": "story_01",
		"title": "新野练兵",
		"intro": "第一章：新野练兵，先稳住刘备军的前线",
		"completion": "第一章完成，新野军阵已经整备完毕。",
		"duration": 300.0,
		"phases": [
			{"until": 100.0, "threat": 0, "profile": {"interval": 0.72, "soft_capacity": 18, "hard_capacity": 26, "burst": 2}, "enemies": [{"id": "sword", "weight": 76}, {"id": "shield", "weight": 24}]},
			{"until": 200.0, "threat": 0, "profile": {"interval": 0.62, "soft_capacity": 24, "hard_capacity": 34, "burst": 2}, "enemies": [{"id": "sword", "weight": 52}, {"id": "shield", "weight": 48}]},
			{"until": 300.0, "threat": 1, "profile": {"interval": 0.54, "soft_capacity": 30, "hard_capacity": 40, "burst": 2}, "enemies": [{"id": "sword", "weight": 38}, {"id": "shield", "weight": 42}, {"id": "spear", "weight": 20}]},
		],
		"events": [
			{"time": 100.0, "message": "拒阵推进：盾兵开始护住前排", "formation": "shield_line"},
			{"time": 108.0, "message": "夏侯恩率亲卫截击", "elite": "xiahou_en"},
			{"time": 200.0, "message": "长枪压阵：横移避开长刺", "formation": "spear_wall"},
		],
	},
	2: {
		"id": "story_02",
		"title": "博望坡·火攻",
		"intro": "第二章：博望坡火攻，击破曹军前锋",
		"completion": "第二章完成，博望坡曹军前锋已经溃退。",
		"duration": 360.0,
		"requires_boss": true,
		"phases": [
			{"until": 120.0, "threat": 0, "profile": {"interval": 0.66, "soft_capacity": 22, "hard_capacity": 32, "burst": 2}, "enemies": [{"id": "sword", "weight": 44}, {"id": "shield", "weight": 34}, {"id": "spear", "weight": 22}]},
			{"until": 240.0, "threat": 1, "profile": {"interval": 0.56, "soft_capacity": 30, "hard_capacity": 42, "burst": 2}, "enemies": [{"id": "sword", "weight": 30}, {"id": "shield", "weight": 38}, {"id": "spear", "weight": 32}]},
			{"until": 360.0, "threat": 1, "profile": {"interval": 0.48, "soft_capacity": 36, "hard_capacity": 48, "burst": 3}, "enemies": [{"id": "sword", "weight": 22}, {"id": "shield", "weight": 34}, {"id": "spear", "weight": 28}, {"id": "halberd", "weight": 16}]},
		],
		"events": [
			{"time": 120.0, "message": "枪盾并进：先拆开拒阵缺口", "formation": "spear_wall"},
			{"time": 132.0, "message": "夏侯恩再度压阵", "elite": "xiahou_en"},
			{"time": 252.0, "message": "淳于导提刀增援", "elite": "chunyu_dao"},
			{"time": 300.0, "message": "敌将现身：夏侯惇", "boss": true},
		],
	},
	3: {
		"id": "story_03",
		"title": "火烧新野",
		"intro": "第三章：火烧新野，组织撤离并击退追兵",
		"completion": "第三章完成，新野百姓已经脱离曹军追击。",
		"duration": 390.0,
		"phases": [
			{"until": 130.0, "threat": 1, "profile": {"interval": 0.62, "soft_capacity": 26, "hard_capacity": 36, "burst": 2}, "enemies": [{"id": "sword", "weight": 34}, {"id": "shield", "weight": 36}, {"id": "spear", "weight": 30}]},
			{"until": 260.0, "threat": 1, "profile": {"interval": 0.52, "soft_capacity": 34, "hard_capacity": 46, "burst": 2}, "enemies": [{"id": "sword", "weight": 26}, {"id": "shield", "weight": 32}, {"id": "spear", "weight": 26}, {"id": "archer", "weight": 16}]},
			{"until": 390.0, "threat": 2, "profile": {"interval": 0.46, "soft_capacity": 40, "hard_capacity": 54, "burst": 3}, "enemies": [{"id": "shield", "weight": 28}, {"id": "spear", "weight": 25}, {"id": "halberd", "weight": 22}, {"id": "archer", "weight": 25}]},
		],
		"events": [
			{"time": 130.0, "message": "乱箭逼近：优先切入后排弓手", "formation": "archer_screen"},
			{"time": 168.0, "message": "淳于导督阵而来", "elite": "chunyu_dao"},
		],
	},
	4: {
		"id": "story_04",
		"title": "襄阳撤退",
		"intro": "第四章：襄阳撤退，护住百姓并突破北线合围",
		"completion": "第四章完成，撤退队伍已经穿过襄阳北线。",
		"duration": 480.0,
		"phases": [
			{"until": 150.0, "threat": 1, "profile": {"interval": 0.56, "soft_capacity": 30, "hard_capacity": 42, "burst": 2}, "enemies": [{"id": "shield", "weight": 34}, {"id": "spear", "weight": 34}, {"id": "halberd", "weight": 18}, {"id": "sword", "weight": 14}]},
			{"until": 300.0, "threat": 2, "profile": {"interval": 0.48, "soft_capacity": 38, "hard_capacity": 52, "burst": 3}, "enemies": [{"id": "shield", "weight": 26}, {"id": "spear", "weight": 25}, {"id": "halberd", "weight": 28}, {"id": "archer", "weight": 21}]},
			{"until": 480.0, "threat": 2, "profile": {"interval": 0.42, "soft_capacity": 46, "hard_capacity": 60, "burst": 3}, "enemies": [{"id": "shield", "weight": 20}, {"id": "spear", "weight": 23}, {"id": "halberd", "weight": 28}, {"id": "archer", "weight": 29}]},
		],
		"events": [
			{"time": 150.0, "message": "戟卫合围：保持移动，避开夹击", "formation": "halberd_pincer"},
			{"time": 170.0, "message": "夏侯恩率队封锁侧翼", "elite": "xiahou_en"},
			{"time": 306.0, "message": "弓手增援：先压制后排火力", "formation": "archer_screen"},
			{"time": 340.0, "message": "淳于导率亲卫压阵", "elite": "chunyu_dao"},
		],
	},
	5: {
		"id": "story_05",
		"title": "当阳断后",
		"intro": "第五章：当阳断后，掩护队伍穿过狭路",
		"completion": "第五章完成，主力已经脱离当阳追兵。",
		"duration": 540.0,
		"phases": [
			{"until": 180.0, "threat": 2, "profile": {"interval": 0.52, "soft_capacity": 34, "hard_capacity": 46, "burst": 2}, "enemies": [{"id": "shield", "weight": 28}, {"id": "spear", "weight": 30}, {"id": "halberd", "weight": 22}, {"id": "archer", "weight": 20}]},
			{"until": 360.0, "threat": 2, "profile": {"interval": 0.44, "soft_capacity": 44, "hard_capacity": 58, "burst": 3}, "enemies": [{"id": "shield", "weight": 20}, {"id": "spear", "weight": 24}, {"id": "halberd", "weight": 23}, {"id": "archer", "weight": 20}, {"id": "crossbow", "weight": 13}, {"id": "cavalry", "weight": 10}]},
			{"until": 540.0, "threat": 3, "profile": {"interval": 0.38, "soft_capacity": 52, "hard_capacity": 68, "burst": 3}, "enemies": [{"id": "shield", "weight": 18}, {"id": "spear", "weight": 20}, {"id": "halberd", "weight": 24}, {"id": "archer", "weight": 20}, {"id": "crossbow", "weight": 18}, {"id": "cavalry", "weight": 18}]},
		],
		"events": [
			{"time": 180.0, "message": "弩矢平射：横移脱离火线", "formation": "crossbow_screen"},
			{"time": 190.0, "message": "夏侯恩率亲卫突入阵中", "elite": "xiahou_en"},
			{"time": 300.0, "message": "轻骑突袭：及时避开水平冲锋", "formation": "cavalry_pair"},
			{"time": 390.0, "message": "枪弩协同：优先拆开后排弩手", "formation": "crossbow_screen"},
			{"time": 410.0, "message": "淳于导死守退路", "elite": "chunyu_dao"},
		],
	},
}
const ARCHER_INTRO_TIME := 35.0
const SHIELD_BOW_TIME := 80.0
const CROSSBOW_INTRO_TIME := 102.0
const PINCER_TIME := 130.0
const CAVALRY_INTRO_TIME := 138.0
const SPEAR_WALL_TIME := 148.0
const XIAHOU_EN_TIME := 180.0
const CHUNYU_DAO_TIME := 360.0
const BOSS_TIME := 510.0
const ENDLESS_FIRST_BOSS_TIME := 420.0
const BOWANG_XIAHOU_LAN_TIME := 180.0
const BOWANG_HAN_HAO_TIME := 360.0
const BOWANG_BOSS_TIME := 510.0
const OFFSCREEN_SPAWN_MIN_DISTANCE := 350.0
const OFFSCREEN_SPAWN_MAX_DISTANCE := 500.0
const MOBILE_DENSITY_SCALE := 1.15
const DESKTOP_DENSITY_SCALE := 1.28
const MAX_SPAWN_HARD_CAP := 116

var bounds := Rect2(0, 0, 1920, 860)
var elapsed := 0.0
var experience := 0
var level := 1
var next_level_experience := 8
var experience_requirement_multiplier := 1.0
var spawn_accumulator := 0.0
var boss_spawned := false
var endless_boss_sequence: Array[String] = []
var endless_boss_index := -1
var xiahou_en_spawned := false
var chunyu_dao_spawned := false
var shield_bow_deployed := false
var crossbow_screen_deployed := false
var pincer_deployed := false
var cavalry_scouts_deployed := false
var spear_wall_deployed := false
var stage_index := 0
var rng := RandomNumberGenerator.new()
var spawn_focus := Vector2.ZERO
var mode := "story"
var duration := STORY_DURATION
var story_chapter := 1
var active_threat_tier := 0
var boss_trial_stage := 0
var battlefield_id := "changban"
var xiahou_lan_spawned := false
var han_hao_spawned := false
var density_scale := 1.0
var spawn_suppressed := false

func configure_performance_profile(is_mobile_device: bool) -> void:
	# Keep editor/tests at the original density until the runtime profile is selected.
	density_scale = MOBILE_DENSITY_SCALE if is_mobile_device else DESKTOP_DENSITY_SCALE

func configure_account_progress(profile: Dictionary) -> void:
	var effects := MILITARY_STRATEGY.effects_for_profile(profile)
	experience_requirement_multiplier = clampf(float(effects.get("experience_requirement_multiplier", 1.0)), 0.05, 1.0)

func set_spawn_suppressed(value: bool) -> void:
	spawn_suppressed = value

func reset(world_bounds: Rect2, selected_mode: String = "story", selected_battlefield_id: String = "changban", selected_story_chapter: int = 1) -> void:
	bounds = world_bounds
	mode = selected_mode
	battlefield_id = selected_battlefield_id if selected_battlefield_id in ["changban", "xinye", "bowangpo", "bowangpo_story", "huoshaoxinye", "xiangyangchetui", "dangyangduanhou", "hulao"] else "changban"
	story_chapter = clampi(selected_story_chapter, 1, STORY_CHAPTERS.size())
	duration = ENDLESS_DURATION if mode == "endless" else (STORY_DURATION if is_boss_trial() or is_bowangpo() else _story_duration())
	elapsed = 0.0
	experience = 0
	level = 1
	next_level_experience = _experience_requirement(EXPERIENCE_BASE_REQUIREMENT, level)
	if is_boss_trial():
		level = BOSS_TRIAL_START_LEVEL
		next_level_experience = _experience_requirement(EXPERIENCE_BASE_REQUIREMENT, level)
	spawn_accumulator = 0.0
	spawn_suppressed = false
	boss_spawned = false
	rng.randomize()
	endless_boss_sequence.clear()
	if mode == "endless":
		endless_boss_sequence.append("xiahou_dun")
		endless_boss_sequence.append("lvbu" if rng.randf() < 0.5 else "zhang_he")
	endless_boss_index = 0 if mode == "endless" else -1
	xiahou_en_spawned = false
	chunyu_dao_spawned = false
	xiahou_lan_spawned = false
	han_hao_spawned = false
	shield_bow_deployed = false
	crossbow_screen_deployed = false
	pincer_deployed = false
	cavalry_scouts_deployed = false
	spear_wall_deployed = false
	stage_index = 0
	spawn_focus = bounds.get_center()
	active_threat_tier = threat_tier()
	boss_trial_stage = 0
	if is_boss_trial():
		stage_changed.emit("名将斗阵：战前整备")
	elif _uses_story_chapter_schedule():
		stage_changed.emit(str(_story_chapter_definition().get("intro", "乱军初起：击破刀兵")))
	else:
		stage_changed.emit("无尽兵海：守住阵线" if mode == "endless" else ("火谷前哨：曹军列阵而来" if is_bowangpo() else "乱军初起：击破刀兵"))

func tick(delta: float, active_enemy_count: int, player_position: Vector2 = Vector2.INF) -> void:
	if player_position.is_finite():
		spawn_focus = player_position
	elapsed += delta
	_update_threat_tier()
	if is_boss_trial():
		return
	_advance_encounter_events()
	if spawn_suppressed:
		return
	spawn_accumulator += delta
	var profile := _spawn_profile()
	var soft_capacity := int(profile.soft_capacity)
	var hard_capacity := int(profile.hard_capacity)
	if active_enemy_count >= hard_capacity:
		return
	var spawn_interval := float(profile.interval)
	var burst := int(profile.burst)
	if active_enemy_count >= soft_capacity:
		spawn_interval *= 2.4
		burst = 1
	if spawn_accumulator < spawn_interval:
		return
	spawn_accumulator = fmod(spawn_accumulator, spawn_interval)
	var burst_count := mini(burst, hard_capacity - active_enemy_count)
	for _index in range(maxi(0, burst_count)):
		spawn_requested.emit(_choose_enemy(), _choose_spawn())

func add_experience(value: int) -> void:
	experience += value
	while experience >= next_level_experience:
		experience -= next_level_experience
		level += 1
		next_level_experience = _experience_requirement(EXPERIENCE_BASE_REQUIREMENT, level)
		level_up.emit(level)

func grant_levels(count: int) -> void:
	for _index in range(maxi(0, count)):
		level += 1
		next_level_experience = _experience_requirement(EXPERIENCE_BASE_REQUIREMENT, level)
		level_up.emit(level)

func _experience_requirement(base_requirement: float, target_level: int) -> int:
	var scaled_requirement := base_requirement * pow(EXPERIENCE_GROWTH_RATE, target_level - 1) * experience_requirement_multiplier
	return clampi(ceili(scaled_requirement), 1, MAX_EXPERIENCE_REQUIREMENT)

func progress() -> float:
	return float(experience) / maxf(1.0, float(next_level_experience))

func remaining_time() -> float:
	return maxf(0.0, duration - elapsed)

func is_time_over() -> bool:
	if is_boss_trial():
		return false
	return elapsed >= duration

func threat_tier() -> int:
	if is_boss_trial():
		return 3
	if mode == "endless":
		return mini(7, int(elapsed / 120.0))
	if _uses_story_chapter_schedule():
		return int(_story_phase().get("threat", 0))
	return mini(4, int(elapsed / 120.0))

func difficulty_multiplier() -> float:
	# Chapters open below their target threat, then build toward a stronger
	# finale. The smooth curve avoids a sharp difficulty wall at phase changes.
	if is_boss_trial():
		return 1.0
	var progress := clampf(elapsed / maxf(1.0, duration), 0.0, 1.0)
	var warmup_end := 0.58 if mode == "story" else 0.34
	var ramp_progress := clampf(progress / warmup_end, 0.0, 1.0)
	ramp_progress = ramp_progress * ramp_progress * (3.0 - 2.0 * ramp_progress)
	var multiplier := lerpf(0.80, 1.0, ramp_progress)
	if progress > warmup_end:
		var finale_progress := clampf((progress - warmup_end) / maxf(0.01, 1.0 - warmup_end), 0.0, 1.0)
		finale_progress = finale_progress * finale_progress * (3.0 - 2.0 * finale_progress)
		multiplier = lerpf(1.0, 1.12 if mode == "story" else 1.08, finale_progress)
	return multiplier

func is_boss_trial() -> bool:
	return mode == BOSS_TRIAL_MODE

func is_bowangpo() -> bool:
	return battlefield_id == "bowangpo" and not is_boss_trial()

func _uses_story_chapter_schedule() -> bool:
	return mode == "story" and not is_bowangpo()

func story_chapter_id() -> String:
	return str(_story_chapter_definition().get("id", "story_01"))

func story_chapter_title() -> String:
	return str(_story_chapter_definition().get("title", "当阳断后"))

func story_completion_message() -> String:
	if is_bowangpo():
		return "博望坡火谷突围成功！"
	return str(_story_chapter_definition().get("completion", "当阳退路已经稳住。"))

func story_requires_boss_defeat() -> bool:
	if is_bowangpo():
		return true
	return bool(_story_chapter_definition().get("requires_boss", false))

func boss_archetype_id() -> String:
	if is_boss_trial():
		match boss_trial_stage:
			3: return "xiahou_dun"
			5: return "lvbu"
			_: return "zhang_he"
	if mode == "endless" and endless_boss_index >= 0 and endless_boss_index < endless_boss_sequence.size():
		return endless_boss_sequence[endless_boss_index]
	if is_bowangpo() or (mode == "story" and story_chapter == 2):
		return "xiahou_dun"
	return "zhang_he"

func advance_boss_after_defeat() -> bool:
	# Bosses are swapped only after the previous death animation has completed.
	# The caller can then use the regular boss_requested path to activate the next
	# archetype without creating a second BossActor.
	if is_boss_trial() and boss_trial_stage == 3:
		boss_trial_stage = 4
		boss_spawned = true
		boss_requested.emit(bounds.get_center())
		stage_changed.emit("夏侯惇败退：第四试炼，张郃现身")
		return true
	if is_boss_trial() and boss_trial_stage == 4:
		boss_trial_stage = 5
		boss_spawned = true
		boss_requested.emit(bounds.get_center())
		stage_changed.emit("张郃败退：最终试炼，吕布现身")
		return true
	if mode == "endless" and endless_boss_index + 1 < endless_boss_sequence.size():
		endless_boss_index += 1
		boss_spawned = true
		boss_requested.emit(bounds.get_center())
		stage_changed.emit("前任领主败退：领主%s加入战场" % ("吕布" if boss_archetype_id() == "lvbu" else "张郃"))
		return true
	return false

func begin_boss_trial() -> void:
	if not is_boss_trial() or boss_trial_stage != 0:
		return
	# The trial is currently a focused Lv Bu combat sandbox. Other named enemies
	# remain available in story and endless modes while this encounter is tuned.
	boss_trial_stage = 5
	boss_spawned = true
	boss_requested.emit(bounds.get_center())
	stage_changed.emit("名将斗阵：吕布现身")

func advance_boss_trial_after_elite() -> void:
	if not is_boss_trial():
		return
	if boss_trial_stage == 1:
		boss_trial_stage = 2
		elite_requested.emit("chunyu_dao", bounds.get_center())
		stage_changed.emit("第二试炼：淳于导")
		return
	if boss_trial_stage == 2:
		boss_trial_stage = 3
		boss_spawned = true
		boss_requested.emit(bounds.get_center())
		stage_changed.emit("第三试炼：夏侯惇")

func _update_threat_tier() -> void:
	var next_tier := threat_tier()
	if next_tier == active_threat_tier:
		return
	active_threat_tier = next_tier
	threat_tier_changed.emit(active_threat_tier)

func _story_chapter_definition() -> Dictionary:
	return STORY_CHAPTERS.get(story_chapter, STORY_CHAPTERS[1]) as Dictionary

func _story_duration() -> float:
	return float(_story_chapter_definition().get("duration", STORY_DURATION))

func _story_phase() -> Dictionary:
	var phases: Array = _story_chapter_definition().get("phases", []) as Array
	for phase_variant in phases:
		var phase := phase_variant as Dictionary
		if elapsed < float(phase.get("until", duration)):
			return phase
	return phases.back() as Dictionary if not phases.is_empty() else {}

func _choose_story_enemy() -> int:
	var entries: Array = _story_phase().get("enemies", []) as Array
	var total_weight := 0.0
	for entry_variant in entries:
		total_weight += float((entry_variant as Dictionary).get("weight", 0.0))
	if total_weight <= 0.0:
		return EnemySimulation.EnemyType.SWORD
	var roll := rng.randf_range(0.0, total_weight)
	for entry_variant in entries:
		var entry := entry_variant as Dictionary
		roll -= float(entry.get("weight", 0.0))
		if roll <= 0.0:
			return _enemy_type_from_story_id(str(entry.get("id", "sword")))
	return _enemy_type_from_story_id(str((entries.back() as Dictionary).get("id", "sword")))

func _story_spawn_profile() -> Dictionary:
	var profile: Dictionary = _story_phase().get("profile", {}) as Dictionary
	var adjusted_profile := {
		"interval": float(profile.get("interval", 0.60)),
		"soft_capacity": int(profile.get("soft_capacity", 24)),
		"hard_capacity": int(profile.get("hard_capacity", 34)),
		"burst": int(profile.get("burst", 2)),
	}
	# Bring the pressure curve forward so the first half of a story battle is
	# populated, while the later phases retain their authored progression.
	if elapsed < duration * 0.62:
		adjusted_profile["interval"] = maxf(0.28, float(adjusted_profile["interval"]) * 0.88)
		adjusted_profile["soft_capacity"] = ceili(float(adjusted_profile["soft_capacity"]) * 1.16)
		adjusted_profile["hard_capacity"] = ceili(float(adjusted_profile["hard_capacity"]) * 1.16)
	return _scale_spawn_profile(adjusted_profile)

func _enemy_type_from_story_id(enemy_id: String) -> int:
	match enemy_id:
		"shield": return EnemySimulation.EnemyType.SHIELD
		"spear": return EnemySimulation.EnemyType.SPEAR
		"halberd": return EnemySimulation.EnemyType.HALBERD
		"archer": return EnemySimulation.EnemyType.ARCHER
		"crossbow": return EnemySimulation.EnemyType.CROSSBOW
		# 军旗兵暂未开放；旧关卡配置中的 banner 条目改由剑兵替代。
		"banner": return EnemySimulation.EnemyType.SWORD
		"cavalry": return EnemySimulation.EnemyType.CAVALRY
		"guard": return EnemySimulation.EnemyType.GUARD
		_: return EnemySimulation.EnemyType.SWORD

func _advance_story_encounter_events() -> void:
	var events: Array = _story_chapter_definition().get("events", []) as Array
	while stage_index < events.size():
		var event := events[stage_index] as Dictionary
		if elapsed < float(event.get("time", duration)):
			return
		stage_index += 1
		var formation := str(event.get("formation", ""))
		if not formation.is_empty():
			_deploy_story_formation(formation)
		var elite_id := str(event.get("elite", ""))
		if not elite_id.is_empty():
			elite_requested.emit(elite_id, _north_spawn())
		if bool(event.get("boss", false)) and not boss_spawned:
			boss_spawned = true
			boss_requested.emit(Vector2(bounds.get_center().x, bounds.position.y + 90.0))
		var message := str(event.get("message", ""))
		if not message.is_empty():
			stage_changed.emit(message)

func _deploy_story_formation(formation: String) -> void:
	match formation:
		"shield_line":
			_deploy_story_shield_line()
		"spear_wall":
			_deploy_spear_wall()
		"archer_screen":
			_deploy_story_archer_screen()
		"crossbow_screen":
			_deploy_crossbow_screen()
		"halberd_pincer":
			_deploy_halberd_pincer()
		"cavalry_pair":
			_deploy_cavalry_scouts()

func _deploy_story_shield_line() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-96.0, 96.0), bounds.position.y + 96.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front + Vector2(-38.0, 0.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front + Vector2(38.0, 0.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SWORD, front + Vector2(0.0, -34.0))

func _deploy_story_archer_screen() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-88.0, 88.0), bounds.position.y + 110.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front)
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(-54.0, -42.0))
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(54.0, -42.0))

func _choose_enemy() -> int:
	if mode == "endless":
		var tier := int(elapsed / 120.0)
		var roll := rng.randf()
		var cavalry_chance := 0.0
		if tier >= 4:
			cavalry_chance = 0.24 if tier >= 6 else 0.20
		if roll < cavalry_chance:
			return EnemySimulation.EnemyType.CAVALRY
		# Reallocate only the weak sword share as cavalry becomes common, leaving
		# the rest of the endless roster's combat roles intact.
		var cavalry_shift := maxf(0.0, cavalry_chance - 0.15)
		if tier >= 3 and roll < 0.30 + cavalry_shift:
			return EnemySimulation.EnemyType.CROSSBOW
		if tier >= 5 and roll < 0.38 + cavalry_shift:
			return EnemySimulation.EnemyType.GUARD
		if tier >= 3 and roll < 0.54 + cavalry_shift:
			return EnemySimulation.EnemyType.HALBERD
		if tier >= 2 and roll < 0.68 + cavalry_shift:
			return EnemySimulation.EnemyType.SHIELD
		if tier >= 2 and roll < 0.80 + cavalry_shift:
			return EnemySimulation.EnemyType.SPEAR
		if tier >= 1 and roll < minf(1.0, 0.91 + cavalry_shift):
			return EnemySimulation.EnemyType.ARCHER
		return EnemySimulation.EnemyType.SWORD
	if _uses_story_chapter_schedule():
		return _choose_story_enemy()
	if is_bowangpo():
		return _choose_bowang_enemy()
	if boss_spawned:
		var boss_roll := rng.randf()
		if boss_roll < 0.18:
			return EnemySimulation.EnemyType.CAVALRY
		if boss_roll < 0.24:
			return EnemySimulation.EnemyType.CROSSBOW
		if boss_roll < 0.42:
			return EnemySimulation.EnemyType.SPEAR
		if boss_roll < 0.62:
			return EnemySimulation.EnemyType.HALBERD
		if boss_roll < 0.78:
			return EnemySimulation.EnemyType.SHIELD
		if boss_roll < 0.92:
			return EnemySimulation.EnemyType.ARCHER
		return EnemySimulation.EnemyType.SWORD
	if elapsed < ARCHER_INTRO_TIME:
		return EnemySimulation.EnemyType.SWORD
	if elapsed < SHIELD_BOW_TIME:
		return EnemySimulation.EnemyType.ARCHER if rng.randf() < 0.28 else EnemySimulation.EnemyType.SWORD
	if elapsed < CROSSBOW_INTRO_TIME:
		var shield_bow_roll := rng.randf()
		return EnemySimulation.EnemyType.SHIELD if shield_bow_roll < 0.28 else (EnemySimulation.EnemyType.ARCHER if shield_bow_roll < 0.58 else EnemySimulation.EnemyType.SWORD)
	if elapsed < PINCER_TIME:
		var roll := rng.randf()
		if roll < 0.26:
			return EnemySimulation.EnemyType.CROSSBOW
		return EnemySimulation.EnemyType.SHIELD if roll < 0.50 else (EnemySimulation.EnemyType.ARCHER if roll < 0.70 else EnemySimulation.EnemyType.SWORD)
	var pincer_roll := rng.randf()
	if elapsed >= CAVALRY_INTRO_TIME and pincer_roll < 0.18:
		return EnemySimulation.EnemyType.CAVALRY
	if elapsed >= SPEAR_WALL_TIME and pincer_roll < 0.38:
		return EnemySimulation.EnemyType.SPEAR
	if elapsed >= CROSSBOW_INTRO_TIME and pincer_roll < 0.54:
		return EnemySimulation.EnemyType.CROSSBOW
	return EnemySimulation.EnemyType.HALBERD if pincer_roll < 0.74 else (EnemySimulation.EnemyType.SHIELD if pincer_roll < 0.90 else EnemySimulation.EnemyType.SWORD)

func _choose_bowang_enemy() -> int:
	var roll := rng.randf()
	if boss_spawned:
		if roll < 0.18:
			return EnemySimulation.EnemyType.CAVALRY
		if roll < 0.30:
			return EnemySimulation.EnemyType.CROSSBOW
		if roll < 0.52:
			return EnemySimulation.EnemyType.SPEAR
		if roll < 0.70:
			return EnemySimulation.EnemyType.SHIELD
		return EnemySimulation.EnemyType.SWORD
	if elapsed < 42.0:
		return EnemySimulation.EnemyType.SPEAR if roll < 0.56 else EnemySimulation.EnemyType.SWORD
	if elapsed < 96.0:
		return EnemySimulation.EnemyType.SHIELD if roll < 0.28 else (EnemySimulation.EnemyType.SPEAR if roll < 0.70 else EnemySimulation.EnemyType.CROSSBOW)
	if elapsed < BOWANG_HAN_HAO_TIME:
		if roll < 0.35:
			return EnemySimulation.EnemyType.CROSSBOW
		if roll < 0.70:
			return EnemySimulation.EnemyType.SPEAR
		return EnemySimulation.EnemyType.SHIELD
	if roll < 0.15:
		return EnemySimulation.EnemyType.CAVALRY
	if roll < 0.44:
		return EnemySimulation.EnemyType.CROSSBOW
	if roll < 0.70:
		return EnemySimulation.EnemyType.SPEAR
	return EnemySimulation.EnemyType.SHIELD if roll < 0.88 else EnemySimulation.EnemyType.SWORD

func _spawn_profile() -> Dictionary:
	if mode == "endless":
		var tier := int(elapsed / 120.0)
		return _scale_spawn_profile({"interval": maxf(0.22, 0.58 - 0.05 * tier), "soft_capacity": mini(70, 32 + tier * 8), "hard_capacity": mini(88, 48 + tier * 10), "burst": mini(4, 2 + tier / 3)})
	if _uses_story_chapter_schedule():
		return _story_spawn_profile()
	if boss_spawned:
		return _scale_spawn_profile({"interval": 0.44, "soft_capacity": 28, "hard_capacity": 38, "burst": 2})
	if is_bowangpo():
		if elapsed < 96.0:
			return _scale_spawn_profile({"interval": 0.48, "soft_capacity": 34, "hard_capacity": 46, "burst": 2})
		if elapsed < BOWANG_HAN_HAO_TIME:
			return _scale_spawn_profile({"interval": 0.36, "soft_capacity": 48, "hard_capacity": 64, "burst": 3})
		return _scale_spawn_profile({"interval": 0.32, "soft_capacity": 58, "hard_capacity": 76, "burst": 3})
	if elapsed < ARCHER_INTRO_TIME:
		return _scale_spawn_profile({"interval": 0.56, "soft_capacity": 24, "hard_capacity": 34, "burst": 2})
	if elapsed < SHIELD_BOW_TIME:
		return _scale_spawn_profile({"interval": 0.43, "soft_capacity": 35, "hard_capacity": 46, "burst": 2})
	if elapsed < PINCER_TIME:
		return _scale_spawn_profile({"interval": 0.38, "soft_capacity": 46, "hard_capacity": 60, "burst": 2})
	return _scale_spawn_profile({"interval": 0.30, "soft_capacity": 60, "hard_capacity": 78, "burst": 3})

func _scale_spawn_profile(profile: Dictionary) -> Dictionary:
	var base_soft := maxi(1, int(profile.get("soft_capacity", 24)))
	var base_hard := maxi(base_soft + 1, int(profile.get("hard_capacity", 34)))
	var pressure := difficulty_multiplier()
	var level_density := _level_density_multiplier()
	var scaled_soft := maxi(6, ceili(float(base_soft) * pressure * density_scale * level_density))
	var scaled_hard := maxi(scaled_soft + 1, ceili(float(base_hard) * pressure * density_scale * level_density))
	var base_interval := float(profile.get("interval", 0.60))
	var scaled_burst := maxi(1, int(floor(float(profile.get("burst", 2)) * pressure)))
	return {
		"interval": maxf(0.22, base_interval / maxf(0.5, pressure)),
		"soft_capacity": scaled_soft,
		"hard_capacity": mini(MAX_SPAWN_HARD_CAP, scaled_hard),
		"burst": scaled_burst,
	}

func _level_density_multiplier() -> float:
	# Once the player reaches level 3, the battlefield gradually fills out.
	# Capacity grows in steps so the early game remains readable on mobile.
	match level:
		0, 1, 2: return 1.0
		3: return 1.20
		4: return 1.27
		5: return 1.35
		6: return 1.40
		7: return 1.45
		_: return 1.50

func _advance_encounter_events() -> void:
	if is_boss_trial():
		return
	if mode == "endless":
		_advance_endless_encounter_events()
	if _uses_story_chapter_schedule():
		_advance_story_encounter_events()
		return
	if is_bowangpo():
		_advance_bowangpo_encounter_events()
		return
	if stage_index == 0 and elapsed >= ARCHER_INTRO_TIME:
		stage_index = 1
		stage_changed.emit("乱箭逼近：注意黄色落点")
	if stage_index == 1 and elapsed >= SHIELD_BOW_TIME:
		stage_index = 2
		stage_changed.emit("拒阵：盾弓阵推进")
	if not shield_bow_deployed and elapsed >= SHIELD_BOW_TIME + 5.0:
		shield_bow_deployed = true
		_deploy_shield_bow()
	if stage_index == 2 and elapsed >= CROSSBOW_INTRO_TIME:
		stage_index = 3
		stage_changed.emit("弩矢平射：横移脱离火线")
	if not crossbow_screen_deployed and elapsed >= CROSSBOW_INTRO_TIME + 3.0:
		crossbow_screen_deployed = true
		_deploy_crossbow_screen()
	if stage_index == 3 and elapsed >= PINCER_TIME:
		stage_index = 4
		stage_changed.emit("戟卫夹击：选择突破方向")
	if not pincer_deployed and elapsed >= PINCER_TIME + 3.0:
		pincer_deployed = true
		_deploy_halberd_pincer()
	if stage_index == 4 and elapsed >= CAVALRY_INTRO_TIME:
		stage_index = 5
		stage_changed.emit("轻骑试探：迎击水平冲锋")
	if not cavalry_scouts_deployed and elapsed >= CAVALRY_INTRO_TIME + 2.0:
		cavalry_scouts_deployed = true
		_deploy_cavalry_scouts()
	if not spear_wall_deployed and elapsed >= SPEAR_WALL_TIME:
		spear_wall_deployed = true
		_deploy_spear_wall()
		stage_changed.emit("枪阵推进：注意长刺与横向封锁")
	if mode != "endless" and not xiahou_en_spawned and elapsed >= XIAHOU_EN_TIME:
		xiahou_en_spawned = true
		elite_requested.emit("xiahou_en", _north_spawn())
		stage_changed.emit("夏侯恩持偃月刀拦路")
	if mode != "endless" and not chunyu_dao_spawned and elapsed >= CHUNYU_DAO_TIME:
		chunyu_dao_spawned = true
		elite_requested.emit("chunyu_dao", _north_spawn() + Vector2(92.0, 34.0))
		stage_changed.emit("淳于导提刀压阵")
	if mode != "endless" and not boss_spawned and elapsed >= BOSS_TIME:
		boss_spawned = true
		boss_requested.emit(Vector2(bounds.get_center().x, bounds.position.y + 90.0))
		stage_changed.emit("敌将现身：张郃")

func _advance_endless_encounter_events() -> void:
	if boss_spawned or elapsed < ENDLESS_FIRST_BOSS_TIME or endless_boss_sequence.is_empty():
		return
	boss_spawned = true
	endless_boss_index = 0
	boss_requested.emit(Vector2(bounds.get_center().x, bounds.position.y + 90.0))
	stage_changed.emit("无尽领主现身：夏侯惇")

func _advance_bowangpo_encounter_events() -> void:
	if stage_index == 0 and elapsed >= 34.0:
		stage_index = 1
		stage_changed.emit("枪阵先登：横移避开长刺")
	if not spear_wall_deployed and elapsed >= 38.0:
		spear_wall_deployed = true
		_deploy_spear_wall()
	if stage_index == 1 and elapsed >= 72.0:
		stage_index = 2
		stage_changed.emit("弩手列阵：先拆后排火力")
	if not crossbow_screen_deployed and elapsed >= 76.0:
		crossbow_screen_deployed = true
		_deploy_crossbow_screen()
	if mode != "endless" and not xiahou_lan_spawned and elapsed >= BOWANG_XIAHOU_LAN_TIME:
		xiahou_lan_spawned = true
		elite_requested.emit("xiahou_lan", _north_spawn())
		stage_changed.emit("夏侯兰率斥候迎战")
	if mode != "endless" and not han_hao_spawned and elapsed >= BOWANG_HAN_HAO_TIME:
		han_hao_spawned = true
		elite_requested.emit("han_hao", _north_spawn() + Vector2(-88.0, 30.0))
		stage_changed.emit("韩浩举盾前压")
	if stage_index == 2 and elapsed >= 382.0:
		stage_index = 3
		stage_changed.emit("火谷起势：为督军来袭留出退路")
	if not cavalry_scouts_deployed and elapsed >= 390.0:
		cavalry_scouts_deployed = true
		_deploy_cavalry_scouts()
	if mode != "endless" and not boss_spawned and elapsed >= BOWANG_BOSS_TIME:
		boss_spawned = true
		boss_requested.emit(Vector2(bounds.get_center().x, bounds.position.y + 92.0))
		stage_changed.emit("敌将现身：夏侯惇")

func _deploy_shield_bow() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-110.0, 110.0), bounds.position.y + 95.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front)
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(-62.0, -38.0))
	spawn_requested.emit(EnemySimulation.EnemyType.ARCHER, front + Vector2(62.0, -38.0))

func _deploy_crossbow_screen() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-96.0, 96.0), bounds.position.y + 110.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SHIELD, front)
	spawn_requested.emit(EnemySimulation.EnemyType.CROSSBOW, front + Vector2(-54.0, -42.0))
	spawn_requested.emit(EnemySimulation.EnemyType.CROSSBOW, front + Vector2(54.0, -42.0))

func _deploy_halberd_pincer() -> void:
	var center_y := bounds.get_center().y
	spawn_requested.emit(EnemySimulation.EnemyType.HALBERD, Vector2(bounds.position.x + 24.0, center_y - 64.0))
	spawn_requested.emit(EnemySimulation.EnemyType.HALBERD, Vector2(bounds.end.x - 24.0, center_y + 64.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SWORD, Vector2(bounds.get_center().x - 38.0, bounds.position.y + 50.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SWORD, Vector2(bounds.get_center().x + 38.0, bounds.position.y + 50.0))

func _deploy_cavalry_scouts() -> void:
	var center_y := bounds.get_center().y
	spawn_requested.emit(EnemySimulation.EnemyType.CAVALRY, Vector2(bounds.position.x + 26.0, center_y - 72.0))
	spawn_requested.emit(EnemySimulation.EnemyType.CAVALRY, Vector2(bounds.end.x - 26.0, center_y + 72.0))

func _deploy_spear_wall() -> void:
	var front := Vector2(bounds.get_center().x + rng.randf_range(-110.0, 110.0), bounds.position.y + 112.0)
	spawn_requested.emit(EnemySimulation.EnemyType.SPEAR, front + Vector2(0.0, -34.0))
	spawn_requested.emit(EnemySimulation.EnemyType.SPEAR, front)
	spawn_requested.emit(EnemySimulation.EnemyType.SPEAR, front + Vector2(0.0, 34.0))

func _choose_spawn() -> Vector2:
	var spawn_area := bounds.grow(-24.0)
	for attempt in range(8):
		var direction := Vector2.from_angle(rng.randf_range(0.0, TAU))
		var distance := rng.randf_range(OFFSCREEN_SPAWN_MIN_DISTANCE, OFFSCREEN_SPAWN_MAX_DISTANCE)
		var candidate := spawn_focus + direction * distance
		if spawn_area.has_point(candidate):
			return candidate
	return _choose_edge_spawn()

func _choose_edge_spawn() -> Vector2:
	var edge := rng.randi_range(0, 3)
	match edge:
		0: return _north_spawn()
		1: return Vector2(bounds.position.x + 12.0, rng.randf_range(bounds.position.y + 40.0, bounds.end.y - 70.0))
		2: return Vector2(bounds.end.x - 12.0, rng.randf_range(bounds.position.y + 40.0, bounds.end.y - 70.0))
		_: return Vector2(rng.randf_range(bounds.position.x + 80.0, bounds.end.x - 80.0), bounds.end.y - 12.0)

func _north_spawn() -> Vector2:
	return Vector2(rng.randf_range(bounds.position.x + 80.0, bounds.end.x - 80.0), bounds.position.y + 14.0)
