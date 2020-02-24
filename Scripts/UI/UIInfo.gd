extends CanvasLayer

signal unit_buy(unit_index)

func _on_Game_select(player, map_pos, base):
	$WindowContainer/BaseInfo.update_info(base)

func _on_Map_tile_changed(new_map : TileMap):
	var player_cells = {}
	for cell in new_map.get_used_cells():
		player_cells[new_map.get_cellv(cell)] = player_cells.get(new_map.get_cellv(cell), 0) + 1


	$WindowContainer/PlayerInfo.update_bars(player_cells)


func _on_BuyTroopButt_pressed():
	emit_signal("unit_buy", MapManager.tile_object.Peasant)


func _on_BuyTowerButt_pressed():
	emit_signal("unit_buy", MapManager.tile_object.Tower)


func _on_Game_start_of_turn(team):
	$WindowContainer/TurnDisplay.set_current_team(team)

sync func set_cpu_icons(bool_array : PoolByteArray):
	$WindowContainer/PlayerInfo.set_cpu_icons(bool_array)
