extends VBoxContainer

@export var amount:int
@export var hbox:PackedScene

var boxes: Array[HboxScroller] = []

func _ready() -> void:
	randomize()
	for i in amount:
		var new_elem = hbox.instantiate()
		add_child(new_elem)
		boxes.append(new_elem)
	randomize_rotation()

func randomize_rotation() -> void:
	rotation_degrees = randf_range(0,180)
