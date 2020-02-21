class_name Player
extends Node2D

signal move_object(player, from_global_pos, to_global_pos)
signal place_object(player, global_pos, obj)
signal remove_object(player, global_pos)
signal end_turn(player)

var player_info = {}

var game_logic
var map_manager

func init(player_data, p_game_logic, p_map_manager):
	game_logic = p_game_logic
	player_info = player_data
	map_manager = p_map_manager
	
	connect("move_object", game_logic, "_on_player_move")
	connect("place_object", game_logic, "_on_player_place")
	connect("remove_object", game_logic, "_on_player_remove")
	connect("end_turn", game_logic, "_on_player_end_turn")
	
	game_logic.connect("start_of_turn", self , "_on_turn_start")

func _on_turn_start(next_team):
	if next_team == player_info.team:
		start_turn()

func start_turn():
	print("ITS YOUR TURN " + str(name))