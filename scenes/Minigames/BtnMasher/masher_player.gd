extends Node
class_name PlayerMasher

signal replay_end

@export var _hub: PlayerHub
@export var _root: Node2D
@export var _sprite_root: Node2D
@export var _sprite: Sprite2D
@export var _score_label: Label
@export var _angles: Array[float]
@export var _steps: AudioStream
@export var _pumps: AudioStream
@export var _SFX_win: AudioStream
@export var _SFX_lose: AudioStream
@export var anim:AnimationPlayer
@export var ignored_beats: Array[int]

var target_score: int
var _display_score: int = 0
var _is_winner: bool = false
var _replay_ended: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hub.btn1_pressed.connect(_on_btn_pressed)
	_hub.btn2_pressed.connect(_on_btn_pressed)
	initialize_display()

func initialize_display() -> void :
	# _score_label.text = str(int(target_score - _hub.score))
	_score_label.text = ""
	_sprite.texture = _hub.get_character().idle_sprite
	_sprite.z_index = int(_sprite_root.global_position.y)

func _on_btn_pressed() -> void :
	if !_hub.controls_enabled: return
	_hub.score += 1
	SFXPlayer.play(_pumps)
	if int(_hub.score) % 2 == 0 : 
		_sprite_root.scale = Vector2(1,1)
		_sprite.texture = _hub.get_character().idle_sprite
	else : 
		_sprite_root.scale = Vector2 (1 + .25 * (int(_hub.score) % 4 - 2), 1 - .25 * (int(_hub.score) % 4 - 2) )
		_sprite.texture = _hub.get_character().action1_sprite

	# _score_label.text = str(int(target_score - _hub.score))
	# _score_label.text = str(int(_hub.score))
	# if _hub.score >= target_score: _hub.win();
	# _root.position.x = _hub.score * _step_distance
	#_sprite.texture = _hub.get_character().get_random_sprite([_sprite.texture])
	#_sprite.rotation_degrees = _angles[int(_hub.score) % _angles.size()]

func on_play_phase_end(winners:Array[int]) -> void:
	_hub.controls_enabled = false
	_is_winner = winners.has(_hub.get_player_index())
	_sprite_root.scale = Vector2(1,1)
	_sprite.texture = _hub.get_character().idle_sprite

func move_to_dance_spot(position: Vector2 )-> void:
	_root.global_position = position
	_sprite.modulate = Color.BLACK
	_sprite.z_index = int(_sprite_root.global_position.y)

func dance_reveal_1() -> void:
	_sprite.texture = _hub.get_character().action1_sprite
	_sprite.modulate = Color.WHITE

func dance_reveal_2() -> void:
	_sprite.texture = _hub.get_character().action2_sprite

func dance_jump() -> void:
	anim.play('DanceJump')
	
func bind_rhythm() -> void:
	MusicPlayer.beats(0.25).connect(on_beat)
	pass

func on_beat(beat:int) -> void:
	if _replay_ended: return 
	if ignored_beats.has(beat): 
		ignored_beats.remove_at(ignored_beats.find(beat))
		return;
	if _display_score >= int(_hub.score):
		_replay_ended = true
		if _is_winner:
			_sprite.texture = _hub.get_character().action2_sprite
			SFXPlayer.play(_SFX_win)
		else:
			_sprite_root.rotation_degrees = 90
			_sprite.texture = _hub.get_character().idle_sprite
			_sprite.modulate = Color.GRAY
			SFXPlayer.play(_SFX_lose)
		replay_end.emit()
		return;
	_display_score += 1
	_sprite.texture = _hub.get_character().get_random_sprite([_sprite.texture])
	_sprite_root.rotation_degrees = _angles[_display_score % _angles.size()]
	_score_label.text = str(_display_score)
	SFXPlayer.play(_steps)
