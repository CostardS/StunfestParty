extends TextureRect

@export var pulse_scale: float = 1.2
@export var duration_pct: float = .5
@export var colors: Array[Color]
@export var pulse_pct: int = 10

var tween: Tween = null

func _ready() -> void:
	randomize()
	modulate = colors[randi_range(0, colors.size() - 1)]
	MusicPlayer.beat.connect(animate)

func animate(_beat: int) -> void:
	if randi_range(1,100) > pulse_pct: return
	var duration = MusicPlayer.beat_length * duration_pct
	if tween: tween.kill()
	tween = create_tween()
	modulate = colors[randi_range(0, colors.size() - 1)]
	tween.tween_property(self, "scale", Vector2.ONE, duration).from(Vector2.ONE * pulse_scale)