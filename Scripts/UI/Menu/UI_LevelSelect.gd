extends PanelContainer

signal level_selected(level_info)
signal abort_select

onready var item_list := $VBoxContainer/ItemList

export var default_level_tex : Texture


func _ready():
	reload_level_list()


func reload_level_list():
	item_list.clear()
	for level in Data.level_list:
		item_list.add_item(level.name, default_level_tex)


func _on_OkButton_pressed():
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		emit_signal("level_selected", Data.level_list[selected_items[0]])


func _on_BackButton_pressed():
	emit_signal("abort_select")
