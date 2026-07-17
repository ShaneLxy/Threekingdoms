class_name RunScene
extends Node2D

const WORLD_BOUNDS := Rect2(0, 0, 2560, 1440)
const CAMERA_LOOK_AHEAD := 68.0
const ELITE_ACTOR_SCENE := preload("res://scenes/actors/elite_actor.tscn")

@onready var renderer: BattleRenderer = $BattleRenderer
@onready var player: PlayerActor = $Player
@onready var battle_camera: Camera2D = $Player/BattleCamera
@onready var boss: BossActor = $Boss
@onready var enemies: EnemySimulation = $EnemySimulation
@onready var combat: CombatSystem = $CombatSystem
@onready var upgrades: UpgradeSystem = $UpgradeSystem
@onready var director: RunDirector = $RunDirector
@onready var loot = $LootSystem
@onready var input_router: InputRouter = $InputRouter
@onready var hud: BattleHud = $HudLayer/BattleHud

var telegraphs: Array[Telegraph] = []
var elites: Array[EliteActor] = []
var upgrade_open := false
var finished := false
var paused := false
var hitstop_remaining := 0.0
var run_gold := 0
var queued_level_ups: Array[int] = []
var run_mode := "story"

func _ready() -> void:
	var profile := SaveService.load_profile()
	player.configure_hero(SaveService.equipped_hero_id())
	enemies.reset(WORLD_BOUNDS)
	loot.reset()
	player.reset_for_run(WORLD_BOUNDS)
	player.apply_account_progress(profile)
	run_mode = SceneRouter.active_mode
	_configure_battle_camera()
	director.reset(WORLD_BOUNDS, run_mode)
	upgrades.seed_with(20260712)
	renderer.configure(WORLD_BOUNDS, enemies, player, boss, telegraphs, loot, elites)
	hud.configure(player, boss, director, elites)
	input_router.configure(player, hud)
	player.attack_requested.connect(_on_player_attack)
	player.ultimate_ready.connect(_on_ultimate_ready)
	player.ultimate_started.connect(_on_ultimate_started)
	player.died.connect(_on_player_died)
	enemies.enemy_died.connect(_on_enemy_died)
	loot.collected.connect(_on_loot_collected)
	enemies.enemy_attack_requested.connect(_on_enemy_attack)
	enemies.enemy_attack_cancelled.connect(_on_enemy_attack_cancelled)
	enemies.enemy_death_collision.connect(_on_enemy_death_collision)
	director.spawn_requested.connect(_on_spawn_requested)
	director.elite_requested.connect(_on_elite_requested)
	director.boss_requested.connect(_on_boss_requested)
	director.level_up.connect(_on_level_up)
	director.stage_changed.connect(hud.set_message)
	boss.telegraph_requested.connect(_add_telegraph)
	boss.summon_requested.connect(_on_boss_summon)
	boss.phase_changed.connect(_on_boss_phase)
	boss.defeated.connect(_on_boss_defeated)
	hud.upgrade_selected.connect(_on_upgrade_selected)
	hud.restart_requested.connect(_on_restart_requested)
	hud.resume_requested.connect(_on_resume_requested)
	hud.home_requested.connect(_on_home_requested)
	input_router.basic_requested.connect(player.request_basic)
	input_router.active_requested.connect(player.request_active)
	input_router.ultimate_requested.connect(_on_ultimate_requested)
	input_router.pause_requested.connect(_on_pause_requested)

func _process(delta: float) -> void:
	if paused:
		return
	if finished or upgrade_open:
		return
	if hitstop_remaining > 0.0:
		hitstop_remaining = maxf(0.0, hitstop_remaining - delta)
		renderer.queue_redraw()
		return
	renderer.tick_visuals(delta)
	player.tick(delta, input_router.movement_direction())
	_update_battle_camera(delta)
	director.tick(delta, enemies.active_count, player.position)
	enemies.tick(delta, player.position)
	loot.tick(delta, player.position)
	for elite in elites:
		elite.tick(delta, player.position)
	boss.tick(delta, player.position)
	_tick_telegraphs(delta)
	if director.is_time_over() and not boss.active:
		_finish_run(run_mode == "endless", "无尽试炼完成，军功已结算" if run_mode == "endless" else "时间耗尽，长坂坡失守")

func _on_spawn_requested(enemy_type: int, at: Vector2) -> void:
	enemies.spawn(enemy_type, at)

func _on_elite_requested(elite_id: String, at: Vector2) -> void:
	if elites.size() >= 4:
		return
	var elite := ELITE_ACTOR_SCENE.instantiate() as EliteActor
	add_child(elite)
	var archetype := EliteActor.Archetype.XIAHOU_EN if elite_id == "xiahou_en" else EliteActor.Archetype.CHUNYU_DAO
	elite.activate(archetype, at)
	elite.telegraph_requested.connect(_on_elite_telegraph)
	elite.defeated.connect(_on_elite_defeated)
	elites.append(elite)
	renderer.set_elites(elites)
	hud.set_elites(elites)
	hud.set_message("精英现身：%s·%s" % [elite.display_name(), elite.weapon_title()])

func _configure_battle_camera() -> void:
	battle_camera.limit_left = int(WORLD_BOUNDS.position.x)
	battle_camera.limit_top = int(WORLD_BOUNDS.position.y)
	battle_camera.limit_right = int(WORLD_BOUNDS.end.x)
	battle_camera.limit_bottom = int(WORLD_BOUNDS.end.y)
	battle_camera.position = Vector2.ZERO
	battle_camera.make_current()

func _update_battle_camera(delta: float) -> void:
	var target_offset := player.last_attack_direction.x * CAMERA_LOOK_AHEAD
	battle_camera.position.x = move_toward(battle_camera.position.x, target_offset, 300.0 * delta)

func _on_boss_requested(at: Vector2) -> void:
	boss.activate(at)
	hud.set_message("张郃·雁翎枪 现身")

func _on_boss_summon(phase: int) -> void:
	if enemies.get_boss_guard_count() >= 4:
		return
	var use_east := phase % 2 == 0
	var x := WORLD_BOUNDS.end.x - 28.0 if use_east else WORLD_BOUNDS.position.x + 28.0
	var base := Vector2(x, WORLD_BOUNDS.get_center().y)
	if phase == 2:
		_spawn_boss_guard(EnemySimulation.EnemyType.SHIELD, base + Vector2(0, -45))
		_spawn_boss_guard(EnemySimulation.EnemyType.ARCHER, base + Vector2(0, 10))
		_spawn_boss_guard(EnemySimulation.EnemyType.ARCHER, base + Vector2(0, 55))
	else:
		_spawn_boss_guard(EnemySimulation.EnemyType.SHIELD, base + Vector2(0, -45))
		_spawn_boss_guard(EnemySimulation.EnemyType.HALBERD, base + Vector2(0, 5))
		_spawn_boss_guard(EnemySimulation.EnemyType.GUARD, base + Vector2(0, 45))
		_spawn_boss_guard(EnemySimulation.EnemyType.GUARD, base + Vector2(0, 82))

func _on_boss_phase(phase: int) -> void:
	_cancel_boss_telegraphs()
	hud.set_message("张郃进入第 %d 阶段" % phase)

func _on_player_attack(request: AttackRequest) -> void:
	var hit_count := combat.resolve_player_attack(request, player.base_attack, player.attack_bonus, enemies)
	for elite in elites:
		var elite_id := elite.get_instance_id()
		var can_hit_elite := not request.one_hit_per_target or not request.hit_elite_ids.has(elite_id)
		if can_hit_elite and elite.active and combat.request_hits_point(request, elite.position):
			var elite_damage := CombatMath.final_damage(player.base_attack, request.multiplier, player.attack_bonus, elite.armor())
			elite.receive_damage(elite_damage)
			request.hit_elite_ids[elite_id] = true
			request.total_hits += 1
			hit_count += 1
	var can_hit_boss := not request.one_hit_per_target or not request.hit_boss
	if can_hit_boss and boss.active and combat.request_hits_point(request, boss.position):
		var boss_damage := CombatMath.final_damage(player.base_attack, request.multiplier, player.attack_bonus, 18.0)
		boss.receive_damage(boss_damage)
		request.hit_boss = true
		request.total_hits += 1
		hit_count += 1
	if request.label in ["穿阵挑刺", "破军"] and request.total_hits >= 3 and not request.dragon_triggered:
		player.trigger_dragon()
		request.dragon_triggered = true
	if request.label == "破军" and request.total_hits > 0 and not request.breakout_granted:
		player.grant_breakout_guard()
		request.breakout_granted = true
	if not request.visual_emitted:
		renderer.add_flash(request)
		if request.label == "七进七出":
			renderer.add_ultimate_dash_wave(request.origin, request.direction, request.range, player.ultimate_segment_index)
		request.visual_emitted = true
	if hit_count > 0 and not request.impact_emitted:
		var hitstop := _hitstop_duration(request, hit_count)
		hitstop_remaining = maxf(hitstop_remaining, hitstop)
		renderer.add_impact(player.position, request.label, hit_count)
		request.impact_emitted = true

func _hitstop_duration(request: AttackRequest, hit_count: int) -> float:
	var extra_hits := float(maxi(0, hit_count - 1))
	if request.is_path_attack:
		return minf(0.030, 0.014 + extra_hits * 0.003)
	if request.label == "七进七出·收势":
		return minf(0.065, 0.040 + extra_hits * 0.005)
	if request.label == "七进七出":
		return minf(0.055, 0.026 + extra_hits * 0.004)
	if request.label in ["穿阵挑刺", "破军", "破军收势"]:
		return minf(0.070, 0.040 + extra_hits * 0.006)
	return minf(0.060, 0.022 + extra_hits * 0.006)

func _on_ultimate_requested(direction: Vector2) -> void:
	if player.request_ultimate(direction):
		return
	if player.ultimate_time > 0.0:
		hud.set_message("无双正在发动")
	elif player.is_action_locked():
		hud.set_message("招式未收，暂不能发动无双")
	else:
		hud.show_ultimate_unavailable(player.ultimate_energy)

func _on_ultimate_ready() -> void:
	hud.announce_ultimate_ready()

func _on_ultimate_started() -> void:
	hud.set_message("无双·七进七出！")

func _on_enemy_died(enemy_id: int, enemy_type: int, at: Vector2, experience: int, ultimate_energy: float) -> void:
	_cancel_enemy_telegraphs(enemy_id)
	loot.drop_loot(at, experience, enemies.gold_reward(enemy_type))
	player.add_ultimate_energy(ultimate_energy)
	player.on_enemy_defeated(enemy_type)

func _on_enemy_death_collision(at: Vector2, direction: Vector2) -> void:
	renderer.add_death_collision(at, direction)

func _on_loot_collected(experience: int, gold: int) -> void:
	director.add_experience(experience)
	run_gold += gold
	hud.set_run_gold(run_gold)

func _on_enemy_attack(enemy_id: int, origin: Vector2, target: Vector2, enemy_type: int, damage: float, windup: float) -> void:
	if telegraphs.size() >= 18 or not _can_schedule_enemy_attack(enemy_type):
		enemies.cancel_attack(enemy_id)
		return
	var telegraph: Telegraph
	var source := _enemy_attack_source(enemy_type)
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		telegraph = Telegraph.circle(target, 22.0, windup, damage, source)
		renderer.add_archer_projectile(enemy_id, origin, target, windup)
	elif enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.ELITE:
		telegraph = Telegraph.line(origin, target - origin, 145.0, 30.0, windup, damage, source)
	elif enemy_type == EnemySimulation.EnemyType.SHIELD:
		telegraph = Telegraph.fan(origin, target - origin, 72.0, deg_to_rad(72.0), windup, damage, source)
	else:
		telegraph = Telegraph.circle(target, 38.0, windup, damage, source)
	telegraph.source_enemy_id = enemy_id
	_add_telegraph(telegraph)

func _on_enemy_attack_cancelled(enemy_id: int) -> void:
	_cancel_enemy_telegraphs(enemy_id)

func _on_elite_telegraph(telegraph: Telegraph) -> void:
	_add_telegraph(telegraph)

func _on_elite_defeated(elite: EliteActor) -> void:
	_cancel_elite_telegraphs(elite.telegraph_source)
	loot.drop_loot(elite.position, 12, 4)
	player.add_ultimate_energy(12.0)
	player.on_enemy_defeated(EnemySimulation.EnemyType.ELITE)
	hud.set_message("精英击破：%s" % elite.display_name())
	elites.erase(elite)
	renderer.set_elites(elites)
	hud.set_elites(elites)
	elite.call_deferred("queue_free")

func _add_telegraph(telegraph: Telegraph) -> void:
	if telegraphs.size() >= 22:
		return
	if _is_named_threat_source(telegraph.source) and _named_threat_count() >= 2:
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
			if _telegraph_hits_player(telegraph):
				var damage_taken := player.receive_damage(telegraph.damage, telegraph.source)
				if telegraph.source == "boss":
					if damage_taken > 0.0:
						hud.set_message("张郃命中：-%d 生命" % int(damage_taken))
					else:
						hud.set_message("龙胆护体抵挡了张郃的攻击")
			telegraphs.remove_at(index)

func _can_schedule_enemy_attack(enemy_type: int) -> bool:
	var group := _enemy_attack_group(enemy_type)
	var maximum := 4
	if group == "archer":
		maximum = 3
	elif group == "halberd":
		maximum = 1
	for telegraph in telegraphs:
		if telegraph.source_enemy_id >= 0 and _enemy_attack_group_for_source(telegraph.source) == group:
			maximum -= 1
	return maximum > 0

func _enemy_attack_source(enemy_type: int) -> String:
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.ELITE:
		return "halberd"
	if enemy_type == EnemySimulation.EnemyType.SHIELD:
		return "shield"
	return "sword"

func _enemy_attack_group(enemy_type: int) -> String:
	if enemy_type == EnemySimulation.EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemySimulation.EnemyType.HALBERD or enemy_type == EnemySimulation.EnemyType.ELITE:
		return "halberd"
	return "frontline"

func _enemy_attack_group_for_source(source: String) -> String:
	if source == "archer":
		return "archer"
	if source == "halberd":
		return "halberd"
	return "frontline"

func _cancel_enemy_telegraphs(enemy_id: int) -> void:
	for index in range(telegraphs.size() - 1, -1, -1):
		if telegraphs[index].source_enemy_id == enemy_id:
			telegraphs.remove_at(index)
	renderer.cancel_archer_projectiles(enemy_id)

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

func _on_level_up(level: int) -> void:
	player.apply_level_up_benefits()
	if upgrade_open:
		queued_level_ups.append(level)
		return
	_open_level_up(level)

func _open_level_up(level: int) -> void:
	upgrade_open = true
	input_router.set_input_enabled(false)
	hud.set_message("等级提升：Lv.%d" % level)
	hud.show_upgrades(upgrades.draft(level), upgrades)

func _on_upgrade_selected(upgrade_id: String) -> void:
	upgrades.record_selection(upgrade_id)
	player.apply_upgrade(upgrade_id)
	hud.set_message("已获得：%s" % upgrades.title_for(upgrade_id))
	if not queued_level_ups.is_empty():
		_open_level_up(queued_level_ups.pop_front())
		return
	upgrade_open = false
	input_router.set_input_enabled(true)

func _on_pause_requested() -> void:
	if paused or finished or upgrade_open:
		return
	paused = true
	input_router.set_input_enabled(false)
	hud.show_pause()

func _on_resume_requested() -> void:
	if not paused:
		return
	paused = false
	hud.hide_pause()
	input_router.set_input_enabled(true)

func _on_home_requested() -> void:
	SceneRouter.go_home()

func _on_player_died() -> void:
	_finish_run(false, "赵云力竭，战局失败")

func _on_boss_defeated() -> void:
	_cancel_boss_telegraphs()
	_finish_run(true, "张郃败退，长坂坡突围成功！")

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
	input_router.set_input_enabled(false)
	hud.set_message(message)
	hud.show_result(victory, message)
	SceneRouter.finish_run({"victory": victory, "military_merit": run_gold + (20 if victory else 0)})
