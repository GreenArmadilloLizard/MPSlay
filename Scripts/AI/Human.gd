extends Player

onready var cursor_image := $CanvasLayer/BuyingUnit
onready var arrow := $Arrow

export var alt_arrow_mode := false

var start_lmb : Vector2
var selected_buy := -1

func _ready():
	arrow.visible = false
	set_process(true)

func _input(event):
	if event.is_action_pressed("move_object"):
		if selected_buy == -1:
			start_lmb = get_global_mouse_position()
			arrow.points[0] = map_manager.map_to_world(map_manager.world_to_map(get_global_mouse_position())) + Vector2(10,15)
			arrow.visible = true
	elif event.is_action_released("move_object"):
		if selected_buy == -1:
			emit_signal("move_object", player_info, start_lmb , get_global_mouse_position())
			arrow.visible = false
		else:
			emit_signal("place_object", player_info, get_global_mouse_position(), selected_buy)
			set_selected_buy(-1)
	elif event.is_action_pressed("place_object"):
		emit_signal("place_object", player_info, get_global_mouse_position(), MapManager.tile_object.Peasant)
	elif event.is_action_released("place_object"):
		pass
	elif event.is_action_pressed("end_turn"):
		emit_signal("end_turn", player_info)
	elif event.is_action_pressed("delete"):
		emit_signal("remove_object", player_info, get_global_mouse_position())
	elif event.is_action_pressed("ui_cancel"):
		set_selected_buy(-1)

func set_selected_buy(index):
	if selected_buy == index:
		return
	if index != -1:
		var obj_tex = map_manager.object_map.tile_set.tile_get_texture(index)
		cursor_image.texture = obj_tex
		cursor_image.visible = true
	else:
		cursor_image.visible = false
	selected_buy = index

func _process(delta):
	if arrow.visible:
		if alt_arrow_mode:
			arrow.points[1] = map_manager.map_to_world(map_manager.world_to_map(get_global_mouse_position())) + Vector2(10,15)
		else:
			arrow.points[1] = get_global_mouse_position()
	if cursor_image.visible:
		cursor_image.rect_position = get_viewport().get_mouse_position()


func _on_unit_buy(unit_index):
	set_selected_buy(unit_index)
	print("Buying Unit " + str(unit_index))
