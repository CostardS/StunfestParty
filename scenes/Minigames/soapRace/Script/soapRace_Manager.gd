extends CharacterBody2D

@export var minigame: MinigameBase
@export var playerMat: PackedScene

var world_speed:float = 250
var timer_end:bool = false
var players_mats:Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.game_initialized.connect(_on_game_initialized)
	minigame.players_spawned.connect(_on_player_spawned)
	minigame.game_timer_timeout.connect(_on_time_end)



func _on_game_initialized() -> void:
	var idx:int = 0
	var player_count:int = minigame.players.size()
	var min_x = 220  if player_count > 2 else 620
	var max_x = 980 if player_count == 1 else 1780 if player_count == 4 else 1380


	for player in minigame.players:
		var matInstance = playerMat.instantiate() as Node2D
		add_child(matInstance)
		matInstance.position = (minigame.player_spawns[idx] as Node2D).global_position
		players_mats.append(matInstance)
		var soap_player:SoapRace_Player = player.get_node("Player") as SoapRace_Player
		soap_player.min_x =min_x
		soap_player.max_x = max_x

		idx += 1


func _on_player_spawned() -> void:
	pass


func _on_time_end() -> void:
	minigame.show_finish_and_lock()
	for player in minigame.players:
		var soap_player:SoapRace_Player = player.get_node('Player') as SoapRace_Player
		soap_player.collision_mask = 0
	timer_end = true

func finish_game() -> void:
	var winner = minigame.get_winners_from_score(true)
	minigame.end_game(winner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if timer_end:
		var all_end:bool = true
		for player in minigame.players:
			var soap_player:SoapRace_Player = player.get_node('Player') as SoapRace_Player
			if soap_player.global_position.y < 1000:
				soap_player.move_and_collide(Vector2(0, (world_speed + soap_player.player_acceleration) * delta))
				all_end = false
		if all_end:
			finish_game()
			timer_end = false
	if not minigame._minigame_running:
		return
	move_and_collide(Vector2(0,-1) * delta * world_speed)
