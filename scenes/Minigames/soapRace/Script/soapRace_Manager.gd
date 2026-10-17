extends Node

@export var minigame: MinigameBase
@export var playerMat: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.game_initialized.connect(_on_game_initialized)
	minigame.players_spawned.connect(_on_player_spawned)


func _on_game_initialized() -> void:
	var idx:int = 0
	for player in minigame.players:
		var matInstance = playerMat.instantiate() as Node2D
		add_child(matInstance)
		matInstance.position = (minigame.player_spawns[idx] as Node2D).position + Vector2(25/2.,0)
		idx += 1

func _on_player_spawned() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
