extends Node

signal play_ended(winners:Array[int])
@export var minigame: MinigameBase
@export var target_score: int

@export var _SFX_whistle: AudioStream
@export var _dance_music: AudioStream
@export var _dance_positions: Array[Node2D]
@export var _animator: AnimationPlayer
@export var mash_label: Label
var training_phase = true

var current_ends: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	# await get_tree().create_timer(2.5).timeout
	# minigame.request_game_start()

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerMasher = player.get_node("%MasherPlayerMgr") as PlayerMasher
		p.replay_end.connect(on_replay_end)
		p.target_score = target_score
		p.initialize_display()
		play_ended.connect(p.on_play_phase_end)

func _on_game_timeout() -> void:
	play_ended.emit(minigame.get_winners_from_score(true))
	mash_label.text = ""
	SFXPlayer.play(_SFX_whistle);
	MusicPlayer.stop()
	await get_tree().create_timer(.5).timeout
	_animator.play("phase_transition")
	# Animation du fond et déplacement des joueurs vers leur position 
		
func move_players() -> void :
	for player in minigame.players:
		var p:PlayerMasher = player.get_node("%MasherPlayerMgr") as PlayerMasher
		p.move_to_dance_spot(_dance_positions[player.get_player_index()].global_position)

func dance_music_start() -> void:
	MusicPlayer.play(_dance_music)

func dance_player_reveal(index: int) -> void:
	if index >= minigame.players.size(): return
	(minigame.players[index].get_node("%MasherPlayerMgr") as PlayerMasher).dance_reveal_1()

func dance_player_reaveal_2(index: int) -> void:
	if index >= minigame.players.size(): return
	(minigame.players[index].get_node("%MasherPlayerMgr") as PlayerMasher).dance_reveal_2()

func dance_player_jump() -> void:
	for player in minigame.players:
		(player.get_node("%MasherPlayerMgr") as PlayerMasher).dance_jump()

func dance_player_bind_rhythm() -> void:
	MusicPlayer.beat.connect(on_beat)
	for player in minigame.players:
		(player.get_node("%MasherPlayerMgr") as PlayerMasher).bind_rhythm()
	# minigame.show_finish_and_lock()
	# await get_tree().create_timer(3).timeout
	#minigame.end_game()

func on_beat(beat:int):
	_animator.play('DancePulse')

func on_replay_end():
	current_ends += 1
	if current_ends >= minigame.players.size() :
		await get_tree().create_timer(1).timeout
		minigame.end_game(minigame.get_winners_from_score(true))
