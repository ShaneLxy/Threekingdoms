class_name BattleSoulSystem
extends Node

# 战魂是低频的战场临时事件：不参与经验包的合并和自动吸附，玩家必须主动
# 走到阵亡敌军的位置接触拾取。这样既保留随机惊喜，也不打断割草节奏。
signal soul_spawned(soul_id: String, at: Vector2)
signal soul_collected(soul_id: String, title: String, description: String, duration: float)
signal soul_expired(soul_id: String, at: Vector2)

const DROP_INTERVAL := 35.0
const BUFF_DURATION := 20.0
const GROUND_LIFETIME := 20.0
const PICKUP_DISTANCE := 30.0
const CORPSE_MEMORY_DURATION := 48.0
const CORPSE_SEARCH_RADIUS := 520.0
const CORPSE_MIN_DROP_DISTANCE := 84.0
const MAX_REMEMBERED_CORPSES := 72
const PROC_COOLDOWN := 0.68

const SOUL_IDS: Array[String] = ["gale", "thunder", "flame", "iron", "machine"]

var drops: Array[Dictionary] = []
var recent_corpses: Array[Dictionary] = []
var drop_remaining := DROP_INTERVAL
var drop_interval := DROP_INTERVAL
var buff_duration := BUFF_DURATION
var soul_ranks: Dictionary = {}
var proc_cooldowns: Dictionary = {}

func configure_profile(profile: Dictionary) -> void:
	var effects := SoulResonance.effects_for(profile)
	drop_interval = float(effects.drop_interval)
	buff_duration = float(effects.buff_duration)
	soul_ranks = (profile.get("battle_soul_armory", {}) as Dictionary).duplicate(true)

func profile_effects() -> Dictionary:
	return {"drop_interval": drop_interval, "buff_duration": buff_duration}

func reset() -> void:
	drops.clear()
	recent_corpses.clear()
	proc_cooldowns.clear()
	drop_remaining = drop_interval

func record_enemy_corpse(at: Vector2) -> void:
	if not at.is_finite():
		return
	recent_corpses.append({"position": at, "remaining": CORPSE_MEMORY_DURATION})
	if recent_corpses.size() > MAX_REMEMBERED_CORPSES:
		recent_corpses.remove_at(0)

func tick(delta: float, player_position: Vector2) -> void:
	for index in range(recent_corpses.size() - 1, -1, -1):
		var corpse: Dictionary = recent_corpses[index]
		corpse["remaining"] = maxf(0.0, float(corpse.get("remaining", 0.0)) - delta)
		if float(corpse.get("remaining", 0.0)) <= 0.0:
			recent_corpses.remove_at(index)
		else:
			recent_corpses[index] = corpse
	for soul_id_value in proc_cooldowns.keys():
		var soul_id := str(soul_id_value)
		proc_cooldowns[soul_id] = maxf(0.0, float(proc_cooldowns.get(soul_id, 0.0)) - delta)
	drop_remaining = maxf(0.0, drop_remaining - delta)
	if drop_remaining <= 0.0:
		# If the player happens to clear the whole field at the exact interval,
		# retry shortly rather than creating a reward at an arbitrary position.
		drop_remaining = drop_interval if _try_spawn_at_nearby_corpse(player_position) else 2.0
	for index in range(drops.size() - 1, -1, -1):
		var drop: Dictionary = drops[index]
		drop["remaining"] = maxf(0.0, float(drop.get("remaining", 0.0)) - delta)
		var at: Vector2 = drop.get("position", Vector2.ZERO)
		if player_position.distance_squared_to(at) <= PICKUP_DISTANCE * PICKUP_DISTANCE:
			var soul_id := str(drop.get("id", "gale"))
			var armory_id := _armory_id_for(soul_id)
			var rank := clampi(int(soul_ranks.get(armory_id, 0)), 0, BattleSoulArmory.max_rank_for(armory_id))
			soul_collected.emit(soul_id, title_for(soul_id), description_for(soul_id, rank), buff_duration)
			drops.remove_at(index)
			continue
		if float(drop.get("remaining", 0.0)) <= 0.0:
			soul_expired.emit(str(drop.get("id", "gale")), at)
			drops.remove_at(index)
			continue
		drops[index] = drop

func has_proc_ready(soul_id: String) -> bool:
	return float(proc_cooldowns.get(soul_id, 0.0)) <= 0.0

func consume_proc(soul_id: String) -> void:
	proc_cooldowns[soul_id] = PROC_COOLDOWN

func build_proc_requests(hero: HeroActor, source_request: AttackRequest, hit_count: int, target_positions: Array[Vector2]) -> Array[Dictionary]:
	var procs: Array[Dictionary] = []
	if hero == null or hit_count <= 0 or source_request.label.begins_with("战魂·"):
		return procs
	var target := _proc_target_for(source_request, target_positions)
	if hero.has_battle_soul("thunder") and has_proc_ready("thunder"):
		consume_proc("thunder")
		var chain_targets := target_positions.slice(0, mini(hero.battle_soul_thunder_chain_count(), target_positions.size()))
		if chain_targets.is_empty():
			chain_targets.append(target)
		for chain_target in chain_targets:
			var thunder := AttackRequest.circle(chain_target, 34.0, 0.42, 1, "战魂·雷引")
			thunder.action_kind = AttackRequest.ActionKind.PASSIVE
			thunder.grants_boss_ultimate_energy = false
			thunder.grants_special_target_dragon_progress = false
			thunder.suppress_visual_feedback = true
			thunder.suppress_impact_feedback = true
			procs.append({"id": "thunder", "request": thunder, "position": chain_target})
	if hero.has_battle_soul("flame") and has_proc_ready("flame"):
		consume_proc("flame")
		var flame := AttackRequest.circle(target, hero.battle_soul_flame_radius(), 0.72, hero.battle_soul_flame_target_count_for_attack(), "战魂·爆炎")
		flame.action_kind = AttackRequest.ActionKind.PASSIVE
		flame.knockback = 180.0
		flame.grants_boss_ultimate_energy = false
		flame.grants_special_target_dragon_progress = false
		flame.suppress_visual_feedback = true
		flame.suppress_impact_feedback = true
		procs.append({"id": "flame", "request": flame, "position": target})
	return procs

func title_for(soul_id: String) -> String:
	match soul_id:
		"gale": return "罡风战魂"
		"thunder": return "雷霆战魂"
		"flame": return "爆炎战魂"
		"iron": return "玄甲战魂"
		"machine": return "神机战魂"
		_: return "战魂"

func short_title_for(soul_id: String) -> String:
	match soul_id:
		"gale": return "罡风"
		"thunder": return "雷霆"
		"flame": return "爆炎"
		"iron": return "玄甲"
		_: return "战魂"

func _armory_id_for(soul_id: String) -> String:
	return "%s_mastery" % soul_id

func description_for(soul_id: String, rank: int = 0) -> String:
	var armory_id := _armory_id_for(soul_id)
	if BattleSoulArmory.definition_for(armory_id).is_empty():
		return "获得临时战场增益"
	return BattleSoulArmory.current_effect_for(armory_id, rank)

func icon_for(soul_id: String) -> String:
	match soul_id:
		"gale": return "风"
		"thunder": return "雷"
		"flame": return "炎"
		"iron": return "甲"
		"machine": return "机"
		_: return "魂"

func color_for(soul_id: String) -> Color:
	match soul_id:
		"gale": return Color("75d9a6")
		"thunder": return Color("79baff")
		"flame": return Color("f28a48")
		"iron": return Color("e1c26a")
		"machine": return Color("d8a84e")
		_: return Color("d8e7ef")

func _try_spawn_at_nearby_corpse(player_position: Vector2) -> bool:
	var candidates: Array[Dictionary] = []
	for corpse in recent_corpses:
		var at: Vector2 = corpse.get("position", Vector2.ZERO)
		var distance_squared := at.distance_squared_to(player_position)
		if distance_squared > CORPSE_SEARCH_RADIUS * CORPSE_SEARCH_RADIUS:
			continue
		# Do not spawn directly under the hero: the player must consciously step
		# over the pickup instead of receiving it in the same frame it appears.
		if distance_squared < CORPSE_MIN_DROP_DISTANCE * CORPSE_MIN_DROP_DISTANCE:
			continue
		candidates.append(corpse)
	if candidates.is_empty():
		return false
	var corpse: Dictionary = candidates[randi() % candidates.size()]
	var soul_id := SOUL_IDS[randi() % SOUL_IDS.size()]
	var at: Vector2 = corpse.get("position", player_position)
	drops.append({"id": soul_id, "position": at, "remaining": GROUND_LIFETIME})
	# A single corpse cannot repeatedly manufacture rewards during the same run.
	recent_corpses.erase(corpse)
	soul_spawned.emit(soul_id, at)
	return true

func _proc_target_for(source_request: AttackRequest, target_positions: Array[Vector2]) -> Vector2:
	if not target_positions.is_empty():
		return target_positions[0]
	var direction := source_request.direction.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	return source_request.origin + direction * maxf(16.0, source_request.range * 0.55)
