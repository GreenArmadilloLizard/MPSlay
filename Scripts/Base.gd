class_name BaseClass

var savings := 0

var income := 0
var wages := 0

var balance := 0
var money := 0

var position := Vector2(-1,-1)

func _init(pos : Vector2):
	position = pos

func start_turn():
	savings = money
	balance = savings + income + wages
	money = balance
