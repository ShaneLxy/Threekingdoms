extends Node

const HOME_SCENE := "res://scenes/home/main.tscn"
const RUN_SCENE := "res://scenes/run/main.tscn"
const MAP_EDITOR_SCENE := "res://scenes/map_editor.tscn"
const TRANSITION_LOADING := 0
const TRANSITION_SWITCHING := 1
const SCENE_SWITCH_TIMEOUT := 8.0
const SCENE_LOAD_TIMEOUT := 45.0
const MINIMUM_LOADING_DURATION := 1.5
const SCENE_SWITCH_DISPLAY_DELAY := 0.10
const STORY_BATTLEFIELD_IDS := ["xinye", "bowangpo_story", "huoshaoxinye", "xiangyangchetui", "dangyangduanhou"]

var active_mode := "story"
var active_battlefield_id := "changban"
var active_story_chapter := 1
var title_seen := false
var pending_scene_path := ""
var scene_transition_pending := false
var transition_state := TRANSITION_LOADING
var transition_target_scene_path := ""
var transition_watchdog := 0.0
var transition_elapsed := 0.0
var transition_switch_delay := 0.0
var transition_load_started := false
var transition_threaded_load_failed := false
var transition_scene_switch_started := false
var transition_scene_pack: PackedScene

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not scene_transition_pending:
		return
	if transition_state == TRANSITION_LOADING:
		_poll_threaded_scene_load(delta)
	else:
		_poll_scene_switch(delta)

func start_run(mode: String, battlefield_id: String = "changban", story_chapter: int = 1) -> void:
	if scene_transition_pending:
		return
	active_mode = mode
	active_story_chapter = clampi(story_chapter, 1, 5)
	active_battlefield_id = STORY_BATTLEFIELD_IDS[active_story_chapter - 1] if active_mode == "story" else battlefield_id
	_begin_scene_transition(RUN_SCENE, "正在点兵 · 奔赴战场")

func _begin_scene_transition(scene_path: String, message: String) -> void:
	scene_transition_pending = true
	pending_scene_path = scene_path
	transition_target_scene_path = scene_path
	transition_state = TRANSITION_LOADING
	transition_watchdog = 0.0
	transition_elapsed = 0.0
	transition_switch_delay = 0.0
	transition_load_started = false
	transition_threaded_load_failed = false
	transition_scene_switch_started = false
	transition_scene_pack = null
	LoadingOverlay.show_transition(message)
	LoadingOverlay.set_progress(0.0, "正在集结军阵")
	# Let the overlay enter the frame before requesting the battle scene on a
	# loader thread. The heavy dependency graph must never block its first draw.
	call_deferred("_start_threaded_scene_load")

func _start_threaded_scene_load() -> void:
	if not scene_transition_pending or transition_load_started:
		return
	if transition_target_scene_path.is_empty():
		transition_target_scene_path = RUN_SCENE
		pending_scene_path = transition_target_scene_path
	var error := ResourceLoader.load_threaded_request(transition_target_scene_path, "PackedScene", false, ResourceLoader.CACHE_MODE_REUSE)
	if error != OK:
		push_error("Unable to start scene load %s (error %d)" % [transition_target_scene_path, error])
		_abort_scene_transition("无法载入战场，请重试")
		return
	transition_load_started = true

func _poll_threaded_scene_load(delta: float) -> void:
	transition_elapsed += maxf(0.0, delta)
	if transition_threaded_load_failed:
		if transition_elapsed >= MINIMUM_LOADING_DURATION:
			transition_state = TRANSITION_SWITCHING
			transition_switch_delay = SCENE_SWITCH_DISPLAY_DELAY
			transition_watchdog = 0.0
			LoadingOverlay.set_progress(99.0, "正在进入战场")
		else:
			_update_loading_progress()
		return
	if not transition_load_started:
		_update_loading_progress()
		return
	var load_progress: Array = []
	var load_status := ResourceLoader.load_threaded_get_status(transition_target_scene_path, load_progress)
	if load_status == ResourceLoader.THREAD_LOAD_FAILED or load_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		# Some platform resource graphs fail threaded loading even though the
		# regular loader can resolve them. Keep the visible loading flow and fall
		# back to the engine's regular scene switch instead of trapping the player.
		transition_threaded_load_failed = true
		transition_load_started = false
		if transition_elapsed >= MINIMUM_LOADING_DURATION:
			transition_state = TRANSITION_SWITCHING
			transition_switch_delay = SCENE_SWITCH_DISPLAY_DELAY
			transition_watchdog = 0.0
			LoadingOverlay.set_progress(99.0, "正在进入战场")
		else:
			_update_loading_progress()
		return
	if load_status == ResourceLoader.THREAD_LOAD_LOADED and transition_scene_pack == null:
		transition_scene_pack = ResourceLoader.load_threaded_get(transition_target_scene_path) as PackedScene
		if transition_scene_pack == null:
			push_error("Loaded resource is not a PackedScene: %s" % transition_target_scene_path)
			_abort_scene_transition("战场资源异常，请重试")
			return
	if transition_scene_pack != null and transition_elapsed >= MINIMUM_LOADING_DURATION:
		transition_state = TRANSITION_SWITCHING
		transition_switch_delay = SCENE_SWITCH_DISPLAY_DELAY
		transition_watchdog = 0.0
		LoadingOverlay.set_progress(100.0, "战场已就绪")
		return
	if transition_elapsed >= SCENE_LOAD_TIMEOUT:
		push_error("Scene load timed out: %s" % transition_target_scene_path)
		_abort_scene_transition("载入战场超时，请重试")
		return
	_update_loading_progress()

func _update_loading_progress() -> void:
	if transition_elapsed < MINIMUM_LOADING_DURATION:
		var fixed_progress := 80.0 * clampf(transition_elapsed / MINIMUM_LOADING_DURATION, 0.0, 1.0)
		LoadingOverlay.set_progress(fixed_progress, "正在调遣兵马")
		return
	var waiting_progress := minf(99.0, 80.0 + (transition_elapsed - MINIMUM_LOADING_DURATION) * 4.0)
	LoadingOverlay.set_progress(waiting_progress, "正在布置战场")

func _change_to_loaded_scene() -> void:
	if not scene_transition_pending or transition_scene_switch_started:
		return
	transition_scene_switch_started = true
	var error := get_tree().change_scene_to_packed(transition_scene_pack) if transition_scene_pack != null else get_tree().change_scene_to_file(transition_target_scene_path)
	if error != OK:
		push_error("Unable to change to preloaded scene %s (error %d)" % [transition_target_scene_path, error])
		_abort_scene_transition("无法进入战场，请重试")

func _poll_scene_switch(delta: float) -> void:
	if not transition_scene_switch_started:
		transition_switch_delay = maxf(0.0, transition_switch_delay - maxf(0.0, delta))
		if transition_switch_delay <= 0.0:
			_change_to_loaded_scene()
		return
	transition_watchdog += maxf(0.0, delta)
	if _target_scene_is_active():
		LoadingOverlay.set_progress(100.0, "战场已就绪")
		_finish_scene_transition()
		return
	if transition_watchdog < SCENE_SWITCH_TIMEOUT:
		return
	# Do not leave the player behind a permanent "已就绪" overlay if the engine
	# reports a scene-change failure. Close the transition and restore routing
	# state so a later departure can be attempted again.
	push_error("Scene transition timed out: %s" % transition_target_scene_path)
	_abort_scene_transition("进入战场超时，请重试")

func _target_scene_is_active() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return false
	if not transition_target_scene_path.is_empty() and current_scene.scene_file_path == transition_target_scene_path:
		return true
	return transition_target_scene_path == RUN_SCENE and current_scene.name == "RunScene"

func _finish_scene_transition() -> void:
	scene_transition_pending = false
	pending_scene_path = ""
	transition_target_scene_path = ""
	transition_state = TRANSITION_LOADING
	transition_watchdog = 0.0
	transition_elapsed = 0.0
	transition_switch_delay = 0.0
	transition_load_started = false
	transition_threaded_load_failed = false
	transition_scene_switch_started = false
	transition_scene_pack = null
	LoadingOverlay.finish_transition()

func _abort_scene_transition(message: String) -> void:
	scene_transition_pending = false
	pending_scene_path = ""
	transition_target_scene_path = ""
	transition_state = TRANSITION_LOADING
	transition_watchdog = 0.0
	transition_elapsed = 0.0
	transition_switch_delay = 0.0
	transition_load_started = false
	transition_threaded_load_failed = false
	transition_scene_switch_started = false
	transition_scene_pack = null
	LoadingOverlay.fail_transition(message)

func restart_run() -> void:
	LoadingOverlay.show_transition("正在重整旗鼓")
	get_tree().reload_current_scene()

func go_home() -> void:
	LoadingOverlay.show_transition("正在回营 · 整备军务")
	get_tree().change_scene_to_file(HOME_SCENE)

func is_map_editor_available() -> bool:
	return OS.has_feature("pc") and (OS.has_feature("editor") or OS.is_debug_build())

func open_map_editor() -> void:
	if not is_map_editor_available():
		return
	LoadingOverlay.show_transition("正在展开舆图")
	get_tree().change_scene_to_file(MAP_EDITOR_SCENE)

func finish_run(result: Dictionary) -> void:
	var resolved_result := result.duplicate(true)
	if active_mode == "story":
		resolved_result["completed_chapter"] = "story_%02d" % active_story_chapter
	SaveService.apply_result(resolved_result)
