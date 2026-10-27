extends Node

@export var minigame: MinigameBase
@export var viewports: Array[SubViewport]
@export var portraits: Array[TextureRect]
@export var portraits_BG: Array[TextureRect]

var finished : bool  = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigame.players_spawned.connect(_on_players_spawned)

	

func _on_players_spawned() -> void:	
	var i = 0;
	for player in minigame.players:
		player.reparent(viewports[i])
		portraits_BG[i].modulate = player.get_player_color()
		for child in player.get_child(0).get_children():
			if child is MazePlayer:
				(child as MazePlayer).assign_portrait(portraits[i])
				(child as MazePlayer).init_rotation()
				(child as MazePlayer)._onDeath.connect(_onPlayerDeath)
		i += 1
			
func _onPlayerDeath() -> void:
	if finished:
		return
	var lastAlive = -1
	var countDead = 0
	for player in minigame.players:
		for child in player.get_child(0).get_children():
			if child is MazePlayer:
				if child.isDead:
					countDead += 1
				else:
					lastAlive = player.get_player_index()
	if countDead >= minigame.players.size() - 1:
		if lastAlive < 0: minigame.end_game([]) 
		else: minigame.end_game([lastAlive])
		finished = true
