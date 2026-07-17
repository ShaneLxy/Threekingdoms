class_name Telegraph
extends RefCounted

enum Shape { LINE, FAN, CIRCLE }

var shape: Shape = Shape.CIRCLE
var origin := Vector2.ZERO
var direction := Vector2.UP
var range := 0.0
var width := 0.0
var half_angle := 0.0
var remaining := 0.0
var damage := 0.0
var source := "enemy"
var source_enemy_id := -1

static func line(at: Vector2, toward: Vector2, length: float, line_width: float, duration: float, value: float, owner: String) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape = Shape.LINE
	telegraph.origin = at
	telegraph.direction = toward.normalized()
	telegraph.range = length
	telegraph.width = line_width
	telegraph.remaining = duration
	telegraph.damage = value
	telegraph.source = owner
	return telegraph

static func fan(at: Vector2, toward: Vector2, radius: float, angle: float, duration: float, value: float, owner: String) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape = Shape.FAN
	telegraph.origin = at
	telegraph.direction = toward.normalized()
	telegraph.range = radius
	telegraph.half_angle = angle * 0.5
	telegraph.remaining = duration
	telegraph.damage = value
	telegraph.source = owner
	return telegraph

static func circle(at: Vector2, radius: float, duration: float, value: float, owner: String) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape = Shape.CIRCLE
	telegraph.origin = at
	telegraph.range = radius
	telegraph.remaining = duration
	telegraph.damage = value
	telegraph.source = owner
	return telegraph

func hits_point(point: Vector2) -> bool:
	var offset := point - origin
	match shape:
		Shape.CIRCLE:
			return offset.length_squared() <= range * range
		Shape.FAN:
			if offset.length_squared() <= 0.01:
				return true
			if offset.length_squared() > range * range:
				return false
			return absf(direction.angle_to(offset.normalized())) <= half_angle
		Shape.LINE:
			var projected := offset.dot(direction)
			return projected >= 0.0 and projected <= range and absf(offset.cross(direction)) <= width * 0.5
	return false
