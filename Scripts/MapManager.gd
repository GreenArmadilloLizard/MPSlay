extends Node

class_name MapManager

signal tile_changed(new_floor_map)

var floor_map : TileMap
var object_map : TileMap
var effect_map : TileMap

enum tile_object{
	Empty = -1,
	Base = 0,
	Tower = 1
	Peasant = 2,
	Bandit = 3,
	Warrior = 4,
	Knight = 5
	}

enum tile_effect{
	Empty = -1,
	Sleep = 0,
	}

var troop_upgrade = {
	tile_object.Peasant : tile_object.Bandit,
	tile_object.Bandit : tile_object.Warrior,
	tile_object.Warrior : tile_object.Knight,
}

var object_power = {
	tile_object.Empty : 0,
	tile_object.Base : 1,
	tile_object.Tower : 2,
	tile_object.Peasant : 1,
	tile_object.Bandit : 2,
	tile_object.Warrior : 3,
	tile_object.Knight : 4
}

var object_cost = {
	tile_object.Empty : 0,
	tile_object.Base : 0,
	tile_object.Tower : 0,
	tile_object.Peasant : 2,
	tile_object.Bandit : 6,
	tile_object.Warrior : 18,
	tile_object.Knight : 54
}

var object_buy_cost = {
	tile_object.Tower : 30,
	tile_object.Peasant : 10
}

var bases := []

func _ready():
	if floor_map == null:
		floor_map = $FloorMap
		object_map = $ObjectMap
		effect_map = $EffectMap

	#register Bases
	bases.clear()
	var all_obj_tiles = object_map.get_used_cells()
	for map_pos in all_obj_tiles:
		if get_object(map_pos) == tile_object.Base:
			var new_base = BaseClass.new(map_pos)
			bases.append(new_base)
			update_tile(map_pos)

	var all_floor_tiles = floor_map.get_used_cells()
	for map_pos in all_floor_tiles:
		update_tile(map_pos)

	for base in bases:
		update_base(base.position)
		base.start_turn()


func clear_effect(map_pos):
	effect_map.set_cellv(map_pos, tile_effect.Empty)

func set_effect(map_pos, effect):
	effect_map.set_cellv(map_pos, effect)

func get_all_objects():
	return object_map.get_used_cells()

func get_all_tiles():
	return floor_map.get_used_cells()

# returns removed object
func remove_object(map_pos : Vector2) -> int:
	var old_obj := object_map.get_cellv(map_pos) as int
	object_map.set_cellv(map_pos, tile_object.Empty)

	if old_obj == tile_object.Base:
		var del_me = get_base_with_pos(map_pos)
		bases.erase(del_me)
	return old_obj

# removes objects and places one
func place_object(map_pos : Vector2, obj : int):
	remove_object(map_pos)
	object_map.set_cellv(map_pos, obj)
	if obj == tile_object.Base:
		var new_base = BaseClass.new(map_pos)
		bases.append(new_base)

# moves obj from A to B. if A is empty it does nothing. Does not check if B is empty
func move_object(from_map_pos : Vector2, to_map_pos : Vector2):
	var target_obj := object_map.get_cellv(from_map_pos) as int
	if target_obj == tile_object.Empty:
		print("Target is empty")
		return

	place_object(from_map_pos, tile_object.Empty)
	place_object(to_map_pos, target_obj)

# converts tile to new color then updates neighbours
func convert_tile(map_pos : Vector2, new_team : int):
	if get_team(map_pos) == new_team:
		return
	floor_map.set_cellv(map_pos, new_team)
	for tile in get_neighbours(map_pos):
		update_tile(tile)
	emit_signal("tile_changed",floor_map)

func starve_area(map_pos : Vector2):
	var area = get_area(map_pos)
	for tile in area:
		if is_troop(tile):
			remove_object(tile)

func update_base(map_pos):
	var base = get_base_with_pos(map_pos)
	var area = get_area(map_pos)

	base.income = len(area)
	base.wages = 0
	for tile in area:
		if get_object(tile) != tile_object.Empty:
			base.wages -= object_cost[get_object(tile)]

# fuses all bases in an area to one
func update_tile(map_pos : Vector2):
	var area := get_area(map_pos)
	if len(area) == 0:
		return
	elif len(area) == 1:
		remove_object(area[0])
		return
	var local_bases := []
	var local_troops := []
	for tile in area:
		if object_map.get_cellv(tile) == tile_object.Base:
			local_bases.append(tile)
		elif is_troop(tile):
			local_troops.append(tile)

	var main_base
	if len(local_bases) == 0: # if there is no base
		var ran_index = randi() % len(area)
		for i in range(len(area)):
			if object_map.get_cellv(area[ran_index]) == tile_object.Empty:
				break
			print(area)
			ran_index = (ran_index + 1) % len(area)
		place_object(area[ran_index], tile_object.Base)
		main_base = area[ran_index]
	elif len(local_bases) >= 2: # if there are 2 or more bases
		var ran_index = randi() % len(local_bases)
		main_base = local_bases[ran_index]
		local_bases.remove(ran_index)
		for base in local_bases:
			fuse_bases(main_base, base)

# returns a list with all positions of tiles from the same team
func get_area(map_pos : Vector2) -> Array:
	var team := floor_map.get_cellv(map_pos) as int
	if team == tile_object.Empty:
		return []
	var todo_check := []
	var done_check := []
	todo_check.append(map_pos)

	while(todo_check.size() > 0):
		var current_tile = todo_check[0]
		todo_check.remove(0)
		done_check.append(current_tile)
		for tile in get_neighbours(current_tile):
			if floor_map.get_cellv(tile) == team && !done_check.has(tile) && !todo_check.has(tile):
				todo_check.append(tile)

	return done_check

#returns the border tiles from area
func get_border(map_pos : Vector2) -> Array:
	var team := floor_map.get_cellv(map_pos) as int
	if team == tile_object.Empty:
		return []
	var todo_check := []
	var done_check := []
	var border := []
	todo_check.append(map_pos)

	while(todo_check.size() > 0):
		var current_tile = todo_check[0]
		todo_check.remove(0)
		done_check.append(current_tile)
		for tile in get_neighbours(current_tile):
			if !done_check.has(tile) && !todo_check.has(tile):
				if get_team(tile) == team:
					todo_check.append(tile)
				elif get_team(tile) != global.Team.Empty && !border.has(tile):
					border.append(tile)
	return border

# Base B's savings will get transfert to A. then B gets removed
func fuse_bases(map_pos_A : Vector2, map_pos_B : Vector2):
	if object_map.get_cellv(map_pos_A) != tile_object.Base || object_map.get_cellv(map_pos_B) != tile_object.Base || map_pos_A == map_pos_B:
		print("There are no 2 bases")
		return

	var baseA := get_base_with_pos(map_pos_A)
	var baseB := get_base_with_pos(map_pos_B)
	baseA.money += baseB.money
	remove_object(map_pos_B)

# upgrades troop. returns true if possible
func upgrade_troop(map_pos : Vector2):
	var obj = get_object(map_pos)
	if !troop_upgrade.has(obj):
		return false
	place_object(map_pos, troop_upgrade[obj])
	update_tile(map_pos)
	return true

# returns base on position map_pos
func get_base_with_pos(map_pos : Vector2) -> BaseClass:
	for base in bases:
			if base.position == map_pos:
				return base
	return null

# returns the first base found in an area
func get_base_in_area(map_pos : Vector2):
	var area = get_area(map_pos)
	for tile in area:
		if get_object(tile) == tile_object.Base:
			return get_base_with_pos(tile)
	print("ERROR: No Base in area " + str(map_pos) + " found.")
	return null

# retuns all bases in an array which are from team team
func get_bases_of_team(team):
	var ret = []
	for base in bases:
		if get_team(base.position) == team:
			ret.append(base)
	return ret

# returns the max power from tile & neighbours from same team
func get_tile_power(map_pos : Vector2) -> int:
	var power = 0
	var team = get_team(map_pos)
	power = max(power, object_power[get_object(map_pos)])
	for tile in get_neighbours(map_pos):
		if get_team(tile) == team:
			power = max(power, object_power[get_object(tile)])
	return power

# returns an array with all positions of neighbours
func get_neighbours(map_pos : Vector2) -> Array:
	var neighbours := []
	if (map_pos.y as int % 2) == 0:
		neighbours.append(map_pos + Vector2(1,0))
		neighbours.append(map_pos + Vector2(-1,0))

		neighbours.append(map_pos + Vector2(0,1))
		neighbours.append(map_pos + Vector2(0,-1))

		neighbours.append(map_pos + Vector2(-1,1))
		neighbours.append(map_pos + Vector2(-1,-1))
	else:
		neighbours.append(map_pos + Vector2(1,0))
		neighbours.append(map_pos + Vector2(-1,0))

		neighbours.append(map_pos + Vector2(0,1))
		neighbours.append(map_pos + Vector2(0,-1))

		neighbours.append(map_pos + Vector2(1,1))
		neighbours.append(map_pos + Vector2(1,-1))
	return neighbours

# TODO: correct Hexa map pos
func world_to_map(world_pos : Vector2):
	return floor_map.world_to_map(world_pos)

# TODO: correct Hexa map pos
func map_to_world(map_pos : Vector2):
	return floor_map.map_to_world(map_pos) + Vector2(50,50)

# returns the id on object_map
func get_object(map_pos : Vector2):
	return object_map.get_cellv(map_pos)

# returns true if tile contains troop obj
func is_troop(map_pos : Vector2):
	var obj = get_object(map_pos)
	if obj == tile_object.Peasant \
	or obj == tile_object.Bandit \
	or obj == tile_object.Warrior \
	or obj == tile_object.Knight:
		return true
	else:
		return false

# returns the team on floor_map
func get_team(map_pos : Vector2):
	return floor_map.get_cellv(map_pos)

func ai_reset_map():
	floor_map = TileMap.new()
	object_map = TileMap.new()
