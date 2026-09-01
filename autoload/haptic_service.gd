extends Node

const PLAYER_DAMAGE_DURATION_MS := 48
const PLAYER_DAMAGE_AMPLITUDE := 0.72
const TIANJI_DAMAGE_DURATION_MS := 26
const TIANJI_DAMAGE_AMPLITUDE := 0.42
const TIANJI_FINAL_METEOR_DURATION_MS := 92
const TIANJI_FINAL_METEOR_AMPLITUDE := 0.90
const MIN_PULSE_INTERVAL := 0.08

var cooldown_remaining := 0.0

func _process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)

func player_damaged() -> void:
	pulse(PLAYER_DAMAGE_DURATION_MS, PLAYER_DAMAGE_AMPLITUDE)

func tianji_damage() -> void:
	pulse(TIANJI_DAMAGE_DURATION_MS, TIANJI_DAMAGE_AMPLITUDE)

func tianji_final_meteor() -> void:
	if not SaveService.setting_enabled("vibration_enabled"):
		return
	if not OS.has_feature("mobile"):
		return
	# This is intentionally a stronger, dedicated impact profile. It also
	# overrides the short ordinary-Tianji pulse emitted by the same hit.
	Input.vibrate_handheld(TIANJI_FINAL_METEOR_DURATION_MS, TIANJI_FINAL_METEOR_AMPLITUDE)
	cooldown_remaining = 0.14

func pulse(duration_ms: int, amplitude: float) -> void:
	if cooldown_remaining > 0.0:
		return
	if not SaveService.setting_enabled("vibration_enabled"):
		return
	if not OS.has_feature("mobile"):
		return
	Input.vibrate_handheld(maxi(1, duration_ms), clampf(amplitude, 0.0, 1.0))
	cooldown_remaining = MIN_PULSE_INTERVAL
