class_name InputRouter
extends Node

signal basic_requested(direction: Vector2)
signal basic_hold_started(direction: Vector2)
signal basic_hold_released(direction: Vector2)
signal active_requested(direction: Vector2)
signal active_hold_started(direction: Vector2)
signal active_hold_released(direction: Vector2)
signal ultimate_requested(direction: Vector2)
signal guard_requested(direction: Vector2)
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
var mouse_attack_held := false
var mouse_active_held := false
var touch_active_index := -1
var active_hold_tracking := false
var basic_hold_pending := false
var basic_hold_active := false
var basic_hold_elapsed := 0.0
var suspended_basic_hold := false
var suspended_basic_mouse := false
var suspended_basic_touch := false
var suspended_basic_release_pending := false

const MOVE_MAX_DISTANCE := 110.0
const MOVE_DEAD_ZONE := 10.0
const BASIC_HOLD_TRIGGER_DURATION := 0.24

func configure(player_actor: HeroActor, battle_hud: BattleHud) -> void:
	player = player_actor
	hud = battle_hud

func set_input_enabled(value: bool) -> void:
	if enabled == value:
		return
	if not value:
		# Upgrade and pause overlays stop the battle input loop. Preserve the
		# physical attack source so a drag-charge release is not lost while the
		# overlay is open.
		suspended_basic_hold = basic_hold_active or _player_is_drag_charging()
		suspended_basic_mouse = mouse_attack_held
		suspended_basic_touch = touch_attack_index >= 0
		suspended_basic_release_pending = false
	enabled = value
	if not enabled:
		reset_touch_state()
	else:
		_flush_suspended_basic_hold()

func reset_touch_state() -> void:
	touch_move_index = -1
	touch_move_start = Vector2.ZERO
	touch_move_current = Vector2.ZERO
	touch_attack_index = -1
	touch_attack_start = Vector2.ZERO
	mouse_attack_held = false
	mouse_active_held = false
	touch_active_index = -1
	_reset_basic_hold_state()
	_reset_active_hold_state()
	if hud != null:
		hud.clear_move_stick_offset()

func _flush_suspended_basic_hold() -> void:
	if not suspended_basic_hold:
		suspended_basic_mouse = false
		suspended_basic_touch = false
		suspended_basic_release_pending = false
		return
	var should_release := suspended_basic_release_pending
	if suspended_basic_mouse:
		should_release = should_release or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if suspended_basic_touch:
		# Touch identifiers cannot be queried reliably after a modal overlay. A
		# missing release is safer to resolve here than to leave drag charging
		# permanently latched.
		should_release = true
	if should_release and _player_is_drag_charging():
		player.release_basic_hold(movement_direction())
	elif suspended_basic_mouse and _player_is_drag_charging():
		# The mouse is still held: restore the router-side ownership so the next
		# real mouse-up can close the drag normally.
		mouse_attack_held = true
		basic_hold_active = true
	suspended_basic_hold = false
	suspended_basic_mouse = false
	suspended_basic_touch = false
	suspended_basic_release_pending = false

func _player_is_drag_charging() -> bool:
	return player != null and player.has_method("is_drag_charging") and player.is_drag_charging()

func _process(delta: float) -> void:
	if not enabled or not basic_hold_pending or player == null or not player.supports_basic_hold():
		return
	basic_hold_elapsed += delta
	if basic_hold_elapsed < BASIC_HOLD_TRIGGER_DURATION:
		return
	basic_hold_pending = false
	basic_hold_active = true
	basic_hold_started.emit(movement_direction())

func _begin_basic_press(direction: Vector2 = Vector2.ZERO) -> void:
	if hud != null:
		hud.set_control_pressed("attack", true)
	if not player.supports_basic_hold() or player.is_action_locked():
		basic_requested.emit(direction)
		return
	basic_hold_pending = true
	basic_hold_active = false
	basic_hold_elapsed = 0.0

func _end_basic_press(direction: Vector2 = Vector2.ZERO) -> void:
	if hud != null:
		hud.set_control_pressed("attack", false)
	if basic_hold_pending:
		basic_requested.emit(direction)
	elif basic_hold_active:
		basic_hold_released.emit(direction)
	_reset_basic_hold_state()

func _reset_basic_hold_state() -> void:
	basic_hold_pending = false
	basic_hold_active = false
	basic_hold_elapsed = 0.0

func _begin_active_press(direction: Vector2 = Vector2.ZERO) -> bool:
	if player == null or not player.supports_active_hold():
		if hud != null:
			hud.set_control_pressed("active", true)
		active_requested.emit(direction)
		return false
	if not player.can_use_active():
		return false
	if hud != null:
		hud.set_control_pressed("active", true)
	active_hold_tracking = true
	active_hold_started.emit(direction)
	return true

func _end_active_press(direction: Vector2 = Vector2.ZERO) -> void:
	if hud != null:
		hud.set_control_pressed("active", false)
	if active_hold_tracking:
		active_hold_released.emit(direction)
	active_hold_tracking = false

func _reset_active_hold_state() -> void:
	if active_hold_tracking and player != null:
		player.cancel_active_hold()
	active_hold_tracking = false

func _emit_guard_request(direction: Vector2) -> void:
	if hud != null:
		hud.set_control_pressed("guard", true)
	# A guard can cancel a basic attack, so discard any pending mouse/touch
	# release that would otherwise re-fire the cancelled attack.
	mouse_attack_held = false
	touch_attack_index = -1
	_reset_basic_hold_state()
	guard_requested.emit(direction)

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

func _input(event: InputEvent) -> void:
	# Capture release events before modal upgrade controls consume them. This is
	# deliberately limited to an already-held attack, so menu clicks do not
	# affect normal input.
	if enabled or not suspended_basic_hold:
		return
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and suspended_basic_mouse:
		suspended_basic_release_pending = true
	elif event is InputEventScreenTouch and not event.pressed and suspended_basic_touch:
		suspended_basic_release_pending = true

func _unhandled_input(event: InputEvent) -> void:
	if player == null or hud == null:
		return
	if not enabled:
		return
	if hud.modal_active:
		return
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			if event.pressed and not event.echo:
				_begin_active_press(movement_direction())
			elif not event.pressed:
				_end_active_press(movement_direction())
		elif event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
				pause_requested.emit()
			elif event.keycode == KEY_SHIFT:
				_emit_guard_request(movement_direction())
			elif event.keycode == KEY_R:
				weapon_stance_requested.emit()
			elif event.keycode == KEY_E or event.keycode == KEY_SPACE:
				hud.set_control_pressed("ultimate", true)
				ultimate_requested.emit(Vector2.ZERO)
	elif event is InputEventMouseButton:
		if not event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT and mouse_active_held:
				mouse_active_held = false
				_end_active_press(movement_direction())
			if event.button_index == MOUSE_BUTTON_LEFT and mouse_attack_held:
				mouse_attack_held = false
				_end_basic_press(movement_direction())
			if event.button_index == MOUSE_BUTTON_LEFT and mouse_active_held:
				mouse_active_held = false
				_end_active_press(movement_direction())
			return
		if event.button_index == MOUSE_BUTTON_LEFT and hud.is_pause_hit(event.position):
			pause_requested.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_active_held = _begin_active_press(movement_direction())
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			hud.set_control_pressed("ultimate", true)
			ultimate_requested.emit(Vector2.ZERO)
		elif hud.is_weapon_stance_hit(event.position):
			weapon_stance_requested.emit()
		elif hud.is_guard_hit(event.position):
			_emit_guard_request(movement_direction())
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.position.distance_to(hud.move_center()) <= hud.move_capture_radius():
				return
			elif event.position.distance_to(hud.active_center()) < 65.0:
				mouse_active_held = _begin_active_press(movement_direction())
			elif event.position.distance_to(hud.ultimate_center()) < 65.0:
				hud.set_control_pressed("ultimate", true)
				ultimate_requested.emit(Vector2.ZERO)
			else:
				mouse_attack_held = true
				_begin_basic_press(Vector2.ZERO)
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
			if _begin_active_press(movement_direction()):
				touch_active_index = event.index
		elif event.position.distance_to(hud.ultimate_center()) < 70.0:
			hud.set_control_pressed("ultimate", true)
			ultimate_requested.emit(Vector2.ZERO)
		elif hud.is_weapon_stance_hit(event.position):
			weapon_stance_requested.emit()
		elif hud.is_guard_hit(event.position):
			_emit_guard_request(movement_direction())
		else:
			touch_attack_index = event.index
			touch_attack_start = event.position
			_begin_basic_press(Vector2.ZERO)
	else:
		if event.index == touch_move_index:
			touch_move_index = -1
			hud.clear_move_stick_offset()
		if event.index == touch_attack_index:
			touch_attack_index = -1
			_end_basic_press(movement_direction())
		if event.index == touch_active_index:
			touch_active_index = -1
			_end_active_press(movement_direction())

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == touch_move_index:
		touch_move_current = event.position
		hud.set_move_stick_offset(touch_move_current - touch_move_start)

func _is_move_touch(at: Vector2) -> bool:
	if at.distance_to(hud.move_center()) <= hud.move_capture_radius():
		return true
	return at.x <= get_viewport().get_visible_rect().size.x * 0.44 and at.y >= get_viewport().get_visible_rect().size.y * 0.42
