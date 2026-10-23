extends Control
class_name PlayerScorePanel

@export var index_text:Label
@export var score_text:Label
@export var portrait:TextureRect
@export var anim:AnimationPlayer
@export var sfx_point:AudioStream
@export var sfx_point_hit:AudioStream

var _player_info:PlayerInfo

func assign_player_info(info: PlayerInfo)-> void:
	_player_info = info
	initialize_display()

func initialize_display() -> void:
	index_text.text = "P" + str(_player_info.player_number)
	score_text.text = str(_player_info.global_party_score)
	index_text.self_modulate = _player_info.get_player_color()
	score_text.self_modulate = _player_info.get_player_color()
	portrait.texture = _player_info.character_info.idle_sprite

func update_display() -> void:
	score_text.text = str(_player_info.global_party_score)
	
func animate_score_up() -> void:
	SFXPlayer.play(sfx_point)
	portrait.texture = _player_info.character_info.action1_sprite
	anim.play("score_up")

func update_score() -> void:
	SFXPlayer.play(sfx_point_hit)
	portrait.texture = _player_info.character_info.action2_sprite
	update_display()

func animation_end() -> void:
	portrait.texture = _player_info.character_info.idle_sprite


func get_player_index() -> int:
	return _player_info.player_index
