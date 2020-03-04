extends Control

export (String) var singleplayer_scene
export (String) var muliplayer_scene


func _on_SingleplayerButton_pressed():
	GameData.multiplayer_mode = false
	ScreenManager.load_scene(singleplayer_scene)


func _on_MultiplayerButton_pressed():
	GameData.multiplayer_mode = true

	return
	ScreenManager.load_scene(muliplayer_scene)


func _on_QuitButton_pressed():
	get_tree().quit()

