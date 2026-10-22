extends Sprite2D

@export var rotation_value: float
@export var colors: Array[Color]

func _ready() -> void:
	randomize()
	colors.shuffle()
	MusicPlayer.beat.connect(change_color)

func _process(delta: float) -> void:
	rotation_degrees += rotation_value * delta

func change_color(beat:int) -> void:
	self_modulate = colors[beat % colors.size()-1]

