class_name AttackRequest
extends RefCounted

enum Shape { LINE, FAN, CIRCLE }

var shape: Shape = Shape.LINE
var origin := Vector2.ZERO
var direction := Vector2.UP
var range := 0.0
var width := 0.0
var half_angle := 0.0
var multiplier := 1.0
var pierce := 1
var knockback := 0.0
var ignore_knockback_resistance := false
var forced_displacement := 0.0
var forced_displacement_duration := 0.0
var label := ""
var one_hit_per_target := false
var hit_targets: Dictionary = {}
var hit_boss := false
var hit_elite_ids: Dictionary = {}
var total_hits := 0
var visual_emitted := false
var impact_emitted := false
var special_effect_applied := false
var dragon_triggered := false
var breakout_granted := false
var is_path_attack := false
var fan_knockback := false
var empowered_knockback_active := false
var empowered_knockback_target_limit := 0
var empowered_knockback_multiplier := 1.0
var empowered_knockback_targets: Dictionary = {}

static func line(at: Vector2, toward: Vector2, length: float, line_width: float, damage_multiplier: float, max_targets: int, name: String) -> AttackRequest:
	var request := AttackRequest.new()
	request.shape = Shape.LINE
	request.origin = at
	request.direction = toward.normalized()
	request.range = length
	request.width = line_width
	request.multiplier = damage_multiplier
	request.pierce = max_targets
	request.label = name
	return request

static func fan(at: Vector2, toward: Vector2, radius: float, angle: float, damage_multiplier: float, max_targets: int, name: String) -> AttackRequest:
	var request := AttackRequest.new()
	request.shape = Shape.FAN
	request.origin = at
	request.direction = toward.normalized()
	request.range = radius
	request.half_angle = angle * 0.5
	request.multiplier = damage_multiplier
	request.pierce = max_targets
	request.label = name
	return request

static func circle(at: Vector2, radius: float, damage_multiplier: float, max_targets: int, name: String) -> AttackRequest:
	var request := AttackRequest.new()
	request.shape = Shape.CIRCLE
	request.origin = at
	request.range = radius
	request.multiplier = damage_multiplier
	request.pierce = max_targets
	request.label = name
	return request
