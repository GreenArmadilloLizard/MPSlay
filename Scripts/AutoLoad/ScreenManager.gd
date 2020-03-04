extends Node

var last_scene_path := ""
var current_scene_path := "res://Scenes/UI/Menu/TitleScreen.tscn"


func load_scene(scene_path : String) -> void:
	assert(scene_path != "")

	get_tree().change_scene(scene_path)

	last_scene_path = current_scene_path
	current_scene_path = scene_path


func load_last_scene() -> void:
	assert(last_scene_path != "")

	get_tree().change_scene(last_scene_path)

	var temp = current_scene_path
	current_scene_path = last_scene_path
	last_scene_path = temp


func start_game():
	Network.create_server()
	load_scene(GameData.get_selected_level().path)
