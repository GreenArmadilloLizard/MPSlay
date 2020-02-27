extends Control

signal singleplayer_selected
signal multiplayer_selected
signal options_selected
signal quit_selected


func _on_SPButton_pressed():
	emit_signal("singleplayer_selected")


func _on_MPButton_pressed():
	emit_signal("multiplayer_selected")


func _on_OptionsButton_pressed():
	emit_signal("options_selected")


func _on_QuitButton_pressed():
	emit_signal("quit_selected")
	get_tree().quit()
