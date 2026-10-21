extends Node

@export var minigame: MinigameBase
@export var lap_count: int = 3
@export var _SFX_lap: AudioStream
@export var npc_holder: Node2D

var finished: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	minigame.players_spawned.connect(_on_players_spawned)
	
	var characters = CharacterRepository.get_all_characters()
	for child in npc_holder.get_children():
		if child is DriftNPC: 
			(child as DriftNPC).assign_character(characters[randi_range(0,characters.size()-1)])
	pass # Replace with function body.

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerDrift = player.get_node("%DriftPlayerMgr") as PlayerDrift
		p.max_lap_count = lap_count
		p.lap_complete.connect(_on_lap_complete)

func _on_lap_complete(player:int, lap: int) -> void:
	if finished: return
	if lap >= lap_count:
		finished = true
		minigame.end_game([player])
		
		for pl in minigame.players:
			var p:PlayerDrift = pl.get_node("%DriftPlayerMgr") as PlayerDrift
			p.on_game_end()
	SFXPlayer.play(_SFX_lap)
