class_name SoulResonance
extends RefCounted

const ID := "five_soul_resonance"
const TITLE := "五魂共鸣"
const PROFILE_KEY := "soul_resonance_rank"
const COSTS := [300, 800, 1800]
const DESCRIPTION := "战魂掉得更快，效果持续更久。五种战魂铭刻全部达到四级后，可激活共鸣。"

static func rank_for(profile: Dictionary) -> int:
	return clampi(int(profile.get(PROFILE_KEY, 0)), 0, 3)

static func unfinished_for(profile: Dictionary) -> Array[String]:
	var unfinished: Array[String] = []
	var ranks: Dictionary = profile.get("battle_soul_armory", {}) as Dictionary
	for id in BattleSoulArmory.DISPLAY_ORDER:
		if int(ranks.get(id, 0)) != BattleSoulArmory.max_rank_for(id):
			unfinished.append(BattleSoulArmory.title_for(id))
	return unfinished

static func prerequisite_text(profile: Dictionary) -> String:
	var unfinished := unfinished_for(profile)
	return "已满级战魂：%d / 5\n%s" % [5 - unfinished.size(), "五魂已全部达到四级" if unfinished.is_empty() else "未满级：%s" % "、".join(unfinished)]

static func cost_for(profile: Dictionary) -> int:
	var rank := rank_for(profile)
	return COSTS[rank] if rank < 3 else 0

static func can_purchase(profile: Dictionary) -> bool:
	return rank_for(profile) < 3 and unfinished_for(profile).is_empty() and int(profile.get("military_merit", 0)) >= cost_for(profile)

static func purchase(profile: Dictionary) -> bool:
	if not can_purchase(profile):
		return false
	var cost := cost_for(profile)
	profile[PROFILE_KEY] = rank_for(profile) + 1
	profile["military_merit"] = int(profile.get("military_merit", 0)) - cost
	return true

static func effects_for(profile: Dictionary) -> Dictionary:
	var rank := rank_for(profile)
	return {"drop_interval": 17.5 if rank >= 3 else (24.5 if rank >= 1 else 35.0), "buff_duration": 30.0 if rank >= 2 else 20.0}

static func description_for(profile: Dictionary) -> String:
	var effects := effects_for(profile)
	return "%s\n当前：每 %s 秒掉落，效果持续 %s 秒。\n一级：掉落间隔减少 30%%。\n二级：保留一级效果，持续时间增加 50%%。\n三级：掉落间隔改为减少 50%%，保留 30 秒持续时间。" % [DESCRIPTION, str(effects.drop_interval), str(effects.buff_duration)]
