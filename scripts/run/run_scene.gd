class_name RunScene
extends Node2D

const WORLD_BOUNDS := Rect2(0, 0, 2560, 1440)
const BOWANGPO_WORLD_BOUNDS := Rect2(0, 0, 2304, 1248)
const BOSS_TRIAL_WORLD_BOUNDS := Rect2(0, 0, 1672, 941)
const BOSS_TRIAL_ARENA_BOUNDS := BattlefieldLayout.BOSS_TRIAL_ARENA_BOUNDS
const CAMERA_LOOK_AHEAD := 68.0
const DEFAULT_BATTLE_CAMERA_ZOOM := Vector2(1.55, 1.55)
const NORMAL_GUARD_CAMERA_ZOOM_MULTIPLIER := 1.08
const PERFECT_GUARD_CAMERA_ZOOM_MULTIPLIER := 1.16
const NORMAL_GUARD_CAMERA_FOCUS_DURATION := 0.35
const PERFECT_GUARD_CAMERA_FOCUS_DURATION := 0.60
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
const HERO_ATTACK_SHOUT_CHANCE := 0.20
const ELITE_ACTOR_SCENE := preload("res://scenes/actors/elite_actor.tscn")
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")
const BATTLE_WEATHER_MODES := ["sunny", "rain", "storm", "snow"]
const BOSS_TRIAL_STARTING_UPGRADES := 5
const BOSS_TRIAL_LEVELS_PER_NAMED_DEFEAT := 5
const BOSS_TRIAL_UPGRADE_OPTION_COUNT := 3
const BOSS_TRIAL_UPGRADE_SELECTION_LIMIT := 1
const UPGRADE_REFRESH_LIMIT := 5
const WEAPON_CLASH_WINDOW := 0.28
const PERFECT_WEAPON_CLASH_WINDOW := 0.10
const NORMAL_CLASH_STANCE_DAMAGE := 18.0
const PERFECT_CLASH_STANCE_DAMAGE := 58.0
const NORMAL_SKILL_CLASH_STANCE_DAMAGE := 27.0
const PERFECT_SKILL_CLASH_STANCE_DAMAGE := 87.0
const CLASH_TIME_SCALE := 0.50
const NORMAL_CLASH_SLOW_DURATION := 0.35
const EMPHATIC_CLASH_SLOW_DURATION := 0.60
const VICTORY_CINEMATIC_HOLD_DURATION := 0.22
const VICTORY_CINEMATIC_SALVO_INTERVAL := 0.42
const VICTORY_CINEMATIC_FINAL_HOLD_DURATION := 0.34
const VICTORY_CINEMATIC_SALVO_COUNT := 3
const STORY_CLEAR_MERIT := [160.0, 240.0, 340.0, 480.0, 650.0]
const BOSS_DEFEAT_MERIT := 220.0
const BOSS_TRIAL_ID := "lvbu"
const BOSS_TRIAL_BOSS_DEFEAT_MERIT := 1100.0
const BOSS_TRIAL_FIRST_CLEAR_MERIT := 600.0
# Rewarded refreshes are temporarily hidden. Keep the counter for runtime
# compatibility so the ad path can be restored without changing draft flow.
const UPGRADE_AD_REFRESH_LIMIT := 0
const ENDLESS_MILESTONE_TIMES := [300.0, 600.0, 900.0, 1200.0]
const ENDLESS_MILESTONE_REWARDS := [120.0, 160.0, 200.0, 260.0]

@onready var renderer: BattleRenderer = $BattleRenderer
@onready var player: HeroActor = $Player as HeroActor  # 使用 as 转换以避免类型错误
var battle_camera: Camera2D
@onready var boss: BossActor = $Boss
@onready var enemies: EnemySimulation = $EnemySimulation
@onready var combat: CombatSystem = $CombatSystem
@onready var upgrades: UpgradeSystem = $UpgradeSystem
@onready var tianji: TianjiSystem = $TianjiSystem
@onready var director: RunDirector = $RunDirector
@onready var loot: LootSystem = $LootSystem
@onready var input_router: InputRouter = $InputRouter
@onready var hud: BattleHud = $HudLayer/BattleHud
@onready var ultimate_cutin: UltimateCutin = $UltimateCutinLayer/UltimateCutin

var telegraphs: Array[Telegraph] = []
var elites: Array[EliteActor] = []
var upgrade_open := false
var finished := false
var restart_settlement_started := false
var paused := false
var player_death_cinematic_active := false
var revive_prompt_active := false
var revive_count := 0
var pending_defeat_message := ""
var victory_cinematic_active := false
var victory_phase := ""
var victory_phase_remaining := 0.0
var victory_message := ""
var victory_result_stats: Dictionary = {}
var victory_salvo_index := 0
var run_defeated_count := 0
var run_damage_taken := 0.0
var hitstop_remaining := 0.0
var clash_slow_remaining := 0.0
var battle_camera_focus_remaining := 0.0
var battle_camera_focus_multiplier := 1.0
const DUEL_HIT_LOG_PATH := "user://duel_hit_debug.log"
var run_gold := 0
var run_merit_fraction := 0.0
var endless_milestone_index := 0
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
var guard_perfect_telegraphs: Dictionary = {}
var guard_named_reward_consumed := false
var upgrade_refreshes_remaining := UPGRADE_REFRESH_LIMIT
var upgrade_ad_refreshes_remaining := UPGRADE_AD_REFRESH_LIMIT
var result_double_claimed := false
var current_upgrade_level := 1
var current_upgrade_options: Array[String] = []
var current_upgrade_selection_limit := 1
var current_upgrade_selection_count := 0
var opening_strategy_selected := false
var run_strategy_id := UpgradeSystem.DRAFT_TENDENCY_BALANCED
var duel_formation_was_sealed := false
var overtime_settlement_active := false
var overtime_settlement_remaining := 0.0
var pending_named_formations: Array[Dictionary] = []
var pending_named_formation_safe_remaining := 0.0
var armed_named_formation: Dictionary = {}
var named_formation_warning_remaining := 0.0
const OVERTIME_SETTLEMENT_DELAY := 5.0
const MAX_REVIVES_PER_RUN := 2
const NAMED_FORMATION_WARNING_DURATION := 3.0
const NAMED_FORMATION_POST_COMBAT_DELAY := 12.0

func _ready() -> void:
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_enemy_duel_cheers()
	AudioService.stop_battle_voiceovers()
	AudioService.play_battle_bgm()
	upgrade_refreshes_remaining = UPGRADE_REFRESH_LIMIT
	upgrade_ad_refreshes_remaining = UPGRADE_AD_REFRESH_LIMIT
	revive_prompt_active = false
	revive_count = 0
	result_double_claimed = false
	duel_formation_was_sealed = false
	overtime_settlement_active = false
	overtime_settlement_remaining = 0.0
	pending_named_formations.clear()
	pending_named_formation_safe_remaining = 0.0
	armed_named_formation.clear()
	named_formation_warning_remaining = 0.0
	_reset_duel_hit_debug_log()
	var profile := SaveService.load_profile()
	run_mode = SceneRouter.active_mode
	endless_milestone_index = 0
	active_world_bounds = _world_bounds_for_mode(run_mode)
	active_obstacles = BATTLEFIELD_LAYOUT.obstacle_rects_for(_active_battlefield_id(), active_world_bounds)
	boss_trial_advance_after_levels = false
	_install_equipped_hero(SaveService.equipped_hero_id())
	if not _battle_dependencies_ready():
		set_process(false)
		LoadingOverlay.finish_transition()
		return
	boss.set_movement_bounds(active_world_bounds.grow(-NAMED_SPAWN_MARGIN))
	enemies.reset(active_world_bounds, run_mode)
	enemies.set_navigation_obstacles(active_obstacles)
	loot.reset()
	player.reset_for_run(active_world_bounds)
	player.reset_guard_state()
	player.position = _resolve_movement_against_obstacles(player.position, player.position, 16.0)
	player_last_audio_position = player.position
	enemy_voice_remaining = randf_range(ENEMY_VOICE_INTERVAL_MIN, ENEMY_VOICE_INTERVAL_MAX)
	player.apply_account_progress(profile)
	loot.configure_account_progress(profile)
	_configure_battle_camera()
	director.configure_performance_profile(OS.has_feature("mobile"))
	director.configure_account_progress(profile)
	director.set_enemy_simulation(enemies)
	director.reset(active_world_bounds, run_mode, _active_battlefield_id(), SceneRouter.active_story_chapter)
	if director.is_boss_trial():
		for _level in range(2, director.level + 1):
			player.apply_level_up_benefits()
	enemies.set_threat_tier(director.threat_tier())
	enemies.set_difficulty_ramp(director.difficulty_multiplier())
	upgrades.configure_talent_pool(profile, player.hero_id)
	upgrades.configure_tianji_pool(profile)
	upgrades.set_draft_tendency(UpgradeSystem.DRAFT_TENDENCY_BALANCED)
	upgrades.randomize_seed()
	# Keep the complete artwork visible while the simulation remains constrained
	# to the central stone arena.
	var renderer_bounds := BOSS_TRIAL_WORLD_BOUNDS if director.is_boss_trial() else active_world_bounds
	renderer.configure(renderer_bounds, enemies, player, boss, telegraphs, loot, elites, _active_battlefield_id())
	renderer.set_battle_camera(battle_camera)
	renderer.set_weather_mode("sunny" if run_mode == "endless" else _battle_weather_for(profile))
	tianji.configure(player, enemies, elites, boss, battle_camera, upgrades.tianji_slot_capacity())
	hud.configure(player, boss, director, elites, tianji)
	if not active_obstacles.is_empty():
		hud.set_message("%s · 已载入 %d 处地形障碍" % [BATTLEFIELD_LAYOUT.title_for(_active_battlefield_id()), active_obstacles.size()])
	hud.set_upgrade_refreshes_remaining(upgrade_refreshes_remaining)
	hud.set_upgrade_ad_refreshes_remaining(upgrade_ad_refreshes_remaining)
	input_router.configure(player, hud)
	player.attack_requested.connect(_on_player_attack)
	player.visual_effect_started.connect(_on_player_visual_effect_started)
	player.camera_shake_requested.connect(_on_player_camera_shake)
	player.combat_action_started.connect(_on_player_combat_action_started)
	player.combat_action_finished.connect(_on_player_combat_action_finished)
	player.ultimate_ready.connect(_on_ultimate_ready)
	player.ultimate_started.connect(_on_ultimate_started)
	player.died.connect(_on_player_died)
	player.damaged.connect(_on_player_damaged)
	enemies.enemy_died.connect(_on_enemy_died)
	loot.collected.connect(_on_loot_collected)
	enemies.enemy_attack_requested.connect(_on_enemy_attack)
	enemies.enemy_attack_cancelled.connect(_on_enemy_attack_cancelled)
	enemies.enemy_death_collision.connect(_on_enemy_death_collision)
	enemies.banner_command_requested.connect(_on_banner_command)
	enemies.named_formation_broken.connect(_on_named_formation_broken)
	enemies.named_formation_gate_changed.connect(_on_named_formation_gate_changed)
	enemies.named_formation_break_opened.connect(_on_named_formation_break_opened)
	director.spawn_requested.connect(_on_spawn_requested)
	director.formation_requested.connect(_on_formation_requested)
	director.elite_requested.connect(_on_elite_requested)
	director.boss_requested.connect(_on_boss_requested)
	director.level_up.connect(_on_level_up)
	director.stage_changed.connect(hud.set_message)
	director.weather_changed.connect(renderer.set_weather_mode)
	director.threat_tier_changed.connect(_on_threat_tier_changed)
	boss.telegraph_requested.connect(_add_telegraph)
	boss.skill_impact_requested.connect(_on_named_skill_impact)
	boss.rush_started.connect(_on_boss_rush_started)
	boss.summon_requested.connect(_on_boss_summon)
	boss.phase_changed.connect(_on_boss_phase)
	boss.defeated.connect(_on_boss_defeated)
	tianji.skill_windup_started.connect(_on_tianji_windup_started)
	tianji.skill_impacted.connect(_on_tianji_impacted)
	tianji.damage_applied.connect(_on_tianji_damage_applied)
	tianji.fire_rain_meteor_started.connect(_on_fire_rain_meteor_started)
	hud.upgrade_selected.connect(_on_upgrade_selected)
	hud.upgrade_refresh_requested.connect(_on_upgrade_refresh_requested)
	hud.run_strategy_selected.connect(_on_run_strategy_selected)
	hud.revive_requested.connect(_on_revive_requested)
	hud.revive_declined.connect(_on_revive_declined)
	hud.result_reward_requested.connect(_on_result_reward_requested)
	hud.restart_requested.connect(_on_restart_requested)
	hud.resume_requested.connect(_on_resume_requested)
	hud.combo_setting_changed.connect(_on_combo_setting_changed)
	hud.home_requested.connect(_on_home_requested)
	hud.retreat_requested.connect(_on_retreat_requested)
	AdService.rewarded_video_completed.connect(_on_rewarded_video_completed)
	input_router.basic_requested.connect(player.request_basic)
	input_router.basic_hold_started.connect(player.begin_basic_hold)
	input_router.basic_hold_released.connect(player.release_basic_hold)
	input_router.active_hold_started.connect(player.begin_active_hold)
	input_router.active_hold_released.connect(player.release_active_hold)
	input_router.active_requested.connect(player.request_active)
	input_router.ultimate_requested.connect(_on_ultimate_requested)
	input_router.guard_requested.connect(_on_guard_requested)
	input_router.weapon_stance_requested.connect(_on_weapon_stance_requested)
	input_router.pause_requested.connect(_on_pause_requested)
	upgrade_open = true
	input_router.set_input_enabled(false)
	call_deferred("_open_run_strategy_choice")
	# SceneRouter closes the departure overlay only after it confirms this scene
	# is active. Keep direct scene launches and restarts compatible without
	# allowing _ready() to report a false "战场已就绪" during a pending switch.
	if not SceneRouter.scene_transition_pending:
		LoadingOverlay.finish_transition()

func _exit_tree() -> void:
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_enemy_duel_cheers()
	AudioService.stop_battle_voiceovers()
	AudioService.stop_battle_bgm()

func _install_equipped_hero(requested_hero_id: String) -> void:
	var hero_id := requested_hero_id if HERO_CATALOG.is_playable(requested_hero_id) else "zhao_yun"
	var actor_scene_path := HERO_CATALOG.actor_scene_for(hero_id)
	if actor_scene_path.is_empty():
		push_warning("No playable actor scene configured for %s; falling back to Zhao Yun." % hero_id)
		hero_id = "zhao_yun"
		actor_scene_path = HERO_CATALOG.actor_scene_for(hero_id)
	if not is_instance_valid(player):
		var invalid_player_node := get_node_or_null("Player")
		if invalid_player_node != null:
			remove_child(invalid_player_node)
			invalid_player_node.queue_free()
		player = null
		var initial_player := _instantiate_hero_actor(actor_scene_path)
		if initial_player == null and hero_id != "zhao_yun":
			hero_id = "zhao_yun"
			actor_scene_path = HERO_CATALOG.actor_scene_for(hero_id)
			initial_player = _instantiate_hero_actor(actor_scene_path)
		if initial_player != null:
			initial_player.name = "Player"
			add_child(initial_player)
			player = initial_player
	if player != null and player.scene_file_path != actor_scene_path:
		var replacement := _instantiate_hero_actor(actor_scene_path)
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
	if player != null:
		player.configure_hero(hero_id)
	battle_camera = player.get_node_or_null("BattleCamera") as Camera2D if player != null else null
	if battle_camera == null:
		push_error("Hero actor %s must provide a BattleCamera child." % hero_id)

func _instantiate_hero_actor(actor_scene_path: String) -> HeroActor:
	if actor_scene_path.is_empty():
		return null
	var actor_scene := load(actor_scene_path) as PackedScene
	if actor_scene == null:
		push_error("Unable to load hero actor scene: %s" % actor_scene_path)
		return null
	var actor := actor_scene.instantiate()
	var hero_actor := actor as HeroActor
	if hero_actor == null:
		if actor != null:
			actor.queue_free()
		push_error("Hero actor scene does not extend HeroActor: %s" % actor_scene_path)
	return hero_actor

func _battle_dependencies_ready() -> bool:
	var missing: Array[String] = []
	if not is_instance_valid(player):
		missing.append("Player")
	if not is_instance_valid(boss):
		missing.append("Boss")
	if not is_instance_valid(enemies):
		missing.append("EnemySimulation")
	if not is_instance_valid(combat):
		missing.append("CombatSystem")
	if not is_instance_valid(upgrades):
		missing.append("UpgradeSystem")
	if not is_instance_valid(tianji):
		missing.append("TianjiSystem")
	if not is_instance_valid(director):
		missing.append("RunDirector")
	if not is_instance_valid(loot):
		missing.append("LootSystem")
	if not is_instance_valid(input_router):
		missing.append("InputRouter")
	if not is_instance_valid(renderer):
		missing.append("BattleRenderer")
	if not is_instance_valid(hud):
		missing.append("BattleHud")
	if not is_instance_valid(ultimate_cutin):
		missing.append("UltimateCutin")
	if missing.is_empty():
		return true
	push_error("Battle scene cannot start; missing dependencies: %s" % ", ".join(missing))
	return false

func _process(delta: float) -> void:
	if paused:
		return
	if finished or upgrade_open:
		return
	if victory_cinematic_active:
		_tick_victory_cinematic(delta)
		return
	if player_death_cinematic_active:
		renderer.tick_player_death_cinematic(delta)
		if renderer.is_player_death_cinematic_finished():
			player_death_cinematic_active = false
			if revive_count < MAX_REVIVES_PER_RUN:
				revive_prompt_active = true
				hud.show_revive_prompt(MAX_REVIVES_PER_RUN - revive_count)
			else:
				_finish_run(false, pending_defeat_message)
		return
	if revive_prompt_active:
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
	player.tick_guard(simulation_delta)
	player.tick(simulation_delta, move_direction)
	player.position = _resolve_movement_against_obstacles(player_move_origin, player.position, 16.0)
	_tick_player_action_clash()
	_tick_player_move_audio(simulation_delta, move_direction)
	_update_battle_camera(simulation_delta)
	director.set_spawn_view_rect(_battle_visible_world_rect())
	director.tick(delta, enemies.active_count, player.position)
	_tick_endless_milestones()
	enemies.set_battle_elapsed(director.elapsed)
	enemies.set_difficulty_ramp(director.difficulty_multiplier())
	var enemy_move_origins := _capture_enemy_positions()
	enemies.tick(simulation_delta, player.position)
	_resolve_enemy_obstacles(enemy_move_origins)
	if enemies.is_duel_formation_active():
		player.position = enemies.apply_duel_player_boundary(player_move_origin, player.position)
		if enemies.is_duel_formation_sealed() and not duel_formation_was_sealed:
			duel_formation_was_sealed = true
			AudioService.start_enemy_duel_cheers()
			hud.begin_duel_hints()
		elif not enemies.is_duel_formation_sealed() and duel_formation_was_sealed:
			_stop_duel_formation_audio()
	elif duel_formation_was_sealed:
		_stop_duel_formation_audio()
	var nearby_radius: float = player.nearby_enemy_radius()
	var nearby_enemy_count := enemies.count_active_within(player.position, nearby_radius)
	for elite in elites:
		if is_instance_valid(elite) and elite.active and elite.position.distance_to(player.position) <= nearby_radius:
			nearby_enemy_count += 1
	if boss.active and boss.position.distance_to(player.position) <= nearby_radius:
		nearby_enemy_count += 1
	player.set_nearby_enemy_count(nearby_enemy_count)
	loot.tick(simulation_delta, player.position)
	var named_move_origins := _capture_named_positions()
	_tick_named_enemies(simulation_delta)
	_resolve_named_obstacles(named_move_origins)
	_tick_pending_named_formation(delta)
	tianji.tick(simulation_delta)
	_tick_telegraphs(simulation_delta)
	if director.is_time_over():
		if not boss.active and not boss.is_dying():
			_finish_run(true, director.story_completion_message() if run_mode == "story" else "无尽试炼完成，军功已结算")
		else:
			_tick_overtime_settlement(delta)

func _on_spawn_requested(enemy_type: int, at: Vector2) -> void:
	# 军旗兵暂未开放，防止旧配置或遗留波次将其生成到战场。
	if enemy_type == EnemySimulation.EnemyType.BANNER:
		return
	enemies.spawn(enemy_type, at)

func _on_formation_requested(_formation_id: String, _at: Vector2) -> void:
	# 铁桶阵已取消；保留信号接收端，兼容旧关卡配置而不创建任何阵型。
	return

func _on_named_formation_broken(formation_id: String) -> void:
	var formation_name := _named_formation_name(formation_id)
	hud.set_message("%s已破，敌阵溃散" % formation_name)

func _on_named_formation_gate_changed(_at: Vector2) -> void:
	if enemies != null and enemies.is_named_formation_active() and enemies.named_formation_id() == "bagua":
		hud.set_message("八卦阵生门轮换：追击青色阵眼")

func _on_named_formation_break_opened(formation_id: String) -> void:
	var formation_name := _named_formation_name(formation_id)
	hud.set_message("%s破阵窗口开启：剩余15秒，优先攻击高亮阵眼" % formation_name)

func _tick_pending_named_formation(delta: float) -> void:
	# 队列只曾用于铁桶阵。清理旧会话或旧配置遗留请求，避免再次触发已下线的玩法。
	pending_named_formations.clear()
	armed_named_formation.clear()
	pending_named_formation_safe_remaining = 0.0
	named_formation_warning_remaining = 0.0

func _is_named_formation_start_safe() -> bool:
	if enemies == null or boss == null:
		return false
	if enemies.is_duel_formation_active() or boss.active or boss.is_dying():
		return false
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			return false
	return true

func _named_formation_name(formation_id: String) -> String:
	match formation_id:
		"eight_gates": return "八门金锁阵"
		"fish_scale": return "鱼鳞阵"
		"bagua": return "八卦阵"
	return "敌军阵法"

func _named_formation_start_message(formation_id: String) -> String:
	match formation_id:
		"eight_gates": return "八门金锁阵成阵：外圈盾墙封门，内格枪弓协击"
		"fish_scale": return "鱼鳞阵成阵：盾墙错列成鳞，两翼骑兵沿通道突入"
		"bagua": return "八卦阵成阵：回字迷宫闭合，追踪轮换阵眼破阵"
	return "%s成阵" % _named_formation_name(formation_id)

func _on_threat_tier_changed(tier: int) -> void:
	enemies.set_threat_tier(tier)

func _world_bounds_for_mode(mode: String) -> Rect2:
	if mode == RunDirector.BOSS_TRIAL_MODE:
		return BOSS_TRIAL_ARENA_BOUNDS
	return BOWANGPO_WORLD_BOUNDS if _active_battlefield_id() == "bowangpo" else WORLD_BOUNDS

func _active_battlefield_id() -> String:
	if run_mode == "endless":
		return "changban"
	return SceneRouter.active_battlefield_id if SceneRouter.active_battlefield_id in ["changban", "xinye", "bowangpo", "bowangpo_story", "huoshaoxinye", "xiangyangchetui", "dangyangduanhou", "hulao"] else "changban"

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
			var origin: Vector2 = origins[enemy_id] if enemy_id < origins.size() else enemies.positions[enemy_id]
			var destination: Vector2 = enemies.positions[enemy_id]
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
			if enemies.is_duel_formation_active():
				elite.position = enemies.constrain_named_to_duel_formation(elite.position, 32.0)
	if boss.active:
		var boss_origin: Vector2 = origins.get(boss.get_instance_id(), boss.position) as Vector2
		boss.position = _resolve_movement_against_obstacles(boss_origin, boss.position, 26.0)
		if enemies.is_duel_formation_active():
			boss.position = enemies.constrain_named_to_duel_formation(boss.position, 40.0)

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
	if not director.is_boss_trial() and not enemies.is_duel_formation_active():
		enemies.begin_duel_formation(player.position)
		director.set_spawn_background_mode(true)
		_stop_duel_formation_audio()
	renderer.set_elites(elites)
	hud.set_elites(elites)
	hud.set_message("精英现身：%s · 敌军正在列阵" % elite.display_name())

func _configure_battle_camera() -> void:
	# Active bounds are selected before RunDirector.reset(), so they are safe to
	# use for initial camera limits here.
	# Trial actors remain constrained to the central arena, but the camera can
	# pan across the complete background so its edge atmosphere guards are visible.
	var camera_bounds := BOSS_TRIAL_WORLD_BOUNDS if run_mode == RunDirector.BOSS_TRIAL_MODE else active_world_bounds
	battle_camera.limit_left = int(camera_bounds.position.x)
	battle_camera.limit_top = int(camera_bounds.position.y)
	battle_camera.limit_right = int(camera_bounds.end.x)
	battle_camera.limit_bottom = int(camera_bounds.end.y)
	battle_camera.zoom = DEFAULT_BATTLE_CAMERA_ZOOM
	battle_camera.position = Vector2(player.last_attack_direction.x * CAMERA_LOOK_AHEAD, 0.0)
	battle_camera_focus_remaining = 0.0
	battle_camera_focus_multiplier = 1.0
	battle_camera.make_current()
	battle_camera.reset_smoothing()
	battle_camera.force_update_scroll()

func _update_battle_camera(delta: float) -> void:
	var focus_active := battle_camera_focus_remaining > 0.0
	battle_camera_focus_remaining = maxf(0.0, battle_camera_focus_remaining - delta)
	var target_offset := 0.0 if focus_active else player.last_attack_direction.x * CAMERA_LOOK_AHEAD
	var target_zoom := DEFAULT_BATTLE_CAMERA_ZOOM * (battle_camera_focus_multiplier if focus_active else 1.0)
	battle_camera.position.x = move_toward(battle_camera.position.x, target_offset, 300.0 * delta)
	battle_camera.zoom = battle_camera.zoom.lerp(target_zoom, minf(1.0, delta * (14.0 if focus_active else 8.0)))

func _focus_battle_camera_after_guard(perfect: bool) -> void:
	var focus_duration := PERFECT_GUARD_CAMERA_FOCUS_DURATION if perfect else NORMAL_GUARD_CAMERA_FOCUS_DURATION
	var focus_multiplier := PERFECT_GUARD_CAMERA_ZOOM_MULTIPLIER if perfect else NORMAL_GUARD_CAMERA_ZOOM_MULTIPLIER
	if focus_duration >= battle_camera_focus_remaining:
		battle_camera_focus_multiplier = focus_multiplier
	battle_camera_focus_remaining = maxf(battle_camera_focus_remaining, focus_duration)

func _battle_visible_world_rect() -> Rect2:
	if battle_camera == null:
		return Rect2()
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Rect2()
	var zoom := battle_camera.zoom
	var visible_world_size := Vector2(
		viewport_size.x / maxf(0.01, zoom.x),
		viewport_size.y / maxf(0.01, zoom.y)
	)
	return Rect2(battle_camera.get_screen_center_position() - visible_world_size * 0.5, visible_world_size)

func _update_named_target_indicators() -> void:
	var visible_world_rect := _battle_visible_world_rect()
	if visible_world_rect.size.x <= 0.0 or visible_world_rect.size.y <= 0.0:
		return
	var screen_center := battle_camera.get_screen_center_position()
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
	var boss_id := director.boss_archetype_id()
	match boss_id:
		"xiahou_dun": boss.set_archetype(BossActor.Archetype.XIAHOU_DUN)
		"lvbu": boss.set_archetype(BossActor.Archetype.LV_BU)
		_: boss.set_archetype(BossActor.Archetype.ZHANG_HE)
	boss.activate(_choose_named_spawn(spawn_min_distance, spawn_max_distance), threat_tier)
	AudioService.play_boss_entrance_voice()
	if not director.is_boss_trial() and not enemies.is_duel_formation_active():
		enemies.begin_duel_formation(player.position)
		director.set_spawn_background_mode(true)
		_stop_duel_formation_audio()
	hud.set_message("%s·%s 现身 · 敌军正在列阵" % [boss.display_name(), boss.weapon_title()])

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
		# Guard has no dedicated frame set and falls back to a proxy block. Use
		# animated sword soldiers for the close escort instead.
		_spawn_boss_guard(EnemySimulation.EnemyType.SWORD, base + Vector2(0, 45))
		_spawn_boss_guard(EnemySimulation.EnemyType.SWORD, base + Vector2(0, 82))

func _on_boss_phase(phase: int) -> void:
	_cancel_boss_telegraphs()
	player.add_ultimate_energy(5.0)
	hud.set_message("%s进入第 %d 阶段" % [boss.display_name(), phase])

func _on_tianji_windup_started(skill_id: String, center: Vector2, direction: Vector2, definition: Dictionary, rank: int, radius: float) -> void:
	renderer.add_tianji_windup(skill_id, center, direction, definition, rank, radius)

func _on_tianji_impacted(skill_id: String, center: Vector2, direction: Vector2, hit_count: int, active_duration: float, rank: int, radius: float) -> void:
	renderer.add_tianji_impact(skill_id, center, direction, hit_count, active_duration, rank, radius)
	if skill_id == "fire_rain_final" and rank >= 5 and not paused and not upgrade_open and not finished:
		HapticService.tianji_final_meteor()
	if skill_id in ["seven_star_lightning", "arrow_support_volley", "eight_trigram_tide", "xun_wind_break"]:
		AudioService.start_tianji_sound(skill_id, tianji.sound_duration_for(skill_id))

func _on_tianji_damage_applied(hit_count: int) -> void:
	if hit_count > 0 and not paused and not upgrade_open and not finished:
		HapticService.tianji_damage()

func _on_fire_rain_meteor_started(center: Vector2, rank: int, final_meteor: bool, delay: float, radius: float, wave_index: int, wave_last: bool) -> void:
	renderer.add_fire_rain_meteor(center, rank, final_meteor, delay, radius, wave_index, wave_last)
	if wave_index == 0:
		AudioService.start_tianji_sound("fire_rain_burning", tianji.sound_duration_for("fire_rain_burning"))

func _on_player_visual_effect_started(effect_id: String, _origin: Vector2, _direction: Vector2, _travel_distance: float, _metadata: Dictionary) -> void:
	if effect_id in ["guan_drag_wave", "guan_active_wave", "guan_wusheng_wave", "guan_fourth_wave"]:
		AudioService.play_guan_yu_blade_wave()

func _on_player_camera_shake(strength: float) -> void:
	if renderer != null and is_instance_valid(renderer):
		renderer.add_named_skill_shake(strength)

func _on_player_attack(request: AttackRequest) -> void:
	if request.label in ["丈八跃砸", "据水断桥·跃砸", "蛇矛掷阵·裂地·首震"]:
		AudioService.play_zhang_fei_ground_slam()
	if request.clears_projectiles:
		_clear_projectiles_in_attack(request)
	# Offensive weapon-clash resolution is intentionally hidden for this version.
	# The legacy resolver remains below for compatibility, while the live combat
	# path uses the dedicated guard button instead.
	var clashed_elite_ids: Dictionary = {}
	var clashed_boss := false
	var hit_count := combat.resolve_hero_attack(request, player.total_attack(), 0.0, enemies)
	var combo_hit_count := hit_count
	for elite in elites:
		var elite_id := elite.get_instance_id()
		var can_hit_elite := not request.one_hit_per_target or not request.hit_elite_ids.has(elite_id)
		var elite_geometry_hit := elite.active and combat.request_hits_point(request, elite.position)
		if enemies.is_duel_formation_active() and elite.active:
			_log_duel_named_hit("elite", elite.display_name(), request, elite.position, elite_geometry_hit, elite.is_cast_invulnerable(), elite.current_action, elite.health_component.current, -1.0)
		if can_hit_elite and not clashed_elite_ids.has(elite_id) and elite_geometry_hit:
			# 垂直盾墙系统：精英总是可以被攻击到，不再有圆形盾墙的阻挡逻辑
			if request.displacement_only:
				_apply_elite_guard_knockback(elite, request)
				request.hit_elite_ids[elite_id] = true
				request.total_hits += 1
				hit_count += 1
				continue
			var elite_damage := CombatMath.final_damage(player.total_attack(), request.damage_multiplier_at(elite.position), 0.0, elite.armor())
			elite_damage = player.modify_named_target_damage(HeroActor.NamedTargetKind.ELITE, "elite:%d" % elite_id, request, elite_damage)
			var elite_result := elite.receive_player_hit(elite_damage)
			var elite_actual_damage := float(elite_result.get("damage", 0.0))
			if enemies.is_duel_formation_active():
				_log_duel_named_hit("elite_result", elite.display_name(), request, elite.position, true, elite.is_cast_invulnerable(), elite.current_action, elite.health_component.current, elite_actual_damage, elite_result)
			if elite_actual_damage > 0.0:
				combo_hit_count += 1
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
	var boss_geometry_hit := boss.active and combat.request_hits_point(request, boss.position)
	if enemies.is_duel_formation_active() and boss.active:
		_log_duel_named_hit("boss", boss.display_name(), request, boss.position, boss_geometry_hit, boss.is_cast_invulnerable(), boss.current_action, boss.health_component.current, -1.0)
	if can_hit_boss and not clashed_boss and boss_geometry_hit:
		# 垂直盾墙系统：领主总是可以被攻击到，不再需要等待决斗封闭
		if request.displacement_only:
			_apply_boss_guard_knockback(request)
			request.hit_boss = true
			request.total_hits += 1
			hit_count += 1
		else:
			var boss_damage := CombatMath.final_damage(player.total_attack(), request.damage_multiplier_at(boss.position), 0.0, boss.armor())
			boss_damage = player.modify_named_target_damage(HeroActor.NamedTargetKind.BOSS, "boss", request, boss_damage)
			var vulnerable_stance_damage := (request.stance_damage if request.stance_damage > 0.0 else BossActor.VULNERABLE_DEFAULT_STANCE_DAMAGE) if boss.is_vulnerable() else 0.0
			var boss_result := boss.receive_player_hit(boss_damage, vulnerable_stance_damage)
			var boss_actual_damage := float(boss_result.get("damage", 0.0))
			if enemies.is_duel_formation_active():
				_log_duel_named_hit("boss_result", boss.display_name(), request, boss.position, true, boss.is_cast_invulnerable(), boss.current_action, boss.health_component.current, boss_actual_damage, boss_result)
			if boss_actual_damage > 0.0:
				combo_hit_count += 1
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
	if combo_hit_count > 0:
		hud.record_combo_hits(combo_hit_count)
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

func _reset_duel_hit_debug_log() -> void:
	var file := FileAccess.open(DUEL_HIT_LOG_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("无法创建斗将受击日志：%s" % DUEL_HIT_LOG_PATH)
		return
	file.store_line(JSON.stringify({
		"event": "run_started",
		"timestamp": Time.get_datetime_string_from_system(),
		"path": DUEL_HIT_LOG_PATH,
	}))

func _log_duel_named_hit(kind: String, target_name: String, request: AttackRequest, target_position: Vector2, geometry_hit: bool, cast_invulnerable: bool, action: String, health_before_or_current: float, actual_damage: float, result: Dictionary = {}) -> void:
	var file := FileAccess.open(DUEL_HIT_LOG_PATH, FileAccess.READ_WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line(JSON.stringify({
		"event": kind,
		"run_time": director.elapsed if director != null else -1.0,
		"target": target_name,
		"attack": request.label,
		"shape": request.shape,
		"origin": {"x": request.origin.x, "y": request.origin.y},
		"target_position": {"x": target_position.x, "y": target_position.y},
		"geometry_hit": geometry_hit,
		"cast_invulnerable": cast_invulnerable,
		"current_action": action,
		"health": health_before_or_current,
		"actual_damage": actual_damage,
		"invulnerable_result": bool(result.get("invulnerable", false)),
		"duel_sealed": enemies.is_duel_formation_sealed() if enemies != null else false,
	}))

func _tick_player_action_clash() -> void:
	# Offensive weapon clashes are retained as dormant compatibility code.
	player.consume_weapon_clash_window()

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
			var boss_broken := boss.add_stance_damage(_clash_stance_damage(perfect, clash_kind), perfect)
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
		var elite_broken := elite.add_stance_damage(_clash_stance_damage(perfect, clash_kind), perfect)
		var clashed_elite_ids: Dictionary = result.get("elite_ids", {}) as Dictionary
		clashed_elite_ids[elite.get_instance_id()] = true
		result["elite_ids"] = clashed_elite_ids
		_finalize_weapon_clash((player.position + elite.position) * 0.5, perfect, clash_kind, elite.display_name(), elite_broken, elite)
		return result
	return result

func _try_resolve_late_weapon_clash(telegraph: Telegraph) -> bool:
	var clash_kind: int = player.current_weapon_clash_type()
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
	var toward_enemy: Vector2 = enemies.positions[enemy_id] - player.position
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
	_record_weapon_clash_audio(perfect, skill_clash)
	if stance_broken:
		_on_named_stance_broken(target_name, at)
	elif perfect:
		hud.set_message("完美格挡：%s 架势重创" % target_name)

func _finalize_light_enemy_weapon_clash(at: Vector2) -> void:
	player.on_light_weapon_clash_success()
	renderer.add_weapon_clash(at, false, false, true)
	hitstop_remaining = maxf(hitstop_remaining, 0.045)

func _start_clash_slowmotion(perfect: bool, skill_clash: bool) -> void:
	var duration := EMPHATIC_CLASH_SLOW_DURATION if perfect or skill_clash else NORMAL_CLASH_SLOW_DURATION
	clash_slow_remaining = maxf(clash_slow_remaining, duration)

func _record_weapon_clash_audio(perfect: bool, skill_clash: bool) -> void:
	if skill_clash:
		for action_id in ["active", "ultimate"]:
			if action_audio_hits.has(action_id):
				action_audio_hits[action_id] = true
	else:
		var action_id := "basic_%d" % player.combo_stage
		if not action_audio_hits.has(action_id) and action_audio_hits.has("drag"):
			action_id = "drag"
		if action_audio_hits.has(action_id):
			action_audio_hits[action_id] = true
	AudioService.play_weapon_clash(perfect, skill_clash)

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
	var impact_position: Vector2 = boss.position
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
	if randf() < HERO_ATTACK_SHOUT_CHANCE:
		AudioService.play_hero_attack_shout()
	if action_id == "firewheel":
		AudioService.play_hero_firewheel_loop()

func _on_player_combat_action_finished(action_id: String) -> void:
	player_action_clash_consumed = true
	player.consume_weapon_clash_window()
	if action_id == "firewheel":
		AudioService.stop_hero_firewheel_loop()
	if action_id.begins_with("basic_"):
		input_router.on_basic_action_finished()
	elif action_id == "firewheel":
		input_router.call_deferred("on_firewheel_action_finished")
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
	# Skill requests already carry an action kind. Prefer it over display labels
	# so new hero variants cannot accidentally report a false miss.
	if request.action_kind == AttackRequest.ActionKind.ACTIVE:
		return "active"
	if request.action_kind == AttackRequest.ActionKind.ULTIMATE:
		return "ultimate"
	match request.label:
		"青龙横江": return "basic_1"
		"压阵斩": return "basic_2"
		"拖刀断阵": return "basic_3"
		"拖刀斩浪", "拖刀刀浪": return "drag"
		"青龙破阵", "青龙断浪": return "active"
		"武圣刀浪", "武圣震阵", "武圣拖刀震阵": return "ultimate"
		"威震华夏·横江", "威震华夏·断岳", "威震华夏·斩将": return "ultimate"
		"扫阵横击": return "basic_1"
		"蛇矛挑阵": return "basic_2"
		"断阵横掷", "丈八跃砸": return "basic_3"
		"蛇矛掷阵·裂地·首震", "蛇矛掷阵·裂地": return "basic_4"
		"据水断桥·掀阵", "据水断桥·跃砸": return "active"
		"万夫莫开·怒喝震阵", "万夫莫开·横扫", "万夫莫开·掀阵", "万夫莫开·断阵": return "ultimate"
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
	var is_regular_movement: bool = moved and move_direction.length_squared() > 0.01 and not player.is_attacking() and (player.ultimate_time <= 0.0 or player.is_zhang_fei_ultimate_active()) and not player.is_path_dashing()
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
	if request.label in ["断阵横掷", "丈八跃砸", "据水断桥·掀阵", "据水断桥·跃砸", "万夫莫开·怒喝震阵", "万夫莫开·掀阵", "万夫莫开·断阵"]:
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

func _on_guard_requested(direction: Vector2) -> void:
	if not player.request_guard(direction):
		return
	guard_named_reward_consumed = false
	guard_perfect_telegraphs.clear()
	# Preserve the old perfect-clash timing: an attack already inside its final
	# 0.10 seconds when the button is pressed is a perfect guard.
	for telegraph in telegraphs:
		if not _is_guardable_telegraph(telegraph) or telegraph.remaining > PERFECT_WEAPON_CLASH_WINDOW:
			continue
		var origin := _telegraph_attack_origin(telegraph)
		if player.can_guard_attack(origin):
			guard_perfect_telegraphs[telegraph.get_instance_id()] = true

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
	run_defeated_count += 1
	var death_action_kind := enemies.consume_death_action_kind(enemy_id)
	if enemies.consume_duel_fodder_reward(enemy_id):
		return
	loot.drop_loot(at, experience, enemies.gold_reward(enemy_type))
	# Regular soldiers only have a 50% chance to drop ultimate energy. Elite
	# simulation enemies remain guaranteed drops through the same callback.
	if enemy_type == EnemySimulation.EnemyType.ELITE or randf() < 0.50:
		player.add_ultimate_energy(ultimate_energy)
	player.on_enemy_defeated(enemy_type, not tianji.is_resolving_damage(), death_action_kind)
	if director.is_time_over() and overtime_settlement_active and _overtime_high_enemy_count() <= 0:
		overtime_settlement_remaining = minf(overtime_settlement_remaining, OVERTIME_SETTLEMENT_DELAY)

func _on_enemy_death_collision(at: Vector2, direction: Vector2) -> void:
	renderer.add_death_collision(at, direction)

func _on_player_damaged(amount: float) -> void:
	run_damage_taken += maxf(0.0, amount)
	if amount > 0.0 and not paused and not upgrade_open and not finished:
		HapticService.player_damaged()

func _on_loot_collected(experience: int, gold: int) -> void:
	director.add_experience(experience)
	_grant_run_merit(float(gold), true)

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
				telegraph = Telegraph.fan(origin, halberd_direction, EnemySimulation.HALBERD_BRACE_MAX_DISTANCE, deg_to_rad(158.0), windup, damage * 1.25, source)
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
				telegraph = Telegraph.line(origin, target - origin, 170.0, 36.0, windup, damage * 1.12, source)
				telegraph.clash_kind = Telegraph.ClashKind.BASIC
				telegraph.clashable = true
			EnemySimulation.ATTACK_KIND_DUEL_SPEAR_THRUST:
				telegraph = Telegraph.line(origin, target - origin, 208.0, 34.0, windup, damage * 0.82, source)
				telegraph.clash_kind = Telegraph.ClashKind.BASIC
				telegraph.clashable = true
			_:
				telegraph = Telegraph.line(origin, target - origin, 140.0, 32.0, windup, damage * 0.88, source)
	elif enemy_type == EnemySimulation.EnemyType.CAVALRY:
		if attack_kind == EnemySimulation.ATTACK_KIND_CAVALRY_CHARGE:
			telegraph = Telegraph.line(origin, target - origin, EnemySimulation.CAVALRY_CHARGE_DISTANCE + 24.0, 48.0, windup, damage * 1.42, source)
			telegraph.clash_kind = Telegraph.ClashKind.ACTIVE
			telegraph.clashable = true
		else:
			telegraph = Telegraph.line(origin, target - origin, 104.0, 34.0, windup, damage * 0.82, source)
			telegraph.clash_kind = Telegraph.ClashKind.BASIC
			telegraph.clashable = true
	elif enemy_type == EnemySimulation.EnemyType.ELITE:
		telegraph = Telegraph.line(origin, target - origin, 145.0, 30.0, windup, damage, source)
	elif enemy_type == EnemySimulation.EnemyType.SHIELD:
		var shield_direction := (enemies.duel_formation_center() - origin).normalized() if attack_kind == EnemySimulation.ATTACK_KIND_DUEL_SHIELD_PUSH else ((enemies.named_formation_center() - origin).normalized() if attack_kind == EnemySimulation.ATTACK_KIND_NAMED_SHIELD_PUSH else ((enemies.iron_bucket_center_for_enemy(enemy_id) - origin).normalized() if attack_kind == EnemySimulation.ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH else (target - origin).normalized()))
		if shield_direction.length_squared() <= 0.01:
			shield_direction = Vector2.RIGHT
		var is_formation_shield_push := attack_kind in [EnemySimulation.ATTACK_KIND_DUEL_SHIELD_PUSH, EnemySimulation.ATTACK_KIND_NAMED_SHIELD_PUSH, EnemySimulation.ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH]
		telegraph = Telegraph.fan(origin, shield_direction, 82.0 if is_formation_shield_push else 72.0, deg_to_rad(78.0), windup, 1.0 if is_formation_shield_push else damage, source)
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

func _on_boss_rush_started(at: Vector2, direction: Vector2, segment: int) -> void:
	if boss.archetype == BossActor.Archetype.LV_BU:
		renderer.add_lv_bu_rush_effect(at, direction, segment)

func _on_elite_defeated(elite: EliteActor) -> void:
	_cancel_elite_telegraphs(elite.telegraph_source)
	run_defeated_count += 1
	loot.drop_loot(elite.position, 12, 60)
	player.add_ultimate_energy(12.0)
	player.on_enemy_defeated(EnemySimulation.EnemyType.ELITE, not tianji.is_resolving_damage())
	if director.is_boss_trial():
		if not tianji.is_resolving_damage():
			player.apply_boss_trial_defeat_recovery()
	hud.set_message("精英击破：%s" % elite.display_name())
	renderer.add_elite_corpse(elite)
	elites.erase(elite)
	renderer.set_elites(elites)
	hud.set_elites(elites)
	elite.call_deferred("queue_free")
	if director.is_boss_trial():
		boss_trial_advance_after_levels = true
		director.grant_levels(BOSS_TRIAL_LEVELS_PER_NAMED_DEFEAT)
	elif elites.is_empty() and not boss.active:
		enemies.clear_duel_formation()
		director.set_spawn_background_mode(false)
		_stop_duel_formation_audio()

func _add_telegraph(telegraph: Telegraph) -> void:
	# Radial Lu Bu thrusts intentionally keep all eight lanes visible at once;
	# the normal named-threat cap would otherwise discard the final three lanes.
	var is_lv_bu_cyclone := telegraph.source == "boss" and telegraph.visual_kind == "lvbu_cyclone_thrust"
	if telegraphs.size() >= (30 if is_lv_bu_cyclone else 22):
		return
	if _is_named_threat_source(telegraph.source) and _named_threat_count() >= 5 and not is_lv_bu_cyclone:
		return
	telegraphs.append(telegraph)

func _tick_telegraphs(delta: float) -> void:
	var resolved_hit_groups: Dictionary = {}
	for index in range(telegraphs.size() - 1, -1, -1):
		var telegraph := telegraphs[index]
		if telegraph.source_enemy_id >= 0 and not enemies.is_active(telegraph.source_enemy_id):
			telegraphs.remove_at(index)
			continue
		telegraph.remaining -= delta
		if telegraph.remaining <= 0.0:
			var hit_group: String = telegraph.hit_group
			if hit_group != "" and resolved_hit_groups.has(hit_group):
				telegraphs.remove_at(index)
				continue
			if _try_resolve_guard(telegraph):
				if hit_group != "":
					resolved_hit_groups[hit_group] = true
				telegraphs.remove_at(index)
				continue
			if _try_resolve_late_weapon_clash(telegraph):
				if hit_group != "":
					resolved_hit_groups[hit_group] = true
				telegraphs.remove_at(index)
				continue
			if _telegraph_hits_player(telegraph):
				if hit_group != "":
					resolved_hit_groups[hit_group] = true
				if _try_block_projectile_telegraph(telegraph):
					hud.set_message(player.projectile_guard_block_message())
					telegraphs.remove_at(index)
					continue
				# Lu Bu's skyfall uses geometric contact as its hit condition. A
				# shield or invulnerability frame may prevent HP loss, but it does
				# not turn a landing inside the target area into a miss.
				if telegraph.source == "boss" and telegraph.threat_kind == Telegraph.ThreatKind.UNBLOCKABLE and boss.active:
					boss.record_unblockable_hit_player()
				var shield_charges_before: int = player.health_component.shield_charges if player.health_component != null else 0
				var damage_taken: float = player.receive_damage(telegraph.damage, telegraph.source, _telegraph_attack_origin(telegraph))
				if damage_taken > 0.0 and telegraph.movement_slow_duration > 0.0 and telegraph.movement_slow_multiplier < 1.0:
					player.apply_movement_slow(telegraph.movement_slow_multiplier, telegraph.movement_slow_duration)
				if telegraph.source in [EnemySimulation.ATTACK_KIND_DUEL_SHIELD_PUSH, EnemySimulation.ATTACK_KIND_NAMED_SHIELD_PUSH, EnemySimulation.ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH] and telegraph.source_enemy_id >= 0 and enemies.is_active(telegraph.source_enemy_id):
					var push_center := enemies.duel_formation_center() if telegraph.source == EnemySimulation.ATTACK_KIND_DUEL_SHIELD_PUSH else (enemies.named_formation_center() if telegraph.source == EnemySimulation.ATTACK_KIND_NAMED_SHIELD_PUSH else enemies.iron_bucket_center_for_enemy(telegraph.source_enemy_id))
					var push_direction := (player.position - push_center).normalized() if telegraph.source == EnemySimulation.ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH else (push_center - player.position).normalized()
					player.apply_duel_push(push_direction, 72.0 * player.incoming_knockback_multiplier(_telegraph_attack_origin(telegraph)))
				if player_death_cinematic_active:
					telegraphs.clear()
					return
				if telegraph.source == "boss":
					if damage_taken > 0.0:
						hud.set_message("%s命中：-%d 生命" % [boss.display_name(), int(damage_taken)])
					elif player.health_component != null and player.health_component.shield_charges < shield_charges_before:
						hud.set_message("护体抵挡了%s的攻击" % boss.display_name())
					else:
						hud.set_message("%s的攻击未造成伤害" % boss.display_name())
			telegraphs.remove_at(index)

func _tick_named_enemies(delta: float) -> void:
	# Keep one named enemy as the active mover so elites and the boss do not all
	# strafe at once when their recoveries line up.
	var tactical_reposition_slot_taken := false
	for elite in elites:
		if is_instance_valid(elite) and elite.is_tactically_repositioning():
			tactical_reposition_slot_taken = true
			break
	if boss.active or boss.is_dying():
		if boss.active:
			boss.set_tactical_reposition_allowed(not tactical_reposition_slot_taken)
			boss.set_high_risk_skill_allowed(_can_begin_named_high_risk_action(boss))
			boss.set_navigation_waypoint(_named_navigation_waypoint(boss.position, player.position, 26.0, boss.get_instance_id()))
		boss.tick(delta, player.position, player.is_attacking())
		if boss.active:
			boss.position = _clamp_named_spawn(boss.position)
			if enemies.is_duel_formation_active():
				boss.position = enemies.constrain_named_to_duel_formation(boss.position, 40.0)
		tactical_reposition_slot_taken = tactical_reposition_slot_taken or boss.is_tactically_repositioning()
	for elite in elites:
		if not is_instance_valid(elite):
			continue
		if elite.active:
			elite.set_tactical_reposition_allowed(not tactical_reposition_slot_taken)
			elite.set_high_risk_skill_allowed(_can_begin_named_high_risk_action(elite))
			elite.set_navigation_waypoint(_named_navigation_waypoint(elite.position, player.position, 22.0, elite.get_instance_id()))
		elite.tick(delta, player.position, player.is_attacking())
		if elite.active:
			# Elite dashes and stance-break knockback update their position internally,
			# so clamp after their tick as well as at their spawn point.
			elite.position = _clamp_named_spawn(elite.position)
			if enemies.is_duel_formation_active():
				elite.position = enemies.constrain_named_to_duel_formation(elite.position, 32.0)
		tactical_reposition_slot_taken = tactical_reposition_slot_taken or elite.is_tactically_repositioning()

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
	if source.begins_with("duel_spear"):
		return "spear"
	if source.begins_with("duel_shield"):
		return "frontline"
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

func _telegraph_attack_origin(telegraph: Telegraph) -> Vector2:
	if telegraph.source_enemy_id >= 0 and enemies.is_active(telegraph.source_enemy_id):
		return enemies.positions[telegraph.source_enemy_id]
	if telegraph.source == "boss" and boss.active:
		return boss.position
	if telegraph.source.begins_with("elite:"):
		var elite := _elite_for_telegraph_source(telegraph.source)
		if elite != null and elite.active:
			return elite.position
	return Vector2.ZERO

func _try_block_projectile_telegraph(telegraph: Telegraph) -> bool:
	if telegraph.source_enemy_id < 0 or not enemies.is_active(telegraph.source_enemy_id):
		return false
	var enemy_type := enemies.get_type(telegraph.source_enemy_id)
	if enemy_type != EnemySimulation.EnemyType.ARCHER and enemy_type != EnemySimulation.EnemyType.CROSSBOW:
		return false
	if not player.try_block_frontal_projectile(enemies.positions[telegraph.source_enemy_id]):
		return false
	var block_direction: Vector2 = (enemies.positions[telegraph.source_enemy_id] - player.position).normalized()
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

func _try_resolve_guard(telegraph: Telegraph) -> bool:
	if not player.is_guard_active() or not _is_guardable_telegraph(telegraph):
		return false
	var attack_origin := _telegraph_attack_origin(telegraph)
	if not player.can_guard_attack(attack_origin) or not _telegraph_hits_player(telegraph):
		return false
	var perfect := guard_perfect_telegraphs.has(telegraph.get_instance_id())
	var is_named := telegraph.source == "boss" or telegraph.source.begins_with("elite:")
	if is_named and not guard_named_reward_consumed:
		guard_named_reward_consumed = true
		if telegraph.source == "boss" and boss.active:
			var boss_broken := boss.add_stance_damage(_clash_stance_damage(perfect, Telegraph.ClashKind.BASIC), perfect)
			_finalize_guard_named_block((player.position + boss.position) * 0.5, perfect, boss.display_name(), boss_broken, boss)
		elif telegraph.source.begins_with("elite:"):
			var elite := _elite_for_telegraph_source(telegraph.source)
			if elite != null and elite.active:
				var elite_broken := elite.add_stance_damage(_clash_stance_damage(perfect, Telegraph.ClashKind.BASIC), perfect)
				_finalize_guard_named_block((player.position + elite.position) * 0.5, perfect, elite.display_name(), elite_broken, elite)
			else:
				_finalize_guard_minor(telegraph)
		else:
			_finalize_guard_minor(telegraph)
	else:
		_finalize_guard_minor(telegraph)
	if telegraph.source_enemy_id >= 0 and enemies.is_active(telegraph.source_enemy_id):
		var enemy_type := enemies.get_type(telegraph.source_enemy_id)
		if enemy_type == EnemySimulation.EnemyType.CAVALRY:
			enemies.resolve_cavalry_clash(telegraph.source_enemy_id, player.guard_direction)
		elif enemy_type == EnemySimulation.EnemyType.ARCHER:
			renderer.cancel_next_archer_projectile(telegraph.source_enemy_id)
		elif enemy_type == EnemySimulation.EnemyType.CROSSBOW:
			renderer.cancel_next_crossbow_bolt(telegraph.source_enemy_id)
	return true

func _is_guardable_telegraph(telegraph: Telegraph) -> bool:
	if telegraph.threat_kind == Telegraph.ThreatKind.BASIC:
		return true
	# Arrow and bolt volleys are active-pattern telegraphs, but the projectiles
	# themselves remain guardable for the whole 0.3 second guard window.
	if telegraph.threat_kind != Telegraph.ThreatKind.ACTIVE:
		return false
	if telegraph.source_enemy_id < 0 or not enemies.is_active(telegraph.source_enemy_id):
		return false
	var enemy_type := enemies.get_type(telegraph.source_enemy_id)
	if enemy_type == EnemySimulation.EnemyType.CAVALRY and telegraph.source == EnemySimulation.ATTACK_KIND_CAVALRY_CHARGE:
		return true
	return enemy_type == EnemySimulation.EnemyType.ARCHER or enemy_type == EnemySimulation.EnemyType.CROSSBOW

func _finalize_guard_named_block(at: Vector2, perfect: bool, target_name: String, stance_broken: bool, named_target: Node) -> void:
	player.on_weapon_clash_success(perfect, false)
	player.refresh_guard_cooldown_after_named_block()
	if not perfect and not stance_broken and is_instance_valid(named_target) and named_target.has_method("grant_counterattack"):
		named_target.call("grant_counterattack")
	renderer.add_weapon_clash(at, perfect, false)
	var contact_direction: Vector2 = (named_target.position - player.position).normalized() if is_instance_valid(named_target) else player.guard_direction
	if contact_direction.length_squared() <= 0.01:
		contact_direction = player.guard_direction
	renderer.add_guard_feedback(at, contact_direction, perfect)
	if named_target is BossActor:
		var boss_reaction_distance := BossActor.PERFECT_GUARD_REACTION_DISTANCE if perfect else BossActor.GUARD_REACTION_DISTANCE
		var boss_start: Vector2 = named_target.position
		var boss_destination: Vector2 = _clamp_named_spawn(boss_start + contact_direction * boss_reaction_distance)
		if enemies.is_duel_formation_active():
			boss_destination = enemies.constrain_named_to_duel_formation(boss_destination, 40.0)
		named_target.apply_guard_reaction_knockback(contact_direction, perfect, boss_start.distance_to(boss_destination))
		named_target.position = boss_destination
		_interrupt_boss_action_for_knockback()
	elif named_target is EliteActor:
		var elite_reaction_distance := EliteActor.PERFECT_GUARD_REACTION_DISTANCE if perfect else EliteActor.GUARD_REACTION_DISTANCE
		var elite_start: Vector2 = named_target.position
		var elite_destination: Vector2 = _clamp_named_spawn(elite_start + contact_direction * elite_reaction_distance)
		if enemies.is_duel_formation_active():
			elite_destination = enemies.constrain_named_to_duel_formation(elite_destination, 32.0)
		named_target.apply_guard_reaction_knockback(contact_direction, perfect, elite_start.distance_to(elite_destination))
		named_target.position = elite_destination
		_interrupt_elite_action_for_knockback(named_target)
	_focus_battle_camera_after_guard(perfect)
	hitstop_remaining = maxf(hitstop_remaining, 0.17 if perfect else 0.12)
	_start_clash_slowmotion(perfect, false)
	_record_weapon_clash_audio(perfect, false)
	if stance_broken:
		_on_named_stance_broken(target_name, at)
	else:
		hud.set_message("完美格挡：%s 架势重创" % target_name if perfect else "格挡反制：%s" % target_name)

func _finalize_guard_minor(telegraph: Telegraph) -> void:
	var origin := _telegraph_attack_origin(telegraph)
	var direction := (origin - player.position).normalized()
	if direction.length_squared() <= 0.01:
		direction = player.guard_direction
	renderer.add_weapon_clash(player.position + direction * 34.0, false, false, true)

func _on_level_up(level: int) -> void:
	player.apply_level_up_benefits()
	if upgrade_open:
		queued_level_ups.append(level)
		return
	_open_level_up(level)

func _open_level_up(level: int) -> void:
	upgrade_open = true
	AudioService.set_tianji_sounds_paused(true)
	current_upgrade_level = level
	var option_count := _upgrade_option_count_for_current_run()
	current_upgrade_selection_limit = _upgrade_selection_limit_for_current_run()
	current_upgrade_selection_count = 0
	upgrades.begin_draft()
	current_upgrade_options = upgrades.draft(level, option_count)
	current_upgrade_selection_limit = mini(current_upgrade_selection_limit, maxi(1, current_upgrade_options.size()))
	input_router.set_input_enabled(false)
	hud.set_message("等级提升：Lv.%d" % level)
	hud.show_upgrades(current_upgrade_options, upgrades, current_upgrade_selection_limit)

func _open_run_strategy_choice() -> void:
	if finished or opening_strategy_selected:
		return
	upgrade_open = true
	input_router.set_input_enabled(false)
	hud.set_message("出战筹谋")
	hud.show_run_strategy_choice()

func _on_run_strategy_selected(strategy_id: String) -> void:
	if opening_strategy_selected:
		return
	opening_strategy_selected = true
	run_strategy_id = strategy_id
	upgrades.set_draft_tendency(run_strategy_id)
	if director.is_boss_trial():
		_start_boss_trial()
		return
	upgrade_open = false
	input_router.set_input_enabled(true)
	hud.set_message("本局策略：%s" % ("战法" if run_strategy_id == UpgradeSystem.DRAFT_TENDENCY_TALENT else ("天机" if run_strategy_id == UpgradeSystem.DRAFT_TENDENCY_TIANJI else "均衡")))

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
	AudioService.set_tianji_sounds_paused(true)
	current_upgrade_level = director.level
	var option_count := _upgrade_option_count_for_current_run()
	current_upgrade_selection_limit = _upgrade_selection_limit_for_current_run()
	current_upgrade_selection_count = 0
	upgrades.begin_draft()
	current_upgrade_options = upgrades.draft(current_upgrade_level, option_count)
	current_upgrade_selection_limit = mini(current_upgrade_selection_limit, maxi(1, current_upgrade_options.size()))
	input_router.set_input_enabled(false)
	var stage_label := "精英击破：选择强化" if boss_trial_advance_after_upgrade else "战前整备：%d选%d" % [current_upgrade_options.size(), current_upgrade_selection_limit]
	hud.set_message("%s（剩余 %d）" % [stage_label, boss_trial_upgrades_remaining])
	hud.show_upgrades(current_upgrade_options, upgrades, current_upgrade_selection_limit)

func _on_upgrade_refresh_requested() -> void:
	if not upgrade_open or current_upgrade_selection_count > 0:
		return
	if upgrade_refreshes_remaining > 0:
		upgrade_refreshes_remaining -= 1
		hud.set_upgrade_refreshes_remaining(upgrade_refreshes_remaining)
		_refresh_upgrade_choices("已刷新%d选%d（剩余 %d 次）" % [_upgrade_option_count_for_current_run(), _upgrade_selection_limit_for_current_run(), upgrade_refreshes_remaining])

func _refresh_upgrade_choices(message: String = "") -> void:
	if not message.is_empty():
		hud.set_message(message)
	var refreshed_options := upgrades.draft(current_upgrade_level, _upgrade_option_count_for_current_run())
	var attempts := 0
	while _same_upgrade_choices(refreshed_options, current_upgrade_options) and attempts < 6:
		refreshed_options = upgrades.draft(current_upgrade_level, upgrades.upgrade_option_count())
		attempts += 1
	current_upgrade_options = refreshed_options
	current_upgrade_selection_limit = mini(current_upgrade_selection_limit, maxi(1, current_upgrade_options.size()))
	hud.show_upgrades(current_upgrade_options, upgrades, current_upgrade_selection_limit)

func _upgrade_option_count_for_current_run() -> int:
	return BOSS_TRIAL_UPGRADE_OPTION_COUNT if director.is_boss_trial() else upgrades.upgrade_option_count()

func _upgrade_selection_limit_for_current_run() -> int:
	return BOSS_TRIAL_UPGRADE_SELECTION_LIMIT if director.is_boss_trial() else upgrades.upgrade_selection_limit()

func _same_upgrade_choices(first: Array[String], second: Array[String]) -> bool:
	if first.size() != second.size():
		return false
	for upgrade_id in first:
		if not second.has(upgrade_id):
			return false
	return true

func _on_upgrade_selected(upgrade_id: String) -> void:
	if not current_upgrade_options.has(upgrade_id):
		return
	current_upgrade_options.erase(upgrade_id)
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
	current_upgrade_selection_count += 1
	hud.set_message("已获得：%s" % upgrades.title_for(upgrade_id))
	if current_upgrade_selection_count < current_upgrade_selection_limit:
		hud.set_message("已获得：%s · 继续选择 %d 项" % [upgrades.title_for(upgrade_id), current_upgrade_selection_limit - current_upgrade_selection_count])
		return
	current_upgrade_options.clear()
	if boss_trial_upgrades_remaining > 0:
		boss_trial_upgrades_remaining -= 1
		if boss_trial_upgrades_remaining > 0:
			_open_boss_trial_upgrade()
			return
		var should_advance := boss_trial_advance_after_upgrade
		boss_trial_advance_after_upgrade = false
		upgrade_open = false
		AudioService.set_tianji_sounds_paused(false)
		input_router.set_input_enabled(true)
		if should_advance:
			director.advance_boss_trial_after_named_defeat()
		else:
			director.begin_boss_trial()
		return
	if not queued_level_ups.is_empty():
		_open_level_up(queued_level_ups.pop_front())
		return
	var should_advance_trial := boss_trial_advance_after_levels
	boss_trial_advance_after_levels = false
	upgrade_open = false
	AudioService.set_tianji_sounds_paused(false)
	input_router.set_input_enabled(true)
	if should_advance_trial:
		director.advance_boss_trial_after_named_defeat()

func _on_pause_requested() -> void:
	if paused or finished or upgrade_open or player_death_cinematic_active or ultimate_cutin.is_playing():
		return
	paused = true
	AudioService.set_hero_firewheel_loop_paused(true)
	AudioService.set_tianji_sounds_paused(true)
	AudioService.set_enemy_duel_cheers_paused(true)
	AudioService.set_battle_voiceovers_paused(true)
	input_router.set_input_enabled(false)
	hud.show_pause()

func _on_resume_requested() -> void:
	if not paused:
		return
	paused = false
	AudioService.set_hero_firewheel_loop_paused(false)
	AudioService.set_tianji_sounds_paused(false)
	AudioService.set_enemy_duel_cheers_paused(false)
	AudioService.set_battle_voiceovers_paused(false)
	hud.hide_pause()
	input_router.set_input_enabled(true)

func _on_combo_setting_changed(value: bool) -> void:
	input_router.combo_enabled = value
	SaveService.set_setting("auto_combo_enabled", value)

func _on_home_requested() -> void:
	SceneRouter.go_home()

func _on_retreat_requested() -> void:
	if not paused or finished:
		return
	paused = false
	input_router.set_input_enabled(false)
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_battle_voiceovers()
	_stop_duel_formation_audio()
	telegraphs.clear()
	director.set_spawn_suppressed(true)
	enemies.clear_duel_formation()
	enemies.freeze_for_cinematic()
	for elite in elites:
		if is_instance_valid(elite):
			elite.freeze_for_cinematic()
	boss.freeze_for_cinematic()
	var retreat_stats := {
		"defeated": run_defeated_count,
		"damage_taken": run_damage_taken,
		"combat_time": director.elapsed if director != null else 0.0,
		"military_merit": run_gold,
		"voluntary_end": true,
	}
	_complete_run(false, "鸣金收兵，本局军功已结算", retreat_stats)

func _on_player_died() -> void:
	if finished or player_death_cinematic_active:
		return
	var hero_name := HERO_CATALOG.display_name_for(player.hero_id)
	pending_defeat_message = "%s力竭，名将斗阵失败" % hero_name if director.is_boss_trial() else "%s力竭，战局失败" % hero_name
	player_death_cinematic_active = true
	input_router.set_input_enabled(false)
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_battle_voiceovers()
	_stop_duel_formation_audio()
	if ultimate_cutin.is_playing():
		ultimate_cutin.cancel()
	telegraphs.clear()
	enemies.freeze_for_cinematic()
	for elite in elites:
		if is_instance_valid(elite):
			elite.freeze_for_cinematic()
	boss.freeze_for_cinematic()
	renderer.begin_player_death_cinematic(player.hero_id)

func _on_revive_requested() -> void:
	if not revive_prompt_active or revive_count >= MAX_REVIVES_PER_RUN or AdService.is_showing_rewarded_video():
		return
	hud.set_message("正在加载广告…")
	AdService.show_rewarded_video(AdService.PLACEMENT_REVIVE)

func _on_revive_declined() -> void:
	if not revive_prompt_active:
		return
	revive_prompt_active = false
	hud.hide_revive_prompt()
	_finish_run(false, pending_defeat_message)

func _on_result_reward_requested() -> void:
	if not finished or result_double_claimed or run_gold <= 0 or AdService.is_showing_rewarded_video():
		return
	hud.set_message("正在加载广告…")
	AdService.show_rewarded_video(AdService.PLACEMENT_RESULT_DOUBLE)

func _on_rewarded_video_completed(placement: String, rewarded: bool, message: String) -> void:
	if placement == AdService.PLACEMENT_UPGRADE_REFRESH:
		if rewarded and upgrade_open and current_upgrade_selection_count == 0 and upgrade_ad_refreshes_remaining > 0:
			upgrade_ad_refreshes_remaining -= 1
			hud.set_upgrade_ad_refreshes_remaining(upgrade_ad_refreshes_remaining)
			_refresh_upgrade_choices("广告刷新成功（剩余 %d 次）" % upgrade_ad_refreshes_remaining)
		elif not rewarded and upgrade_open:
			hud.set_message(message if not message.is_empty() else "广告未完成，未刷新选项")
		return
	if placement == AdService.PLACEMENT_REVIVE:
		if rewarded and revive_prompt_active and revive_count < MAX_REVIVES_PER_RUN:
			revive_count += 1
			revive_prompt_active = false
			hud.hide_revive_prompt()
			renderer.end_player_death_cinematic()
			player.revive_from_rewarded_ad()
			enemies.unfreeze_for_cinematic()
			input_router.set_input_enabled(true)
			hud.set_message("援军护住阵脚，继续破阵")
		elif not rewarded and revive_prompt_active:
			hud.set_message(message if not message.is_empty() else "广告未完成，可选择放弃复活")
		return
	if placement == AdService.PLACEMENT_RESULT_DOUBLE:
		if rewarded and finished and not result_double_claimed and run_gold > 0:
			result_double_claimed = true
			var bonus := run_gold
			SaveService.grant_military_merit(bonus)
			hud.set_result_rewarded(run_gold + bonus)
			hud.set_message("军功已翻倍")
		elif not rewarded and finished:
			hud.set_message(message if not message.is_empty() else "广告未完成，保持原结算")

func _on_boss_defeated() -> void:
	var defeated_boss_name := boss.display_name()
	_cancel_boss_telegraphs()
	enemies.clear_duel_formation()
	director.set_spawn_background_mode(false)
	_stop_duel_formation_audio()
	run_defeated_count += 1
	var boss_merit := BOSS_TRIAL_BOSS_DEFEAT_MERIT if director.is_boss_trial() else BOSS_DEFEAT_MERIT
	_grant_run_merit(boss_merit)
	player.apply_military_boss_defeat_reward(not tianji.is_resolving_damage())
	if director.is_boss_trial():
		if not tianji.is_resolving_damage():
			player.apply_boss_trial_defeat_recovery()
		# The first two trial rounds grant five full levels and their associated drafts.
		if director.boss_trial_stage < RunDirector.BOSS_TRIAL_FINAL_STAGE:
			boss_trial_advance_after_levels = true
			director.grant_levels(BOSS_TRIAL_LEVELS_PER_NAMED_DEFEAT)
			return
	if director.is_time_over():
		_finish_run(true, director.story_completion_message() if run_mode == "story" else "无尽试炼完成，军功已结算")
		return
	if director.advance_boss_after_defeat():
		return
	if director.is_boss_trial():
		_finish_run(true, "%s败退，名将斗阵完成！" % defeated_boss_name)
		return
	var battlefield_result := "%s败退，无尽战场暂告一段落！" % defeated_boss_name
	if director.is_bowangpo():
		battlefield_result = "%s败退，博望坡火谷突围成功！" % defeated_boss_name
	elif run_mode == "story":
		battlefield_result = "%s败退，%s" % [defeated_boss_name, director.story_completion_message()]
	_finish_run(true, battlefield_result)

func _tick_overtime_settlement(delta: float) -> void:
	if finished:
		return
	director.set_spawn_suppressed(true)
	if not overtime_settlement_active:
		if _overtime_high_enemy_count() <= 0:
			if run_mode == "story":
				_finish_run(true, director.story_completion_message())
			else:
				_finish_run(true, "无尽试炼完成，军功已结算")
			return
		overtime_settlement_active = true
		overtime_settlement_remaining = -1.0
		hud.set_message("战场时间结束，清理完高级敌人后结算")
		return
	if overtime_settlement_remaining < 0.0:
		if _overtime_high_enemy_count() > 0:
			return
		overtime_settlement_remaining = OVERTIME_SETTLEMENT_DELAY
		hud.set_message("高级敌人已清剿，战场将在 %.0f 秒后结算" % OVERTIME_SETTLEMENT_DELAY)
		return
	overtime_settlement_remaining = maxf(0.0, overtime_settlement_remaining - delta)
	if overtime_settlement_remaining > 0.0:
		return
	overtime_settlement_active = false
	if run_mode == "story":
		_finish_run(true, director.story_completion_message())
	else:
		_finish_run(true, "无尽试炼完成，军功已结算")

func _overtime_high_enemy_count() -> int:
	var count := enemies.count_active_type(EnemySimulation.EnemyType.CAVALRY)
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			count += 1
	if boss.active or boss.is_dying():
		count += 1
	return count


func _is_named_threat_source(source: String) -> bool:
	return source == "boss" or source.begins_with("elite:")

func _named_threat_count() -> int:
	var count := 0
	for telegraph in telegraphs:
		if _is_named_threat_source(telegraph.source):
			count += 1
	return count

func _on_restart_requested() -> void:
	if restart_settlement_started:
		return
	restart_settlement_started = true
	# A restart from an active battle is an early withdrawal, not a chapter
	# completion. Save only the merit already earned, then rebuild the run.
	if not finished:
		finished = true
		paused = false
		input_router.set_input_enabled(false)
		AudioService.stop_hero_firewheel_loop()
		AudioService.stop_all_tianji_sounds()
		AudioService.stop_battle_voiceovers()
		_stop_duel_formation_audio()
		SaveService.apply_result({"victory": false, "military_merit": run_gold})
	SceneRouter.restart_run()

func _finish_run(victory: bool, message: String) -> void:
	if finished or victory_cinematic_active:
		return
	if victory:
		_begin_victory_cinematic(message)
		return
	_complete_run(false, message)

func _begin_victory_cinematic(message: String) -> void:
	victory_cinematic_active = true
	player.force_idle_state()
	victory_phase = "hold"
	victory_phase_remaining = VICTORY_CINEMATIC_HOLD_DURATION
	victory_message = message
	victory_salvo_index = 0
	_grant_run_merit(_clear_military_merit_reward(true))
	victory_result_stats = {
		"defeated": run_defeated_count,
		"damage_taken": run_damage_taken,
		"combat_time": director.elapsed if director != null else 0.0,
		"military_merit": run_gold,
	}
	input_router.set_input_enabled(false)
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_battle_voiceovers()
	_stop_duel_formation_audio()
	if ultimate_cutin.is_playing():
		ultimate_cutin.cancel()
	telegraphs.clear()
	director.set_spawn_suppressed(true)
	enemies.clear_duel_formation()
	enemies.freeze_for_cinematic()
	for elite in elites:
		if is_instance_valid(elite):
			elite.freeze_for_cinematic()
	boss.freeze_for_cinematic()
	hud.set_message("援军抵达，战局已定")
	hud.modulate = Color.WHITE

func _tick_victory_cinematic(delta: float) -> void:
	renderer.tick_visuals(delta)
	enemies.tick_cinematic_deaths(delta)
	if victory_phase == "hold":
		victory_phase_remaining = maxf(0.0, victory_phase_remaining - delta)
		hud.modulate = Color(1.0, 1.0, 1.0, victory_phase_remaining / VICTORY_CINEMATIC_HOLD_DURATION)
		if victory_phase_remaining <= 0.0:
			hud.modulate = Color(1.0, 1.0, 1.0, 0.0)
			_begin_victory_salvo()
		return
	if victory_phase == "salvo":
		victory_phase_remaining = maxf(0.0, victory_phase_remaining - delta)
		if victory_phase_remaining <= 0.0:
			if victory_salvo_index < VICTORY_CINEMATIC_SALVO_COUNT:
				_begin_victory_salvo()
			else:
				victory_phase = "final_hold"
				victory_phase_remaining = VICTORY_CINEMATIC_FINAL_HOLD_DURATION
		return
	if victory_phase == "final_hold":
		victory_phase_remaining = maxf(0.0, victory_phase_remaining - delta)
		if victory_phase_remaining <= 0.0:
			victory_cinematic_active = false
			hud.modulate = Color.WHITE
			_complete_run(true, victory_message, victory_result_stats)

func _begin_victory_salvo() -> void:
	victory_salvo_index += 1
	renderer.add_victory_arrow_salvo()
	var remaining_salvos := VICTORY_CINEMATIC_SALVO_COUNT - victory_salvo_index + 1
	var enemies_to_clear := int(ceili(float(enemies.active_count) / float(maxi(1, remaining_salvos))))
	enemies.defeat_for_victory_cinematic(enemies_to_clear)
	if victory_salvo_index == VICTORY_CINEMATIC_SALVO_COUNT:
		_clear_elites_for_victory_cinematic()
	victory_phase = "salvo"
	victory_phase_remaining = VICTORY_CINEMATIC_SALVO_INTERVAL

func _clear_elites_for_victory_cinematic() -> void:
	for elite in elites:
		if not is_instance_valid(elite):
			continue
		_cancel_elite_telegraphs(elite.telegraph_source)
		renderer.add_elite_corpse(elite)
		elite.call_deferred("queue_free")
	elites.clear()
	renderer.set_elites(elites)
	hud.set_elites(elites)

func _complete_run(victory: bool, message: String, stats: Dictionary = {}) -> void:
	if finished:
		return
	finished = true
	result_double_claimed = false
	AudioService.stop_hero_firewheel_loop()
	AudioService.stop_all_tianji_sounds()
	AudioService.stop_battle_voiceovers()
	_stop_duel_formation_audio()
	AudioService.stop_battle_bgm()
	input_router.set_input_enabled(false)
	hud.set_message(message)
	hud.show_result(victory, message, stats)
	if not victory:
		_grant_run_merit(_clear_military_merit_reward(false))
	var result := {"victory": victory, "military_merit": run_gold}
	if victory and director != null and director.is_boss_trial():
		result["completed_boss_trial"] = BOSS_TRIAL_ID
	SceneRouter.finish_run(result)

func _stop_duel_formation_audio() -> void:
	duel_formation_was_sealed = false
	hud.end_duel_hints()
	AudioService.stop_enemy_duel_cheers()

func _run_merit_multiplier() -> float:
	return 1.0

func _grant_run_merit(base_amount: float, is_loot: bool = false) -> void:
	if base_amount <= 0.0:
		return
	var multiplier := _run_merit_multiplier()
	if is_loot:
		multiplier *= player.military_gold_multiplier
	run_merit_fraction += base_amount * multiplier
	var updated_merit := int(floor(run_merit_fraction))
	if updated_merit == run_gold:
		return
	run_gold = updated_merit
	hud.set_run_gold(run_gold)

func _clear_military_merit_reward(victory: bool) -> float:
	if not victory:
		return 0.0
	if director != null and director.is_boss_trial():
		return 0.0 if SaveService.has_completed_boss_trial(BOSS_TRIAL_ID) else BOSS_TRIAL_FIRST_CLEAR_MERIT
	if run_mode == "endless":
		return 0.0
	var chapter := _visible_story_chapter_index(SceneRouter.active_story_chapter)
	return STORY_CLEAR_MERIT[chapter - 1]

func _visible_story_chapter_index(internal_chapter: int) -> int:
	match internal_chapter:
		1:
			return 1
		3:
			return 2
		4:
			return 3
		5:
			return 3
		_:
			return clampi(internal_chapter, 1, STORY_CLEAR_MERIT.size())

func _tick_endless_milestones() -> void:
	if run_mode != "endless" or director == null:
		return
	while endless_milestone_index < ENDLESS_MILESTONE_TIMES.size() and director.elapsed >= ENDLESS_MILESTONE_TIMES[endless_milestone_index]:
		var reward: float = float(ENDLESS_MILESTONE_REWARDS[endless_milestone_index])
		_grant_run_merit(reward)
		hud.set_message("无尽里程碑：军功 +%d" % int(reward))
		endless_milestone_index += 1
