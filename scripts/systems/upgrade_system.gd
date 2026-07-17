class_name UpgradeSystem
extends Node

const UPGRADE_IDS := [
	"spear_reach", "sweeping_wind", "dash_echo", "dragon_armor",
	"dragon_stride", "dragon_scale", "seven_edge", "snake_spin",
	"spear_shadow", "white_dragon", "returning_spear", "triumph",
]

const WEAPON_IDS := ["spear_reach", "sweeping_wind", "dash_echo"]
const PASSIVE_IDS := ["dragon_armor", "dragon_stride", "dragon_scale"]
const ACTIVE_IDS := ["seven_edge", "snake_spin", "spear_shadow"]

const DEFINITIONS := {
	"spear_reach": {"title": "枪势延展", "category": "枪法", "description": "三段普攻距离 +28，穿透 +2。", "max_stacks": 3},
	"sweeping_wind": {"title": "横扫余威", "category": "枪法", "description": "第二段横扫范围 +32、角度 +30°，击退更强。", "max_stacks": 3},
	"dash_echo": {"title": "追云突刺", "category": "枪法", "description": "第三段突进 +46，命中后可移动恢复更长。", "max_stacks": 3},
	"dragon_armor": {"title": "胆魄凝甲", "category": "龙胆", "description": "防御 +8；龙胆状态下受到的伤害 -25%。", "max_stacks": 2},
	"dragon_stride": {"title": "破阵疾行", "category": "龙胆", "description": "龙胆持续 +1 秒，期间移速额外提高。", "max_stacks": 3},
	"dragon_scale": {"title": "龙鳞不灭", "category": "龙胆", "description": "生命上限 +18，并立即回复等量生命。", "max_stacks": 3},
	"seven_edge": {"title": "破军余锋", "category": "破军", "description": "破军冷却 -1.25 秒，最低 4.5 秒。", "max_stacks": 3},
	"snake_spin": {"title": "破军回旋", "category": "破军", "description": "破军范围、伤害、击退与脱离恢复均大幅提升。", "max_stacks": 3},
	"spear_shadow": {"title": "枪影随行", "category": "破军", "description": "破军结束后追加一次延迟枪影补击。", "max_stacks": 2},
	"white_dragon": {"title": "白龙长驱", "category": "无双", "description": "七进七出每段突进距离 +24，并立刻获得 30 无双能量。", "max_stacks": 3},
	"returning_spear": {"title": "回马穿心", "category": "无双", "description": "七进七出每次穿阵的伤害提高。", "max_stacks": 3},
	"triumph": {"title": "凯歌", "category": "无双", "description": "无双充能效率提高；击败精英额外回血并充能。", "max_stacks": 1},
}

var rng := RandomNumberGenerator.new()
var owned_counts: Dictionary = {}

func seed_with(value: int) -> void:
	rng.seed = value
	owned_counts.clear()

func draft(level: int) -> Array[String]:
	var result: Array[String] = []
	if level <= 2:
		_pick_from_bucket(WEAPON_IDS, result)
		_pick_from_bucket(PASSIVE_IDS, result)
		_pick_from_bucket(ACTIVE_IDS, result)
	_fill_random(result)
	return result

func record_selection(upgrade_id: String) -> void:
	owned_counts[upgrade_id] = int(owned_counts.get(upgrade_id, 0)) + 1

func title_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("title", upgrade_id))

func description_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("description", ""))

func category_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("category", "强化"))

func _pick_from_bucket(bucket: Array, result: Array[String]) -> void:
	var available := _available_from(bucket)
	if available.is_empty() or result.size() >= 3:
		return
	result.append(available.pop_at(rng.randi_range(0, available.size() - 1)))

func _fill_random(result: Array[String]) -> void:
	var available := _available_from(UPGRADE_IDS)
	while result.size() < 3 and not available.is_empty():
		var index := rng.randi_range(0, available.size() - 1)
		var upgrade_id: String = available.pop_at(index)
		if not result.has(upgrade_id):
			result.append(upgrade_id)

func _available_from(candidates: Array) -> Array[String]:
	var available: Array[String] = []
	for candidate in candidates:
		var upgrade_id := str(candidate)
		if int(owned_counts.get(upgrade_id, 0)) < int(_definition(upgrade_id).get("max_stacks", 1)):
			available.append(upgrade_id)
	return available

func _definition(upgrade_id: String) -> Dictionary:
	return DEFINITIONS.get(upgrade_id, {}) as Dictionary
