extends HBoxContainer
class_name HboxScroller

@export var amount:int
@export var bg_scroll_element:PackedScene
@export var scroller:Node
@export var speeds:Vector2
@export var anim:AnimationPlayer

var controls: Array[Node] = []
var current_index: int

var init_done:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_speed()
	initialize()

func initialize() -> void:
	if init_done: return
	init_done = true
	for i in amount :
		var new_elem = bg_scroll_element.instantiate()
		controls.append(new_elem)
		add_child(new_elem)

func change_speed() -> void:
	anim.speed_scale = randf_range(speeds.x, speeds.y)
	# if anim.speed_scale < 0: anim.play("reverse")

func slide_elements() -> void:
	var current = controls[current_index]
	remove_child(current)
	if anim.speed_scale > 0:
		add_child(controls[current_index])
		current_index = (current_index + 1) % controls.size()
	else:
		scroller.add_sibling(current)
		current_index = (current_index - 1 + controls.size()) % controls.size()
