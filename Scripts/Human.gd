extends Player

export var alt_arrow_mode := false

var start_lmb : Vector2

func _ready():
	$Arrow.visible = false
	set_process(true)

func _input(event):
	if event.is_action_pressed("move_object"):
		start_lmb = get_global_mouse_position()
		$Arrow.points[0] = map_manager.map_to_world(map_manager.world_to_map(get_global_mouse_position())) + Vector2(10,15)
		$Arrow.visible = true
	elif event.is_action_released("move_object"):
		emit_signal("move_object", player_info, start_lmb , get_global_mouse_position())
		$Arrow.visible = false
	elif event.is_action_pressed("place_object"):
		emit_signal("place_object", player_info, get_global_mouse_position(), 2)
	elif event.is_action_released("place_object"):
		pass
	elif event.is_action_pressed("end_turn"):
		emit_signal("end_turn", player_info)
	elif event.is_action_pressed("delete"):
		emit_signal("remove_object", player_info, get_global_mouse_position())

func _process(delta):
	if $Arrow.visible:
		if alt_arrow_mode:
			$Arrow.points[1] = map_manager.map_to_world(map_manager.world_to_map(get_global_mouse_position())) + Vector2(10,15)
		else: 
			$Arrow.points[1] = get_global_mouse_position()