extends Node

@export var ball_max_sizes: Vector2
@export var minigame: MinigameBase
@export var drumroll: AudioStream
@export var drumroll_end: AudioStream

var ball_max_size: float
var show_score_counter: int
var display_finishes: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_timer_timeout.connect(_on_game_timeout)
	ball_max_size = randf_range(ball_max_sizes.x, ball_max_sizes.y)

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerPump = player.get_node("%PumpPlayerMgr") as PlayerPump
		p.ball_max_size = ball_max_size

func _on_game_timeout() -> void:
	minigame.show_finish_and_lock()
	for player in minigame.players:
		var p:PlayerPump = player.get_node("%PumpPlayerMgr") as PlayerPump
		p.score_display_finished.connect(_on_score_display_finished)
		p.on_game_end()
	await get_tree().create_timer(1).timeout
	MusicPlayer.play(drumroll)

func _on_score_display_finished() -> void:
	display_finishes += 1
	if display_finishes == minigame.players.size():
		MusicPlayer.play(drumroll_end)
		await get_tree().create_timer(.85).timeout
		minigame.end_game(minigame.get_winners_from_score(true))
		
