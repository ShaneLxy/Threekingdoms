class_name BossActor
extends Node2D

signal telegraph_requested(telegraph: Telegraph)
signal summon_requested(phase: int)
signal phase_changed(phase: int)
signal defeated()

enum State { APPROACH, WINDUP, RECOVER, PHASE_TRANSITION }

const HEALTH_LAYER_CAPACITY := 500.0

@onready var health_component: HealthComponent = %HealthComponent

var active := false
var phase := 1
var state := State.APPROACH
var action_index := 0
var state_timer := 0.0
var pending_recovery := 0.0
var pending_vulnerability := 0.0
var phase_summon_pending := false
var vulnerable_time := 0.0
var move_speed := 135.0
var facing_direction := Vector2.DOWN
var thrust_sequence: Array[float] = []

func _ready() -> void:
	health_component.died.connect(_on_died)

func activate(at: Vector2) -> void:
	active = true
	visible = true
	position = at
	phase = 1
	state = State.APPROACH
	action_index = 0
	state_timer = 0.70
	pending_recovery = 0.0
	pending_vulnerability = 0.0
	phase_summon_pending = false
	vulnerable_time = 0.0
	facing_direction = Vector2.DOWN
	thrust_sequence.clear()
	health_component.reset(1500.0)

func tick(delta: float, player_position: Vector2) -> void:
	if not active:
		return
	vulnerable_time = maxf(0.0, vulnerable_time - delta)
	if _begin_phase_transition_if_needed():
		return
	match state:
		State.PHASE_TRANSITION:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				if phase_summon_pending:
					phase_summon_pending = false
					summon_requested.emit(phase)
				_enter_recovery(0.45, 0.0)
		State.WINDUP:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_finish_windup()
		State.RECOVER:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				state = State.APPROACH
				state_timer = 0.30
		State.APPROACH:
			_approach_player(delta, player_position)
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_issue_next_action(player_position)

func receive_damage(amount: float) -> void:
	if not active:
		return
	var actual := amount
	if vulnerable_time > 0.0:
		actual *= 1.25
	health_component.take_damage(actual)

func health_ratio() -> float:
	return health_component.current / maxf(1.0, health_component.maximum)

func is_recovering() -> bool:
	return state == State.RECOVER

func display_name() -> String:
	return "张郃"

func weapon_title() -> String:
	return "雁翎枪"

func health_layer_capacity() -> float:
	return HEALTH_LAYER_CAPACITY

func _approach_player(delta: float, player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length() > 150.0:
		facing_direction = to_player.normalized()
		position += facing_direction * move_speed * delta

func _begin_phase_transition_if_needed() -> bool:
	var new_phase := 1
	if health_ratio() <= 0.35:
		new_phase = 3
	elif health_ratio() <= 0.70:
		new_phase = 2
	if new_phase == phase:
		return false
	phase = new_phase
	state = State.PHASE_TRANSITION
	state_timer = 1.0
	vulnerable_time = 0.0
	thrust_sequence.clear()
	phase_summon_pending = true
	phase_changed.emit(phase)
	return true

func _issue_next_action(player_position: Vector2) -> void:
	var actions: Array[String] = ["sweep", "thrust"]
	if phase == 2:
		actions = ["summon", "sweep", "thrust", "whirl"]
	elif phase == 3:
		actions = ["sweep", "thrust", "three_thrust", "summon", "whirl"]
	var action: String = actions[action_index % actions.size()]
	action_index += 1
	var direction := (player_position - position).normalized()
	if direction.length_squared() > 0.01:
		facing_direction = direction
	else:
		direction = facing_direction
	state = State.WINDUP
	pending_vulnerability = 0.0
	match action:
		"sweep":
			telegraph_requested.emit(Telegraph.fan(position, direction, 160.0, deg_to_rad(120.0), 0.72, 24.0, "boss"))
			state_timer = 0.72
			pending_recovery = 0.58
			pending_vulnerability = 0.58
		"thrust":
			telegraph_requested.emit(Telegraph.line(position, direction, 310.0, 34.0, 0.90, 30.0, "boss"))
			state_timer = 0.90
			pending_recovery = 1.10
			pending_vulnerability = 1.10
		"whirl":
			telegraph_requested.emit(Telegraph.circle(position, 165.0, 1.0, 28.0, "boss"))
			state_timer = 1.0
			pending_recovery = 0.80
			pending_vulnerability = 0.45
		"three_thrust":
			for angle in [-0.20, 0.0, 0.20]:
				telegraph_requested.emit(Telegraph.line(position, direction.rotated(angle), 300.0, 32.0, 0.88, 0.0, "boss_preview"))
			thrust_sequence = [-0.20, 0.0, 0.20]
			state_timer = 0.88
			pending_recovery = 1.00
			pending_vulnerability = 1.00
		"summon":
			summon_requested.emit(phase)
			state_timer = 0.80
			pending_recovery = 0.80
	if phase == 3 and action != "three_thrust":
		pending_recovery *= 0.82
		pending_vulnerability *= 0.82

func _finish_windup() -> void:
	if not thrust_sequence.is_empty():
		var angle: float = float(thrust_sequence.pop_front())
		telegraph_requested.emit(Telegraph.line(position, facing_direction.rotated(angle), 300.0, 32.0, 0.34, 16.0, "boss"))
		state_timer = 0.34
		return
	_enter_recovery(pending_recovery, pending_vulnerability)

func _enter_recovery(duration: float, vulnerability: float) -> void:
	state = State.RECOVER
	state_timer = duration
	vulnerable_time = vulnerability

func _on_died() -> void:
	active = false
	visible = false
	defeated.emit()
