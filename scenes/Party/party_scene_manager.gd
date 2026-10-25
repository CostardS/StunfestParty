extends Node
class_name PartySceneManager

@export var music: AudioStream
@export var score_panel_mgr: ScorePanel
@export var roulette: Roulette
@export var minigame_holder: Node

@export var party_ui: Control
@export var minigame_ui: SharedMinigameUI;
@export var anim: AnimationPlayer

@export var winner_name_label: Label
@export var winner_texture: TextureRect

@export var music_win:AudioStream


var winner_character: CharacterInfo = null
var _current_minigame: MinigameBase
var _current_winners: Array[int] = []
var _finish_animation_pending: bool = false
var _end_after_finish: bool = false
var can_restart: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.reset_scores()
	score_panel_mgr.intro_ended.connect(_on_intro_end)
	score_panel_mgr.intermission_ended.connect(_on_intermission_end)
	roulette.roulette_ended.connect(_on_roulette_end)
	minigame_ui.start_animation_callback.connect(_on_start_animation_end)
	minigame_ui.finish_animation_callback.connect(_on_finish_animation_end)
	minigame_ui.end_banner_animation_callback.connect(_on_win_animation_end)
	MusicPlayer.play(music)
	score_panel_mgr.start_intro()

func _on_intro_end() -> void:
	_start_roulette()

func _start_roulette() -> void:
	roulette.start_roulette()

func _on_roulette_end(selected_game_info:MinigameInfo) -> void:
	_clean_game_holder()
	MusicPlayer.stop()
	SceneManager.scene_added.connect(_on_minigame_loaded)
	SceneManager.swap_scenes(selected_game_info.prefab.resource_path, minigame_holder)

func _on_minigame_loaded(scene: Node, _loading)-> void:
	SceneManager.scene_added.disconnect(_on_minigame_loaded)
	var minigame: MinigameBase = scene as MinigameBase
	if minigame != null:
		party_ui.visible = false
		minigame_ui.visible = true
		_current_minigame = minigame
		_current_minigame.game_finish_requested.connect(_on_game_finished)
		_current_minigame.game_ended.connect(_on_minigame_end)
		minigame_ui.assign_minigame(_current_minigame)
		_current_minigame.init_game()
		if minigame.auto_start :
			await get_tree().create_timer(0.5).timeout
			_initiate_game_start()
		else :
			minigame.game_start_request.connect(_initiate_game_start)

func _initiate_game_start()-> void :
	if _current_minigame != null :
		if !_current_minigame.auto_start : _current_minigame.game_start_request.disconnect(_initiate_game_start)
		minigame_ui.show_start(_current_minigame.start_countdown, _current_minigame.start_countdown_on_beat)

func _on_start_animation_end() -> void:
	if _current_minigame != null :
		_current_minigame.start_game()

func _on_finish_animation_end() -> void:
	_finish_animation_pending = false
	if _end_after_finish:
		_show_minigame_end()
		

func _on_game_finished() -> void :
	_finish_animation_pending = true
	minigame_ui.show_finish()

func _on_minigame_end(winners: Array[int]) -> void:
	_current_winners = winners
	minigame_ui.assign_winners(winners);
	# assign winners to minigame ui here 
	if _finish_animation_pending : _end_after_finish = true
	else : _show_minigame_end()

func _show_minigame_end() -> void:
	_end_after_finish = false
	minigame_ui.show_game_end()

func _on_win_animation_end() -> void:
	SceneManager.scene_added.connect(_on_minigame_unloaded)
	SceneManager.swap_scenes("res://scenes/SceneManager/empty.tscn",minigame_holder, _current_minigame)

func _on_minigame_unloaded(_scene, _loading) -> void:
	SceneManager.scene_added.disconnect(_on_minigame_unloaded)
	party_ui.visible = true
	roulette.dismiss()
	minigame_ui.visible = false
	minigame_ui.disconnect_minigame()
	_current_minigame = null
	MusicPlayer.play(music)
	await get_tree().create_timer(0.5).timeout
	_start_intermission(_current_winners)

func _start_intermission(winners:Array[int]) -> void:
	
	score_panel_mgr.start_intermission(winners)

func _on_intermission_end(max_score_reached:bool) -> void:
	if max_score_reached:
		_start_party_end()
	else:
		_start_roulette()

func _start_party_end() -> void:
	anim.play("win")
	# Assigner le gagnant
	var winner: PlayerInfo = null
	for player in PlayerManager.get_players():
		if winner == null || player.global_party_score > winner.global_party_score: winner = player
	
	winner_character = winner.character_info
	winner_name_label.text = winner_character.character_name
	winner_name_label.self_modulate = winner.get_player_color()
	winner_texture.texture = winner_character.idle_sprite

	MusicPlayer.play(music_win)

	MusicPlayer.beats(0.5).connect(on_mid_beat)
	MusicPlayer.beat.connect(on_beat)
	MusicPlayer.beats(4,true,3).connect(on_fourth_beat)
	
	await get_tree().create_timer(1.5).timeout
	can_restart = true

func _clean_game_holder() -> void:
	for node in minigame_holder.get_children():
		node.queue_free()

var reset_time = 0

func _process(delta: float) -> void:
	if someone_wants_to_reset()  && reset_time >= 0: 
		reset_time += delta
	else : reset_time = 0
	if can_restart && someone_wants_to_start() || reset_time > 1.5:
		reset_time = -1
		#TODO SFX Lobby Start
		can_restart = false
		SceneManager.swap_scenes("res://scenes/Lobby/Lobby.tscn",null,self)

func someone_wants_to_start() -> bool:
	for player in PlayerManager.get_players():
		if MultiplayerInput.is_action_just_pressed(player.device_number, "start"):
			return true
	return false

func someone_wants_to_reset() -> bool:
	for player in PlayerManager.get_players():
		if MultiplayerInput.is_action_pressed(player.device_number, "select"):
			return true
	return false

	




func on_mid_beat(beat:int):
	if(beat % 2 == 0): return
	switch_pose(0)

func on_beat(beat:int):
	if(beat % 4 == 3): return
	switch_pose(1)
	
func on_fourth_beat(_beat:int):
	switch_pose(2)
	
func switch_pose(pose: int) -> void:
	if(!winner_character): return
	var tex:Texture2D = null
	match pose:
		0: tex = winner_character.idle_sprite
		1: tex = winner_character.action1_sprite
		2: tex = winner_character.action2_sprite
	winner_texture.texture = tex
