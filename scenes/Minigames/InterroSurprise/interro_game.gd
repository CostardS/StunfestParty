extends Node

@export var _minigame: MinigameBase
@export var _equation_bounds: Vector2i
@export var _equation_error_bounds : Vector2i
@export var _equation_text : Label

@export var _miss_ghost_image : Sprite2D
@export var _miss_ghost_sprites : Array[Texture2D]
@export var _miss_ghost_pulse: BeatPulse2D
@export var _ruler : Node2D
@export var _ruler_origin : Node2D
@export var _board : Node2D
@export var _max_points : int
@export var _ruler_destination_offset : Vector2

@export var _SFX_slam: AudioStream
@export var _SFX_pass: AudioStream
@export var _SFX_fail: AudioStream
@export var _SFX_punch: AudioStream
@export var _SFX_btn_ok: AudioStream
@export var _SFX_btn_ko: AudioStream

var _is_equation_good: bool
var _current_equation: String
var _waiting_for_answer: bool
var _initial_ruler_position: Vector2

func _ready() -> void:
	randomize()
	_minigame.players_spawned.connect(_on_players_spawned)
	_miss_ghost_image.texture = _miss_ghost_sprites[3]
	_initial_ruler_position = _ruler.global_position
	MusicPlayer.beat.connect(_equation_on_beat)
	_update_display()

func _equation_on_beat(beat:int) -> void :
	if _waiting_for_answer or !_minigame._minigame_running or beat % 2 == 0: return
	SFXPlayer.play(_SFX_slam)
	shake_board()
	_waiting_for_answer = true
	_miss_ghost_image.texture = _miss_ghost_sprites[0]
	_miss_ghost_pulse.enabled = false
	_generate_equation()
	_update_display()
	_enable_controls(true)
	

func _on_players_spawned() -> void:
	for player in _minigame.players:
		var p:PlayerInterro = player.get_node("%InterroPlayerMgr") as PlayerInterro
		p.answer_question.connect(_on_player_answered)
		player.controls_enabled = false

func _on_player_answered(player:PlayerInterro, answer:bool) :
	_enable_controls(false)

	if answer: SFXPlayer.play(_SFX_btn_ok) 
	else: SFXPlayer.play(_SFX_btn_ko)

	await get_tree().create_timer(.5).timeout

	if answer == _is_equation_good:
		_miss_ghost_image.texture = _miss_ghost_sprites[1]
		SFXPlayer.play(_SFX_pass)
		player.score()
	else:
		_miss_ghost_image.texture = _miss_ghost_sprites[2]
		SFXPlayer.play(_SFX_fail)
		_ruler.global_position = _ruler_origin.global_position
		var tween = get_tree().create_tween()
		tween.tween_property(_ruler, "global_position", player.root_node.global_position + _ruler_destination_offset, .25)
		tween.tween_callback(
			func () -> void:
				SFXPlayer.play(_SFX_punch)
				player.stun(_minigame.players.size() - 1, 1)
				_ruler.global_position = _initial_ruler_position
		)
	await get_tree().create_timer(.75).timeout
	_miss_ghost_image.texture = _miss_ghost_sprites[3]
	_current_equation = ""
	if player.hub.score >= _max_points:
		_current_equation = "Bravo!"
		_minigame.end_game([player.hub.get_player_index()])
		_update_display()
	else :
		_reset_players()
		if _check_all_stun():
			_miss_ghost_image.texture = _miss_ghost_sprites[2]
			_current_equation = "NUL !!!"
			_minigame.end_game([])
			_update_display()
		else:
			_miss_ghost_pulse.enabled = true
			_update_display()
			await get_tree().create_timer(.25).timeout
			_waiting_for_answer = false


func _check_all_stun() -> bool :
	var all_stun = true
	for player in _minigame.players:
		var p:PlayerInterro = player.get_node("%InterroPlayerMgr") as PlayerInterro
		if p.stun_counter <= 0 && p.hp > 0: all_stun = false
	return all_stun

func _update_display() -> void:
	_equation_text.text = _current_equation

func _enable_controls(enabled:bool) -> void :
	for player in _minigame.players:
		player.controls_enabled = enabled
		if !enabled: (player.get_node("%InterroPlayerMgr") as PlayerInterro).dim_player()

func _reset_players() -> void:
	for player in _minigame.players:
		(player.get_node("%InterroPlayerMgr") as PlayerInterro).reset_player();

func _generate_equation() -> void:
	var val1:int = randi_range(_equation_bounds.x, _equation_bounds.y);
	var val2:int = randi_range(_equation_bounds.x, _equation_bounds.y + 1);
	var result:int = 0;
	var isAdd:bool = randi_range(0, 1) == 0;
	_is_equation_good = randi_range(0, 1) == 0;
	_current_equation = "";
	if isAdd:
		result = val1 + val2;
		_current_equation = str(val1) + "+" + str(val2);
	else :
		var max_v:int = max(val1, val2);
		var min_v:int = min(val1, val2);
		result = max_v - min_v;
		_current_equation = str(max_v) + "-" + str(min_v);
	
	if !_is_equation_good:
		var offset:int = randi_range(_equation_error_bounds.x, _equation_error_bounds.y) * (-1 if randi_range(0, 1) == 0 else 1)
		if result + offset < 0: offset = -offset
		result += offset; 

	_current_equation += "=" + str(result);

func shake_board() -> void:
	var origin = _board.global_position
	var tween = get_tree().create_tween()
	for i in 20:
		tween.tween_property(_board, "global_position", origin + Vector2(randf(), randf()) * 20, 0.005)
	tween.tween_property(_board, "global_position", origin, 0.005)