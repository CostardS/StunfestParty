extends CharacterBody2D

@export var minigame: MinigameBase
@export var playerMat: PackedScene

var world_speed:float = 250
var is_playing:bool = false
var players_mats:Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.game_initialized.connect(_on_game_initialized)
	minigame.players_spawned.connect(_on_player_spawned)
	minigame.game_timer_timeout.connect((_on_time_end))



func _on_game_initialized() -> void:
	var idx:int = 0
	for player in minigame.players:
		var matInstance = playerMat.instantiate() as Node2D
		add_child(matInstance)
		matInstance.position = (minigame.player_spawns[idx] as Node2D).global_position
		players_mats.append(matInstance)
		idx += 1


func _on_player_spawned() -> void:
	pass


func _on_time_end() -> void:
	minigame.show_finish_and_lock()
	var winner = minigame.get_winners_from_score(true)
	minigame.end_game(winner)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not minigame._minigame_running:
		return
	move_and_collide(Vector2(0,-1) * delta * world_speed)
