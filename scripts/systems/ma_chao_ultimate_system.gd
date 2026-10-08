class_name MaChaoUltimateSystem
extends RefCounted

signal started
signal finished
signal charge_attack_requested(origin: Vector2, direction: Vector2, distance: float, damage: float)
signal cavalry_attack_requested(ally_id: int, target_id: int, target_kind: String, origin: Vector2, direction: Vector2, damage: float)

const HORSE_DURATION := 5.0
const BATTLE_DURATION := 20.0
const RETREAT_DURATION := 5.0
const FORMATION_COUNT := 10
const BATTLE_ALLY_COUNT := 4
const ALLY_MOVE_SPEED := 132.0
const ALLY_ATTACK_RANGE := 102.0
const ALLY_ATTACK_INTERVAL := 3.6
const BOSS_TRIAL_ARENA_BOUNDS := Rect2(275.0, 211.0, 1123.0, 577.0)
const BATTLEFIELD_EDGE_PADDING := 72.0
var ally_attack_interval_reduction := 0.0
const ALLY_SEARCH_RADIUS := 520.0
const ALLY_RETURN_DISTANCE := 360.0
const VIEW_COMFORT_MARGIN := 96.0
const OFFSCREEN_RETURN_DELAY := 1.8
var gale_attack_events := 0

func comfortable_view_rect() -> Rect2:
	var margin := minf(VIEW_COMFORT_MARGIN, minf(battle_view_rect.size.x, battle_view_rect.size.y) * 0.25)
	return battle_view_rect.grow(-margin)

func _comfortable_position(value: Vector2) -> Vector2:
	var rect := comfortable_view_rect()
	var at := Vector2(clampf(value.x, rect.position.x, rect.end.x), clampf(value.y, rect.position.y, rect.end.y))
	return _trial_safe_position(at) if constrain_to_trial_arena else at

func _tick_view_return(ally: Dictionary, delta: float) -> bool:
	var at: Vector2 = ally.get("position", player_position)
	if bool(ally.get("view_returning", false)):
		if comfortable_view_rect().has_point(at):
			ally["view_returning"] = false
			ally["offscreen_elapsed"] = 0.0
		else:
			return true
	if battle_view_rect.has_point(at):
		ally["offscreen_elapsed"] = 0.0
	else:
		ally["offscreen_elapsed"] = float(ally.get("offscreen_elapsed", 0.0)) + delta
		if float(ally["offscreen_elapsed"]) >= OFFSCREEN_RETURN_DELAY:
			ally["view_returning"] = true
			var inner := comfortable_view_rect().grow(-24.0)
			ally["view_return_target"] = _comfortable_position(Vector2(clampf(at.x, inner.position.x, inner.end.x), clampf(at.y, inner.position.y, inner.end.y)))
			return true
	return false
const ALLY_STANDBY_DISTANCE := 156.0
const ALLY_STANDBY_DEADZONE := 21.0
const ALLY_TARGET_HOLD_DURATION := 0.48
const ALLY_FACING_TURN_SPEED := 8.5
const ALLY_DAMAGE_MULTIPLIER := 0.85
const ARROW_OFFSETS := [Vector2(0, 0), Vector2(-74, -48), Vector2(-74, 48), Vector2(-148, -96), Vector2(-148, 96), Vector2(-222, -144), Vector2(-222, 144), Vector2(-296, -82), Vector2(-296, 82), Vector2(-370, 0)]
const BATTLE_OFFSETS := [Vector2(-92, -54), Vector2(-42, 58), Vector2(44, -52), Vector2(96, 48)]

enum Phase { INACTIVE, CHARGE_IN, BATTLE, CHARGE_OUT }
var phase := Phase.INACTIVE
var phase_remaining := 0.0
var battle_remaining := 0.0
var charge_direction := Vector2.RIGHT
var charge_origin := Vector2.ZERO
var charge_progress := 0.0
var charge_hit_sent := false
var allies: Array[Dictionary] = []
var batches: Array[MaChaoUltimateSystem] = []
var ally_id_offset := 0
var next_ally_id := 0
const MAX_BATTLE_ALLIES := 25
var batch_id := 0
var current_attack_batch_id := 0
var target_provider: Callable
var target_damage: Callable
# 共享追击占用表只记录仍持有目标的副将；owner 用于释放切换/死亡/批次结束的占用。
var target_assignments: Dictionary = {}
var assignment_owners: Dictionary = {}
var standby_slots: Dictionary = {}
var shared_allies: Dictionary = {}
const STANDBY_SLOT_COUNT := 32
const ALLY_SEPARATION_DISTANCE := 28.0
var battlefield_only_named := false
var player_position := Vector2.ZERO
var player_attack := 0.0
var ally_attack_multiplier := ALLY_DAMAGE_MULTIPLIER
var inherited_gale_ratio := 0.0
var inherited_thunder := false
var inherited_flame := false
var battle_view_rect := Rect2(0.0, 0.0, 2560.0, 1440.0)
var entry_start := Vector2.ZERO
var entry_end := Vector2.ZERO
var formation_count := FORMATION_COUNT
var battle_ally_count := BATTLE_ALLY_COUNT
var battle_duration_bonus := 0.0
var constrain_to_trial_arena := false

func configure(target_provider_callback: Callable, target_damage_callback: Callable, trial_arena: bool = false) -> void:
	constrain_to_trial_arena = trial_arena
	target_provider = target_provider_callback
	target_damage = target_damage_callback
	target_assignments.clear()
	assignment_owners.clear()

func configure_target_rules(named_only: bool) -> void:
	battlefield_only_named = named_only
	_release_all_assignments()
	target_assignments.clear()
	assignment_owners.clear()
	for child in batches:
		child.configure_target_rules(named_only)

func start(origin: Vector2, direction: Vector2, attack: float, visible_rect: Rect2 = Rect2(), extra_allies: int = 0, extra_battle_time: float = 0.0, attack_interval_reduction: float = 0.0, gale_ratio: float = 0.0, has_thunder: bool = false, has_flame: bool = false, attack_multiplier: float = ALLY_DAMAGE_MULTIPLIER, preassigned_ally_offset: int = -1, battle_ally_count_override: int = -1) -> bool:
	if phase != Phase.INACTIVE:
		return false
	formation_count = FORMATION_COUNT + clampi(extra_allies, 0, 3)
	battle_ally_count = clampi(battle_ally_count_override, 1, formation_count) if battle_ally_count_override > 0 else BATTLE_ALLY_COUNT + clampi(extra_allies, 0, 3)
	batch_id = next_ally_id if preassigned_ally_offset < 0 else preassigned_ally_offset
	next_ally_id = maxi(next_ally_id, batch_id + formation_count)
	ally_id_offset = batch_id
	current_attack_batch_id = batch_id
	ally_attack_interval_reduction = clampf(attack_interval_reduction, 0.0, 3.0)
	ally_attack_multiplier = clampf(attack_multiplier, ALLY_DAMAGE_MULTIPLIER, 2.0)
	inherited_gale_ratio = clampf(gale_ratio, 0.0, 0.48)
	inherited_thunder = has_thunder
	inherited_flame = has_flame
	battle_duration_bonus = maxf(0.0, extra_battle_time)
	charge_origin = origin
	charge_direction = Vector2.RIGHT if randf() < 0.5 else Vector2.LEFT
	player_position = origin
	battle_view_rect = visible_rect if visible_rect.size.x > 0.0 and visible_rect.size.y > 0.0 else Rect2(origin - Vector2(1280.0, 720.0), Vector2(2560.0, 1440.0))
	var entry_padding := 260.0
	if constrain_to_trial_arena:
		entry_start = _trial_safe_position(origin - charge_direction * 420.0)
		entry_end = _trial_safe_position(origin + charge_direction * 420.0)
	else:
		entry_start = Vector2(battle_view_rect.position.x - entry_padding if charge_direction.x > 0.0 else battle_view_rect.end.x + entry_padding, origin.y)
		entry_end = Vector2(battle_view_rect.end.x + entry_padding if charge_direction.x > 0.0 else battle_view_rect.position.x - entry_padding, origin.y)
	player_attack = attack
	phase = Phase.CHARGE_IN
	phase_remaining = HORSE_DURATION
	charge_progress = 0.0
	charge_hit_sent = false
	_spawn_allies(true)
	started.emit()
	return true

func max_battle_wave_count(revival_rank: int) -> int:
	return 1 + clampi(revival_rank, 0, 2)

func active_battle_ally_count() -> int:
	var count := 0
	for ally in allies:
		if bool(ally.get("is_battle_ally", false)) and str(ally.get("state", "")) != "HIDDEN":
			count += 1
	for child in batches:
		count += child.active_battle_ally_count()
	return count

func active_battle_wave_count() -> int:
	var count := 0
	if phase != Phase.INACTIVE and active_battle_ally_count_local() > 0:
		count += 1
	for child in batches:
		count += child.active_battle_wave_count()
	return count

func active_battle_ally_count_local() -> int:
	var count := 0
	for ally in allies:
		if bool(ally.get("is_battle_ally", false)) and str(ally.get("state", "")) != "HIDDEN":
			count += 1
	return count

func can_start_additional(extra_allies: int, revival_rank: int) -> bool:
	var requested := BATTLE_ALLY_COUNT + clampi(extra_allies, 0, 3)
	var max_waves := max_battle_wave_count(revival_rank)
	var total_capacity := mini(MAX_BATTLE_ALLIES, requested * max_waves)
	return active_battle_wave_count() < max_waves and active_battle_ally_count() + requested <= total_capacity

func start_additional(origin: Vector2, direction: Vector2, attack: float, visible_rect: Rect2, extra_allies: int, extra_battle_time: float, attack_interval_reduction: float, gale_ratio: float, has_thunder: bool, has_flame: bool, attack_multiplier: float, revival_rank: int = 0) -> bool:
	var occupied := active_battle_ally_count()
	var requested := BATTLE_ALLY_COUNT + clampi(extra_allies, 0, 3)
	if not can_start_additional(extra_allies, revival_rank) or occupied >= MAX_BATTLE_ALLIES:
		return false
	requested = mini(requested, MAX_BATTLE_ALLIES - occupied)
	var requested_battle_allies := requested
	if requested <= 0:
		return false
	var child := MaChaoUltimateSystem.new()
	child.configure(target_provider, target_damage, constrain_to_trial_arena)
	child.target_assignments = target_assignments
	child.assignment_owners = assignment_owners
	child.standby_slots = standby_slots
	child.shared_allies = shared_allies
	child.battlefield_only_named = battlefield_only_named
	var assigned_batch_id := next_ally_id
	var child_formation_count := FORMATION_COUNT + (requested_battle_allies - BATTLE_ALLY_COUNT)
	next_ally_id += child_formation_count
	child.charge_attack_requested.connect(_forward_charge_attack.bind(child))
	child.cavalry_attack_requested.connect(_forward_cavalry_attack.bind(child))
	if not child.start(origin, direction, attack, visible_rect, maxi(0, requested_battle_allies - BATTLE_ALLY_COUNT), extra_battle_time, attack_interval_reduction, gale_ratio, has_thunder, has_flame, attack_multiplier, assigned_batch_id, requested_battle_allies):
		return false
	child.current_attack_batch_id = assigned_batch_id
	batches.append(child)
	return true

func tick(delta: float, current_player_position: Vector2, visible_rect: Rect2 = Rect2(), current_gale_ratio: float = -1.0, current_has_thunder: bool = false, current_has_flame: bool = false) -> void:
	for child in batches.duplicate():
		child.battlefield_only_named = battlefield_only_named
		child.tick(delta, current_player_position, visible_rect, current_gale_ratio, current_has_thunder, current_has_flame)
		if not child.is_active():
			child._release_all_assignments()
			batches.erase(child)
	player_position = current_player_position
	if current_gale_ratio >= 0.0:
		inherited_gale_ratio = clampf(current_gale_ratio, 0.0, 0.48)
		inherited_thunder = current_has_thunder
		inherited_flame = current_has_flame
	if visible_rect.size.x > 0.0 and visible_rect.size.y > 0.0:
		battle_view_rect = visible_rect
	if phase == Phase.INACTIVE:
		return
	if phase == Phase.CHARGE_IN:
		phase_remaining = maxf(0.0, phase_remaining - delta)
		charge_progress = 1.0 - phase_remaining / HORSE_DURATION
		_tick_allies_entry(delta)
		if charge_progress >= 0.45 and not charge_hit_sent:
			charge_hit_sent = true
		if phase_remaining <= 0.0:
			phase = Phase.BATTLE
			for ally in allies:
				ally["batch_phase"] = phase
			battle_remaining = BATTLE_DURATION + battle_duration_bonus
			_begin_battle_detach()
		return
	if phase == Phase.BATTLE:
		battle_remaining = maxf(0.0, battle_remaining - delta)
		_tick_allies(delta)
		if battle_remaining <= 0.0:
			phase = Phase.CHARGE_OUT
			_release_all_assignments()
			phase_remaining = RETREAT_DURATION
			charge_direction = Vector2.RIGHT if randf() < 0.5 else Vector2.LEFT
			entry_start = Vector2(player_position.x, player_position.y)
			entry_end = Vector2(battle_view_rect.position.x - 260.0 if charge_direction.x < 0.0 else battle_view_rect.end.x + 260.0, player_position.y)
			charge_progress = 0.0
		return
	if phase == Phase.CHARGE_OUT:
		phase_remaining = maxf(0.0, phase_remaining - delta)
		charge_progress = 1.0 - phase_remaining / RETREAT_DURATION
		_tick_allies_retreat(delta)
		if phase_remaining <= 0.0:
			phase = Phase.INACTIVE
			_release_all_assignments()
			allies.clear()
			if batches.is_empty():
				finished.emit()

func _forward_charge_attack(origin: Vector2, direction: Vector2, distance: float, damage: float, source_batch: MaChaoUltimateSystem = self) -> void:
	current_attack_batch_id = source_batch.batch_id
	charge_attack_requested.emit(origin, direction, distance, damage)

func _forward_cavalry_attack(ally_id: int, target_id: int, target_kind: String, origin: Vector2, direction: Vector2, damage: float, source_batch: MaChaoUltimateSystem = self) -> void:
	current_attack_batch_id = source_batch.batch_id
	cavalry_attack_requested.emit(ally_id, target_id, target_kind, origin, direction, damage)

func is_active() -> bool:
	return phase != Phase.INACTIVE or not batches.is_empty()

func current_attack_batch_id_value() -> int:
	return current_attack_batch_id

func is_charge_active() -> bool:
	return phase == Phase.CHARGE_IN or phase == Phase.CHARGE_OUT

func charge_is_retreating() -> bool:
	return phase == Phase.CHARGE_OUT

func charge_progress_value() -> float:
	return charge_progress

func charge_direction_value() -> Vector2:
	return charge_direction

func sync_inherited_souls(gale_ratio: float, has_thunder: bool, has_flame: bool) -> void:
	if phase == Phase.INACTIVE:
		return
	inherited_gale_ratio = clampf(gale_ratio, 0.0, 0.48)
	inherited_thunder = has_thunder
	inherited_flame = has_flame

func inherited_thunder_active() -> bool:
	return inherited_thunder

func inherited_flame_active() -> bool:
	return inherited_flame

func inherited_gale_attack_ratio() -> float:
	return inherited_gale_ratio * 0.5

func combat_ally(ally_id: int) -> Dictionary:
	if phase == Phase.BATTLE:
		for ally in allies:
			if int(ally.get("id", -1)) == ally_id and bool(ally.get("is_battle_ally", false)) and str(ally.get("state", "")) != "HIDDEN":
				return ally
	for child in batches:
		var found := child.combat_ally(ally_id)
		if not found.is_empty():
			return found
	return {}

func receive_ally_damage(ally_id: int, damage: float) -> bool:
	var ally := combat_ally(ally_id)
	if ally.is_empty():
		return false
	ally["health"] = float(ally.get("health", 100.0)) - maxf(0.0, damage)
	if float(ally["health"]) <= 0.0:
		ally["state"] = "HIDDEN"
		_release_assignment(ally)
		ally["target_id"] = -1
	return true

func active_allies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for ally in allies:
		var snapshot := ally.duplicate(true)
		snapshot["batch_id"] = batch_id
		snapshot["gale_active"] = inherited_gale_ratio > 0.0
		snapshot["gale_attack_events"] = int(ally.get("gale_attack_events", 0))
		snapshot["batch_phase"] = phase
		result.append(snapshot)
	for child in batches:
		result.append_array(child.active_allies())
	return result

func allies_reset() -> void:
	_release_all_assignments()
	target_assignments.clear()
	assignment_owners.clear()
	allies.clear()
	for child in batches:
		child.allies_reset()
	batches.clear()

func _trial_safe_position(value: Vector2) -> Vector2:
	var safe_bounds := BOSS_TRIAL_ARENA_BOUNDS.grow(-BATTLEFIELD_EDGE_PADDING)
	return Vector2(clampf(value.x, safe_bounds.position.x, safe_bounds.end.x), clampf(value.y, safe_bounds.position.y, safe_bounds.end.y))

func _rotated_arrow_offset(offset: Vector2) -> Vector2:
	var forward := charge_direction.normalized()
	var side := Vector2(-forward.y, forward.x)
	return forward * offset.x + side * offset.y

func _formation_offset(index: int) -> Vector2:
	if index < ARROW_OFFSETS.size():
		return ARROW_OFFSETS[index]
	var row := index - ARROW_OFFSETS.size() + 1
	return Vector2(-370.0 - float(row / 2) * 64.0, 54.0 if row % 2 == 0 else -54.0)

func _spawn_allies(entry: bool = false) -> void:
	allies.clear()
	for index in range(formation_count):
		var spawn_position: Vector2 = player_position + _rotated_arrow_offset(_formation_offset(index))
		if entry:
			var entry_distance := 420.0 if constrain_to_trial_arena else 760.0
			spawn_position = player_position - charge_direction * entry_distance + _rotated_arrow_offset(_formation_offset(index))
		if constrain_to_trial_arena:
			spawn_position = _trial_safe_position(spawn_position)
		allies.append({
			"id": ally_id_offset + index,
			"batch_id": batch_id,
			"batch_phase": phase,
			"position": spawn_position,
			"formation_offset": _formation_offset(index),
			"is_battle_ally": false,
			"facing": charge_direction,
			"target": Vector2.ZERO,
			"target_id": -1,
			"attack_remaining": randf_range(0.0, maxf(2.0, ALLY_ATTACK_INTERVAL / (1.0 + inherited_gale_ratio * 0.5) - ally_attack_interval_reduction)),
			"attack_visual": 0.0,
			"target_kind": "enemy",
			"health": 100.0,
			"target_slot": "",
			"target_assignment_key": "",
			"target_hold_remaining": 0.0,
			"wander_phase": randf() * TAU,
			"wander_target": player_position + _formation_offset(index),
			"wander_remaining": randf_range(0.4, 1.4),
		})

func _tick_allies_entry(delta: float) -> void:
	var progress := charge_progress
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		var previous_position: Vector2 = ally.get("position", player_position)
		var offset := _rotated_arrow_offset(_formation_offset(index))
		var target: Vector2 = entry_start.lerp(entry_end, progress) + offset
		if constrain_to_trial_arena:
			target = _trial_safe_position(target)
		ally["position"] = target
		var travel := target - previous_position
		var last_damage_progress := float(ally.get("last_damage_progress", -1.0))
		if travel.length_squared() > 4.0 and (last_damage_progress < 0.0 or progress - last_damage_progress >= 0.10):
			charge_attack_requested.emit(previous_position, travel.normalized(), travel.length() + 62.0, player_attack * 0.42)
			ally["last_damage_progress"] = progress
		ally["facing"] = charge_direction
		ally["state"] = "FORMATION_ENTRY"
		ally["batch_phase"] = phase
		ally["attack_visual"] = 0.0
		allies[index] = ally

func _begin_battle_detach() -> void:
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		var is_battle := index >= 3 and index < 3 + battle_ally_count
		ally["is_battle_ally"] = is_battle
		ally["batch_phase"] = phase
		ally["state"] = "DETACHING" if is_battle else "FORMATION_EXIT"
		var detach_target: Vector2 = ally.get("position", player_position) + _rotated_arrow_offset(Vector2(110.0, float(index - 4) * 42.0))
		ally["detach_target"] = _trial_safe_position(detach_target) if constrain_to_trial_arena else detach_target
		ally["wander_target"] = ally.get("position", player_position)
		allies[index] = ally
		if is_battle:
			shared_allies[int(ally["id"])] = ally

func _tick_allies(delta: float) -> void:
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		if str(ally.get("state", "")) == "HIDDEN":
			_release_assignment(ally)
			continue
		if not bool(ally.get("is_battle_ally", false)):
			_tick_formation_exit(ally, delta)
			allies[index] = ally
			continue
		var position: Vector2 = ally.get("position", player_position)
		var state := str(ally.get("state", "DETACHING"))
		ally["attack_remaining"] = maxf(0.0, float(ally.get("attack_remaining", 0.0)) - delta)
		if state == "ATTACK_DASH":
			var dash_direction: Vector2 = ally.get("dash_direction", ally.get("facing", charge_direction))
			var dash_start: Vector2 = position
			var dash_end: Vector2 = dash_start + dash_direction * 92.0 * delta / 0.20
			if constrain_to_trial_arena:
				dash_end = _trial_safe_position(dash_end)
			ally["position"] = dash_end
			ally["facing"] = dash_direction
			ally["dash_remaining"] = maxf(0.0, float(ally.get("dash_remaining", 0.0)) - delta)
			if not bool(ally.get("dash_hit_sent", false)):
				ally["dash_hit_sent"] = true
				cavalry_attack_requested.emit(int(ally.get("id", -1)), int(ally.get("target_id", -1)), str(ally.get("target_kind", "enemy")), dash_start, dash_direction, player_attack * ally_attack_multiplier)
			if float(ally.get("dash_remaining", 0.0)) <= 0.0:
				ally["state"] = "ATTACK_RECOVERY"
				ally["attack_visual"] = 0.22
			allies[index] = ally
			continue
		if state == "ATTACK_RECOVERY":
			ally["attack_visual"] = maxf(0.0, float(ally.get("attack_visual", 0.0)) - delta)
			if float(ally.get("attack_visual", 0.0)) <= 0.0:
				ally["state"] = "BATTLE"
			allies[index] = ally
			continue
		if state == "DETACHING":

			var detach_target: Vector2 = ally.get("detach_target", position)
			var previous_position: Vector2 = position
			_move_ally(ally, detach_target, delta, 1.15)
			var current_position: Vector2 = ally.get("position", previous_position)
			var reached_detach_target := current_position.distance_to(detach_target) < 18.0
			var blocked_by_trial_boundary := constrain_to_trial_arena and current_position.distance_to(previous_position) < 0.1 and current_position.distance_to(detach_target) > 18.0
			if reached_detach_target or blocked_by_trial_boundary:
				ally["state"] = "BATTLE"
				ally["wander_target"] = current_position
			allies[index] = ally
			continue
		if _tick_view_return(ally, delta):
			ally["state"] = "VIEW_RETURN"
			_move_ally(ally, _comfortable_position(ally.get("view_return_target", position)), delta)
			allies[index] = ally
			continue
		ally["target_hold_remaining"] = maxf(0.0, float(ally.get("target_hold_remaining", 0.0)) - delta)
		var target: Dictionary = _find_target(position, int(ally.get("id", index)), ally)
		var desired: Vector2 = ally.get("wander_target", position)
		var player_distance := position.distance_to(player_position)
		if target.is_empty() and player_distance > ALLY_RETURN_DISTANCE:
			desired = player_position + _rotated_arrow_offset(_formation_offset(index))
			ally["wander_target"] = desired
			ally["wander_remaining"] = 1.0
		elif not target.is_empty():
			var target_position: Vector2 = target.get("position", position)
			ally["target"] = target_position
			ally["target_id"] = int(target.get("id", -1))
			ally["target_kind"] = str(target.get("kind", "enemy"))
			if float(ally.get("attack_remaining", 0.0)) <= 0.0 and not bool(target.get("invulnerable", false)):
				ally["state"] = "APPROACH"
				var to_target := target_position - position
				if to_target.length() > ALLY_STANDBY_DISTANCE:
					desired = target_position - to_target.normalized() * (ALLY_STANDBY_DISTANCE - 4.0)
				else:
					_start_attack_dash(ally, to_target.normalized())
			else:
				ally["state"] = "BATTLE"
				desired = _standby_position(ally, target_position)
		else:
			ally["target_id"] = -1
			ally["target_kind"] = "enemy"
			ally["wander_remaining"] = maxf(0.0, float(ally.get("wander_remaining", 0.0)) - delta)
			if float(ally.get("wander_remaining", 0.0)) <= 0.0:
				var wander_phase := float(ally.get("wander_phase", 0.0)) + randf_range(-0.65, 0.65)
				ally["wander_phase"] = wander_phase
				ally["wander_target"] = position + Vector2.from_angle(wander_phase) * randf_range(64.0, 104.0)
				ally["wander_remaining"] = randf_range(1.2, 2.0)
			desired = ally.get("wander_target", desired)
		if target.is_empty() or str(ally.get("state", "")) == "BATTLE":
			desired = _comfortable_position(desired)
		_move_ally(ally, desired, delta)
		_separate_ally(ally, delta)
		ally["attack_visual"] = maxf(0.0, float(ally.get("attack_visual", 0.0)) - delta)
		allies[index] = ally

func _tick_formation_exit(ally: Dictionary, delta: float) -> void:
	var position: Vector2 = ally.get("position", player_position)
	ally["position"] = position + charge_direction * 420.0 * delta
	ally["facing"] = charge_direction
	var exit_x := battle_view_rect.end.x + 220.0 if charge_direction.x > 0.0 else battle_view_rect.position.x - 220.0
	if (charge_direction.x > 0.0 and position.x >= exit_x) or (charge_direction.x < 0.0 and position.x <= exit_x):
		ally["state"] = "HIDDEN"

func _tick_allies_retreat(delta: float) -> void:
	for index in range(allies.size()):
		var ally: Dictionary = allies[index]
		if str(ally.get("state", "")) == "HIDDEN":
			_release_assignment(ally)
			continue
		if not bool(ally.get("is_battle_ally", false)):
			_tick_formation_exit(ally, delta)
			allies[index] = ally
			continue
		_move_ally(ally, player_position + charge_direction * (720.0 + float(index) * 18.0), delta, 1.9)
		allies[index] = ally

func _standby_position(ally: Dictionary, target_position: Vector2) -> Vector2:
	var ally_id := int(ally.get("id", 0))
	var slot := int(ally.get("standby_slot", -1))
	if slot >= 0 and constrain_to_trial_arena:
		var old_position := target_position + Vector2.from_angle(TAU * float(slot) / float(STANDBY_SLOT_COUNT)) * ALLY_STANDBY_DISTANCE
		if old_position.distance_to(_trial_safe_position(old_position)) > 2.0:
			standby_slots.erase(slot)
			slot = -1
	if slot < 0 or not standby_slots.has(slot) or int(standby_slots.get(slot, -1)) != ally_id:
		var best_slot := -1
		var best_score := INF
		for candidate in range(STANDBY_SLOT_COUNT):
			if standby_slots.has(candidate) and int(standby_slots[candidate]) != ally_id:
				continue
			var angle := TAU * float(candidate) / float(STANDBY_SLOT_COUNT)
			var slot_position := target_position + Vector2.from_angle(angle) * ALLY_STANDBY_DISTANCE
			var boundary_penalty := slot_position.distance_squared_to(_comfortable_position(slot_position)) * 1000.0
			var spacing := 16
			for used_slot in standby_slots.keys():
				var gap := absi(candidate - int(used_slot))
				spacing = mini(spacing, mini(gap, STANDBY_SLOT_COUNT - gap))
			var score := slot_position.distance_squared_to(ally.get("position", slot_position)) * 0.001 + boundary_penalty - float(spacing) * 1000.0
			if score < best_score:
				best_score = score
				best_slot = candidate
		if best_slot >= 0:
			if slot >= 0:
				standby_slots.erase(slot)
			standby_slots[best_slot] = ally_id
			ally["standby_slot"] = best_slot
			slot = best_slot
	if slot < 0:
		slot = posmod(ally_id, STANDBY_SLOT_COUNT)
		standby_slots[slot] = ally_id
		ally["standby_slot"] = slot
	return target_position + Vector2.from_angle(TAU * float(slot) / float(STANDBY_SLOT_COUNT)) * ALLY_STANDBY_DISTANCE

func _separate_ally(ally: Dictionary, delta: float) -> void:
	var position: Vector2 = ally.get("position", player_position)
	var push := Vector2.ZERO
	for other_id in shared_allies.keys():
		if int(other_id) == int(ally.get("id", -1)):
			continue
		var other: Dictionary = shared_allies[other_id]
		var offset: Vector2 = position - other.get("position", position)
		var distance := offset.length()
		if distance <= 0.01:
			var pair_angle := TAU * float(mini(int(other_id), int(ally.get("id", 0))) % STANDBY_SLOT_COUNT) / float(STANDBY_SLOT_COUNT)
			push += Vector2.from_angle(pair_angle) * (1.0 if int(ally.get("id", 0)) > int(other_id) else -1.0)
		elif distance < ALLY_SEPARATION_DISTANCE:
			push += offset.normalized() * (ALLY_SEPARATION_DISTANCE - distance) / ALLY_SEPARATION_DISTANCE
	if push.length_squared() > 0.01:
		var separated := position + push.normalized() * minf(ALLY_MOVE_SPEED * delta * 0.45, push.length() * 10.0)
		ally["position"] = _trial_safe_position(separated) if constrain_to_trial_arena else separated
	shared_allies[int(ally.get("id", -1))] = ally

func _move_ally(ally: Dictionary, desired: Vector2, delta: float, speed_scale: float = 1.0) -> void:
	if str(ally.get("state", "")) == "ATTACK_DASH":
		return
	var position: Vector2 = ally.get("position", player_position)
	var movement := desired - position
	var deadzone := ALLY_STANDBY_DEADZONE if str(ally.get("state", "")) == "BATTLE" else 2.0
	if movement.length() <= deadzone:
		return
	var direction := movement.normalized()
	var previous_direction: Vector2 = ally.get("move_direction", direction)
	var turn_weight := clampf(ALLY_FACING_TURN_SPEED * delta, 0.0, 1.0)
	var smooth_direction := Vector2.from_angle(lerp_angle(previous_direction.angle(), direction.angle(), turn_weight))
	ally["move_direction"] = smooth_direction
	var facing: Vector2 = ally.get("facing", smooth_direction)
	if absf(angle_difference(facing.angle(), smooth_direction.angle())) > 0.10:
		ally["facing"] = Vector2.from_angle(lerp_angle(facing.angle(), smooth_direction.angle(), turn_weight))
	var next_position := position + smooth_direction * minf(ALLY_MOVE_SPEED * speed_scale * delta, movement.length() - deadzone)
	ally["position"] = _trial_safe_position(next_position) if constrain_to_trial_arena else next_position

func _start_attack_dash(ally: Dictionary, direction: Vector2) -> void:
	if direction.length_squared() <= 0.01:
		direction = ally.get("facing", charge_direction)
	ally["state"] = "ATTACK_DASH"
	ally["dash_direction"] = direction.normalized()
	ally["dash_remaining"] = 0.20
	ally["dash_hit_sent"] = false
	if inherited_gale_ratio > 0.0:
		gale_attack_events += 1
		ally["gale_attack_events"] = int(ally.get("gale_attack_events", 0)) + 1
	ally["facing"] = direction.normalized()
	ally["attack_remaining"] = maxf(2.0, ALLY_ATTACK_INTERVAL / (1.0 + inherited_gale_ratio * 0.5) - ally_attack_interval_reduction)

func _attack_if_ready(ally: Dictionary, direction: Vector2, delta: float) -> void:
	var remaining := float(ally.get("attack_remaining", 0.0))
	if remaining > 0.0:
		ally["attack_remaining"] = maxf(0.0, remaining - delta)
		return
	var facing: Vector2 = ally.get("facing", charge_direction)
	var attack_direction := direction if direction.length_squared() > 0.01 else facing
	ally["facing"] = attack_direction
	ally["attack_remaining"] = maxf(2.0, ALLY_ATTACK_INTERVAL / (1.0 + inherited_gale_ratio * 0.5) - ally_attack_interval_reduction)
	ally["attack_visual"] = 0.32
	var target_kind := str(ally.get("target_kind", "enemy"))
	cavalry_attack_requested.emit(int(ally.get("id", -1)), int(ally.get("target_id", -1)), target_kind, ally.get("position", player_position), attack_direction, player_attack * ally_attack_multiplier)

func _assignment_key(target: Dictionary) -> String:
	return "%s:%d" % [str(target.get("kind", "enemy")), int(target.get("id", -1))]

func _release_assignment(ally: Dictionary) -> void:
	var ally_id := int(ally.get("id", -1))
	var key := str(assignment_owners.get(ally_id, ""))
	if not key.is_empty():
		var remaining := int(target_assignments.get(key, 0)) - 1
		if remaining <= 0:
			target_assignments.erase(key)
		else:
			target_assignments[key] = remaining
		assignment_owners.erase(ally_id)
	var slot := int(ally.get("standby_slot", -1))
	if slot >= 0 and int(standby_slots.get(slot, -1)) == ally_id:
		standby_slots.erase(slot)
	ally["standby_slot"] = -1
	if str(ally.get("state", "")) == "HIDDEN" or phase != Phase.BATTLE:
		shared_allies.erase(ally_id)
	ally["target_assignment_key"] = ""
	ally["target_hold_remaining"] = 0.0

func _release_all_assignments() -> void:
	for ally in allies:
		_release_assignment(ally)
		shared_allies.erase(int(ally.get("id", -1)))

func _find_target(position: Vector2, ally_id: int, ally: Dictionary = {}) -> Dictionary:
	if not target_provider.is_valid():
		_release_assignment(ally if not ally.is_empty() else {"id": ally_id})
		return {}
	var ally_candidates_value = target_provider.call(position, ALLY_SEARCH_RADIUS, true)
	var candidates: Array = ally_candidates_value as Array if ally_candidates_value is Array else []
	var target_source_priority := 2.0
	if candidates.is_empty():
		var player_candidates_value = target_provider.call(player_position, ALLY_SEARCH_RADIUS, true)
		candidates = player_candidates_value as Array if player_candidates_value is Array else []
		target_source_priority = 1.0
	var old_key := str(assignment_owners.get(ally_id, ""))
	var held: Dictionary = {}
	for value in candidates:
		if value is Dictionary:
			var candidate: Dictionary = value as Dictionary
			if _assignment_key(candidate) == old_key and (not battlefield_only_named or str(candidate.get("kind", "enemy")) != "enemy"):
				var at: Vector2 = candidate.get("position", position)
				if position.distance_to(at) <= ALLY_SEARCH_RADIUS and float(candidate.get("health", 1.0)) > 0.0:
					held = candidate
	if not held.is_empty() and float(ally.get("target_hold_remaining", 0.0)) > 0.0:
		return held
	var owner := ally if not ally.is_empty() else {"id": ally_id}
	if candidates.is_empty():
		_release_assignment(owner)
		return {}
	var best: Dictionary = {}
	var best_score := -INF
	for candidate_value in candidates:
		if not candidate_value is Dictionary:
			continue
		var candidate: Dictionary = candidate_value as Dictionary
		var candidate_kind := str(candidate.get("kind", "enemy"))
		if battlefield_only_named and candidate_kind == "enemy":
			continue
		var target_id := int(candidate.get("id", -1))
		var target_position_value = candidate.get("position", Vector2.ZERO)
		if target_id < 0 or not target_position_value is Vector2:
			continue
		var target_position: Vector2 = target_position_value
		var offset := target_position - player_position
		var desired_direction: Vector2 = BATTLE_OFFSETS[mini(maxi(ally_id - 3, 0), BATTLE_OFFSETS.size() - 1)].normalized()
		var direction_score := desired_direction.dot(offset.normalized()) * 90.0 if offset.length_squared() > 0.01 else 0.0
		var distance_to_player_score := -player_position.distance_to(target_position) * 0.02
		var distance_to_ally_score := -position.distance_to(target_position) * 1.0
		var priority_score := 1000.0 if str(candidate.get("kind", "enemy")) == "boss" else (700.0 if str(candidate.get("kind", "enemy")) == "elite" else 100.0)
		var kind := str(candidate.get("kind", "enemy"))
		if float(candidate.get("health", 1.0)) <= 0.0:
			continue
		var assigned := int(target_assignments.get("%s:%d" % [kind, target_id], 0))
		var source_score := target_source_priority * 80.0
		var invulnerability_penalty := 10000.0 if bool(candidate.get("invulnerable", false)) else 0.0
		var score := priority_score + direction_score + distance_to_player_score + distance_to_ally_score + source_score - float(assigned) * 80.0 - invulnerability_penalty
		if _assignment_key(candidate) == old_key:
			score += 180.0
		if score > best_score:
			best_score = score
			best = candidate.duplicate()
	if not best.is_empty() and _assignment_key(best) == old_key:
		ally["target_hold_remaining"] = ALLY_TARGET_HOLD_DURATION
		return best
	_release_assignment(owner)
	if not best.is_empty():
		var assignment_key := _assignment_key(best)
		target_assignments[assignment_key] = int(target_assignments.get(assignment_key, 0)) + 1
		assignment_owners[ally_id] = assignment_key
		if not ally.is_empty():
			ally["target_assignment_key"] = assignment_key
			ally["target_hold_remaining"] = ALLY_TARGET_HOLD_DURATION
	return best
