class_name InputRouter
extends Node

signal basic_requested(direction: Vector2)
signal basic_hold_started(direction: Vector2)
signal basic_hold_released(direction: Vector2)
signal active_requested(direction: Vector2)
signal ultimate_requested(direction: Vector2)
signal weapon_stance_requested()
signal pause_requested()

var player: HeroActor
var hud: BattleHud
var enabled := true
var touch_move_index := -1
var touch_move_start := Vector2.ZERO
var touch_move_current := Vector2.ZERO
var touch_attack_index := -1
var touch_attack_start := Vector2.ZERO

const MOVE_MAX_DISTANCE := 110.0
const MOVE_DEAD_ZONE := 10.0

func configure(player_actor: HeroActor, battle_hud: BattleHud) -> void:
	player = player_actor
	hud = battle_hud

func set_input_enabled(value: bool) -> void:
	if enabled == value:
		return
	enabled = value
	if not enabled:
		reset_touch_state()

func reset_touch_state() -> void:
	touch_move_index = -1
	touch_move_start = Vector2.ZERO
	touch_move_current = Vector2.ZERO
	touch_attack_index = -1
	touch_attack_start = Vector2.ZERO
	if hud != null:
		hud.clear_move_stick_offset()

func movement_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if touch_move_index >= 0:
		var move_offset := (touch_move_current - touch_move_start).limit_length(MOVE_MAX_DISTANCE)
		if move_offset.length() > MOVE_DEAD_ZONE:
			direction += move_offset / MOVE_MAX_DISTANCE
	return direction.normalized() if direction.length() > 1.0 else direction

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or player == null or hud == null or hud.modal_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			pause_requested.emit()
		elif event.keycode == KEY_Q:
			active_requested.emit(movement_direction())
		elif event.keycode == KEY_R:
			weapon_stance_requested.emit()
		elif event.keycode == KEY_E or event.keycode == KEY_SPACE:
			ultimate_requested.emit(Vector2.ZERO)
	elif event is InputEventMouseButton:
		if not event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and player.supports_basic_hold():
				basic_hold_released.emit(movement_direction())
			return
		if event.button_index == MOUSE_BUTTON_LEFT and hud.is_pause_hit(event.position):
			pause_requested.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			active_requested.emit(movement_direction())
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			ultimate_requested.emit(Vector2.ZERO)
		elif hud.is_weapon_stance_hit(event.position):
			weapon_stance_requested.emit()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.position.distance_to(hud.move_center()) <= hud.move_capture_radius():
				return
			elif event.position.distance_to(hud.active_center()) < 65.0:
				active_requested.emit(movement_direction())
			elif event.position.distance_to(hud.ultimate_center()) < 65.0:
				ultimate_requested.emit(Vector2.ZERO)
			else:
				if player.supports_basic_hold():
					basic_hold_started.emit(Vector2.ZERO)
				else:
					basic_requested.emit(Vector2.ZERO)
	elif event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if hud.is_pause_hit(event.position):
			pause_requested.emit()
			return
		if _is_move_touch(event.position):
			if touch_move_index >= 0:
				return
			touch_move_index = event.index
			touch_move_start = hud.move_center()
			touch_move_current = event.position
			hud.set_move_stick_offset(touch_move_current - touch_move_start)
		elif event.position.distance_to(hud.active_center()) < 70.0:
			active_requested.emit(movement_direction())
		elif event.position.distance_to(hud.ultimate_center()) < 70.0:
			ultimate_requested.emit(Vector2.ZERO)
		elif hud.is_weapon_stance_hit(event.position):
			weapon_stance_requested.emit()
		else:
			touch_attack_index = event.index
			touch_attack_start = event.position
			if player.supports_basic_hold():
				basic_hold_started.emit(Vector2.ZERO)
			else:
				basic_requested.emit(Vector2.ZERO)
	else:
		if event.index == touch_move_index:
			touch_move_index = -1
			hud.clear_move_stick_offset()
		if event.index == touch_attack_index:
			touch_attack_index = -1
			if player.supports_basic_hold():
				basic_hold_released.emit(movement_direction())

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == touch_move_index:
		touch_move_current = event.position
		hud.set_move_stick_offset(touch_move_current - touch_move_start)
	elif event.index == touch_attack_index and event.position.distance_to(touch_attack_start) > 18.0:
		basic_requested.emit(Vector2.ZERO)

func _is_move_touch(at: Vector2) -> bool:
	if at.distance_to(hud.move_center()) <= hud.move_capture_radius():
		return true
	return at.x <= get_viewport().get_visible_rect().size.x * 0.44 and at.y >= get_viewport().get_visible_rect().size.y * 0.42
