class_name EliteActor
extends Node2D

signal telegraph_requested(telegraph: Telegraph)
signal defeated(elite: EliteActor)

enum Archetype { XIAHOU_EN, CHUNYU_DAO }
enum State { INACTIVE, APPROACH, WINDUP, RECOVER }

const HEALTH_LAYER_CAPACITY := 65.0

@onready var health_component: HealthComponent = %HealthComponent

var archetype: Archetype = Archetype.XIAHOU_EN
var active := false
var state: State = State.INACTIVE
var state_timer := 0.0
var action_index := 0
var current_direction := Vector2.DOWN
var queued_followup := ""
var hurt_remaining := 0.0
var telegraph_source := ""

func _ready() -> void:
	health_component.died.connect(_on_died)
	visible = false

func activate(new_archetype: Archetype, at: Vector2) -> void:
	archetype = new_archetype
	position = at
	active = true
	visible = false
	state = State.APPROACH
	state_timer = 0.72
	action_index = 0
	queued_followup = ""
	hurt_remaining = 0.0
	telegraph_source = "elite:%d" % get_instance_id()
	health_component.reset(max_health())

func tick(delta: float, player_position: Vector2) -> void:
	if not active:
		return
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	match state:
		State.APPROACH:
			_approach_player(delta, player_position)
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_issue_next_action(player_position)
		State.WINDUP:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_finish_windup()
		State.RECOVER:
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				state = State.APPROACH
				state_timer = 0.34

func receive_damage(amount: float) -> void:
	if not active:
		return
	hurt_remaining = 0.14
	health_component.take_damage(amount)

func health_ratio() -> float:
	return health_component.current / maxf(1.0, health_component.maximum)

func max_health() -> float:
	return 260.0 if archetype == Archetype.XIAHOU_EN else 240.0

func armor() -> float:
	return 18.0 if archetype == Archetype.XIAHOU_EN else 12.0

func display_name() -> String:
	return "夏侯恩" if archetype == Archetype.XIAHOU_EN else "淳于导"

func weapon_title() -> String:
	return "偃月刀" if archetype == Archetype.XIAHOU_EN else "大砍刀"

func hud_color() -> Color:
	return Color("d64e32") if archetype == Archetype.XIAHOU_EN else Color("d07a32")

func is_recovering() -> bool:
	return active and state == State.RECOVER

func _approach_player(delta: float, player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length_squared() > 0.01:
		current_direction = to_player.normalized()
	var desired_range := 138.0 if archetype == Archetype.XIAHOU_EN else 112.0
	if to_player.length() > desired_range:
		position += current_direction * (78.0 if archetype == Archetype.XIAHOU_EN else 86.0) * delta

func _issue_next_action(player_position: Vector2) -> void:
	var to_player := player_position - position
	if to_player.length_squared() > 0.01:
		current_direction = to_player.normalized()
	var actions: Array[String] = []
	if archetype == Archetype.XIAHOU_EN:
		actions = ["sweep", "drag"]
	else:
		actions = ["crush", "execute"]
	var action := actions[action_index % actions.size()]
	action_index += 1
	state = State.WINDUP
	queued_followup = ""
	match action:
		"sweep":
			telegraph_requested.emit(Telegraph.fan(position, current_direction, 178.0, deg_to_rad(150.0), 0.85, 20.0, telegraph_source))
			state_timer = 0.85
			queued_followup = "recover:0.68"
		"drag":
			telegraph_requested.emit(Telegraph.fan(position + current_direction * 18.0, current_direction, 192.0, deg_to_rad(128.0), 0.76, 22.0, telegraph_source))
			state_timer = 0.76
			queued_followup = "recover:0.74"
		"crush":
			telegraph_requested.emit(Telegraph.line(position, current_direction, 232.0, 42.0, 0.90, 24.0, telegraph_source))
			state_timer = 0.90
			queued_followup = "recover:0.82"
		"execute":
			telegraph_requested.emit(Telegraph.fan(position, current_direction, 122.0, deg_to_rad(82.0), 0.52, 15.0, telegraph_source))
			state_timer = 0.52
			queued_followup = "execute_followup"

func _finish_windup() -> void:
	if queued_followup == "execute_followup":
		telegraph_requested.emit(Telegraph.fan(position, current_direction, 142.0, deg_to_rad(118.0), 0.50, 18.0, telegraph_source))
		state_timer = 0.50
		queued_followup = "recover:0.58"
		return
	var recovery := 0.55
	if queued_followup.begins_with("recover:"):
		recovery = float(queued_followup.trim_prefix("recover:"))
	state = State.RECOVER
	state_timer = recovery
	queued_followup = ""

func _on_died() -> void:
	if not active:
		return
	active = false
	visible = false
	state = State.INACTIVE
	defeated.emit(self)
