extends Node2D

signal start_of_turn(team)
signal select(player, map_pos, base)

const max_players = 5
export var camera_speed := 3.0

onready var cam := $Camera2D
onready var map := $Map
onready var player_manager := $Players

const player_scene := "res://Scenes/Human.tscn"
const npc_scene := "res://Scenes/NPC.tscn"

var used_units := []

const possilbe_teams := [global.Team.Dirt, global.Team.Grass, global.Team.Mars, global.Team.Sand, global.Team.Stone]
var current_team = global.Team.Dirt

var player_count
var npc_count

func _input(event):
	if event.is_action_released("debug_i"):
		print("Debug i")
		var base = map.get_base_with_pos(map.world_to_map(get_global_mouse_position()))
		print(base)
		if base != null:
			base.print_self()


func start_game(players):
	player_count = players.size()
	npc_count = max_players - player_count

	# create client player
	var selfPeerID = get_tree().get_network_unique_id()
	var client_player = preload(player_scene).instance()
	client_player.set_name(str(selfPeerID))
	$Players.add_child(client_player)
	# set vars
	client_player.set_network_master(selfPeerID)
	client_player.init(Network.my_info, self, map)
	$UIInfo.connect("unit_buy", client_player, "_on_unit_buy")

	if selfPeerID == 1: # Load NPC, connect with end of turn
		var cpus = [false, false, false, false, false]

		for player in Network.player_info:
			possilbe_teams.erase(Network.player_info[player].team)

		for free_team in possilbe_teams:
			cpus[free_team] = true
			var npc_player = load(npc_scene).instance()
			npc_player.set_name("CPU " + str(free_team))
			$Players.add_child(npc_player)
			npc_player.init({name = "CPU " + str(free_team), team = free_team}, self, map)
			print(npc_player.name + " was created.")

		$UIInfo.rpc("set_cpu_icons", cpus)
	$UIInfo._on_Map_tile_changed(map.floor_map)
	emit_signal("start_of_turn", current_team)

func _on_player_move(player, from_world_pos, to_world_pos):
	var from_map_pos = map.world_to_map(from_world_pos)
	var to_map_pos = map.world_to_map(to_world_pos)
	if from_map_pos == to_map_pos:
		player_select(player, to_map_pos)
	else:
		rpc("move", player, from_world_pos, to_world_pos)
		player_select(player, to_map_pos)

func player_select(player, map_pos):
	if map.get_team(map_pos) != player.team:
		emit_signal("select", player, map_pos, null)
		print("Wrong Select 1") # Not your Tile
		return
	var area = map.get_area(map_pos)
	if area.size() <= 1:
		emit_signal("select", player, map_pos, null)
		print("Wrong Select 2") # Too small area
		return
	var base = map.get_base_in_area(map_pos)
	emit_signal("select", player, map_pos, base)

sync func move(player, from_world_pos, to_world_pos):
	var from_map_pos = map.world_to_map(from_world_pos)
	var to_map_pos = map.world_to_map(to_world_pos)
	print(str(player.name) + " moved from " + str(from_map_pos) + " to " + str(to_map_pos))
	var moving_obj = map.get_object(from_map_pos)

	# Abort Check
	if player.team != current_team:
		print("Wrong Move 1") # Ist nicht an der Reihe
		return
	elif map.get_team(from_map_pos) != player.team:
		print("Wrong Move 2") # Nicht eigenes Feld
		return
	elif !map.is_troop(from_map_pos) :
		print("Wrong Move 3") # Das zu bewegende Objekt ist keine Truppe
		return
	elif map.get_team(to_map_pos) == player.team \
	and (map.get_object(to_map_pos) != map.tile_object.Empty \
	or !map.get_area(to_map_pos).has(from_map_pos)): # TODO Fuse
		if map.get_area(to_map_pos).has(from_map_pos) and map.get_object(to_map_pos) == map.get_object(from_map_pos):
			if map.upgrade_troop(to_map_pos):
				map.remove_object(from_map_pos)
				return
			print("Wrong Move 6") # Cant be Upgradet
			return
		else:
			print("Wrong Move 4") # Eigenes Feld nicht frei oder falsches Gebiet
			return
	elif map.get_team(to_map_pos) != player.team \
	and (!map.get_border(from_map_pos).has(to_map_pos) \
	or map.object_power[map.get_object(from_map_pos)] <= map.get_tile_power(to_map_pos)):
		print("Wrong Move 5") # Power zu wenig oder außer Reichweite
		return
	elif used_units.has(from_map_pos):
		print("Wrong Move 6") # Unit wurde bereits bewegt
		return

	if map.get_team(to_map_pos) != player.team:
		used_units.append(to_map_pos)
		map.set_effect(to_map_pos, map.tile_effect.Sleep)

	map.move_object(from_map_pos, to_map_pos)
	map.convert_tile(to_map_pos, player.team)

func _on_player_place(player, world_pos, obj):
	rpc("place",player, world_pos, obj)
	player_select(player, map.world_to_map(world_pos))
	if player.team == current_team:
		map.update_base_shop_effect(player.team)

sync func place(player, world_pos, obj):
	print(str(player.name) + " placed " + str(obj) + " on " + str(world_pos))
	var map_pos = map.world_to_map(world_pos)
	var base = map.get_base_in_area(map_pos)
	if !base:
		print("Wrong Place 0")  # Keine Base im Gebiet
		return
	if player.team != current_team:
		print("Wrong Place 1") # Ist nicht an der Reihe
		return
	elif map.get_team(map_pos) != player.team:
		print("Wrong Place 2") # Nicht eigenes Feld
		return
	elif obj == map.get_object(map_pos): # Fuse
		if base.money - map.object_buy_cost[obj] < 0:
			print("Not enough Gold")
		elif map.upgrade_troop(map_pos):
			base.money -= map.object_buy_cost[obj] # Pay
			map.update_tile(map_pos)
		return
	elif map.get_object(map_pos) != map.tile_object.Empty:
		print("Wrong Place 3") # Target tile ist nicht leer
		return

	if base.money - map.object_buy_cost[obj] < 0:
		print("Not enough Gold")
		return
	map.place_object(map_pos, obj)
	base.money -= map.object_buy_cost[obj] # Pay
	map.update_tile(map_pos)

func _on_player_remove(player, world_pos):
	rpc("remove", player, world_pos)

sync func remove(player, world_pos):
	print(str(player.name) + " removed on " + str(world_pos))
	var map_pos = map.world_to_map(world_pos)

	if player.team != current_team:
		print("Wrong Remove 1") # Ist nicht an der Reihe
		return
	elif map.get_team(map_pos) != player.team:
		print("Wrong Remove 2") # Nicht eigenes Feld
		return
	elif !map.is_troop(map_pos):
		print("Wrong Remove 3") # Target tile ist nicht leer oder Unit
		return

	map.remove_object(map_pos)
	map.update_tile(map_pos)

func _on_player_end_turn(player):
	rpc("end_turn", player)
	emit_signal("select", player, null, null)

sync func end_turn(player):
	print(str(player.name) + " ended its turn")
	if player.team != current_team:
		print("Wrong End 1")
		return

	if has_player_won(player):
		print(str(player.name) + " Won!")
		return

	current_team = (current_team + 1) % max_players

	var player_bases = map.get_bases_of_team(current_team)
	for base in player_bases:
		map.update_base(base.position)
		base.start_turn()
		if base.money < 0:
			base.money = 0
			map.starve_area(base.position)

	map.clear_all_effects()
	used_units.clear()

	emit_signal("start_of_turn", current_team)

func has_player_won(player):
	var all_tiles = map.get_all_tiles()
	for tile in all_tiles:
		if map.get_team(tile) != player.team:
			return false
	return true
