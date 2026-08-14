class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal died()
signal shield_broken()

var maximum := 100.0
var current := 100.0
var shield_charges := 0
var shield_charge_cap := 1

func reset(new_maximum: float) -> void:
	maximum = new_maximum
	current = maximum
	shield_charges = 0
	shield_charge_cap = 1
	health_changed.emit(current, maximum)

func set_shield_charge_cap(cap: int) -> void:
	shield_charge_cap = maxi(1, cap)
	shield_charges = mini(shield_charges, shield_charge_cap)

func grant_shield(charges: int = 1) -> void:
	shield_charges = mini(shield_charge_cap, shield_charges + maxi(0, charges))

func take_damage(amount: float, bypass_shield: bool = false) -> float:
	if not bypass_shield and shield_charges > 0:
		shield_charges -= 1
		shield_broken.emit()
		return 0.0
	var applied := maxf(0.0, amount)
	current = maxf(0.0, current - applied)
	health_changed.emit(current, maximum)
	if current <= 0.0:
		died.emit()
	return applied
