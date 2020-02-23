extends Player

const max_ai_loops = 10

# Scores
const s_protect_unit = 1
const s_new_land = 6
const s_kill = 2
const s_negative_wages_score = -10

const b_min_saved_money = 12
const b_min_furure_balance = 0

var map_manager_class := load("res://Scripts/MapManager.gd")
# Moves are of the form ["move", pos1, pos2]

var acted_objects = []

func start_turn():
	acted_objects = []
	var my_objects = map_manager.get_all_objects_in_team(player_info.team)
	var next_act = my_objects
	var loop_counter = 0

	while !next_act.empty() and loop_counter < max_ai_loops:
		loop_counter += 1
		my_objects = next_act
		next_act = []
		next_act.clear()
		for obj in my_objects:
			var move = get_best_object_move(map_manager, obj)
			if move[0][0] == "move" or move[0][0] == "attack" or move[0][0] ==  "fuse":
				emit_signal("move_object",
				player_info,
				map_manager.map_to_world(move[0][1]) + Vector2(0.1,0.1),
				map_manager.map_to_world(move[0][2]) + Vector2(0.1,0.1)
				)
				if move[0][0] == "move":
					next_act.append(move[0][2])
			elif move[0][0] == "place":
				emit_signal("place_object",
				player_info,
				map_manager.map_to_world(move[0][1]) + Vector2(0.1,0.1),
				MapManager.tile_object.Peasant
				)
				next_act.append(obj)
				next_act.append(move[0][1])

	emit_signal("end_turn", player_info)

func get_copy_of_map(map_manager):
	var new_manager = map_manager_class.new()
	new_manager.ai_reset_map()

	for cell in map_manager.get_all_tiles():
		new_manager.floor_map.set_cellv(cell, map_manager.floor_map.get_cellv(cell))

	for cell in map_manager.get_all_objects():
		new_manager.object_map.set_cellv(cell, map_manager.object_map.get_cellv(cell))

	new_manager._ready()
	return new_manager


func get_best_object_move(manager : MapManager, pos):
	var target = manager.get_object(pos)
	var best_move = [["pass", null, null], 0]

	if manager.is_troop(pos):
		var power = manager.object_power[target]
		var border = manager.get_border(pos)

		for tile in border:
			if manager.get_tile_power(tile) < power:
				var temp_s = 0
				if manager.get_object(tile) == MapManager.tile_object.Empty:
					temp_s = get_score_for_troop_position(manager, target, manager.get_team(pos), tile) + s_new_land
				else:
					temp_s = get_score_for_troop_position(manager, target, manager.get_team(pos), tile) + s_new_land + s_kill * manager.object_power[manager.get_object(tile)]

				if temp_s > best_move[1]:
					best_move = [["attack", pos, tile], temp_s]

		for tile in manager.get_area(pos):
			if manager.get_object(tile) == MapManager.tile_object.Empty: # Move to empty Space
				var temp_s = get_score_for_troop_position(manager, target, manager.get_team(pos), tile)
				if temp_s > best_move[1]:
					best_move = [["move", pos, tile], temp_s]
			elif manager.get_object(tile) == target and manager.troop_upgrade.has(target): # Fuse Troop
				if tile == pos:
					var temp_s = get_score_for_troop_position(manager, target, manager.get_team(pos), tile)
					if temp_s > best_move[1]:
						best_move = [["pass", null, null], temp_s]
				else:
					var temp_s = get_value_for_fuseing(manager, tile)
					if temp_s > best_move[1]:
						best_move = [["fuse", pos, tile], temp_s]

	elif target == MapManager.tile_object.Base:
		var base = manager.get_base_with_pos(pos)
		if base.money < b_min_saved_money:
			return best_move
		elif len(manager.get_area(pos)) - manager.get_area_wages(pos) - manager.object_cost[MapManager.tile_object.Peasant] < b_min_furure_balance:
			return best_move
		else:
			for tile in manager.get_area(pos):
				if manager.get_object(tile) == MapManager.tile_object.Empty:
					return [["place", tile, null], 1]


	return best_move


func get_value_for_fuseing(manager, pos):
	return 1

func get_score_for_troop_position(manager : MapManager, troop, team ,pos):
	var score = 0
	for tile in manager.get_neighbours(pos):
		if manager.get_team(tile) == team and manager.get_object(tile) != MapManager.tile_object.Empty and manager.get_tile_power(tile) < manager.object_power[troop]:
			score += s_protect_unit
	return score
