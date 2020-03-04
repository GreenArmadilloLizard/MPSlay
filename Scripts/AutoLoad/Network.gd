extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 25565
const MAX_PLAYERS = 5


# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Player", team = 0 }

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Creating a Server
func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	my_info = { name = "Player", team = GameData.selected_team }
	change_player_info(1, my_info)
	if GameData.multiplayer_mode:
		get_tree().refuse_new_network_connections = false
	else:
		get_tree().refuse_new_network_connections = true
	print("Server was created.")


# Joining a Server
func join_server(server_ip):
	if server_ip == '' or server_ip == 'localhost':
		server_ip = DEFAULT_IP
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	print("Trying to join server on IP " + str(server_ip) + ":" + str(DEFAULT_PORT))

# Called on both clients and server when a peer connects
func _player_connected(id):
	print("Player with ID " + str(id) + " connected.")
	rpc_id(id, "change_player_info",get_tree().get_network_unique_id(), my_info)

# Called when a Player disconnects
func _player_disconnected(id):
	print("Player with ID " + str(id) + " disconnected.")
	player_info.erase(id) # Erase player from info.

# Called when you connected Successfully
func _connected_ok():
	print("You connected successfully.")
	var my_id = get_tree().get_network_unique_id()
	rpc("change_player_info",my_id, my_info)

func _server_disconnected():
	print("Server was closed.")

func _connected_fail():
	print("Connection failed.")

# Called when another user Changes Information
sync func change_player_info(id, new_info):
	player_info[id] = new_info
	if id == get_tree().get_network_unique_id():
		my_info = new_info

	# TODO: Update Lobby
