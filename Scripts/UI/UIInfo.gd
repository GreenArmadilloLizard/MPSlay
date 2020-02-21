extends CanvasLayer

func _on_Game_select(player, map_pos, base):
	$WindowContainer/BaseInfo.update_info(base)

func _on_Map_tile_changed(new_map : TileMap):
	var player_cells = {}
	for cell in new_map.get_used_cells():
		player_cells[new_map.get_cellv(cell)] = player_cells.get(new_map.get_cellv(cell), 0) + 1
	
	
	$WindowContainer/PlayerInfo.update_bars(player_cells)
