extends VBoxContainer

export var tint_color : Color
export var player_icon : Texture
export var cpu_icon : Texture

func set_value(new_value : float):
	$PlayerProgress.value = new_value

func _ready():
	$PlayerProgress.tint_progress = tint_color

func set_is_computer(b : bool):
	if b:
		$PlayerIcon.texture = cpu_icon
	else:
		$PlayerIcon.texture = player_icon
