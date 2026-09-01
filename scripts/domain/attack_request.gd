class_name AttackRequest
extends RefCounted

enum Shape { LINE, FAN, CIRCLE }
enum ActionKind { NONE, BASIC, ACTIVE, ULTIMATE, PASSIVE, PROJECTILE }

var shape: Shape = Shape.LINE
var origin := Vector2.ZERO
var direction := Vector2.UP
var range := 0.0
var inner_radius := 0.0
var width := 0.0
var half_angle := 0.0
var multiplier := 1.0
var center_damage_radius := 0.0
var center_damage_multiplier := 1.0
var pierce := 1
var knockback := 0.0
var ignore_knockback_resistance := false
var forced_displacement := 0.0
var forced_displacement_duration := 0.0
var visual_scale := 1.0
var label := ""
var action_kind: ActionKind = ActionKind.NONE
var clash_kind := 0
var dash_kind := 0
var stance_damage := 0.0
var one_hit_per_target := false
var hit_targets: Dictionary = {}
var excluded_enemy_ids: Dictionary = {}
var hit_boss := false
var hit_elite_ids: Dictionary = {}
var total_hits := 0
var visual_emitted := false
var impact_emitted := false
var audio_emitted := false
var special_effect_applied := false
var breakout_granted := false
var is_path_attack := false
var fan_knockback := false
var displacement_only := false
var suppress_visual_feedback := false
var empowered_knockback_active := false
var empowered_knockback_target_limit := 0
var empowered_knockback_multiplier := 1.0
var empowered_knockback_targets: Dictionary = {}
var suppress_impact_feedback := false
var prevent_elite_knockback := false
var grants_boss_ultimate_energy := true
var grants_special_target_dragon_progress := true
var grants_breakout_guard_on_hit := false
var slow_multiplier := 1.0
var slow_duration := 0.0
var clears_projectiles := false
# Some attacks turn ordinary soldiers into moving collision projectiles.  This
# stays on the attack request so hero-specific launch behavior remains outside
# the shared enemy simulation.
var launches_enemies := false
var launch_speed := 0.0
var launch_duration := 0.0
var launch_collision_damage_multiplier := 0.0
var launch_collision_knockback := 0.0
var launch_collision_max_targets := 0
var launch_relay_count := 0
var launch_target_limit := 0

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

func damage_multiplier_at(point: Vector2) -> float:
	if shape == Shape.CIRCLE and center_damage_radius > 0.0 and point.distance_squared_to(origin) <= center_damage_radius * center_damage_radius:
		return multiplier * maxf(1.0, center_damage_multiplier)
	return multiplier
