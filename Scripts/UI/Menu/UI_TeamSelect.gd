extends PanelContainer

signal level_selected(team_index)
signal abort_select

onready var item_list := $VBoxContainer/ItemList

func _ready():
	reload_level_list()


func reload_level_list():
	item_list.clear()
	for level in Data.team_list:
		item_list.add_item(level.name, level.tex)


func _on_OkButton_pressed():
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		emit_signal("level_selected", selected_items[0])


func _on_BackButton_pressed():
	emit_signal("abort_select")
