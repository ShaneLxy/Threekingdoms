extends Node

const HOME_SCENE := "res://scenes/home/main.tscn"
const RUN_SCENE := "res://scenes/run/main.tscn"

var active_mode := "story"

func start_run(mode: String) -> void:
	active_mode = mode
	get_tree().change_scene_to_file(RUN_SCENE)

func restart_run() -> void:
	get_tree().reload_current_scene()

func go_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)

func finish_run(result: Dictionary) -> void:
	SaveService.apply_result(result)
