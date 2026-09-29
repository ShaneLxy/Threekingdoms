class_name SiegeSystem
extends Node

const COMBAT_MATH = preload("res://scripts/domain/combat_math.gd")
const SIEGE_ARMORY = preload("res://scripts/domain/siege_armory.gd")

# "攻城略地"首版只持有模式专属的轻量状态。己方兵卒采用数据驱动的
# 简化模拟，避免为十余名友军引入完整 Actor、碰撞和动画树开销；正式美术
# 到位后可在不改战局规则的前提下替换 BattleRenderer 的占位绘制。

signal gate_destroyed()
signal message_requested(value: String)
signal targeting_changed()
signal counterattack_started()
signal gate_assault_started(seconds: float)
signal defense_resumed()
signal node_challenge_requested(node_index: int, elite_id: String, at: Vector2)
signal final_challenge_requested(at: Vector2)
signal final_hero_reinforcement_requested()
signal wall_volley_requested(origin: Vector2, impacts: Array, final_volley: bool)
signal arrow_tower_shot_requested(tower_index: int, origin: Vector2, impact: Vector2)
signal arrow_tower_damaged(at: Vector2, damage: float, tower_index: int)
signal garrison_volley_requested(shots: Array)

enum RamState { INACTIVE, MARCHING, BLOCKED, ATTACKING, REBUILDING }
enum FriendlyAttackState { READY, WINDUP, RECOVERY }
enum SiegePhase { DEFENSE, COUNTERATTACK, GATE_ASSAULT, NODE_CHALLENGE, FINAL_CHALLENGE, FINAL_ASSAULT }

const INITIAL_RESERVES := 100
const INITIAL_FRIENDLY_COUNT := 12
const FRIENDLY_FIELD_CAP := 18
const FRIENDLY_REINFORCEMENT_BATCH := 4
const FRIENDLY_REINFORCEMENT_INTERVAL := 10.0
const FRIENDLY_REINFORCEMENT_THRESHOLD := 14
const FRIENDLY_MAX_HEALTH := 48.0
const FRIENDLY_BASE_DEFENSE := 0.0
const FRIENDLY_MOVE_SPEED := 78.0
const FRIENDLY_ATTACK_RANGE := 58.0
const FRIENDLY_ATTACK_DAMAGE := 5.0
const FRIENDLY_GATE_DAMAGE_PER_SECOND := 0.12
const FRIENDLY_HOSTILE_RADIUS := 118.0
const FRIENDLY_KNIFE_ATTACK_INTERVAL := 1.35
const FRIENDLY_KNIFE_WINDUP := 0.60
const FRIENDLY_KNIFE_RECOVERY := 0.28
const FRIENDLY_KNIFE_ATTACK_VISUAL_DURATION := 0.88
const FRIENDLY_SPEAR_ATTACK_INTERVAL := 1.55
const FRIENDLY_SPEAR_WINDUP := 0.58
const FRIENDLY_SPEAR_RECOVERY := 0.36
const FRIENDLY_SPEAR_ATTACK_VISUAL_DURATION := 0.94
const FRIENDLY_ATTACK_SLOT_COUNT := 5
const FRIENDLY_ATTACK_SLOT_SETTLE_DISTANCE := 14.0
const FRIENDLY_TARGET_RELEASE_RADIUS := 220.0
const FRIENDLY_TARGET_LOAD_PENALTY := 76.0
const FRIENDLY_TARGET_OVERLOAD_PENALTY := 180.0
const FRIENDLY_TARGET_ATTACKER_CAP := 5
const FRIENDLY_SEPARATION_RADIUS := 46.0
const FRIENDLY_SEPARATION_STRENGTH := 94.0
const FRIENDLY_CORPSE_DURATION := 1.22
const FRIENDLY_CORPSE_LIMIT := 18

const GATE_MAX_DURABILITY := 2400.0
const GATE_WIDTH := 132.0
const GATE_HALF_HEIGHT := 330.0
const PLAYER_GATE_DAMAGE_RATIO := 0.035
const FINAL_GATE_DURABILITY := 360.0
const FINAL_PLAYER_GATE_DAMAGE_RATIO := 0.20
const FINAL_FRIENDLY_GATE_DAMAGE_PER_SECOND := 2.2
const GATE_BREACH_DURATION := 2.4
# 与攻取荆州底图右侧城墙内沿对应。边界从上方向右下方倾斜，战场有效区域
# 始终位于该线左侧；用比例而非固定坐标以便以后替换等比例地图时复用。
const WALL_FRONT_TOP_RATIO := 0.775
const WALL_FRONT_BOTTOM_RATIO := 0.925
const WALL_FRONTLINE_CLEARANCE := 24.0
# 左侧军营只保留中间的主路作为通行带。该限制只在地图左端的军营
# 横向范围内生效，单位离开军营后仍可在完整战场高度内移动。
const CAMP_GUARD_X_END_RATIO := 0.12
const CAMP_WALK_TOP_RATIO := 0.28
const CAMP_WALK_BOTTOM_RATIO := 0.56
const FRIENDLY_CAMP_LANE_STEP := 15.0
# 底图中城门前有一段向右凹入的石砌门道。该范围应可行走至城门前，
# 但两侧仍由城墙阻挡，不能把整条斜向城墙都向右放开。
const GATE_ENTRY_HALF_HEIGHT := 330.0
const GATE_ENTRY_DEPTH := 170.0
const GATE_DOOR_CLEARANCE := 28.0
const HERO_FORCE_FOCUS_DISTANCE := 112.0
# 攻城锤是移动目标。守军必须在近距离主动拦截，但不能让整支部队无脑
# 堆在车旁；容量始终优先给实际靠近工程车的敌军。
const RAM_MELEE_ASSAULT_CAP := 6
const RAM_RANGED_ASSAULT_CAP := 2
const RAM_INTERCEPT_RADIUS := 160.0
const RAM_APPROACH_RADIUS := 260.0
const RAM_INTERCEPT_RELEASE_RADIUS := 320.0
const RAM_INTERCEPT_REPLACEMENT_MARGIN := 24.0
const FRIENDLY_DEFENDER_CAP := 2
const FRIENDLY_TARGET_SPREAD_DISTANCE := 220.0
const ASSIGNMENT_PRUNE_INTERVAL := 0.75

const FIRST_RAM_DEPLOYMENT_DELAY := 48.0
const RAM_REBUILD_DELAY := 35.0
const RAM_MAX_HEALTH := 1150.0
const RAM_BASE_DEFENSE := 61.0
const RAM_MOVE_SPEED := 108.0
const RAM_BLOCKED_SPEED_MULTIPLIER := 0.46
const RAM_BLOCKED_ENEMY_COUNT := 9
const RAM_FINAL_APPROACH_DISTANCE := 128.0
const RAM_ATTACK_INTERVAL := 2.8
const RAM_GATE_DAMAGE := 126.0
const RAM_DANGER_RADIUS := 176.0
const RAM_DAMAGE_PER_ENEMY_PER_SECOND := 1.45
# 该偏移量必须与 BattleRenderer._draw_siege_ram() 中锤头的绘制位置一致。
# 用锤头碰门，而不是用车体中心或城墙通行边界判断，避免“视觉已到城门、
# 逻辑仍在行军”的卡门问题。
const RAM_HAMMER_OFFSET_X := 82.0
const RAM_HAMMER_CLEARANCE := 8.0
const GATE_ASSAULT_DURATION := 30.0

# 攻城略地改为连续大地图的分层推进。每一层由曹军盾墙封锁，击破关键
# 目标后才允许继续右移；阻挡本身只使用数学边界，不给整排展示兵创建碰撞体。
const NODE_TRIGGER_DISTANCE := 308.0
const BARRIER_EDGE_CLEARANCE := 8.0
const BARRIER_HOLD_DISTANCE := 16.0
const BARRIER_TOP_CLEARANCE := 58.0
const BARRIER_BOTTOM_CLEARANCE := 58.0
const BARRIER_BREAK_VISUAL_DURATION := 1.25
const ARROW_TOWER_COUNT := 4
const ARROW_TOWER_MAX_HEALTH := 14400.0
const ARROW_TOWER_ARMOR := 20.0
# 箭楼统一以模型脚底中心定位。旧版受击点、模型和箭矢起点分别使用不同的
# X 偏移，既会让塔身压到后方守军，也容易造成“模型在这里、判定在别处”的错觉。
const ARROW_TOWER_FOOT_X_OFFSET := -96.0
const ARROW_TOWER_ARROW_ORIGIN_OFFSET := Vector2(-10.0, -198.0)
# 只覆盖箭楼塔基，避免用整张高塔图片做碰撞而产生过宽、过高的空气墙。
const ARROW_TOWER_BLOCK_HALF_EXTENTS := Vector2(36.0, 32.0)
const ARROW_TOWER_BARRIER_HOLD_DISTANCE := 16.0
const ARROW_TOWER_HURT_DURATION := 0.18
const ARROW_TOWER_DESTROY_DURATION := 0.62
const ARROW_TOWER_FIRE_DURATION := 0.34
const ARROW_TOWER_FIRST_VOLLEY_DELAY := 1.05
const ARROW_TOWER_VOLLEY_INTERVAL := 1.65
const ARROW_TOWER_SHOTS_PER_VOLLEY := 2
const ARROW_TOWER_SHOT_STAGGER := 0.12
const ARROW_TOWER_REPEAT_SHOT_DELAY := 0.42
const ARROW_TOWER_PROJECTILE_WINDUP := 0.86
const ARROW_TOWER_PROJECTILE_DAMAGE := 8.0
const ARROW_TOWER_PROJECTILE_SOURCE_BASE := -9200
# 节点盾墙与后方守军阵列只负责表现与少量压制箭。每排沿整张地图的
# 纵深排开，玩家镜头内能够看到完整密集战线，但不占用 EnemySimulation 槽位。
const GARRISON_LINE_TOP_MARGIN := 24.0
const GARRISON_LINE_BOTTOM_MARGIN := 18.0
const GARRISON_LINE_UNIT_SPACING := 44.0
const GARRISON_SHIELD_X_OFFSET := 0.0
const GARRISON_SHIELD_SECOND_X_OFFSET := 72.0
const GARRISON_SPEAR_X_OFFSET := 144.0
const GARRISON_SPEAR_SECOND_X_OFFSET := 216.0
const GARRISON_ARCHER_X_OFFSET := 304.0
const GARRISON_ARCHER_SECOND_X_OFFSET := 376.0
const GARRISON_ARCHER_THIRD_X_OFFSET := 448.0
const GARRISON_ARCHER_FIRE_DURATION := 0.95
const GARRISON_VOLLEY_FIRST_DELAY := 3.0
const GARRISON_VOLLEY_INTERVAL := 10.0
const GARRISON_VOLLEY_COLUMNS := 10
const GARRISON_VOLLEY_ROWS := 5
const GARRISON_VOLLEY_COLUMN_SPACING := 44.0
const GARRISON_VOLLEY_ROW_SPACING := 44.0
const GARRISON_VOLLEY_FRONT_OFFSET := 84.0
const GARRISON_VOLLEY_COLUMN_INTERVAL := 0.15
const GARRISON_VOLLEY_WINDUP := 0.92
const GARRISON_VOLLEY_PROJECTILE_DAMAGE := 8.0
const GARRISON_VOLLEY_SOURCE_LANE_RANGE := 360.0
const GARRISON_PROJECTILE_SOURCE_BASE := -9400
const GARRISON_SOURCE_NODE_STRIDE := 1000
# 每层盾阵被突破后，只把玩家所在纵深附近的一小部分守军转入正常敌军模拟。
# 这样阵列不会突兀消失，又不会把整条防线的数十名展示兵全部转成 AI。
const GARRISON_RESIDUAL_SHIELD_COUNT := 5
const GARRISON_RESIDUAL_SPEAR_COUNT := 5
const GARRISON_RESIDUAL_ARCHER_COUNT := 4
const GARRISON_RESIDUAL_RELEASE_DELAY := 0.46
const GARRISON_RESIDUAL_RELEASE_INTERVAL := 0.055
const GARRISON_RETREAT_DELAY := 0.46
const GARRISON_RETREAT_SPEED := 300.0
const GARRISON_RETREAT_EXIT_OFFSET := 180.0
# 开局和首层斩将后的蜀军都只服务于战场气氛。它们没有 Actor、寻路、碰撞、
# 仇恨或掉落；镜头外也不会采样动画帧。每批兵卒以短间隔分散出营，避免
# 整队瞬移堆在英雄身后，仍不会挤占 EnemySimulation 与 friendly_units 槽位。
const BATTLEFIELD_FRIENDLY_OPENING_WAVE_COUNT := 20
const BATTLEFIELD_FRIENDLY_REINFORCEMENT_WAVE_COUNT := 28
const BATTLEFIELD_FRIENDLY_ENTRY_COLUMNS := 4
const BATTLEFIELD_FRIENDLY_ENTRY_X_SPACING := 44.0
const BATTLEFIELD_FRIENDLY_ENTRY_INTERVAL := 0.18
const BATTLEFIELD_FRIENDLY_ADVANCE_SPEED_MIN := 78.0
const BATTLEFIELD_FRIENDLY_ADVANCE_SPEED_MAX := 118.0
const BATTLEFIELD_FRIENDLY_FRONT_SPREAD_MIN := 108.0
const BATTLEFIELD_FRIENDLY_FRONT_SPREAD_MAX := 520.0
const BATTLEFIELD_FRIENDLY_PRESSURE_SAMPLE_INTERVAL := 0.5
const BATTLEFIELD_FRIENDLY_ATTACK_MIN_INTERVAL := 0.72
const BATTLEFIELD_FRIENDLY_ATTACK_MAX_INTERVAL := 1.36
const BATTLEFIELD_FRIENDLY_TARGET_RADIUS := 244.0
const BATTLEFIELD_FRIENDLY_TARGET_REFRESH_INTERVAL := 0.56
const BATTLEFIELD_FRIENDLY_ATTACK_RANGE := 62.0
const BATTLEFIELD_FRIENDLY_ATTACK_DAMAGE := 4.0
const BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS := 42.0
const BATTLEFIELD_FRIENDLY_TARGET_LOAD_PENALTY := 24000.0
const BATTLEFIELD_FRIENDLY_TARGET_LANE_PENALTY := 17.0
const ENEMY_FRIENDLY_TARGET_RADIUS := 280.0
const FIRST_NODE_ELITE_TRIGGER_SECONDS := 30.0
const FIRST_NODE_ELITE_ENTRY_OFFSET := 544.0
const FIRST_NODE_ELITE_RETREAT_OFFSET := 676.0
const FINAL_CHALLENGE_DISTANCE := 360.0
const FINAL_HERO_REINFORCEMENT_DELAY := 10.0
const FINAL_DUEL_LEFT_WALL_DISTANCE := 720.0
const FINALE_FRIENDLY_COUNT := 18
const FINALE_FRIENDLY_START_DISTANCE := 470.0
const FINALE_FRIENDLY_MOVE_SPEED := 180.0
const VOLLEY_WINDUP := 1.10
const NODE_VOLLEY_INTERVAL := 5.7
const FINAL_VOLLEY_INTERVAL := 3.85
const PROGRESSION_NODE_DEFINITIONS := [
	{
		"id": "forward_shield_wall",
		"ratio": 0.40,
		"title": "前军盾墙",
		"objective": "斩杀守备校尉",
		"elite": "xiahou_en",
		"challenge_type": "elite",
	},
	{
		"id": "central_duel_line",
		"ratio": 0.68,
		"title": "中军拒战",
		"objective": "击退淳于导、夏侯恩",
		"elite": "chunyu_dao",
		"challenge_type": "elite",
	},
]

const OFFENSE_DURATION := 25.0
const OFFENSE_MAX_STACKS := 3
const DEFENSE_MAX_STACKS := 2

var active := false
var world_bounds := Rect2()
var enemies: EnemySimulation
var siege_elapsed := 0.0
var phase := SiegePhase.DEFENSE
var gate_assault_remaining := 0.0
var progression_nodes: Array[Dictionary] = []
var active_node_index := -1
var active_node_elite_id := -1
var second_node_reinforcement_triggered := false
var second_node_support_elite_id := -1
var second_node_primary_defeated := false
var second_node_support_defeated := false
var final_challenge_started := false
var final_hero_reinforcement_remaining := INF
var final_hero_reinforcement_emitted := false
var final_formation_elite_ids: Dictionary = {}
var final_formation_defeated_ids: Dictionary = {}
var final_duel_left_wall_units: Array[Dictionary] = []
var volley_remaining := NODE_VOLLEY_INTERVAL
var volley_serial := 0
var arrow_tower_volley_remaining := INF
var arrow_tower_shot_queue: Array[Dictionary] = []
var garrison_volley_remaining := GARRISON_VOLLEY_FIRST_DELAY
var garrison_volley_serial := 0
var garrison_volley_columns: Array = []
var garrison_volley_column_remaining := 0.0
var garrison_firing_refs: Array[Dictionary] = []
var garrison_rng := RandomNumberGenerator.new()
var garrison_residual_release_queue: Array[Dictionary] = []
var visible_world_rect := Rect2()
var gate_position := Vector2.ZERO
var gate_durability := GATE_MAX_DURABILITY
var gate_breach_remaining := 0.0
var gate_hit_flash := 0.0
var gate_has_fallen := false

var reserves := INITIAL_RESERVES
var reinforcement_timer := FRIENDLY_REINFORCEMENT_INTERVAL
var friendly_units: Array[Dictionary] = []
var friendly_corpses: Array[Dictionary] = []
# 与 friendly_units 完全分离的展示兵团。它不参与敌人目标选择或失败条件，
# 只通过战场压力和箭雨导演小批伤亡，避免大规模画面变成大规模模拟。
var battlefield_friendly_units: Array[Dictionary] = []
var battlefield_friendly_deployment_queue: Array[Dictionary] = []
var battlefield_friendly_serial := 0
var battlefield_friendly_deployment_remaining := 0.0
var battlefield_pressure_sample_remaining := 0.0
var battlefield_pressure := 0
var friendly_attack_assignments: Dictionary = {}
var friendly_serial := 0
var lone_stand_announced := false
var armory_effects: Dictionary = {}

var ram_state := RamState.INACTIVE
var ram_position := Vector2.ZERO
var ram_health := 0.0
var ram_attack_remaining := 0.0
var ram_deployment_remaining := FIRST_RAM_DEPLOYMENT_DELAY
var ram_hit_flash := 0.0

var offense_stacks := 0
var offense_remaining := 0.0
var defense_stacks := 0
var defender_target_assignments: Dictionary = {}
var friendly_defender_counts: Dictionary = {}
var ram_melee_defender_count := 0
var ram_ranged_defender_count := 0
var assignment_prune_remaining := 0.0

func configure(bounds: Rect2, enemy_simulation: EnemySimulation, enabled: bool) -> void:
	active = enabled
	world_bounds = bounds
	enemies = enemy_simulation
	siege_elapsed = 0.0
	# 城门交互点位于门道最内侧。角色可进入石砌门道，但会停在关闭的门扉前，
	# 仍可用已有攻击范围对城门造成伤害。
	gate_position = Vector2(_walkable_wall_limit_x_at_y(bounds.get_center().y) + GATE_DOOR_CLEARANCE, bounds.get_center().y)
	gate_durability = GATE_MAX_DURABILITY
	gate_breach_remaining = 0.0
	gate_hit_flash = 0.0
	gate_has_fallen = false
	phase = SiegePhase.DEFENSE
	gate_assault_remaining = 0.0
	progression_nodes.clear()
	active_node_index = -1
	active_node_elite_id = -1
	second_node_reinforcement_triggered = false
	second_node_support_elite_id = -1
	second_node_primary_defeated = false
	second_node_support_defeated = false
	final_challenge_started = false
	final_hero_reinforcement_remaining = INF
	final_hero_reinforcement_emitted = false
	final_formation_elite_ids.clear()
	final_formation_defeated_ids.clear()
	final_duel_left_wall_units.clear()
	volley_remaining = NODE_VOLLEY_INTERVAL
	volley_serial = 0
	arrow_tower_volley_remaining = INF
	arrow_tower_shot_queue.clear()
	garrison_volley_remaining = GARRISON_VOLLEY_FIRST_DELAY
	garrison_volley_serial = 0
	garrison_volley_columns.clear()
	garrison_volley_column_remaining = 0.0
	garrison_firing_refs.clear()
	garrison_residual_release_queue.clear()
	visible_world_rect = Rect2()
	garrison_rng.randomize()
	armory_effects = SIEGE_ARMORY.effects_for_profile(SaveService.load_profile())
	reserves = INITIAL_RESERVES
	reinforcement_timer = FRIENDLY_REINFORCEMENT_INTERVAL
	friendly_units.clear()
	friendly_corpses.clear()
	battlefield_friendly_units.clear()
	battlefield_friendly_deployment_queue.clear()
	battlefield_friendly_serial = 0
	battlefield_friendly_deployment_remaining = 0.0
	battlefield_pressure_sample_remaining = 0.0
	battlefield_pressure = 0
	friendly_attack_assignments.clear()
	friendly_serial = 0
	lone_stand_announced = false
	ram_state = RamState.INACTIVE
	ram_position = Vector2(bounds.position.x + 146.0, bounds.get_center().y)
	ram_health = 0.0
	ram_attack_remaining = 0.0
	ram_deployment_remaining = FIRST_RAM_DEPLOYMENT_DELAY
	ram_hit_flash = 0.0
	offense_stacks = 0
	offense_remaining = 0.0
	defense_stacks = 0
	defender_target_assignments.clear()
	friendly_defender_counts.clear()
	ram_melee_defender_count = 0
	ram_ranged_defender_count = 0
	assignment_prune_remaining = ASSIGNMENT_PRUNE_INTERVAL
	if enemies != null:
		enemies.set_siege_morale(0)
	if active:
		_build_progression_nodes()
		_enqueue_battlefield_friendly_wave(BATTLEFIELD_FRIENDLY_OPENING_WAVE_COUNT, _battlefield_front_for_node(0))

func is_active() -> bool:
	return active

func gate_ratio() -> float:
	var maximum := FINAL_GATE_DURABILITY if phase == SiegePhase.FINAL_ASSAULT else GATE_MAX_DURABILITY
	return clampf(gate_durability / maximum, 0.0, 1.0)

func objective_ratio() -> float:
	var completed := 0
	for node_variant in progression_nodes:
		if str((node_variant as Dictionary).get("state", "locked")) == "cleared":
			completed += 1
	if phase == SiegePhase.FINAL_ASSAULT or gate_has_fallen:
		completed = progression_nodes.size() + 1
	return clampf(float(completed) / maxf(1.0, float(progression_nodes.size() + 1)), 0.0, 1.0)

func objective_label() -> String:
	if phase == SiegePhase.FINAL_ASSAULT:
		return "破城总攻"
	if phase == SiegePhase.FINAL_CHALLENGE:
		return "城下决战"
	var node := _next_locked_node()
	if not node.is_empty():
		return "%s · %s" % [str(node.get("title", "前方防线")), str(node.get("objective", "突破防线"))]
	return "城门在前"

func progression_barrier_data() -> Array[Dictionary]:
	return progression_nodes

func final_duel_left_wall_data() -> Array[Dictionary]:
	return final_duel_left_wall_units

func final_duel_left_wall_x() -> float:
	return gate_position.x - FINAL_DUEL_LEFT_WALL_DISTANCE

func arrow_towers_for_render() -> Array[Dictionary]:
	var towers: Array[Dictionary] = []
	for node_variant in progression_nodes:
		var node := node_variant as Dictionary
		if not _node_uses_arrow_towers(node):
			continue
		if str(node.get("state", "locked")) == "cleared" and float(node.get("break_remaining", 0.0)) <= 0.0:
			continue
		for tower_variant in node.get("towers", []) as Array:
			towers.append((tower_variant as Dictionary).duplicate())
	return towers

func active_arrow_towers() -> Array[Dictionary]:
	if phase != SiegePhase.NODE_CHALLENGE:
		return []
	var node := _active_node()
	if not _node_uses_arrow_towers(node):
		return []
	var towers: Array[Dictionary] = []
	for tower_variant in node.get("towers", []) as Array:
		towers.append((tower_variant as Dictionary).duplicate())
	return towers

func arrow_tower_origin_for_projectile(source_enemy_id: int) -> Vector2:
	var tower_index := -source_enemy_id - ARROW_TOWER_PROJECTILE_SOURCE_BASE
	for node_variant in progression_nodes:
		var node := node_variant as Dictionary
		if not _node_uses_arrow_towers(node):
			continue
		for tower_variant in node.get("towers", []) as Array:
			var tower := tower_variant as Dictionary
			if int(tower.get("id", -1)) == tower_index:
				return tower.get("arrow_origin", Vector2.ZERO) as Vector2
	return Vector2.ZERO

func is_arrow_tower_projectile_source(source_enemy_id: int) -> bool:
	return source_enemy_id <= ARROW_TOWER_PROJECTILE_SOURCE_BASE and source_enemy_id > ARROW_TOWER_PROJECTILE_SOURCE_BASE - ARROW_TOWER_COUNT

func is_garrison_projectile_source(source_enemy_id: int) -> bool:
	return source_enemy_id <= GARRISON_PROJECTILE_SOURCE_BASE and source_enemy_id > GARRISON_PROJECTILE_SOURCE_BASE - GARRISON_SOURCE_NODE_STRIDE * maxi(1, progression_nodes.size())

func garrison_archer_origin_for_projectile(source_enemy_id: int) -> Vector2:
	for node_index in range(progression_nodes.size()):
		var node := progression_nodes[node_index]
		for unit_variant in node.get("garrison", []) as Array:
			var unit := unit_variant as Dictionary
			if _garrison_source_id(node_index, int(unit.get("id", -1))) == source_enemy_id:
				return (unit.get("position", Vector2.ZERO) as Vector2) + Vector2(-6.0, -54.0)
	return Vector2.ZERO

func gate_visual_rect() -> Rect2:
	return Rect2(
		gate_position - Vector2(GATE_WIDTH * 0.5, GATE_HALF_HEIGHT),
		Vector2(GATE_WIDTH, GATE_HALF_HEIGHT * 2.0)
	)

func wall_front_x_at_y(world_y: float) -> float:
	var ratio := inverse_lerp(world_bounds.position.y, world_bounds.end.y, world_y)
	return world_bounds.position.x + world_bounds.size.x * lerpf(WALL_FRONT_TOP_RATIO, WALL_FRONT_BOTTOM_RATIO, clampf(ratio, 0.0, 1.0))

func enemy_spawn_limit_x_at_y(world_y: float) -> float:
	# 当前盾墙尚在时，守军只在玩家可抵达的这一层防线内补入，避免敌兵从
	# 盾墙后方穿模般地直接穿过。全部节点击破后才恢复到城墙前的出生范围。
	var barrier := _next_locked_node()
	if not barrier.is_empty():
		var barrier_position: Vector2 = barrier.get("position", Vector2.INF)
		if barrier_position.is_finite():
			var hold_distance := ARROW_TOWER_BARRIER_HOLD_DISTANCE if _node_uses_arrow_towers(barrier) else BARRIER_HOLD_DISTANCE
			var combat_front := barrier_position.x - hold_distance - BARRIER_EDGE_CLEARANCE - 32.0
			return minf(wall_front_x_at_y(world_y), combat_front)
	return wall_front_x_at_y(world_y)

func _gate_entry_top(radius: float) -> float:
	return world_bounds.get_center().y - GATE_ENTRY_HALF_HEIGHT + maxf(0.0, radius)

func _gate_entry_bottom(radius: float) -> float:
	return world_bounds.get_center().y + GATE_ENTRY_HALF_HEIGHT - maxf(0.0, radius)

func _is_within_gate_entry_y(world_y: float, radius: float) -> bool:
	return world_y >= _gate_entry_top(radius) and world_y <= _gate_entry_bottom(radius)

func _camp_guard_x_end() -> float:
	return world_bounds.position.x + world_bounds.size.x * CAMP_GUARD_X_END_RATIO

func _camp_walk_top(radius: float) -> float:
	return world_bounds.position.y + world_bounds.size.y * CAMP_WALK_TOP_RATIO + maxf(0.0, radius)

func _camp_walk_bottom(radius: float) -> float:
	return world_bounds.position.y + world_bounds.size.y * CAMP_WALK_BOTTOM_RATIO - maxf(0.0, radius)

func _is_within_camp_corridor_y(world_y: float, radius: float) -> bool:
	return world_y >= _camp_walk_top(radius) and world_y <= _camp_walk_bottom(radius)

func _constrain_camp_entry(origin: Vector2, candidate: Vector2, radius: float) -> Vector2:
	# 军营上下两块是美术区域。这里不再把试图越界的单位强制夹到通道
	# 上/下边缘，否则斜向移动会表现成瞬移；只移除会继续进入禁区的分量。
	var camp_boundary_x := _camp_guard_x_end() + maxf(0.0, radius)
	if candidate.x > camp_boundary_x or _is_within_camp_corridor_y(candidate.y, radius):
		return candidate
	var origin_inside_camp := origin.x <= camp_boundary_x
	var origin_in_corridor := _is_within_camp_corridor_y(origin.y, radius)
	if origin_inside_camp:
		if origin_in_corridor:
			# 从道路向军营上下区域移动时，保留当前 Y，只允许继续沿道路前进。
			return Vector2(candidate.x, origin.y)
		if candidate.x > origin.x:
			# 容错处理：旧版本遗留在禁区内的单位可优先向右离开军营。
			return candidate
		if is_equal_approx(origin.x, camp_boundary_x):
			# 已贴在军营外沿时可沿边界上下滑动，寻找中间通道入口。
			return Vector2(camp_boundary_x, candidate.y)
		return origin
	# 从战场斜向撞入上/下营区时，沿实际轨迹停在军营外沿，而非改写 Y。
	var movement_x := candidate.x - origin.x
	if movement_x >= -0.001:
		return candidate
	var contact_ratio := clampf((camp_boundary_x - origin.x) / movement_x, 0.0, 1.0)
	var contact := origin.lerp(candidate, contact_ratio)
	return Vector2(camp_boundary_x, contact.y)

func _walkable_wall_limit_x_at_y(_world_y: float) -> float:
	# 门道右侧即关闭的门扉，保持为竖直线；不能随着外墙斜线变化，否则角色
	# 在门道内上下走时仍会被缓慢横推。门道两端由专门的横向侧墙处理。
	return wall_front_x_at_y(world_bounds.get_center().y) + GATE_ENTRY_DEPTH

func clamp_to_wall_front(origin: Vector2, candidate: Vector2, radius: float, enforce_progression_barrier: bool = true) -> Vector2:
	if not active or gate_has_fallen:
		return candidate
	# 攻城图只需限制右侧城墙内沿，不需要把斜线离散成数十个碰撞矩形。
	# 门道采用 U 形边界：角色在凹槽内撞到上下侧墙时应停住，而不是被
	# “渐变墙线”瞬间横推回战场。该计算仍为常数时间。
	var camp_constrained := _constrain_camp_entry(origin, candidate, radius)
	var safe_y := clampf(camp_constrained.y, world_bounds.position.y + radius, world_bounds.end.y - radius)
	var outer_limit_x := wall_front_x_at_y(safe_y) - maxf(0.0, radius)
	var safe_origin_y := clampf(origin.y, world_bounds.position.y + radius, world_bounds.end.y - radius)
	var started_inside_entry := _is_within_gate_entry_y(safe_origin_y, radius) and origin.x > wall_front_x_at_y(safe_origin_y) - maxf(0.0, radius)
	var wall_clamped := Vector2.ZERO
	if started_inside_entry and not _is_within_gate_entry_y(safe_y, radius) and candidate.x > outer_limit_x:
		# 保持角色在门道内的横向位置，并在其试图穿过的上/下侧墙前停住。
		safe_y = _gate_entry_top(radius) if safe_y < _gate_entry_top(radius) else _gate_entry_bottom(radius)
		var entry_limit_x := _walkable_wall_limit_x_at_y(safe_y) - maxf(0.0, radius)
		wall_clamped = Vector2(minf(camp_constrained.x, entry_limit_x), safe_y)
	else:
		var right_limit_x := _walkable_wall_limit_x_at_y(safe_y) if _is_within_gate_entry_y(safe_y, radius) else wall_front_x_at_y(safe_y)
		wall_clamped = Vector2(
			minf(camp_constrained.x, right_limit_x - maxf(0.0, radius)),
			safe_y
		)
	var progression_clamped := _clamp_to_progression_barrier(wall_clamped, radius) if enforce_progression_barrier else wall_clamped
	var final_duel_clamped := _clamp_to_final_duel_left_wall(origin, progression_clamped, radius)
	return _clamp_to_arrow_tower_bases(origin, final_duel_clamped, radius)

func _clamp_to_final_duel_left_wall(origin: Vector2, candidate: Vector2, radius: float) -> Vector2:
	if phase != SiegePhase.FINAL_CHALLENGE or final_duel_left_wall_units.is_empty():
		return candidate
	var left_limit := final_duel_left_wall_x() + GARRISON_SHIELD_SECOND_X_OFFSET + BARRIER_EDGE_CLEARANCE + radius
	if candidate.x >= left_limit:
		return candidate
	# 角色从城下战区撞上左侧盾墙时只阻止继续向左，不改写纵向位置，
	# 因而不会重现早期空气墙造成的横跳或瞬移。
	if origin.x >= left_limit:
		return Vector2(left_limit, candidate.y)
	return Vector2(maxf(origin.x, candidate.x), candidate.y)

func _clamp_to_progression_barrier(candidate: Vector2, radius: float) -> Vector2:
	var barrier := _next_locked_node()
	if barrier.is_empty():
		return candidate
	var barrier_position: Vector2 = barrier.get("position", Vector2.INF)
	var hold_distance := ARROW_TOWER_BARRIER_HOLD_DISTANCE if _node_uses_arrow_towers(barrier) else BARRIER_HOLD_DISTANCE
	var advance_limit := barrier_position.x - hold_distance - radius - BARRIER_EDGE_CLEARANCE
	if not barrier_position.is_finite() or candidate.x <= advance_limit:
		return candidate
	# 盾墙只留出贴身交战所需的极小安全间隔，玩家可以压到盾牌前，
	# 但不能从上下边缘绕过整列盾兵。
	return Vector2(advance_limit, candidate.y)

func _clamp_to_arrow_tower_bases(origin: Vector2, candidate: Vector2, radius: float) -> Vector2:
	# 四座箭楼仅用塔基的圆角近似矩形阻挡。此处是常数次的纯数学裁剪，
	# 比新增 PhysicsBody 或全图碰撞检测更轻，且能同时约束英雄、敌军和友军。
	var resolved := candidate
	for tower_variant in arrow_towers_for_render():
		var tower := tower_variant as Dictionary
		if float(tower.get("health", 0.0)) <= 0.0:
			continue
		var foot: Vector2 = tower.get("visual_position", Vector2.ZERO)
		var half_size := ARROW_TOWER_BLOCK_HALF_EXTENTS + Vector2.ONE * maxf(0.0, radius)
		var block := Rect2(foot - half_size, half_size * 2.0)
		if not block.has_point(resolved):
			continue
		# 从矩形哪一侧进入，就停在对应边缘，可沿边滑动；不以“推离中心”
		# 的方式处理，避免角色触边时出现突然横跳或快速滑出。
		if origin.x <= block.position.x:
			resolved.x = block.position.x
		elif origin.x >= block.end.x:
			resolved.x = block.end.x
		elif origin.y <= block.position.y:
			resolved.y = block.position.y
		elif origin.y >= block.end.y:
			resolved.y = block.end.y
		else:
			var left_distance := absf(resolved.x - block.position.x)
			var right_distance := absf(block.end.x - resolved.x)
			var top_distance := absf(resolved.y - block.position.y)
			var bottom_distance := absf(block.end.y - resolved.y)
			var closest_edge := minf(minf(left_distance, right_distance), minf(top_distance, bottom_distance))
			if is_equal_approx(closest_edge, left_distance):
				resolved.x = block.position.x
			elif is_equal_approx(closest_edge, right_distance):
				resolved.x = block.end.x
			elif is_equal_approx(closest_edge, top_distance):
				resolved.y = block.position.y
			else:
				resolved.y = block.end.y
	return resolved

func remaining_reserves() -> int:
	return reserves

func initial_reserves() -> int:
	return INITIAL_RESERVES

func friendly_count() -> int:
	return friendly_units.size()

func ram_is_active() -> bool:
	return ram_state in [RamState.MARCHING, RamState.BLOCKED, RamState.ATTACKING]

func ram_health_ratio() -> float:
	return clampf(ram_health / _ram_max_health(), 0.0, 1.0) if ram_is_active() else 0.0

func ram_status_label() -> String:
	match ram_state:
		RamState.MARCHING: return "攻城锤·行军"
		RamState.BLOCKED: return "攻城锤·受阻"
		RamState.ATTACKING: return "攻城锤·攻门"
		RamState.REBUILDING: return "攻城锤·整备中"
		_: return "攻城锤·待命"

func phase_status_label() -> String:
	match phase:
		SiegePhase.NODE_CHALLENGE:
			var node := _active_node()
			return "%s · %s" % [str(node.get("title", "前军盾墙")), str(node.get("objective", "击破守军"))]
		SiegePhase.FINAL_CHALLENGE:
			return "城下决战 · 敌楼箭雨"
		SiegePhase.FINAL_ASSAULT:
			return "破门总攻 · 城门 %d%%" % int(round(gate_ratio() * 100.0))
		SiegePhase.COUNTERATTACK:
			return "我军反攻·推进中"
		SiegePhase.GATE_ASSAULT:
			return "攻城窗口 %d 秒" % int(ceili(gate_assault_remaining))
		_:
			return "向城门推进"

func is_counterattack_active() -> bool:
	return phase in [SiegePhase.COUNTERATTACK, SiegePhase.GATE_ASSAULT, SiegePhase.FINAL_ASSAULT]

func is_final_assault_active() -> bool:
	return phase == SiegePhase.FINAL_ASSAULT

func bind_node_elite(node_index: int, elite_instance_id: int) -> void:
	if node_index != active_node_index or phase != SiegePhase.NODE_CHALLENGE:
		return
	active_node_elite_id = elite_instance_id
	if node_index == 1:
		second_node_reinforcement_triggered = false
		second_node_support_elite_id = -1
		second_node_primary_defeated = false
		second_node_support_defeated = false

func second_node_reinforcement_threshold(elite_instance_id: int) -> float:
	if phase != SiegePhase.NODE_CHALLENGE or active_node_index != 1 or elite_instance_id != active_node_elite_id:
		return INF
	# 精英血条一格为 120。淳于导血量降至第五格时进入双将阶段。
	return EliteActor.HEALTH_LAYER_CAPACITY * 5.0

func should_trigger_second_node_reinforcement(elite_instance_id: int, current_health: float, incoming_damage: float) -> bool:
	if second_node_reinforcement_triggered or incoming_damage <= 0.0:
		return false
	var threshold := second_node_reinforcement_threshold(elite_instance_id)
	return is_finite(threshold) and current_health > threshold and current_health - incoming_damage <= threshold

func begin_second_node_reinforcement(elite_instance_id: int) -> bool:
	if second_node_reinforcement_triggered or phase != SiegePhase.NODE_CHALLENGE or active_node_index != 1 or elite_instance_id != active_node_elite_id:
		return false
	second_node_reinforcement_triggered = true
	return true

func second_node_support_spawn_position() -> Vector2:
	if active_node_index != 1 or active_node_index >= progression_nodes.size():
		return Vector2.INF
	var node := progression_nodes[active_node_index]
	var node_position: Vector2 = node.get("position", world_bounds.get_center())
	var x := minf(wall_front_x_at_y(world_bounds.get_center().y) - 72.0, node_position.x + 286.0)
	return Vector2(x, clampf(world_bounds.get_center().y - 118.0, world_bounds.position.y + 72.0, world_bounds.end.y - 72.0))

func bind_second_node_support_elite(elite_instance_id: int) -> void:
	if phase == SiegePhase.NODE_CHALLENGE and active_node_index == 1 and elite_instance_id >= 0:
		second_node_support_elite_id = elite_instance_id

func bind_final_formation_member(elite_instance_id: int) -> void:
	if phase == SiegePhase.FINAL_CHALLENGE and elite_instance_id >= 0:
		final_formation_elite_ids[elite_instance_id] = true

func resolve_final_formation_member(elite_instance_id: int, player_position: Vector2 = Vector2.INF) -> bool:
	if phase != SiegePhase.FINAL_CHALLENGE or not final_formation_elite_ids.has(elite_instance_id):
		return false
	final_formation_defeated_ids[elite_instance_id] = true
	if final_formation_defeated_ids.size() < final_formation_elite_ids.size():
		return false
	return resolve_final_boss(player_position)

func allows_bound_elite_barrier_crossing(elite_instance_id: int) -> bool:
	# 节点精英从盾墙后方入场时是唯一需要穿过本层视觉阵列的单位；若沿用
	# 常规推进边界，会在首帧被数学边界强行夹到盾墙前而像“瞬移”。
	return active and phase == SiegePhase.NODE_CHALLENGE and elite_instance_id in [active_node_elite_id, second_node_support_elite_id]

func resolve_node_elite(elite_instance_id: int, player_position: Vector2 = Vector2.INF) -> bool:
	if phase != SiegePhase.NODE_CHALLENGE or active_node_index < 0 or elite_instance_id != active_node_elite_id:
		if active_node_index != 1 or elite_instance_id != second_node_support_elite_id:
			return false
	if active_node_index == 1 and second_node_reinforcement_triggered:
		if elite_instance_id == active_node_elite_id:
			second_node_primary_defeated = true
		elif elite_instance_id == second_node_support_elite_id:
			second_node_support_defeated = true
		if not (second_node_primary_defeated and second_node_support_defeated):
			return false
	var resolved_node_index := active_node_index
	var node := progression_nodes[resolved_node_index]
	node["state"] = "cleared"
	node["break_remaining"] = BARRIER_BREAK_VISUAL_DURATION
	progression_nodes[active_node_index] = node
	_queue_garrison_residuals(resolved_node_index, player_position)
	var title := str(node.get("title", "箭楼盾阵"))
	active_node_index = -1
	active_node_elite_id = -1
	phase = SiegePhase.DEFENSE
	volley_remaining = NODE_VOLLEY_INTERVAL
	if resolved_node_index == 0:
		# 首层夏侯恩败退的同时，第二批蜀军从军营分散补入，向下一道阵线
		# 压上；其后的伤亡仍由轻量战场导演控制，不会增加 AI 或寻路开销。
		_enqueue_battlefield_friendly_wave(BATTLEFIELD_FRIENDLY_REINFORCEMENT_WAVE_COUNT, _battlefield_front_for_next_locked_node())
		message_requested.emit("夏侯恩败退 · 援军压上，继续突破敌阵")
	else:
		message_requested.emit("%s已破 · 全军继续推进" % title)
	return true

func retreat_destination_for_node(node_index: int, from_position: Vector2 = Vector2.INF) -> Vector2:
	if node_index < 0 or node_index >= progression_nodes.size():
		return Vector2.INF
	var node := progression_nodes[node_index]
	var barrier_position: Vector2 = node.get("position", Vector2.INF)
	if not barrier_position.is_finite():
		return Vector2.INF
	# 败退精英从上下侧斜向撤离，终点明确放到地图边界以外。玩家不能追出
	# 边界，镜头中只会看到其快速离场，而不会在面前走到固定 X 后消失。
	var source := from_position if from_position.is_finite() else barrier_position
	var retreat_up := source.y <= world_bounds.get_center().y
	var exit_y := world_bounds.position.y - GARRISON_RETREAT_EXIT_OFFSET if retreat_up else world_bounds.end.y + GARRISON_RETREAT_EXIT_OFFSET
	var far_side := minf(
		wall_front_x_at_y(world_bounds.get_center().y) - 38.0,
		maxf(barrier_position.x + FIRST_NODE_ELITE_RETREAT_OFFSET * 0.30, source.x + 96.0)
	)
	return Vector2(far_side, exit_y)

func final_retreat_destination(from_position: Vector2, formation_slot: int = 0) -> Vector2:
	# 城下四将败退时按上下两个方向分流，避免四个模型挤在同一条撤退线上。
	var source := from_position if from_position.is_finite() else Vector2(gate_position.x - 180.0, world_bounds.get_center().y)
	var retreat_up := posmod(formation_slot, 2) == 0
	var exit_y := world_bounds.position.y - GARRISON_RETREAT_EXIT_OFFSET if retreat_up else world_bounds.end.y + GARRISON_RETREAT_EXIT_OFFSET
	var exit_x := minf(
		wall_front_x_at_y(world_bounds.get_center().y) - 28.0,
		source.x + 96.0 + float(posmod(formation_slot, 3)) * 24.0
	)
	return Vector2(exit_x, exit_y)

func set_visible_world_rect(value: Rect2) -> void:
	visible_world_rect = value

func resolve_final_boss(player_position: Vector2 = Vector2.INF) -> bool:
	if phase != SiegePhase.FINAL_CHALLENGE:
		return false
	phase = SiegePhase.FINAL_ASSAULT
	final_duel_left_wall_units.clear()
	gate_durability = minf(gate_durability, FINAL_GATE_DURABILITY)
	volley_remaining = INF
	_spawn_finale_friendlies(player_position)
	message_requested.emit("敌将尽退 · 增援抵达，亲自攻破城门")
	return true

func begin_counterattack() -> bool:
	if not active or gate_has_fallen or phase != SiegePhase.DEFENSE:
		return false
	phase = SiegePhase.COUNTERATTACK
	gate_assault_remaining = 0.0
	# 反攻只在斩将后发起：一次性派出一批大军与工程车，而非在防守阶段
	# 自动把部队送向城门。军需中的“援军数量”会直接强化这次出阵规模。
	var available_slots := FRIENDLY_FIELD_CAP - friendly_units.size()
	var assault_batch := INITIAL_FRIENDLY_COUNT + int(armory_effects.get("reinforcement_batch_bonus", 0))
	_spawn_friendly_batch(mini(assault_batch, available_slots))
	reinforcement_timer = maxf(2.0, FRIENDLY_REINFORCEMENT_INTERVAL - float(armory_effects.get("reinforcement_interval_reduction", 0.0)))
	ram_state = RamState.INACTIVE
	ram_deployment_remaining = 0.0
	_deploy_ram()
	targeting_changed.emit()
	counterattack_started.emit()
	message_requested.emit("敌将已斩 · 我军反攻，攻城锤与援军出阵")
	return true

func offense_status_label() -> String:
	return "攻势 %d/%d" % [offense_stacks, OFFENSE_MAX_STACKS]

func defense_status_label() -> String:
	return "守势 %d/%d" % [defense_stacks, DEFENSE_MAX_STACKS]

func is_lone_stand() -> bool:
	return reserves <= 0 and friendly_units.is_empty()

func enemy_target_for(enemy_id: int, enemy_position: Vector2, enemy_type: int, hero_position: Vector2) -> Dictionary:
	# 攻城车附近不能沿用“固定编号拆车组”：路过的守军也必须临时转向
	# 拦截。工程车之外，守军仍优先截击我方普通士兵，英雄贴身才拉仇恨。
	if not active:
		_release_defender_target(enemy_id)
		return {"kind": 0, "id": -1, "position": hero_position}
	var ram_distance := enemy_position.distance_to(ram_position) if ram_is_active() else INF
	var holds_ram_intercept := _has_defender_target(enemy_id, 1, 0) and ram_distance <= RAM_INTERCEPT_RELEASE_RADIUS
	if holds_ram_intercept:
		return {"kind": 1, "id": 0, "position": ram_position}
	_release_defender_target(enemy_id)
	if ram_is_active() and _should_intercept_ram(enemy_id, enemy_position, enemy_type, ram_distance):
		_assign_defender_target(enemy_id, 1, 0, enemy_type)
		return {"kind": 1, "id": 0, "position": ram_position}
	if enemy_position.distance_squared_to(hero_position) <= HERO_FORCE_FOCUS_DISTANCE * HERO_FORCE_FOCUS_DISTANCE:
		return {"kind": 0, "id": -1, "position": hero_position}
	var friendly_target := _best_friendly_target(enemy_position)
	if not friendly_target.is_empty():
		_assign_defender_target(enemy_id, 2, int(friendly_target.get("id", -1)), enemy_type)
		return friendly_target
	return {"kind": 0, "id": -1, "position": hero_position}

func receive_enemy_attack(target_kind: int, target_id: int, damage: float) -> bool:
	# 友军与攻城锤只需接收结算后的简化伤害；完整预警、格挡和受击仍专属英雄，
	# 从而避免大量非玩家目标的预警图形占满屏幕。
	if not active or damage <= 0.0:
		return false
	if target_kind == 1:
		if not ram_is_active():
			return false
		ram_health = maxf(0.0, ram_health - COMBAT_MATH.mitigate_damage(damage, _ram_defense()))
		ram_hit_flash = maxf(ram_hit_flash, 0.18)
		return true
	if target_kind != 2:
		return false
	for index in range(friendly_units.size() - 1, -1, -1):
		var unit: Dictionary = friendly_units[index]
		if int(unit.get("id", -1)) != target_id:
			continue
		# 我方普通士兵不再享受固定减伤，受到敌军命中时按完整伤害结算。
		# 攻城锤维持独立耐久规则，不受这里影响。
		unit["health"] = float(unit.get("health", _friendly_max_health())) - COMBAT_MATH.mitigate_damage(damage, _friendly_defense())
		unit["flash"] = maxf(float(unit.get("flash", 0.0)), 0.22)
		if float(unit.get("health", 0.0)) <= 0.0:
			_release_targets_for(2, target_id)
			_release_friendly_attack_target(int(unit.get("id", -1)))
			_record_friendly_corpse(unit)
			friendly_units.remove_at(index)
			targeting_changed.emit()
		else:
			friendly_units[index] = unit
		return true
	for index in range(battlefield_friendly_units.size() - 1, -1, -1):
		var battlefield_unit: Dictionary = battlefield_friendly_units[index]
		if int(battlefield_unit.get("id", -1)) != target_id:
			continue
		# 大场面展示兵同样可被附近敌军选中和击杀，但仍只保存轻量数据，
		# 不创建额外的 Actor、碰撞体或寻路状态。
		battlefield_unit["health"] = float(battlefield_unit.get("health", _friendly_max_health())) - COMBAT_MATH.mitigate_damage(damage, _friendly_defense())
		battlefield_unit["flash"] = maxf(float(battlefield_unit.get("flash", 0.0)), 0.22)
		if float(battlefield_unit.get("health", 0.0)) <= 0.0:
			_release_targets_for(2, target_id)
			_record_friendly_corpse(battlefield_unit)
			battlefield_friendly_units.remove_at(index)
			targeting_changed.emit()
		else:
			battlefield_friendly_units[index] = battlefield_unit
		return true
	return false

func tick(delta: float, player_position: Vector2) -> void:
	if not active or gate_has_fallen:
		return
	siege_elapsed += delta
	assignment_prune_remaining = maxf(0.0, assignment_prune_remaining - delta)
	if assignment_prune_remaining <= 0.0:
		_prune_defender_target_assignments()
		assignment_prune_remaining = ASSIGNMENT_PRUNE_INTERVAL
	gate_breach_remaining = maxf(0.0, gate_breach_remaining - delta)
	gate_hit_flash = maxf(0.0, gate_hit_flash - delta)
	ram_hit_flash = maxf(0.0, ram_hit_flash - delta)
	_tick_barrier_break_visuals(delta)
	_tick_arrow_tower_visuals(delta)
	_tick_garrison_fire_visual(delta)
	_tick_garrison_residual_releases(delta)
	_tick_retreating_garrisons(delta)
	_tick_battlefield_friendlies(delta, player_position)
	_tick_final_hero_reinforcement(delta)
	if phase == SiegePhase.FINAL_ASSAULT:
		_tick_finale_friendlies(delta)
		_tick_final_assault(delta)
		_tick_friendly_corpses(delta)
		return
	_tick_progression(player_position)
	_tick_garrison_archers(delta, player_position)
	_tick_arrow_tower_volley(delta, player_position)
	_tick_wall_volley(delta, player_position)
	if offense_remaining > 0.0:
		offense_remaining = maxf(0.0, offense_remaining - delta)
		if offense_remaining <= 0.0:
			offense_stacks = 0
	if phase in [SiegePhase.COUNTERATTACK, SiegePhase.GATE_ASSAULT]:
		_tick_reinforcements(delta)
	_tick_friendlies(delta)
	_tick_friendly_corpses(delta)
	_tick_ram(delta)
	if phase == SiegePhase.GATE_ASSAULT:
		gate_assault_remaining = maxf(0.0, gate_assault_remaining - delta)
		if gate_assault_remaining <= 0.0 and not gate_has_fallen:
			_resume_enemy_offense()
	if is_lone_stand() and not lone_stand_announced:
		lone_stand_announced = true
		message_requested.emit("我军援兵耗尽 · 背水破城")

func _enqueue_battlefield_friendly_wave(count: int, front_x: float) -> void:
	if count <= 0 or not is_finite(front_x):
		return
	# 先进入部署队列，再逐名从军营主路出发。兵卒拥有各自的纵向路线和
	# 前线驻点，既不会开局重叠，也不会将英雄位置作为跟随目标。
	var camp_top := world_bounds.position.y + world_bounds.size.y * CAMP_WALK_TOP_RATIO + 28.0
	var camp_bottom := world_bounds.position.y + world_bounds.size.y * CAMP_WALK_BOTTOM_RATIO - 28.0
	for _index in range(count):
		var serial_hint := battlefield_friendly_serial + battlefield_friendly_deployment_queue.size()
		var entry_column := posmod(serial_hint, BATTLEFIELD_FRIENDLY_ENTRY_COLUMNS)
		var lane_ratio := fposmod(float(serial_hint * 37 + entry_column * 11), 97.0) / 96.0
		var entry_position := Vector2(
			world_bounds.position.x + 86.0 + float(entry_column) * BATTLEFIELD_FRIENDLY_ENTRY_X_SPACING,
			lerpf(camp_top, camp_bottom, lane_ratio)
		)
		var battle_lane_y := lerpf(world_bounds.position.y + 78.0, world_bounds.end.y - 78.0, garrison_rng.randf())
		var front_spread := garrison_rng.randf_range(BATTLEFIELD_FRIENDLY_FRONT_SPREAD_MIN, BATTLEFIELD_FRIENDLY_FRONT_SPREAD_MAX)
		var route_target_x := clampf(front_x - front_spread, entry_position.x + 250.0, front_x - 52.0)
		battlefield_friendly_deployment_queue.append({
			"position": entry_position,
			"battle_lane_y": battle_lane_y,
			"route_target_x": route_target_x,
			"advance_speed": garrison_rng.randf_range(BATTLEFIELD_FRIENDLY_ADVANCE_SPEED_MIN, BATTLEFIELD_FRIENDLY_ADVANCE_SPEED_MAX),
			"kind": 1 if posmod(serial_hint, 3) == 0 else 0,
			"health": _friendly_max_health(),
			"moving": true,
			"facing": 1.0,
			"flash": 0.0,
			"enemy_target_id": -1,
			"target_refresh_remaining": 0.0,
			"attack_cooldown": garrison_rng.randf_range(0.10, 0.42),
			"combat_contact": false,
			"attack_visual_remaining": 0.0,
			"attack_state": FriendlyAttackState.READY,
			"attack_state_remaining": 0.0,
			"attack_target_id": -1,
		})

func _deploy_next_battlefield_friendly() -> void:
	if battlefield_friendly_deployment_queue.is_empty():
		return
	var unit: Dictionary = battlefield_friendly_deployment_queue.pop_front()
	battlefield_friendly_serial += 1
	unit["id"] = 10000 + battlefield_friendly_serial
	battlefield_friendly_units.append(unit)

func _battlefield_front_for_node(node_index: int) -> float:
	if node_index < 0 or node_index >= progression_nodes.size():
		return world_bounds.position.x + world_bounds.size.x * 0.48
	var node := progression_nodes[node_index]
	var position: Vector2 = node.get("position", Vector2.INF)
	return position.x - 56.0 if position.is_finite() else world_bounds.position.x + world_bounds.size.x * 0.48

func _battlefield_front_for_next_locked_node() -> float:
	var next_index := _next_locked_node_index()
	return _battlefield_front_for_node(next_index)

func _tick_battlefield_friendlies(delta: float, player_position: Vector2) -> void:
	# 每 0.18 秒只让一名兵卒出营。刚加入战场的兵卒从自己的路线向前，
	# 不以英雄坐标作为目标，因而不会发生“英雄一移动，全军漂移跟随”。
	battlefield_friendly_deployment_remaining = maxf(0.0, battlefield_friendly_deployment_remaining - delta)
	while not battlefield_friendly_deployment_queue.is_empty() and battlefield_friendly_deployment_remaining <= 0.0:
		_deploy_next_battlefield_friendly()
		battlefield_friendly_deployment_remaining += BATTLEFIELD_FRIENDLY_ENTRY_INTERVAL
	if not battlefield_friendly_units.is_empty():
		# 展示兵在刷新目标前先统计当前接敌人数。目标评分会主动避开已被多名
		# 友军缠住的敌人，让前线看起来是多点交锋而非整群追着一个人跑。
		var target_loads := _battlefield_friendly_target_loads()
		for index in range(battlefield_friendly_units.size()):
			var unit := battlefield_friendly_units[index]
			var at: Vector2 = unit.get("position", Vector2.ZERO)
			var battle_lane_y := float(unit.get("battle_lane_y", world_bounds.get_center().y))
			var route_target_x := float(unit.get("route_target_x", at.x))
			var destination := Vector2(route_target_x, battle_lane_y)
			var target_refresh_remaining := maxf(0.0, float(unit.get("target_refresh_remaining", 0.0)) - delta)
			var target_enemy_id := int(unit.get("enemy_target_id", -1))
			if target_enemy_id < 0 or enemies == null or not enemies.is_active(target_enemy_id) or target_refresh_remaining <= 0.0:
				if target_enemy_id >= 0 and target_loads.has(target_enemy_id):
					target_loads[target_enemy_id] = maxi(0, int(target_loads[target_enemy_id]) - 1)
				target_enemy_id = _choose_battlefield_friendly_target(unit, at, target_loads)
				if target_enemy_id >= 0:
					target_loads[target_enemy_id] = int(target_loads.get(target_enemy_id, 0)) + 1
				target_refresh_remaining = BATTLEFIELD_FRIENDLY_TARGET_REFRESH_INTERVAL
			unit["enemy_target_id"] = target_enemy_id
			unit["target_refresh_remaining"] = target_refresh_remaining
			var has_enemy_contact := target_enemy_id >= 0 and enemies != null and enemies.is_active(target_enemy_id)
			if has_enemy_contact:
				destination = enemies.positions[target_enemy_id] + _battlefield_friendly_target_offset(int(unit.get("id", 0)))
			var resolved_position := at
			var facing := float(unit.get("facing", 1.0))
			var attack_state := int(unit.get("attack_state", FriendlyAttackState.READY))
			var attack_state_remaining := maxf(0.0, float(unit.get("attack_state_remaining", 0.0)) - delta)
			var attack_target_id := int(unit.get("attack_target_id", -1))
			var attack_cooldown := maxf(0.0, float(unit.get("attack_cooldown", 0.0)) - delta)
			var is_spear := int(unit.get("kind", 0)) == 1
			var windup := FRIENDLY_SPEAR_WINDUP if is_spear else FRIENDLY_KNIFE_WINDUP
			var recovery := FRIENDLY_SPEAR_RECOVERY if is_spear else FRIENDLY_KNIFE_RECOVERY
			var interval := FRIENDLY_SPEAR_ATTACK_INTERVAL if is_spear else FRIENDLY_KNIFE_ATTACK_INTERVAL
			var visual_duration := FRIENDLY_SPEAR_ATTACK_VISUAL_DURATION if is_spear else FRIENDLY_KNIFE_ATTACK_VISUAL_DURATION
			unit["flash"] = maxf(0.0, float(unit.get("flash", 0.0)) - delta)
			unit["attack_visual_remaining"] = maxf(0.0, float(unit.get("attack_visual_remaining", 0.0)) - delta)
			# 攻击前摇和后摇都锁定原地。即使目标恰好死亡，也必须播完当前动作，
			# 不能再出现兵卒挥刀时一路向前滑行的画面。
			if attack_state == FriendlyAttackState.WINDUP:
				if attack_target_id >= 0 and enemies != null and enemies.is_active(attack_target_id):
					var target_offset := enemies.positions[attack_target_id] - at
					if absf(target_offset.x) > 0.01:
						facing = signf(target_offset.x)
				if attack_state_remaining <= 0.0:
					if attack_target_id >= 0 and enemies != null and enemies.is_active(attack_target_id) and at.distance_squared_to(enemies.positions[attack_target_id]) <= BATTLEFIELD_FRIENDLY_ATTACK_RANGE * BATTLEFIELD_FRIENDLY_ATTACK_RANGE * 1.44:
						enemies.apply_siege_friendly_damage(attack_target_id, BATTLEFIELD_FRIENDLY_ATTACK_DAMAGE)
						unit["flash"] = 0.13
					attack_state = FriendlyAttackState.RECOVERY
					attack_state_remaining = recovery
			elif attack_state == FriendlyAttackState.RECOVERY:
				if attack_state_remaining <= 0.0:
					attack_state = FriendlyAttackState.READY
					attack_state_remaining = 0.0
					attack_target_id = -1
					attack_cooldown = maxf(0.0, interval - windup - recovery)
			else:
				var in_attack_range := has_enemy_contact and at.distance_squared_to(enemies.positions[target_enemy_id]) <= BATTLEFIELD_FRIENDLY_ATTACK_RANGE * BATTLEFIELD_FRIENDLY_ATTACK_RANGE
				if in_attack_range:
					var target_offset := enemies.positions[target_enemy_id] - at
					if absf(target_offset.x) > 0.01:
						facing = signf(target_offset.x)
					if attack_cooldown <= 0.0:
						attack_state = FriendlyAttackState.WINDUP
						attack_state_remaining = windup
						attack_target_id = target_enemy_id
						unit["attack_visual_remaining"] = visual_duration
				else:
					var move_offset := destination - at
					if absf(move_offset.x) > 0.01:
						facing = signf(move_offset.x)
					var requested_position := at.move_toward(destination, float(unit.get("advance_speed", BATTLEFIELD_FRIENDLY_ADVANCE_SPEED_MIN)) * delta)
					resolved_position = _clamp_unit_position(at, requested_position)
			unit["position"] = resolved_position
			unit["moving"] = attack_state == FriendlyAttackState.READY and at.distance_squared_to(resolved_position) > 0.25
			unit["facing"] = facing
			unit["attack_state"] = attack_state
			unit["attack_state_remaining"] = attack_state_remaining
			unit["attack_target_id"] = attack_target_id
			unit["attack_cooldown"] = attack_cooldown
			unit["combat_contact"] = has_enemy_contact and (attack_state != FriendlyAttackState.READY or at.distance_squared_to(enemies.positions[target_enemy_id]) <= BATTLEFIELD_FRIENDLY_ATTACK_RANGE * BATTLEFIELD_FRIENDLY_ATTACK_RANGE)
			battlefield_friendly_units[index] = unit
	battlefield_pressure_sample_remaining = maxf(0.0, battlefield_pressure_sample_remaining - delta)
	if battlefield_pressure_sample_remaining <= 0.0:
		battlefield_pressure = _hostile_count_near(player_position, 340.0)
		battlefield_pressure_sample_remaining = BATTLEFIELD_FRIENDLY_PRESSURE_SAMPLE_INTERVAL
	# 展示兵已接入敌方目标选择和伤害结算；不再依据英雄附近的敌人数随机
	# 处决，避免镜头里出现“没有接战却突然死亡”或“对空气出刀”。

func _battlefield_friendly_target_offset(unit_id: int) -> Vector2:
	var slot := posmod(unit_id, 5)
	match slot:
		0: return Vector2(-BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS, 0.0)
		1: return Vector2(-BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS * 0.70, -BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS * 0.72)
		2: return Vector2(-BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS * 0.70, BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS * 0.72)
		3: return Vector2(-14.0, -BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS)
		_: return Vector2(-14.0, BATTLEFIELD_FRIENDLY_TARGET_SLOT_RADIUS)

func _battlefield_friendly_target_loads() -> Dictionary:
	var loads: Dictionary = {}
	if enemies == null:
		return loads
	for unit_variant in battlefield_friendly_units:
		var unit := unit_variant as Dictionary
		var target_id := int(unit.get("enemy_target_id", -1))
		if target_id >= 0 and enemies.is_active(target_id):
			loads[target_id] = int(loads.get(target_id, 0)) + 1
	return loads

func _choose_battlefield_friendly_target(unit: Dictionary, origin: Vector2, loads: Dictionary) -> int:
	if enemies == null:
		return -1
	var best_id := -1
	var best_score := INF
	var desired_lane_y := float(unit.get("battle_lane_y", origin.y))
	var max_distance_squared := BATTLEFIELD_FRIENDLY_TARGET_RADIUS * BATTLEFIELD_FRIENDLY_TARGET_RADIUS
	for enemy_id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(enemy_id):
			continue
		var enemy_position := enemies.positions[enemy_id]
		var distance_squared := origin.distance_squared_to(enemy_position)
		if distance_squared > max_distance_squared:
			continue
		var target_load := int(loads.get(enemy_id, 0))
		# 距离仍是基础条件，但每多一名友军锁定同一目标都会明显降低其优先级；
		# 相近距离时优先选择与自己行军纵深相符的敌人，形成横向展开的接战面。
		var score := distance_squared
		score += float(target_load) * BATTLEFIELD_FRIENDLY_TARGET_LOAD_PENALTY
		score += absf(enemy_position.y - desired_lane_y) * BATTLEFIELD_FRIENDLY_TARGET_LANE_PENALTY
		if score >= best_score:
			continue
		best_score = score
		best_id = enemy_id
	return best_id

func apply_player_attack(request: AttackRequest, combat: CombatSystem, base_attack: float) -> bool:
	if not active or gate_has_fallen or request.displacement_only:
		return false
	if phase == SiegePhase.NODE_CHALLENGE and _node_uses_arrow_towers(_active_node()):
		return _apply_player_attack_to_arrow_towers(request, combat, base_attack)
	if phase not in [SiegePhase.COUNTERATTACK, SiegePhase.GATE_ASSAULT, SiegePhase.FINAL_ASSAULT]:
		return false
	if not _request_hits_gate(request, combat):
		return false
	var multiplier := maxf(0.1, request.damage_multiplier_at(gate_position))
	var breach_bonus := 1.85 if gate_breach_remaining > 0.0 else 1.0
	var damage_ratio := FINAL_PLAYER_GATE_DAMAGE_RATIO if phase == SiegePhase.FINAL_ASSAULT else PLAYER_GATE_DAMAGE_RATIO
	var damage := maxf(1.0, base_attack * multiplier * damage_ratio * breach_bonus)
	_damage_gate(damage, false)
	return true

func _request_hits_gate(request: AttackRequest, combat: CombatSystem) -> bool:
	for vertical_offset in [-150.0, -72.0, 0.0, 72.0, 150.0]:
		if combat.request_hits_point(request, gate_position + Vector2(-GATE_WIDTH * 0.18, vertical_offset)):
			return true
	return false

func _build_progression_nodes() -> void:
	for definition_variant in PROGRESSION_NODE_DEFINITIONS:
		var definition := definition_variant as Dictionary
		var ratio := clampf(float(definition.get("ratio", 0.5)), 0.08, 0.90)
		var position := Vector2(world_bounds.position.x + world_bounds.size.x * ratio, world_bounds.get_center().y)
		var node := {
			"id": str(definition.get("id", "node")),
			"title": str(definition.get("title", "前军盾墙")),
			"objective": str(definition.get("objective", "突破盾阵")),
			"elite": str(definition.get("elite", "xiahou_en")),
			"challenge_type": str(definition.get("challenge_type", "elite")),
			"position": position,
			"state": "locked",
			"break_remaining": 0.0,
			"towers": [],
			"garrison": _build_node_garrison_data(position),
		}
		if _node_uses_arrow_towers(node):
			node["towers"] = _build_arrow_tower_data(position)
		progression_nodes.append(node)

func _build_node_garrison_data(barrier_position: Vector2) -> Array[Dictionary]:
	# 每个节点采用 2 列盾、2 列枪、3 列弓的七层纵深阵列。上下两端
	# 额外补到地图边缘，避免视觉上留下能绕过盾墙的缺口。
	# 阵列只保存轻量 Dictionary，不创建 Actor、碰撞体或 AI；渲染端还会
	# 按镜头裁剪，玩家实际看到并播放帧动画的始终只是面前的一段战线。
	var units: Array[Dictionary] = []
	var rows := [
		{"kind": "shield", "offset": GARRISON_SHIELD_X_OFFSET, "lane_offset": 0.0},
		{"kind": "shield", "offset": GARRISON_SHIELD_SECOND_X_OFFSET, "lane_offset": GARRISON_LINE_UNIT_SPACING * 0.5},
		{"kind": "spear", "offset": GARRISON_SPEAR_X_OFFSET, "lane_offset": 0.0},
		{"kind": "spear", "offset": GARRISON_SPEAR_SECOND_X_OFFSET, "lane_offset": GARRISON_LINE_UNIT_SPACING * 0.5},
		{"kind": "archer", "offset": GARRISON_ARCHER_X_OFFSET, "lane_offset": 0.0},
		{"kind": "archer", "offset": GARRISON_ARCHER_SECOND_X_OFFSET, "lane_offset": GARRISON_LINE_UNIT_SPACING * 0.5},
		{"kind": "archer", "offset": GARRISON_ARCHER_THIRD_X_OFFSET, "lane_offset": 0.0},
	]
	var top := world_bounds.position.y + GARRISON_LINE_TOP_MARGIN
	var bottom := world_bounds.end.y - GARRISON_LINE_BOTTOM_MARGIN
	var line_count := maxi(2, int(ceil((bottom - top) / GARRISON_LINE_UNIT_SPACING)) + 1)
	var serial := 0
	for row_index in range(rows.size()):
		var row := rows[row_index] as Dictionary
		for line_index in range(line_count):
			var lane_y := clampf(top + float(line_index) * GARRISON_LINE_UNIT_SPACING + float(row.get("lane_offset", 0.0)), top, bottom)
			units.append({
				"id": serial,
				"kind": str(row.get("kind", "shield")),
				"position": Vector2(barrier_position.x + float(row.get("offset", 0.0)), lane_y),
				"phase": fposmod(float(serial * 37 + row_index * 19), 101.0) * 0.013,
				"fire_remaining": 0.0,
			})
			serial += 1
	return units

func _build_arrow_tower_data(barrier_position: Vector2) -> Array[Dictionary]:
	var towers: Array[Dictionary] = []
	# 箭楼以脚底落点对齐地图；上、下两端留出足够边距，避免塔顶切出可行区域。
	var top := world_bounds.position.y + BARRIER_TOP_CLEARANCE + 300.0
	var bottom := world_bounds.end.y - BARRIER_BOTTOM_CLEARANCE - 90.0
	for index in range(ARROW_TOWER_COUNT):
		var lane_ratio := float(index) / maxf(1.0, float(ARROW_TOWER_COUNT - 1))
		var y := lerpf(top, bottom, lane_ratio)
		# 塔身整体左移到盾墙前，不再压在后方守军身上；攻击受击点和箭矢
		# 发射点都从同一个脚底锚点推导，保证视觉和战斗判定一致。
		var foot_position := Vector2(barrier_position.x + ARROW_TOWER_FOOT_X_OFFSET, y)
		towers.append({
			"id": index,
			"position": foot_position,
			"visual_position": foot_position,
			"arrow_origin": foot_position + ARROW_TOWER_ARROW_ORIGIN_OFFSET,
			"health": ARROW_TOWER_MAX_HEALTH,
			"maximum": ARROW_TOWER_MAX_HEALTH,
			"hurt_remaining": 0.0,
			"fire_remaining": 0.0,
			"destroy_remaining": 0.0,
		})
	return towers

func _node_uses_arrow_towers(node: Dictionary) -> bool:
	return str(node.get("challenge_type", "elite")) == "arrow_towers"

func _next_locked_node() -> Dictionary:
	for node_variant in progression_nodes:
		var node := node_variant as Dictionary
		if str(node.get("state", "locked")) != "cleared":
			return node
	return {}

func _active_node() -> Dictionary:
	if active_node_index < 0 or active_node_index >= progression_nodes.size():
		return {}
	return progression_nodes[active_node_index]

func _tick_progression(player_position: Vector2) -> void:
	if phase == SiegePhase.NODE_CHALLENGE or phase == SiegePhase.FINAL_CHALLENGE:
		return
	var node := _next_locked_node()
	if not node.is_empty():
		var node_position: Vector2 = node.get("position", Vector2.INF)
		var node_index := progression_nodes.find(node)
		if node_index < 0:
			return
		# 首层夏侯恩固定在开战 30 秒后从盾墙后方出阵，不能被玩家提前
		# 贴近盾墙而触发。后续节点仍保持靠近即开战的推进节奏。
		if node_index == 0 and siege_elapsed < FIRST_NODE_ELITE_TRIGGER_SECONDS:
			return
		if node_index != 0 and player_position.x < node_position.x - NODE_TRIGGER_DISTANCE:
			return
		node["state"] = "challenging"
		progression_nodes[node_index] = node
		active_node_index = node_index
		active_node_elite_id = -1
		phase = SiegePhase.NODE_CHALLENGE
		if _node_uses_arrow_towers(node):
			arrow_tower_shot_queue.clear()
			arrow_tower_volley_remaining = ARROW_TOWER_FIRST_VOLLEY_DELAY
		else:
			var entry_x := minf(wall_front_x_at_y(world_bounds.get_center().y) - 48.0, node_position.x + FIRST_NODE_ELITE_ENTRY_OFFSET)
			var spawn_at := Vector2(entry_x, world_bounds.get_center().y)
			node_challenge_requested.emit(node_index, str(node.get("elite", "xiahou_en")), spawn_at)
		message_requested.emit("%s · %s" % [str(node.get("title", "前军盾墙")), str(node.get("objective", "击破守军"))])
		return
	if final_challenge_started or player_position.x < gate_position.x - FINAL_CHALLENGE_DISTANCE:
		return
	final_challenge_started = true
	phase = SiegePhase.FINAL_CHALLENGE
	_build_final_duel_left_wall()
	volley_remaining = 1.0
	final_hero_reinforcement_remaining = FINAL_HERO_REINFORCEMENT_DELAY
	final_hero_reinforcement_emitted = false
	final_challenge_requested.emit(Vector2(gate_position.x - 248.0, world_bounds.get_center().y))
	message_requested.emit("城下决战 · 四将列阵，斩退敌将破城")

func _build_final_duel_left_wall() -> void:
	# 城下决战左侧以两列盾兵封住来路，既延续关卡内盾阵的视觉语言，
	# 又只保存轻量表现数据，不为四将战增加几十个真实单位的 AI 成本。
	final_duel_left_wall_units.clear()
	var wall_position := Vector2(final_duel_left_wall_x(), world_bounds.get_center().y)
	for unit_variant in _build_node_garrison_data(wall_position):
		var unit := unit_variant as Dictionary
		if str(unit.get("kind", "")) != "shield":
			continue
		unit["final_duel_wall"] = true
		final_duel_left_wall_units.append(unit)

func _tick_final_hero_reinforcement(delta: float) -> void:
	if phase != SiegePhase.FINAL_CHALLENGE or final_hero_reinforcement_emitted:
		return
	final_hero_reinforcement_remaining = maxf(0.0, final_hero_reinforcement_remaining - delta)
	if final_hero_reinforcement_remaining > 0.0:
		return
	final_hero_reinforcement_emitted = true
	final_hero_reinforcement_requested.emit()

func _tick_barrier_break_visuals(delta: float) -> void:
	for index in range(progression_nodes.size()):
		var node := progression_nodes[index]
		var remaining := float(node.get("break_remaining", 0.0))
		if remaining <= 0.0:
			continue
		node["break_remaining"] = maxf(0.0, remaining - delta)
		progression_nodes[index] = node

func _queue_garrison_residuals(node_index: int, player_position: Vector2) -> void:
	if enemies == null or node_index < 0 or node_index >= progression_nodes.size():
		return
	var node := progression_nodes[node_index]
	var units: Array = node.get("garrison", []) as Array
	if units.is_empty():
		return
	# 以玩家突破时的所在纵深为中心挑选残军，故屏幕内看见的守军会自然地
	# 随盾阵溃散转入战斗；镜头外其余阵列仍按表现数据淡出，不制造 AI 峰值。
	var reference: Vector2 = player_position if player_position.is_finite() else node.get("position", world_bounds.get_center()) as Vector2
	var selected: Dictionary = {}
	var composition := [
		{"kind": "shield", "count": GARRISON_RESIDUAL_SHIELD_COUNT},
		{"kind": "spear", "count": GARRISON_RESIDUAL_SPEAR_COUNT},
		{"kind": "archer", "count": GARRISON_RESIDUAL_ARCHER_COUNT},
	]
	for composition_variant in composition:
		var entry := composition_variant as Dictionary
		var required_kind := str(entry.get("kind", "shield"))
		for _count in range(int(entry.get("count", 0))):
			var selected_index := -1
			var selected_distance := INF
			for unit_index in range(units.size()):
				var unit := units[unit_index] as Dictionary
				var unit_id := int(unit.get("id", -1))
				if str(unit.get("kind", "")) != required_kind or selected.has(unit_id) or bool(unit.get("residual_released", false)):
					continue
				var at: Vector2 = unit.get("position", Vector2.ZERO)
				var distance := at.distance_squared_to(reference)
				if distance < selected_distance:
					selected_index = unit_index
					selected_distance = distance
			if selected_index < 0:
				break
			var selected_unit := units[selected_index] as Dictionary
			var selected_id := int(selected_unit.get("id", -1))
			selected[selected_id] = true
			garrison_residual_release_queue.append({
				"node_index": node_index,
				"garrison_id": selected_id,
				"kind": str(selected_unit.get("kind", "shield")),
				"position": selected_unit.get("position", Vector2.ZERO),
				"remaining": GARRISON_RESIDUAL_RELEASE_DELAY + float(garrison_residual_release_queue.size()) * GARRISON_RESIDUAL_RELEASE_INTERVAL,
			})
	# 被选中的守军留在原地，依次转入真实战斗；其余守军不是淡出，而是
	# 先短暂停顿、再从画面上、下侧斜向溃退。这样即使玩家追赶，也不会在
	# 镜头内看见整排守军跑到固定位置后凭空消失。
	for unit_index in range(units.size()):
		var unit := units[unit_index] as Dictionary
		var unit_id := int(unit.get("id", -1))
		if selected.has(unit_id):
			unit["residual_candidate"] = true
			units[unit_index] = unit
			continue
		var unit_position: Vector2 = unit.get("position", Vector2.ZERO)
		var retreat_up := unit_position.y <= world_bounds.get_center().y
		var retreat_y := world_bounds.position.y - GARRISON_RETREAT_EXIT_OFFSET if retreat_up else world_bounds.end.y + GARRISON_RETREAT_EXIT_OFFSET
		var retreat_x := minf(
			wall_front_x_at_y(clampf(unit_position.y, world_bounds.position.y, world_bounds.end.y)) - 30.0,
			unit_position.x + garrison_rng.randf_range(54.0, 126.0)
		)
		unit["retreating"] = true
		unit["retreat_delay"] = GARRISON_RETREAT_DELAY + float(posmod(unit_id, 7)) * 0.045
		unit["retreat_target"] = Vector2(retreat_x, retreat_y)
		unit["moving"] = false
		units[unit_index] = unit
	node["garrison"] = units
	node["garrison_retreating"] = true
	progression_nodes[node_index] = node

func _tick_garrison_residual_releases(delta: float) -> void:
	if garrison_residual_release_queue.is_empty():
		return
	for queue_index in range(garrison_residual_release_queue.size()):
		var entry := garrison_residual_release_queue[queue_index]
		entry["remaining"] = float(entry.get("remaining", 0.0)) - delta
		garrison_residual_release_queue[queue_index] = entry
	while not garrison_residual_release_queue.is_empty() and float((garrison_residual_release_queue[0] as Dictionary).get("remaining", 0.0)) <= 0.0:
		var entry := garrison_residual_release_queue.pop_front() as Dictionary
		_release_garrison_residual(entry)

func _tick_retreating_garrisons(delta: float) -> void:
	for node_index in range(progression_nodes.size()):
		var node := progression_nodes[node_index]
		if not bool(node.get("garrison_retreating", false)):
			continue
		var units: Array = node.get("garrison", []) as Array
		var has_retreating_units := false
		for unit_index in range(units.size() - 1, -1, -1):
			var unit := units[unit_index] as Dictionary
			if not bool(unit.get("retreating", false)):
				continue
			var delay := maxf(0.0, float(unit.get("retreat_delay", 0.0)) - delta)
			unit["retreat_delay"] = delay
			if delay > 0.0:
				units[unit_index] = unit
				has_retreating_units = true
				continue
			var at: Vector2 = unit.get("position", Vector2.ZERO)
			var retreat_target: Vector2 = unit.get("retreat_target", at)
			var moved_at := at.move_toward(retreat_target, GARRISON_RETREAT_SPEED * delta)
			unit["position"] = moved_at
			unit["moving"] = moved_at.distance_squared_to(at) > 0.02
			if absf(moved_at.x - at.x) > 0.01:
				unit["facing"] = signf(moved_at.x - at.x)
			var has_visible_rect := visible_world_rect.size.x > 0.0 and visible_world_rect.size.y > 0.0
			var exited_view := has_visible_rect and not visible_world_rect.grow(96.0).has_point(moved_at)
			var reached_target := moved_at.distance_squared_to(retreat_target) <= 4.0
			if exited_view or (not has_visible_rect and reached_target):
				# 只有越出当前可视区域（无相机数据时退到世界边界外）才释放展示
				# 数据，因此镜头内始终能看到连续的撤离动作。
				units.remove_at(unit_index)
				continue
			if reached_target:
				# 极宽镜头或玩家恰好紧追时继续沿同方向撤出，避免在可视范围内停住。
				var escape_direction := (retreat_target - at).normalized()
				unit["retreat_target"] = retreat_target + escape_direction * GARRISON_RETREAT_EXIT_OFFSET
			units[unit_index] = unit
			has_retreating_units = true
		node["garrison"] = units
		node["garrison_retreating"] = has_retreating_units
		progression_nodes[node_index] = node

func _release_garrison_residual(entry: Dictionary) -> void:
	if enemies == null:
		return
	var node_index := int(entry.get("node_index", -1))
	if node_index < 0 or node_index >= progression_nodes.size():
		return
	var node := progression_nodes[node_index]
	var units: Array = node.get("garrison", []) as Array
	var wanted_id := int(entry.get("garrison_id", -1))
	for unit_index in range(units.size()):
		var unit := units[unit_index] as Dictionary
		if int(unit.get("id", -1)) != wanted_id or bool(unit.get("residual_released", false)):
			continue
		var enemy_type := EnemySimulation.EnemyType.SHIELD
		match str(entry.get("kind", "shield")):
			"spear": enemy_type = EnemySimulation.EnemyType.SPEAR
			"archer": enemy_type = EnemySimulation.EnemyType.ARCHER
		var spawned_id := enemies.spawn(enemy_type, entry.get("position", Vector2.ZERO) as Vector2)
		if spawned_id < 0:
			return
		# 刚转入真实战斗的残军先保持向左的列阵朝向，下一次 AI 决策再自然
		# 转向各自目标，避免第一帧在原地突兀翻身。
		enemies.facing_directions[spawned_id] = Vector2.LEFT
		unit["residual_released"] = true
		units[unit_index] = unit
		node["garrison"] = units
		progression_nodes[node_index] = node
		targeting_changed.emit()
		return

func _wall_volley_is_active() -> bool:
	return phase == SiegePhase.FINAL_CHALLENGE

func _tick_wall_volley(delta: float, player_position: Vector2) -> void:
	if not _wall_volley_is_active():
		return
	volley_remaining = maxf(0.0, volley_remaining - delta)
	if volley_remaining > 0.0:
		return
	var final_volley := phase == SiegePhase.FINAL_CHALLENGE
	var volley_count := 4
	var impacts: Array = []
	var spacing := 52.0
	for index in range(volley_count):
		var lateral := (float(index) - float(volley_count - 1) * 0.5) * spacing
		var stagger := float((volley_serial + index) % 3 - 1) * 24.0
		impacts.append(player_position + Vector2(lateral, stagger))
	volley_serial += 1
	var origin := gate_position + Vector2(-24.0, -126.0)
	wall_volley_requested.emit(origin, impacts, final_volley)
	volley_remaining = FINAL_VOLLEY_INTERVAL

func _tick_arrow_tower_visuals(delta: float) -> void:
	for node_index in range(progression_nodes.size()):
		var node := progression_nodes[node_index]
		if not _node_uses_arrow_towers(node):
			continue
		var changed := false
		var towers: Array = node.get("towers", []) as Array
		for tower_index in range(towers.size()):
			var tower := towers[tower_index] as Dictionary
			var hurt_remaining := maxf(0.0, float(tower.get("hurt_remaining", 0.0)) - delta)
			var fire_remaining := maxf(0.0, float(tower.get("fire_remaining", 0.0)) - delta)
			var destroy_remaining := maxf(0.0, float(tower.get("destroy_remaining", 0.0)) - delta)
			if not is_equal_approx(hurt_remaining, float(tower.get("hurt_remaining", 0.0))) or not is_equal_approx(fire_remaining, float(tower.get("fire_remaining", 0.0))) or not is_equal_approx(destroy_remaining, float(tower.get("destroy_remaining", 0.0))):
				tower["hurt_remaining"] = hurt_remaining
				tower["fire_remaining"] = fire_remaining
				tower["destroy_remaining"] = destroy_remaining
				towers[tower_index] = tower
				changed = true
		if changed:
			node["towers"] = towers
			progression_nodes[node_index] = node

func _tick_garrison_fire_visual(delta: float) -> void:
	# 每次齐射只更新当前参与射击的 4 至 20 名弓手，而不是遍历整支
	# 守军。渲染端仍会对镜头外单位跳过贴图帧采样。
	for ref_index in range(garrison_firing_refs.size() - 1, -1, -1):
		var reference := garrison_firing_refs[ref_index]
		var node_index := int(reference.get("node_index", -1))
		var unit_index := int(reference.get("unit_index", -1))
		if node_index < 0 or node_index >= progression_nodes.size():
			garrison_firing_refs.remove_at(ref_index)
			continue
		var node := progression_nodes[node_index]
		var units: Array = node.get("garrison", []) as Array
		if unit_index < 0 or unit_index >= units.size():
			garrison_firing_refs.remove_at(ref_index)
			continue
		var unit := units[unit_index] as Dictionary
		var remaining := maxf(0.0, float(unit.get("fire_remaining", 0.0)) - delta)
		unit["fire_remaining"] = remaining
		units[unit_index] = unit
		node["garrison"] = units
		progression_nodes[node_index] = node
		if remaining <= 0.0:
			garrison_firing_refs.remove_at(ref_index)

func _tick_garrison_archers(delta: float, player_position: Vector2) -> void:
	# 一轮齐射以 10 列 × 5 行逐列推进。每列保持短促连续的节奏，使箭雨
	# 有明确的推进压迫感；下一层未被击破时，无论玩家距盾墙多远都持续施压。
	if not garrison_volley_columns.is_empty():
		garrison_volley_column_remaining = maxf(0.0, garrison_volley_column_remaining - delta)
		if garrison_volley_column_remaining <= 0.0:
			_emit_next_garrison_volley_column()
		return
	var node_index := _next_locked_node_index()
	if node_index < 0 or node_index >= progression_nodes.size():
		return
	var node := progression_nodes[node_index]
	if str(node.get("state", "locked")) == "cleared":
		return
	garrison_volley_remaining = maxf(0.0, garrison_volley_remaining - delta)
	if garrison_volley_remaining > 0.0:
		return
	_begin_garrison_volley(node_index, player_position)

func _begin_garrison_volley(node_index: int, player_position: Vector2) -> void:
	if node_index < 0 or node_index >= progression_nodes.size():
		return
	var node := progression_nodes[node_index]
	var units: Array = node.get("garrison", []) as Array
	var candidates: Array[int] = []
	for unit_index in range(units.size()):
		var unit := units[unit_index] as Dictionary
		if str(unit.get("kind", "")) != "archer":
			continue
		var at: Vector2 = unit.get("position", Vector2.ZERO)
		if absf(at.y - player_position.y) <= GARRISON_VOLLEY_SOURCE_LANE_RANGE:
			candidates.append(unit_index)
	if candidates.is_empty():
		garrison_volley_remaining = 1.0
		return
	garrison_volley_serial += 1
	var remaining_candidates := candidates.duplicate()
	for column in range(GARRISON_VOLLEY_COLUMNS):
		var shots: Array = []
		var impact_x := clampf(
			player_position.x + GARRISON_VOLLEY_FRONT_OFFSET - float(column) * GARRISON_VOLLEY_COLUMN_SPACING,
			world_bounds.position.x + 28.0,
			world_bounds.end.x - 28.0
		)
		for row in range(GARRISON_VOLLEY_ROWS):
			if remaining_candidates.is_empty():
				remaining_candidates = candidates.duplicate()
			var candidate_pick := garrison_rng.randi_range(0, remaining_candidates.size() - 1)
			var unit_index := int(remaining_candidates[candidate_pick])
			remaining_candidates.remove_at(candidate_pick)
			var archer := units[unit_index] as Dictionary
			var impact_y := clampf(
				player_position.y + (float(row) - float(GARRISON_VOLLEY_ROWS - 1) * 0.5) * GARRISON_VOLLEY_ROW_SPACING,
				world_bounds.position.y + 28.0,
				world_bounds.end.y - 28.0
			)
			shots.append({
				"node_index": node_index,
				"unit_index": unit_index,
				"volley_id": garrison_volley_serial,
				"column": column,
				"source_id": _garrison_source_id(node_index, int(archer.get("id", -1))),
				"origin": (archer.get("position", Vector2.ZERO) as Vector2) + Vector2(-6.0, -54.0),
				"impact": Vector2(impact_x, impact_y),
			})
		garrison_volley_columns.append(shots)
	# 计时从第一列开始算；扣除后续九列的推进时间，使下一轮仍约十秒到达。
	garrison_volley_remaining = GARRISON_VOLLEY_INTERVAL - float(GARRISON_VOLLEY_COLUMNS - 1) * GARRISON_VOLLEY_COLUMN_INTERVAL
	garrison_volley_column_remaining = 0.0
	_emit_next_garrison_volley_column()
	# 兵卒战损完全交给敌方锁定后的实际攻击结算，箭雨不再随机移除镜头内
	# 任意一名友军，避免没有命中关系的突兀死亡。

func _emit_next_garrison_volley_column() -> void:
	if garrison_volley_columns.is_empty():
		return
	var shots: Array = garrison_volley_columns.pop_front() as Array
	for shot_variant in shots:
		var shot := shot_variant as Dictionary
		_mark_garrison_volley_archer_firing(int(shot.get("node_index", -1)), int(shot.get("unit_index", -1)))
	garrison_volley_requested.emit(shots)
	garrison_volley_column_remaining = GARRISON_VOLLEY_COLUMN_INTERVAL if not garrison_volley_columns.is_empty() else 0.0

func _mark_garrison_volley_archer_firing(node_index: int, unit_index: int) -> void:
	if node_index < 0 or node_index >= progression_nodes.size():
		return
	var node := progression_nodes[node_index]
	var units: Array = node.get("garrison", []) as Array
	if unit_index < 0 or unit_index >= units.size():
		return
	var archer := units[unit_index] as Dictionary
	archer["fire_remaining"] = GARRISON_ARCHER_FIRE_DURATION
	units[unit_index] = archer
	node["garrison"] = units
	progression_nodes[node_index] = node
	garrison_firing_refs.append({"node_index": node_index, "unit_index": unit_index})

func _next_locked_node_index() -> int:
	for node_index in range(progression_nodes.size()):
		if str((progression_nodes[node_index] as Dictionary).get("state", "locked")) != "cleared":
			return node_index
	return -1

func _garrison_source_id(node_index: int, unit_id: int) -> int:
	return GARRISON_PROJECTILE_SOURCE_BASE - node_index * GARRISON_SOURCE_NODE_STRIDE - maxi(0, unit_id)

func _tick_arrow_tower_volley(delta: float, player_position: Vector2) -> void:
	if phase != SiegePhase.NODE_CHALLENGE or not _node_uses_arrow_towers(_active_node()):
		return
	for queue_index in range(arrow_tower_shot_queue.size()):
		var shot := arrow_tower_shot_queue[queue_index]
		shot["remaining"] = float(shot.get("remaining", 0.0)) - delta
		arrow_tower_shot_queue[queue_index] = shot
	while not arrow_tower_shot_queue.is_empty() and float(arrow_tower_shot_queue[0].get("remaining", 0.0)) <= 0.0:
		var shot: Dictionary = arrow_tower_shot_queue.pop_front() as Dictionary
		var tower_index := int(shot.get("tower_index", -1))
		var tower := _active_arrow_tower_by_id(tower_index)
		if tower.is_empty() or float(tower.get("health", 0.0)) <= 0.0:
			continue
		_mark_arrow_tower_fired(tower_index)
		arrow_tower_shot_requested.emit(tower_index, tower.get("arrow_origin", Vector2.ZERO) as Vector2, player_position)
	if not arrow_tower_shot_queue.is_empty():
		return
	arrow_tower_volley_remaining = maxf(0.0, arrow_tower_volley_remaining - delta)
	if arrow_tower_volley_remaining > 0.0:
		return
	var fire_order := _living_arrow_tower_ids()
	if fire_order.is_empty():
		return
	if volley_serial % 2 == 1:
		fire_order.reverse()
	# 每座箭楼连射两发。按轮次入队可保证 remaining 单调递增，
	# 让现有队头弹出逻辑稳定呈现“齐射后紧跟一轮追射”的压迫感。
	for shot_index in range(ARROW_TOWER_SHOTS_PER_VOLLEY):
		for order_index in range(fire_order.size()):
			arrow_tower_shot_queue.append({
				"tower_index": fire_order[order_index],
				"remaining": float(shot_index) * ARROW_TOWER_REPEAT_SHOT_DELAY + float(order_index) * ARROW_TOWER_SHOT_STAGGER,
			})
	volley_serial += 1
	arrow_tower_volley_remaining = ARROW_TOWER_VOLLEY_INTERVAL

func _active_arrow_tower_by_id(tower_id: int) -> Dictionary:
	var node := _active_node()
	if not _node_uses_arrow_towers(node):
		return {}
	for tower_variant in node.get("towers", []) as Array:
		var tower := tower_variant as Dictionary
		if int(tower.get("id", -1)) == tower_id:
			return tower
	return {}

func _living_arrow_tower_ids() -> Array[int]:
	var ids: Array[int] = []
	for tower_variant in _active_node().get("towers", []) as Array:
		var tower := tower_variant as Dictionary
		if float(tower.get("health", 0.0)) > 0.0:
			ids.append(int(tower.get("id", -1)))
	return ids

func _mark_arrow_tower_fired(tower_id: int) -> void:
	if active_node_index < 0 or active_node_index >= progression_nodes.size():
		return
	var node := progression_nodes[active_node_index]
	var towers: Array = node.get("towers", []) as Array
	for tower_index in range(towers.size()):
		var tower := towers[tower_index] as Dictionary
		if int(tower.get("id", -1)) != tower_id:
			continue
		tower["fire_remaining"] = ARROW_TOWER_FIRE_DURATION
		towers[tower_index] = tower
		node["towers"] = towers
		progression_nodes[active_node_index] = node
		return

func _apply_player_attack_to_arrow_towers(request: AttackRequest, combat: CombatSystem, base_attack: float) -> bool:
	if active_node_index < 0 or active_node_index >= progression_nodes.size():
		return false
	var node := progression_nodes[active_node_index]
	var towers: Array = node.get("towers", []) as Array
	for tower_index in range(towers.size()):
		var tower := towers[tower_index] as Dictionary
		if float(tower.get("health", 0.0)) <= 0.0:
			continue
		var target_position: Vector2 = tower.get("position", Vector2.ZERO)
		if not combat.request_hits_point(request, target_position):
			continue
		var multiplier := maxf(0.1, request.damage_multiplier_at(target_position))
		var damage := COMBAT_MATH.final_damage(base_attack, multiplier, 0.0, ARROW_TOWER_ARMOR, false, request.armor_ignore_ratio)
		tower["health"] = maxf(0.0, float(tower.get("health", 0.0)) - damage)
		tower["hurt_remaining"] = ARROW_TOWER_HURT_DURATION
		if float(tower.get("health", 0.0)) <= 0.0:
			tower["destroy_remaining"] = ARROW_TOWER_DESTROY_DURATION
		towers[tower_index] = tower
		node["towers"] = towers
		progression_nodes[active_node_index] = node
		arrow_tower_damaged.emit(target_position, damage, int(tower.get("id", tower_index)))
		if _living_arrow_tower_ids().is_empty():
			_resolve_arrow_tower_node(request.origin)
		return true
	return false

func _resolve_arrow_tower_node(player_position: Vector2 = Vector2.INF) -> void:
	if phase != SiegePhase.NODE_CHALLENGE or active_node_index < 0 or active_node_index >= progression_nodes.size():
		return
	var node := progression_nodes[active_node_index]
	if not _node_uses_arrow_towers(node):
		return
	node["state"] = "cleared"
	node["break_remaining"] = BARRIER_BREAK_VISUAL_DURATION
	progression_nodes[active_node_index] = node
	_queue_garrison_residuals(active_node_index, player_position)
	var title := str(node.get("title", "箭楼防线"))
	active_node_index = -1
	active_node_elite_id = -1
	phase = SiegePhase.DEFENSE
	arrow_tower_volley_remaining = INF
	arrow_tower_shot_queue.clear()
	message_requested.emit("%s已破 · 盾墙溃散，全军继续推进" % title)

func _spawn_finale_friendlies(player_position: Vector2) -> void:
	# 仅把新到的援军布置在英雄身后。已在场的友军不瞬移，仍从自己的
	# 当前位置赶往城下，避免“斩将后人群凭空贴门”的违和表现。
	var starting_count := friendly_units.size()
	_spawn_friendly_batch(mini(FINALE_FRIENDLY_COUNT - starting_count, FRIENDLY_FIELD_CAP - starting_count))
	var rally_position := player_position if player_position.is_finite() else gate_position - Vector2(FINALE_FRIENDLY_START_DISTANCE, 0.0)
	var start_x := clampf(rally_position.x - FINALE_FRIENDLY_START_DISTANCE, world_bounds.position.x + 148.0, gate_position.x - GATE_WIDTH * 0.5 - 190.0)
	for index in range(starting_count, friendly_units.size()):
		var unit := friendly_units[index]
		var lane := float((index - starting_count) % 9 - 4) * 34.0
		unit["position"] = Vector2(start_x - float((index - starting_count) % 3) * 28.0, clampf(rally_position.y + lane, world_bounds.position.y + 52.0, world_bounds.end.y - 52.0))
		unit["lane"] = clampf(float(unit.get("position", Vector2.ZERO).y) - world_bounds.get_center().y, -260.0, 260.0)
		unit["facing"] = 1.0
		unit["moving"] = true
		unit["attack_state"] = FriendlyAttackState.READY
		friendly_units[index] = unit

func deploy_hero_reinforcement(entry_position: Vector2) -> void:
	# 城下援军不再从左侧营地慢慢赶来，而是随援将自屏幕外切入最终战区。
	# 仍复用真实友军数据和上限，避免为单次演出增加独立的大规模 AI。
	if not active or phase != SiegePhase.FINAL_CHALLENGE:
		return
	var starting_count := friendly_units.size()
	var count := mini(10, FRIENDLY_FIELD_CAP - starting_count)
	_spawn_friendly_batch(count)
	for index in range(starting_count, friendly_units.size()):
		var unit := friendly_units[index]
		var formation_column := posmod(index - starting_count, 3)
		var formation_row := int((index - starting_count) / 3)
		var entry := entry_position + Vector2(-88.0 - float(formation_column) * 34.0, (float(formation_row) - 1.0) * 42.0)
		unit["position"] = _clamp_unit_position(entry, entry)
		unit["moving"] = true
		unit["facing"] = 1.0
		friendly_units[index] = unit
	message_requested.emit("援将率蜀军杀入城下！")

func _tick_finale_friendlies(delta: float) -> void:
	var destination_x := gate_position.x - GATE_WIDTH * 0.62
	for index in range(friendly_units.size()):
		var unit := friendly_units[index]
		var at: Vector2 = unit.get("position", Vector2.ZERO)
		var destination := Vector2(destination_x, world_bounds.get_center().y + float(unit.get("lane", 0.0)))
		var next_position := at.move_toward(destination, FINALE_FRIENDLY_MOVE_SPEED * delta)
		unit["position"] = next_position
		unit["facing"] = 1.0
		unit["moving"] = next_position.distance_squared_to(destination) > 4.0
		unit["attack_visual_remaining"] = 0.48 if next_position.distance_squared_to(destination) <= 1600.0 else 0.0
		friendly_units[index] = unit

func _tick_final_assault(delta: float) -> void:
	var destination_x := gate_position.x - GATE_WIDTH * 0.62
	var attackers := 0
	for unit_variant in friendly_units:
		var unit := unit_variant as Dictionary
		var at: Vector2 = unit.get("position", Vector2.ZERO)
		var lane_y := world_bounds.get_center().y + float(unit.get("lane", 0.0))
		if absf(at.x - destination_x) <= 20.0 and absf(at.y - lane_y) <= 20.0:
			attackers += 1
	if attackers <= 0:
		return
	gate_hit_flash = maxf(gate_hit_flash, 0.15)
	_damage_gate(float(attackers) * FINAL_FRIENDLY_GATE_DAMAGE_PER_SECOND * delta, false)

func _tick_reinforcements(delta: float) -> void:
	if reserves <= 0 or friendly_units.size() >= FRIENDLY_REINFORCEMENT_THRESHOLD:
		return
	reinforcement_timer = maxf(0.0, reinforcement_timer - delta)
	if reinforcement_timer > 0.0:
		return
	var available_slots := FRIENDLY_FIELD_CAP - friendly_units.size()
	var reinforcement_batch := FRIENDLY_REINFORCEMENT_BATCH + int(armory_effects.get("reinforcement_batch_bonus", 0))
	_spawn_friendly_batch(mini(reinforcement_batch, available_slots))
	reinforcement_timer = maxf(2.0, FRIENDLY_REINFORCEMENT_INTERVAL - float(armory_effects.get("reinforcement_interval_reduction", 0.0)))

func _spawn_friendly_batch(count: int) -> void:
	var spawn_count := mini(maxi(0, count), reserves)
	for index in range(spawn_count):
		friendly_serial += 1
		# 友军从左侧军营出发时，出生队列必须落在中间道路内；否则即使
		# 移动边界不再瞬移，也会产生一部分初始就位于下方营区的士兵。
		var lane := float((friendly_serial * 37) % 9 - 4) * FRIENDLY_CAMP_LANE_STEP
		var kind := friendly_serial % 3
		var maximum := _friendly_max_health()
		friendly_units.append({
			"id": friendly_serial,
			"position": Vector2(world_bounds.position.x + 116.0 + float(index % 3) * 26.0, world_bounds.get_center().y + lane),
			"health": maximum,
			"maximum": maximum,
			"cooldown": float(index) * 0.08,
			"kind": kind,
			"lane": lane,
			"flash": 0.0,
			"moving": false,
			"facing": 1.0,
			"attack_visual_remaining": 0.0,
			"attack_state": FriendlyAttackState.READY,
			"attack_state_remaining": 0.0,
			"attack_target_id": -1,
		})
	reserves -= spawn_count

func _tick_friendlies(delta: float) -> void:
	_prune_friendly_attack_assignments()
	for index in range(friendly_units.size() - 1, -1, -1):
		var unit: Dictionary = friendly_units[index]
		var at: Vector2 = unit.get("position", Vector2.ZERO)
		var movement_origin := at
		var facing := float(unit.get("facing", 1.0))
		var nearby_hostiles := _hostile_count_near(at, FRIENDLY_HOSTILE_RADIUS)
		unit["cooldown"] = maxf(0.0, float(unit.get("cooldown", 0.0)) - delta)
		unit["flash"] = maxf(0.0, float(unit.get("flash", 0.0)) - delta)
		unit["attack_visual_remaining"] = maxf(0.0, float(unit.get("attack_visual_remaining", 0.0)) - delta)
		var target := _friendly_target_for(unit, at)
		if not target.is_empty():
			var enemy_at: Vector2 = target.get("position", Vector2.ZERO)
			var offset := enemy_at - at
			if absf(offset.x) > 0.01:
				facing = signf(offset.x)
			if int(unit.get("attack_state", FriendlyAttackState.READY)) == FriendlyAttackState.READY:
				var target_slot: Vector2 = target.get("slot_position", enemy_at)
				if at.distance_squared_to(target_slot) > FRIENDLY_ATTACK_SLOT_SETTLE_DISTANCE * FRIENDLY_ATTACK_SLOT_SETTLE_DISTANCE:
					at = _move_friendly_toward(int(unit.get("id", -1)), at, target_slot, delta)
				elif at.distance_squared_to(enemy_at) <= FRIENDLY_ATTACK_RANGE * FRIENDLY_ATTACK_RANGE and float(unit.get("cooldown", 0.0)) <= 0.0:
					_begin_friendly_attack(unit, int(target.get("id", -1)))
		else:
			_release_friendly_attack_target(int(unit.get("id", -1)))
		if int(unit.get("attack_state", FriendlyAttackState.READY)) != FriendlyAttackState.READY:
			_tick_friendly_attack_state(unit, delta)
		if target.is_empty() and int(unit.get("attack_state", FriendlyAttackState.READY)) == FriendlyAttackState.READY:
			var rally_point := Vector2(gate_position.x - 160.0, world_bounds.get_center().y + float(unit.get("lane", 0.0)))
			var advance := rally_point - at
			if absf(advance.x) > 0.01:
				facing = signf(advance.x)
			if advance.length_squared() > 16.0:
				at = _move_friendly_toward(int(unit.get("id", -1)), at, rally_point, delta)
			elif gate_breach_remaining > 0.0:
				_damage_gate(FRIENDLY_GATE_DAMAGE_PER_SECOND * (1.0 + float(offense_stacks) * 0.08) * delta, false)
		# 主要伤害改由敌军真实选中后的攻击结算；这里只保留极轻的贴身挤压损耗，
		# 防止完全被包围却无任何危险感。
		var hostile_damage := float(nearby_hostiles) * 0.025 * delta * 100.0 / (100.0 + _friendly_defense())
		unit["health"] = float(unit.get("health", _friendly_max_health())) - hostile_damage
		unit["position"] = _clamp_unit_position(movement_origin, at)
		unit["moving"] = at.distance_squared_to(movement_origin) > 0.04
		unit["facing"] = facing
		if float(unit.get("health", 0.0)) <= 0.0:
			_release_targets_for(2, int(unit.get("id", -1)))
			_release_friendly_attack_target(int(unit.get("id", -1)))
			_record_friendly_corpse(unit)
			friendly_units.remove_at(index)
			targeting_changed.emit()
		else:
			friendly_units[index] = unit

func _friendly_target_for(unit: Dictionary, origin: Vector2) -> Dictionary:
	if enemies == null:
		return {}
	var unit_id := int(unit.get("id", -1))
	var assignment: Dictionary = friendly_attack_assignments.get(unit_id, {}) as Dictionary
	var assigned_enemy_id := int(assignment.get("enemy_id", -1))
	if assigned_enemy_id >= 0 and enemies.is_active(assigned_enemy_id):
		var assigned_enemy_at := enemies.positions[assigned_enemy_id]
		if origin.distance_squared_to(assigned_enemy_at) <= FRIENDLY_TARGET_RELEASE_RADIUS * FRIENDLY_TARGET_RELEASE_RADIUS:
			return {
				"id": assigned_enemy_id,
				"position": assigned_enemy_at,
				"slot_position": assigned_enemy_at + _friendly_attack_slot_offset(int(assignment.get("slot", 0))),
			}
	_release_friendly_attack_target(unit_id)
	var best_enemy_id := -1
	var best_score := INF
	for enemy_id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(enemy_id):
			continue
		var enemy_at := enemies.positions[enemy_id]
		var distance := origin.distance_to(enemy_at)
		if distance > FRIENDLY_HOSTILE_RADIUS:
			continue
		var assigned_count := _friendly_attack_count_for_enemy(enemy_id)
		var overload_penalty := FRIENDLY_TARGET_OVERLOAD_PENALTY if assigned_count >= FRIENDLY_TARGET_ATTACKER_CAP else 0.0
		var score := distance + float(assigned_count) * FRIENDLY_TARGET_LOAD_PENALTY + overload_penalty
		if score >= best_score:
			continue
		best_score = score
		best_enemy_id = enemy_id
	if best_enemy_id < 0:
		return {}
	var slot := _claim_friendly_attack_slot(unit_id, best_enemy_id)
	var target_position := enemies.positions[best_enemy_id]
	return {
		"id": best_enemy_id,
		"position": target_position,
		"slot_position": target_position + _friendly_attack_slot_offset(slot),
	}

func _friendly_attack_count_for_enemy(enemy_id: int) -> int:
	var count := 0
	for assignment_variant in friendly_attack_assignments.values():
		var assignment := assignment_variant as Dictionary
		if int(assignment.get("enemy_id", -1)) == enemy_id:
			count += 1
	return count

func _claim_friendly_attack_slot(unit_id: int, enemy_id: int) -> int:
	var used_slots: Dictionary = {}
	for assigned_unit_id_variant in friendly_attack_assignments:
		var assigned_unit_id := int(assigned_unit_id_variant)
		if assigned_unit_id == unit_id:
			continue
		var assignment: Dictionary = friendly_attack_assignments.get(assigned_unit_id, {}) as Dictionary
		if int(assignment.get("enemy_id", -1)) == enemy_id:
			used_slots[int(assignment.get("slot", 0))] = true
	var preferred_slot := posmod(unit_id * 3 + enemy_id, FRIENDLY_ATTACK_SLOT_COUNT)
	var selected_slot := preferred_slot
	for offset in range(FRIENDLY_ATTACK_SLOT_COUNT):
		var candidate_slot := posmod(preferred_slot + offset, FRIENDLY_ATTACK_SLOT_COUNT)
		if not used_slots.has(candidate_slot):
			selected_slot = candidate_slot
			break
	friendly_attack_assignments[unit_id] = {"enemy_id": enemy_id, "slot": selected_slot}
	return selected_slot

func _release_friendly_attack_target(unit_id: int) -> void:
	if unit_id >= 0:
		friendly_attack_assignments.erase(unit_id)

func _prune_friendly_attack_assignments() -> void:
	var active_unit_ids: Dictionary = {}
	for unit_variant in friendly_units:
		active_unit_ids[int((unit_variant as Dictionary).get("id", -1))] = true
	var stale_unit_ids: Array[int] = []
	for unit_id_variant in friendly_attack_assignments:
		var unit_id := int(unit_id_variant)
		var assignment: Dictionary = friendly_attack_assignments.get(unit_id, {}) as Dictionary
		var enemy_id := int(assignment.get("enemy_id", -1))
		if not active_unit_ids.has(unit_id) or enemies == null or not enemies.is_active(enemy_id):
			stale_unit_ids.append(unit_id)
	for unit_id in stale_unit_ids:
		friendly_attack_assignments.erase(unit_id)

func _friendly_attack_slot_offset(slot: int) -> Vector2:
	match posmod(slot, FRIENDLY_ATTACK_SLOT_COUNT):
		0: return Vector2(-54.0, 0.0)
		1: return Vector2(-40.0, -36.0)
		2: return Vector2(-40.0, 36.0)
		3: return Vector2(-12.0, -52.0)
		_: return Vector2(-12.0, 52.0)

func _move_friendly_toward(unit_id: int, origin: Vector2, destination: Vector2, delta: float) -> Vector2:
	var desired_velocity := (destination - origin).limit_length(FRIENDLY_MOVE_SPEED)
	var separation_velocity := Vector2.ZERO
	for other_variant in friendly_units:
		var other := other_variant as Dictionary
		if int(other.get("id", -1)) == unit_id:
			continue
		var other_at: Vector2 = other.get("position", Vector2.ZERO)
		var away := origin - other_at
		var distance := away.length()
		if distance >= FRIENDLY_SEPARATION_RADIUS:
			continue
		if distance <= 0.01:
			away = Vector2(-1.0, -0.45) if posmod(unit_id, 2) == 0 else Vector2(1.0, 0.45)
			distance = 1.0
		separation_velocity += away.normalized() * (1.0 - distance / FRIENDLY_SEPARATION_RADIUS) * FRIENDLY_SEPARATION_STRENGTH
	var velocity := desired_velocity + separation_velocity.limit_length(FRIENDLY_SEPARATION_STRENGTH)
	return origin + velocity.limit_length(FRIENDLY_MOVE_SPEED) * delta

func _begin_friendly_attack(unit: Dictionary, target_enemy_id: int) -> void:
	if target_enemy_id < 0:
		return
	var is_spear := int(unit.get("kind", 0)) == 1
	unit["attack_state"] = FriendlyAttackState.WINDUP
	unit["attack_state_remaining"] = FRIENDLY_SPEAR_WINDUP if is_spear else FRIENDLY_KNIFE_WINDUP
	unit["attack_target_id"] = target_enemy_id
	unit["attack_visual_remaining"] = FRIENDLY_SPEAR_ATTACK_VISUAL_DURATION if is_spear else FRIENDLY_KNIFE_ATTACK_VISUAL_DURATION

func _tick_friendly_attack_state(unit: Dictionary, delta: float) -> void:
	var state := int(unit.get("attack_state", FriendlyAttackState.READY))
	var remaining := maxf(0.0, float(unit.get("attack_state_remaining", 0.0)) - delta)
	if state == FriendlyAttackState.WINDUP and remaining <= 0.0:
		var target_enemy_id := int(unit.get("attack_target_id", -1))
		var at: Vector2 = unit.get("position", Vector2.ZERO)
		if enemies != null and target_enemy_id >= 0 and enemies.is_active(target_enemy_id) and at.distance_squared_to(enemies.positions[target_enemy_id]) <= FRIENDLY_ATTACK_RANGE * FRIENDLY_ATTACK_RANGE * 1.44:
			var attack_multiplier := 1.0 + float(offense_stacks) * 0.08
			# 敌我杂兵对砍只结算生命和轻量闪白：不击退、不硬直，
			# 但伤害现在在前摇结束的命中帧结算，和画面保持一致。
			enemies.apply_siege_friendly_damage(target_enemy_id, _friendly_attack_damage() * attack_multiplier)
			unit["flash"] = 0.13
		unit["attack_state"] = FriendlyAttackState.RECOVERY
		unit["attack_state_remaining"] = _friendly_attack_recovery(unit)
		return
	if state == FriendlyAttackState.RECOVERY and remaining <= 0.0:
		unit["attack_state"] = FriendlyAttackState.READY
		unit["attack_state_remaining"] = 0.0
		unit["attack_target_id"] = -1
		unit["cooldown"] = maxf(0.0, _friendly_attack_interval(unit) - _friendly_attack_windup(unit) - _friendly_attack_recovery(unit))
		return
	unit["attack_state_remaining"] = remaining

func _friendly_attack_interval(unit: Dictionary) -> float:
	return FRIENDLY_SPEAR_ATTACK_INTERVAL if int(unit.get("kind", 0)) == 1 else FRIENDLY_KNIFE_ATTACK_INTERVAL

func _friendly_attack_windup(unit: Dictionary) -> float:
	return FRIENDLY_SPEAR_WINDUP if int(unit.get("kind", 0)) == 1 else FRIENDLY_KNIFE_WINDUP

func _friendly_attack_recovery(unit: Dictionary) -> float:
	return FRIENDLY_SPEAR_RECOVERY if int(unit.get("kind", 0)) == 1 else FRIENDLY_KNIFE_RECOVERY

func _friendly_max_health() -> float:
	return FRIENDLY_MAX_HEALTH + float(armory_effects.get("friendly_health_bonus", 0.0))

func _friendly_attack_damage() -> float:
	return FRIENDLY_ATTACK_DAMAGE + float(armory_effects.get("friendly_attack_bonus", 0.0))

func _friendly_defense() -> float:
	return FRIENDLY_BASE_DEFENSE + float(armory_effects.get("friendly_defense_bonus", 0.0))

func _ram_max_health() -> float:
	return RAM_MAX_HEALTH * (1.0 + float(armory_effects.get("ram_health_ratio", 0.0)))

func _ram_defense() -> float:
	return RAM_BASE_DEFENSE + float(armory_effects.get("ram_defense_bonus", 0.0))

func _record_friendly_corpse(unit: Dictionary) -> void:
	friendly_corpses.append({
		"position": unit.get("position", Vector2.ZERO),
		"kind": int(unit.get("kind", 0)),
		"facing": float(unit.get("facing", 1.0)),
		"elapsed": 0.0,
	})
	if friendly_corpses.size() > FRIENDLY_CORPSE_LIMIT:
		friendly_corpses.pop_front()

func _tick_friendly_corpses(delta: float) -> void:
	for index in range(friendly_corpses.size() - 1, -1, -1):
		var corpse: Dictionary = friendly_corpses[index]
		corpse["elapsed"] = float(corpse.get("elapsed", 0.0)) + delta
		if float(corpse.get("elapsed", 0.0)) >= FRIENDLY_CORPSE_DURATION:
			friendly_corpses.remove_at(index)
		else:
			friendly_corpses[index] = corpse

func _tick_ram(delta: float) -> void:
	if phase not in [SiegePhase.COUNTERATTACK, SiegePhase.GATE_ASSAULT]:
		# 分层推进模式不再把攻城锤作为护送目标；它只在最终总攻演出中由友军替代。
		return
	if ram_state == RamState.INACTIVE or ram_state == RamState.REBUILDING:
		if phase == SiegePhase.GATE_ASSAULT:
			return
		ram_deployment_remaining = maxf(0.0, ram_deployment_remaining - delta)
		if ram_deployment_remaining <= 0.0:
			_deploy_ram()
		return
	var nearby_hostiles := _hostile_count_near(ram_position, RAM_DANGER_RADIUS)
	if nearby_hostiles > 0:
		ram_health -= float(nearby_hostiles) * 0.12 * (1.0 + float(defense_stacks) * 0.18) * delta
	if ram_health <= 0.0:
		_destroy_ram()
		return
	# 攻城锤可驶入中央门道，但以“锤头接触城门左门面”为唯一到达条件。
	# 过去这里混用了可通行城墙边界与门扉位置，导致工程车视觉上已到门前，
	# 实际却永远停在行军阈值，因而无法触发撞门。
	var gate_front_x := gate_position.x - GATE_WIDTH * 0.5
	var ram_contact_x := gate_front_x - RAM_HAMMER_OFFSET_X - RAM_HAMMER_CLEARANCE
	if ram_position.x < ram_contact_x:
		# 守军可在中途拖慢工程车，但不允许把它永久堵死在门前。进入最后一段
		# 门道后工程车会顶着人群完成贴门，保证攻击状态一定可以触发。
		var final_approach := ram_contact_x - ram_position.x <= RAM_FINAL_APPROACH_DISTANCE
		var blocked := nearby_hostiles >= RAM_BLOCKED_ENEMY_COUNT and not final_approach
		ram_state = RamState.BLOCKED if blocked else RamState.MARCHING
		var speed_multiplier := RAM_BLOCKED_SPEED_MULTIPLIER if blocked else 1.0
		var armory_speed_multiplier := 1.0 + float(armory_effects.get("ram_speed_ratio", 0.0))
		ram_position.x = minf(ram_contact_x, ram_position.x + RAM_MOVE_SPEED * armory_speed_multiplier * speed_multiplier * delta)
		return
	if ram_state != RamState.ATTACKING:
		ram_state = RamState.ATTACKING
		ram_position.x = ram_contact_x
		if phase == SiegePhase.COUNTERATTACK:
			phase = SiegePhase.GATE_ASSAULT
			gate_assault_remaining = GATE_ASSAULT_DURATION
			gate_assault_started.emit(GATE_ASSAULT_DURATION)
			message_requested.emit("大军抵达城下 · %d 秒攻城窗口开始" % int(GATE_ASSAULT_DURATION))
	ram_attack_remaining = maxf(0.0, ram_attack_remaining - delta)
	if ram_attack_remaining > 0.0:
		return
	var siege_multiplier := 1.0 + float(offense_stacks) * 0.08
	var armory_damage_multiplier := 1.0 + float(armory_effects.get("ram_damage_ratio", 0.0))
	_damage_gate(RAM_GATE_DAMAGE * siege_multiplier * armory_damage_multiplier, true)
	ram_attack_remaining = RAM_ATTACK_INTERVAL
	ram_hit_flash = 0.34
	offense_stacks = mini(OFFENSE_MAX_STACKS, offense_stacks + 1)
	offense_remaining = OFFENSE_DURATION
	message_requested.emit("攻城锤撞击城门 · %s" % offense_status_label())

func _deploy_ram() -> void:
	ram_state = RamState.MARCHING
	ram_position = Vector2(world_bounds.position.x + 146.0, world_bounds.get_center().y)
	ram_health = _ram_max_health()
	ram_attack_remaining = 0.0
	_release_targets_for(1, 0)
	targeting_changed.emit()
	message_requested.emit("攻城锤出阵 · 护送其攻破城门")

func _destroy_ram() -> void:
	ram_state = RamState.REBUILDING
	ram_health = 0.0
	ram_deployment_remaining = RAM_REBUILD_DELAY
	_release_targets_for(1, 0)
	targeting_changed.emit()
	defense_stacks = mini(DEFENSE_MAX_STACKS, defense_stacks + 1)
	if enemies != null:
		enemies.set_siege_morale(defense_stacks)
	message_requested.emit("攻城锤被毁 · 敌军%s" % defense_status_label())

func _resume_enemy_offense() -> void:
	if phase != SiegePhase.GATE_ASSAULT:
		return
	phase = SiegePhase.DEFENSE
	gate_assault_remaining = 0.0
	# 首版不设置前进营寨。攻城窗口结束后，攻城部队撤出战场，左侧仍保持
	# 固定的出兵方向；下一次击杀敌将才会重新组织一次反攻。
	friendly_units.clear()
	friendly_attack_assignments.clear()
	_release_targets_for(1, 0)
	ram_state = RamState.INACTIVE
	ram_health = 0.0
	ram_attack_remaining = 0.0
	ram_deployment_remaining = FIRST_RAM_DEPLOYMENT_DELAY
	targeting_changed.emit()
	defense_resumed.emit()
	message_requested.emit("攻城窗口结束 · 敌军恢复进攻")

func _damage_gate(value: float, caused_by_ram: bool) -> void:
	if value <= 0.0 or gate_has_fallen:
		return
	gate_durability = maxf(0.0, gate_durability - value)
	gate_hit_flash = 0.20 if caused_by_ram else 0.08
	if caused_by_ram:
		gate_breach_remaining = GATE_BREACH_DURATION
	if gate_durability > 0.0:
		return
	gate_has_fallen = true
	message_requested.emit("城门已破 · 全军入城")
	gate_destroyed.emit()

func _nearest_enemy(origin: Vector2, radius: float) -> int:
	if enemies == null:
		return -1
	var best_id := -1
	var best_distance := radius * radius
	for enemy_id in range(EnemySimulation.CAPACITY):
		if not enemies.is_active(enemy_id):
			continue
		var distance := origin.distance_squared_to(enemies.positions[enemy_id])
		if distance < best_distance:
			best_id = enemy_id
			best_distance = distance
	return best_id

func _hostile_count_near(origin: Vector2, radius: float) -> int:
	if enemies == null:
		return 0
	return enemies.count_active_within(origin, radius)

func _clamp_unit_position(origin: Vector2, candidate: Vector2) -> Vector2:
	var result := clamp_to_wall_front(origin, candidate, WALL_FRONTLINE_CLEARANCE)
	result.x = maxf(world_bounds.position.x + 24.0, result.x)
	return result

func _best_friendly_target(origin: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_score := INF
	for unit_variant in friendly_units:
		var unit := unit_variant as Dictionary
		var unit_position: Vector2 = unit.get("position", Vector2.ZERO)
		var distance := origin.distance_to(unit_position)
		if distance > ENEMY_FRIENDLY_TARGET_RADIUS:
			continue
		var unit_id := int(unit.get("id", -1))
		var assigned_count := int(friendly_defender_counts.get(unit_id, 0))
		# 先照顾尚未被拦截的友军，再在同等压力下选择最近目标；容量用
		# 较高惩罚而非硬拒绝，避免战场末段仅剩少数士兵时守军停摆。
		var overload_penalty := maxf(0.0, float(assigned_count - FRIENDLY_DEFENDER_CAP + 1)) * FRIENDLY_TARGET_SPREAD_DISTANCE * 2.0
		var score := distance + float(assigned_count) * FRIENDLY_TARGET_SPREAD_DISTANCE + overload_penalty
		if score >= best_score:
			continue
		best_score = score
		best = {"kind": 2, "id": unit_id, "position": unit_position}
	for unit_variant in battlefield_friendly_units:
		var battlefield_unit := unit_variant as Dictionary
		var battlefield_position: Vector2 = battlefield_unit.get("position", Vector2.ZERO)
		var battlefield_distance := origin.distance_to(battlefield_position)
		if battlefield_distance > ENEMY_FRIENDLY_TARGET_RADIUS:
			continue
		var battlefield_unit_id := int(battlefield_unit.get("id", -1))
		var battlefield_assigned_count := int(friendly_defender_counts.get(battlefield_unit_id, 0))
		var battlefield_overload_penalty := maxf(0.0, float(battlefield_assigned_count - FRIENDLY_DEFENDER_CAP + 1)) * FRIENDLY_TARGET_SPREAD_DISTANCE * 2.0
		var battlefield_score := battlefield_distance + float(battlefield_assigned_count) * FRIENDLY_TARGET_SPREAD_DISTANCE + battlefield_overload_penalty
		if battlefield_score >= best_score:
			continue
		best_score = battlefield_score
		best = {"kind": 2, "id": battlefield_unit_id, "position": battlefield_position}
	return best

func _is_ranged_defender(enemy_type: int) -> bool:
	return enemy_type in [EnemySimulation.EnemyType.ARCHER, EnemySimulation.EnemyType.CROSSBOW]

func _should_intercept_ram(enemy_id: int, enemy_position: Vector2, enemy_type: int, ram_distance: float) -> bool:
	if ram_distance <= RAM_INTERCEPT_RADIUS:
		# 进入工程车身边的拦截区后，所有守军都有责任停下拦车；若名额已满，
		# 更靠近的路过单位可以替换远处的旧拆车者。
		return _try_claim_ram_assault_slot(enemy_id, enemy_position, enemy_type, true)
	if ram_distance <= RAM_APPROACH_RADIUS and _is_ram_assault_candidate(enemy_id, enemy_type):
		return _try_claim_ram_assault_slot(enemy_id, enemy_position, enemy_type, false)
	return false

func _is_ram_assault_candidate(enemy_id: int, enemy_type: int) -> bool:
	var threshold := 22
	if enemy_type in [EnemySimulation.EnemyType.SHIELD, EnemySimulation.EnemyType.HALBERD]:
		threshold = 58
	elif enemy_type in [EnemySimulation.EnemyType.SPEAR, EnemySimulation.EnemyType.CAVALRY]:
		threshold = 36
	elif _is_ranged_defender(enemy_type):
		threshold = 18
	return posmod(enemy_id * 71 + enemy_type * 31, 100) < threshold

func _has_ram_assault_capacity(enemy_type: int) -> bool:
	return ram_ranged_defender_count < RAM_RANGED_ASSAULT_CAP if _is_ranged_defender(enemy_type) else ram_melee_defender_count < RAM_MELEE_ASSAULT_CAP

func _try_claim_ram_assault_slot(enemy_id: int, enemy_position: Vector2, enemy_type: int, allow_nearest_replacement: bool) -> bool:
	if _has_ram_assault_capacity(enemy_type):
		return true
	if not allow_nearest_replacement:
		return false
	var candidate_distance := enemy_position.distance_to(ram_position)
	var furthest_id := _furthest_ram_assault_enemy_id(_is_ranged_defender(enemy_type))
	if furthest_id < 0 or enemies == null:
		return false
	var furthest_distance := enemies.positions[furthest_id].distance_to(ram_position)
	if candidate_distance + RAM_INTERCEPT_REPLACEMENT_MARGIN >= furthest_distance:
		return false
	_release_defender_target(furthest_id)
	targeting_changed.emit()
	return true

func _furthest_ram_assault_enemy_id(ranged: bool) -> int:
	if enemies == null:
		return -1
	var furthest_id := -1
	var furthest_distance := -INF
	for enemy_id_variant in defender_target_assignments:
		var enemy_id := int(enemy_id_variant)
		var assignment: Dictionary = defender_target_assignments.get(enemy_id, {}) as Dictionary
		if int(assignment.get("kind", -1)) != 1 or bool(assignment.get("ranged", false)) != ranged or not enemies.is_active(enemy_id):
			continue
		var distance := enemies.positions[enemy_id].distance_to(ram_position)
		if distance > furthest_distance:
			furthest_distance = distance
			furthest_id = enemy_id
	return furthest_id

func _assign_defender_target(enemy_id: int, target_kind: int, target_id: int, enemy_type: int) -> void:
	defender_target_assignments[enemy_id] = {"kind": target_kind, "id": target_id, "ranged": _is_ranged_defender(enemy_type)}
	if target_kind == 1:
		if _is_ranged_defender(enemy_type):
			ram_ranged_defender_count += 1
		else:
			ram_melee_defender_count += 1
	elif target_kind == 2:
		friendly_defender_counts[target_id] = int(friendly_defender_counts.get(target_id, 0)) + 1

func _has_defender_target(enemy_id: int, target_kind: int, target_id: int) -> bool:
	if not defender_target_assignments.has(enemy_id):
		return false
	var assignment: Dictionary = defender_target_assignments.get(enemy_id, {}) as Dictionary
	return int(assignment.get("kind", -1)) == target_kind and int(assignment.get("id", -1)) == target_id

func _release_defender_target(enemy_id: int) -> void:
	if not defender_target_assignments.has(enemy_id):
		return
	var assignment: Dictionary = defender_target_assignments.get(enemy_id, {}) as Dictionary
	defender_target_assignments.erase(enemy_id)
	var target_kind := int(assignment.get("kind", -1))
	var target_id := int(assignment.get("id", -1))
	if target_kind == 1:
		if bool(assignment.get("ranged", false)):
			ram_ranged_defender_count = maxi(0, ram_ranged_defender_count - 1)
		else:
			ram_melee_defender_count = maxi(0, ram_melee_defender_count - 1)
	elif target_kind == 2:
		var count := maxi(0, int(friendly_defender_counts.get(target_id, 0)) - 1)
		if count <= 0:
			friendly_defender_counts.erase(target_id)
		else:
			friendly_defender_counts[target_id] = count

func _release_targets_for(target_kind: int, target_id: int) -> void:
	var release_ids: Array[int] = []
	for enemy_id_variant in defender_target_assignments:
		var enemy_id := int(enemy_id_variant)
		var assignment: Dictionary = defender_target_assignments.get(enemy_id, {}) as Dictionary
		if int(assignment.get("kind", -1)) == target_kind and int(assignment.get("id", -1)) == target_id:
			release_ids.append(enemy_id)
	for enemy_id in release_ids:
		_release_defender_target(enemy_id)

func _friendly_target_exists(target_id: int) -> bool:
	for unit_variant in friendly_units:
		if int((unit_variant as Dictionary).get("id", -1)) == target_id:
			return true
	for unit_variant in battlefield_friendly_units:
		if int((unit_variant as Dictionary).get("id", -1)) == target_id:
			return true
	return false

func _prune_defender_target_assignments() -> void:
	var release_ids: Array[int] = []
	for enemy_id_variant in defender_target_assignments:
		var enemy_id := int(enemy_id_variant)
		var assignment: Dictionary = defender_target_assignments.get(enemy_id, {}) as Dictionary
		var target_kind := int(assignment.get("kind", -1))
		var target_id := int(assignment.get("id", -1))
		var ram_target_out_of_range := target_kind == 1 and (not ram_is_active() or enemies == null or enemies.positions[enemy_id].distance_to(ram_position) > RAM_INTERCEPT_RELEASE_RADIUS)
		if enemies == null or not enemies.is_active(enemy_id) or ram_target_out_of_range or (target_kind == 2 and not _friendly_target_exists(target_id)):
			release_ids.append(enemy_id)
	for enemy_id in release_ids:
		_release_defender_target(enemy_id)
	if not release_ids.is_empty():
		targeting_changed.emit()
