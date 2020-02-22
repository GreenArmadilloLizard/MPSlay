extends Node

const DEFAULT_CAM_POS = Vector2(1000, 800)

onready var game_node := get_node("/root/StartUp/Game")
onready var cam := get_node("/root/StartUp/Camera2D")
onready var lobby := get_node("/root/StartUp/Lobby")
var map_manager

enum Team {
	Empty = -1,
	Dirt = 0,
	Grass = 1,
	Mars = 2,
	Sand = 3,
	Stone = 4
	}

enum tile_object{
	Empty = -1,
	Base = 0,
	Tower = 1
	Peasant = 2,
	Bandit = 3,
	Warrior = 4,
	Knight = 5
	}

func _ready():
	seed(121117)

func load_map(map):
	lobby.hide()
	var world = load(map).instance()
	game_node.add_child(world)

	world.start_game(Network.player_info)
	cam.set_offset(DEFAULT_CAM_POS)
	cam.current = true
