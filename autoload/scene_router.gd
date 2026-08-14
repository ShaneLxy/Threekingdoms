extends Node

const HOME_SCENE := "res://scenes/home/main.tscn"
const RUN_SCENE := "res://scenes/run/main.tscn"
const MAP_EDITOR_SCENE := "res://scenes/map_editor.tscn"

var active_mode := "story"
var active_battlefield_id := "changban"
var active_story_chapter := 1
var title_seen := false

func start_run(mode: String, battlefield_id: String = "changban", story_chapter: int = 1) -> void:
	active_mode = mode
	active_battlefield_id = battlefield_id
	active_story_chapter = clampi(story_chapter, 1, 6)
	get_tree().change_scene_to_file(RUN_SCENE)

func restart_run() -> void:
	get_tree().reload_current_scene()

func go_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)

func is_map_editor_available() -> bool:
	return OS.has_feature("editor") or OS.is_debug_build()

func open_map_editor() -> void:
	if not is_map_editor_available():
		return
	get_tree().change_scene_to_file(MAP_EDITOR_SCENE)

func finish_run(result: Dictionary) -> void:
	var resolved_result := result.duplicate(true)
	if active_mode == "story":
		resolved_result["completed_chapter"] = "story_%02d" % active_story_chapter
	SaveService.apply_result(resolved_result)
