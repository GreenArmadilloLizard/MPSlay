extends Node

const DEFAULT_CAM_POS = Vector2(1000, 800)

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
