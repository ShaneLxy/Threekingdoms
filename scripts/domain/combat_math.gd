class_name CombatMath
extends RefCounted

static func final_damage(attack: float, multiplier: float, bonus_damage: float, target_armor: float, critical: bool = false) -> float:
	var raw := attack * multiplier * (1.0 + bonus_damage)
	if critical:
		raw *= 1.5
	return maxf(1.0, raw * 100.0 / (100.0 + maxf(0.0, target_armor)))

static func mitigate_damage(incoming_damage: float, defense: float) -> float:
	return maxf(1.0, incoming_damage * 100.0 / (100.0 + maxf(0.0, defense)))
