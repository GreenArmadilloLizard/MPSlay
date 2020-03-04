extends PanelContainer

onready var team_turn_tex := $VBoxContainer/TeamTurnTex
onready var team_turn_label := $VBoxContainer/TeamTurnLabel

export var team_dirt_tex : Texture
export var team_grass_tex : Texture
export var team_mars_tex : Texture
export var team_sand_tex : Texture
export var team_stone_tex : Texture

func set_current_team(team_index):
	team_turn_label.text = "It's Team " + str(global.Team.keys()[team_index + 1]) + "'s' Turn"

	if team_index == global.Team.Dirt:
		team_turn_tex.texture = team_dirt_tex
	elif team_index == global.Team.Grass:
		team_turn_tex.texture = team_grass_tex
	elif team_index == global.Team.Mars:
		team_turn_tex.texture = team_mars_tex
	elif team_index == global.Team.Sand:
		team_turn_tex.texture = team_sand_tex
	elif team_index == global.Team.Stone:
		team_turn_tex.texture = team_stone_tex
