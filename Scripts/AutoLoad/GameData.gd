extends Node

var multiplayer_mode := false


var selected_level = 0
const level_list := [
	{name = "Level 1", path = "res://Level/World_1.tscn"},
	{name = "Level 2", path = "res://Level/World_2.tscn"},
]

var selected_team = 0
const team_list := [
	{name = "Dirt", tex = preload("res://Asstes/TileMap/dirt_06.png"), index = 0},
	{name = "Grass", tex = preload("res://Asstes/TileMap/grass_05.png"), index = 1},
	{name = "Mars", tex = preload("res://Asstes/TileMap/mars_07.png"), index = 2},
	{name = "Sand", tex = preload("res://Asstes/TileMap/sand_07.png"), index = 3},
	{name = "Stone", tex = preload("res://Asstes/TileMap/stone_07.png"), index = 4},
]


func get_selected_team():
	return team_list[selected_team]


func get_selected_level():
	return level_list[selected_level]
