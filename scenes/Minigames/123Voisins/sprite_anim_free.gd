extends AnimatedSprite2D

@export var root: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(root.queue_free)
