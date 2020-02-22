extends Player

var map_manager_class := load("res://Scripts/MapManager.gd")
# Moves are of the form ["move", pos1, pos2]

var map_simulation = null

func start_turn():
	map_simulation = get_copy_of_map(map_manager)

func get_possible_moves_for_object(map_pos):
	var moves = []
	moves.append(["pass",null ,null]) # No Move is always an Option
	var obj = map_manager.get_object(map_pos)

	if map_manager.is_troop(map_pos): # Troop moves
		var area = map_manager.get_area(map_pos)
		for tile in area:
			if map_manager.get_object(tile) == map_manager.tile_object.Empty:
				moves.append(["move", map_pos, tile]) # Moves in Area

		area = map_manager.get_border(map_pos)
		for tile in area:
			if map_manager.get_tile_power(tile) <= map_manager.object_power[map_manager.tile_object.Peasant] - 1:
				moves.append(["move", map_pos, tile])
	elif obj == map_manager.tile_object.Base: # Base moves
		var base = map_manager.get_base_with_pos(map_pos)
		# TODO: all possible buys and places

	return moves

func get_copy_of_map(map_manager):
	var new_manager = map_manager_class.new()
	new_manager.ai_reset_map()

	for cell in map_manager.get_all_tiles():
		new_manager.floor_map.set_cellv(cell, map_manager.floor_map.get_cellv(cell))

	for cell in map_manager.get_all_objects():
		new_manager.object_map.set_cellv(cell, map_manager.object_map.get_cellv(cell))

	new_manager._ready()
	return new_manager
