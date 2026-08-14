class_name RunScene
extends Node2D

const WORLD_BOUNDS := Rect2(0, 0, 2560, 1440)
const BOWANGPO_WORLD_BOUNDS := Rect2(0, 0, 2304, 1248)
const BOSS_TRIAL_WORLD_BOUNDS := Rect2(0, 0, 1920, 1080)
const CAMERA_LOOK_AHEAD := 68.0
const NAMED_SPAWN_MARGIN := 72.0
const ELITE_SPAWN_MIN_DISTANCE := 420.0
const ELITE_SPAWN_MAX_DISTANCE := 560.0
const BOSS_SPAWN_MIN_DISTANCE := 560.0
const BOSS_SPAWN_MAX_DISTANCE := 720.0
const BOSS_TRIAL_ELITE_SPAWN_MIN_DISTANCE := 280.0
const BOSS_TRIAL_ELITE_SPAWN_MAX_DISTANCE := 390.0
const BOSS_TRIAL_BOSS_SPAWN_MIN_DISTANCE := 340.0
const BOSS_TRIAL_BOSS_SPAWN_MAX_DISTANCE := 450.0
const NAMED_SPAWN_SEPARATION := 230.0
const ENEMY_VOICE_INTERVAL_MIN := 20.0
const ENEMY_VOICE_INTERVAL_MAX := 30.0
const ELITE_ACTOR_SCENE := preload("res://scenes/actors/elite_actor.tscn")
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")
const BATTLE_WEATHER_MODES := ["sunny", "rain", "storm"]
const BOSS_TRIAL_STARTING_UPGRADES := 3
const BOSS_TRIAL_ELITE_LEVEL_REWARD := 3
const UPGRADE_REFRESH_LIMIT := 2
const WEAPON_CLASH_WINDOW := 0.28
const PERFECT_WEAPON_CLASH_WINDOW := 0.10
const NORMAL_CLASH_STANCE_DAMAGE := 18.0
const PERFECT_CLASH_STANCE_DAMAGE := 58.0
const NORMAL_SKILL_CLASH_STANCE_DAMAGE := 27.0
const PERFECT_SKILL_CLASH_STANCE_DAMAGE := 87.0
const CLASH_TIME_SCALE := 0.50
const NORMAL_CLASH_SLOW_DURATION := 0.35
const EMPHATIC_CLASH_SLOW_DURATION := 0.50

@onready var renderer: BattleRenderer = $BattleRenderer
@onready var player: HeroActor = $Player
var battle_camera: Camera2D
@onready var boss: BossActor = $Boss
@onready var enemies: EnemySimulation = $EnemySimulation
@onready var combat: CombatSystem = $CombatSystem
@onready var upgrades: UpgradeSystem = $UpgradeSystem
@onready var tianji: TianjiSystem = $TianjiSystem
@onready var director: RunDirector = $RunDirector
@onready var loot = $LootSystem
@onready var input_router: InputRouter = $InputRouter
@onready var hud: BattleHud = $HudLayer/BattleHud
@onready var ultimate_cutin: UltimateCutin = $UltimateCutinLayer/UltimateCutin

var telegraphs: Array[Telegraph] = []
var elites: Array[EliteActor] = []
var upgrade_open := false
var finished := false
var paused := false
var player_death_cinematic_active := false
var pending_defeat_message := ""
var hitstop_remaining := 0.0
var clash_slow_remaining := 0.0
var run_gold := 0
var run_merit_fraction := 0.0
var queued_level_ups: Array[int] = []
var run_mode := "story"
var action_audio_hits: Dictionary = {}
var move_sound_cooldown := 0.0
var player_last_audio_position := Vector2.ZERO
var enemy_voice_remaining := 0.0
var active_world_bounds := WORLD_BOUNDS
var active_obstacles: Array[Rect2] = []
var boss_trial_upgrades_remaining := 0
var boss_trial_advance_after_upgrade := false
var boss_trial_advance_after_levels := false
var player_action_clash_consumed := false
var upgrade_refreshes_remaining := UPGRADE_REFRESH_LIMIT
var current_upgrade_level := 1
var current_upgrade_options: Array[String] = []

func _ready() -> void:
	AudioService.stop_hero_firewheel_loop()
	AudioService.play_battle_bgm()
	upgrade_refreshes_remaining = UPGRADE_REFRESH_LIMIT
	var profile := SaveService.load_profile()
	run_mode = SceneRouter.active_mode
	active_world_bounds = _world_bounds_for_mode(run_mode)
	active_obstacles = BATTLEFIELD_LAYOUT.obstacle_rects_for(_active_battlefield_id(), active_world_bounds)
	boss_trial_advance_after_levels = false
	_install_equipped_hero(SaveService.equipped_hero_id())
	boss.set_movement_bounds(active_world_bounds.grow(-NAMED_SPAWN_MARGIN))
	enemies.reset(active_world_bounds, run_mode)
	enemies.set_navigation_obstacles(active_obstacles)
	loot.reset()
	player.reset_for_run(active_world_bounds)
	player.position = _resolve_movement_against_obstacles(player.position, player.position, 16.0)
	player_last_audio_position = player.position
	enemy_voice_remaining = randf_range(ENEMY_VOICE_INTERVAL_MIN, ENEMY_VOICE_INTERVAL_MAX)
	player.apply_account_progress(profile)
	loot.configure_account_progress(profile)
	_configure_battle_camera()
	director.reset(active_world_bounds, run_mode, _active_battlefield_id(), SceneRouter.active_story_chapter)
	if director.is_boss_trial():
		for _level in range(2, director.level + 1):
			player.apply_level_up_benefits()
	enemies.set_threat_tier(director.threat_tier())
	upgrades.configure_talent_pool(profile, player.hero_id)
	upgrades.configure_tianji_pool(profile)
	upgrades.seed_with(20260712)
	renderer.configure(active_world_bounds, enemies, player, boss, telegraphs, loot, elites, _active_battlefield_id())
	renderer.set_weather_mode(_battle_weather_for(profile))
	tianji.configure(player, enemies, elites, boss)
	hud.configure(player, boss, director, elites, tianji)
	if not active_obstacles.is_empty():
		hud.set_message("%s · 已载入 %d 处地形障碍" % [BATTLEFIELD_LAYOUT.title_for(_active_battlefield_id()), active_obstacles.size()])
	hud.set_upgrade_refreshes_remaining(upgrade_refreshes_remaining)
	input_router.configure(player, hud)
	player.attack_requested.connect(_on_player_attack)
	player.combat_action_started.connect(_on_player_combat_action_started)
	player.combat_action_finished.connect(_on_player_combat_action_finished)
	player.ultimate_ready.connect(_on_ultimate_ready)
	player.ultimate_started.connect(_on_ultimate_started)
	player.died.connect(_on_player_died)
	enemies.enemy_died.connect(_on_enemy_died)
	loot.collected.connect(_on_loot_collected)
	enemies.enemy_attack_requested.connect(_on_enemy_attack)
	enemies.enemy_attack_cancelled.connect(_on_enemy_attack_cancelled)
	enemies.enemy_death_collision.connect(_on_enemy_death_collision)
	enemies.banner_command_requested.connect(_on_banner_command)
	director.spawn_requested.connect(_on_spawn_requested)
	director.elite_requested.connect(_on_elite_requested)
	director.boss_requested.connect(_on_boss_requested)
	director.level_up.connect(_on_level_up)
	director.stage_changed.connect(hud.set_message)
	director.threat_tier_changed.connect(_on_threat_tier_changed)
	boss.telegraph_requested.connect(_add_telegraph)
	boss.skill_impact_requested.connect(_on_named_skill_impact)
	boss.summon_requested.connect(_on_boss_summon)
	boss.phase_changed.connect(_on_boss_phase)
	boss.defeated.connect(_on_boss_defeated)
	tianji.skill_windup_started.connect(_on_tianji_windup_started)
	tianji.skill_impacted.connect(_on_tianji_impacted)
	hud.upgrade_selected.connect(_on_upgrade_selected)
	hud.upgrade_refresh_requested.connect(_on_upgrade_refresh_requested)
	hud.restart_requested.connect(_on_restart_requested)
	hud.resume_requested.connect(_on_resume_requested)
	hud.home_requested.connect(_on_home_requested)
	input_router.basic_requested.connect(player.request_basic)
	input_router.basic_hold_started.connect(player.begin_basic_hold)
	input_router.basic_hold_released.connect(player.release_basic_hold)
	input_router.active_requested.connect(player.request_active)
	input_router.ultimate_requested.connect(_on_ultimate_requested)
	input_router.weapon_stance_requested.connect(_on_weapon_stance_requested)
	input_router.pause_requested.connect(_on_pause_requested)
	if director.is_boss_trial():
		call_deferred("_start_boss_trial")

func _exit_tree() -> void:
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_battle_bgm()

func _install_equipped_hero(requested_hero_id: String) -> void:
	var hero_id := requested_hero_id if HERO_CATALOG.is_playable(requested_hero_id) else "zhao_yun"
	var actor_scene_path := HERO_CATALOG.actor_scene_for(hero_id)
	if actor_scene_path.is_empty():
		push_warning("No playable actor scene configured for %s; falling back to Zhao Yun." % hero_id)
		hero_id = "zhao_yun"
		actor_scene_path = HERO_CATALOG.actor_scene_for(hero_id)
	if player.scene_file_path != actor_scene_path:
		var actor_scene := load(actor_scene_path) as PackedScene
		var replacement := actor_scene.instantiate() as HeroActor if actor_scene != null else null
		if replacement == null:
			push_error("Failed to create hero actor from %s." % actor_scene_path)
			return
		var previous_player := player
		var player_index := previous_player.get_index()
		previous_player.get_parent().remove_child(previous_player)
		add_child(replacement)
		move_child(replacement, player_index)
		replacement.name = "Player"
		player = replacement
		previous_player.queue_free()
	player.configure_hero(hero_id)
	battle_camera = player.get_node_or_null("BattleCamera") as Camera2D
	if battle_camera == null:
		push_error("Hero actor %s must provide a BattleCamera child." % hero_id)

func _process(delta: float) -> void:
	if paused:
		return
	if finished or upgrade_open:
		return
	if player_death_cinematic_active:
		renderer.tick_player_death_cinematic(delta)
		if renderer.is_player_death_cinematic_finished():
			player_death_cinematic_active = false
			_finish_run(false, pending_defeat_message)
		return
	_update_named_target_indicators()
	_tick_enemy_battle_voice(delta)
	clash_slow_remaining = maxf(0.0, clash_slow_remaining - delta)
	var clash_time_scale := CLASH_TIME_SCALE if clash_slow_remaining > 0.0 else 1.0
	var simulation_delta := delta * ultimate_cutin.combat_time_scale() * clash_time_scale
	if hitstop_remaining > 0.0:
		hitstop_remaining = maxf(0.0, hitstop_remaining - delta)
		renderer.queue_redraw()
		return
	renderer.tick_visuals(simulation_delta)
	var move_direction := input_router.movement_direction()
	var player_move_origin := player.position
	player.tick(simulation_delta, move_direction)
	player.position = _resolve_movement_against_obstacles(player_move_origin, player.position, 16.0)
	_tick_player_action_clash()
	_tick_player_move_audio(simulation_delta, move_direction)
	_update_battle_camera(simulation_delta)
	director.tick(delta, enemies.active_count, player.position)
	enemies.set_battle_elapsed(director.elapsed)
	var enemy_move_origins := _capture_enemy_positions()
	enemies.tick(simulation_delta, player.position)
	_resolve_enemy_obstacles(enemy_move_origins)
	var nearby_enemy_count := enemies.count_active_within(player.position, 184.0)
	for elite in elites:
		if is_instance_valid(elite) and elite.active and elite.position.distance_to(player.position) <= 184.0:
			nearby_enemy_count += 1
	if boss.active and boss.position.distance_to(player.position) <= 184.0:
		nearby_enemy_count += 1
	player.set_nearby_enemy_count(nearby_enemy_count)
	loot.tick(simulation_delta, player.position)
	var named_move_origins := _capture_named_positions()
	_tick_named_enemies(simulation_delta)
	_resolve_named_obstacles(named_move_origins)
	tianji.tick(simulation_delta)
	_tick_telegraphs(simulation_delta)
	if director.is_time_over():
		if run_mode == "story":
			if director.story_requires_boss_defeat() and boss.active:
				_finish_run(false, "未能击破张郃，长坂坡防线失守")
			elif not boss.active:
				_finish_run(true, director.story_completion_message())
		elif not boss.active:
			_finish_run(true, "无尽试炼完成，军功已结算")

func _on_spawn_requested(enemy_type: int, at: Vector2) -> void:
	enemies.spawn(enemy_type, at)

func _on_threat_tier_changed(tier: int) -> void:
	enemies.set_threat_tier(tier)

func _world_bounds_for_mode(mode: String) -> Rect2:
	if mode == RunDirector.BOSS_TRIAL_MODE:
		return BOSS_TRIAL_WORLD_BOUNDS
	return BOWANGPO_WORLD_BOUNDS if _active_battlefield_id() == "bowangpo" else WORLD_BOUNDS

func _active_battlefield_id() -> String:
	return SceneRouter.active_battlefield_id if SceneRouter.active_battlefield_id in ["changban", "xinye", "bowangpo", "bowangpo_story", "hulao"] else "changban"

func _capture_enemy_positions() -> Array[Vector2]:
	var origins: Array[Vector2] = []
	origins.resize(EnemySimulation.CAPACITY)
	for enemy_id in range(EnemySimulation.CAPACITY):
		origins[enemy_id] = enemies.positions[enemy_id]
	return origins

func _capture_named_positions() -> Dictionary:
	var origins: Dictionary = {}
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			origins[elite.get_instance_id()] = elite.position
	if boss.active:
		origins[boss.get_instance_id()] = boss.position
	return origins

func _resolve_enemy_obstacles(origins: Array[Vector2]) -> void:
	if active_obstacles.is_empty():
		return
	for enemy_id in range(EnemySimulation.CAPACITY):
		if enemies.is_active(enemy_id):
			var origin := origins[enemy_id] if enemy_id < origins.size() else enemies.positions[enemy_id]
			var destination := enemies.positions[enemy_id]
			var resolved := _resolve_movement_against_obstacles(origin, destination, _enemy_collision_radius(enemies.get_type(enemy_id)))
			if destination.distance_to(origin) > 2.0 and resolved.distance_to(origin) < destination.distance_to(origin) * 0.55:
				enemies.mark_navigation_blocked(enemy_id)
			enemies.positions[enemy_id] = resolved

func _resolve_named_obstacles(origins: Dictionary) -> void:
	if active_obstacles.is_empty():
		return
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			var origin: Vector2 = origins.get(elite.get_instance_id(), elite.position) as Vector2
			elite.position = _resolve_movement_against_obstacles(origin, elite.position, 22.0)
	if boss.active:
		var boss_origin: Vector2 = origins.get(boss.get_instance_id(), boss.position) as Vector2
		boss.position = _resolve_movement_against_obstacles(boss_origin, boss.position, 26.0)

func _resolve_movement_against_obstacles(origin: Vector2, destination: Vector2, radius: float) -> Vector2:
	if active_obstacles.is_empty():
		return destination
	var resolved := BATTLEFIELD_LAYOUT.move_with_obstacles(origin, destination, active_obstacles, radius)
	return Vector2(
		clampf(resolved.x, active_world_bounds.position.x + radius, active_world_bounds.end.x - radius),
		clampf(resolved.y, active_world_bounds.position.y + radius, active_world_bounds.end.y - radius)
	)

func _enemy_collision_radius(enemy_type: int) -> float:
	match enemy_type:
		EnemySimulation.EnemyType.CAVALRY:
			return 28.0
		EnemySimulation.EnemyType.BANNER:
			return 24.0
		EnemySimulation.EnemyType.SHIELD, EnemySimulation.EnemyType.HALBERD:
			return 20.0
		_:
			return 17.0

func _battle_weather_for(profile: Dictionary) -> String:
	var settings: Dictionary = profile.get("settings", {}) as Dictionary
	var selected_mode := str(settings.get("weather_mode", "auto"))
	if selected_mode in BATTLE_WEATHER_MODES:
		return selected_mode
	return BATTLE_WEATHER_MODES[randi() % BATTLE_WEATHER_MODES.size()]

func _on_elite_requested(elite_id: String, _scheduled_at: Vector2) -> void:
	if elites.size() >= 4:
		return
	var elite := ELITE_ACTOR_SCENE.instantiate() as EliteActor
	add_child(elite)
	var archetype: EliteActor.Archetype = EliteActor.Archetype.XIAHOU_EN
	match elite_id:
		"chunyu_dao": archetype = EliteActor.Archetype.CHUNYU_DAO
		"xiahou_lan": archetype = EliteActor.Archetype.XIAHOU_LAN
		"han_hao": archetype = EliteActor.Archetype.HAN_HAO
	var spawn_min_distance := ELITE_SPAWN_MIN_DISTANCE
	var spawn_max_distance := ELITE_SPAWN_MAX_DISTANCE
	var threat_tier := director.threat_tier()
	if director.is_boss_trial():
		spawn_min_distance = BOSS_TRIAL_ELITE_SPAWN_MIN_DISTANCE
		spawn_max_distance = BOSS_TRIAL_ELITE_SPAWN_MAX_DISTANCE
		threat_tier = 1 if archetype == EliteActor.Archetype.XIAHOU_EN else 2
	elite.activate(archetype, _choose_named_spawn(spawn_min_distance, spawn_max_distance), threat_tier)
	elite.telegraph_requested.connect(_on_elite_telegraph)
	elite.skill_impact_requested.connect(_on_named_skill_impact)
	elite.defeated.connect(_on_elite_defeated)
	elites.append(elite)
	renderer.set_elites(elites)
	hud.set_elites(elites)
	hud.set_message("精英现身：%s" % elite.display_name())

func _configure_battle_camera() -> void:
	battle_camera.limit_left = int(active_world_bounds.position.x)
	battle_camera.limit_top = int(active_world_bounds.position.y)
	battle_camera.limit_right = int(active_world_bounds.end.x)
	battle_camera.limit_bottom = int(active_world_bounds.end.y)
	battle_camera.position = Vector2(player.last_attack_direction.x * CAMERA_LOOK_AHEAD, 0.0)
	battle_camera.make_current()
	battle_camera.reset_smoothing()
	battle_camera.force_update_scroll()

func _update_battle_camera(delta: float) -> void:
	var target_offset := player.last_attack_direction.x * CAMERA_LOOK_AHEAD
	battle_camera.position.x = move_toward(battle_camera.position.x, target_offset, 300.0 * delta)

func _update_named_target_indicators() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var zoom := battle_camera.zoom
	var visible_world_size := Vector2(
		viewport_size.x / maxf(0.01, zoom.x),
		viewport_size.y / maxf(0.01, zoom.y)
	)
	var screen_center := battle_camera.get_screen_center_position()
	var visible_world_rect := Rect2(screen_center - visible_world_size * 0.5, visible_world_size)
	var targets: Array[Dictionary] = []
	if boss.active and _is_named_target_offscreen(boss.position, visible_world_rect):
		targets.append(_named_target_indicator(boss.position, screen_center, "boss"))
	for elite in elites:
		if not is_instance_valid(elite) or not elite.active:
			continue
		if _is_named_target_offscreen(elite.position, visible_world_rect):
			var kind := _elite_indicator_kind(elite.archetype)
			targets.append(_named_target_indicator(elite.position, screen_center, kind))
	hud.set_named_target_indicators(targets)

func _is_named_target_offscreen(target_position: Vector2, visible_world_rect: Rect2) -> bool:
	return not visible_world_rect.grow(-32.0).has_point(target_position)

func _named_target_indicator(target_position: Vector2, screen_center: Vector2, kind: String) -> Dictionary:
	var direction := (target_position - screen_center).normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.UP
	return {"direction": direction, "kind": kind}

func _elite_indicator_kind(archetype: EliteActor.Archetype) -> String:
	match archetype:
		EliteActor.Archetype.CHUNYU_DAO: return "elite_chunyu"
		EliteActor.Archetype.XIAHOU_LAN: return "elite_xiahou_lan"
		EliteActor.Archetype.HAN_HAO: return "elite_han_hao"
	return "elite_xiahou"

func _on_boss_requested(_scheduled_at: Vector2) -> void:
	var spawn_min_distance := BOSS_SPAWN_MIN_DISTANCE
	var spawn_max_distance := BOSS_SPAWN_MAX_DISTANCE
	var threat_tier := director.threat_tier()
	if director.is_boss_trial():
		spawn_min_distance = BOSS_TRIAL_BOSS_SPAWN_MIN_DISTANCE
		spawn_max_distance = BOSS_TRIAL_BOSS_SPAWN_MAX_DISTANCE
		threat_tier = 3
	boss.set_archetype(BossActor.Archetype.XIAHOU_DUN if director.boss_archetype_id() == "xiahou_dun" else BossActor.Archetype.ZHANG_HE)
	boss.activate(_choose_named_spawn(spawn_min_distance, spawn_max_distance), threat_tier)
	hud.set_message("%s·%s 现身" % [boss.display_name(), boss.weapon_title()])

func _choose_named_spawn(min_distance: float, max_distance: float) -> Vector2:
	for _attempt in range(18):
		var direction := Vector2.from_angle(randf_range(0.0, TAU))
		var candidate := _clamp_named_spawn(player.position + direction * randf_range(min_distance, max_distance))
		if candidate.distance_to(player.position) < min_distance * 0.88:
			continue
		if _is_named_spawn_clear(candidate):
			return candidate
	var directions: Array[Vector2] = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]
	var start_index := randi_range(0, directions.size() - 1)
	for offset in range(directions.size()):
		var fallback := _clamp_named_spawn(player.position + directions[(start_index + offset) % directions.size()] * min_distance)
		if fallback.distance_to(player.position) >= min_distance * 0.75 and _is_named_spawn_clear(fallback):
			return fallback
	return _clamp_named_spawn(player.position + Vector2.UP * min_distance)

func _clamp_named_spawn(candidate: Vector2) -> Vector2:
	var spawn_bounds := active_world_bounds.grow(-NAMED_SPAWN_MARGIN)
	return Vector2(
		clampf(candidate.x, spawn_bounds.position.x, spawn_bounds.end.x),
		clampf(candidate.y, spawn_bounds.position.y, spawn_bounds.end.y)
	)

func _is_named_spawn_clear(candidate: Vector2) -> bool:
	if candidate.distance_to(player.position) < NAMED_SPAWN_SEPARATION:
		return false
	for elite in elites:
		if elite.active and candidate.distance_to(elite.position) < NAMED_SPAWN_SEPARATION:
			return false
	return not boss.active or candidate.distance_to(boss.position) >= NAMED_SPAWN_SEPARATION

func _on_boss_summon(phase: int) -> void:
	if enemies.get_boss_guard_count() >= 4:
		return
	var use_east := phase % 2 == 0
	var x := active_world_bounds.end.x - 28.0 if use_east else active_world_bounds.position.x + 28.0
	var base := Vector2(x, active_world_bounds.get_center().y)
	if phase == 2:
		_spawn_boss_guard(EnemySimulation.EnemyType.SHIELD, base + Vector2(0, -45))
		_spawn_boss_guard(EnemySimulation.EnemyType.CROSSBOW, base + Vector2(0, 10))
		_spawn_boss_guard(EnemySimulation.EnemyType.ARCHER, base + Vector2(0, 55))
	else:
		_spawn_boss_guard(EnemySimulation.EnemyType.SHIELD, base + Vector2(0, -45))
		_spawn_boss_guard(EnemySimulation.EnemyType.HALBERD, base + Vector2(0, 5))
		_spawn_boss_guard(EnemySimulation.EnemyType.GUARD, base + Vector2(0, 45))
		_spawn_boss_guard(EnemySimulation.EnemyType.GUARD, base + Vector2(0, 82))

func _on_boss_phase(phase: int) -> void:
	_cancel_boss_telegraphs()
	player.add_ultimate_energy(5.0)
	hud.set_message("%s进入第 %d 阶段" % [boss.display_name(), phase])

func _on_tianji_windup_started(skill_id: String, center: Vector2, direction: Vector2, definition: Dictionary) -> void:
	renderer.add_tianji_windup(skill_id, center, direction, definition)

func _on_tianji_impacted(skill_id: String, center: Vector2, direction: Vector2, hit_count: int, active_duration: float) -> void:
	renderer.add_tianji_impact(skill_id, center, direction, hit_count, active_duration)

func _on_player_attack(request: AttackRequest) -> void:
	if request.clears_projectiles:
		_clear_projectiles_in_attack(request)
	var clash_result := {} if request.displacement_only else _resolve_weapon_clash(request)
	var clashed_elite_ids: Dictionary = clash_result.get("elite_ids", {}) as Dictionary
	var clashed_boss := bool(clash_result.get("boss", false))
	var clashed_spear_ids: Dictionary = clash_result.get("spear_ids", {}) as Dictionary
	var clashed_cavalry_ids: Dictionary = clash_result.get("cavalry_ids", {}) as Dictionary
	if clashed_boss or not clashed_elite_ids.is_empty() or not clashed_spear_ids.is_empty() or not clashed_cavalry_ids.is_empty():
		player_action_clash_consumed = true
		player.consume_weapon_clash_window()
	var hit_count := combat.resolve_hero_attack(request, player.base_attack, player.attack_bonus, enemies)
	for elite in elites:
		var elite_id := elite.get_instance_id()
		var can_hit_elite := not request.one_hit_per_target or not request.hit_elite_ids.has(elite_id)
		if can_hit_elite and not clashed_elite_ids.has(elite_id) and elite.active and combat.request_hits_point(request, elite.position):
			if request.displacement_only:
				_apply_elite_guard_knockback(elite, request)
				request.hit_elite_ids[elite_id] = true
				request.total_hits += 1
				hit_count += 1
				continue
			var elite_damage := CombatMath.final_damage(player.base_attack, request.multiplier, player.attack_bonus, elite.armor())
			elite_damage = player.modify_named_target_damage(HeroActor.NamedTargetKind.ELITE, "elite:%d" % elite_id, request, elite_damage)
			var elite_result := elite.receive_player_hit(elite_damage)
			var elite_actual_damage := float(elite_result.get("damage", 0.0))
			if elite_actual_damage > 0.0 and request.slow_duration > 0.0 and request.slow_multiplier < 1.0:
				elite.apply_slow(maxf(0.35, request.slow_multiplier + 0.10), request.slow_duration * 0.78)
			var interrupt_elite := bool(elite_result.get("stance_broken", false))
			if elite.is_stance_broken():
				interrupt_elite = _apply_elite_stance_break_knockback(elite, request) or interrupt_elite
			if interrupt_elite:
				_interrupt_elite_action_for_knockback(elite)
			if bool(elite_result.get("stance_broken", false)):
				_on_named_stance_broken(elite.display_name(), elite.position)
			request.hit_elite_ids[elite_id] = true
			request.total_hits += 1
			hit_count += 1
			player.on_named_target_hit(HeroActor.NamedTargetKind.ELITE, request, elite_actual_damage)
			player.record_named_target_combat_hit(HeroActor.NamedTargetKind.ELITE, "elite:%d" % elite_id, request, elite_actual_damage)
	var can_hit_boss := not request.one_hit_per_target or not request.hit_boss
	if can_hit_boss and not clashed_boss and boss.active and combat.request_hits_point(request, boss.position):
		if request.displacement_only:
			_apply_boss_guard_knockback(request)
			request.hit_boss = true
			request.total_hits += 1
			hit_count += 1
		else:
			var boss_damage := CombatMath.final_damage(player.base_attack, request.multiplier, player.attack_bonus, boss.armor())
			boss_damage = player.modify_named_target_damage(HeroActor.NamedTargetKind.BOSS, "boss", request, boss_damage)
			var boss_result := boss.receive_player_hit(boss_damage)
			var boss_actual_damage := float(boss_result.get("damage", 0.0))
			if boss_actual_damage > 0.0 and request.slow_duration > 0.0 and request.slow_multiplier < 1.0:
				boss.apply_slow(maxf(0.45, request.slow_multiplier + 0.16), request.slow_duration * 0.62)
			var interrupt_boss := bool(boss_result.get("stance_broken", false))
			if boss.is_stance_broken():
				interrupt_boss = _apply_boss_stance_break_knockback(request) or interrupt_boss
			if interrupt_boss:
				_interrupt_boss_action_for_knockback()
			if bool(boss_result.get("stance_broken", false)):
				_on_named_stance_broken(boss.display_name(), boss.position)
			request.hit_boss = true
			request.total_hits += 1
			hit_count += 1
			if boss_actual_damage > 0.0:
				player.on_named_target_hit(HeroActor.NamedTargetKind.BOSS, request, boss_actual_damage)
				player.record_named_target_combat_hit(HeroActor.NamedTargetKind.BOSS, "boss", request, boss_actual_damage)
				if request.grants_boss_ultimate_energy:
					player.add_ultimate_energy(boss.convert_damage_to_ultimate_energy(boss_actual_damage))
	if request.grants_breakout_guard_on_hit and request.total_hits > 0 and not request.breakout_granted:
		player.grant_breakout_guard()
		request.breakout_granted = true
	if hit_count > 0:
		_record_player_attack_audio(request)
	if not request.visual_emitted and not request.suppress_visual_feedback:
		renderer.add_flash(request)
		if request.dash_kind == HeroActor.DashKind.ULTIMATE:
			renderer.add_ultimate_dash_wave(request.origin, request.direction, request.range, player.ultimate_segment_index)
		request.visual_emitted = true
	if hit_count > 0 and not request.suppress_impact_feedback and not request.impact_emitted:
		var hitstop := _hitstop_duration(request, hit_count)
		hitstop_remaining = maxf(hitstop_remaining, hitstop)
		renderer.add_impact(player.position, request.label, hit_count)
		request.impact_emitted = true

func _tick_player_action_clash() -> void:
	if player_action_clash_consumed:
		player.consume_weapon_clash_window()
		return
	var request := player.current_action_clash_request()
	if request == null:
		player.consume_weapon_clash_window()
		return
	var clash_result := _resolve_weapon_clash(request)
	var clashed_elite_ids: Dictionary = clash_result.get("elite_ids", {}) as Dictionary
	var clashed_boss := bool(clash_result.get("boss", false))
	var clashed_spear_ids: Dictionary = clash_result.get("spear_ids", {}) as Dictionary
	var clashed_cavalry_ids: Dictionary = clash_result.get("cavalry_ids", {}) as Dictionary
	if clashed_boss or not clashed_elite_ids.is_empty() or not clashed_spear_ids.is_empty() or not clashed_cavalry_ids.is_empty():
		player_action_clash_consumed = true
		player.consume_weapon_clash_window()
		return
	player.open_weapon_clash_window(request, request.clash_kind)

func _clear_projectiles_in_attack(request: AttackRequest) -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		var telegraph := telegraphs[index]
		if telegraph.source_enemy_id < 0 or not enemies.is_active(telegraph.source_enemy_id):
			continue
		var enemy_type := enemies.get_type(telegraph.source_enemy_id)
		if enemy_type != EnemySimulation.EnemyType.ARCHER and enemy_type != EnemySimulation.EnemyType.CROSSBOW:
			continue
		if not request_hits_telegraph_origin(request, telegraph) and not telegraph.hits_point(request.origin):
			continue
		renderer.cancel_projectiles_for_enemy(telegraph.source_enemy_id)
		telegraphs.remove_at(index)

func request_hits_telegraph_origin(request: AttackRequest, telegraph: Telegraph) -> bool:
	return combat.request_hits_point(request, telegraph.origin)

func _resolve_weapon_clash(request: AttackRequest) -> Dictionary:
	var result := {"elite_ids": {}, "boss": false, "spear_ids": {}, "cavalry_ids": {}}
	var clash_kind := _player_clash_kind(request)
	if clash_kind == Telegraph.ClashKind.NONE:
		return result
	for index in range(telegraphs.size() - 1, -1, -1):
		var telegraph := telegraphs[index]
		if telegraph.clash_kind != clash_kind or telegraph.remaining > WEAPON_CLASH_WINDOW or not telegraph.hits_point(player.position):
			continue
		if _is_light_enemy_clash_telegraph(telegraph) and _can_clash_light_enemy(request, telegraph.source_enemy_id):
			var enemy_id := telegraph.source_enemy_id
			var enemy_type := enemies.get_type(enemy_id)
			telegraphs.remove_at(index)
			request.excluded_enemy_ids[enemy_id] = true
			if enemy_type == EnemySimulation.EnemyType.CAVALRY:
				var clashed_cavalry_ids: Dictionary = result.get("cavalry_ids", {}) as Dictionary
				clashed_cavalry_ids[enemy_id] = true
				result["cavalry_ids"] = clashed_cavalry_ids
				enemies.resolve_cavalry_clash(enemy_id, request.direction)
			else:
				var clashed_spear_ids: Dictionary = result.get("spear_ids", {}) as Dictionary
				clashed_spear_ids[enemy_id] = true
				result["spear_ids"] = clashed_spear_ids
				enemies.resolve_spear_clash(enemy_id, request.direction)
			_finalize_light_enemy_weapon_clash((player.position + enemies.positions[enemy_id]) * 0.5)
			return result
		if telegraph.source == "boss" and boss.active and _can_clash_named_target(request, boss.position):
			var perfect := telegraph.remaining <= PERFECT_WEAPON_CLASH_WINDOW
			telegraphs.remove_at(index)
			var boss_broken := boss.add_stance_damage(_clash_stance_damage(perfect, clash_kind))
			result["boss"] = true
			_finalize_weapon_clash((player.position + boss.position) * 0.5, perfect, clash_kind, boss.display_name(), boss_broken, boss)
			return result
		if not telegraph.source.begins_with("elite:"):
			continue
		var elite := _elite_for_telegraph_source(telegraph.source)
		if elite == null or not elite.active or not _can_clash_named_target(request, elite.position):
			continue
		var perfect := telegraph.remaining <= PERFECT_WEAPON_CLASH_WINDOW
		telegraphs.remove_at(index)
		var elite_broken := elite.add_stance_damage(_clash_stance_damage(perfect, clash_kind))
		var clashed_elite_ids: Dictionary = result.get("elite_ids", {}) as Dictionary
		clashed_elite_ids[elite.get_instance_id()] = true
		result["elite_ids"] = clashed_elite_ids
		_finalize_weapon_clash((player.position + elite.position) * 0.5, perfect, clash_kind, elite.display_name(), elite_broken, elite)
		return result
	return result

func _try_resolve_late_weapon_clash(telegraph: Telegraph) -> bool:
	var clash_kind := player.current_weapon_clash_type()
	if telegraph.clash_kind != clash_kind or clash_kind == Telegraph.ClashKind.NONE or not telegraph.hits_point(player.position):
		return false
	if telegraph.source == "boss" and boss.active and player.can_weapon_clash_target(boss.position):
		player.consume_weapon_clash_window()
		var boss_broken := boss.add_stance_damage(_clash_stance_damage(false, clash_kind))
		_finalize_weapon_clash((player.position + boss.position) * 0.5, false, clash_kind, boss.display_name(), boss_broken, boss)
		return true
	if _is_light_enemy_clash_telegraph(telegraph) and player.can_weapon_clash_target(enemies.positions[telegraph.source_enemy_id]):
		var enemy_id := telegraph.source_enemy_id
		player.consume_weapon_clash_window()
		if enemies.get_type(enemy_id) == EnemySimulation.EnemyType.CAVALRY:
			enemies.resolve_cavalry_clash(enemy_id, player.last_attack_direction)
		else:
			enemies.resolve_spear_clash(enemy_id, player.last_attack_direction)
		_finalize_light_enemy_weapon_clash((player.position + enemies.positions[enemy_id]) * 0.5)
		return true
	if not telegraph.source.begins_with("elite:"):
		return false
	var elite := _elite_for_telegraph_source(telegraph.source)
	if elite == null or not elite.active or not player.can_weapon_clash_target(elite.position):
		return false
	player.consume_weapon_clash_window()
	var elite_broken := elite.add_stance_damage(_clash_stance_damage(false, clash_kind))
	_finalize_weapon_clash((player.position + elite.position) * 0.5, false, clash_kind, elite.display_name(), elite_broken, elite)
	return true

func _player_clash_kind(request: AttackRequest) -> int:
	return request.clash_kind

func _clash_stance_damage(perfect: bool, clash_kind: int) -> float:
	if clash_kind == Telegraph.ClashKind.ACTIVE:
		return PERFECT_SKILL_CLASH_STANCE_DAMAGE if perfect else NORMAL_SKILL_CLASH_STANCE_DAMAGE
	return PERFECT_CLASH_STANCE_DAMAGE if perfect else NORMAL_CLASH_STANCE_DAMAGE

func _can_clash_named_target(request: AttackRequest, target_position: Vector2) -> bool:
	if not combat.request_hits_point(request, target_position):
		return false
	var toward_target := target_position - player.position
	if toward_target.length_squared() <= 0.01:
		return true
	return request.direction.dot(toward_target.normalized()) >= -0.10

func _is_light_enemy_clash_telegraph(telegraph: Telegraph) -> bool:
	if telegraph.source_enemy_id < 0 or not enemies.is_active(telegraph.source_enemy_id):
		return false
	var enemy_type := enemies.get_type(telegraph.source_enemy_id)
	return enemy_type == EnemySimulation.EnemyType.SPEAR or enemy_type == EnemySimulation.EnemyType.CAVALRY

func _can_clash_light_enemy(request: AttackRequest, enemy_id: int) -> bool:
	if not enemies.is_active(enemy_id) or not combat.request_hits_point(request, enemies.positions[enemy_id]):
		return false
	var toward_enemy := enemies.positions[enemy_id] - player.position
	if toward_enemy.length_squared() <= 0.01:
		return true
	return request.direction.dot(toward_enemy.normalized()) >= -0.10

func _elite_for_telegraph_source(source: String) -> EliteActor:
	for elite in elites:
		if is_instance_valid(elite) and elite.telegraph_source == source:
			return elite
	return null

func _finalize_weapon_clash(at: Vector2, perfect: bool, clash_kind: int, target_name: String, stance_broken: bool, named_target: Node = null) -> void:
	var skill_clash := clash_kind == Telegraph.ClashKind.ACTIVE
	player.on_weapon_clash_success(perfect, skill_clash)
	if not perfect and not stance_broken and is_instance_valid(named_target) and named_target.has_method("grant_counterattack"):
		named_target.call("grant_counterattack")
	renderer.add_weapon_clash(at, perfect, skill_clash)
	hitstop_remaining = maxf(hitstop_remaining, 0.17 if perfect else (0.12 if skill_clash else 0.10))
	_start_clash_slowmotion(perfect, skill_clash)
	_record_weapon_clash_audio()
	if stance_broken:
		_on_named_stance_broken(target_name, at)
	elif perfect:
		hud.set_message("完美拼刀：%s 架势重创" % target_name)

func _finalize_light_enemy_weapon_clash(at: Vector2) -> void:
	renderer.add_weapon_clash(at, false, false, true)
	hitstop_remaining = maxf(hitstop_remaining, 0.045)

func _start_clash_slowmotion(perfect: bool, skill_clash: bool) -> void:
	var duration := EMPHATIC_CLASH_SLOW_DURATION if perfect or skill_clash else NORMAL_CLASH_SLOW_DURATION
	clash_slow_remaining = maxf(clash_slow_remaining, duration)

func _record_weapon_clash_audio() -> void:
	var action_id := "basic_%d" % player.combo_stage
	if not action_audio_hits.has(action_id) or bool(action_audio_hits[action_id]):
		return
	action_audio_hits[action_id] = true
	AudioService.play_hero_attack_hit()

func _apply_elite_stance_break_knockback(elite: EliteActor, request: AttackRequest) -> bool:
	if request.prevent_elite_knockback:
		return false
	var force := _named_knockback_force(request)
	if force <= 0.0:
		return false
	var direction := _named_knockback_direction(request, elite.position)
	var impact_position := elite.position
	var displacement := elite.apply_stance_break_knockback(direction, force, request.forced_displacement)
	elite.position = _clamp_named_spawn(elite.position)
	if displacement > 0.0:
		renderer.add_named_hit_feedback(impact_position, direction, displacement / EliteActor.STANCE_BREAK_MAX_HIT_KNOCKBACK, displacement >= 30.0)
	return displacement > 0.0

func _apply_elite_guard_knockback(elite: EliteActor, request: AttackRequest) -> bool:
	var direction := _named_knockback_direction(request, elite.position)
	var displacement := 0.0
	if elite.is_stance_broken():
		displacement = elite.apply_stance_break_knockback(direction, _named_knockback_force(request), request.forced_displacement)
	else:
		displacement = elite.apply_guard_knockback(direction, _named_knockback_force(request), request.forced_displacement)
	if displacement > 0.0:
		elite.position = _clamp_named_spawn(elite.position)
	return displacement > 0.0

func _apply_boss_stance_break_knockback(request: AttackRequest) -> bool:
	var force := _named_knockback_force(request)
	if force <= 0.0:
		return false
	var direction := _named_knockback_direction(request, boss.position)
	var impact_position := boss.position
	var displacement := boss.apply_stance_break_knockback(direction, force, request.forced_displacement)
	boss.position = _clamp_named_spawn(boss.position)
	if displacement > 0.0:
		renderer.add_named_hit_feedback(impact_position, direction, displacement / BossActor.STANCE_BREAK_MAX_HIT_KNOCKBACK, displacement >= 24.0)
	return displacement > 0.0

func _apply_boss_guard_knockback(request: AttackRequest) -> bool:
	var direction := _named_knockback_direction(request, boss.position)
	var displacement := boss.apply_stance_break_knockback(direction, _named_knockback_force(request), request.forced_displacement) if boss.is_stance_broken() else boss.apply_guard_knockback(direction, _named_knockback_force(request), request.forced_displacement)
	boss.position = _clamp_named_spawn(boss.position)
	return displacement > 0.0

func _interrupt_elite_action_for_knockback(elite: EliteActor) -> void:
	if elite.interrupt_action_for_knockback():
		_cancel_elite_telegraphs(elite.telegraph_source)

func _interrupt_boss_action_for_knockback() -> void:
	if boss.interrupt_action_for_knockback():
		_cancel_boss_telegraphs()

func _named_knockback_direction(request: AttackRequest, target_position: Vector2) -> Vector2:
	var direction := request.direction
	if request.shape == AttackRequest.Shape.CIRCLE or request.fan_knockback:
		direction = target_position - request.origin
	if direction.length_squared() <= 0.01:
		direction = target_position - player.position
	return direction.normalized()

func _named_knockback_force(request: AttackRequest) -> float:
	var force := maxf(request.knockback, request.forced_displacement * 5.0)
	if request.empowered_knockback_active:
		force *= request.empowered_knockback_multiplier
	return force

func _on_named_stance_broken(target_name: String, at: Vector2) -> void:
	renderer.add_stance_break(at)
	hud.set_message("破势：%s 失去霸体" % target_name)

func _on_player_combat_action_started(action_id: String) -> void:
	player_action_clash_consumed = false
	action_audio_hits[action_id] = false
	if action_id == "firewheel":
		AudioService.play_hero_firewheel_loop()

func _on_player_combat_action_finished(action_id: String) -> void:
	player_action_clash_consumed = true
	player.consume_weapon_clash_window()
	if action_id == "firewheel":
		AudioService.stop_hero_firewheel_loop()
	var action_hit := bool(action_audio_hits.get(action_id, false))
	if action_audio_hits.has(action_id) and not action_hit:
		AudioService.play_hero_miss()
	action_audio_hits.erase(action_id)

func _record_player_attack_audio(request: AttackRequest) -> void:
	var action_id := _audio_action_id_for_request(request)
	if action_id.is_empty() or not action_audio_hits.has(action_id):
		return
	if action_id == "ultimate":
		action_audio_hits[action_id] = true
		if not request.audio_emitted:
			AudioService.play_hero_skill_hit()
			request.audio_emitted = true
		return
	if bool(action_audio_hits[action_id]):
		return
	action_audio_hits[action_id] = true
	if action_id == "active":
		AudioService.play_hero_skill_hit()
	else:
		AudioService.play_hero_attack_hit()

func _audio_action_id_for_request(request: AttackRequest) -> String:
	match request.label:
		"青龙横江": return "basic_1"
		"压阵斩": return "basic_2"
		"拖刀断阵": return "basic_3"
		"拖刀斩浪", "拖刀刀浪": return "drag"
		"青龙破阵", "青龙断浪": return "active"
		"武圣刀浪", "武圣震阵", "武圣拖刀震阵": return "ultimate"
		"威震华夏·横江", "威震华夏·断岳", "威震华夏·斩将": return "ultimate"
		"蛇矛横扫": return "basic_1"
		"横矛断阵": return "basic_2"
		"燕人震退": return "basic_3"
		"据水断桥": return "active"
		"当阳怒吼·横断", "当阳怒吼·震地", "当阳怒吼·断喝": return "ultimate"
		"银枪点阵": return "basic_1"
		"流星横挑": return "basic_2"
		"踏阵突刺": return "basic_3"
		"西凉破阵": return "active"
		"银枪奔雷": return "ultimate"
		"连珠箭", "断弦横斩": return "basic_1"
		"蓄力穿云", "回身断阵": return "basic_2"
		"贯星矢", "返弦斩": return "active"
		"定军连珠": return "ultimate"
		"点刺", "枪势震退": return "basic_1"
		"横扫": return "basic_2"
		"穿阵挑刺": return "basic_3"
		"哪吒火轮", "乾坤掷轮": return "firewheel"
		"破军", "破军收势", "破军枪影": return "active"
		"七进七出", "七进七出·收势": return "ultimate"
		_: return ""

func _tick_player_move_audio(delta: float, move_direction: Vector2) -> void:
	var moved := player.position.distance_squared_to(player_last_audio_position) > 0.01
	player_last_audio_position = player.position
	var is_regular_movement := moved and move_direction.length_squared() > 0.01 and not player.is_attacking() and player.ultimate_time <= 0.0 and not player.is_path_dashing()
	if not is_regular_movement:
		move_sound_cooldown = 0.0
		return
	move_sound_cooldown = maxf(0.0, move_sound_cooldown - delta)
	if move_sound_cooldown > 0.0:
		return
	AudioService.play_hero_move()
	move_sound_cooldown = randf_range(0.32, 0.38)

func _tick_enemy_battle_voice(delta: float) -> void:
	if enemies.active_count <= 0:
		return
	enemy_voice_remaining = maxf(0.0, enemy_voice_remaining - delta)
	if enemy_voice_remaining > 0.0:
		return
	AudioService.play_enemy_battle_voice()
	enemy_voice_remaining = randf_range(ENEMY_VOICE_INTERVAL_MIN, ENEMY_VOICE_INTERVAL_MAX)

func _hitstop_duration(request: AttackRequest, hit_count: int) -> float:
	var extra_hits := float(maxi(0, hit_count - 1))
	if request.is_path_attack:
		return minf(0.055, 0.030 + extra_hits * 0.006)
	var hitstop := 0.045
	if hit_count >= 9:
		hitstop = 0.120
	elif hit_count >= 5:
		hitstop = 0.100
	elif hit_count >= 2:
		hitstop = 0.074
	if request.label == "哪吒火轮":
		return minf(0.070, hitstop)
	if request.label == "七进七出·收势":
		return minf(0.130, hitstop + 0.012)
	if request.label == "七进七出":
		return minf(0.110, hitstop + 0.006)
	if request.label in ["穿阵挑刺", "破军", "破军收势"]:
		return minf(0.120, hitstop + 0.008)
	if request.label in ["拖刀断阵", "青龙断浪", "威震华夏·横江", "威震华夏·断岳"]:
		return minf(0.135, hitstop + 0.014)
	if request.label == "威震华夏·斩将":
		return minf(0.150, hitstop + 0.026)
	if request.label in ["燕人震退", "据水断桥", "当阳怒吼·震地", "当阳怒吼·断喝"]:
		return minf(0.155, hitstop + 0.030)
	if request.label in ["踏阵突刺", "西凉破阵", "银枪奔雷"]:
		return minf(0.125, hitstop + 0.015)
	if request.label in ["蓄力穿云", "贯星矢", "定军连珠"]:
		return minf(0.118, hitstop + 0.012)
	return hitstop

func _on_ultimate_requested(direction: Vector2) -> void:
	if player.request_ultimate(direction):
		return
	if player.ultimate_time > 0.0:
		hud.set_message("无双正在发动")
	elif player.is_action_locked():
		hud.set_message("招式未收，暂不能发动无双")
	else:
		hud.show_ultimate_unavailable(player.ultimate_energy)

func _on_weapon_stance_requested() -> void:
	if player.request_weapon_stance_toggle():
		hud.set_message("黄忠切换为%s形态" % player.weapon_stance_label())

func _on_ultimate_ready() -> void:
	hud.announce_ultimate_ready()

func _on_ultimate_started() -> void:
	hud.set_message("无双·%s！" % player.ultimate_ability_label())
	hitstop_remaining = 0.0
	AudioService.play_hero_ultimate_start()
	ultimate_cutin.play(player.hero_id)

func _on_enemy_died(enemy_id: int, enemy_type: int, at: Vector2, experience: int, ultimate_energy: float) -> void:
	_cancel_enemy_telegraphs(enemy_id)
	loot.drop_loot(at, experience, enemies.gold_reward(enemy_type))
	player.add_ultimate_energy(ultimate_energy)
	player.on_enemy_defeated(enemy_type)

func _on_enemy_death_collision(at: Vector2, direction: Vector2) -> void:
	renderer.add_death_collision(at, direction)

func _on_loot_collected(experience: int, gold: int) -> void:
	director.add_experience(experience)
	run_merit_fraction += float(gold) * player.military_gold_multiplier
	var updated_merit := int(floor(run_merit_fraction))
	if updated_merit != run_gold:
		run_gold = updated_merit
		hud.set_run_gold(run_gold)

func _on_enemy_attack(enemy_id: int, origin: Vector2, target: Vector2, enemy_type: int, damage: float, windup: float, attack_kind: String) -> void:
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		if _available_enemy_attack_slots(enemy_type) <= 0:
			enemies.cancel_attack(enemy_id)
		return
	if telegraphs.size() >= 20 or _available_enemy_attack_slots(enemy_type) <= 0:
		enemies.cancel_attack(enemy_id)
		return
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		_schedule_archer_attack(enemy_id, origin, target, damage, windup, attack_kind)
		return
	if enemy_type == EnemySimulation.EnemyType.CROSSBOW:
		_schedule_crossbow_attack(enemy_id, origin, target, damage, windup, attack_kind)
		return
	var source := attack_kind if attack_kind != EnemySimulation.ATTACK_KIND_DEFAULT else _enemy_attack_source(enemy_type)
	var telegraph: Telegraph
	if enemy_type == EnemySimulation.EnemyType.HALBERD:
		var halberd_direction := Vector2.RIGHT if target.x >= origin.x else Vector2.LEFT
		match attack_kind:
			EnemySimulation.ATTACK_KIND_HALBERD_SWEEP:
				telegraph = Telegraph.fan(origin, halberd_direction, EnemySimulation.HALBERD_SWEEP_RANGE, deg_to_rad(132.0), windup, damage * 0.86, source)
			EnemySimulation.ATTACK_KIND_HALBERD_BRACE:
				telegraph = Telegraph.fan(origin, halberd_direction, 142.0, deg_to_rad(158.0), windup, damage * 1.25, source)
			_:
				telegraph = Telegraph.fan(origin, halberd_direction, EnemySimulation.HALBERD_SWEEP_RANGE, deg_to_rad(132.0), windup, damage * 0.86, source)
	elif enemy_type == EnemySimulation.EnemyType.SPEAR:
		match attack_kind:
			EnemySimulation.ATTACK_KIND_SPEAR_FORMATION:
				for index in range(3):
					var lane_offset := (float(index) - 1.0) * 14.0
					var thrust_origin := origin + Vector2(0.0, lane_offset)
					var thrust_windup := windup * (0.70 + float(index) * 0.14)
					var formation_telegraph := Telegraph.line(thrust_origin, target - origin, 238.0, 54.0, thrust_windup, damage * 0.62, source)
					_schedule_enemy_telegraph(formation_telegraph, enemy_id, Telegraph.ThreatKind.ACTIVE)
				return
			EnemySimulation.ATTACK_KIND_SPEAR_THRUST_2:
				telegraph = Telegraph.line(origin, target - origin, 190.0, 36.0, windup, damage * 1.12, source)
				telegraph.clash_kind = Telegraph.ClashKind.BASIC
				telegraph.clashable = true
			_:
				telegraph = Telegraph.line(origin, target - origin, 156.0, 32.0, windup, damage * 0.88, source)
	elif enemy_type == EnemySimulation.EnemyType.CAVALRY:
		if attack_kind == EnemySimulation.ATTACK_KIND_CAVALRY_CHARGE:
			telegraph = Telegraph.line(origin, target - origin, 184.0, 42.0, windup, damage * 1.32, source)
			telegraph.clash_kind = Telegraph.ClashKind.ACTIVE
			telegraph.clashable = true
		else:
			telegraph = Telegraph.line(origin, target - origin, 104.0, 34.0, windup, damage * 0.82, source)
			telegraph.clash_kind = Telegraph.ClashKind.BASIC
			telegraph.clashable = true
	elif enemy_type == EnemySimulation.EnemyType.ELITE:
		telegraph = Telegraph.line(origin, target - origin, 145.0, 30.0, windup, damage, source)
	elif enemy_type == EnemySimulation.EnemyType.SHIELD:
		telegraph = Telegraph.fan(origin, target - origin, 72.0, deg_to_rad(72.0), windup, damage, source)
	else:
		telegraph = Telegraph.circle(target, 38.0, windup, damage, source)
	var threat_kind := Telegraph.ThreatKind.ACTIVE if attack_kind in [EnemySimulation.ATTACK_KIND_HALBERD_BRACE, EnemySimulation.ATTACK_KIND_SPEAR_FORMATION, EnemySimulation.ATTACK_KIND_CAVALRY_CHARGE] else Telegraph.ThreatKind.BASIC
	_schedule_enemy_telegraph(telegraph, enemy_id, threat_kind)

func _schedule_archer_attack(enemy_id: int, origin: Vector2, target: Vector2, damage: float, windup: float, attack_kind: String) -> void:
	var source := attack_kind
	var available_slots := _available_enemy_attack_slots(EnemySimulation.EnemyType.ARCHER)
	var global_room := 22 - telegraphs.size()
	if attack_kind == EnemySimulation.ATTACK_KIND_ARCHER_VOLLEY and available_slots >= 3 and global_room >= 3 and not _has_enemy_attack_source(EnemySimulation.ATTACK_KIND_ARCHER_VOLLEY):
		var flight_direction := (target - origin).normalized()
		if flight_direction.length_squared() <= 0.01:
			flight_direction = Vector2.UP
		var lateral := flight_direction.rotated(PI * 0.5)
		for index in range(3):
			var offset := (float(index) - 1.0) * 36.0
			var impact_target := _clamp_enemy_attack_target(target + lateral * offset)
			var impact_windup := windup + float(index) * 0.15
			var telegraph := Telegraph.circle(impact_target, 28.0, impact_windup, damage * 0.72, source)
			_schedule_enemy_telegraph(telegraph, enemy_id, Telegraph.ThreatKind.ACTIVE)
			renderer.add_archer_projectile(enemy_id, origin, impact_target, impact_windup)
		return
	var fallback_source := EnemySimulation.ATTACK_KIND_ARCHER_LEAD if attack_kind == EnemySimulation.ATTACK_KIND_ARCHER_VOLLEY else source
	var radius := 27.0 if fallback_source == EnemySimulation.ATTACK_KIND_ARCHER_LEAD else 24.0
	var telegraph := Telegraph.circle(target, radius, windup, damage, fallback_source)
	_schedule_enemy_telegraph(telegraph, enemy_id, Telegraph.ThreatKind.BASIC)
	renderer.add_archer_projectile(enemy_id, origin, target, windup)

func _schedule_crossbow_attack(enemy_id: int, origin: Vector2, target: Vector2, damage: float, windup: float, attack_kind: String) -> void:
	var available_slots := _available_enemy_attack_slots(EnemySimulation.EnemyType.CROSSBOW)
	var global_room := 22 - telegraphs.size()
	if attack_kind == EnemySimulation.ATTACK_KIND_CROSSBOW_VOLLEY and available_slots >= 3 and global_room >= 3 and not _has_enemy_attack_source(EnemySimulation.ATTACK_KIND_CROSSBOW_VOLLEY):
		var direction := (target - origin).normalized()
		if direction.length_squared() <= 0.01:
			direction = Vector2.RIGHT
		var lateral := Vector2(-direction.y, direction.x)
		for index in range(3):
			var offset := (float(index) - 1.0) * 24.0
			var impact_target := _clamp_enemy_attack_target(target + lateral * offset)
			var impact_windup := windup + float(index) * 0.12
			var volley_telegraph := Telegraph.line(origin, impact_target - origin, origin.distance_to(impact_target), 24.0, impact_windup, damage * 0.60, EnemySimulation.ATTACK_KIND_CROSSBOW_VOLLEY)
			_schedule_enemy_telegraph(volley_telegraph, enemy_id, Telegraph.ThreatKind.ACTIVE)
			renderer.add_crossbow_bolt(enemy_id, origin, impact_target, impact_windup)
		return
	var fallback_source := EnemySimulation.ATTACK_KIND_CROSSBOW_DIRECT if attack_kind == EnemySimulation.ATTACK_KIND_CROSSBOW_VOLLEY else attack_kind
	var telegraph := Telegraph.line(origin, target - origin, origin.distance_to(target), 22.0, windup, damage, fallback_source)
	_schedule_enemy_telegraph(telegraph, enemy_id, Telegraph.ThreatKind.BASIC)
	renderer.add_crossbow_bolt(enemy_id, origin, target, windup)

func _schedule_enemy_telegraph(telegraph: Telegraph, enemy_id: int, threat_kind: int) -> void:
	telegraph.threat_kind = threat_kind
	telegraph.source_enemy_id = enemy_id
	_add_telegraph(telegraph)

func _clamp_enemy_attack_target(target: Vector2) -> Vector2:
	return Vector2(
		clampf(target.x, active_world_bounds.position.x + 12.0, active_world_bounds.end.x - 12.0),
		clampf(target.y, active_world_bounds.position.y + 12.0, active_world_bounds.end.y - 12.0)
	)

func _has_enemy_attack_source(source: String) -> bool:
	for telegraph in telegraphs:
		if telegraph.source == source:
			return true
	return false

func _on_enemy_attack_cancelled(enemy_id: int) -> void:
	_cancel_enemy_telegraphs(enemy_id)

func _on_banner_command(enemy_id: int, at: Vector2) -> void:
	if enemies.issue_banner_command(enemy_id):
		renderer.add_banner_command(at)

func _on_elite_telegraph(telegraph: Telegraph) -> void:
	_add_telegraph(telegraph)

func _on_named_skill_impact(strength: float) -> void:
	renderer.add_named_skill_shake(strength)

func _on_elite_defeated(elite: EliteActor) -> void:
	_cancel_elite_telegraphs(elite.telegraph_source)
	loot.drop_loot(elite.position, 12, 40)
	player.add_ultimate_energy(12.0)
	player.on_enemy_defeated(EnemySimulation.EnemyType.ELITE)
	hud.set_message("精英击破：%s" % elite.display_name())
	renderer.add_elite_corpse(elite)
	elites.erase(elite)
	renderer.set_elites(elites)
	hud.set_elites(elites)
	elite.call_deferred("queue_free")
	if director.is_boss_trial():
		boss_trial_advance_after_levels = true
		director.grant_levels(BOSS_TRIAL_ELITE_LEVEL_REWARD)

func _add_telegraph(telegraph: Telegraph) -> void:
	if telegraphs.size() >= 22:
		return
	if _is_named_threat_source(telegraph.source) and _named_threat_count() >= 5:
		return
	telegraphs.append(telegraph)

func _tick_telegraphs(delta: float) -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		var telegraph := telegraphs[index]
		if telegraph.source_enemy_id >= 0 and not enemies.is_active(telegraph.source_enemy_id):
			telegraphs.remove_at(index)
			continue
		telegraph.remaining -= delta
		if telegraph.remaining <= 0.0:
			if _try_resolve_late_weapon_clash(telegraph):
				telegraphs.remove_at(index)
				continue
			if _telegraph_hits_player(telegraph):
				if _try_block_projectile_telegraph(telegraph):
					hud.set_message(player.projectile_guard_block_message())
					telegraphs.remove_at(index)
					continue
				var damage_taken := player.receive_damage(telegraph.damage, telegraph.source)
				if player_death_cinematic_active:
					telegraphs.clear()
					return
				if telegraph.source == "boss":
					if damage_taken > 0.0:
						hud.set_message("张郃命中：-%d 生命" % int(damage_taken))
					else:
						hud.set_message("龙胆护体抵挡了张郃的攻击")
			telegraphs.remove_at(index)

func _tick_named_enemies(delta: float) -> void:
	for elite in elites:
		if not is_instance_valid(elite):
			continue
		if elite.active:
			elite.set_high_risk_skill_allowed(_can_begin_named_high_risk_action(elite))
			elite.set_navigation_waypoint(_named_navigation_waypoint(elite.position, player.position, 22.0, elite.get_instance_id()))
		elite.tick(delta, player.position, player.is_attacking())
	if boss.active or boss.is_dying():
		if boss.active:
			boss.set_high_risk_skill_allowed(_can_begin_named_high_risk_action(boss))
			boss.set_navigation_waypoint(_named_navigation_waypoint(boss.position, player.position, 26.0, boss.get_instance_id()))
		boss.tick(delta, player.position, player.is_attacking())
		if boss.active:
			boss.position = _clamp_named_spawn(boss.position)

func _named_navigation_waypoint(start: Vector2, target: Vector2, radius: float, identity: int) -> Vector2:
	if active_obstacles.is_empty():
		return Vector2.ZERO
	var preferred_side := -1 if identity % 2 == 0 else 1
	return BATTLEFIELD_LAYOUT.navigation_waypoint_for(start, target, active_obstacles, radius, preferred_side)

func _can_begin_named_high_risk_action(requester: Node) -> bool:
	if boss.active and boss != requester and boss.is_high_risk_action_active():
		return false
	for elite in elites:
		if is_instance_valid(elite) and elite != requester and elite.active and elite.is_high_risk_action_active():
			return false
	return true

func _available_enemy_attack_slots(enemy_type: int) -> int:
	var group := _enemy_attack_group(enemy_type)
	var available := enemies.attack_telegraph_limit(enemy_type)
	for telegraph in telegraphs:
		if telegraph.source_enemy_id >= 0 and _enemy_attack_group_for_source(telegraph.source) == group:
			available -= 1
	return maxi(0, available)

func _enemy_attack_source(enemy_type: int) -> String:
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemySimulation.EnemyType.CROSSBOW:
		return "crossbow"
	if enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.ELITE:
		return "halberd"
	if enemy_type == EnemySimulation.EnemyType.SHIELD:
		return "shield"
	if enemy_type == EnemySimulation.EnemyType.SPEAR:
		return "spear"
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		return "banner"
	if enemy_type == EnemySimulation.EnemyType.CAVALRY:
		return "cavalry"
	return "sword"

func _enemy_attack_group(enemy_type: int) -> String:
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemySimulation.EnemyType.CROSSBOW:
		return "crossbow"
	if enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.ELITE:
		return "halberd"
	if enemy_type == EnemySimulation.EnemyType.SPEAR:
		return "spear"
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		return "banner"
	if enemy_type == EnemySimulation.EnemyType.CAVALRY:
		return "cavalry"
	return "frontline"

func _enemy_attack_group_for_source(source: String) -> String:
	if source.begins_with("archer"):
		return "archer"
	if source.begins_with("crossbow"):
		return "crossbow"
	if source.begins_with("halberd"):
		return "halberd"
	if source.begins_with("spear"):
		return "spear"
	if source.begins_with("banner"):
		return "banner"
	if source.begins_with("cavalry"):
		return "cavalry"
	return "frontline"

func _cancel_enemy_telegraphs(enemy_id: int) -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		if telegraphs[index].source_enemy_id == enemy_id:
			telegraphs.remove_at(index)
	renderer.cancel_archer_projectiles(enemy_id)
	renderer.cancel_crossbow_bolts(enemy_id)

func _cancel_boss_telegraphs() -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		if telegraphs[index].source == "boss" or telegraphs[index].source == "boss_preview":
			telegraphs.remove_at(index)

func _cancel_elite_telegraphs(source: String) -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		if telegraphs[index].source == source:
			telegraphs.remove_at(index)

func _spawn_boss_guard(enemy_type: int, at: Vector2) -> void:
	if enemies.get_boss_guard_count() >= 4:
		return
	enemies.spawn(enemy_type, at, true)

func _telegraph_hits_player(telegraph: Telegraph) -> bool:
	return telegraph.hits_point(player.position)

func _try_block_projectile_telegraph(telegraph: Telegraph) -> bool:
	if telegraph.source_enemy_id < 0 or not enemies.is_active(telegraph.source_enemy_id):
		return false
	var enemy_type := enemies.get_type(telegraph.source_enemy_id)
	if enemy_type != EnemySimulation.EnemyType.ARCHER and enemy_type != EnemySimulation.EnemyType.CROSSBOW:
		return false
	if not player.try_block_frontal_projectile(enemies.positions[telegraph.source_enemy_id]):
		return false
	var block_direction := (enemies.positions[telegraph.source_enemy_id] - player.position).normalized()
	if block_direction.length_squared() <= 0.01:
		block_direction = player.last_attack_direction.normalized()
	if block_direction.length_squared() <= 0.01:
		block_direction = Vector2.RIGHT
	renderer.add_weapon_clash(player.position + block_direction * 34.0, false, false, true)
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		renderer.cancel_next_archer_projectile(telegraph.source_enemy_id)
	else:
		renderer.cancel_next_crossbow_bolt(telegraph.source_enemy_id)
	return true

func _on_level_up(level: int) -> void:
	player.apply_level_up_benefits()
	if upgrade_open:
		queued_level_ups.append(level)
		return
	_open_level_up(level)

func _open_level_up(level: int) -> void:
	upgrade_open = true
	current_upgrade_level = level
	current_upgrade_options = upgrades.draft(level)
	input_router.set_input_enabled(false)
	hud.set_message("等级提升：Lv.%d" % level)
	hud.show_upgrades(current_upgrade_options, upgrades)

func _start_boss_trial() -> void:
	if not director.is_boss_trial():
		return
	_begin_boss_trial_upgrades(BOSS_TRIAL_STARTING_UPGRADES, false)

func _begin_boss_trial_upgrades(count: int, advance_after_upgrade: bool) -> void:
	if count <= 0:
		return
	boss_trial_upgrades_remaining = count
	boss_trial_advance_after_upgrade = advance_after_upgrade
	_open_boss_trial_upgrade()

func _open_boss_trial_upgrade() -> void:
	upgrade_open = true
	current_upgrade_level = director.level
	current_upgrade_options = upgrades.draft(current_upgrade_level)
	input_router.set_input_enabled(false)
	var stage_label := "精英击破：选择强化" if boss_trial_advance_after_upgrade else "战前整备：三选一"
	hud.set_message("%s（剩余 %d）" % [stage_label, boss_trial_upgrades_remaining])
	hud.show_upgrades(current_upgrade_options, upgrades)

func _on_upgrade_refresh_requested() -> void:
	if not upgrade_open or upgrade_refreshes_remaining <= 0:
		return
	upgrade_refreshes_remaining -= 1
	hud.set_upgrade_refreshes_remaining(upgrade_refreshes_remaining)
	hud.set_message("已刷新三选一（剩余 %d 次）" % upgrade_refreshes_remaining)
	var refreshed_options := upgrades.draft(current_upgrade_level)
	var attempts := 0
	while _same_upgrade_choices(refreshed_options, current_upgrade_options) and attempts < 6:
		refreshed_options = upgrades.draft(current_upgrade_level)
		attempts += 1
	current_upgrade_options = refreshed_options
	hud.show_upgrades(current_upgrade_options, upgrades)

func _same_upgrade_choices(first: Array[String], second: Array[String]) -> bool:
	if first.size() != second.size():
		return false
	for upgrade_id in first:
		if not second.has(upgrade_id):
			return false
	return true

func _on_upgrade_selected(upgrade_id: String) -> void:
	current_upgrade_options.clear()
	upgrades.record_selection(upgrade_id)
	if upgrades.is_tianji_upgrade(upgrade_id):
		var tianji_skill_id := upgrades.tianji_skill_for_upgrade(upgrade_id)
		if upgrades.tianji_activation_ids().has(upgrade_id):
			tianji.activate_skill(tianji_skill_id)
		else:
			tianji.apply_run_upgrade(upgrade_id)
		upgrades.set_active_tianji_ids(tianji.active_skill_ids())
	else:
		player.apply_upgrade(upgrade_id)
	hud.set_message("已获得：%s" % upgrades.title_for(upgrade_id))
	if boss_trial_upgrades_remaining > 0:
		boss_trial_upgrades_remaining -= 1
		if boss_trial_upgrades_remaining > 0:
			_open_boss_trial_upgrade()
			return
		var should_advance := boss_trial_advance_after_upgrade
		boss_trial_advance_after_upgrade = false
		upgrade_open = false
		input_router.set_input_enabled(true)
		if should_advance:
			director.advance_boss_trial_after_elite()
		else:
			director.begin_boss_trial()
		return
	if not queued_level_ups.is_empty():
		_open_level_up(queued_level_ups.pop_front())
		return
	var should_advance_trial := boss_trial_advance_after_levels
	boss_trial_advance_after_levels = false
	upgrade_open = false
	input_router.set_input_enabled(true)
	if should_advance_trial:
		director.advance_boss_trial_after_elite()

func _on_pause_requested() -> void:
	if paused or finished or upgrade_open or player_death_cinematic_active or ultimate_cutin.is_playing():
		return
	paused = true
	AudioService.set_hero_firewheel_loop_paused(true)
	AudioService.set_battle_bgm_paused(true)
	input_router.set_input_enabled(false)
	hud.show_pause()

func _on_resume_requested() -> void:
	if not paused:
		return
	paused = false
	AudioService.set_hero_firewheel_loop_paused(false)
	AudioService.set_battle_bgm_paused(false)
	hud.hide_pause()
	input_router.set_input_enabled(true)

func _on_home_requested() -> void:
	SceneRouter.go_home()

func _on_player_died() -> void:
	if finished or player_death_cinematic_active:
		return
	var hero_name := HERO_CATALOG.display_name_for(player.hero_id)
	pending_defeat_message = "%s力竭，名将试炼失败" % hero_name if director.is_boss_trial() else "%s力竭，战局失败" % hero_name
	player_death_cinematic_active = true
	input_router.set_input_enabled(false)
	AudioService.stop_hero_firewheel_loop()
	if ultimate_cutin.is_playing():
		ultimate_cutin.cancel()
	telegraphs.clear()
	enemies.freeze_for_cinematic()
	for elite in elites:
		if is_instance_valid(elite):
			elite.freeze_for_cinematic()
	boss.freeze_for_cinematic()
	renderer.begin_player_death_cinematic(player.hero_id)

func _on_boss_defeated() -> void:
	_cancel_boss_telegraphs()
	run_merit_fraction += 180.0
	run_gold = int(floor(run_merit_fraction))
	hud.set_run_gold(run_gold)
	player.apply_military_boss_defeat_reward()
	if director.is_boss_trial():
		_finish_run(true, "张郃败退，名将试炼完成！")
		return
	var battlefield_result := "夏侯惇败退，博望坡火谷突围成功！" if director.is_bowangpo() else "张郃败退，长坂坡突围成功！"
	_finish_run(true, battlefield_result)

func _is_named_threat_source(source: String) -> bool:
	return source == "boss" or source.begins_with("elite:")

func _named_threat_count() -> int:
	var count := 0
	for telegraph in telegraphs:
		if _is_named_threat_source(telegraph.source):
			count += 1
	return count

func _on_restart_requested() -> void:
	SceneRouter.restart_run()

func _finish_run(victory: bool, message: String) -> void:
	if finished:
		return
	finished = true
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_battle_bgm()
	input_router.set_input_enabled(false)
	hud.set_message(message)
	hud.show_result(victory, message)
	var clear_reward := _clear_military_merit_reward(victory)
	run_gold += clear_reward
	hud.set_run_gold(run_gold)
	SceneRouter.finish_run({"victory": victory, "military_merit": run_gold})

func _clear_military_merit_reward(victory: bool) -> int:
	if not victory:
		return 0
	if director != null and director.is_boss_trial():
		return 120
	if run_mode == "endless":
		return 50 + mini(4, int(floor(director.elapsed / 300.0))) * 20
	var chapter := clampi(SceneRouter.active_story_chapter, 1, 6)
	return 60 + (chapter - 1) * 8
