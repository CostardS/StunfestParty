extends Area2D
class_name DriftCheckpoint

@export var starting_line: bool
@export var last_checkpoint: bool

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body is PlayerDrift :
        (body as PlayerDrift).checkpoint_entered(self)