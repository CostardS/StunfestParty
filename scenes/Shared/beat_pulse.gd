class_name BeatPulse2D
extends Node2D

@export var pulse_scale: Vector2 = Vector2.ONE
@export var scale_duration_pct: float = 1.0
@export var enabled: bool = true
@export var target: Node2D = null

var tween: Tween = null
var init_scale: Vector2 = Vector2.ONE
var computed_pulse_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if target == null: target = self
	init_scale = target.scale
	computed_pulse_scale = Vector2(init_scale.x * pulse_scale.x, init_scale.y * pulse_scale.y)
	MusicPlayer.beat.connect(animate)

func animate(_beat: int) -> void:
	if !enabled: return
	var duration = MusicPlayer.beat_length * scale_duration_pct
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(target, "scale", init_scale, duration).from(computed_pulse_scale)
