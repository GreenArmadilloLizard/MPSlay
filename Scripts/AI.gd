extends Player
# Moves are of the form ["move", pos1, pos2]

enum tile_object{
	Empty = -1,
	Base = 0,
	Tower = 1
	Peasant = 2
	}

func start_turn(): # TODO: first buy, then move
	# Find own Objects
	var my_peasants = []
	for obj in map_manager.object_map.get_used_cells():
		if map_manager.get_team(obj) == player_info.team && map_manager.get_object(obj) == map_manager.tile_object.Peasant:
			my_peasants.append(obj)
	if len(my_peasants) == 0:
		emit_signal("end_turn", player_info)
		return
	var moves = get_possible_moves_for_object(my_peasants[randi() % len(my_peasants)])
	if len(moves) == 0:
		emit_signal("end_turn", player_info)
		return
	var move = moves[randi() % len(moves)]
	if move[0] == "move":
		emit_signal("move_object", player_info, map_manager.map_to_world(move[1]), map_manager.map_to_world(move[2]))
	emit_signal("end_turn", player_info)

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