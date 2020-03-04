extends PanelContainer

onready var player_bars = [
	$VBoxContainer/PlayerBars/Player1,
	$VBoxContainer/PlayerBars/Player2,
	$VBoxContainer/PlayerBars/Player3,
	$VBoxContainer/PlayerBars/Player4,
	$VBoxContainer/PlayerBars/Player5,
	]

func update_bars(player_tile_count : Dictionary):
	var tile_max := 0.1

	for key in player_tile_count.keys():
		tile_max = max(player_tile_count[key], tile_max)

	for key in player_tile_count.keys():
		player_bars[key].set_value(player_tile_count[key] / tile_max)

func set_cpu_icons(bool_array : PoolByteArray):
	var index := 0
	for b in bool_array:
		player_bars[index].set_is_computer(b)
		index+=1
