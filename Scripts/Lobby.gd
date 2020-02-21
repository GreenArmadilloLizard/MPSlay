extends CanvasLayer

onready var menu_create_game = $"Background/CenterContainer/CreateGame"
onready var menu_join_server = $"Background/CenterContainer/JoinServer"
onready var menu_player_lobby = $"Background/CenterContainer/PlayerLobby"

onready var label_ip_input = $Background/CenterContainer/JoinServer/IPRow/TextfieldIP

func _ready():
		$ContainerIP/LabelIP.text = "Your IP: " + str(IP.get_local_addresses()[1])
		menu_create_game.visible = true # TRIGGER ELSEWERE
		menu_join_server.visible = false
		menu_player_lobby.visible = false
		$ContainerIP.visible = false
		$Background/CenterContainer/LabelLoading.visible = false

func hide():
	for node in get_children():
		node.visible = false

func _on_CreateServer_pressed():
	Network.create_server()
	menu_create_game.visible = false
	menu_player_lobby.visible = true
	#$ContainerIP.visible = true

func _on_PreJoinServer_pressed():
	menu_create_game.visible = false
	menu_join_server.visible = true

func _on_JoinServer_pressed():
	menu_join_server.visible = false
	Network.join_server(label_ip_input.text)
	$Background/CenterContainer/LabelLoading.visible = true
	yield(get_tree(),"connected_to_server")
	$Background/CenterContainer/LabelLoading.visible = false
	menu_player_lobby.visible = true

func _on_ButtonStartGame_pressed():
	rpc("start_game")

sync func start_game():
	global.load_map("res://Level/World_1.tscn")

func _on_ButtonIP_pressed():
	OS.set_clipboard(IP.get_local_addresses()[1])

sync func update_lobby():
	$Background/CenterContainer/PlayerLobby/ItemList.clear()
	var player_list = Network.player_info
	for id in player_list:
		var player = player_list[id]
		$Background/CenterContainer/PlayerLobby/ItemList.add_item("Team " + str(global.Team.keys()[player.team + 1]) + ": " + player.name)
	$Background/CenterContainer/PlayerLobby/ItemList.sort_items_by_text()

func _on_name_text_entered(new_text):
	var my_info = {name = new_text, team = get_team_id()}
	Network.rpc("change_player_info", get_tree().get_network_unique_id(), my_info)
	rpc("update_lobby")

func _on_team_item_selected(ID):
	var my_info = {name = get_player_name(), team = ID}
	Network.rpc("change_player_info", get_tree().get_network_unique_id(), my_info)
	rpc("update_lobby")

func get_player_name() -> String:
	return $Background/CenterContainer/PlayerLobby/HBoxContainer2/NameInput.text

func get_team_name() -> String:
	return $Background/CenterContainer/PlayerLobby/HBoxContainer/SelectTeam.text

func get_team_id() -> int:
	return $Background/CenterContainer/PlayerLobby/HBoxContainer/SelectTeam.selected





















