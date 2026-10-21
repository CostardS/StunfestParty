extends Node
class_name PlayerInterro

signal answer_question(player: PlayerInterro, answer:bool)

@export var hub:PlayerHub
@export var root_node: Node2D
@export var scale_pulser: BeatPulse2D
@export var animator: AnimationPlayer
@export var score_animator: AnimationPlayer
@export var score_label: Label
@export var score_up_label: Label
@export var _sprite: Sprite2D
@export var _answer_sign: Sprite2D
@export var _sign_OK: Texture2D
@export var _sign_KO: Texture2D
@export var hp: int
@export var _hearts: Node2D

@export var _SFX_score_change: AudioStream
@export var _SFX_lose: AudioStream

var stun_counter:int
var _answering: bool = false

func _ready() -> void:
	_sprite.texture = hub.get_character().idle_sprite
	hub.btn1_pressed.connect(_answer_true)
	hub.btn2_pressed.connect(_answer_false)
	_answer_sign.visible = false
	score_label.text = str(int(hub.score))
	score_label.self_modulate = hub.get_player_color()
	for i in _hearts.get_child_count():
		(_hearts.get_child(i) as Sprite2D).self_modulate = hub.get_player_color()

func _process(_delta: float) -> void:
	for i in _hearts.get_child_count():
		(_hearts.get_child(i) as Node2D).visible = i < hp

func score() -> void:
	hub.score = hub.score + 1
	animate_score_change(true)

func stun(stun_amount:int, points_lost:int) -> void:
	hp = hp - 1
	stun_counter = stun_amount
	hub.score = max(0, hub.score - points_lost)
	animator.play("drowsy")
	_answer_sign.visible = false
	shake_player()
	if hp <= 0:
		update_score_label(true)
		animator.play("chute")
	else: animate_score_change(false)

func _answer_true() -> void:
	if hp > 0 && !_answering && stun_counter <= 0:
		_answering = true
		_sprite.texture = hub.get_character().action1_sprite
		answer_question.emit(self, true)
		_answer_sign.texture = _sign_OK
		_answer_sign.visible = true
	
func _answer_false() -> void:
	if hp > 0 && !_answering && stun_counter <= 0:
		_answering = true
		_sprite.texture = hub.get_character().action2_sprite
		answer_question.emit(self, false)
		_answer_sign.texture = _sign_KO
		_answer_sign.visible = true

func dim_player() -> void:
	scale_pulser.enabled = false
	if !_answering: _sprite.modulate = Color(255,255,255,.25)

func reset_player() -> void:
	if hp <= 0: return
	if stun_counter > 0: stun_counter = stun_counter - 1

	if stun_counter <= 0:
		animator.play("RESET")
		scale_pulser.enabled = true
	#_sprite.self_modulate = Color.WHITE
	_sprite.modulate = Color.WHITE
	_answering = false
	_sprite.texture = hub.get_character().idle_sprite
	_answer_sign.visible = false

func shake_player() -> void:
	var origin = _sprite.global_position
	var tween = get_tree().create_tween()
	for i in 20:
		tween.tween_property(_sprite, "global_position", origin + Vector2(randf(), randf()) * 20, 0.005)
	tween.tween_property(_sprite, "global_position", origin, 0.05)

func animate_score_change(positive:bool) -> void:
	if positive: score_up_label.text = "+1"
	else: score_up_label.text = "-1"
	score_animator.play("add")

func update_score_label(lose:bool = false) -> void:
	score_label.text = str(int(hub.score))
	if lose: 
		score_label.text = "RIP"
		SFXPlayer.play(_SFX_lose)
	else: SFXPlayer.play(_SFX_score_change)