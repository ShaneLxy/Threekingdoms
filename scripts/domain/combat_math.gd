class_name CombatMath
extends RefCounted

static func final_damage(attack: float, multiplier: float, bonus_damage: float, target_armor: float, critical: bool = false, armor_ignore_ratio: float = 0.0) -> float:
	var raw := attack * multiplier * (1.0 + bonus_damage)
	if critical:
		raw *= 1.5
	var effective_armor := maxf(0.0, target_armor) * (1.0 - clampf(armor_ignore_ratio, 0.0, 1.0))
	return maxf(1.0, raw * 100.0 / (100.0 + effective_armor))

static func final_damage_against_regular_enemy(attack: float, multiplier: float, bonus_damage: float, target_armor: float, critical: bool = false, armor_ignore_ratio: float = 0.0) -> float:
	# 无视防御对普通敌人转为同等比例的直接增伤；精英和领主继续调用
	# final_damage()，保持其原有的按比例降低防御的结算方式。
	var damage := final_damage(attack, multiplier, bonus_damage, target_armor, critical)
	return damage * (1.0 + clampf(armor_ignore_ratio, 0.0, 1.0))

static func mitigate_damage(incoming_damage: float, defense: float) -> float:
	return maxf(1.0, incoming_damage * 100.0 / (100.0 + maxf(0.0, defense)))
