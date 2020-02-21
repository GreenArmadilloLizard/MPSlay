extends PanelContainer

onready var player_bars = [
	$PlayerBars/Player1,
	$PlayerBars/Player2,
	$PlayerBars/Player3,
	$PlayerBars/Player4,
	$PlayerBars/Player5,
	]

func update_bars(player_tile_count : Dictionary):
	var tile_max := 0.1
	
	for key in player_tile_count.keys():
		tile_max = max(player_tile_count[key], tile_max)
	
	for key in player_tile_count.keys():
		player_bars[key].set_value(player_tile_count[key] / tile_max)