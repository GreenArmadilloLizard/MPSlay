extends Control

enum SelectType{
	Teams,
	Levels
}

onready var default_lvl_tex = load("res://icon.png")
onready var item_list := $Menu/ItemList

export (String) var next_scene
export (SelectType) var select_type
export (bool) var start_game_after_select

func _ready():
	fill_level_list()


func fill_level_list():
	item_list.clear()

	if select_type == SelectType.Levels:
		for lvl in GameData.level_list:
			item_list.add_item(lvl.name, default_lvl_tex)

	elif select_type == SelectType.Teams:
		for team in GameData.team_list:
			item_list.add_item(team.name, team.tex)


func _on_BackButton_pressed():
	ScreenManager.load_last_scene()


func _on_SelectButton_pressed():
	if len(item_list.get_selected_items()) == 0:
		return

	if select_type == SelectType.Levels:
		GameData.selected_level = item_list.get_selected_items()[0]
		print("Level index " + str(GameData.selected_level) + " selected.")

	elif select_type == SelectType.Teams:
		GameData.selected_team = item_list.get_selected_items()[0]
		print("Team index " + str(GameData.selected_team) + " selected.")

	if start_game_after_select:
		ScreenManager.start_game()
	else:
		ScreenManager.load_scene(next_scene)

