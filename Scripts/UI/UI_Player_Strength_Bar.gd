extends VBoxContainer

export var tint_color : Color

func set_value(new_value : float):
	$PlayerProgress.value = new_value

func _ready():
	$PlayerProgress.tint_progress = tint_color