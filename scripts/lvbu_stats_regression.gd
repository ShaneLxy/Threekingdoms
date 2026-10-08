extends SceneTree

const BOSS_SCENE := "res://scenes/actors/boss_actor.tscn"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	var boss := load(BOSS_SCENE).instantiate() as BossActor
	root.add_child(boss)
	_assert_stats(boss, BossActor.Archetype.ZHANG_HE, 3600.0, 24.0, "张郃")
	_assert_stats(boss, BossActor.Archetype.XIAHOU_DUN, 4400.0, 28.0, "夏侯惇")
	_assert_stats(boss, BossActor.Archetype.LV_BU, 6975.0, 45.0, "吕布")
	if boss.health_component.current != boss.health_component.maximum:
		_fail("吕布初始化后当前生命必须同步到生命上限")
	print("LVBU_STATS_REGRESSION_PASS")
	boss.queue_free()
	quit()

func _assert_stats(boss: BossActor, archetype: BossActor.Archetype, expected_health: float, expected_armor: float, label: String) -> void:
	boss.set_archetype(archetype)
	boss.activate(Vector2.ZERO, 0)
	if not is_equal_approx(boss.max_health(), expected_health):
		_fail("%s生命上限异常：实际 %.2f，期望 %.2f" % [label, boss.max_health(), expected_health])
	if not is_equal_approx(boss.health_component.maximum, expected_health):
		_fail("%s初始化生命未应用到HealthComponent：实际 %.2f，期望 %.2f" % [label, boss.health_component.maximum, expected_health])
	if not is_equal_approx(boss.armor(), expected_armor):
		_fail("%s防御异常：实际 %.2f，期望 %.2f" % [label, boss.armor(), expected_armor])

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
