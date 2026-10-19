extends Node
class_name PlayerPump

@export var _hub: PlayerHub
@export var _sprite: Sprite2D
#@export var _sprite_container: Node2D
@export var _ball: Sprite2D
@export var _explosion: AnimatedSprite2D
#@export var _ball_container: Node2D
@export var _animator: AnimationPlayer
@export var _ball_animator: AnimationPlayer
@export var _pump_speeds: Vector2
@export var _anim_pump_speeds: Vector2
@export var _ball_blink_speeds: Vector2
@export var ball_outline_gradient: Gradient
@export var score_label: Label

@export var _pump_speed_decrease: float

@export var _ball_scale_multiplier: float
@export var _ball_min_scale: float
@export var _pumps: AudioStream
@export var _SFX_explo: AudioStream
@export var _SFX_ding: AudioStream

var ball_max_size: float

signal score_display_finished

var _pumping: bool
var _display_score: bool
var _displayed_score: float
var _alive: bool = true
var _outline_alpha = 1

func _ready() -> void:
	_hub.btn1_pressed.connect(_on_slow_pressed)
	_hub.btn2_pressed.connect(_on_fast_pressed)
	score_label.text = ""
	initialize_display()
	_ball.self_modulate = _hub.get_player_color()

func _process(delta: float) -> void:
	if _display_score: update_score_display(delta)
	if !_alive || !_hub.controls_enabled || !_hub._global_controls_enabled : return

	var speed = -_pump_speed_decrease
	if _hub.btn2_hold: 
		speed = _pump_speeds.y
		_animator.speed_scale = _anim_pump_speeds.y
	elif _hub.btn1_hold: 
		speed = _pump_speeds.x
		_animator.speed_scale = _anim_pump_speeds.x

	_hub.score = max(0, _hub.score + speed * delta)

	if _pumping && !_hub.btn1_hold && !_hub.btn2_hold:
		_animator.play("RESET")
		_sprite.texture = _hub.get_character().idle_sprite

	_pumping = _hub.btn1_hold || _hub.btn2_hold

	if _hub.score > ball_max_size:
		explode()

	var pct = _hub.score / ball_max_size

	_ball_animator.speed_scale = _ball_blink_speeds.x + (_ball_blink_speeds.y - _ball_blink_speeds.x) * pct * pct
	var color = ball_outline_gradient.sample(pct)
	color.a = _outline_alpha
	_ball.material.set("shader_parameter/outline_color", color)
	_ball.material.set("shader_parameter/outline_width", 3 + 9 * pct)
	_ball.material.set("shader_parameter/softness", 1 - 0.85 * pct)
	_ball.scale = Vector2.ONE * (_ball_min_scale + _ball_scale_multiplier * _hub.score)

func initialize_display() -> void :
	change_sprite(0)

func _on_slow_pressed() -> void:
	change_sprite(1)
	if !_animator.is_playing(): _animator.play("Pump")

func _on_fast_pressed() -> void:
	change_sprite(2)
	if !_animator.is_playing(): _animator.play("Pump")

func explode() -> void:
	_alive = false;
	_hub.score = 0
	_explosion.stop()
	_animator.stop()
	_ball.visible = false
	_hub.controls_enabled = false
	_explosion.visible = true
	SFXPlayer.play(_SFX_explo)
	_animator.play("Explode")
	_explosion.play("boom")
	
func change_sprite(state: int) -> void:
	if state == 0 : _sprite.texture = _hub.get_character().idle_sprite
	elif state == 1 : _sprite.texture = _hub.get_character().action1_sprite
	else : _sprite.texture = _hub.get_character().action2_sprite

func pump_sfx() -> void:
	SFXPlayer.play(_pumps)

func outline_blink() -> void:
	_outline_alpha = 1 - _outline_alpha

func on_game_end() -> void:
	_animator.play("RESET")
	change_sprite(0)
	await get_tree().create_timer(1).timeout
	_ball.material.set("shader_parameter/outline_color", Color.TRANSPARENT)
	start_display_score()

func start_display_score() :
	score_label.text = "0cm"
	await get_tree().create_timer(1).timeout
	_display_score = true;

func update_score_display(delta: float) : 
	_displayed_score = min(_hub.score, _displayed_score + delta * 7)
	if _displayed_score >= _hub.score :
		_display_score = false;
		score_label.modulate = _hub.get_player_color()
		_animator.play("score_bump")
		SFXPlayer.play(_SFX_ding)
		score_display_finished.emit()
	score_label.text = str(int(_displayed_score * 200)) + "cm"
