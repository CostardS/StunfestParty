extends Node2D
class_name PlayerVoisin

@export var _hub: PlayerHub
@export var root_node: Node2D
@export var _sprite: Sprite2D
@export var _anim: AnimationPlayer
@export var _angles: Array[float]

@export var _SFX_steps: AudioStream
@export var _SFX_explosion: AudioStream


signal mistake(PlayerVoisin)

var step_distance: float
var target_score: int
var _lights_on: bool
var _initial_position: Vector2

func _ready() -> void:
	_hub.btn1_pressed.connect(move)
	_hub.btn2_pressed.connect(move)

func initialize_player() -> void:
	_sprite.texture = _hub.get_character().idle_sprite
	_initial_position = root_node.position

func move() -> void:
	SFXPlayer.play(_SFX_steps)
	root_node.position.x += step_distance
	_hub.score += 1
	_sprite.texture = _hub.get_character().get_random_sprite([_sprite.texture])
	_sprite.rotation_degrees = _angles[int(_hub.score) % _angles.size()]

	if _lights_on:
		_hub.controls_enabled = false
		mistake.emit(self)
	elif _hub.score >= target_score: _hub.win()

func explode() -> void:
	SFXPlayer.play(_SFX_explosion)
	_hub.score = 0
	var tween = get_tree().create_tween()
	tween.tween_property(root_node,"position", _initial_position,.75)
	_anim.play("explode")

func change_lights(lights_on: bool) -> void:
	_lights_on = lights_on
	if !lights_on:
		_hub.controls_enabled = true
