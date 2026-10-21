extends Node2D

@export var bounce_velocity = -500.0
@export var sfx: AudioStream;
@export var probability: float = 1
@onready var anim = $Area2D/Animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if randf() > probability : queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.velocity.y = bounce_velocity
	anim.play("default")
	if sfx != null: SFXPlayer.play(sfx);
