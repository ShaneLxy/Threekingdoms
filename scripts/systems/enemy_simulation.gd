class_name EnemySimulation
extends Node

const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")

signal enemy_died(enemy_id: int, enemy_type: int, at: Vector2, experience: int, ultimate_energy: float)
signal enemy_attack_requested(enemy_id: int, origin: Vector2, target: Vector2, enemy_type: int, damage: float, windup: float, attack_kind: String)
signal enemy_attack_cancelled(enemy_id: int)
signal enemy_death_collision(at: Vector2, direction: Vector2)
signal banner_command_requested(enemy_id: int, at: Vector2)
signal named_formation_broken(formation_id: String)
signal named_formation_gate_changed(at: Vector2)
signal named_formation_break_opened(formation_id: String)
signal iron_bucket_entered(at: Vector2)
signal iron_bucket_collapsed(at: Vector2)

enum EnemyType { SWORD, HALBERD, ARCHER, SHIELD, ELITE, GUARD, SPEAR, CROSSBOW, BANNER, CAVALRY }
enum AttackState { APPROACH, WINDUP, RECOVER }
enum DeathState { NONE, FALLING, LAUNCHED }
enum EngagementLayer { ENGAGE, PRESSURE, ATMOSPHERE }
enum DuelRole { NONE, SHIELD_RING, SPEAR_RING, RANGED_RING }
enum DuelPhase { NONE, ASSEMBLING, SEALED }
enum NamedFormationRole { FRONT, SPEAR, RANGED, FLANK, RESERVE, SHIELD_WALL, CAVALRY_CHANNEL }

const DUEL_WALL_SIDE_LEFT := 0
const DUEL_WALL_SIDE_RIGHT := 1
const DUEL_WALL_SIDE_TOP := 2
const DUEL_WALL_SIDE_BOTTOM := 3

const CAPACITY := 400
const MAX_DEATH_RECORDS := 160
const DEATH_DISPLAY_DURATION := 0.72
const DEATH_ANIMATION_DURATION := 0.45
const DEATH_FADE_DELAY := 0.42
const DEATH_LAUNCH_CHANCE := 0.20
const DEATH_LAUNCH_SPEED := 980.0
const DEATH_LAUNCH_DECELERATION := 2600.0
const DEATH_COLLISION_DAMAGE := 5.0
const DEATH_COLLISION_KNOCKBACK := 520.0
const DEATH_COLLISION_RADIUS := 25.0
const DEATH_COLLISION_MAX_TARGETS := 2
const LAUNCH_COLLISION_RADIUS := 29.0
const LAUNCH_DECELERATION := 2100.0
const LAUNCH_MIN_SPEED := 170.0
const FORMATION_SQUAD_SIZE := 6
const FORMATION_SLOT_ANGLE_STEP := 0.0959931
const FORMATION_SECTOR_ANGLES := [-PI * 0.5, PI, 0.0]
const FORMATION_ARRIVAL_DISTANCE := 10.0
const NAMED_FORMATION_DURATION := 60.0
const NAMED_FORMATION_BREAK_WINDOW := 15.0
const NAMED_FORMATION_MIN_MEMBERS := 40
const NAMED_FORMATION_BREAK_REQUIRED := 8
const NAMED_FORMATION_ASSEMBLY_DURATION := 7.0
const NAMED_FORMATION_SLOT_CAPACITY := CAPACITY
const NAMED_FORMATION_SHIELD_DAMAGE_MULTIPLIER := 0.24
const NAMED_FORMATION_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER := 0.42
const NAMED_FORMATION_SHIELD_PUSH_RADIUS := 72.0
const BAGUA_GATE_ROTATE_INTERVAL := 3.6
# 铁桶阵已从玩法中下线。保留旧数据结构仅用于兼容已有存档与测试入口，运行时不会创建或更新阵型。
const IRON_BUCKET_ENABLED := false
const IRON_BUCKET_MAX_FORMATIONS := 3
const IRON_BUCKET_MIN_MEMBERS := 16
const IRON_BUCKET_MAX_MEMBERS := 24
const IRON_BUCKET_MIN_SHIELDS := 7
const IRON_BUCKET_MIN_INTERIOR_MEMBERS := 6
const IRON_BUCKET_SHIELD_RATIO := 0.42
const IRON_BUCKET_MIN_RADIUS := 92.0
const IRON_BUCKET_MAX_RADIUS := 116.0
const IRON_BUCKET_FORMATION_CLEARANCE := 96.0
const IRON_BUCKET_GAP_MIN_WIDTH := 0.82
const IRON_BUCKET_GAP_MAX_WIDTH := 1.18
const IRON_BUCKET_ROTATION_SPEED_MIN := 0.30
const IRON_BUCKET_ROTATION_SPEED_MAX := 0.54
const IRON_BUCKET_DRIFT_SPEED_MIN := 22.0
const IRON_BUCKET_DRIFT_SPEED_MAX := 42.0
const IRON_BUCKET_ASSEMBLY_DURATION := 2.8
const IRON_BUCKET_LIFETIME := 48.0
const IRON_BUCKET_RECRUIT_RADIUS := 250.0
const IRON_BUCKET_REINFORCE_RADIUS := 380.0
const IRON_BUCKET_MIN_SHIELDS_CRITICAL := 5
const IRON_BUCKET_REINFORCE_COOLDOWN := 2.0
const IRON_BUCKET_SHIELD_PUSH_RADIUS := 52.0
const IRON_BUCKET_SHIELDS_PER_FORMATION := 10
const IRON_BUCKET_INTERIOR_PER_FORMATION := 12
const IRON_BUCKET_OFFSCREEN_MARGIN := 220.0
const IRON_BUCKET_MARCH_SPEED := 120.0
const IRON_BUCKET_OUTSIDE_DAMAGE_MULTIPLIER := 0.01
const IRON_BUCKET_INSIDE_DAMAGE_MULTIPLIER := 0.28
const IRON_BUCKET_ASSEMBLING_DAMAGE_MULTIPLIER := 0.50
const IRON_BUCKET_ASSEMBLY_SPEED_BOOST := 2.5
const IRON_BUCKET_DRIFT_TRACKING_SPEED := 35.0
const IRON_BUCKET_DRIFT_KEEP_DISTANCE := 180.0
const IRON_BUCKET_DRIFT_UPDATE_INTERVAL := 1.5
const IRON_BUCKET_OUTER_RING_MIN := 0.85
const IRON_BUCKET_OUTER_RING_MAX := 1.15
const IRON_BUCKET_INNER_RING_MIN := 0.25
const IRON_BUCKET_INNER_RING_MAX := 0.75
const IRON_BUCKET_GAP_THRESHOLD := 90.0
const ATTACK_KIND_DEFAULT := "default"
const ATTACK_KIND_ARCHER_DIRECT := "archer_direct"
const ATTACK_KIND_ARCHER_LEAD := "archer_lead"
const ATTACK_KIND_ARCHER_VOLLEY := "archer_volley"
const ATTACK_KIND_HALBERD_SWEEP := "halberd_sweep"
const ATTACK_KIND_HALBERD_BRACE := "halberd_brace"
const ATTACK_KIND_SPEAR_THRUST_1 := "spear_thrust_1"
const ATTACK_KIND_SPEAR_THRUST_2 := "spear_thrust_2"
const ATTACK_KIND_SPEAR_FORMATION := "spear_formation"
const ATTACK_KIND_DUEL_SPEAR_THRUST := "duel_spear_thrust"
const ATTACK_KIND_CROSSBOW_DIRECT := "crossbow_direct"
const ATTACK_KIND_CROSSBOW_VOLLEY := "crossbow_volley"
const ATTACK_KIND_DUEL_SHIELD_PUSH := "duel_shield_push"
const ATTACK_KIND_NAMED_SHIELD_PUSH := "named_shield_push"
const ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH := "iron_bucket_shield_push"
const ATTACK_KIND_BANNER_COMMAND := "banner_command"
const ATTACK_KIND_CAVALRY_STAB := "cavalry_stab"
const ATTACK_KIND_CAVALRY_CHARGE := "cavalry_charge"
const ARCHER_LEAD_SPEED_THRESHOLD := 42.0
const ARCHER_VOLLEY_STORY_TIME := 80.0
const ARCHER_VOLLEY_COOLDOWN := 6.0
const ARCHER_VOLLEY_ENDLESS_COOLDOWN := 5.2
const CROSSBOW_VOLLEY_STORY_TIME := 118.0
const CROSSBOW_VOLLEY_COOLDOWN := 7.2
const CROSSBOW_VOLLEY_ENDLESS_COOLDOWN := 6.2
const CROSSBOW_VOLLEY_MIN_MEMBERS := 3
const BANNER_AURA_RADIUS := 168.0
const BANNER_COMMAND_RADIUS := 202.0
const BANNER_COMMAND_DURATION := 2.8
const BANNER_DAMAGE_MULTIPLIER := 1.10
const BANNER_SPEED_MULTIPLIER := 1.08
const BANNER_COMMAND_DAMAGE_MULTIPLIER := 1.24
const BANNER_COMMAND_SPEED_MULTIPLIER := 1.22
const CAVALRY_LINE_HALF_WIDTH := 38.0
const CAVALRY_CHARGE_DISTANCE := 224.0
const CAVALRY_CHARGE_START_DELAY := 0.40
const CAVALRY_CHARGE_SPEED := 900.0
const CAVALRY_CHARGE_COOLDOWN := 4.8
const CAVALRY_CHARGE_MIN_DISTANCE := 170.0
const CAVALRY_CLASH_COOLDOWN := 2.4
const CAVALRY_CLASH_HURT_DURATION := 0.22
const CAVALRY_CLASH_KNOCKBACK := 560.0
const HALBERD_SWEEP_RANGE := 68.0
const HALBERD_BRACE_MIN_DISTANCE := 72.0
const HALBERD_BRACE_MAX_DISTANCE := 110.0
const HALBERD_BRACE_APPROACH_SPEED := 78.0
const SPEAR_LINE_HALF_WIDTH := 36.0
const SPEAR_FORMATION_MIN_MEMBERS := 3
const SPEAR_FORMATION_COOLDOWN := 6.0
const SPEAR_CLASH_COOLDOWN := 2.7
const SPEAR_CLASH_HURT_DURATION := 0.24
const SPEAR_CLASH_KNOCKBACK := 520.0
const SPATIAL_CELL_SIZE := 64.0
const MAX_SEPARATION_NEIGHBORS := 8
const PRESSURE_SEPARATION_REFRESH_INTERVAL := 0.10
const ATMOSPHERE_SEPARATION_REFRESH_INTERVAL := 0.18
const LAYER_REFRESH_INTERVAL := 0.55
const LAYER_ROTATION_MIN_INTERVAL := 1.50
const LAYER_ROTATION_MAX_INTERVAL := 2.50
const NAVIGATION_REPLAN_INTERVAL := 0.28
const NAVIGATION_TARGET_SHIFT := 46.0
const NAVIGATION_WAYPOINT_ARRIVAL := 18.0
const ENGAGE_MELEE_LIMIT := 10
const ENGAGE_HALBERD_LIMIT := 3
const ENGAGE_ARCHER_LIMIT := 5
const ENGAGE_ELITE_LIMIT := 1
const ENGAGE_SPEAR_LIMIT := 4
const ENGAGE_CROSSBOW_LIMIT := 3
const ENGAGE_BANNER_LIMIT := 1
const ENGAGE_CAVALRY_LIMIT := 3
const DUEL_SHIELD_SLOTS := 40
const DUEL_SPEAR_SLOTS := 36
const DUEL_RANGED_SLOTS := 24
const DUEL_SHIELD_RADIUS := Vector2(346.0, 229.0)
const DUEL_SPEAR_RADIUS := Vector2(424.0, 282.0)
const DUEL_RANGED_RADIUS := Vector2(510.0, 339.0)
const DUEL_SOFT_BOUNDARY_RADIUS := Vector2(386.0, 257.0)
const DUEL_PLAYER_MAX_OVERSTEP := 44.0
const DUEL_SLOT_ARRIVAL_DISTANCE := 34.0
const DUEL_SHIELD_SEAL_REQUIREMENT := 14
const DUEL_SHIELD_PUSH_ATTACKERS := 2
const DUEL_SPEAR_ATTACKERS := 1
const DUEL_RANGED_ATTACKERS := 1
const DUEL_FORMATION_DAMAGE_MULTIPLIER := 0.20
const DUEL_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER := 0.35
const DUEL_REINFORCEMENT_DELAY_MIN := 0.70
const DUEL_REINFORCEMENT_DELAY_MAX := 1.15
const DUEL_REINFORCEMENT_SPAWN_INTERVAL := 0.42
const DUEL_RANGED_ATTACK_COOLDOWN_MIN := 4.2
const DUEL_RANGED_ATTACK_COOLDOWN_MAX := 6.2
# 纵列盾墙斗将常量
const DUEL_WALL_INITIAL_LEFT_PERCENT := 0.25   # 左盾墙初始位置（地图宽度的25%）
const DUEL_WALL_INITIAL_RIGHT_PERCENT := 0.75  # 右盾墙初始位置（地图宽度的75%）
const DUEL_WALL_INITIAL_TOP_PERCENT := 0.15    # 上盾墙位置（地图高度的15%）
const DUEL_WALL_INITIAL_BOTTOM_PERCENT := 0.85 # 下盾墙位置（地图高度的85%）
const DUEL_WALL_MIN_WIDTH_PERCENT := 0.25      # 最小战场宽度（地图宽度的25%）
const DUEL_WALL_SHIELDS_PER_SIDE := 10          # 每侧盾墙目标人数
const DUEL_WALL_SHIELD_SPACING := 48.0          # 盾兵间距
const DUEL_WALL_VERTICAL_MARGIN := 74.0         # 盾墙上下留白
const DUEL_WALL_HORIZONTAL_MARGIN := 42.0       # 上下盾墙左右留白
const DUEL_WALL_VISUAL_SHIELDS_PER_SIDE := 12   # 只负责表现的补位盾兵数量
const DUEL_WALL_VISUAL_SHIELD_SPACING := 64.0   # 表现盾墙的最大间距
const DUEL_WALL_SUPPORT_SPEARS_PER_SIDE := 12  # 每侧枪兵槽位（2列×6行）
const DUEL_WALL_SUPPORT_RANGED_PER_SIDE := 8   # 每侧弓弩兵槽位（2列×4行）
const DUEL_WALL_SUPPORT_SPEARS_PER_TOP_BOTTOM := 6 # 上下盾墙外侧枪兵槽位
const DUEL_WALL_SUPPORT_RANGED_PER_TOP_BOTTOM := 4 # 上下盾墙外侧弓弩兵槽位
const DUEL_WALL_SUPPORT_COLUMN_SPACING := 56.0  # 盾墙后方纵深列间距
const DUEL_WALL_SUPPORT_ROW_SPACING := 64.0    # 盾墙后方横向行间距
const DUEL_WALL_COMPRESSION_PHASE1_TIME := 30.0  # 第一阶段时间（观察期）
const DUEL_WALL_COMPRESSION_PHASE2_TIME := 60.0  # 第二阶段时间（压缩期）
const DUEL_WALL_COMPRESSION_SPEED_SLOW := 0.3    # 慢速压缩（%/秒）
const DUEL_WALL_COMPRESSION_SPEED_FAST := 0.6    # 快速压缩（%/秒）
const DUEL_WALL_PLAYER_LOW_HEALTH_PAUSE := 10.0  # 玩家低血量时暂停压缩时间
const DUEL_WALL_HARASSMENT_ZONE_CLOSE := 60.0    # 近距离骚扰区域
const DUEL_WALL_HARASSMENT_ZONE_FAR := 120.0     # 远距离骚扰区域
const DUEL_WALL_SPEAR_DAMAGE := 9.0              # 枪兵骚扰伤害
const DUEL_WALL_ARCHER_DAMAGE := 7.0             # 弓兵骚扰伤害
const DUEL_WALL_CROSSBOW_DAMAGE := 5.0           # 弩兵骚扰伤害
const DUEL_WALL_SPEAR_COOLDOWN := 3.0            # 枪兵攻击间隔
const DUEL_WALL_ARCHER_COOLDOWN := 8.0           # 弓兵攻击间隔
const DUEL_WALL_CROSSBOW_COOLDOWN := 5.0         # 弩兵攻击间隔
const THREAT_HEALTH_MULTIPLIERS := [1.0, 1.35, 1.80, 2.35, 3.00, 3.70, 4.50, 5.40]
const THREAT_DAMAGE_MULTIPLIERS := [1.0, 1.12, 1.28, 1.48, 1.72, 1.92, 2.14, 2.38]
const THREAT_ARMOR_BONUSES := [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0]

var bounds := Rect2(80, 100, 1120, 500)
var positions: Array[Vector2] = []
var hit_points := PackedFloat32Array()
var max_hit_points := PackedFloat32Array()
var armor := PackedFloat32Array()
var move_speeds := PackedFloat32Array()
var damage_multipliers := PackedFloat32Array()
var cooldowns := PackedFloat32Array()
var hurt_timers := PackedFloat32Array()
var attack_states := PackedInt32Array()
var attack_timers := PackedFloat32Array()
var types := PackedInt32Array()
var active := PackedByteArray()
var tianji_lifted := PackedByteArray()
var knockback_velocities: Array[Vector2] = []
var recoil_timers := PackedFloat32Array()
var recoil_velocities: Array[Vector2] = []
var facing_directions: Array[Vector2] = []
var boss_guard_flags := PackedByteArray()
var death_states := PackedByteArray()
var death_timers := PackedFloat32Array()
var death_velocities: Array[Vector2] = []
var death_impact_charges := PackedByteArray()
var launch_timers := PackedFloat32Array()
var launch_durations := PackedFloat32Array()
var launch_velocities: Array[Vector2] = []
var launch_collision_damages := PackedFloat32Array()
var launch_collision_knockbacks := PackedFloat32Array()
var launch_collision_charges := PackedByteArray()
var launch_relay_charges := PackedByteArray()
var launch_hit_targets: Array[Dictionary] = []
var forced_displacement_timers := PackedFloat32Array()
var forced_displacement_velocities: Array[Vector2] = []
var hit_feedback_timers := PackedFloat32Array()
var hit_feedback_durations := PackedFloat32Array()
var hit_feedback_strengths := PackedFloat32Array()
var slow_timers := PackedFloat32Array()
var slow_multipliers := PackedFloat32Array()
var behavior_layers := PackedByteArray()
var desired_behavior_layers := PackedByteArray()
var decision_timers := PackedFloat32Array()
var decision_cycles := PackedInt32Array()
var movement_targets: Array[Vector2] = []
var spawn_anchors: Array[Vector2] = []
var patrol_offsets: Array[Vector2] = []
var attack_wait_times := PackedFloat32Array()
var attack_turn_grants := PackedByteArray()
var spear_combo_stages := PackedByteArray()
var spear_combo_timers := PackedFloat32Array()
var command_aura_strengths := PackedFloat32Array()
var command_surge_timers := PackedFloat32Array()
var separation_vectors: Array[Vector2] = []
var separation_refresh_timers := PackedFloat32Array()
var duel_roles := PackedByteArray()
var duel_slots := PackedInt32Array()
var cavalry_charge_cooldowns := PackedFloat32Array()
var cavalry_charge_distances := PackedFloat32Array()
var cavalry_charge_directions: Array[Vector2] = []
var current_attack_kinds: Array[String] = []
var death_action_kinds := PackedInt32Array()
var free_ids: Array[int] = []
var death_records: Array[Dictionary] = []
var active_count := 0
var boss_guard_count := 0
var spatial_cells: Dictionary = {}
var layer_refresh_remaining := 0.0
var layer_rotation_cursor := 0
var layer_rotation_remaining := 0.0
var threat_tier := 0
var battle_mode := "story"
var battle_elapsed := 0.0
var difficulty_ramp := 1.0
var formation_time := 0.0
var last_player_position := Vector2.ZERO
var player_velocity := Vector2.ZERO
var has_player_position := false
var archer_volley_cooldown := 0.0
var spear_formation_cooldown := 0.0
var crossbow_volley_cooldown := 0.0
var navigation_obstacles: Array[Rect2] = []
var navigation_waypoints: Array[Vector2] = []
var navigation_targets: Array[Vector2] = []
var navigation_replan_timers := PackedFloat32Array()
var navigation_waypoint_active := PackedByteArray()
var navigation_preferred_sides := PackedInt32Array()
var duel_phase := DuelPhase.NONE
var duel_center := Vector2.ZERO
var duel_slot_refill_timers := PackedFloat32Array()
var duel_fodder_death_ids: Dictionary = {}
var duel_maintenance_remaining := 0.0
var duel_reinforcement_spawn_remaining := 0.0
var duel_ranged_attack_cooldown := 0.0
# 纵列盾墙斗将变量
var duel_wall_left_percent := 0.25      # 左盾墙位置（百分比）
var duel_wall_right_percent := 0.75     # 右盾墙位置（百分比）
var duel_wall_top_percent := 0.15       # 上盾墙位置（百分比）
var duel_wall_bottom_percent := 0.85    # 下盾墙位置（百分比）
var duel_wall_elapsed := 0.0            # 斗将经过时间
var duel_wall_compression_paused := false  # 压缩是否暂停
var duel_wall_compression_pause_remaining := 0.0  # 暂停剩余时间
var duel_wall_left_shield_ids: Array[int] = []   # 左盾墙盾兵ID列表
var duel_wall_right_shield_ids: Array[int] = []  # 右盾墙盾兵ID列表
var duel_wall_top_shield_ids: Array[int] = []    # 上盾墙盾兵ID列表
var duel_wall_bottom_shield_ids: Array[int] = [] # 下盾墙盾兵ID列表
var duel_wall_spear_harassment_cooldown := 0.0   # 枪兵骚扰冷却
var duel_wall_archer_harassment_cooldown := 0.0  # 弓兵骚扰冷却
var duel_wall_crossbow_harassment_cooldown := 0.0 # 弩兵骚扰冷却
var duel_wall_shield_clash_sound_timer := 0.0    # 盾墙敲击音效计时器
var duel_exiting := PackedByteArray()
var duel_exit_targets: Array[Vector2] = []
var named_formation_kind := ""
var named_formation_origin := Vector2.ZERO
var named_formation_remaining := 0.0
var named_formation_elapsed := 0.0
var named_formation_break_open := false
var named_formation_progress := 0
var named_formation_required := NAMED_FORMATION_BREAK_REQUIRED
var named_formation_members := PackedByteArray()
var named_formation_critical := PackedByteArray()
var named_formation_targets: Array[Vector2] = []
var named_formation_local_targets: Array[Vector2] = []
var named_formation_gate_slots: Array[int] = []
var named_formation_break_slots: Array[int] = []
var named_formation_gate_index := -1
var named_formation_gate_rotation_remaining := 0.0
var named_formation_slots: Array[Dictionary] = []
var named_formation_wall_segments: Array[Dictionary] = []
var named_formation_slot_taken := PackedByteArray()
var named_formation_slot_index := PackedInt32Array()
var iron_bucket_formations: Array[Dictionary] = []
var iron_bucket_member_formation := PackedInt32Array()
var iron_bucket_member_role := PackedInt32Array()
var iron_bucket_member_slot := PackedInt32Array()
var iron_bucket_targets: Array[Vector2] = []
var iron_bucket_local_targets: Array[Vector2] = []
var iron_bucket_next_id := 1
var iron_bucket_player_inside := PackedByteArray()

func _ready() -> void:
	positions.resize(CAPACITY)
	hit_points.resize(CAPACITY)
	max_hit_points.resize(CAPACITY)
	armor.resize(CAPACITY)
	move_speeds.resize(CAPACITY)
	damage_multipliers.resize(CAPACITY)
	cooldowns.resize(CAPACITY)
	hurt_timers.resize(CAPACITY)
	attack_states.resize(CAPACITY)
	attack_timers.resize(CAPACITY)
	types.resize(CAPACITY)
	active.resize(CAPACITY)
	tianji_lifted.resize(CAPACITY)
	knockback_velocities.resize(CAPACITY)
	recoil_timers.resize(CAPACITY)
	recoil_velocities.resize(CAPACITY)
	facing_directions.resize(CAPACITY)
	boss_guard_flags.resize(CAPACITY)
	death_states.resize(CAPACITY)
	death_timers.resize(CAPACITY)
	death_velocities.resize(CAPACITY)
	death_impact_charges.resize(CAPACITY)
	launch_timers.resize(CAPACITY)
	launch_durations.resize(CAPACITY)
	launch_velocities.resize(CAPACITY)
	launch_collision_damages.resize(CAPACITY)
	launch_collision_knockbacks.resize(CAPACITY)
	launch_collision_charges.resize(CAPACITY)
	launch_relay_charges.resize(CAPACITY)
	launch_hit_targets.resize(CAPACITY)
	forced_displacement_timers.resize(CAPACITY)
	forced_displacement_velocities.resize(CAPACITY)
	hit_feedback_timers.resize(CAPACITY)
	hit_feedback_durations.resize(CAPACITY)
	hit_feedback_strengths.resize(CAPACITY)
	slow_timers.resize(CAPACITY)
	slow_multipliers.resize(CAPACITY)
	behavior_layers.resize(CAPACITY)
	desired_behavior_layers.resize(CAPACITY)
	decision_timers.resize(CAPACITY)
	decision_cycles.resize(CAPACITY)
	movement_targets.resize(CAPACITY)
	spawn_anchors.resize(CAPACITY)
	patrol_offsets.resize(CAPACITY)
	attack_wait_times.resize(CAPACITY)
	attack_turn_grants.resize(CAPACITY)
	spear_combo_stages.resize(CAPACITY)
	spear_combo_timers.resize(CAPACITY)
	command_aura_strengths.resize(CAPACITY)
	command_surge_timers.resize(CAPACITY)
	separation_vectors.resize(CAPACITY)
	separation_refresh_timers.resize(CAPACITY)
	duel_roles.resize(CAPACITY)
	duel_slots.resize(CAPACITY)
	duel_exiting.resize(CAPACITY)
	duel_exit_targets.resize(CAPACITY)
	duel_slot_refill_timers.resize(_duel_total_slot_count())
	named_formation_members.resize(CAPACITY)
	named_formation_critical.resize(CAPACITY)
	named_formation_targets.resize(CAPACITY)
	named_formation_local_targets.resize(CAPACITY)
	named_formation_slot_taken.resize(NAMED_FORMATION_SLOT_CAPACITY)
	named_formation_slot_index.resize(CAPACITY)
	iron_bucket_member_formation.resize(CAPACITY)
	iron_bucket_member_role.resize(CAPACITY)
	iron_bucket_member_slot.resize(CAPACITY)
	iron_bucket_targets.resize(CAPACITY)
	iron_bucket_local_targets.resize(CAPACITY)
	iron_bucket_player_inside.resize(CAPACITY)
	cavalry_charge_cooldowns.resize(CAPACITY)
	cavalry_charge_distances.resize(CAPACITY)
	cavalry_charge_directions.resize(CAPACITY)
	current_attack_kinds.resize(CAPACITY)
	death_action_kinds.resize(CAPACITY)
	for id in range(CAPACITY):
		positions[id] = Vector2.ZERO
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		attack_states[id] = AttackState.APPROACH
		damage_multipliers[id] = 1.0
		attack_timers[id] = 0.0
		boss_guard_flags[id] = 0
		tianji_lifted[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		_clear_launch_state(id)
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		slow_timers[id] = 0.0
		slow_multipliers[id] = 1.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = 0.0
		separation_vectors[id] = Vector2.ZERO
		separation_refresh_timers[id] = 0.0
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
		duel_exiting[id] = 0
		duel_exit_targets[id] = Vector2.ZERO
		named_formation_members[id] = 0
		named_formation_critical[id] = 0
		named_formation_targets[id] = Vector2.ZERO
		named_formation_local_targets[id] = Vector2.ZERO
		named_formation_slot_index[id] = -1
		iron_bucket_member_formation[id] = -1
		iron_bucket_member_role[id] = 0
		iron_bucket_member_slot[id] = -1
		iron_bucket_targets[id] = Vector2.ZERO
		iron_bucket_local_targets[id] = Vector2.ZERO
		cavalry_charge_cooldowns[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		current_attack_kinds[id] = ""
		death_action_kinds[id] = AttackRequest.ActionKind.NONE
		free_ids.append(CAPACITY - id - 1)

func set_threat_tier(value: int) -> void:
	threat_tier = clampi(value, 0, THREAT_HEALTH_MULTIPLIERS.size() - 1)

func set_difficulty_ramp(value: float) -> void:
	difficulty_ramp = clampf(value, 0.70, 1.20)

func reset(world_bounds: Rect2, selected_mode: String = "story") -> void:
	bounds = world_bounds
	battle_mode = selected_mode
	battle_elapsed = 0.0
	difficulty_ramp = 1.0
	formation_time = 0.0
	last_player_position = world_bounds.get_center()
	player_velocity = Vector2.ZERO
	has_player_position = false
	archer_volley_cooldown = 0.0
	spear_formation_cooldown = 0.0
	crossbow_volley_cooldown = 0.0
	duel_phase = DuelPhase.NONE
	duel_center = world_bounds.get_center()
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0
	duel_fodder_death_ids.clear()
	clear_named_formation(false)
	clear_iron_bucket_formations(false)
	death_records.clear()
	for slot_index in range(duel_slot_refill_timers.size()):
		duel_slot_refill_timers[slot_index] = 0.0
	navigation_waypoints.resize(CAPACITY)
	navigation_targets.resize(CAPACITY)
	navigation_replan_timers.resize(CAPACITY)
	navigation_waypoint_active.resize(CAPACITY)
	navigation_preferred_sides.resize(CAPACITY)
	free_ids.clear()
	spatial_cells.clear()
	active_count = 0
	boss_guard_count = 0
	layer_refresh_remaining = 0.0
	layer_rotation_cursor = 0
	layer_rotation_remaining = 0.0
	for id in range(CAPACITY):
		active[id] = 0
		tianji_lifted[id] = 0
		hurt_timers[id] = 0.0
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		facing_directions[id] = Vector2.DOWN
		boss_guard_flags[id] = 0
		death_states[id] = DeathState.NONE
		death_timers[id] = 0.0
		death_velocities[id] = Vector2.ZERO
		death_impact_charges[id] = 0
		_clear_launch_state(id)
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		slow_timers[id] = 0.0
		slow_multipliers[id] = 1.0
		behavior_layers[id] = EngagementLayer.ATMOSPHERE
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		decision_timers[id] = 0.0
		decision_cycles[id] = 0
		movement_targets[id] = Vector2.ZERO
		spawn_anchors[id] = Vector2.ZERO
		patrol_offsets[id] = Vector2.ZERO
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = 0.0
		separation_vectors[id] = Vector2.ZERO
		separation_refresh_timers[id] = 0.0
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
		duel_exiting[id] = 0
		duel_exit_targets[id] = Vector2.ZERO
		named_formation_members[id] = 0
		named_formation_critical[id] = 0
		named_formation_targets[id] = Vector2.ZERO
		named_formation_local_targets[id] = Vector2.ZERO
		named_formation_slot_index[id] = -1
		iron_bucket_member_formation[id] = -1
		iron_bucket_member_role[id] = 0
		iron_bucket_member_slot[id] = -1
		iron_bucket_targets[id] = Vector2.ZERO
		iron_bucket_local_targets[id] = Vector2.ZERO
		cavalry_charge_cooldowns[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		current_attack_kinds[id] = ""
		navigation_waypoints[id] = Vector2.ZERO
		navigation_targets[id] = Vector2.ZERO
		navigation_replan_timers[id] = 0.0
		navigation_waypoint_active[id] = 0
		navigation_preferred_sides[id] = -1 if id % 2 == 0 else 1
		damage_multipliers[id] = 1.0
		free_ids.append(CAPACITY - id - 1)

func set_navigation_obstacles(value: Array[Rect2]) -> void:
	navigation_obstacles = value.duplicate()
	for id in range(CAPACITY):
		navigation_replan_timers[id] = 0.0
		navigation_waypoint_active[id] = 0

func mark_navigation_blocked(id: int) -> void:
	if id < 0 or id >= CAPACITY:
		return
	navigation_replan_timers[id] = 0.0
	navigation_waypoint_active[id] = 0
	navigation_preferred_sides[id] = -navigation_preferred_sides[id] if navigation_preferred_sides[id] != 0 else 1

func set_battle_elapsed(value: float) -> void:
	battle_elapsed = maxf(0.0, value)

func begin_duel_formation(center: Vector2) -> void:
	# 清除其他阵型
	clear_named_formation(false)
	clear_iron_bucket_formations(false)
	clear_duel_formation()

	duel_center = _clamp_duel_center(center)
	duel_phase = DuelPhase.ASSEMBLING

	# 初始化纵列盾墙参数
	duel_wall_left_percent = DUEL_WALL_INITIAL_LEFT_PERCENT
	duel_wall_right_percent = DUEL_WALL_INITIAL_RIGHT_PERCENT
	duel_wall_top_percent = DUEL_WALL_INITIAL_TOP_PERCENT
	duel_wall_bottom_percent = DUEL_WALL_INITIAL_BOTTOM_PERCENT
	duel_wall_elapsed = 0.0
	duel_wall_compression_paused = false
	duel_wall_compression_pause_remaining = 0.0
	duel_wall_left_shield_ids.clear()
	duel_wall_right_shield_ids.clear()
	duel_wall_top_shield_ids.clear()
	duel_wall_bottom_shield_ids.clear()
	duel_wall_spear_harassment_cooldown = 0.0
	duel_wall_archer_harassment_cooldown = 0.0
	duel_wall_crossbow_harassment_cooldown = 0.0
	duel_wall_shield_clash_sound_timer = 5.0  # 5秒后第一次敲击

	# 建立四边盾墙，明确斗将区域的四条边界。
	_build_duel_shield_walls()

	# 分配其他士兵到待命区域
	_assign_duel_waiting_soldiers()

	layer_refresh_remaining = 0.0
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0

func clear_duel_formation() -> void:
	duel_phase = DuelPhase.NONE
	for id in range(CAPACITY):
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
		duel_exiting[id] = 0
		duel_exit_targets[id] = Vector2.ZERO
	layer_refresh_remaining = 0.0
	duel_maintenance_remaining = 0.0
	duel_reinforcement_spawn_remaining = 0.0
	duel_ranged_attack_cooldown = 0.0
	duel_fodder_death_ids.clear()
	for slot_index in range(duel_slot_refill_timers.size()):
		duel_slot_refill_timers[slot_index] = 0.0
	# 清理纵列盾墙数据
	duel_wall_left_shield_ids.clear()
	duel_wall_right_shield_ids.clear()
	duel_wall_top_shield_ids.clear()
	duel_wall_bottom_shield_ids.clear()
	duel_wall_elapsed = 0.0

func _build_duel_shield_walls() -> void:
	var left_wall_x: float = bounds.position.x + bounds.size.x * duel_wall_left_percent
	var right_wall_x: float = bounds.position.x + bounds.size.x * duel_wall_right_percent
	var top_wall_y: float = bounds.position.y + bounds.size.y * duel_wall_top_percent
	var bottom_wall_y: float = bounds.position.y + bounds.size.y * duel_wall_bottom_percent
	var shield_count_per_wall := DUEL_WALL_SHIELDS_PER_SIDE

	# 收集或生成盾兵用于左盾墙
	for i in range(shield_count_per_wall):
		var y_pos := _duel_wall_y(i, shield_count_per_wall)
		var shield_id: int = _find_or_spawn_shield_for_wall(Vector2(left_wall_x, y_pos))
		if shield_id >= 0 and shield_id < CAPACITY:
			duel_wall_left_shield_ids.append(shield_id)
			duel_roles[shield_id] = DuelRole.SHIELD_RING
			duel_slots[shield_id] = i
			movement_targets[shield_id] = Vector2(left_wall_x, y_pos)
			# 只有盾墙盾兵设置为无敌，不影响其他单位
			if types[shield_id] == EnemyType.SHIELD:
				hit_points[shield_id] = 999999.0  # 使用大数值而不是INF
				max_hit_points[shield_id] = 999999.0

	# 上下横向盾墙补足纵向边界。槽位从左右两列之后连续编号。
	for i in range(shield_count_per_wall):
		var x_pos := _duel_wall_x(i, shield_count_per_wall)
		var shield_id := _find_or_spawn_shield_for_wall(Vector2(x_pos, top_wall_y))
		if shield_id >= 0 and shield_id < CAPACITY:
			duel_wall_top_shield_ids.append(shield_id)
			duel_roles[shield_id] = DuelRole.SHIELD_RING
			duel_slots[shield_id] = shield_count_per_wall * 2 + i
			movement_targets[shield_id] = Vector2(x_pos, top_wall_y)
			if types[shield_id] == EnemyType.SHIELD:
				hit_points[shield_id] = 999999.0
				max_hit_points[shield_id] = 999999.0

	for i in range(shield_count_per_wall):
		var x_pos := _duel_wall_x(i, shield_count_per_wall)
		var shield_id := _find_or_spawn_shield_for_wall(Vector2(x_pos, bottom_wall_y))
		if shield_id >= 0 and shield_id < CAPACITY:
			duel_wall_bottom_shield_ids.append(shield_id)
			duel_roles[shield_id] = DuelRole.SHIELD_RING
			duel_slots[shield_id] = shield_count_per_wall * 3 + i
			movement_targets[shield_id] = Vector2(x_pos, bottom_wall_y)
			if types[shield_id] == EnemyType.SHIELD:
				hit_points[shield_id] = 999999.0
				max_hit_points[shield_id] = 999999.0

	# 收集或生成盾兵用于右盾墙
	for i in range(shield_count_per_wall):
		var y_pos := _duel_wall_y(i, shield_count_per_wall)
		var shield_id: int = _find_or_spawn_shield_for_wall(Vector2(right_wall_x, y_pos))
		if shield_id >= 0 and shield_id < CAPACITY:
			duel_wall_right_shield_ids.append(shield_id)
			duel_roles[shield_id] = DuelRole.SHIELD_RING
			duel_slots[shield_id] = i + shield_count_per_wall
			movement_targets[shield_id] = Vector2(right_wall_x, y_pos)
			# 只有盾墙盾兵设置为无敌，不影响其他单位
			if types[shield_id] == EnemyType.SHIELD:
				hit_points[shield_id] = 999999.0  # 使用大数值而不是INF
				max_hit_points[shield_id] = 999999.0

func _find_or_spawn_shield_for_wall(target_pos: Vector2) -> int:
	# 先尝试找附近的现有盾兵
	var closest_id := -1
	var closest_distance := INF
	for id in range(CAPACITY):
		if active[id] == 0 or types[id] != EnemyType.SHIELD:
			continue
		if duel_roles[id] != DuelRole.NONE or boss_guard_flags[id] == 1:
			continue
		var distance := positions[id].distance_to(target_pos)
		if distance < closest_distance:
			closest_id = id
			closest_distance = distance

	if closest_id >= 0:
		return closest_id

	# 新盾兵从最近的场外边缘进入，避免一帧填满墙面。
	var distances := [
		absf(target_pos.x - bounds.position.x),
		absf(bounds.end.x - target_pos.x),
		absf(target_pos.y - bounds.position.y),
		absf(bounds.end.y - target_pos.y),
	]
	var nearest_edge := 0
	for index in range(1, distances.size()):
		if distances[index] < distances[nearest_edge]:
			nearest_edge = index
	var spawn_position := target_pos
	match nearest_edge:
		0: spawn_position.x = bounds.position.x - 96.0
		1: spawn_position.x = bounds.end.x + 96.0
		2: spawn_position.y = bounds.position.y - 96.0
		_: spawn_position.y = bounds.end.y + 96.0
	return spawn(EnemyType.SHIELD, spawn_position, false)

func _duel_wall_y(index: int, count: int) -> float:
	if count <= 1:
		return bounds.get_center().y
	var top_wall_y := bounds.position.y + bounds.size.y * duel_wall_top_percent
	var bottom_wall_y := bounds.position.y + bounds.size.y * duel_wall_bottom_percent
	return lerpf(top_wall_y, bottom_wall_y, float(index) / float(count - 1))

func _duel_wall_x(index: int, count: int) -> float:
	if count <= 1:
		return bounds.get_center().x
	var left_wall_x := bounds.position.x + bounds.size.x * duel_wall_left_percent
	var right_wall_x := bounds.position.x + bounds.size.x * duel_wall_right_percent
	return lerpf(left_wall_x, right_wall_x, float(index) / float(count - 1))

func _duel_wall_visual_y(index: int, count: int) -> float:
	if count <= 1:
		return bounds.get_center().y
	return _duel_wall_y(index, count)

func get_duel_wall_visual_positions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_duel_formation_active():
		return result
	var visual_count := DUEL_WALL_VISUAL_SHIELDS_PER_SIDE
	for side in range(DUEL_WALL_SIDE_BOTTOM + 1):
		var shield_ids := _duel_wall_shield_ids_for_side(side)
		for index in range(visual_count):
			var candidate := _duel_wall_visual_position(side, index, visual_count)
			var occupied := false
			for shield_id in shield_ids:
				if shield_id >= 0 and shield_id < CAPACITY and active[shield_id] == 1 and positions[shield_id].distance_to(candidate) < 30.0:
					occupied = true
					break
			if not occupied:
				result.append({"position": candidate, "facing": _duel_wall_side_facing(side)})
	return result

func _duel_wall_shield_ids_for_side(side: int) -> Array[int]:
	match side:
		DUEL_WALL_SIDE_LEFT: return duel_wall_left_shield_ids
		DUEL_WALL_SIDE_RIGHT: return duel_wall_right_shield_ids
		DUEL_WALL_SIDE_TOP: return duel_wall_top_shield_ids
		DUEL_WALL_SIDE_BOTTOM: return duel_wall_bottom_shield_ids
	return []

func _duel_wall_visual_position(side: int, index: int, count: int) -> Vector2:
	match side:
		DUEL_WALL_SIDE_LEFT:
			return Vector2(bounds.position.x + bounds.size.x * duel_wall_left_percent, _duel_wall_visual_y(index, count))
		DUEL_WALL_SIDE_RIGHT:
			return Vector2(bounds.position.x + bounds.size.x * duel_wall_right_percent, _duel_wall_visual_y(index, count))
		DUEL_WALL_SIDE_TOP:
			return Vector2(_duel_wall_x(index, count), bounds.position.y + bounds.size.y * duel_wall_top_percent)
		_:
			return Vector2(_duel_wall_x(index, count), bounds.position.y + bounds.size.y * duel_wall_bottom_percent)

func _duel_wall_side_facing(side: int) -> Vector2:
	match side:
		DUEL_WALL_SIDE_LEFT: return Vector2.RIGHT
		DUEL_WALL_SIDE_RIGHT: return Vector2.LEFT
		DUEL_WALL_SIDE_TOP: return Vector2.DOWN
		_: return Vector2.UP

func _assign_duel_waiting_soldiers() -> void:
	var all_spears: Array[int] = []
	var all_ranged: Array[int] = []
	var other_soldiers: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or boss_guard_flags[id] == 1:
			continue
		if duel_roles[id] == DuelRole.SHIELD_RING:
			continue
		if types[id] == EnemyType.SPEAR:
			all_spears.append(id)
		elif types[id] == EnemyType.ARCHER or types[id] == EnemyType.CROSSBOW:
			all_ranged.append(id)
		else:
			other_soldiers.append(id)

	# 左右墙的纵深更大，上下墙采用较短横列；按各自容量分配，避免轮转后留下空槽。
	var spear_cursor := 0
	var ranged_cursor := 0
	for side in range(DUEL_WALL_SIDE_BOTTOM + 1):
		var spear_group: Array[int] = []
		var ranged_group: Array[int] = []
		for _index in range(_duel_support_capacity(DuelRole.SPEAR_RING, side)):
			if spear_cursor >= all_spears.size():
				break
			spear_group.append(all_spears[spear_cursor])
			spear_cursor += 1
		for _index in range(_duel_support_capacity(DuelRole.RANGED_RING, side)):
			if ranged_cursor >= all_ranged.size():
				break
			ranged_group.append(all_ranged[ranged_cursor])
			ranged_cursor += 1
		_arrange_duel_support_soldiers(spear_group, ranged_group, side)
	for index in range(spear_cursor, all_spears.size()):
		_mark_duel_soldier_for_exit(all_spears[index])
	for index in range(ranged_cursor, all_ranged.size()):
		_mark_duel_soldier_for_exit(all_ranged[index])
	for id in other_soldiers:
		_mark_duel_soldier_for_exit(id)

func _arrange_duel_support_soldiers(spears: Array, ranged: Array, side: int) -> void:
	var spear_capacity := _duel_support_capacity(DuelRole.SPEAR_RING, side)
	var ranged_capacity := _duel_support_capacity(DuelRole.RANGED_RING, side)
	var spear_offset := _duel_support_slot_offset(DuelRole.SPEAR_RING, side)
	var ranged_offset := _duel_support_slot_offset(DuelRole.RANGED_RING, side)
	for index in range(mini(spears.size(), spear_capacity)):
		var soldier_id := int(spears[index])
		duel_roles[soldier_id] = DuelRole.SPEAR_RING
		duel_slots[soldier_id] = spear_offset + index
		movement_targets[soldier_id] = _duel_slot_position(DuelRole.SPEAR_RING, duel_slots[soldier_id])
	for index in range(mini(ranged.size(), ranged_capacity)):
		var soldier_id := int(ranged[index])
		duel_roles[soldier_id] = DuelRole.RANGED_RING
		duel_slots[soldier_id] = ranged_offset + index
		movement_targets[soldier_id] = _duel_slot_position(DuelRole.RANGED_RING, duel_slots[soldier_id])
	for index in range(spear_capacity, spears.size()):
		_mark_duel_soldier_for_exit(int(spears[index]))
	for index in range(ranged_capacity, ranged.size()):
		_mark_duel_soldier_for_exit(int(ranged[index]))

func _mark_duel_soldier_for_exit(id: int) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return
	var is_on_top: bool = positions[id].y < bounds.get_center().y
	var exit_y: float = bounds.position.y - 120.0 if is_on_top else bounds.end.y + 120.0
	var retreat_target := Vector2(positions[id].x, exit_y)
	# 设置独立退场目标，避免后续阵型刷新将其拉回场内。
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	duel_exiting[id] = 1
	duel_exit_targets[id] = retreat_target
	# 退场单位不再参与围阵接战层，避免层级刷新把它们重新拉回场内。
	behavior_layers[id] = EngagementLayer.ATMOSPHERE
	desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
	attack_turn_grants[id] = 0
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	decision_timers[id] = 0.0
	movement_targets[id] = retreat_target



func is_duel_formation_active() -> bool:
	return duel_phase != DuelPhase.NONE

func is_duel_formation_sealed() -> bool:
	return duel_phase == DuelPhase.SEALED

func duel_formation_center() -> Vector2:
	return duel_center

func is_duel_formation_member(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and duel_roles[id] != DuelRole.NONE

func is_duel_shield(id: int) -> bool:
	return is_duel_formation_member(id) and duel_roles[id] == DuelRole.SHIELD_RING

func duel_containment_radii() -> Vector2:
	if not is_duel_formation_active():
		return Vector2.ZERO
	return DUEL_SHIELD_RADIUS

func duel_soft_boundary_radii() -> Vector2:
	if not is_duel_formation_active():
		return Vector2.ZERO
	return DUEL_SOFT_BOUNDARY_RADIUS

func constrain_to_duel_formation(at: Vector2, margin: float = 12.0) -> Vector2:
	if not is_duel_formation_active():
		return at
	return _constrain_to_duel_rect(at, margin)

func duel_combat_rect(margin: float = 0.0) -> Rect2:
	var safe_margin := maxf(0.0, margin)
	var left := bounds.position.x + bounds.size.x * duel_wall_left_percent + safe_margin
	var right := bounds.position.x + bounds.size.x * duel_wall_right_percent - safe_margin
	var top := bounds.position.y + bounds.size.y * duel_wall_top_percent + safe_margin
	var bottom := bounds.position.y + bounds.size.y * duel_wall_bottom_percent - safe_margin
	return Rect2(Vector2(left, top), Vector2(maxf(1.0, right - left), maxf(1.0, bottom - top)))

func _constrain_to_duel_rect(at: Vector2, margin: float) -> Vector2:
	var combat_rect := duel_combat_rect(margin)
	return Vector2(
		clampf(at.x, combat_rect.position.x, combat_rect.end.x),
		clampf(at.y, combat_rect.position.y, combat_rect.end.y)
	)

func apply_duel_player_boundary(_origin: Vector2, candidate: Vector2) -> Vector2:
	if not is_duel_formation_active():
		return candidate
	return _constrain_to_duel_rect(candidate, 20.0)

func constrain_named_to_duel_formation(at: Vector2, margin: float = 32.0) -> Vector2:
	if not is_duel_formation_active():
		return at
	return _constrain_to_duel_rect(at, margin)

func _duel_normalized_distance(at: Vector2, radii: Vector2) -> float:
	var offset := at - duel_center
	return sqrt(pow(offset.x / maxf(1.0, radii.x), 2.0) + pow(offset.y / maxf(1.0, radii.y), 2.0))

func is_player_near_duel_boundary(at: Vector2, threshold: float = 0.68) -> bool:
	if not is_duel_formation_active():
		return false
	var combat_rect := duel_combat_rect()
	var distance_to_wall := minf(
		minf(at.x - combat_rect.position.x, combat_rect.end.x - at.x),
		minf(at.y - combat_rect.position.y, combat_rect.end.y - at.y)
	)
	var boundary_band := minf(combat_rect.size.x, combat_rect.size.y) * (1.0 - clampf(threshold, 0.0, 0.98)) * 0.5
	return distance_to_wall <= boundary_band

func block_duel_shield_hit(id: int) -> void:
	if not is_duel_shield(id):
		return
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.72)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.11)
	hit_feedback_timers[id] = hit_feedback_durations[id]

func is_duel_formation_fodder(id: int) -> bool:
	return is_duel_formation_member(id) and duel_roles[id] != DuelRole.SHIELD_RING

func is_named_formation_active() -> bool:
	return not named_formation_kind.is_empty() and named_formation_remaining > 0.0

func named_formation_id() -> String:
	return named_formation_kind

func named_formation_center() -> Vector2:
	return named_formation_origin

func get_named_formation_wall_segments() -> Array[Dictionary]:
	return named_formation_wall_segments

func get_named_formation_wall_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for id in range(CAPACITY):
		if not is_named_formation_shield_wall(id):
			continue
		var slot_index := named_formation_slot_index[id]
		if slot_index < 0 or slot_index >= named_formation_slots.size():
			continue
		if bool(named_formation_slots[slot_index].get("wall", false)):
			result.append(positions[id])
	return result

func get_named_formation_wall_gap_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	if not is_named_formation_active():
		return result
	for slot_index in range(named_formation_slots.size()):
		var slot: Dictionary = named_formation_slots[slot_index]
		if not bool(slot.get("wall", false)) or _named_wall_slot_has_shield(slot_index):
			continue
		result.append(named_formation_origin + slot.get("local", Vector2.ZERO))
	return result

func get_named_formation_channel_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for id in range(CAPACITY):
		if not is_named_formation_member(id) or types[id] != EnemyType.CAVALRY:
			continue
		var slot_index := named_formation_slot_index[id]
		if slot_index < 0 or slot_index >= named_formation_slots.size():
			continue
		if bool(named_formation_slots[slot_index].get("channel", false)):
			result.append(positions[id])
	return result

func is_named_formation_wall_gap_at(world_at: Vector2) -> bool:
	if not is_named_formation_active():
		return false
	for slot_index in range(named_formation_slots.size()):
		var slot: Dictionary = named_formation_slots[slot_index]
		if not bool(slot.get("wall", false)):
			continue
		if _named_wall_slot_has_shield(slot_index):
			continue
		var gap_center: Vector2 = named_formation_origin + slot.get("local", Vector2.ZERO)
		if world_at.distance_squared_to(gap_center) <= 92.0 * 92.0:
			return true
	return false

func _named_wall_slot_has_shield(slot_index: int) -> bool:
	for id in range(CAPACITY):
		if active[id] == 1 and named_formation_members[id] == 1 and named_formation_slot_index[id] == slot_index and types[id] == EnemyType.SHIELD:
			return true
	return false

func named_formation_time_remaining() -> float:
	return maxf(0.0, named_formation_remaining)

func named_formation_assembly_time_remaining() -> float:
	if not is_named_formation_active():
		return 0.0
	return maxf(0.0, NAMED_FORMATION_ASSEMBLY_DURATION - named_formation_elapsed)

func named_formation_break_time_remaining() -> float:
	return maxf(0.0, minf(NAMED_FORMATION_BREAK_WINDOW, named_formation_remaining)) if named_formation_break_open else 0.0

func is_named_formation_break_window() -> bool:
	return is_named_formation_active() and named_formation_break_open

func named_formation_break_progress() -> int:
	return named_formation_progress

func named_formation_break_required() -> int:
	return named_formation_required

func is_named_formation_member(id: int) -> bool:
	return id >= 0 and id < CAPACITY and named_formation_members[id] == 1

func is_named_formation_critical(id: int) -> bool:
	return id >= 0 and id < CAPACITY and named_formation_critical[id] == 1

func named_formation_gate_target() -> Vector2:
	if named_formation_kind != "bagua" or named_formation_gate_index < 0 or named_formation_gate_index >= named_formation_gate_slots.size():
		return named_formation_origin
	var gate_id := named_formation_gate_slots[named_formation_gate_index]
	return positions[gate_id] if is_active(gate_id) else named_formation_origin

func iron_bucket_count() -> int:
	if not IRON_BUCKET_ENABLED:
		return 0
	var count := 0
	for formation in iron_bucket_formations:
		if str(formation.get("state", "")) in ["forming", "marching", "assembling", "active"]:
			count += 1
	return count

func is_iron_bucket_active() -> bool:
	return IRON_BUCKET_ENABLED and iron_bucket_count() > 0

func get_iron_bucket_formations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not IRON_BUCKET_ENABLED:
		return result
	for formation in iron_bucket_formations:
		if str(formation.get("state", "")) in ["forming", "marching", "assembling", "active"]:
			result.append(formation)
	return result

func is_iron_bucket_assembling() -> bool:
	if not IRON_BUCKET_ENABLED:
		return false
	for formation in iron_bucket_formations:
		if str(formation.get("state", "")) in ["forming", "marching", "assembling"]:
			return true
	return false

func is_iron_bucket_member(id: int) -> bool:
	return IRON_BUCKET_ENABLED and id >= 0 and id < CAPACITY and active[id] == 1 and iron_bucket_member_formation[id] >= 0

func is_iron_bucket_shield(id: int) -> bool:
	return is_iron_bucket_member(id) and iron_bucket_member_role[id] == 1 and types[id] == EnemyType.SHIELD

func iron_bucket_center_for_enemy(id: int) -> Vector2:
	if not is_iron_bucket_member(id):
		return positions[id] if id >= 0 and id < CAPACITY else Vector2.ZERO
	var formation_index := iron_bucket_member_formation[id]
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return positions[id]
	return iron_bucket_formations[formation_index].get("center", positions[id])

func iron_bucket_damage_multiplier(id: int) -> float:
	if not is_iron_bucket_shield(id):
		return 1.0
	var formation_index := iron_bucket_member_formation[id]
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return 1.0
	var formation: Dictionary = iron_bucket_formations[formation_index]
	if str(formation.get("state", "")) == "assembling":
		return 0.0
	# 外圈盾兵是阵法的空气墙表现，不应被外部攻击削减。
	return 0.0

func block_iron_bucket_shield_hit(id: int) -> void:
	if not is_iron_bucket_shield(id):
		return
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.78)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.12)
	hit_feedback_timers[id] = hit_feedback_durations[id]

func _clamp_iron_bucket_center(point: Vector2, radius: float) -> Vector2:
	var margin := maxf(48.0, radius + 24.0)
	return Vector2(
		clampf(point.x, bounds.position.x + margin, bounds.end.x - margin),
		clampf(point.y, bounds.position.y + margin, bounds.end.y - margin)
	)

func _iron_bucket_center_is_clear(point: Vector2, radius: float) -> bool:
	if has_player_position and point.distance_to(last_player_position) < radius + 150.0:
		return false
	return _iron_bucket_center_has_clearance(point, radius)

func _iron_bucket_center_has_clearance(point: Vector2, radius: float, ignored_formation_index: int = -1) -> bool:
	for formation_index in range(iron_bucket_formations.size()):
		if formation_index == ignored_formation_index:
			continue
		var formation: Dictionary = iron_bucket_formations[formation_index]
		if str(formation.get("state", "")) not in ["forming", "marching", "assembling", "active"]:
			continue
		var other_center: Vector2 = formation.get("center", Vector2.ZERO)
		var other_radius := float(formation.get("radius", IRON_BUCKET_MIN_RADIUS))
		if point.distance_to(other_center) < radius + other_radius + IRON_BUCKET_FORMATION_CLEARANCE:
			return false
	return true

func _find_iron_bucket_center(requested: Vector2, radius: float) -> Vector2:
	var origin := _clamp_iron_bucket_center(requested, radius)
	var candidates: Array[Vector2] = [origin]
	var start_angle := randf_range(0.0, TAU)
	for ring in range(3):
		var search_distance := 180.0 + float(ring) * 180.0
		for index in range(8):
			candidates.append(_clamp_iron_bucket_center(origin + Vector2.from_angle(start_angle + TAU * float(index) / 8.0) * search_distance, radius))
	for candidate in candidates:
		if _iron_bucket_center_is_clear(candidate, radius):
			return candidate
	return Vector2.INF

func _resolve_iron_bucket_center_spacing(formation_index: int, requested: Vector2, radius: float) -> Vector2:
	var clamped_requested := _clamp_iron_bucket_center(requested, radius)
	var candidates: Array[Vector2] = [clamped_requested]
	if formation_index >= 0 and formation_index < iron_bucket_formations.size():
		candidates.append(iron_bucket_formations[formation_index].get("center", clamped_requested))
	for other_index in range(iron_bucket_formations.size()):
		if other_index == formation_index:
			continue
		var other: Dictionary = iron_bucket_formations[other_index]
		if str(other.get("state", "")) not in ["assembling", "active"]:
			continue
		var other_center: Vector2 = other.get("center", Vector2.ZERO)
		var offset := clamped_requested - other_center
		var distance := offset.length()
		var minimum_distance := radius + float(other.get("radius", IRON_BUCKET_MIN_RADIUS)) + IRON_BUCKET_FORMATION_CLEARANCE
		var direction := offset.normalized()
		if direction.length_squared() <= 0.01:
			direction = Vector2.from_angle(float(formation_index + other_index) * 2.17)
		candidates.append(_clamp_iron_bucket_center(other_center + direction * (minimum_distance + 8.0), radius))
		for direction_index in range(16):
			var angle := TAU * float(direction_index) / 16.0
			candidates.append(_clamp_iron_bucket_center(other_center + Vector2.from_angle(angle) * (minimum_distance + 8.0), radius))
	var closest_center := Vector2.INF
	var closest_distance_squared := INF
	for candidate in candidates:
		if not _iron_bucket_center_has_clearance(candidate, radius, formation_index):
			continue
		var distance_squared := candidate.distance_squared_to(clamped_requested)
		if distance_squared < closest_distance_squared:
			closest_center = candidate
			closest_distance_squared = distance_squared
	if closest_center.is_finite():
		return closest_center
	return iron_bucket_formations[formation_index].get("center", clamped_requested) if formation_index >= 0 and formation_index < iron_bucket_formations.size() else clamped_requested

func begin_iron_bucket_formation(center: Vector2) -> bool:
	if not IRON_BUCKET_ENABLED:
		return false
	if battle_mode != "endless" or iron_bucket_count() >= IRON_BUCKET_MAX_FORMATIONS:
		return false
	if is_duel_formation_active() or is_named_formation_active():
		return false
	var formation_radius := randf_range(IRON_BUCKET_MIN_RADIUS, IRON_BUCKET_MAX_RADIUS)

	# 铁桶阵在屏幕外完整生成，然后行军进入
	# 生成位置：地图边界外侧
	var is_spawn_left := randf() < 0.5
	var offscreen_distance := formation_radius + IRON_BUCKET_OFFSCREEN_MARGIN
	var offscreen_x := bounds.position.x - offscreen_distance if is_spawn_left else bounds.end.x + offscreen_distance
	var offscreen_center := Vector2(offscreen_x, bounds.get_center().y + randf_range(-100.0, 100.0))

	# 目标中心点：使用传入的center作为行军目标
	var target_center := _find_iron_bucket_center(center, formation_radius)
	if not target_center.is_finite():
		return false

	# 铁桶阵使用额外兵力，不抽调或瞬移当前战场单位。
	# 先检查容量，确保阵型可以完整生成；不足时由上层稍后重试。
	var shield_count := IRON_BUCKET_SHIELDS_PER_FORMATION
	var interior_count := IRON_BUCKET_INTERIOR_PER_FORMATION
	var total_count := shield_count + interior_count
	if shield_count < IRON_BUCKET_MIN_SHIELDS or interior_count < IRON_BUCKET_MIN_INTERIOR_MEMBERS or total_count < IRON_BUCKET_MIN_MEMBERS:
		return false
	if free_ids.size() < total_count:
		return false

	var shield_ids: Array[int] = []
	var interior_ids: Array[int] = []
	var member_ids: Array[int] = []
	var interior_spears: Array[int] = []
	var interior_ranged: Array[int] = []
	var interior_others: Array[int] = []
	for index in range(shield_count):
		var shield_id := spawn(EnemyType.SHIELD, offscreen_center)
		if shield_id < 0:
			_release_iron_bucket_spawned_units(member_ids)
			return false
		shield_ids.append(shield_id)
		member_ids.append(shield_id)
	for index in range(interior_count):
		var interior_type := EnemyType.SPEAR if index < 4 else (EnemyType.ARCHER if index % 2 == 0 else EnemyType.CROSSBOW)
		var interior_id := spawn(interior_type, offscreen_center)
		if interior_id < 0:
			_release_iron_bucket_spawned_units(member_ids)
			return false
		interior_ids.append(interior_id)
		member_ids.append(interior_id)
		match interior_type:
			EnemyType.SPEAR:
				interior_spears.append(interior_id)
			EnemyType.ARCHER, EnemyType.CROSSBOW:
				interior_ranged.append(interior_id)
			_:
				interior_others.append(interior_id)

	# 对内圈单位进行分类，用于后续槽位分配

	var formation_index := iron_bucket_formations.size()
	var gap_angle := (target_center - offscreen_center).angle()  # 缺口朝向行军方向

	# 计算朝向目标的行军漂移
	var march_drift := (target_center - offscreen_center).normalized() * IRON_BUCKET_MARCH_SPEED

	var formation := {
		"id": iron_bucket_next_id,
		"center": offscreen_center,  # 初始在屏幕外
		"target_center": target_center,  # 目标位置
		"radius": formation_radius,
		"gap_angle": gap_angle,
		"gap_width": randf_range(IRON_BUCKET_GAP_MIN_WIDTH, IRON_BUCKET_GAP_MAX_WIDTH),
		"rotation_angle": 0.0,
		"rotation_speed": randf_range(IRON_BUCKET_ROTATION_SPEED_MIN, IRON_BUCKET_ROTATION_SPEED_MAX) * 0.2 * (-1.0 if randf() < 0.5 else 1.0),
		"drift": march_drift,
		"drift_update_timer": 0.0,
		"elapsed": 0.0,
		"state": "forming",  # 先在屏外编成，再整体行军入场
		"player_inside": false,
		"member_ids": member_ids,
		"shield_ids": shield_ids,
		"interior_ids": interior_ids,
		"interior_spears": interior_spears,
		"interior_ranged": interior_ranged,
		"interior_others": interior_others,
		"slots": [],
		"inner_alive": interior_ids.size(),
		"inner_total": interior_ids.size(),
		"reinforce_cooldown": 0.0,
		"shields_alive": shield_ids.size(),
		"shield_gap_markers": [],
		"tianji_resistance": 0.5,  # 50%天机伤害减免
	}
	iron_bucket_formations.append(formation)
	iron_bucket_player_inside[formation_index] = 0
	iron_bucket_next_id += 1
	_build_iron_bucket_slots(formation_index)
	formation = iron_bucket_formations[formation_index]

	# 分配槽位并立即将单位传送到屏幕外的阵型位置
	var slots: Array = formation.get("slots", [])
	for id in member_ids:
		iron_bucket_member_formation[id] = formation_index
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		attack_turn_grants[id] = 0
		decision_timers[id] = 0.0

	# 分配盾兵到外圈槽位
	for shield_index in range(shield_ids.size()):
		var id := shield_ids[shield_index]
		iron_bucket_member_role[id] = 1  # 外圈盾兵
		iron_bucket_member_slot[id] = shield_index

		# 立即传送到屏幕外的阵型位置
		if shield_index < slots.size():
			var slot: Dictionary = slots[shield_index]
			var local: Vector2 = slot.get("local", Vector2.ZERO)
			var rotation: float = formation.get("rotation_angle", 0.0)
			positions[id] = offscreen_center + local.rotated(rotation)
			movement_targets[id] = positions[id]

	# 分配内圈单位到内圈槽位
	for interior_index in range(interior_ids.size()):
		var id := interior_ids[interior_index]
		iron_bucket_member_role[id] = 2  # 内圈攻击
		iron_bucket_member_slot[id] = shield_ids.size() + interior_index

		# 立即传送到屏幕外的阵型位置
		var slot_index := shield_ids.size() + interior_index
		if slot_index < slots.size():
			var slot: Dictionary = slots[slot_index]
			var local: Vector2 = slot.get("local", Vector2.ZERO)
			var rotation: float = formation.get("rotation_angle", 0.0)
			positions[id] = offscreen_center + local.rotated(rotation)
			movement_targets[id] = positions[id]

	return true

func _release_iron_bucket_spawned_units(ids: Array[int]) -> void:
	# 组建失败时回收本次已经生成的额外兵力，避免留下孤立单位。
	for id in ids:
		if id < 0 or id >= CAPACITY or active[id] == 0:
			continue
		active[id] = 0
		active_count = maxi(0, active_count - 1)
		boss_guard_flags[id] = 0
		duel_exiting[id] = 0
		iron_bucket_member_formation[id] = -1
		iron_bucket_member_role[id] = 0
		iron_bucket_member_slot[id] = -1
		iron_bucket_targets[id] = Vector2.ZERO
		iron_bucket_local_targets[id] = Vector2.ZERO
		free_ids.append(id)

func _build_iron_bucket_slots(formation_index: int) -> void:
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return
	var formation: Dictionary = iron_bucket_formations[formation_index]
	var radius := float(formation.get("radius", IRON_BUCKET_MIN_RADIUS))
	var gap_angle := float(formation.get("gap_angle", 0.0))
	var gap_width := float(formation.get("gap_width", 1.0))
	var shield_ids: Array = formation.get("shield_ids", [])
	var interior_spears: Array = formation.get("interior_spears", [])
	var interior_ranged: Array = formation.get("interior_ranged", [])
	var interior_others: Array = formation.get("interior_others", [])

	var slots: Array[Dictionary] = []

	# 外圈：盾兵均匀分布在圆周上，形成完整防护圈
	var shield_count := shield_ids.size()
	for index in range(shield_count):
		# 从缺口后开始分布盾兵，确保缺口位置没有盾兵
		var angle := gap_angle + gap_width * 0.5 + TAU * (float(index) + 0.5) / float(maxi(1, shield_count))
		slots.append({
			"local": Vector2.from_angle(angle) * radius,
			"role": 1,  # 外圈盾兵
			"angle": angle,
			"unit_type": "shield"
		})

	# 内圈分层：枪兵在前（靠近中心），远程在后（稍外层）
	# 第一层：枪兵，半径约0.45-0.50
	var spear_layer_radius := radius * 0.48
	for index in range(interior_spears.size()):
		# 枪兵面向外圈，形成内部防御层
		var angle := float(index) * TAU / float(maxi(1, interior_spears.size())) + gap_angle + PI
		slots.append({
			"local": Vector2.from_angle(angle) * spear_layer_radius,
			"role": 2,  # 内圈攻击
			"angle": angle,
			"unit_type": "spear",
			"layer": "front"
		})

	# 第二层：远程单位（弓兵/弩兵），半径约0.30-0.35
	var ranged_layer_radius := radius * 0.32
	for index in range(interior_ranged.size()):
		# 远程单位站在更靠近中心的位置，获得更好的射击视野
		var angle := float(index) * TAU / float(maxi(1, interior_ranged.size())) + gap_angle
		slots.append({
			"local": Vector2.from_angle(angle) * ranged_layer_radius,
			"role": 2,  # 内圈攻击
			"angle": angle,
			"unit_type": "ranged",
			"layer": "back"
		})

	# 其他单位：填充在中间层，半径约0.38-0.42
	var others_layer_radius := radius * 0.40
	for index in range(interior_others.size()):
		var angle := float(index) * TAU / float(maxi(1, interior_others.size())) + gap_angle + PI * 0.5
		slots.append({
			"local": Vector2.from_angle(angle) * others_layer_radius,
			"role": 2,  # 内圈攻击
			"angle": angle,
			"unit_type": "other",
			"layer": "middle"
		})

	formation["slots"] = slots
	iron_bucket_formations[formation_index] = formation

func clear_iron_bucket_formations(emit_signal: bool = false) -> void:
	for formation in iron_bucket_formations:
		if emit_signal and str(formation.get("state", "")) in ["forming", "marching", "assembling", "active"]:
			iron_bucket_collapsed.emit(formation.get("center", Vector2.ZERO))
	iron_bucket_formations.clear()
	for id in range(CAPACITY):
		iron_bucket_member_formation[id] = -1
		iron_bucket_member_role[id] = 0
		iron_bucket_member_slot[id] = -1
		iron_bucket_targets[id] = Vector2.ZERO
		iron_bucket_local_targets[id] = Vector2.ZERO
	for index in range(iron_bucket_player_inside.size()):
		iron_bucket_player_inside[index] = 0

func _tick_iron_bucket_formations(delta: float, player_position: Vector2) -> void:
	for formation_index in range(iron_bucket_formations.size()):
		var formation: Dictionary = iron_bucket_formations[formation_index]
		var state := str(formation.get("state", ""))
		if state not in ["forming", "marching", "assembling", "active"]:
			continue
		formation["elapsed"] = float(formation.get("elapsed", 0.0)) + delta

		var center: Vector2 = formation.get("center", bounds.get_center())

		# 先在屏幕外完成编组，再整体向目标点行军。
		if state == "forming":
			if float(formation.get("elapsed", 0.0)) >= IRON_BUCKET_ASSEMBLY_DURATION:
				formation["state"] = "marching"
				formation["elapsed"] = 0.0
				var target_center: Vector2 = formation.get("target_center", center)
				formation["drift"] = (target_center - center).normalized() * IRON_BUCKET_MARCH_SPEED
			iron_bucket_formations[formation_index] = formation
			_update_iron_bucket_targets(formation_index)
			continue

		# 处理行军状态：向目标点移动
		if state == "marching":
			var target_center: Vector2 = formation.get("target_center", center)
			var distance_to_target := center.distance_to(target_center)

			if distance_to_target < 50.0:
				# 到达目标，切换到assembling状态
				formation["state"] = "assembling"
				formation["elapsed"] = 0.0
				formation["center"] = target_center
				# 重新计算漂移方向（朝向玩家）
				if has_player_position:
					var to_player := (last_player_position - target_center)
					var distance_to_player := to_player.length()
					if distance_to_player > IRON_BUCKET_DRIFT_KEEP_DISTANCE:
						formation["drift"] = to_player.normalized() * IRON_BUCKET_DRIFT_TRACKING_SPEED
					elif distance_to_player < IRON_BUCKET_DRIFT_KEEP_DISTANCE * 0.7:
						formation["drift"] = -to_player.normalized() * IRON_BUCKET_DRIFT_TRACKING_SPEED * 0.5
					else:
						formation["drift"] = Vector2.ZERO
			else:
				# 继续行军，保持匀速前进
				var march_direction := (target_center - center).normalized()
				formation["center"] = center + march_direction * IRON_BUCKET_MARCH_SPEED * delta

			iron_bucket_formations[formation_index] = formation
			_update_iron_bucket_targets(formation_index)
			continue

		# 只有在 active 状态才旋转，assembling 阶段禁用旋转
		if state == "active":
			formation["rotation_angle"] = float(formation.get("rotation_angle", 0.0)) + float(formation.get("rotation_speed", 0.0)) * delta

		formation["reinforce_cooldown"] = maxf(0.0, float(formation.get("reinforce_cooldown", 0.0)) - delta)
		formation["drift_update_timer"] = float(formation.get("drift_update_timer", 0.0)) + delta

		# 动态更新漂移方向，追踪玩家位置
		if float(formation.get("drift_update_timer", 0.0)) >= IRON_BUCKET_DRIFT_UPDATE_INTERVAL:
			formation["drift_update_timer"] = 0.0
			if has_player_position:
				var to_player := (last_player_position - center)
				var distance_to_player := to_player.length()
				if distance_to_player > IRON_BUCKET_DRIFT_KEEP_DISTANCE:
					# 距离太远，追踪玩家
					formation["drift"] = to_player.normalized() * IRON_BUCKET_DRIFT_TRACKING_SPEED
				elif distance_to_player < IRON_BUCKET_DRIFT_KEEP_DISTANCE * 0.6:
					# 距离太近，稍微后退
					formation["drift"] = -to_player.normalized() * IRON_BUCKET_DRIFT_TRACKING_SPEED * 0.4
				else:
					# 保持当前距离，减慢漂移
					formation["drift"] = to_player.normalized() * IRON_BUCKET_DRIFT_TRACKING_SPEED * 0.2

		var drift: Vector2 = formation.get("drift", Vector2.ZERO)
		var radius := float(formation.get("radius", IRON_BUCKET_MIN_RADIUS))
		center = _resolve_iron_bucket_center_spacing(formation_index, center + drift * delta, radius)
		formation["center"] = center
		if state == "assembling" and float(formation.get("elapsed", 0.0)) >= IRON_BUCKET_ASSEMBLY_DURATION:
			formation["state"] = "active"
		state = str(formation.get("state", ""))

		# 统计内圈和盾兵存活数
		var inner_alive := 0
		for id in formation.get("interior_ids", []):
			if is_active(id):
				inner_alive += 1
		formation["inner_alive"] = inner_alive

		var shields_alive := 0
		for id in formation.get("shield_ids", []):
			if is_active(id):
				shields_alive += 1
		formation["shields_alive"] = shields_alive

		# 检测盾兵之间的大缺口
		if state == "active":
			_detect_iron_bucket_gaps(formation_index)

		# 检查阵型是否崩溃
		if inner_alive <= 0 or float(formation.get("elapsed", 0.0)) >= IRON_BUCKET_LIFETIME:
			var collapsed_at: Vector2 = formation.get("center", Vector2.ZERO)
			formation["state"] = "collapsed"
			iron_bucket_formations[formation_index] = formation
			iron_bucket_collapsed.emit(collapsed_at)
			for id in formation.get("member_ids", []):
				if id >= 0 and id < CAPACITY and iron_bucket_member_formation[id] == formation_index:
					iron_bucket_member_formation[id] = -1
					iron_bucket_member_role[id] = 0
					iron_bucket_member_slot[id] = -1
			continue
		iron_bucket_formations[formation_index] = formation
		_update_iron_bucket_targets(formation_index)
		if player_position.distance_to(formation.get("center", Vector2.ZERO)) < float(formation.get("radius", 0.0)) - 42.0 and not bool(formation.get("player_inside", false)):
			formation["player_inside"] = true
			iron_bucket_player_inside[formation_index] = 1
			iron_bucket_formations[formation_index] = formation
			iron_bucket_entered.emit(formation.get("center", Vector2.ZERO))

func _update_iron_bucket_targets(formation_index: int) -> void:
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return
	var formation: Dictionary = iron_bucket_formations[formation_index]
	var center: Vector2 = formation.get("center", Vector2.ZERO)
	var rotation := float(formation.get("rotation_angle", 0.0))
	var is_marching := str(formation.get("state", "")) in ["forming", "marching"]
	var slots: Array = formation.get("slots", [])
	for id in formation.get("member_ids", []):
		if id < 0 or id >= CAPACITY or not is_active(id):
			continue
		var slot_index := iron_bucket_member_slot[id]
		if slot_index < 0 or slot_index >= slots.size():
			continue
		var local: Vector2 = slots[slot_index].get("local", Vector2.ZERO)
		iron_bucket_local_targets[id] = local
		var target := center + local.rotated(rotation)
		iron_bucket_targets[id] = target if is_marching else _clamp_point(target)

func _detect_iron_bucket_gaps(formation_index: int) -> void:
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return
	var formation: Dictionary = iron_bucket_formations[formation_index]
	var center: Vector2 = formation.get("center", Vector2.ZERO)
	var shield_ids: Array = formation.get("shield_ids", [])

	# 收集所有活着的盾兵位置和角度
	var alive_shields: Array[Dictionary] = []
	for shield_id in shield_ids:
		if shield_id >= 0 and shield_id < CAPACITY and is_active(shield_id):
			var shield_pos := positions[shield_id]
			var angle := (shield_pos - center).angle()
			alive_shields.append({"id": shield_id, "pos": shield_pos, "angle": angle})

	if alive_shields.size() < 2:
		formation["shield_gap_markers"] = []
		iron_bucket_formations[formation_index] = formation
		return

	# 按角度排序
	alive_shields.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("angle", 0.0)) < float(b.get("angle", 0.0))
	)

	# 检测相邻盾兵之间的间距
	var gap_markers: Array[Vector2] = []
	for i in range(alive_shields.size()):
		var current: Dictionary = alive_shields[i]
		var next: Dictionary = alive_shields[(i + 1) % alive_shields.size()]
		var distance := Vector2(current.get("pos", Vector2.ZERO)).distance_to(next.get("pos", Vector2.ZERO))

		# 如果间距超过阈值，标记为大缺口
		if distance > IRON_BUCKET_GAP_THRESHOLD:
			var gap_center := (Vector2(current.get("pos", Vector2.ZERO)) + Vector2(next.get("pos", Vector2.ZERO))) * 0.5
			gap_markers.append(gap_center)

	formation["shield_gap_markers"] = gap_markers
	iron_bucket_formations[formation_index] = formation

func _reinforce_iron_bucket_shields(formation_index: int) -> void:
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return
	var formation: Dictionary = iron_bucket_formations[formation_index]
	var center: Vector2 = formation.get("center", Vector2.ZERO)
	var shield_ids: Array = formation.get("shield_ids", [])
	var slots: Array = formation.get("slots", [])

	# 找出已阵亡的盾兵槽位
	var vacant_slots: Array[int] = []
	for slot_index in range(shield_ids.size()):
		var shield_id: int = shield_ids[slot_index]
		if shield_id < 0 or shield_id >= CAPACITY or not is_active(shield_id):
			vacant_slots.append(slot_index)

	if vacant_slots.is_empty():
		return

	# 寻找周边可用的盾兵
	var available_shields: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or boss_guard_flags[id] == 1:
			continue
		if types[id] != EnemyType.SHIELD:
			continue
		if iron_bucket_member_formation[id] >= 0:
			continue  # 已经在其他阵型中
		if positions[id].distance_to(center) > IRON_BUCKET_REINFORCE_RADIUS:
			continue
		available_shields.append(id)

	if available_shields.is_empty():
		return

	# 按距离排序，优先补充最近的
	available_shields.sort_custom(func(first: int, second: int) -> bool:
		return positions[first].distance_squared_to(center) < positions[second].distance_squared_to(center)
	)

	# 补充盾兵到空缺槽位
	var reinforced_count := 0
	for i in range(mini(vacant_slots.size(), available_shields.size())):
		var slot_index := vacant_slots[i]
		var new_shield_id := available_shields[i]

		# 更新阵型数据
		shield_ids[slot_index] = new_shield_id
		formation["shield_ids"] = shield_ids

		# 更新成员列表
		var member_ids: Array = formation.get("member_ids", [])
		if not member_ids.has(new_shield_id):
			member_ids.append(new_shield_id)
			formation["member_ids"] = member_ids

		# 分配该盾兵到槽位
		iron_bucket_member_formation[new_shield_id] = formation_index
		iron_bucket_member_role[new_shield_id] = 1  # 外圈盾兵
		iron_bucket_member_slot[new_shield_id] = slot_index
		attack_states[new_shield_id] = AttackState.APPROACH
		attack_timers[new_shield_id] = 0.0
		current_attack_kinds[new_shield_id] = ""
		attack_turn_grants[new_shield_id] = 0
		decision_timers[new_shield_id] = 0.0

		reinforced_count += 1

	if reinforced_count > 0:
		iron_bucket_formations[formation_index] = formation
		_update_iron_bucket_targets(formation_index)

func apply_iron_bucket_boundaries(origin: Vector2, candidate: Vector2) -> Vector2:
	if not IRON_BUCKET_ENABLED:
		return candidate
	var resolved := candidate
	for formation_index in range(iron_bucket_formations.size()):
		var formation: Dictionary = iron_bucket_formations[formation_index]
		if str(formation.get("state", "")) not in ["assembling", "active"]:
			continue

		var center: Vector2 = formation.get("center", Vector2.ZERO)
		var wall_radius := maxf(32.0, float(formation.get("radius", IRON_BUCKET_MIN_RADIUS)) - 26.0)
		var origin_distance := origin.distance_to(center)
		var candidate_distance := resolved.distance_to(center)
		var player_inside := bool(formation.get("player_inside", false))
		var crosses_wall := (origin_distance <= wall_radius) != (candidate_distance <= wall_radius)
		if crosses_wall:
			var crossing_point := _segment_circle_entry_point(origin, resolved, center, wall_radius)
			var gap_angle := float(formation.get("gap_angle", 0.0)) + float(formation.get("rotation_angle", 0.0))
			var crossing_angle := (crossing_point - center).angle()
			var gap_width := float(formation.get("gap_width", 1.0)) + 0.16
			if absf(angle_difference(gap_angle, crossing_angle)) > gap_width * 0.5:
				var push_direction := (crossing_point - center).normalized()
				if push_direction.length_squared() <= 0.01:
					push_direction = Vector2.RIGHT
				var safe_radius := wall_radius - 4.0 if origin_distance <= wall_radius else wall_radius + 4.0
				resolved = center + push_direction * safe_radius
			elif candidate_distance <= wall_radius:
				player_inside = true
		elif candidate_distance <= wall_radius:
			player_inside = true
		if player_inside:
			formation["player_inside"] = true
			iron_bucket_player_inside[formation_index] = 1

		iron_bucket_formations[formation_index] = formation

	return resolved

func _segment_circle_entry_point(start: Vector2, end: Vector2, center: Vector2, radius: float) -> Vector2:
	var segment := end - start
	var segment_length_squared := segment.length_squared()
	if segment_length_squared <= 0.0001:
		return end
	var offset := start - center
	var quadratic_b := 2.0 * offset.dot(segment)
	var quadratic_c := offset.length_squared() - radius * radius
	var discriminant := quadratic_b * quadratic_b - 4.0 * segment_length_squared * quadratic_c
	if discriminant < 0.0:
		return end
	var root := sqrt(discriminant)
	var first_t := (-quadratic_b - root) / (2.0 * segment_length_squared)
	var second_t := (-quadratic_b + root) / (2.0 * segment_length_squared)
	var starts_inside := offset.length_squared() <= radius * radius
	var crossing_t := second_t if starts_inside else first_t
	return start + segment * clampf(crossing_t, 0.0, 1.0)

func begin_named_formation(formation_id: String, _center: Vector2) -> void:
	clear_named_formation(false)
	if formation_id not in ["eight_gates", "fish_scale", "bagua"]:
		return
	named_formation_kind = formation_id
	named_formation_origin = _clamp_point(bounds.get_center())
	named_formation_remaining = NAMED_FORMATION_DURATION
	named_formation_elapsed = 0.0
	named_formation_break_open = false
	named_formation_progress = 0
	named_formation_required = NAMED_FORMATION_BREAK_REQUIRED
	named_formation_gate_slots.clear()
	named_formation_break_slots.clear()
	named_formation_gate_index = -1
	named_formation_gate_rotation_remaining = 0.0
	named_formation_slots.clear()
	named_formation_wall_segments.clear()
	for slot_index in range(NAMED_FORMATION_SLOT_CAPACITY):
		named_formation_slot_taken[slot_index] = 0
	var member_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 1 and tianji_lifted[id] == 0:
			member_ids.append(id)
	_build_named_formation_slots(formation_id, member_ids)
	_assign_named_formation_members(formation_id, member_ids)
	# Formation entry is an intentional pause in the enemy attack rhythm. The
	# soldiers keep their current positions while they visibly close ranks.
	for id in member_ids:
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		attack_turn_grants[id] = 0
		decision_timers[id] = 0.0
	if member_ids.size() < NAMED_FORMATION_MIN_MEMBERS:
		push_warning("Named formation %s assembled fewer than %d soldiers (%d)" % [formation_id, NAMED_FORMATION_MIN_MEMBERS, member_ids.size()])

func _append_named_formation_slot(
	local_position: Vector2,
	role: int,
	gate_index: int = -1,
	break_slot: bool = false,
	wall_kind: String = "",
	channel: bool = false
) -> void:
	named_formation_slots.append({
		"local": local_position,
		"role": role,
		"gate": gate_index,
		"break": break_slot,
		"wall": role == NamedFormationRole.SHIELD_WALL,
		"wall_kind": wall_kind,
		"channel": channel,
	})

func _append_named_wall_segment(start: Vector2, end: Vector2, kind: String) -> void:
	named_formation_wall_segments.append({"start": start, "end": end, "kind": kind})

func _append_named_wall_slots(segments: Array[Dictionary], slot_count: int, kind: String, break_every: int = 0, gate_cycle: bool = false) -> void:
	if slot_count <= 0 or segments.is_empty():
		return
	var total_length := 0.0
	for segment in segments:
		var segment_start: Vector2 = segment.get("start", Vector2.ZERO)
		var segment_end: Vector2 = segment.get("end", Vector2.ZERO)
		total_length += segment_end.distance_to(segment_start)
	if total_length <= 0.01:
		return
	for slot_index in range(slot_count):
		var distance := total_length * (float(slot_index) + 0.5) / float(slot_count)
		var selected_start := Vector2.ZERO
		var selected_end := Vector2.ZERO
		for segment in segments:
			var start: Vector2 = segment.get("start", Vector2.ZERO)
			var end: Vector2 = segment.get("end", Vector2.ZERO)
			var segment_length := start.distance_to(end)
			if distance <= segment_length:
				selected_start = start
				selected_end = end
				break
			distance -= segment_length
		var position := selected_start.lerp(selected_end, 0.5 if selected_start.is_equal_approx(selected_end) else clampf(distance / maxf(0.01, selected_start.distance_to(selected_end)), 0.0, 1.0))
		var is_break_slot := break_every > 0 and slot_index % break_every == 0
		var gate_index := slot_index % 8 if gate_cycle else -1
		_append_named_formation_slot(position, NamedFormationRole.SHIELD_WALL, gate_index, is_break_slot, kind)

func _append_named_cell_slot(local_position: Vector2, role: int) -> void:
	_append_named_formation_slot(local_position, role)

func _build_named_formation_slots(formation_id: String, member_ids: Array[int]) -> void:
	var count := member_ids.size()
	if count <= 0:
		return
	# Smaller waves keep the same readable military silhouette instead of
	# leaving a huge, empty rectangle. Large waves use the full battlefield set.
	var formation_scale := clampf(sqrt(float(count) / 118.0), 0.62, 1.0)
	match formation_id:
		"eight_gates":
			# The battlefield itself is the formation board: about 80% of its width
			# and 95% of its height, leaving a deliberate camera-safe margin.
			var width := bounds.size.x * 0.40
			var height := bounds.size.y * 0.475
			var outer_segments: Array[Dictionary] = [
				{"start": Vector2(-width, -height), "end": Vector2(-370.0, -height)},
				{"start": Vector2(-290.0, -height), "end": Vector2(290.0, -height)},
				{"start": Vector2(370.0, -height), "end": Vector2(width, -height)},
				{"start": Vector2(width, -height), "end": Vector2(width, -260.0)},
				{"start": Vector2(width, -180.0), "end": Vector2(width, 180.0)},
				{"start": Vector2(width, 260.0), "end": Vector2(width, height)},
				{"start": Vector2(width, height), "end": Vector2(370.0, height)},
				{"start": Vector2(290.0, height), "end": Vector2(-290.0, height)},
				{"start": Vector2(-370.0, height), "end": Vector2(-width, height)},
				{"start": Vector2(-width, height), "end": Vector2(-width, 260.0)},
				{"start": Vector2(-width, 180.0), "end": Vector2(-width, -180.0)},
				{"start": Vector2(-width, -260.0), "end": Vector2(-width, -height)},
			]
			for segment in outer_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "outer")
			var inner_segments: Array[Dictionary] = [
				{"start": Vector2(-width + 190.0, -height + 220.0), "end": Vector2(width - 230.0, -height + 220.0)},
				{"start": Vector2(width - 230.0, -height + 220.0), "end": Vector2(width - 230.0, -80.0)},
				{"start": Vector2(width - 230.0, -80.0), "end": Vector2(-width + 390.0, -80.0)},
				{"start": Vector2(-width + 390.0, -80.0), "end": Vector2(-width + 390.0, 180.0)},
				{"start": Vector2(-width + 390.0, 180.0), "end": Vector2(width - 390.0, 180.0)},
				{"start": Vector2(width - 390.0, 180.0), "end": Vector2(width - 390.0, height - 220.0)},
				{"start": Vector2(width - 390.0, height - 220.0), "end": Vector2(-width + 230.0, height - 220.0)},
				{"start": Vector2(-width + 230.0, height - 220.0), "end": Vector2(-width + 230.0, 300.0)},
			]
			for segment in inner_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "inner")
			var wall_count := clampi(roundi(float(count) * 0.62), 20, 90)
			var inner_wall_count := clampi(roundi(float(count) * 0.20), 8, 40)
			_append_named_wall_slots(outer_segments, wall_count, "outer", 6, true)
			_append_named_wall_slots(inner_segments, inner_wall_count, "inner", 5)
			for row in range(4):
				for column in range(5):
					var cell_x := (float(column) - 2.0) * 220.0
					var cell_y := -height + 360.0 + float(row) * 178.0
					_append_named_cell_slot(Vector2(cell_x, cell_y), NamedFormationRole.SPEAR if row % 2 == 0 else NamedFormationRole.FRONT)
			for side in [-1.0, 1.0]:
				for row in range(4):
					_append_named_formation_slot(Vector2(side * (width - 150.0), -height + 270.0 + float(row) * 330.0), NamedFormationRole.CAVALRY_CHANNEL, -1, false, "", true)
			for row in range(2):
				for column in range(7):
					_append_named_cell_slot(Vector2((float(column) - 3.0) * 190.0, -height + 96.0 + float(row) * 82.0), NamedFormationRole.RANGED)
		"fish_scale":
			var width := 590.0 * formation_scale
			var height := 330.0 * formation_scale
			var outer_segments: Array[Dictionary] = [
				{"start": Vector2(-width, 0.0), "end": Vector2(0.0, -height)},
				{"start": Vector2(0.0, -height), "end": Vector2(width, 0.0)},
				{"start": Vector2(width, 0.0), "end": Vector2(0.0, height)},
				{"start": Vector2(0.0, height), "end": Vector2(-width, 0.0)},
			]
			for segment in outer_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "outer")
			var inner_segments: Array[Dictionary] = []
			for row in range(5):
				var y := (float(row) - 2.0) * 104.0 * formation_scale
				var x := (float(row) - 2.0) * 88.0 * formation_scale
				inner_segments.append({"start": Vector2(-350.0 * formation_scale, y), "end": Vector2(-x, y - 92.0 * formation_scale)})
				inner_segments.append({"start": Vector2(x, y - 92.0 * formation_scale), "end": Vector2(350.0 * formation_scale, y)})
			for segment in inner_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "inner")
			_append_named_wall_slots(outer_segments, clampi(roundi(float(count) * 0.28), 12, 48), "outer", 6)
			_append_named_wall_slots(inner_segments, clampi(roundi(float(count) * 0.22), 8, 36), "inner", 5)
			for row in range(5):
				var y := (float(row) - 2.0) * 96.0 * formation_scale
				var stagger := 46.0 * formation_scale if row % 2 == 1 else 0.0
				for column in range(4):
					var x := (float(column) - 1.5) * 160.0 * formation_scale + stagger
					_append_named_cell_slot(Vector2(x, y), NamedFormationRole.SPEAR if row < 3 else NamedFormationRole.FRONT)
			for side in [-1.0, 1.0]:
				for row in range(3):
					_append_named_formation_slot(Vector2(side * 448.0 * formation_scale, (float(row) - 1.0) * 116.0 * formation_scale), NamedFormationRole.CAVALRY_CHANNEL, -1, false, "", true)
			for row in range(2):
				for column in range(5):
					_append_named_cell_slot(Vector2((float(column) - 2.0) * 128.0 * formation_scale, (-210.0 + float(row) * 62.0) * formation_scale), NamedFormationRole.RANGED)
		"bagua":
			var width := 600.0 * formation_scale
			var height := 350.0 * formation_scale
			var outer_segments: Array[Dictionary] = [
				{"start": Vector2(-width, -height), "end": Vector2(width, -height)},
				{"start": Vector2(width, -height), "end": Vector2(width, height)},
				{"start": Vector2(width, height), "end": Vector2(-width, height)},
				{"start": Vector2(-width, height), "end": Vector2(-width, -height)},
			]
			for segment in outer_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "outer")
			var inner_segments: Array[Dictionary] = [
				{"start": Vector2(-410.0 * formation_scale, -210.0 * formation_scale), "end": Vector2(260.0 * formation_scale, -210.0 * formation_scale)},
				{"start": Vector2(410.0 * formation_scale, -210.0 * formation_scale), "end": Vector2(410.0 * formation_scale, 170.0 * formation_scale)},
				{"start": Vector2(410.0 * formation_scale, 210.0 * formation_scale), "end": Vector2(-260.0 * formation_scale, 210.0 * formation_scale)},
				{"start": Vector2(-410.0 * formation_scale, 210.0 * formation_scale), "end": Vector2(-410.0 * formation_scale, -170.0 * formation_scale)},
				{"start": Vector2(-245.0 * formation_scale, -112.0 * formation_scale), "end": Vector2(245.0 * formation_scale, -112.0 * formation_scale)},
				{"start": Vector2(245.0 * formation_scale, -112.0 * formation_scale), "end": Vector2(245.0 * formation_scale, 112.0 * formation_scale)},
				{"start": Vector2(245.0 * formation_scale, 112.0 * formation_scale), "end": Vector2(-245.0 * formation_scale, 112.0 * formation_scale)},
				{"start": Vector2(-245.0 * formation_scale, 112.0 * formation_scale), "end": Vector2(-245.0 * formation_scale, -30.0 * formation_scale)},
			]
			for segment in inner_segments:
				_append_named_wall_segment(segment["start"], segment["end"], "inner")
			_append_named_wall_slots(outer_segments, clampi(roundi(float(count) * 0.30), 12, 52), "outer", 6, true)
			_append_named_wall_slots(inner_segments, clampi(roundi(float(count) * 0.24), 8, 42), "inner", 5)
			for row in range(3):
				for column in range(4):
					_append_named_cell_slot(Vector2((float(column) - 1.5) * 118.0 * formation_scale, (float(row) - 1.0) * 84.0 * formation_scale), NamedFormationRole.SPEAR if row != 1 else NamedFormationRole.FRONT)
			for row in range(2):
				for column in range(5):
					_append_named_cell_slot(Vector2((float(column) - 2.0) * 118.0 * formation_scale, (-292.0 + float(row) * 60.0) * formation_scale), NamedFormationRole.RANGED)
			for side in [-1.0, 1.0]:
				for row in range(3):
					_append_named_formation_slot(Vector2(side * 460.0 * formation_scale, (float(row) - 1.0) * 114.0 * formation_scale), NamedFormationRole.CAVALRY_CHANNEL, -1, false, "", true)
	_fit_named_formation_slots(count)
	while named_formation_slots.size() < count:
		var extra_index := named_formation_slots.size()
		var extra_column := extra_index % 9
		var extra_row := floori(float(extra_index) / 9.0)
		var extra_x := (float(extra_column) - 4.0) * 76.0
		var extra_y := (float(extra_row % 5) - 2.0) * 72.0
		_append_named_formation_slot(Vector2(extra_x, extra_y), NamedFormationRole.RESERVE)

func _fit_named_formation_slots(max_count: int) -> void:
	if named_formation_slots.size() <= max_count:
		return
	var buckets: Dictionary = {}
	for index in range(named_formation_slots.size()):
		var role := int(named_formation_slots[index].get("role", NamedFormationRole.RESERVE))
		var indices: Array = buckets.get(role, [])
		indices.append(index)
		buckets[role] = indices
	var selected_indices: Array[int] = []
	var wall_indices: Array = buckets.get(NamedFormationRole.SHIELD_WALL, [])
	var ranged_indices: Array = buckets.get(NamedFormationRole.RANGED, [])
	var cavalry_indices: Array = buckets.get(NamedFormationRole.CAVALRY_CHANNEL, [])
	var remaining := max_count
	var wall_amount := mini(wall_indices.size(), maxi(8, roundi(float(max_count) * 0.60)))
	_take_named_slot_indices(wall_indices, mini(wall_amount, remaining), selected_indices)
	remaining = maxi(0, max_count - selected_indices.size())
	var ranged_amount := mini(ranged_indices.size(), maxi(2, roundi(float(max_count) * 0.12)))
	_take_named_slot_indices(ranged_indices, mini(ranged_amount, remaining), selected_indices)
	remaining = maxi(0, max_count - selected_indices.size())
	var cavalry_amount := mini(cavalry_indices.size(), maxi(2, roundi(float(max_count) * 0.10)))
	_take_named_slot_indices(cavalry_indices, mini(cavalry_amount, remaining), selected_indices)
	for role in [NamedFormationRole.FRONT, NamedFormationRole.SPEAR, NamedFormationRole.FLANK, NamedFormationRole.RESERVE]:
		if selected_indices.size() >= max_count:
			break
		var role_indices: Array = buckets.get(role, [])
		_take_named_slot_indices(role_indices, mini(role_indices.size(), max_count - selected_indices.size()), selected_indices)
	if selected_indices.size() < max_count:
		for index in range(named_formation_slots.size()):
			if selected_indices.size() >= max_count:
				break
			if not selected_indices.has(index):
				selected_indices.append(index)
	var fitted_slots: Array[Dictionary] = []
	for index in selected_indices:
		fitted_slots.append(named_formation_slots[index])
	named_formation_slots = fitted_slots

func _take_named_slot_indices(indices: Array, amount: int, selected_indices: Array[int]) -> void:
	var selected_amount := mini(amount, indices.size())
	if selected_amount <= 0:
		return
	if selected_amount == 1:
		var only_slot: int = indices[0]
		if not selected_indices.has(only_slot):
			selected_indices.append(only_slot)
		return
	for index in range(selected_amount):
		# Spread the retained slots across the entire wall/role group. This keeps
		# both the outer perimeter and the inner turns represented in small waves.
		var source_index := roundi(float(index) * float(indices.size() - 1) / float(selected_amount - 1))
		var slot_index: int = indices[source_index]
		if not selected_indices.has(slot_index):
			selected_indices.append(slot_index)

func _assign_named_formation_members(_formation_id: String, member_ids: Array[int]) -> void:
	var assigned: Dictionary = {}
	var gate_leaders: Dictionary = {}
	var unassigned_slots: Array[int] = []
	for id in member_ids:
		named_formation_members[id] = 1
		named_formation_critical[id] = 0
		named_formation_slot_index[id] = -1
	for slot_index in range(named_formation_slots.size()):
		var slot := named_formation_slots[slot_index]
		var chosen_id := -1
		for id in member_ids:
			if assigned.has(id):
				continue
			if _named_formation_type_matches(int(slot.get("role", NamedFormationRole.RESERVE)), types[id]):
				chosen_id = id
				break
		if chosen_id < 0:
			# A vacant shield or cavalry lane is intentional.  Do not let a sword or
			# spear occupy it and create a wall that has no shield-wall properties.
			var role := int(slot.get("role", NamedFormationRole.RESERVE))
			if role != NamedFormationRole.SHIELD_WALL and role != NamedFormationRole.CAVALRY_CHANNEL:
				unassigned_slots.append(slot_index)
			continue
		assigned[chosen_id] = true
		_bind_named_formation_slot(chosen_id, slot_index, gate_leaders)
	for slot_index in unassigned_slots:
		var fallback_id := -1
		for id in member_ids:
			if not assigned.has(id):
				fallback_id = id
				break
		if fallback_id < 0:
			break
		assigned[fallback_id] = true
		_bind_named_formation_slot(fallback_id, slot_index, gate_leaders)
	# Keep every living soldier under formation control even when the wave has
	# fewer shields or cavalry than the authored architecture expects.  These
	# reserve slots are inside the maze and never masquerade as wall positions.
	var reserve_index := 0
	for id in member_ids:
		if named_formation_slot_index[id] >= 0:
			continue
		var reserve_column := reserve_index % 9
		var reserve_row := floori(float(reserve_index) / 9.0)
		var reserve_local := Vector2((float(reserve_column) - 4.0) * 76.0, (float(reserve_row % 5) - 2.0) * 72.0)
		_append_named_formation_slot(reserve_local, NamedFormationRole.RESERVE)
		var reserve_slot_index := named_formation_slots.size() - 1
		_bind_named_formation_slot(id, reserve_slot_index, gate_leaders)
		reserve_index += 1

func _bind_named_formation_slot(id: int, slot_index: int, gate_leaders: Dictionary) -> void:
	var slot := named_formation_slots[slot_index]
	named_formation_slot_taken[slot_index] = 1
	named_formation_slot_index[id] = slot_index
	var local_position: Vector2 = slot.get("local", Vector2.ZERO)
	named_formation_local_targets[id] = local_position
	named_formation_targets[id] = _clamp_point(named_formation_origin + local_position)
	var gate_index := int(slot.get("gate", -1))
	if bool(slot.get("break", false)) and not named_formation_break_slots.has(id):
		named_formation_break_slots.append(id)
	if gate_index >= 0 and not gate_leaders.has(gate_index):
		gate_leaders[gate_index] = id
		named_formation_gate_slots.append(id)
		if not named_formation_break_slots.has(id):
			named_formation_break_slots.append(id)

func _assign_enemy_to_named_formation(id: int, preferred_slot: int = -1) -> void:
	if not is_named_formation_active() or id < 0 or id >= CAPACITY or active[id] == 0:
		return
	var selected_slot := preferred_slot if preferred_slot >= 0 and preferred_slot < named_formation_slots.size() and named_formation_slot_taken[preferred_slot] == 0 else -1
	if selected_slot >= 0:
		var preferred := named_formation_slots[selected_slot]
		if not _named_formation_type_matches(int(preferred.get("role", NamedFormationRole.RESERVE)), types[id]):
			selected_slot = -1
	for slot_index in range(named_formation_slots.size()):
		if selected_slot >= 0:
			break
		if named_formation_slot_taken[slot_index] == 1:
			continue
		var slot := named_formation_slots[slot_index]
		if _named_formation_type_matches(int(slot.get("role", NamedFormationRole.RESERVE)), types[id]):
			selected_slot = slot_index
			break
	if selected_slot < 0:
		for slot_index in range(named_formation_slots.size()):
			if named_formation_slot_taken[slot_index] == 0:
				var fallback_role := int(named_formation_slots[slot_index].get("role", NamedFormationRole.RESERVE))
				if fallback_role == NamedFormationRole.SHIELD_WALL or fallback_role == NamedFormationRole.CAVALRY_CHANNEL:
					continue
				selected_slot = slot_index
				break
	if selected_slot < 0:
		# A reinforcement can arrive after all authored interior slots are full.
		# Add one interior reserve slot instead of filling a protected wall lane.
		var reserve_index := id % 9
		var reserve_row := floori(float(id) / 9.0)
		_append_named_formation_slot(Vector2((float(reserve_index) - 4.0) * 76.0, (float(reserve_row % 5) - 2.0) * 72.0), NamedFormationRole.RESERVE)
		selected_slot = named_formation_slots.size() - 1
	if selected_slot < 0:
		return
	var slot := named_formation_slots[selected_slot]
	named_formation_slot_taken[selected_slot] = 1
	named_formation_members[id] = 1
	named_formation_critical[id] = 0
	named_formation_slot_index[id] = selected_slot
	named_formation_local_targets[id] = slot.get("local", Vector2.ZERO)
	named_formation_targets[id] = _clamp_point(named_formation_origin + named_formation_local_targets[id])
	attack_turn_grants[id] = 0
	decision_timers[id] = 0.0

func _refill_named_formation_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= named_formation_slots.size() or named_formation_slot_taken[slot_index] == 1:
		return
	var candidates: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 1 and tianji_lifted[id] == 0 and named_formation_members[id] == 0:
			candidates.append(id)
	if candidates.is_empty():
		return
	var slot := named_formation_slots[slot_index]
	var role := int(slot.get("role", NamedFormationRole.RESERVE))
	for id in candidates:
		if _named_formation_type_matches(role, types[id]):
			_assign_enemy_to_named_formation(id, slot_index)
			return
	_assign_enemy_to_named_formation(candidates[0], slot_index)

func _named_formation_type_matches(role: int, enemy_type: int) -> bool:
	match role:
		NamedFormationRole.FRONT:
			return enemy_type in [EnemyType.SHIELD, EnemyType.GUARD, EnemyType.HALBERD, EnemyType.SWORD]
		NamedFormationRole.SPEAR:
			return enemy_type in [EnemyType.SPEAR, EnemyType.HALBERD, EnemyType.GUARD, EnemyType.SWORD]
		NamedFormationRole.RANGED:
			return enemy_type in [EnemyType.ARCHER, EnemyType.CROSSBOW]
		NamedFormationRole.FLANK:
			return enemy_type in [EnemyType.CAVALRY, EnemyType.HALBERD, EnemyType.SPEAR]
		NamedFormationRole.RESERVE:
			return true
		NamedFormationRole.SHIELD_WALL:
			return enemy_type == EnemyType.SHIELD
		NamedFormationRole.CAVALRY_CHANNEL:
			return enemy_type == EnemyType.CAVALRY
		_:
			return true

func clear_named_formation(emit_break_signal: bool = true) -> void:
	var was_active := is_named_formation_active()
	var previous_kind := named_formation_kind
	named_formation_kind = ""
	named_formation_remaining = 0.0
	named_formation_elapsed = 0.0
	named_formation_break_open = false
	named_formation_progress = 0
	named_formation_gate_slots.clear()
	named_formation_break_slots.clear()
	named_formation_gate_index = -1
	named_formation_gate_rotation_remaining = 0.0
	named_formation_slots.clear()
	named_formation_wall_segments.clear()
	for slot_index in range(NAMED_FORMATION_SLOT_CAPACITY):
		named_formation_slot_taken[slot_index] = 0
	for id in range(CAPACITY):
		named_formation_members[id] = 0
		named_formation_critical[id] = 0
		named_formation_targets[id] = Vector2.ZERO
		named_formation_local_targets[id] = Vector2.ZERO
		named_formation_slot_index[id] = -1
	if was_active and emit_break_signal:
		named_formation_broken.emit(previous_kind)

func _named_formation_point(angle: float, radius: float) -> Vector2:
	return _clamp_point(named_formation_origin + Vector2.from_angle(angle) * radius)

func _named_formation_member_count() -> int:
	var count := 0
	for id in range(CAPACITY):
		if named_formation_members[id] == 1:
			count += 1
	return count

func _open_named_formation_break_window() -> void:
	if not is_named_formation_active() or named_formation_break_open:
		return
	named_formation_break_open = true
	for id in range(CAPACITY):
		named_formation_critical[id] = 0
	for id in named_formation_break_slots:
		if id >= 0 and id < CAPACITY and named_formation_members[id] == 1:
			named_formation_critical[id] = 1
	var critical_count := 0
	for id in range(CAPACITY):
		if named_formation_critical[id] == 1:
			critical_count += 1
	if critical_count < 4:
		for id in range(CAPACITY):
			if critical_count >= 4:
				break
			if named_formation_members[id] == 1 and named_formation_critical[id] == 0:
				named_formation_critical[id] = 1
				critical_count += 1
	if named_formation_kind == "bagua":
		_activate_bagua_gate(0)
	named_formation_break_opened.emit(named_formation_kind)

func _update_named_formation_targets() -> void:
	if not is_named_formation_active():
		return
	var active_elapsed := maxf(0.0, named_formation_elapsed - NAMED_FORMATION_ASSEMBLY_DURATION)
	var phase := active_elapsed / NAMED_FORMATION_DURATION
	var rotation := 0.0
	var drift := Vector2.ZERO
	match named_formation_kind:
		"eight_gates":
			rotation = sin(phase * TAU * 1.15) * 0.08
			drift = Vector2(sin(phase * TAU * 1.4) * 24.0, cos(phase * TAU * 1.1) * 10.0)
		"fish_scale":
			drift = Vector2(sin(phase * TAU * 1.5) * 32.0, 0.0)
		"bagua":
			rotation = phase * TAU * 0.72
	for id in range(CAPACITY):
		if named_formation_members[id] != 1:
			continue
		var slot_index := named_formation_slot_index[id]
		var slot: Dictionary = {}
		if slot_index >= 0 and slot_index < named_formation_slots.size():
			slot = named_formation_slots[slot_index]
		var role := int(slot.get("role", NamedFormationRole.RESERVE))
		var gate_index := int(slot.get("gate", -1))
		var is_wall := bool(slot.get("wall", false))
		var transformed := named_formation_local_targets[id].rotated(rotation) + drift
		var command_phase := fposmod(active_elapsed, 10.0) / 10.0
		if is_wall:
			# Shield walls are the fixed architecture of the formation. Infantry
			# inside the cells can shift, but a wall must remain visually coherent.
			transformed = named_formation_local_targets[id]
		elif named_formation_kind == "eight_gates" and gate_index >= 0:
			var gate_wave := sin(command_phase * TAU + float(gate_index) * PI * 0.25)
			var outward := named_formation_local_targets[id].normalized()
			transformed += outward * gate_wave * 26.0
		elif named_formation_kind == "fish_scale":
			var row_wave := sin(command_phase * TAU + absf(named_formation_local_targets[id].x) * 0.003)
			if role == NamedFormationRole.FRONT:
				transformed += Vector2(0.0, maxf(0.0, row_wave) * 36.0)
			elif role == NamedFormationRole.SPEAR:
				transformed += Vector2(0.0, maxf(0.0, row_wave - 0.25) * 22.0)
			transformed.x += signf(named_formation_local_targets[id].x) * sin(command_phase * TAU) * 12.0
		elif named_formation_kind == "bagua":
			var ring_rotation := rotation
			if role == NamedFormationRole.SPEAR:
				ring_rotation = -rotation * 0.72
			elif role == NamedFormationRole.RANGED:
				ring_rotation = rotation * 0.42
			transformed = named_formation_local_targets[id].rotated(ring_rotation) + drift * 0.4
		named_formation_targets[id] = _clamp_point(named_formation_origin + transformed)

func _activate_bagua_gate(start_index: int) -> void:
	if named_formation_kind != "bagua" or not named_formation_break_open or named_formation_gate_slots.is_empty():
		return
	for id in range(CAPACITY):
		if named_formation_members[id] == 1:
			named_formation_critical[id] = 0
	for offset in range(named_formation_gate_slots.size()):
		var gate_index := posmod(start_index + offset, named_formation_gate_slots.size())
		var gate_id := named_formation_gate_slots[gate_index]
		if not is_active(gate_id):
			continue
		named_formation_gate_index = gate_index
		named_formation_critical[gate_id] = 1
		named_formation_gate_rotation_remaining = BAGUA_GATE_ROTATE_INTERVAL
		named_formation_gate_changed.emit(positions[gate_id])
		return
	named_formation_gate_index = -1
	named_formation_gate_rotation_remaining = 0.0

func duel_damage_multiplier(id: int) -> float:
	if not is_duel_formation_active():
		return 1.0
	if is_duel_shield(id):
		# Shields can still be pressured while the ring is assembling.  They only
		# become fully invulnerable once the formation has actually sealed.
		return 0.0 if is_duel_formation_sealed() else DUEL_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER
	return DUEL_FORMATION_DAMAGE_MULTIPLIER if types[id] != EnemyType.ELITE else 1.0

func is_named_formation_shield_wall(id: int) -> bool:
	if not is_named_formation_member(id) or id < 0 or id >= CAPACITY:
		return false
	var slot_index := named_formation_slot_index[id]
	if slot_index < 0 or slot_index >= named_formation_slots.size():
		return false
	var slot: Dictionary = named_formation_slots[slot_index]
	return bool(slot.get("wall", false)) and types[id] == EnemyType.SHIELD

func is_named_formation_cavalry_channel(id: int) -> bool:
	if not is_named_formation_member(id) or types[id] != EnemyType.CAVALRY:
		return false
	var slot_index := named_formation_slot_index[id]
	if slot_index < 0 or slot_index >= named_formation_slots.size():
		return false
	return bool(named_formation_slots[slot_index].get("channel", false))

func named_formation_damage_multiplier(id: int) -> float:
	if not is_named_formation_shield_wall(id):
		return 1.0
	return NAMED_FORMATION_ASSEMBLING_SHIELD_DAMAGE_MULTIPLIER if named_formation_elapsed < NAMED_FORMATION_ASSEMBLY_DURATION else NAMED_FORMATION_SHIELD_DAMAGE_MULTIPLIER

func block_named_formation_shield_hit(id: int) -> void:
	if not is_named_formation_shield_wall(id):
		return
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.76)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.12)
	hit_feedback_timers[id] = hit_feedback_durations[id]

func apply_named_formation_shield_boundary(origin: Vector2, candidate: Vector2) -> Vector2:
	if not is_named_formation_active() or named_formation_elapsed < NAMED_FORMATION_ASSEMBLY_DURATION:
		return candidate
	var resolved := candidate
	var staffed_wall_slots := _named_formation_staffed_wall_slots()
	for segment in named_formation_wall_segments:
		var segment_start: Vector2 = named_formation_origin + segment.get("start", Vector2.ZERO)
		var segment_end: Vector2 = named_formation_origin + segment.get("end", Vector2.ZERO)
		# A partially staffed wall is a real breach, not an invisible barrier.
		# Individual shields still push the hero through the body-radius pass below;
		# only a continuously staffed segment gets the stronger line collision.
		if not _named_wall_segment_is_fully_staffed(segment.get("start", Vector2.ZERO), segment.get("end", Vector2.ZERO), staffed_wall_slots):
			continue
		var nearest := _nearest_point_on_named_segment(resolved, segment_start, segment_end)
		var candidate_distance := resolved.distance_to(nearest)
		if candidate_distance > NAMED_FORMATION_SHIELD_PUSH_RADIUS:
			continue
		var line_direction := (segment_end - segment_start).normalized()
		if line_direction.length_squared() <= 0.01:
			continue
		var line_normal := line_direction.rotated(PI * 0.5)
		var origin_side := (origin - nearest).dot(line_normal)
		var candidate_side := (resolved - nearest).dot(line_normal)
		var side_sign := signf(candidate_side)
		if absf(side_sign) <= 0.01:
			side_sign = signf(origin_side)
		if absf(side_sign) <= 0.01:
			side_sign = 1.0
		# Crossing a wall keeps the hero on the side they started from. Moving
		# parallel to it simply resolves to the nearest side and feels like sliding.
		if absf(origin_side) > 4.0 and origin_side * candidate_side < 0.0:
			side_sign = signf(origin_side)
		resolved = nearest + line_normal * side_sign * NAMED_FORMATION_SHIELD_PUSH_RADIUS
	for id in range(CAPACITY):
		if not is_named_formation_shield_wall(id) or active[id] == 0:
			continue
		var offset := resolved - positions[id]
		var distance := offset.length()
		if distance >= NAMED_FORMATION_SHIELD_PUSH_RADIUS:
			continue
		var push_direction := offset.normalized()
		if push_direction.length_squared() <= 0.01:
			push_direction = (origin - positions[id]).normalized()
		if push_direction.length_squared() <= 0.01:
			push_direction = Vector2.UP
		# When crossing a wall, keep the hero on the side they entered from;
		# this makes the line feel solid while still allowing dead shields to open.
		if origin.distance_to(positions[id]) > NAMED_FORMATION_SHIELD_PUSH_RADIUS * 0.84:
			push_direction = (origin - positions[id]).normalized()
		resolved = positions[id] + push_direction * NAMED_FORMATION_SHIELD_PUSH_RADIUS
	return _clamp_point(resolved)

func _named_formation_staffed_wall_slots() -> PackedByteArray:
	var staffed := PackedByteArray()
	staffed.resize(named_formation_slots.size())
	for id in range(CAPACITY):
		if active[id] == 0 or named_formation_members[id] == 0 or types[id] != EnemyType.SHIELD:
			continue
		var slot_index := named_formation_slot_index[id]
		if slot_index >= 0 and slot_index < named_formation_slots.size() and bool(named_formation_slots[slot_index].get("wall", false)):
			staffed[slot_index] = 1
	return staffed

func _named_wall_segment_is_fully_staffed(start: Vector2, end: Vector2, staffed_wall_slots: PackedByteArray) -> bool:
	var staffed_count := 0
	var segment_slot_count := 0
	for slot_index in range(named_formation_slots.size()):
		var slot: Dictionary = named_formation_slots[slot_index]
		if not bool(slot.get("wall", false)):
			continue
		var local_position: Vector2 = slot.get("local", Vector2.ZERO)
		var nearest := _nearest_point_on_named_segment(local_position, start, end)
		if local_position.distance_squared_to(nearest) > 30.0 * 30.0:
			continue
		segment_slot_count += 1
		if slot_index < staffed_wall_slots.size() and staffed_wall_slots[slot_index] == 1:
			staffed_count += 1
	return segment_slot_count >= 2 and staffed_count == segment_slot_count

func _nearest_point_on_named_segment(point: Vector2, start: Vector2, end: Vector2) -> Vector2:
	var segment := end - start
	var segment_length_squared := segment.length_squared()
	if segment_length_squared <= 0.01:
		return start
	var ratio := clampf((point - start).dot(segment) / segment_length_squared, 0.0, 1.0)
	return start + segment * ratio

func consume_duel_fodder_reward(id: int) -> bool:
	if id < 0 or id >= CAPACITY:
		return false
	var was_fodder := bool(duel_fodder_death_ids.get(id, false))
	duel_fodder_death_ids.erase(id)
	return was_fodder

func _assign_duel_role_slots(role: int, slot_count: int) -> void:
	for slot in range(slot_count):
		var assigned_id := _find_duel_member_for_slot(role, slot)
		if assigned_id < 0:
			assigned_id = spawn(_duel_reinforcement_type(role, slot), _duel_reinforcement_position(role, slot))
		if assigned_id < 0:
			continue
		duel_roles[assigned_id] = role
		duel_slots[assigned_id] = slot
		decision_timers[assigned_id] = 0.0

func _find_duel_member_for_slot(role: int, slot: int) -> int:
	var desired_position := _duel_slot_position(role, slot)
	var selected_id := -1
	var selected_distance := INF
	for id in range(CAPACITY):
		if active[id] == 0 or duel_roles[id] != DuelRole.NONE or boss_guard_flags[id] == 1:
			continue
		if not _is_duel_role_type(role, types[id]):
			continue
		var distance := positions[id].distance_squared_to(desired_position)
		if distance < selected_distance:
			selected_id = id
			selected_distance = distance
	return selected_id

func _is_duel_role_type(role: int, enemy_type: int) -> bool:
	match role:
		DuelRole.SHIELD_RING: return enemy_type == EnemyType.SHIELD
		DuelRole.SPEAR_RING: return enemy_type == EnemyType.SPEAR
		DuelRole.RANGED_RING: return enemy_type == EnemyType.ARCHER or enemy_type == EnemyType.CROSSBOW
	return false

func _duel_reinforcement_type(role: int, slot: int) -> int:
	match role:
		DuelRole.SHIELD_RING: return EnemyType.SHIELD
		DuelRole.SPEAR_RING: return EnemyType.SPEAR
		DuelRole.RANGED_RING: return EnemyType.CROSSBOW if slot % 2 == 0 else EnemyType.ARCHER
	return EnemyType.SWORD

func _duel_reinforcement_position(role: int, slot: int) -> Vector2:
	var slot_position := _duel_slot_position(role, slot)
	if role == DuelRole.SHIELD_RING:
		return _duel_offscreen_position(_duel_shield_slot_side(slot), slot_position)
	if role == DuelRole.SPEAR_RING or role == DuelRole.RANGED_RING:
		return _duel_offscreen_position(_duel_support_side_for_slot(role, slot), slot_position)
	var outward := (slot_position - duel_center).normalized()
	if outward.length_squared() <= 0.01:
		outward = Vector2.RIGHT
	return _clamp_point(duel_center + outward * 460.0)

func _duel_offscreen_position(side: int, slot_position: Vector2) -> Vector2:
	match side:
		DUEL_WALL_SIDE_LEFT:
			return Vector2(bounds.position.x - 96.0, slot_position.y)
		DUEL_WALL_SIDE_RIGHT:
			return Vector2(bounds.end.x + 96.0, slot_position.y)
		DUEL_WALL_SIDE_TOP:
			return Vector2(slot_position.x, bounds.position.y - 96.0)
		_:
			return Vector2(slot_position.x, bounds.end.y + 96.0)

func _duel_slot_position(role: int, slot: int) -> Vector2:
	if role == DuelRole.SHIELD_RING and slot >= 0 and slot < DUEL_SHIELD_SLOTS:
		var wall_side := _duel_shield_slot_side(slot)
		var wall_index := _duel_shield_slot_index(slot)
		match wall_side:
			DUEL_WALL_SIDE_LEFT:
				return Vector2(bounds.position.x + bounds.size.x * duel_wall_left_percent, _duel_wall_y(wall_index, DUEL_WALL_SHIELDS_PER_SIDE))
			DUEL_WALL_SIDE_RIGHT:
				return Vector2(bounds.position.x + bounds.size.x * duel_wall_right_percent, _duel_wall_y(wall_index, DUEL_WALL_SHIELDS_PER_SIDE))
			DUEL_WALL_SIDE_TOP:
				return Vector2(_duel_wall_x(wall_index, DUEL_WALL_SHIELDS_PER_SIDE), bounds.position.y + bounds.size.y * duel_wall_top_percent)
			_:
				return Vector2(_duel_wall_x(wall_index, DUEL_WALL_SHIELDS_PER_SIDE), bounds.position.y + bounds.size.y * duel_wall_bottom_percent)
	if role == DuelRole.SPEAR_RING and slot >= 0 and slot < DUEL_SPEAR_SLOTS:
		return _duel_support_slot_position(role, slot)
	if role == DuelRole.RANGED_RING and slot >= 0 and slot < DUEL_RANGED_SLOTS:
		return _duel_support_slot_position(role, slot)
	var slot_count := _duel_slot_count(role)
	if slot_count <= 0:
		return duel_center
	var angle := TAU * (float(slot) + 0.5) / float(slot_count)
	var radii := _duel_role_radius(role)
	return _clamp_point(duel_center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))

func _duel_shield_slot_side(slot: int) -> int:
	if slot < DUEL_WALL_SHIELDS_PER_SIDE:
		return DUEL_WALL_SIDE_LEFT
	if slot < DUEL_WALL_SHIELDS_PER_SIDE * 2:
		return DUEL_WALL_SIDE_RIGHT
	if slot < DUEL_WALL_SHIELDS_PER_SIDE * 3:
		return DUEL_WALL_SIDE_TOP
	return DUEL_WALL_SIDE_BOTTOM

func _duel_shield_slot_index(slot: int) -> int:
	return posmod(slot, DUEL_WALL_SHIELDS_PER_SIDE)

func _duel_support_capacity(role: int, side: int) -> int:
	if role == DuelRole.SPEAR_RING:
		return DUEL_WALL_SUPPORT_SPEARS_PER_SIDE if side == DUEL_WALL_SIDE_LEFT or side == DUEL_WALL_SIDE_RIGHT else DUEL_WALL_SUPPORT_SPEARS_PER_TOP_BOTTOM
	if role == DuelRole.RANGED_RING:
		return DUEL_WALL_SUPPORT_RANGED_PER_SIDE if side == DUEL_WALL_SIDE_LEFT or side == DUEL_WALL_SIDE_RIGHT else DUEL_WALL_SUPPORT_RANGED_PER_TOP_BOTTOM
	return 0

func _duel_support_slot_offset(role: int, side: int) -> int:
	var offset := 0
	for previous_side in range(side):
		offset += _duel_support_capacity(role, previous_side)
	return offset

func _duel_support_side_for_slot(role: int, slot: int) -> int:
	var remaining_slot := slot
	for side in range(DUEL_WALL_SIDE_BOTTOM + 1):
		var capacity := _duel_support_capacity(role, side)
		if remaining_slot < capacity:
			return side
		remaining_slot -= capacity
	return DUEL_WALL_SIDE_BOTTOM

func _duel_support_slot_index(role: int, slot: int) -> int:
	return slot - _duel_support_slot_offset(role, _duel_support_side_for_slot(role, slot))

func _duel_support_slot_position(role: int, slot: int) -> Vector2:
	var side := _duel_support_side_for_slot(role, slot)
	var side_slot := _duel_support_slot_index(role, slot)
	var capacity := _duel_support_capacity(role, side)
	var outward_depth := 70.0 if role == DuelRole.SPEAR_RING else 158.0
	match side:
		DUEL_WALL_SIDE_LEFT, DUEL_WALL_SIDE_RIGHT:
			var column := side_slot % 2
			var rows := maxi(1, ceili(float(capacity) * 0.5))
			var row := floori(float(side_slot) * 0.5)
			var wall_x := bounds.position.x + bounds.size.x * (duel_wall_left_percent if side == DUEL_WALL_SIDE_LEFT else duel_wall_right_percent)
			var outward := -1.0 if side == DUEL_WALL_SIDE_LEFT else 1.0
			var x := wall_x + outward * (outward_depth + float(column) * DUEL_WALL_SUPPORT_COLUMN_SPACING)
			var y := _duel_wall_y(row, rows)
			return _clamp_point(Vector2(x, y))
		DUEL_WALL_SIDE_TOP, DUEL_WALL_SIDE_BOTTOM:
			var wall_y := bounds.position.y + bounds.size.y * (duel_wall_top_percent if side == DUEL_WALL_SIDE_TOP else duel_wall_bottom_percent)
			var vertical_outward := -1.0 if side == DUEL_WALL_SIDE_TOP else 1.0
			var support_x := _duel_wall_x(side_slot, maxi(1, capacity))
			return _clamp_point(Vector2(support_x, wall_y + vertical_outward * outward_depth))
	return duel_center

func _clamp_duel_center(center: Vector2) -> Vector2:
	var edge_margin := DUEL_RANGED_RADIUS + Vector2(12.0, 12.0)
	return Vector2(
		clampf(center.x, bounds.position.x + edge_margin.x, bounds.end.x - edge_margin.x),
		clampf(center.y, bounds.position.y + edge_margin.y, bounds.end.y - edge_margin.y)
	)

func _duel_slot_count(role: int) -> int:
	match role:
		DuelRole.SHIELD_RING: return DUEL_SHIELD_SLOTS
		DuelRole.SPEAR_RING: return DUEL_SPEAR_SLOTS
		DuelRole.RANGED_RING: return DUEL_RANGED_SLOTS
	return 0

func _duel_total_slot_count() -> int:
	return DUEL_SHIELD_SLOTS + DUEL_SPEAR_SLOTS + DUEL_RANGED_SLOTS

func _duel_slot_key(role: int, slot: int) -> int:
	match role:
		DuelRole.SHIELD_RING:
			return slot
		DuelRole.SPEAR_RING:
			return DUEL_SHIELD_SLOTS + slot
		DuelRole.RANGED_RING:
			return DUEL_SHIELD_SLOTS + DUEL_SPEAR_SLOTS + slot
	return -1

func _duel_member_for_slot(role: int, slot: int) -> int:
	for id in range(CAPACITY):
		if active[id] == 1 and duel_roles[id] == role and duel_slots[id] == slot:
			return id
	return -1

func _duel_role_radius(role: int) -> Vector2:
	match role:
		DuelRole.SHIELD_RING: return DUEL_SHIELD_RADIUS
		DuelRole.SPEAR_RING: return DUEL_SPEAR_RADIUS
		DuelRole.RANGED_RING: return DUEL_RANGED_RADIUS
	return Vector2.ZERO

func _is_duel_member_in_position(id: int) -> bool:
	if not is_duel_formation_member(id):
		return false
	return positions[id].distance_squared_to(_duel_slot_position(duel_roles[id], duel_slots[id])) <= DUEL_SLOT_ARRIVAL_DISTANCE * DUEL_SLOT_ARRIVAL_DISTANCE

func _duel_shields_in_position() -> int:
	if not is_duel_formation_active():
		return 0
	var count := 0
	for id in range(CAPACITY):
		if is_duel_shield(id) and _is_duel_member_in_position(id):
			count += 1
	return count

func _refresh_duel_phase() -> void:
	if duel_phase != DuelPhase.ASSEMBLING:
		return
	if _duel_shields_in_position() >= DUEL_SHIELD_SEAL_REQUIREMENT:
		duel_phase = DuelPhase.SEALED

func spawn(enemy_type: int, at: Vector2, is_boss_guard: bool = false) -> int:
	if free_ids.is_empty():
		return -1
	# 护卫兵暂时停用。保留枚举和数值表以兼容旧配置，但不让 GUARD
	# 进入实际战场，旧调用降级为剑兵以维持刷怪数量和战斗节奏。
	if enemy_type == EnemyType.GUARD:
		enemy_type = EnemyType.SWORD
	var id: int = free_ids.pop_back()
	var stats: Dictionary = _stats(enemy_type)
	var health_multiplier := _threat_health_multiplier() * difficulty_ramp
	positions[id] = at
	types[id] = enemy_type
	hit_points[id] = float(stats.hp) * health_multiplier
	max_hit_points[id] = hit_points[id]
	armor[id] = (float(stats.armor) + _threat_armor_bonus()) * difficulty_ramp
	move_speeds[id] = stats.speed
	damage_multipliers[id] = _threat_damage_multiplier() * difficulty_ramp
	cooldowns[id] = randf_range(1.2, 1.8)
	hurt_timers[id] = 0.0
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	knockback_velocities[id] = Vector2.ZERO
	recoil_timers[id] = 0.0
	recoil_velocities[id] = Vector2.ZERO
	facing_directions[id] = Vector2.DOWN
	boss_guard_flags[id] = 1 if is_boss_guard else 0
	tianji_lifted[id] = 0
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	_clear_launch_state(id)
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	hit_feedback_timers[id] = 0.0
	hit_feedback_durations[id] = 0.0
	hit_feedback_strengths[id] = 0.0
	slow_timers[id] = 0.0
	slow_multipliers[id] = 1.0
	behavior_layers[id] = EngagementLayer.ENGAGE
	desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
	decision_timers[id] = 0.0
	decision_cycles[id] = 0
	movement_targets[id] = at
	spawn_anchors[id] = at
	patrol_offsets[id] = Vector2.ZERO
	navigation_waypoints[id] = Vector2.ZERO
	navigation_targets[id] = Vector2.ZERO
	navigation_replan_timers[id] = 0.0
	navigation_waypoint_active[id] = 0
	navigation_preferred_sides[id] = -1 if id % 2 == 0 else 1
	attack_wait_times[id] = float((id * 29) % 10) * 0.03
	attack_turn_grants[id] = 0
	spear_combo_stages[id] = 0
	spear_combo_timers[id] = 0.0
	command_aura_strengths[id] = 0.0
	command_surge_timers[id] = 0.0
	separation_vectors[id] = Vector2.ZERO
	separation_refresh_timers[id] = 0.0
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	duel_exiting[id] = 0
	duel_exit_targets[id] = Vector2.ZERO
	named_formation_members[id] = 0
	named_formation_critical[id] = 0
	named_formation_targets[id] = Vector2.ZERO
	named_formation_local_targets[id] = Vector2.ZERO
	named_formation_slot_index[id] = -1
	iron_bucket_member_formation[id] = -1
	iron_bucket_member_role[id] = 0
	iron_bucket_member_slot[id] = -1
	iron_bucket_targets[id] = Vector2.ZERO
	iron_bucket_local_targets[id] = Vector2.ZERO
	cavalry_charge_cooldowns[id] = 1.4 + float(id % 4) * 0.15 if enemy_type == EnemyType.CAVALRY else 0.0
	cavalry_charge_distances[id] = 0.0
	cavalry_charge_directions[id] = Vector2.ZERO
	current_attack_kinds[id] = ""
	death_action_kinds[id] = AttackRequest.ActionKind.NONE
	active[id] = 1
	active_count += 1
	layer_refresh_remaining = 0.0
	if is_boss_guard:
		boss_guard_count += 1
	elif is_named_formation_active() and tianji_lifted[id] == 0:
		_assign_enemy_to_named_formation(id)
	return id

func tick(delta: float, player_position: Vector2) -> void:
	formation_time += delta
	_tick_death_records(delta)
	_track_player_motion(delta, player_position)
	archer_volley_cooldown = maxf(0.0, archer_volley_cooldown - delta)
	spear_formation_cooldown = maxf(0.0, spear_formation_cooldown - delta)
	crossbow_volley_cooldown = maxf(0.0, crossbow_volley_cooldown - delta)
	duel_ranged_attack_cooldown = maxf(0.0, duel_ranged_attack_cooldown - delta)
	if is_named_formation_active():
		named_formation_elapsed += delta
		named_formation_remaining = maxf(0.0, named_formation_remaining - delta)
		if not named_formation_break_open and named_formation_remaining <= NAMED_FORMATION_BREAK_WINDOW:
			_open_named_formation_break_window()
		_update_named_formation_targets()
		if named_formation_kind == "bagua" and named_formation_break_open:
			named_formation_gate_rotation_remaining = maxf(0.0, named_formation_gate_rotation_remaining - delta)
			if named_formation_gate_rotation_remaining <= 0.0:
				_activate_bagua_gate(named_formation_gate_index + 1)
		if named_formation_remaining <= 0.0:
			# A formation that survives its window disperses, rather than reporting
			# a player break. Its soldiers return to the regular field behavior.
			clear_named_formation(false)
	if IRON_BUCKET_ENABLED:
		_tick_iron_bucket_formations(delta, player_position)
	elif not iron_bucket_formations.is_empty():
		clear_iron_bucket_formations(false)
	if is_duel_formation_active():
		# 更新纵列盾墙压缩
		_tick_duel_wall_compression(delta)
		# 更新盾墙位置
		_update_shield_wall_positions()
		# 检测并处理边缘骚扰
		_tick_duel_wall_harassment(delta, player_position)
		# 盾墙敲击音效计时
		duel_wall_shield_clash_sound_timer = maxf(0.0, duel_wall_shield_clash_sound_timer - delta)

		duel_maintenance_remaining = maxf(0.0, duel_maintenance_remaining - delta)
		duel_reinforcement_spawn_remaining = maxf(0.0, duel_reinforcement_spawn_remaining - delta)
		if duel_maintenance_remaining <= 0.0:
			_maintain_duel_formation(delta)
			duel_maintenance_remaining = 0.12
	_refresh_banner_commands(delta)
	layer_refresh_remaining = maxf(0.0, layer_refresh_remaining - delta)
	layer_rotation_remaining = maxf(0.0, layer_rotation_remaining - delta)
	if layer_refresh_remaining <= 0.0:
		_assign_desired_behavior_layers(player_position)
		layer_refresh_remaining = LAYER_REFRESH_INTERVAL
		if layer_rotation_remaining <= 0.0:
			layer_rotation_cursor += 1
			layer_rotation_remaining = randf_range(LAYER_ROTATION_MIN_INTERVAL, LAYER_ROTATION_MAX_INTERVAL)
	_update_attack_wait_times(delta)
	_assign_attack_turns(player_position)
	_rebuild_spatial_cells()
	for id in range(CAPACITY):
		if active[id] == 0:
			if death_states[id] != DeathState.NONE:
				_tick_dying(id, delta)
			continue
		if tianji_lifted[id] == 1:
			continue
		if launch_timers[id] > 0.0:
			_tick_enemy_launch(id, delta)
			continue
		if duel_exiting[id] == 1:
			var exit_offset := duel_exit_targets[id] - positions[id]
			if exit_offset.length_squared() > 4.0:
				positions[id] += exit_offset.normalized() * move_speeds[id] * 1.15 * delta
				facing_directions[id] = exit_offset.normalized()
			if positions[id].y < bounds.position.y - 72.0 or positions[id].y > bounds.end.y + 72.0:
				_despawn_duel_exiting(id)
			continue
		if _is_iron_bucket_in_transit(id):
			_advance_iron_bucket_member(id, delta)
			continue
		cooldowns[id] -= delta
		if types[id] == EnemyType.CAVALRY:
			cavalry_charge_cooldowns[id] = maxf(0.0, cavalry_charge_cooldowns[id] - delta)
		if types[id] == EnemyType.SPEAR:
			spear_combo_timers[id] = maxf(0.0, spear_combo_timers[id] - delta)
			if spear_combo_timers[id] <= 0.0:
				spear_combo_stages[id] = 0
		hit_feedback_timers[id] = maxf(0.0, hit_feedback_timers[id] - delta)
		slow_timers[id] = maxf(0.0, slow_timers[id] - delta)
		if slow_timers[id] <= 0.0:
			slow_multipliers[id] = 1.0
		if recoil_timers[id] > 0.0:
			var recoil_delta := minf(delta, recoil_timers[id])
			positions[id] += recoil_velocities[id] * recoil_delta
			recoil_timers[id] = maxf(0.0, recoil_timers[id] - delta)
			if recoil_timers[id] <= 0.0:
				recoil_velocities[id] = Vector2.ZERO
			_clamp_position(id)
		if hurt_timers[id] > 0.0:
			hurt_timers[id] = maxf(0.0, hurt_timers[id] - delta)
			var forced_delta := minf(delta, forced_displacement_timers[id])
			if forced_delta > 0.0:
				positions[id] += forced_displacement_velocities[id] * forced_delta
				forced_displacement_timers[id] = maxf(0.0, forced_displacement_timers[id] - delta)
				if forced_displacement_timers[id] <= 0.0:
					forced_displacement_velocities[id] = Vector2.ZERO
			positions[id] += knockback_velocities[id] * delta
			knockback_velocities[id] = knockback_velocities[id].move_toward(Vector2.ZERO, 2200.0 * delta)
			_clamp_position(id)
			continue
		# A normal hit uses the hurt window; pure guard recoil is handled independently above.
		knockback_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		if attack_states[id] != AttackState.APPROACH:
			_tick_special_attack_motion(id, delta)
			if is_iron_bucket_shield(id):
				_advance_iron_bucket_member(id, delta)
			attack_timers[id] = maxf(0.0, attack_timers[id] - delta)
			if attack_timers[id] <= 0.0:
				if attack_states[id] == AttackState.WINDUP:
					if types[id] == EnemyType.BANNER and current_attack_kinds[id] == ATTACK_KIND_BANNER_COMMAND:
						banner_command_requested.emit(id, positions[id])
					attack_states[id] = AttackState.RECOVER
					attack_timers[id] = _attack_recovery(types[id])
				else:
					attack_states[id] = AttackState.APPROACH
					current_attack_kinds[id] = ""
			continue
		decision_timers[id] = maxf(0.0, decision_timers[id] - delta)
		if decision_timers[id] <= 0.0:
			_refresh_movement_decision(id, player_position)
		navigation_replan_timers[id] = maxf(0.0, navigation_replan_timers[id] - delta)
		var to_player := player_position - positions[id]
		var distance := to_player.length()
		var formation_target := movement_targets[id]
		var to_formation_target := formation_target - positions[id]
		var formation_direction := to_formation_target.normalized() if to_formation_target.length_squared() > FORMATION_ARRIVAL_DISTANCE * FORMATION_ARRIVAL_DISTANCE else Vector2.ZERO
		var formation_strength := clampf(to_formation_target.length() / 42.0, 0.0, 1.0)
		var navigation_direction := _navigation_direction_for(id, formation_target)
		separation_refresh_timers[id] = maxf(0.0, separation_refresh_timers[id] - delta)
		if separation_refresh_timers[id] <= 0.0:
			separation_vectors[id] = _separation_vector(id)
			separation_refresh_timers[id] = _separation_refresh_interval(behavior_layers[id])
		var separation := separation_vectors[id]
		var move_intent := navigation_direction * formation_strength + separation * 1.35
		if move_intent.length_squared() > 0.01:
			var slow_multiplier := slow_multipliers[id] if slow_timers[id] > 0.0 else 1.0
			positions[id] += move_intent.limit_length(1.0) * move_speeds[id] * _layer_speed_multiplier(behavior_layers[id]) * _command_speed_multiplier(id) * slow_multiplier * delta
		_clamp_position(id)
		if attack_turn_grants[id] == 1 and cooldowns[id] <= 0.0 and _can_trigger_attack(id, player_position, distance):
			var attack_kind := _choose_attack_kind(id, player_position, distance)
			cooldowns[id] = _attack_cooldown_for_kind(types[id], attack_kind)
			attack_wait_times[id] = 0.0
			attack_states[id] = AttackState.WINDUP
			attack_timers[id] = _attack_windup_for_kind(types[id], attack_kind)
			var attack_target := _attack_target_for_kind(id, attack_kind, player_position)
			current_attack_kinds[id] = attack_kind
			if types[id] == EnemyType.HALBERD:
				facing_directions[id] = _halberd_horizontal_direction(id, attack_target)
			if attack_kind == ATTACK_KIND_CAVALRY_CHARGE:
				_start_cavalry_charge(id, attack_target)
			enemy_attack_requested.emit(id, positions[id], attack_target, types[id], _damage(types[id]) * damage_multipliers[id] * _command_damage_multiplier(id), attack_timers[id], attack_kind)
	_refresh_duel_phase()

func _despawn_duel_exiting(id: int) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return
	active[id] = 0
	active_count = maxi(0, active_count - 1)
	duel_exiting[id] = 0
	duel_exit_targets[id] = Vector2.ZERO
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	attack_turn_grants[id] = 0
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	current_attack_kinds[id] = ""
	decision_timers[id] = INF
	free_ids.append(id)

func _advance_iron_bucket_member(id: int, delta: float) -> void:
	if not is_iron_bucket_member(id):
		return
	var target := iron_bucket_targets[id]
	var direction := target - positions[id]
	var in_transit := _is_iron_bucket_in_transit(id)
	if direction.length_squared() <= (2.0 * 2.0 if in_transit else 12.0 * 12.0):
		return
	var speed := maxf(move_speeds[id], IRON_BUCKET_MARCH_SPEED) if in_transit else move_speeds[id]
	positions[id] += direction.normalized() * speed * delta
	_clamp_position(id)

func _is_iron_bucket_in_transit(id: int) -> bool:
	if not is_iron_bucket_member(id):
		return false
	var formation_index := iron_bucket_member_formation[id]
	if formation_index < 0 or formation_index >= iron_bucket_formations.size():
		return false
	return str(iron_bucket_formations[formation_index].get("state", "")) in ["forming", "marching"]

func freeze_for_cinematic() -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or duel_exiting[id] == 1:
			continue
		attack_states[id] = AttackState.APPROACH
		attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		_clear_launch_state(id)
		hurt_timers[id] = 0.0
		hit_feedback_timers[id] = 0.0
		hit_feedback_durations[id] = 0.0
		hit_feedback_strengths[id] = 0.0
		movement_targets[id] = positions[id]
		decision_timers[id] = INF
		attack_wait_times[id] = 0.0
		attack_turn_grants[id] = 0
		spear_combo_stages[id] = 0
		spear_combo_timers[id] = 0.0
		cavalry_charge_distances[id] = 0.0
		cavalry_charge_directions[id] = Vector2.ZERO
		command_surge_timers[id] = 0.0

func unfreeze_for_cinematic() -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		if attack_states[id] != AttackState.APPROACH:
			attack_states[id] = AttackState.APPROACH
			attack_timers[id] = 0.0
		current_attack_kinds[id] = ""
		decision_timers[id] = randf_range(0.05, 0.25)
		attack_wait_times[id] = 0.0

func defeat_for_victory_cinematic(maximum_count: int) -> int:
	var defeated_count := 0
	for id in range(CAPACITY):
		if defeated_count >= maximum_count:
			break
		if active[id] == 0:
			continue
		_begin_victory_cinematic_death(id)
		defeated_count += 1
	return defeated_count

func tick_cinematic_deaths(delta: float) -> void:
	_tick_death_records(delta)
	for id in range(CAPACITY):
		if active[id] == 0 and death_states[id] != DeathState.NONE:
			_tick_dying(id, delta)

func _begin_victory_cinematic_death(id: int) -> void:
	active[id] = 0
	tianji_lifted[id] = 0
	active_count = maxi(0, active_count - 1)
	if boss_guard_flags[id] == 1:
		boss_guard_flags[id] = 0
		boss_guard_count = maxi(0, boss_guard_count - 1)
	duel_roles[id] = DuelRole.NONE
	duel_slots[id] = -1
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	current_attack_kinds[id] = ""
	knockback_velocities[id] = Vector2.ZERO
	recoil_timers[id] = 0.0
	recoil_velocities[id] = Vector2.ZERO
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	_clear_launch_state(id)
	hurt_timers[id] = 0.0
	hit_feedback_timers[id] = 0.0
	hit_feedback_durations[id] = 0.0
	hit_feedback_strengths[id] = 0.0
	decision_timers[id] = INF
	movement_targets[id] = positions[id]
	death_states[id] = DeathState.FALLING
	death_timers[id] = DEATH_DISPLAY_DURATION
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0

func query(request: AttackRequest) -> Array[int]:
	var results: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or duel_exiting[id] == 1:
			continue
		if request.one_hit_per_target and request.hit_targets.has(id):
			continue
		if _request_hits_point(request, positions[id]):
			if _iron_bucket_blocks_attack(request, positions[id]):
				continue
			results.append(id)
	results.sort_custom(func(first_id: int, second_id: int) -> bool:
		var first_priority := _request_target_priority(request, first_id)
		var second_priority := _request_target_priority(request, second_id)
		if is_equal_approx(first_priority, second_priority):
			return first_id < second_id
		return first_priority < second_priority
	)
	if results.size() > request.pierce:
		results.resize(request.pierce)
	return results

func _iron_bucket_blocks_attack(request: AttackRequest, target: Vector2) -> bool:
	if not IRON_BUCKET_ENABLED:
		return false
	for formation in iron_bucket_formations:
		if str(formation.get("state", "")) not in ["assembling", "active"]:
			continue
		var center: Vector2 = formation.get("center", Vector2.ZERO)
		var wall_radius := maxf(32.0, float(formation.get("radius", IRON_BUCKET_MIN_RADIUS)) - 26.0)
		if request.origin.distance_to(center) <= wall_radius or target.distance_to(center) >= wall_radius:
			continue
		var crossing := _segment_circle_entry_point(request.origin, target, center, wall_radius)
		var gap_angle := float(formation.get("gap_angle", 0.0)) + float(formation.get("rotation_angle", 0.0))
		var gap_width := float(formation.get("gap_width", 1.0)) + 0.16
		if absf(angle_difference(gap_angle, (crossing - center).angle())) > gap_width * 0.5:
			return true
	return false

func _request_target_priority(request: AttackRequest, id: int) -> float:
	var offset := positions[id] - request.origin
	if request.shape == AttackRequest.Shape.LINE:
		return maxf(0.0, offset.dot(request.direction))
	return offset.length_squared()

func apply_damage(id: int, value: float) -> bool:
	return apply_hit(id, value, Vector2.ZERO, 0.0)

func apply_tianji_damage(id: int, value: float) -> bool:
	# 天机伤害需要检查铁桶阵的天机抗性
	var formation_index := iron_bucket_member_formation[id]
	if formation_index >= 0 and formation_index < iron_bucket_formations.size():
		var formation: Dictionary = iron_bucket_formations[formation_index]
		var tianji_resistance: float = formation.get("tianji_resistance", 0.0)
		value *= (1.0 - tianji_resistance)  # 应用天机减伤
	return apply_hit(id, value, Vector2.ZERO, 0.0)

func set_death_action_kind(id: int, action_kind: int) -> void:
	if id >= 0 and id < CAPACITY:
		death_action_kinds[id] = action_kind

func consume_death_action_kind(id: int) -> int:
	if id < 0 or id >= CAPACITY:
		return AttackRequest.ActionKind.NONE
	var action_kind := death_action_kinds[id]
	death_action_kinds[id] = AttackRequest.ActionKind.NONE
	return action_kind

func apply_knockback_only(id: int, direction: Vector2, knockback: float, ignore_knockback_resistance: bool = false, forced_displacement: float = 0.0, forced_displacement_duration: float = 0.0) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1 or direction.length_squared() <= 0.01:
		return
	if is_duel_shield(id) and is_duel_formation_sealed():
		block_duel_shield_hit(id)
		return
	if is_named_formation_shield_wall(id):
		block_named_formation_shield_hit(id)
		return
	if is_iron_bucket_shield(id):
		block_iron_bucket_shield_hit(id)
		return
	var normalized_direction := direction.normalized()
	var resistance := 1.0 if ignore_knockback_resistance else _knockback_resistance(types[id])
	if is_duel_formation_fodder(id):
		resistance *= 0.20
	var duration := maxf(0.11, forced_displacement_duration)
	var distance := maxf(forced_displacement, knockback * duration * 0.52)
	distance *= resistance
	if distance <= 0.01:
		return
	recoil_timers[id] = maxf(recoil_timers[id], duration)
	recoil_velocities[id] = normalized_direction * distance / duration
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 0.72)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.085)
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0

func apply_slow(id: int, multiplier: float, duration: float) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1 or duration <= 0.0:
		return
	slow_timers[id] = maxf(slow_timers[id], duration)
	slow_multipliers[id] = minf(slow_multipliers[id], clampf(multiplier, 0.15, 1.0))

func count_active_within(at: Vector2, radius: float) -> int:
	var count := 0
	var radius_squared := radius * radius
	for id in range(CAPACITY):
		if active[id] == 1 and tianji_lifted[id] == 0 and positions[id].distance_squared_to(at) <= radius_squared:
			count += 1
	return count

func apply_hit(id: int, value: float, direction: Vector2, knockback: float, ignore_knockback_resistance: bool = false, forced_displacement: float = 0.0, forced_displacement_duration: float = 0.0) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 1:
		return false
	# 命名阵法盾墙仍沿用原有的可受击规则。
	if is_named_formation_shield_wall(id):
		block_named_formation_shield_hit(id)
	if is_iron_bucket_shield(id):
		block_iron_bucket_shield_hit(id)
		return false
	value *= duel_damage_multiplier(id) * named_formation_damage_multiplier(id) * iron_bucket_damage_multiplier(id)
	hit_points[id] -= value
	if hit_points[id] > 0.0:
		if attack_states[id] == AttackState.WINDUP:
			_cancel_attack(id, 0.35)
			enemy_attack_cancelled.emit(id)
		var resistance := 1.0 if ignore_knockback_resistance else _knockback_resistance(types[id])
		if knockback > 0.0 and direction.length_squared() > 0.01:
			knockback_velocities[id] = direction.normalized() * knockback * resistance
		if forced_displacement > 0.0 and forced_displacement_duration > 0.0 and direction.length_squared() > 0.01:
			var forced_resistance := 1.0 if ignore_knockback_resistance else _forced_displacement_resistance(types[id])
			forced_displacement_timers[id] = forced_displacement_duration
			forced_displacement_velocities[id] = direction.normalized() * forced_displacement * forced_resistance / forced_displacement_duration
		var hurt_duration := _hurt_duration(types[id])
		if knockback >= 500.0:
			hurt_duration = maxf(hurt_duration, _break_duration(types[id]))
		hurt_duration = maxf(hurt_duration, forced_displacement_duration)
		hurt_timers[id] = hurt_duration
		hit_feedback_strengths[id] = 1.0 + clampf((knockback + forced_displacement * 7.0) / 700.0, 0.0, 0.95)
		hit_feedback_durations[id] = 0.075 + hit_feedback_strengths[id] * 0.045
		hit_feedback_timers[id] = hit_feedback_durations[id]
		desired_behavior_layers[id] = EngagementLayer.ENGAGE
		decision_timers[id] = 0.0
		return false
	_begin_death(id, direction)
	return true

func set_tianji_lifted(id: int, lifted: bool) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	tianji_lifted[id] = 1 if lifted else 0
	if lifted:
		_cancel_attack(id, 0.0)
		enemy_attack_cancelled.emit(id)
		attack_turn_grants[id] = 0
		attack_wait_times[id] = 0.0
		knockback_velocities[id] = Vector2.ZERO
		recoil_timers[id] = 0.0
		recoil_velocities[id] = Vector2.ZERO
		forced_displacement_timers[id] = 0.0
		forced_displacement_velocities[id] = Vector2.ZERO
		hurt_timers[id] = 0.0
		movement_targets[id] = positions[id]
		decision_timers[id] = INF
	else:
		movement_targets[id] = positions[id]
		decision_timers[id] = 0.0
	return true

func update_tianji_position(id: int, at: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or tianji_lifted[id] == 0:
		return false
	positions[id] = at
	movement_targets[id] = at
	return true

func is_tianji_lifted(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and tianji_lifted[id] == 1

func launch_enemy(id: int, direction: Vector2, speed: float, duration: float, collision_damage: float, collision_knockback: float, collision_targets: int, relay_count: int = 0) -> bool:
	if id < 0 or id >= CAPACITY or (active[id] == 0 and death_states[id] == DeathState.NONE):
		return false
	if not _can_be_launched(id) or direction.length_squared() <= 0.01:
		return false
	if speed <= 0.0 or duration <= 0.0 or collision_targets <= 0:
		return false
	var normalized_direction := direction.normalized()
	launch_timers[id] = duration
	launch_durations[id] = duration
	launch_velocities[id] = normalized_direction * speed
	launch_collision_damages[id] = maxf(1.0, collision_damage)
	launch_collision_knockbacks[id] = maxf(0.0, collision_knockback)
	launch_collision_charges[id] = clampi(collision_targets, 1, 8)
	launch_relay_charges[id] = clampi(relay_count, 0, 1)
	launch_hit_targets[id].clear()
	facing_directions[id] = normalized_direction
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	current_attack_kinds[id] = ""
	knockback_velocities[id] = Vector2.ZERO
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	hurt_timers[id] = maxf(hurt_timers[id], duration)
	hit_feedback_strengths[id] = maxf(hit_feedback_strengths[id], 1.65)
	hit_feedback_durations[id] = maxf(hit_feedback_durations[id], 0.14)
	hit_feedback_timers[id] = hit_feedback_durations[id]
	return true

func is_enemy_launched(id: int) -> bool:
	return id >= 0 and id < CAPACITY and launch_timers[id] > 0.0

func launch_visual_offset(id: int) -> Vector2:
	if not is_enemy_launched(id) or launch_durations[id] <= 0.0:
		return Vector2.ZERO
	var progress := clampf(1.0 - launch_timers[id] / launch_durations[id], 0.0, 1.0)
	return Vector2.UP * sin(progress * PI) * 38.0

func _tick_enemy_launch(id: int, delta: float) -> void:
	launch_timers[id] = maxf(0.0, launch_timers[id] - delta)
	var velocity := launch_velocities[id]
	var direction := velocity.normalized()
	if direction.length_squared() > 0.01:
		var start_position := positions[id]
		positions[id] += velocity * delta
		launch_velocities[id] = velocity.move_toward(Vector2.ZERO, LAUNCH_DECELERATION * delta)
		_clamp_position(id)
		_apply_launch_collision(id, direction, start_position, positions[id])
	if launch_timers[id] <= 0.0 or launch_velocities[id].length() < LAUNCH_MIN_SPEED:
		_stop_enemy_launch(id)

func _apply_launch_collision(source_id: int, direction: Vector2, start_position: Vector2, end_position: Vector2) -> void:
	if launch_collision_charges[source_id] <= 0:
		return
	var target_id := -1
	var nearest_travel := INF
	var travel_distance := start_position.distance_to(end_position)
	for candidate_id in range(CAPACITY):
		if candidate_id == source_id or active[candidate_id] == 0 or launch_hit_targets[source_id].has(candidate_id):
			continue
		var offset := positions[candidate_id] - start_position
		var forward_travel := offset.dot(direction)
		if forward_travel < -LAUNCH_COLLISION_RADIUS or forward_travel > travel_distance + LAUNCH_COLLISION_RADIUS:
			continue
		var closest_position := start_position + direction * clampf(forward_travel, 0.0, travel_distance)
		if positions[candidate_id].distance_squared_to(closest_position) > LAUNCH_COLLISION_RADIUS * LAUNCH_COLLISION_RADIUS or forward_travel >= nearest_travel:
			continue
		target_id = candidate_id
		nearest_travel = forward_travel
	if target_id < 0:
		return
	launch_hit_targets[source_id][target_id] = true
	launch_collision_charges[source_id] -= 1
	var target_defeated := apply_hit(target_id, launch_collision_damages[source_id], direction, launch_collision_knockbacks[source_id], true, 48.0, 0.10)
	enemy_death_collision.emit(positions[target_id], direction)
	if target_defeated and launch_relay_charges[source_id] > 0:
		var inherited_speed := maxf(LAUNCH_MIN_SPEED, launch_velocities[source_id].length() * 0.78)
		var inherited_duration := maxf(0.22, launch_timers[source_id] * 0.82)
		var inherited_targets := mini(2, launch_collision_charges[source_id] + 1)
		launch_relay_charges[source_id] = 0
		if launch_enemy(target_id, direction, inherited_speed, inherited_duration, launch_collision_damages[source_id] * 0.85, launch_collision_knockbacks[source_id] * 0.82, inherited_targets, 0):
			_stop_enemy_launch(source_id)

func _stop_enemy_launch(id: int) -> void:
	var was_active := active[id] == 1
	_clear_launch_state(id)
	if was_active:
		hurt_timers[id] = maxf(hurt_timers[id], 0.12)
		decision_timers[id] = 0.0

func _can_be_launched(id: int) -> bool:
	return types[id] not in [EnemyType.SHIELD, EnemyType.ELITE, EnemyType.GUARD, EnemyType.CAVALRY]

func _clear_launch_state(id: int) -> void:
	launch_timers[id] = 0.0
	launch_durations[id] = 0.0
	launch_velocities[id] = Vector2.ZERO
	launch_collision_damages[id] = 0.0
	launch_collision_knockbacks[id] = 0.0
	launch_collision_charges[id] = 0
	launch_relay_charges[id] = 0
	launch_hit_targets[id] = {}

func get_armor(id: int) -> float:
	return armor[id]

func get_type(id: int) -> int:
	if id < 0:
		var record_index := -id - 1
		if record_index >= 0 and record_index < death_records.size():
			return int(death_records[record_index].get("type", EnemyType.SWORD))
	return types[id]

func is_active(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1

func is_dying(id: int) -> bool:
	if id < 0:
		var record_index := -id - 1
		return record_index >= 0 and record_index < death_records.size()
	return id >= 0 and id < CAPACITY and death_states[id] != DeathState.NONE

func death_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	if id < 0:
		var record: Dictionary = death_records[-id - 1]
		return clampf(1.0 - float(record.get("remaining", 0.0)) / DEATH_DISPLAY_DURATION, 0.0, 1.0)
	return clampf(1.0 - death_timers[id] / DEATH_DISPLAY_DURATION, 0.0, 1.0)

func death_animation_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	if id < 0:
		var record: Dictionary = death_records[-id - 1]
		var record_elapsed := DEATH_DISPLAY_DURATION - float(record.get("remaining", 0.0))
		return clampf(record_elapsed / DEATH_ANIMATION_DURATION, 0.0, 1.0)
	var elapsed := DEATH_DISPLAY_DURATION - death_timers[id]
	return clampf(elapsed / DEATH_ANIMATION_DURATION, 0.0, 1.0)

func death_fade_progress(id: int) -> float:
	if not is_dying(id):
		return 0.0
	if id < 0:
		var record: Dictionary = death_records[-id - 1]
		var record_elapsed := DEATH_DISPLAY_DURATION - float(record.get("remaining", 0.0))
		return clampf((record_elapsed - DEATH_FADE_DELAY) / (DEATH_DISPLAY_DURATION - DEATH_FADE_DELAY), 0.0, 1.0)
	var elapsed := DEATH_DISPLAY_DURATION - death_timers[id]
	return clampf((elapsed - DEATH_FADE_DELAY) / (DEATH_DISPLAY_DURATION - DEATH_FADE_DELAY), 0.0, 1.0)

func is_death_launched(id: int) -> bool:
	if id < 0:
		var record_index := -id - 1
		return record_index >= 0 and record_index < death_records.size() and int(death_records[record_index].get("state", DeathState.FALLING)) == DeathState.LAUNCHED
	return is_dying(id) and death_states[id] == DeathState.LAUNCHED

func death_record_position(id: int, ground: bool = false) -> Vector2:
	if id < 0:
		var record_index := -id - 1
		if record_index >= 0 and record_index < death_records.size():
			var record: Dictionary = death_records[record_index]
			return record.get("ground_position" if ground else "position", Vector2.ZERO)
	return positions[id]

func death_record_facing(id: int) -> Vector2:
	if id < 0:
		var record_index := -id - 1
		if record_index >= 0 and record_index < death_records.size():
			return death_records[record_index].get("facing", Vector2.DOWN)
	return facing_directions[id]

func death_record_count() -> int:
	return death_records.size()

func get_hurt_timer(id: int) -> float:
	return hurt_timers[id] if id >= 0 and id < CAPACITY else 0.0

func get_hit_feedback_ratio(id: int) -> float:
	if id < 0 or id >= CAPACITY or hit_feedback_durations[id] <= 0.0:
		return 0.0
	return clampf(hit_feedback_timers[id] / hit_feedback_durations[id], 0.0, 1.0)

func get_hit_feedback_strength(id: int) -> float:
	return hit_feedback_strengths[id] if id >= 0 and id < CAPACITY else 0.0

func get_behavior_layer(id: int) -> int:
	return behavior_layers[id] if id >= 0 and id < CAPACITY else EngagementLayer.ATMOSPHERE

func has_movement_intent(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	if launch_timers[id] > 0.0:
		return false
	if attack_states[id] != AttackState.APPROACH or hurt_timers[id] > 0.0:
		return false
	return movement_targets[id].distance_squared_to(positions[id]) > 4.0

func is_being_displaced(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return false
	return launch_timers[id] > 0.0 or recoil_timers[id] > 0.0 or forced_displacement_timers[id] > 0.0 or knockback_velocities[id].length_squared() > 16.0

func get_knockback_direction(id: int) -> Vector2:
	if id < 0 or id >= CAPACITY:
		return Vector2.ZERO
	if launch_timers[id] > 0.0:
		return launch_velocities[id].normalized()
	if forced_displacement_timers[id] > 0.0:
		return forced_displacement_velocities[id].normalized()
	if recoil_timers[id] > 0.0:
		return recoil_velocities[id].normalized()
	return knockback_velocities[id].normalized()

func get_attack_state(id: int) -> int:
	return attack_states[id] if id >= 0 and id < CAPACITY else AttackState.APPROACH

func get_attack_remaining(id: int) -> float:
	return attack_timers[id] if id >= 0 and id < CAPACITY else 0.0

func cancel_attack(id: int) -> void:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return
	_cancel_attack(id, 0.35)

func resolve_spear_clash(id: int, direction: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.SPEAR:
		return false
	_cancel_attack(id, SPEAR_CLASH_COOLDOWN)
	spear_combo_stages[id] = 0
	spear_combo_timers[id] = 0.0
	var recoil_direction := direction.normalized()
	if recoil_direction.length_squared() <= 0.01:
		recoil_direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	knockback_velocities[id] = recoil_direction * SPEAR_CLASH_KNOCKBACK
	hurt_timers[id] = SPEAR_CLASH_HURT_DURATION
	hit_feedback_strengths[id] = 1.35
	hit_feedback_durations[id] = 0.12
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0
	enemy_attack_cancelled.emit(id)
	return true

func resolve_cavalry_clash(id: int, direction: Vector2) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.CAVALRY:
		return false
	_cancel_attack(id, CAVALRY_CLASH_COOLDOWN)
	var recoil_direction := direction.normalized()
	if recoil_direction.length_squared() <= 0.01:
		recoil_direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	knockback_velocities[id] = recoil_direction * CAVALRY_CLASH_KNOCKBACK
	hurt_timers[id] = CAVALRY_CLASH_HURT_DURATION
	hit_feedback_strengths[id] = 1.48
	hit_feedback_durations[id] = 0.13
	hit_feedback_timers[id] = hit_feedback_durations[id]
	desired_behavior_layers[id] = EngagementLayer.ENGAGE
	decision_timers[id] = 0.0
	enemy_attack_cancelled.emit(id)
	return true

func issue_banner_command(id: int) -> bool:
	if id < 0 or id >= CAPACITY or active[id] == 0 or types[id] != EnemyType.BANNER:
		return false
	var affected := false
	for target_id in range(CAPACITY):
		if active[target_id] == 0 or types[target_id] == EnemyType.BANNER:
			continue
		if positions[target_id].distance_squared_to(positions[id]) > BANNER_COMMAND_RADIUS * BANNER_COMMAND_RADIUS:
			continue
		command_surge_timers[target_id] = maxf(command_surge_timers[target_id], BANNER_COMMAND_DURATION)
		affected = true
	return affected

func command_aura_ratio(id: int) -> float:
	if id < 0 or id >= CAPACITY or active[id] == 0:
		return 0.0
	if command_surge_timers[id] > 0.0:
		return 1.0
	return command_aura_strengths[id] * 0.58

func is_banner_commanding(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and types[id] == EnemyType.BANNER and attack_states[id] == AttackState.WINDUP and current_attack_kinds[id] == ATTACK_KIND_BANNER_COMMAND

func is_cavalry_charging(id: int) -> bool:
	return id >= 0 and id < CAPACITY and active[id] == 1 and cavalry_charge_distances[id] > 0.01

func count_active_type(enemy_type: int) -> int:
	var count := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == enemy_type:
			count += 1
	return count

func get_facing_direction(id: int) -> Vector2:
	return facing_directions[id] if id >= 0 and id < CAPACITY else Vector2.DOWN

func get_boss_guard_count() -> int:
	return boss_guard_count

func attack_telegraph_limit(enemy_type: int) -> int:
	var group := _attack_group_for_type(enemy_type)
	if group == "archer":
		return _archer_attack_slots()
	if group == "crossbow":
		return _crossbow_attack_slots()
	if group == "halberd":
		return _halberd_attack_slots()
	if group == "spear":
		return _spear_attack_slots()
	if group == "banner":
		return _banner_attack_slots()
	if group == "cavalry":
		return _cavalry_attack_slots()
	return _frontline_attack_slots()

func gold_reward(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.BANNER: return 0
		EnemyType.ELITE: return 60
		EnemyType.SWORD, EnemyType.ARCHER:
			return 1 if randf() <= 0.12 else 0
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY:
			return 2 if randf() <= 0.16 else 0
		_: return 0

func _begin_death(id: int, direction: Vector2) -> void:
	var type := types[id]
	var at := positions[id]
	var duel_role := duel_roles[id]
	var duel_slot := duel_slots[id]
	var was_named_member := is_named_formation_member(id)
	var iron_bucket_index := iron_bucket_member_formation[id]
	var was_iron_bucket_member := is_iron_bucket_member(id)
	var named_break_gain := 2 if was_named_member and is_named_formation_break_window() and is_named_formation_critical(id) else (1 if was_named_member and is_named_formation_break_window() else 0)
	tianji_lifted[id] = 0
	if duel_role != DuelRole.NONE:
		duel_fodder_death_ids[id] = true
		var slot_key := _duel_slot_key(duel_role, duel_slot)
		if slot_key >= 0 and slot_key < duel_slot_refill_timers.size():
			duel_slot_refill_timers[slot_key] = randf_range(DUEL_REINFORCEMENT_DELAY_MIN, DUEL_REINFORCEMENT_DELAY_MAX)
		duel_roles[id] = DuelRole.NONE
		duel_slots[id] = -1
	var preserves_launch := launch_timers[id] > 0.0
	var launch_offset := launch_visual_offset(id)
	var launch_velocity := launch_velocities[id]
	active[id] = 0
	active_count = maxi(0, active_count - 1)
	if boss_guard_flags[id] == 1:
		boss_guard_flags[id] = 0
		boss_guard_count -= 1
	if was_named_member:
		var named_slot_index := named_formation_slot_index[id]
		if named_slot_index >= 0 and named_slot_index < named_formation_slot_taken.size():
			named_formation_slot_taken[named_slot_index] = 0
		named_formation_members[id] = 0
		named_formation_critical[id] = 0
		named_formation_targets[id] = Vector2.ZERO
		named_formation_local_targets[id] = Vector2.ZERO
		named_formation_slot_index[id] = -1
		named_formation_progress = mini(named_formation_required, named_formation_progress + named_break_gain)
		if named_formation_progress >= named_formation_required and is_named_formation_break_window():
			clear_named_formation(true)
		elif named_formation_kind == "bagua" and is_named_formation_break_window() and named_formation_gate_slots.find(id) >= 0:
			_activate_bagua_gate(named_formation_gate_index + 1)
		if is_named_formation_active() and named_slot_index >= 0:
			_refill_named_formation_slot(named_slot_index)
	if was_iron_bucket_member and iron_bucket_index >= 0 and iron_bucket_index < iron_bucket_formations.size():
		var iron_formation: Dictionary = iron_bucket_formations[iron_bucket_index]
		var interior_list: Array = iron_formation.get("interior_ids", [])
		var remaining_inner := 0
		for interior_id in interior_list:
			if is_active(interior_id):
				remaining_inner += 1
		if types[id] != EnemyType.SHIELD:
			remaining_inner = maxi(0, remaining_inner - 1)
		iron_formation["inner_alive"] = remaining_inner
		iron_bucket_formations[iron_bucket_index] = iron_formation
		iron_bucket_member_formation[id] = -1
		iron_bucket_member_role[id] = 0
		iron_bucket_member_slot[id] = -1
		iron_bucket_targets[id] = Vector2.ZERO
		iron_bucket_local_targets[id] = Vector2.ZERO
		if interior_list.is_empty() and str(iron_formation.get("state", "")) in ["assembling", "active"]:
			iron_formation["state"] = "collapsed"
			iron_bucket_formations[iron_bucket_index] = iron_formation
			iron_bucket_collapsed.emit(iron_formation.get("center", Vector2.ZERO))
			for member_id in iron_formation.get("member_ids", []):
				if member_id >= 0 and member_id < CAPACITY and iron_bucket_member_formation[member_id] == iron_bucket_index:
					iron_bucket_member_formation[member_id] = -1
					iron_bucket_member_role[member_id] = 0
					iron_bucket_member_slot[member_id] = -1
	var death_state := DeathState.LAUNCHED if preserves_launch else DeathState.FALLING
	var death_velocity := launch_velocity if preserves_launch else Vector2.ZERO
	var death_position := at + launch_offset
	var death_impact_charge_count := 0
	forced_displacement_timers[id] = 0.0
	forced_displacement_velocities[id] = Vector2.ZERO
	if not preserves_launch and direction.length_squared() > 0.01 and randf() <= DEATH_LAUNCH_CHANCE:
		death_state = DeathState.LAUNCHED
		death_velocity = direction.normalized() * DEATH_LAUNCH_SPEED
		death_impact_charge_count = DEATH_COLLISION_MAX_TARGETS
	death_records.append({
		"ground_position": at,
		"position": death_position,
		"type": type,
		"facing": facing_directions[id],
		"state": death_state,
		"remaining": DEATH_DISPLAY_DURATION,
		"velocity": death_velocity,
		"impact_charges": death_impact_charge_count,
	})
	if death_records.size() > MAX_DEATH_RECORDS:
		death_records.pop_front()
	# The simulation slot is reusable immediately; the independent death record
	# keeps the visual and launch collision state alive until the animation ends.
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	_clear_launch_state(id)
	free_ids.append(id)
	enemy_died.emit(id, type, at, _experience(type), _ultimate_energy(type))

func _tick_dying(id: int, delta: float) -> void:
	death_timers[id] = maxf(0.0, death_timers[id] - delta)
	if launch_timers[id] > 0.0:
		_tick_enemy_launch(id, delta)
	elif death_states[id] == DeathState.LAUNCHED:
		var direction := death_velocities[id].normalized()
		positions[id] += death_velocities[id] * delta
		death_velocities[id] = death_velocities[id].move_toward(Vector2.ZERO, DEATH_LAUNCH_DECELERATION * delta)
		_clamp_position(id)
		if direction.length_squared() > 0.01:
			_apply_death_launch_collision(id, direction)
	if death_timers[id] <= 0.0:
		_recycle_dead(id)

func _tick_death_records(delta: float) -> void:
	for index in range(death_records.size() - 1, -1, -1):
		var record: Dictionary = death_records[index]
		record["remaining"] = maxf(0.0, float(record.get("remaining", 0.0)) - delta)
		if int(record.get("state", DeathState.FALLING)) == DeathState.LAUNCHED:
			var velocity: Vector2 = record.get("velocity", Vector2.ZERO)
			var direction := velocity.normalized()
			var position: Vector2 = record.get("position", Vector2.ZERO)
			position += velocity * delta
			velocity = velocity.move_toward(Vector2.ZERO, DEATH_LAUNCH_DECELERATION * delta)
			record["position"] = position
			record["ground_position"] = position
			record["velocity"] = velocity
			if direction.length_squared() > 0.01:
				_apply_death_launch_collision_record(record, direction)
		death_records[index] = record
		if float(record.get("remaining", 0.0)) <= 0.0:
			death_records.remove_at(index)

func _apply_death_launch_collision_record(record: Dictionary, direction: Vector2) -> void:
	var charges := int(record.get("impact_charges", 0))
	if charges <= 0:
		return
	var source_position: Vector2 = record.get("position", Vector2.ZERO)
	for target_id in range(CAPACITY):
		if active[target_id] == 0:
			continue
		if source_position.distance_squared_to(positions[target_id]) > DEATH_COLLISION_RADIUS * DEATH_COLLISION_RADIUS:
			continue
		charges -= 1
		record["impact_charges"] = charges
		apply_hit(target_id, DEATH_COLLISION_DAMAGE, direction, DEATH_COLLISION_KNOCKBACK)
		enemy_death_collision.emit(positions[target_id], direction)
		return

func _apply_death_launch_collision(source_id: int, direction: Vector2) -> void:
	if death_impact_charges[source_id] <= 0:
		return
	for target_id in range(CAPACITY):
		if active[target_id] == 0:
			continue
		if positions[source_id].distance_squared_to(positions[target_id]) > DEATH_COLLISION_RADIUS * DEATH_COLLISION_RADIUS:
			continue
		death_impact_charges[source_id] -= 1
		apply_hit(target_id, DEATH_COLLISION_DAMAGE, direction, DEATH_COLLISION_KNOCKBACK)
		enemy_death_collision.emit(positions[target_id], direction)
		return

func _recycle_dead(id: int) -> void:
	tianji_lifted[id] = 0
	death_states[id] = DeathState.NONE
	death_timers[id] = 0.0
	death_velocities[id] = Vector2.ZERO
	death_impact_charges[id] = 0
	_clear_launch_state(id)
	free_ids.append(id)

func _maintain_duel_formation(delta: float) -> void:
	if not is_duel_formation_active() or free_ids.is_empty():
		return
	# Fill the open slots nearest the player's current approach first.  Each
	# reinforcement still spawns on that slot's outward radial line, so the
	# replacement visibly comes from the side of the actual gap.
	var missing_slots: Array[Dictionary] = []
	for role in [DuelRole.SHIELD_RING, DuelRole.SPEAR_RING, DuelRole.RANGED_RING]:
		var slot_count := _duel_slot_count(role)
		for slot in range(slot_count):
			var slot_key := _duel_slot_key(role, slot)
			if slot_key < 0 or slot_key >= duel_slot_refill_timers.size():
				continue
			if _duel_member_for_slot(role, slot) >= 0:
				duel_slot_refill_timers[slot_key] = 0.0
				continue
			missing_slots.append({"role": role, "slot": slot, "key": slot_key})
	missing_slots.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_position := _duel_slot_position(int(first["role"]), int(first["slot"]))
		var second_position := _duel_slot_position(int(second["role"]), int(second["slot"]))
		return first_position.distance_squared_to(last_player_position) < second_position.distance_squared_to(last_player_position)
	)
	var spawned := 0
	for missing in missing_slots:
		if spawned >= 2 or duel_reinforcement_spawn_remaining > 0.0:
			break
		var role := int(missing["role"])
		var slot := int(missing["slot"])
		var slot_key := int(missing["key"])
		if duel_slot_refill_timers[slot_key] > 0.0:
			duel_slot_refill_timers[slot_key] = maxf(0.0, duel_slot_refill_timers[slot_key] - delta)
			continue
		var id := spawn(_duel_reinforcement_type(role, slot), _duel_reinforcement_position(role, slot))
		if id < 0:
			return
		duel_roles[id] = role
		duel_slots[id] = slot
		decision_timers[id] = 0.0
		duel_slot_refill_timers[slot_key] = 0.0
		duel_reinforcement_spawn_remaining = DUEL_REINFORCEMENT_SPAWN_INTERVAL
		spawned += 1

func _rebuild_spatial_cells() -> void:
	spatial_cells.clear()
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		var cell := _spatial_cell_for(positions[id])
		var members: Array = spatial_cells.get(cell, [])
		members.append(id)
		spatial_cells[cell] = members

func _separation_vector(id: int) -> Vector2:
	var cell := _spatial_cell_for(positions[id])
	var separation := Vector2.ZERO
	var neighbor_count := 0
	for offset_y in range(-1, 2):
		for offset_x in range(-1, 2):
			var members: Array = spatial_cells.get(cell + Vector2i(offset_x, offset_y), [])
			for other_id in members:
				if other_id == id or active[other_id] == 0 or tianji_lifted[other_id] == 1:
					continue
				var offset := positions[id] - positions[other_id]
				var distance := offset.length()
				var personal_space := maxf(_personal_space(types[id]), _personal_space(types[other_id]))
				if distance >= personal_space:
					continue
				var direction: Vector2
				if distance > 0.01:
					direction = offset / distance
				else:
					var fallback_angle := deg_to_rad(float((id * 37 + other_id * 17) % 360))
					direction = Vector2.from_angle(fallback_angle)
				separation += direction * (1.0 - distance / personal_space)
				neighbor_count += 1
				if neighbor_count >= MAX_SEPARATION_NEIGHBORS:
					return (separation / float(neighbor_count)).limit_length(1.0)
	if neighbor_count == 0:
		return Vector2.ZERO
	return (separation / float(neighbor_count)).limit_length(1.0)

func _separation_refresh_interval(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return PRESSURE_SEPARATION_REFRESH_INTERVAL
		EngagementLayer.ATMOSPHERE: return ATMOSPHERE_SEPARATION_REFRESH_INTERVAL
		_: return 0.0

func _assign_desired_behavior_layers(player_position: Vector2) -> void:
	if is_duel_formation_active():
		for id in range(CAPACITY):
			if active[id] == 0 or tianji_lifted[id] == 1 or duel_exiting[id] == 1:
				continue
			desired_behavior_layers[id] = EngagementLayer.ENGAGE if duel_roles[id] != DuelRole.NONE else EngagementLayer.ATMOSPHERE
		return
	if is_named_formation_active():
		# A named formation owns the whole field. Every living soldier receives a
		# slot so ordinary engagement-layer rotation cannot pull units out of line.
		for id in range(CAPACITY):
			if active[id] == 1 and tianji_lifted[id] == 0 and is_named_formation_member(id):
				desired_behavior_layers[id] = EngagementLayer.ENGAGE
			else:
				desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		return
	if is_iron_bucket_active():
		for id in range(CAPACITY):
			if active[id] == 1 and tianji_lifted[id] == 0 and is_iron_bucket_member(id):
				desired_behavior_layers[id] = EngagementLayer.ENGAGE
			else:
				desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		return
	var melee_ids: Array[int] = []
	var halberd_ids: Array[int] = []
	var archer_ids: Array[int] = []
	var elite_ids: Array[int] = []
	var spear_ids: Array[int] = []
	var crossbow_ids: Array[int] = []
	var banner_ids: Array[int] = []
	var cavalry_ids: Array[int] = []
	var active_count := 0
	var nearby_pressure_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		active_count += 1
		desired_behavior_layers[id] = EngagementLayer.ATMOSPHERE
		match types[id]:
			EnemyType.ARCHER:
				archer_ids.append(id)
			EnemyType.HALBERD:
				halberd_ids.append(id)
			EnemyType.ELITE:
				elite_ids.append(id)
			EnemyType.SPEAR:
				spear_ids.append(id)
			EnemyType.CROSSBOW:
				crossbow_ids.append(id)
			EnemyType.BANNER:
				banner_ids.append(id)
			EnemyType.CAVALRY:
				cavalry_ids.append(id)
			_:
				melee_ids.append(id)
	_assign_nearest_layer(melee_ids, _engage_melee_limit(), player_position)
	_assign_nearest_layer(halberd_ids, _engage_halberd_limit(), player_position)
	_assign_nearest_layer(archer_ids, _engage_archer_limit(), player_position)
	_assign_nearest_layer(elite_ids, ENGAGE_ELITE_LIMIT, player_position)
	_assign_nearest_layer(spear_ids, _engage_spear_limit(), player_position)
	_assign_nearest_layer(crossbow_ids, _engage_crossbow_limit(), player_position)
	_assign_nearest_layer(banner_ids, ENGAGE_BANNER_LIMIT, player_position)
	_assign_nearest_layer(cavalry_ids, _engage_cavalry_limit(), player_position)
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1 or desired_behavior_layers[id] == EngagementLayer.ENGAGE:
			continue
		var pressure_radius := _desired_range(types[id]) + 205.0
		if positions[id].distance_to(player_position) <= pressure_radius:
			if types[id] in [EnemyType.SWORD, EnemyType.SHIELD, EnemyType.SPEAR, EnemyType.HALBERD, EnemyType.CAVALRY]:
				nearby_pressure_ids.append(id)
			else:
				desired_behavior_layers[id] = EngagementLayer.PRESSURE
	nearby_pressure_ids.sort_custom(func(first: int, second: int) -> bool:
		return positions[first].distance_squared_to(player_position) < positions[second].distance_squared_to(player_position)
	)
	# Once the field is populated, rotate a few nearby pressure units into the
	# frontline. This creates an encirclement without allowing every soldier to
	# attack at once; attack-turn slots still control actual swings.
	var extra_engage_budget := mini(5, maxi(0, int(floor(float(active_count - 10) / 10.0))))
	if battle_mode == "story" and battle_elapsed < 180.0:
		extra_engage_budget = mini(5, extra_engage_budget + 1)
	if not nearby_pressure_ids.is_empty():
		var rotation_start := layer_rotation_cursor % nearby_pressure_ids.size()
		for index in range(mini(extra_engage_budget, nearby_pressure_ids.size())):
			var candidate_index := (rotation_start + index) % nearby_pressure_ids.size()
			desired_behavior_layers[nearby_pressure_ids[candidate_index]] = EngagementLayer.ENGAGE
	for id in nearby_pressure_ids:
		if desired_behavior_layers[id] == EngagementLayer.ATMOSPHERE:
			desired_behavior_layers[id] = EngagementLayer.PRESSURE

func _update_attack_wait_times(delta: float) -> void:
	for id in range(CAPACITY):
		if active[id] == 0 or tianji_lifted[id] == 1:
			continue
		if behavior_layers[id] == EngagementLayer.ENGAGE and attack_states[id] == AttackState.APPROACH and hurt_timers[id] <= 0.0:
			attack_wait_times[id] = minf(8.0, attack_wait_times[id] + delta)

func _assign_attack_turns(player_position: Vector2) -> void:
	var previous_grants := attack_turn_grants.duplicate()
	var frontline_candidates: Array[int] = []
	var archer_candidates: Array[int] = []
	var halberd_candidates: Array[int] = []
	var spear_candidates: Array[int] = []
	var crossbow_candidates: Array[int] = []
	var banner_candidates: Array[int] = []
	var cavalry_candidates: Array[int] = []
	var frontline_occupied := 0
	var archer_occupied := 0
	var halberd_occupied := 0
	var spear_occupied := 0
	var crossbow_occupied := 0
	var banner_occupied := 0
	var cavalry_occupied := 0
	var named_formation_assembling := is_named_formation_active() and named_formation_elapsed < NAMED_FORMATION_ASSEMBLY_DURATION
	var iron_bucket_assembling := is_iron_bucket_assembling()
	for id in range(CAPACITY):
		attack_turn_grants[id] = 0
		if active[id] == 0 or tianji_lifted[id] == 1 or duel_exiting[id] == 1 or behavior_layers[id] != EngagementLayer.ENGAGE or named_formation_assembling or (iron_bucket_assembling and is_iron_bucket_member(id)):
			continue
		var group := _attack_group_for_type(types[id])
		if attack_states[id] != AttackState.APPROACH:
			# Recovery releases the attack position immediately so another soldier can rotate in.
			if attack_states[id] == AttackState.WINDUP:
				if group == "frontline":
					frontline_occupied += 1
				elif group == "archer":
					archer_occupied += 1
				elif group == "crossbow":
					crossbow_occupied += 1
				elif group == "spear":
					spear_occupied += 1
				elif group == "banner":
					banner_occupied += 1
				elif group == "cavalry":
					cavalry_occupied += 1
				else:
					halberd_occupied += 1
			continue
		var within_staging_range := positions[id].distance_to(player_position) <= _attack_staging_range(types[id])
		if is_duel_formation_member(id):
			within_staging_range = true
		elif is_named_formation_cavalry_channel(id):
			within_staging_range = true
		elif is_iron_bucket_shield(id):
			within_staging_range = true
		if cooldowns[id] > 0.0 or not within_staging_range:
			continue
		if group == "frontline":
			frontline_candidates.append(id)
		elif group == "archer":
			archer_candidates.append(id)
		elif group == "crossbow":
			crossbow_candidates.append(id)
		elif group == "spear":
			spear_candidates.append(id)
		elif group == "banner":
			banner_candidates.append(id)
		elif group == "cavalry":
			cavalry_candidates.append(id)
		else:
			halberd_candidates.append(id)
	_assign_attack_group_grants(frontline_candidates, maxi(0, _frontline_attack_slots() - frontline_occupied), player_position)
	_assign_attack_group_grants(archer_candidates, maxi(0, _archer_attack_slots() - archer_occupied), player_position)
	_assign_attack_group_grants(halberd_candidates, maxi(0, _halberd_attack_slots() - halberd_occupied), player_position)
	_assign_attack_group_grants(spear_candidates, maxi(0, _spear_attack_slots() - spear_occupied), player_position)
	_assign_attack_group_grants(crossbow_candidates, maxi(0, _crossbow_attack_slots() - crossbow_occupied), player_position)
	_assign_attack_group_grants(banner_candidates, maxi(0, _banner_attack_slots() - banner_occupied), player_position)
	_assign_attack_group_grants(cavalry_candidates, maxi(0, _cavalry_attack_slots() - cavalry_occupied), player_position)
	_limit_duel_formation_attack_turns()
	for id in range(CAPACITY):
		if active[id] == 1 and previous_grants[id] != attack_turn_grants[id]:
			decision_timers[id] = 0.0

func _assign_attack_group_grants(candidates: Array[int], available_slots: int, player_position: Vector2) -> void:
	if available_slots <= 0:
		return
	candidates.sort_custom(func(first: int, second: int) -> bool:
		if not is_equal_approx(attack_wait_times[first], attack_wait_times[second]):
			return attack_wait_times[first] > attack_wait_times[second]
		return decision_cycles[first] < decision_cycles[second]
	)
	var granted := 0
	var used_sectors: Dictionary = {}
	for candidate in candidates:
		var sector := _attack_sector(candidate, player_position)
		if used_sectors.has(sector):
			continue
		attack_turn_grants[candidate] = 1
		used_sectors[sector] = true
		granted += 1
		if granted >= available_slots:
			return
	for candidate in candidates:
		if attack_turn_grants[candidate] == 1:
			continue
		attack_turn_grants[candidate] = 1
		granted += 1
		if granted >= available_slots:
			return

func _limit_duel_formation_attack_turns() -> void:
	if not is_duel_formation_active():
		return
	if duel_phase == DuelPhase.ASSEMBLING:
		for id in range(CAPACITY):
			if duel_roles[id] != DuelRole.NONE:
				attack_turn_grants[id] = 0
		return
	var shield_grants := 0
	var spear_grants := 0
	var ranged_grants := 0
	for id in range(CAPACITY):
		if attack_turn_grants[id] == 0 or duel_roles[id] == DuelRole.NONE:
			continue
		match duel_roles[id]:
			DuelRole.SHIELD_RING:
				if shield_grants >= DUEL_SHIELD_PUSH_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					shield_grants += 1
			DuelRole.SPEAR_RING:
				if spear_grants >= DUEL_SPEAR_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					spear_grants += 1
			DuelRole.RANGED_RING:
				if ranged_grants >= DUEL_RANGED_ATTACKERS:
					attack_turn_grants[id] = 0
				else:
					ranged_grants += 1

func _attack_sector(id: int, player_position: Vector2) -> int:
	var angle := (positions[id] - player_position).angle() + PI
	return clampi(floori(angle / (TAU * 0.25)), 0, 3)

func _attack_group_for_type(enemy_type: int) -> String:
	if enemy_type == EnemyType.ARCHER:
		return "archer"
	if enemy_type == EnemyType.CROSSBOW:
		return "crossbow"
	if enemy_type == EnemyType.HALBERD or enemy_type == EnemyType.ELITE:
		return "halberd"
	if enemy_type == EnemyType.SPEAR:
		return "spear"
	if enemy_type == EnemyType.BANNER:
		return "banner"
	if enemy_type == EnemyType.CAVALRY:
		return "cavalry"
	return "frontline"

func _attack_staging_range(enemy_type: int) -> float:
	if enemy_type == EnemyType.ARCHER:
		return _attack_range(enemy_type) + 70.0
	if enemy_type == EnemyType.CROSSBOW:
		return _attack_range(enemy_type) + 82.0
	if enemy_type == EnemyType.SPEAR:
		return _attack_range(enemy_type) + 48.0
	if enemy_type == EnemyType.BANNER:
		return _attack_range(enemy_type) + 54.0
	if enemy_type == EnemyType.CAVALRY:
		return _attack_range(enemy_type) + 66.0
	return _attack_range(enemy_type) + 145.0

func _assign_nearest_layer(ids: Array[int], limit: int, player_position: Vector2) -> void:
	ids.sort_custom(func(first: int, second: int) -> bool:
		return positions[first].distance_squared_to(player_position) < positions[second].distance_squared_to(player_position)
	)
	for index in range(mini(limit, ids.size())):
		desired_behavior_layers[ids[index]] = EngagementLayer.ENGAGE

func _refresh_movement_decision(id: int, player_position: Vector2) -> void:
	var layer := int(desired_behavior_layers[id])
	behavior_layers[id] = layer
	decision_cycles[id] += 1
	if duel_exiting[id] == 1:
		movement_targets[id] = duel_exit_targets[id]
		facing_directions[id] = (duel_exit_targets[id] - positions[id]).normalized()
		decision_timers[id] = _reaction_delay(layer, id, decision_cycles[id])
		return
	var target := _formation_target(id, player_position, layer)
	var patrol_radius := 0.0 if duel_roles[id] != DuelRole.NONE or is_named_formation_member(id) or is_iron_bucket_member(id) else _patrol_radius(layer)
	var patrol_angle := deg_to_rad(float((id * 47 + decision_cycles[id] * 29) % 360))
	patrol_offsets[id] = Vector2.from_angle(patrol_angle) * patrol_radius
	movement_targets[id] = _clamp_point(target + patrol_offsets[id])
	# Keep the outer ring visually engaged with the hero while it orbits toward
	# its formation target, so background units do not appear to wander aimlessly.
	var facing_target := player_position if layer != EngagementLayer.ENGAGE else player_position
	if duel_roles[id] != DuelRole.NONE:
		facing_target = positions[id] + _duel_member_facing_direction(id)
	elif is_named_formation_shield_wall(id):
		facing_target = named_formation_origin
	elif is_iron_bucket_member(id):
		facing_target = iron_bucket_center_for_enemy(id)
	var desired_facing := (facing_target - positions[id]).normalized()
	if desired_facing.length_squared() > 0.01:
		facing_directions[id] = desired_facing
	decision_timers[id] = _reaction_delay(layer, id, decision_cycles[id])

func _duel_member_facing_direction(id: int) -> Vector2:
	if id < 0 or id >= CAPACITY:
		return Vector2.RIGHT
	var side := DUEL_WALL_SIDE_LEFT
	if duel_roles[id] == DuelRole.SHIELD_RING:
		side = _duel_shield_slot_side(duel_slots[id])
	elif duel_roles[id] == DuelRole.SPEAR_RING or duel_roles[id] == DuelRole.RANGED_RING:
		side = _duel_support_side_for_slot(duel_roles[id], duel_slots[id])
	return _duel_wall_side_facing(side)

func _navigation_direction_for(id: int, target: Vector2) -> Vector2:
	var direct := target - positions[id]
	if direct.length_squared() <= 0.01:
		navigation_waypoint_active[id] = 0
		return Vector2.ZERO
	if navigation_obstacles.is_empty():
		return direct.normalized()
	if navigation_waypoint_active[id] == 1 and positions[id].distance_to(navigation_waypoints[id]) <= NAVIGATION_WAYPOINT_ARRIVAL:
		navigation_waypoint_active[id] = 0
	if navigation_replan_timers[id] <= 0.0 or not navigation_waypoint_active[id] or navigation_targets[id].distance_to(target) > NAVIGATION_TARGET_SHIFT:
		var waypoint := BATTLEFIELD_LAYOUT.navigation_waypoint_for(
			positions[id],
			target,
			navigation_obstacles,
			_collision_radius_for_navigation(types[id]),
			navigation_preferred_sides[id]
		)
		navigation_waypoints[id] = waypoint
		navigation_targets[id] = target
		navigation_waypoint_active[id] = 1 if waypoint.length_squared() > 0.01 else 0
		navigation_replan_timers[id] = NAVIGATION_REPLAN_INTERVAL
	if navigation_waypoint_active[id] == 1:
		return (navigation_waypoints[id] - positions[id]).normalized()
	return direct.normalized()

func _collision_radius_for_navigation(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.CAVALRY:
			return 28.0
		EnemyType.BANNER:
			return 24.0
		EnemyType.SHIELD, EnemyType.HALBERD:
			return 20.0
		_:
			return 17.0

func _formation_target(id: int, player_position: Vector2, layer: int) -> Vector2:
	if is_duel_formation_active():
		if duel_exiting[id] == 1:
			return duel_exit_targets[id]
		if duel_roles[id] != DuelRole.NONE:
			return _duel_slot_position(duel_roles[id], duel_slots[id])
		var reserve_direction := (positions[id] - duel_center).normalized()
		if reserve_direction.length_squared() <= 0.01:
			reserve_direction = Vector2.from_angle(float(id) * 0.618)
		return duel_center + reserve_direction * 440.0
	if is_named_formation_member(id):
		return named_formation_targets[id]
	if is_iron_bucket_member(id):
		return iron_bucket_targets[id]
	var enemy_type := types[id]
	if enemy_type == EnemyType.SPEAR and layer == EngagementLayer.ENGAGE:
		var side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			side = -1.0 if id % 2 == 0 else 1.0
		var lane_offset := float(id % 3 - 1) * 28.0
		var holding_range := _desired_range(enemy_type) + (54.0 if attack_turn_grants[id] == 0 else 0.0)
		return player_position + Vector2(side * holding_range, lane_offset)
	if enemy_type == EnemyType.CAVALRY and layer == EngagementLayer.ENGAGE:
		var cavalry_side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			cavalry_side = -1.0 if id % 2 == 0 else 1.0
		var cavalry_lane_offset := float(id % 3 - 1) * 24.0
		var cavalry_holding_range := _desired_range(enemy_type) + (72.0 if attack_turn_grants[id] == 0 else 0.0)
		return player_position + Vector2(cavalry_side * cavalry_holding_range, cavalry_lane_offset)
	if enemy_type == EnemyType.BANNER and layer == EngagementLayer.ENGAGE:
		var banner_side := -1.0 if positions[id].x < player_position.x else 1.0
		if is_equal_approx(positions[id].x, player_position.x):
			banner_side = -1.0 if id % 2 == 0 else 1.0
		return player_position + Vector2(banner_side * _desired_range(enemy_type), float(id % 3 - 1) * 42.0)
	var squad_index := floori(float(id) / float(FORMATION_SQUAD_SIZE))
	var squad_slot := id % FORMATION_SQUAD_SIZE
	var sector_index := squad_index % FORMATION_SECTOR_ANGLES.size()
	var ring_index := floori(float(squad_index) / float(FORMATION_SECTOR_ANGLES.size())) % 3
	var battalion_index := floori(float(squad_index) / 9.0)
	var centered_slot := float(squad_slot) - float(FORMATION_SQUAD_SIZE - 1) * 0.5
	var squad_drift := sin(formation_time * 0.22 + float(squad_index) * 1.37) * 0.035
	var angle: float = float(FORMATION_SECTOR_ANGLES[sector_index]) + centered_slot * FORMATION_SLOT_ANGLE_STEP + squad_drift + float(battalion_index) * 0.10
	var radius := _desired_range(enemy_type) + _formation_ring_spacing(enemy_type) * ring_index + float(battalion_index) * 18.0
	if layer == EngagementLayer.ENGAGE and attack_turn_grants[id] == 0:
		radius += 64.0 + float(ring_index) * 12.0
	if layer == EngagementLayer.PRESSURE:
		radius += 108.0 + float(ring_index) * 18.0
	elif layer == EngagementLayer.ATMOSPHERE:
		radius += 178.0 + float(ring_index) * 20.0
	return player_position + Vector2.from_angle(angle) * radius

func _layer_speed_multiplier(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 0.78
		EngagementLayer.ATMOSPHERE: return 0.66
		_: return 1.0

func _patrol_radius(layer: int) -> float:
	match layer:
		EngagementLayer.PRESSURE: return 18.0
		EngagementLayer.ATMOSPHERE: return 22.0
		_: return 4.0

func _reaction_delay(layer: int, id: int, cycle: int) -> float:
	var jitter := float((id * 37 + cycle * 19) % 100) / 100.0
	match layer:
		EngagementLayer.PRESSURE: return 0.35 + jitter * 0.55
		EngagementLayer.ATMOSPHERE: return 0.45 + jitter * 0.45
		_: return 0.10 + jitter * 0.20

func _track_player_motion(delta: float, player_position: Vector2) -> void:
	if has_player_position:
		var instantaneous_velocity := (player_position - last_player_position) / maxf(0.001, delta)
		player_velocity = player_velocity.lerp(instantaneous_velocity.limit_length(360.0), 0.48)
	else:
		has_player_position = true
	last_player_position = player_position

func _predicted_player_position(lead_time: float) -> Vector2:
	return _clamp_point(last_player_position + player_velocity.limit_length(280.0) * lead_time)

func _attack_trigger_range(id: int, player_position: Vector2) -> float:
	if types[id] == EnemyType.HALBERD and _player_is_rushing_toward(id, player_position):
		return HALBERD_BRACE_MAX_DISTANCE
	return _attack_range(types[id])

func _can_trigger_attack(id: int, player_position: Vector2, distance: float) -> bool:
	if is_duel_formation_active():
		if duel_phase == DuelPhase.ASSEMBLING:
			return false
		match duel_roles[id]:
			DuelRole.SHIELD_RING:
				return is_player_near_duel_boundary(player_position, 0.84) and distance <= 118.0 and randf() <= 0.34
			DuelRole.SPEAR_RING:
				return is_player_near_duel_boundary(player_position, 0.82) and distance <= 240.0 and randf() <= 0.22
			DuelRole.RANGED_RING:
				return duel_phase == DuelPhase.SEALED and duel_ranged_attack_cooldown <= 0.0 and _is_duel_member_in_position(id) and distance <= DUEL_RANGED_RADIUS.x + 80.0
	if is_named_formation_shield_wall(id):
		return distance <= 122.0 and randf() <= 0.38
	if is_iron_bucket_shield(id):
		var formation_index := iron_bucket_member_formation[id]
		if formation_index >= 0 and formation_index < iron_bucket_formations.size():
			var formation: Dictionary = iron_bucket_formations[formation_index]
			if str(formation.get("state", "")) == "active" and not bool(formation.get("player_inside", false)):
				return distance <= IRON_BUCKET_SHIELD_PUSH_RADIUS + 98.0 and randf() <= 0.32
		return false
	if is_named_formation_cavalry_channel(id):
		return distance <= 560.0 and randf() <= 0.30
	if types[id] != EnemyType.SPEAR and types[id] != EnemyType.CAVALRY:
		return distance <= _attack_trigger_range(id, player_position)
	var offset := player_position - positions[id]
	if types[id] == EnemyType.CAVALRY:
		return absf(offset.x) <= _attack_range(types[id]) and absf(offset.y) <= CAVALRY_LINE_HALF_WIDTH
	return absf(offset.x) <= _attack_range(types[id]) and absf(offset.y) <= SPEAR_LINE_HALF_WIDTH

func _choose_attack_kind(id: int, player_position: Vector2, distance: float) -> String:
	if is_duel_formation_active():
		if duel_roles[id] == DuelRole.SHIELD_RING:
			return ATTACK_KIND_DUEL_SHIELD_PUSH
		if duel_roles[id] == DuelRole.SPEAR_RING:
			return ATTACK_KIND_DUEL_SPEAR_THRUST
		if duel_roles[id] == DuelRole.RANGED_RING:
			duel_ranged_attack_cooldown = randf_range(DUEL_RANGED_ATTACK_COOLDOWN_MIN, DUEL_RANGED_ATTACK_COOLDOWN_MAX)
			return ATTACK_KIND_CROSSBOW_DIRECT if types[id] == EnemyType.CROSSBOW else ATTACK_KIND_ARCHER_DIRECT
	if is_named_formation_shield_wall(id):
		return ATTACK_KIND_NAMED_SHIELD_PUSH
	if is_iron_bucket_shield(id):
		return ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH
	match types[id]:
		EnemyType.ARCHER:
			if _can_start_archer_volley():
				archer_volley_cooldown = ARCHER_VOLLEY_ENDLESS_COOLDOWN if battle_mode == "endless" else ARCHER_VOLLEY_COOLDOWN
				return ATTACK_KIND_ARCHER_VOLLEY
			if player_velocity.length() >= ARCHER_LEAD_SPEED_THRESHOLD:
				return ATTACK_KIND_ARCHER_LEAD
			return ATTACK_KIND_ARCHER_DIRECT
		EnemyType.HALBERD:
			if _player_is_rushing_toward(id, player_position):
				return ATTACK_KIND_HALBERD_BRACE
			return ATTACK_KIND_HALBERD_SWEEP
		EnemyType.SPEAR:
			if spear_combo_stages[id] == 1:
				spear_combo_stages[id] = 0
				spear_combo_timers[id] = 0.0
				return ATTACK_KIND_SPEAR_THRUST_2
			if _can_start_spear_formation():
				spear_formation_cooldown = SPEAR_FORMATION_COOLDOWN
				return ATTACK_KIND_SPEAR_FORMATION
			spear_combo_stages[id] = 1
			spear_combo_timers[id] = 1.25
			return ATTACK_KIND_SPEAR_THRUST_1
		EnemyType.CROSSBOW:
			if _can_start_crossbow_volley():
				crossbow_volley_cooldown = CROSSBOW_VOLLEY_ENDLESS_COOLDOWN if battle_mode == "endless" else CROSSBOW_VOLLEY_COOLDOWN
				return ATTACK_KIND_CROSSBOW_VOLLEY
			return ATTACK_KIND_CROSSBOW_DIRECT
		EnemyType.BANNER:
			return ATTACK_KIND_BANNER_COMMAND
		EnemyType.CAVALRY:
			var horizontal_distance := absf(player_position.x - positions[id].x)
			if cavalry_charge_cooldowns[id] <= 0.0 and horizontal_distance >= CAVALRY_CHARGE_MIN_DISTANCE:
				cavalry_charge_cooldowns[id] = CAVALRY_CHARGE_COOLDOWN
				return ATTACK_KIND_CAVALRY_CHARGE
			return ATTACK_KIND_CAVALRY_STAB
	return ATTACK_KIND_DEFAULT

func _attack_target_for_kind(id: int, attack_kind: String, player_position: Vector2) -> Vector2:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH, ATTACK_KIND_NAMED_SHIELD_PUSH, ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH:
			return player_position
		ATTACK_KIND_DUEL_SPEAR_THRUST:
			return player_position
		ATTACK_KIND_ARCHER_LEAD:
			return _predicted_player_position(0.24)
		ATTACK_KIND_ARCHER_VOLLEY:
			return _predicted_player_position(0.30)
		ATTACK_KIND_CROSSBOW_DIRECT:
			return _predicted_player_position(0.16)
		ATTACK_KIND_CROSSBOW_VOLLEY:
			return _predicted_player_position(0.26)
		ATTACK_KIND_HALBERD_SWEEP:
			return positions[id] + _halberd_horizontal_direction(id, player_position) * HALBERD_SWEEP_RANGE
		ATTACK_KIND_HALBERD_BRACE:
			var brace_target := _predicted_player_position(0.16)
			return positions[id] + _halberd_horizontal_direction(id, brace_target) * HALBERD_BRACE_MAX_DISTANCE
		ATTACK_KIND_SPEAR_THRUST_1, ATTACK_KIND_SPEAR_THRUST_2, ATTACK_KIND_SPEAR_FORMATION:
			return positions[id] + _spear_horizontal_direction(id, player_position) * _attack_range(EnemyType.SPEAR)
		ATTACK_KIND_CAVALRY_STAB:
			return positions[id] + _spear_horizontal_direction(id, player_position) * 104.0
		ATTACK_KIND_CAVALRY_CHARGE:
			return positions[id] + _spear_horizontal_direction(id, player_position) * CAVALRY_CHARGE_DISTANCE
	return player_position

func _can_start_archer_volley() -> bool:
	if archer_volley_cooldown > 0.0:
		return false
	if battle_mode != "endless" and (battle_mode != "story" or battle_elapsed < ARCHER_VOLLEY_STORY_TIME):
		return false
	var engaged_archers := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.ARCHER and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_archers += 1
			if engaged_archers >= 3:
				return true
	return false

func _can_start_spear_formation() -> bool:
	if spear_formation_cooldown > 0.0:
		return false
	var engaged_spears := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.SPEAR and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_spears += 1
			if engaged_spears >= SPEAR_FORMATION_MIN_MEMBERS:
				return true
	return false

func _can_start_crossbow_volley() -> bool:
	if crossbow_volley_cooldown > 0.0:
		return false
	if battle_mode != "endless" and (battle_mode != "story" or battle_elapsed < CROSSBOW_VOLLEY_STORY_TIME):
		return false
	var engaged_crossbows := 0
	for id in range(CAPACITY):
		if active[id] == 1 and types[id] == EnemyType.CROSSBOW and behavior_layers[id] == EngagementLayer.ENGAGE:
			engaged_crossbows += 1
			if engaged_crossbows >= CROSSBOW_VOLLEY_MIN_MEMBERS:
				return true
	return false

func _spear_horizontal_direction(id: int, player_position: Vector2) -> Vector2:
	var horizontal_delta := player_position.x - positions[id].x
	if absf(horizontal_delta) > 0.01:
		return Vector2.RIGHT if horizontal_delta > 0.0 else Vector2.LEFT
	if absf(facing_directions[id].x) > 0.01:
		return Vector2.RIGHT if facing_directions[id].x > 0.0 else Vector2.LEFT
	return Vector2.RIGHT if id % 2 == 0 else Vector2.LEFT

func _halberd_horizontal_direction(id: int, target: Vector2) -> Vector2:
	var horizontal_delta := target.x - positions[id].x
	if absf(horizontal_delta) > 0.01:
		return Vector2.RIGHT if horizontal_delta > 0.0 else Vector2.LEFT
	if absf(facing_directions[id].x) > 0.01:
		return Vector2.RIGHT if facing_directions[id].x > 0.0 else Vector2.LEFT
	return Vector2.RIGHT if id % 2 == 0 else Vector2.LEFT

func _player_is_rushing_toward(id: int, player_position: Vector2) -> bool:
	var speed := player_velocity.length()
	if speed < HALBERD_BRACE_APPROACH_SPEED:
		return false
	var to_halberd := positions[id] - player_position
	var distance := to_halberd.length()
	if distance < HALBERD_BRACE_MIN_DISTANCE or distance > HALBERD_BRACE_MAX_DISTANCE:
		return false
	return player_velocity.normalized().dot(to_halberd.normalized()) >= 0.58

func _attack_windup_for_kind(enemy_type: int, attack_kind: String) -> float:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH, ATTACK_KIND_NAMED_SHIELD_PUSH, ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH: return 0.46
		ATTACK_KIND_DUEL_SPEAR_THRUST: return 0.54
		ATTACK_KIND_ARCHER_VOLLEY: return 0.96
		ATTACK_KIND_CROSSBOW_VOLLEY: return 0.96
		ATTACK_KIND_BANNER_COMMAND: return 0.68
		ATTACK_KIND_CAVALRY_CHARGE: return 0.70
		ATTACK_KIND_CAVALRY_STAB: return 0.52
		ATTACK_KIND_HALBERD_SWEEP: return 0.64
		ATTACK_KIND_HALBERD_BRACE: return 0.78
		ATTACK_KIND_SPEAR_THRUST_2: return 0.68
		ATTACK_KIND_SPEAR_FORMATION: return 1.14
	return _attack_windup(enemy_type)

func _attack_cooldown_for_kind(enemy_type: int, attack_kind: String) -> float:
	match attack_kind:
		ATTACK_KIND_DUEL_SHIELD_PUSH, ATTACK_KIND_NAMED_SHIELD_PUSH, ATTACK_KIND_IRON_BUCKET_SHIELD_PUSH: return 1.55
		ATTACK_KIND_DUEL_SPEAR_THRUST: return 1.75
		ATTACK_KIND_HALBERD_SWEEP: return 1.55
		ATTACK_KIND_HALBERD_BRACE: return 2.25
		ATTACK_KIND_SPEAR_THRUST_1: return 0.44
		ATTACK_KIND_SPEAR_THRUST_2: return 1.60
		ATTACK_KIND_SPEAR_FORMATION: return 5.20
		ATTACK_KIND_CROSSBOW_VOLLEY: return 2.60
		ATTACK_KIND_BANNER_COMMAND: return 6.20
		ATTACK_KIND_CAVALRY_CHARGE: return 1.65
		ATTACK_KIND_CAVALRY_STAB: return 1.35
	return _attack_cooldown(enemy_type)

func _engage_halberd_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 3
		if battle_elapsed < 420.0:
			return 4
		if battle_elapsed < 780.0:
			return 5
		return 6
	return ENGAGE_HALBERD_LIMIT

func _engage_melee_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 14
		if battle_elapsed < 420.0:
			return 18
		if battle_elapsed < 780.0:
			return 22
		return 25
	if battle_mode == "story":
		if battle_elapsed < 30.0:
			return 28
		if battle_elapsed < 90.0:
			return 32
		if battle_elapsed < 150.0:
			return 42
		if battle_elapsed < 180.0:
			return 40
		if battle_elapsed >= 120.0:
			return 12
		if battle_elapsed >= 45.0:
			return 10
		return 9
	return ENGAGE_MELEE_LIMIT

func _engage_archer_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 4
		if battle_elapsed < 420.0:
			return 5
		if battle_elapsed < 780.0:
			return 6
		return 7
	if battle_mode == "story":
		if battle_elapsed < 30.0:
			return 3
		if battle_elapsed < 90.0:
			return 5
		if battle_elapsed < 150.0:
			return 7
		if battle_elapsed < 180.0:
			return 6
		if battle_elapsed >= 130.0:
			return 6
		if battle_elapsed >= 70.0:
			return 5
		return 4
	return ENGAGE_ARCHER_LIMIT

func _engage_spear_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 4
		if battle_elapsed < 420.0:
			return 5
		if battle_elapsed < 780.0:
			return 6
		return 7
	if battle_mode == "story":
		if battle_elapsed < 30.0:
			return 2
		if battle_elapsed < 90.0:
			return 4
		return 6
	return 4 if battle_elapsed < 240.0 else 5

func _engage_crossbow_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 2
		if battle_elapsed < 420.0:
			return 3
		if battle_elapsed < 780.0:
			return 4
		return 5
	if battle_mode == "story":
		return 2 if battle_elapsed < 90.0 else 4
	return 3 if battle_elapsed < 180.0 else 4

func _engage_cavalry_limit() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 1
		if battle_elapsed < 420.0:
			return 2
		if battle_elapsed < 780.0:
			return 3
		return 4
	if battle_mode == "story":
		return 1 if battle_elapsed < 90.0 else 3
	return 3 if battle_elapsed < 240.0 else 4

func _frontline_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 6
		if battle_elapsed < 420.0:
			return 7
		if battle_elapsed < 780.0:
			return 8
		return 9
	if battle_mode == "story":
		if battle_elapsed < 30.0:
			return 12
		if battle_elapsed < 90.0:
			return 13
		return 14
	return 4

func _archer_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 4
		if battle_elapsed < 420.0:
			return 5
		if battle_elapsed < 780.0:
			return 6
		return 7
	if battle_mode == "story":
		return 1 if battle_elapsed < 30.0 else 2
	return 3

func _crossbow_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 2
		if battle_elapsed < 420.0:
			return 3
		if battle_elapsed < 780.0:
			return 4
		return 5
	if battle_mode == "story":
		return 1 if battle_elapsed < 30.0 else 2
	return 2

func _halberd_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 2
		if battle_elapsed < 420.0:
			return 3
		if battle_elapsed < 780.0:
			return 4
		return 5
	if battle_mode == "story":
		return 1 if battle_elapsed < 90.0 else 2
	return 1

func _spear_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 2
		if battle_elapsed < 420.0:
			return 3
		if battle_elapsed < 780.0:
			return 4
		return 5
	if battle_mode == "story":
		return 1 if battle_elapsed < 30.0 else 2
	return 2

func _banner_attack_slots() -> int:
	return 1

func _cavalry_attack_slots() -> int:
	if battle_mode == "endless":
		if battle_elapsed < 180.0:
			return 1
		if battle_elapsed < 420.0:
			return 2
		if battle_elapsed < 780.0:
			return 3
		return 4
	if battle_mode == "story":
		return 1 if battle_elapsed < 90.0 else 2
	return 2

func _clamp_point(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, bounds.position.x + 8.0, bounds.end.x - 8.0),
		clampf(point.y, bounds.position.y + 8.0, bounds.end.y - 8.0)
	)

func _spatial_cell_for(at: Vector2) -> Vector2i:
	return Vector2i(floori(at.x / SPATIAL_CELL_SIZE), floori(at.y / SPATIAL_CELL_SIZE))

func _personal_space(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 38.0
		EnemyType.SHIELD: return 36.0
		EnemyType.SPEAR: return 34.0
		EnemyType.GUARD: return 34.0
		EnemyType.HALBERD: return 32.0
		EnemyType.ARCHER: return 30.0
		EnemyType.CROSSBOW: return 31.0
		EnemyType.BANNER: return 36.0
		EnemyType.CAVALRY: return 39.0
		_: return 28.0

func _forced_displacement_resistance(enemy_type: int) -> float:
	var time_multiplier := lerpf(1.0, 0.72, clampf(battle_elapsed / 900.0, 0.0, 1.0))
	match enemy_type:
		EnemyType.ELITE: return maxf(0.15, 0.50 * time_multiplier)
		EnemyType.SHIELD: return maxf(0.15, 0.65 * time_multiplier)
		EnemyType.GUARD: return maxf(0.15, 0.75 * time_multiplier)
		EnemyType.CAVALRY: return maxf(0.24, 0.42 * time_multiplier)
		_: return maxf(0.15, time_multiplier)

func _formation_ring_spacing(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE, EnemyType.SHIELD: return 32.0
		EnemyType.SPEAR: return 30.0
		EnemyType.ARCHER: return 28.0
		EnemyType.CROSSBOW: return 30.0
		EnemyType.BANNER: return 38.0
		EnemyType.CAVALRY: return 42.0
		_: return 26.0

func _clamp_position(id: int) -> void:
	var min_x := bounds.position.x + 8.0
	var max_x := bounds.end.x - 8.0
	var iron_bucket_marching := false
	if is_iron_bucket_member(id):
		var formation_index := iron_bucket_member_formation[id]
		if formation_index >= 0 and formation_index < iron_bucket_formations.size():
			iron_bucket_marching = str(iron_bucket_formations[formation_index].get("state", "")) in ["forming", "marching"]
	if is_duel_formation_active() and duel_roles[id] == DuelRole.SHIELD_RING:
		min_x -= 110.0
		max_x += 110.0
	if not iron_bucket_marching:
		positions[id].x = clampf(positions[id].x, min_x, max_x)
		positions[id].y = clampf(positions[id].y, bounds.position.y + 8.0, bounds.end.y - 8.0)

func _refresh_banner_commands(delta: float) -> void:
	for id in range(CAPACITY):
		command_aura_strengths[id] = 0.0
		command_surge_timers[id] = maxf(0.0, command_surge_timers[id] - delta)
	for banner_id in range(CAPACITY):
		if active[banner_id] == 0 or types[banner_id] != EnemyType.BANNER:
			continue
		for target_id in range(CAPACITY):
			if active[target_id] == 0 or types[target_id] == EnemyType.BANNER:
				continue
			if positions[target_id].distance_squared_to(positions[banner_id]) <= BANNER_AURA_RADIUS * BANNER_AURA_RADIUS:
				command_aura_strengths[target_id] = 1.0

func _command_speed_multiplier(id: int) -> float:
	if command_surge_timers[id] > 0.0:
		return BANNER_COMMAND_SPEED_MULTIPLIER
	return BANNER_SPEED_MULTIPLIER if command_aura_strengths[id] > 0.0 else 1.0

func _command_damage_multiplier(id: int) -> float:
	if command_surge_timers[id] > 0.0:
		return BANNER_COMMAND_DAMAGE_MULTIPLIER
	return BANNER_DAMAGE_MULTIPLIER if command_aura_strengths[id] > 0.0 else 1.0

func _start_cavalry_charge(id: int, target: Vector2) -> void:
	var direction := (target - positions[id]).normalized()
	if absf(direction.x) <= 0.01:
		direction = Vector2.RIGHT if facing_directions[id].x >= 0.0 else Vector2.LEFT
	direction = Vector2.RIGHT if direction.x >= 0.0 else Vector2.LEFT
	cavalry_charge_directions[id] = direction
	cavalry_charge_distances[id] = CAVALRY_CHARGE_DISTANCE
	facing_directions[id] = direction

func _tick_special_attack_motion(id: int, delta: float) -> void:
	if types[id] != EnemyType.CAVALRY or attack_states[id] != AttackState.WINDUP or current_attack_kinds[id] != ATTACK_KIND_CAVALRY_CHARGE:
		return
	var charge_start_remaining := _attack_windup_for_kind(EnemyType.CAVALRY, ATTACK_KIND_CAVALRY_CHARGE) - CAVALRY_CHARGE_START_DELAY
	var motion_delta := delta
	if attack_timers[id] > charge_start_remaining:
		motion_delta = maxf(0.0, delta - (attack_timers[id] - charge_start_remaining))
	if motion_delta <= 0.0:
		return
	if cavalry_charge_distances[id] <= 0.0:
		return
	var travel := minf(cavalry_charge_distances[id], CAVALRY_CHARGE_SPEED * motion_delta)
	positions[id] += cavalry_charge_directions[id] * travel
	cavalry_charge_distances[id] = maxf(0.0, cavalry_charge_distances[id] - travel)
	_clamp_position(id)

func _request_hits_point(request: AttackRequest, point: Vector2) -> bool:
	const SELF_OVERLAP_ATTACK_RADIUS := 28.0
	var offset := point - request.origin
	match request.shape:
		AttackRequest.Shape.CIRCLE:
			return offset.length_squared() <= request.range * request.range
		AttackRequest.Shape.FAN:
			var distance_squared := offset.length_squared()
			if distance_squared > request.range * request.range:
				return false
			if distance_squared <= SELF_OVERLAP_ATTACK_RADIUS * SELF_OVERLAP_ATTACK_RADIUS:
				return true
			if distance_squared < request.inner_radius * request.inner_radius:
				return false
			return absf(request.direction.angle_to(offset.normalized())) <= request.half_angle
		AttackRequest.Shape.LINE:
			var projected := offset.dot(request.direction)
			if projected < -SELF_OVERLAP_ATTACK_RADIUS or projected > request.range:
				return false
			var perpendicular := absf(offset.cross(request.direction))
			return perpendicular <= request.width * 0.5
	return false

func _stats(enemy_type: int) -> Dictionary:
	match enemy_type:
		EnemyType.HALBERD:
			return {"hp": 42.0, "armor": 4.0, "speed": 85.0}
		EnemyType.ARCHER:
			return {"hp": 22.0, "armor": 0.0, "speed": 72.0}
		EnemyType.SHIELD:
			return {"hp": 55.0, "armor": 12.0, "speed": 75.0}
		EnemyType.SPEAR:
			return {"hp": 36.0, "armor": 3.0, "speed": 84.0}
		EnemyType.CROSSBOW:
			return {"hp": 26.0, "armor": 1.0, "speed": 68.0}
		EnemyType.BANNER:
			return {"hp": 34.0, "armor": 4.0, "speed": 78.0}
		EnemyType.CAVALRY:
			return {"hp": 46.0, "armor": 4.0, "speed": 166.0}
		EnemyType.ELITE:
			return {"hp": 260.0, "armor": 18.0, "speed": 78.0}
		EnemyType.GUARD:
			return {"hp": 70.0, "armor": 8.0, "speed": 76.0}
		_:
			return {"hp": 24.0, "armor": 0.0, "speed": 105.0}

func _threat_health_multiplier() -> float:
	return float(THREAT_HEALTH_MULTIPLIERS[threat_tier])

func _threat_damage_multiplier() -> float:
	return float(THREAT_DAMAGE_MULTIPLIERS[threat_tier])

func _threat_armor_bonus() -> float:
	return float(THREAT_ARMOR_BONUSES[threat_tier])

func _desired_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 230.0
		EnemyType.CROSSBOW: return 276.0
		EnemyType.BANNER: return 232.0
		EnemyType.CAVALRY: return 170.0
		EnemyType.HALBERD: return 68.0
		EnemyType.ELITE: return 135.0
		EnemyType.SPEAR: return 142.0
		EnemyType.SHIELD: return 56.0
		_: return 42.0

func _attack_range(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 280.0
		EnemyType.CROSSBOW: return 340.0
		EnemyType.BANNER: return 252.0
		EnemyType.CAVALRY: return 252.0
		EnemyType.HALBERD: return 68.0
		EnemyType.ELITE: return 155.0
		EnemyType.SPEAR: return 170.0
		EnemyType.SHIELD: return 64.0
		_: return 50.0

func _attack_cooldown(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 2.1
		EnemyType.CROSSBOW: return 2.35
		EnemyType.BANNER: return 6.20
		EnemyType.CAVALRY: return 1.25
		EnemyType.HALBERD, EnemyType.ELITE: return 1.7
		EnemyType.SPEAR: return 1.55
		_: return 1.35

func _attack_windup(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.85
		EnemyType.CROSSBOW: return 0.72
		EnemyType.BANNER: return 0.68
		EnemyType.CAVALRY: return 0.48
		EnemyType.HALBERD, EnemyType.ELITE: return 0.75
		EnemyType.SHIELD: return 0.70
		EnemyType.SPEAR: return 0.58
		_: return 0.60

func _attack_recovery(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ARCHER: return 0.75
		EnemyType.CROSSBOW: return 0.68
		EnemyType.BANNER: return 0.52
		EnemyType.CAVALRY: return 0.56
		EnemyType.HALBERD, EnemyType.ELITE: return 0.38
		EnemyType.SHIELD: return 0.45
		EnemyType.SPEAR: return 0.36
		_: return 0.28

func _cancel_attack(id: int, cooldown: float) -> void:
	attack_states[id] = AttackState.APPROACH
	attack_timers[id] = 0.0
	cooldowns[id] = maxf(cooldowns[id], cooldown)
	current_attack_kinds[id] = ""
	cavalry_charge_distances[id] = 0.0
	cavalry_charge_directions[id] = Vector2.ZERO

func _damage(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD: return 10.0
		EnemyType.ARCHER: return 8.0
		EnemyType.SHIELD: return 6.0
		EnemyType.SPEAR: return 9.0
		EnemyType.CROSSBOW: return 9.0
		EnemyType.BANNER: return 0.0
		EnemyType.CAVALRY: return 11.0
		EnemyType.ELITE: return 16.0
		EnemyType.GUARD: return 9.0
		_: return 5.0

func _experience(enemy_type: int) -> int:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY: return 2
		EnemyType.BANNER: return 3
		EnemyType.ELITE: return 22
		_: return 1

func _ultimate_energy(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.HALBERD, EnemyType.SHIELD, EnemyType.GUARD, EnemyType.SPEAR, EnemyType.CROSSBOW, EnemyType.CAVALRY: return 1.4
		EnemyType.BANNER: return 1.8
		EnemyType.ELITE: return 26.0
		_: return 0.8

func _hurt_duration(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.30
		EnemyType.SHIELD: return 0.45
		EnemyType.GUARD: return 0.45
		_: return 0.68

func _knockback_resistance(enemy_type: int) -> float:
	var time_multiplier := lerpf(1.0, 0.72, clampf(battle_elapsed / 900.0, 0.0, 1.0))
	match enemy_type:
		EnemyType.ELITE: return maxf(0.05, 0.12 * time_multiplier)
		EnemyType.SHIELD: return maxf(0.15, 0.42 * time_multiplier)
		EnemyType.GUARD: return maxf(0.15, 0.62 * time_multiplier)
		EnemyType.CAVALRY: return maxf(0.22, 0.38 * time_multiplier)
		_: return maxf(0.15, time_multiplier)

func _break_duration(enemy_type: int) -> float:
	match enemy_type:
		EnemyType.ELITE: return 0.06
		EnemyType.SHIELD: return 0.12
		EnemyType.GUARD: return 0.14
		_: return 0.20

func _tick_duel_wall_compression(delta: float) -> void:
	if not is_duel_formation_active():
		return

	duel_wall_elapsed += delta

	# 检查是否需要暂停压缩
	if duel_wall_compression_paused:
		duel_wall_compression_pause_remaining = maxf(0.0, duel_wall_compression_pause_remaining - delta)
		if duel_wall_compression_pause_remaining <= 0.0:
			duel_wall_compression_paused = false
		return

	# 计算当前战场宽度
	var current_width_percent := duel_wall_right_percent - duel_wall_left_percent

	# 如果已经达到最小宽度，不再压缩
	if current_width_percent <= DUEL_WALL_MIN_WIDTH_PERCENT:
		return

	# 根据时间阶段决定压缩速度
	var compression_speed := 0.0
	if duel_wall_elapsed < DUEL_WALL_COMPRESSION_PHASE1_TIME:
		# 阶段1：观察期，不压缩
		compression_speed = 0.0
	elif duel_wall_elapsed < DUEL_WALL_COMPRESSION_PHASE2_TIME:
		# 阶段2：压缩期
		compression_speed = DUEL_WALL_COMPRESSION_SPEED_FAST
	else:
		# 阶段3：决战期，压缩到最小宽度后停止
		compression_speed = DUEL_WALL_COMPRESSION_SPEED_SLOW

	# 应用压缩
	var compression_amount := compression_speed * delta * 0.01  # 转换为百分比
	duel_wall_left_percent += compression_amount
	duel_wall_right_percent -= compression_amount

	# 确保不超过最小宽度
	if duel_wall_right_percent - duel_wall_left_percent < DUEL_WALL_MIN_WIDTH_PERCENT:
		var center_percent := (duel_wall_left_percent + duel_wall_right_percent) * 0.5
		duel_wall_left_percent = center_percent - DUEL_WALL_MIN_WIDTH_PERCENT * 0.5
		duel_wall_right_percent = center_percent + DUEL_WALL_MIN_WIDTH_PERCENT * 0.5

func _update_shield_wall_positions() -> void:
	if not is_duel_formation_active():
		return
	# 只更新目标点，实际位置由普通移动循环逐步追踪，避免阵型瞬移成形。
	for id in range(CAPACITY):
		if active[id] == 0 or duel_roles[id] == DuelRole.NONE or duel_exiting[id] == 1:
			continue
		movement_targets[id] = _duel_slot_position(duel_roles[id], duel_slots[id])

func _tick_duel_wall_harassment(delta: float, player_position: Vector2) -> void:
	if not is_duel_formation_active():
		return

	# 更新冷却时间
	duel_wall_spear_harassment_cooldown = maxf(0.0, duel_wall_spear_harassment_cooldown - delta)
	duel_wall_archer_harassment_cooldown = maxf(0.0, duel_wall_archer_harassment_cooldown - delta)
	duel_wall_crossbow_harassment_cooldown = maxf(0.0, duel_wall_crossbow_harassment_cooldown - delta)

	var left_wall_x := bounds.position.x + bounds.size.x * duel_wall_left_percent
	var right_wall_x := bounds.position.x + bounds.size.x * duel_wall_right_percent

	# 计算玩家到盾墙的距离
	var dist_to_left: float = abs(player_position.x - left_wall_x)
	var dist_to_right: float = abs(player_position.x - right_wall_x)
	var closest_wall_dist: float = minf(dist_to_left, dist_to_right)
	var is_near_left: bool = dist_to_left < dist_to_right

	# 检测危险区（近距离）
	if closest_wall_dist < DUEL_WALL_HARASSMENT_ZONE_CLOSE:
		# 同侧枪兵刺击
		if duel_wall_spear_harassment_cooldown <= 0.0:
			_trigger_spear_harassment(player_position, is_near_left)
			duel_wall_spear_harassment_cooldown = DUEL_WALL_SPEAR_COOLDOWN

		# 对侧弓兵齐射
		if duel_wall_archer_harassment_cooldown <= 0.0:
			_trigger_archer_harassment(player_position, not is_near_left)
			duel_wall_archer_harassment_cooldown = DUEL_WALL_ARCHER_COOLDOWN

	# 检测警戒区（中距离）
	elif closest_wall_dist < DUEL_WALL_HARASSMENT_ZONE_FAR:
		# 对侧弩兵直射
		if duel_wall_crossbow_harassment_cooldown <= 0.0:
			_trigger_crossbow_harassment(player_position, not is_near_left)
			duel_wall_crossbow_harassment_cooldown = DUEL_WALL_CROSSBOW_COOLDOWN

func _trigger_spear_harassment(target_pos: Vector2, from_left: bool) -> void:
	# 找到同侧的枪兵发起攻击
	var harassment_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or types[id] != EnemyType.SPEAR:
			continue
		if duel_roles[id] != DuelRole.SPEAR_RING:
			continue
		# 检查是否在正确一侧
		var is_on_left := positions[id].x < bounds.get_center().x
		if is_on_left == from_left:
			harassment_ids.append(id)
			if harassment_ids.size() >= 2:  # 最多2个枪兵同时骚扰
				break

	# 发起刺击攻击
	for id in harassment_ids:
		var attack_direction := (target_pos - positions[id]).normalized()
		var attack_origin := positions[id] + attack_direction * 30.0
		enemy_attack_requested.emit(
			id,
			attack_origin,
			target_pos,
			EnemyType.SPEAR,
			DUEL_WALL_SPEAR_DAMAGE,
			0.8,  # 预警时间
			"spear_harassment"
		)

func _trigger_archer_harassment(target_pos: Vector2, from_left: bool) -> void:
	# 找到对侧的弓兵发起齐射
	var harassment_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or types[id] != EnemyType.ARCHER:
			continue
		if duel_roles[id] != DuelRole.RANGED_RING:
			continue
		var is_on_left := positions[id].x < bounds.get_center().x
		if is_on_left == from_left:
			harassment_ids.append(id)
			if harassment_ids.size() >= 3:  # 最多3个弓兵齐射
				break

	# 发起高抛齐射
	for id in harassment_ids:
		enemy_attack_requested.emit(
			id,
			positions[id],
			target_pos,
			EnemyType.ARCHER,
			DUEL_WALL_ARCHER_DAMAGE,
			1.2,  # 预警时间（较长，因为是抛射）
			ATTACK_KIND_ARCHER_LEAD
		)

func _trigger_crossbow_harassment(target_pos: Vector2, from_left: bool) -> void:
	# 找到对侧的弩兵发起直射
	var harassment_ids: Array[int] = []
	for id in range(CAPACITY):
		if active[id] == 0 or types[id] != EnemyType.CROSSBOW:
			continue
		if duel_roles[id] != DuelRole.RANGED_RING:
			continue
		var is_on_left := positions[id].x < bounds.get_center().x
		if is_on_left == from_left:
			harassment_ids.append(id)
			if harassment_ids.size() >= 2:  # 最多2个弩兵直射
				break

	# 发起直射攻击
	for id in harassment_ids:
		enemy_attack_requested.emit(
			id,
			positions[id],
			target_pos,
			EnemyType.CROSSBOW,
			DUEL_WALL_CROSSBOW_DAMAGE,
			0.72,  # 预警时间
			ATTACK_KIND_CROSSBOW_DIRECT
		)

# 玩家低血量时暂停盾墙压缩
func pause_duel_wall_compression_for_low_health() -> void:
	if not is_duel_formation_active():
		return
	if duel_wall_compression_paused:
		return  # 已经暂停了
	duel_wall_compression_paused = true
	duel_wall_compression_pause_remaining = DUEL_WALL_PLAYER_LOW_HEALTH_PAUSE

# Boss血量低时加速压缩
func get_duel_wall_compression_speed_multiplier(boss_health_percent: float) -> float:
	if boss_health_percent < 0.3:
		return 1.5  # 加速50%
	return 1.0

# 获取当前战场宽度（用于UI显示）
func get_duel_wall_width_percent() -> float:
	if not is_duel_formation_active():
		return 1.0
	return duel_wall_right_percent - duel_wall_left_percent
