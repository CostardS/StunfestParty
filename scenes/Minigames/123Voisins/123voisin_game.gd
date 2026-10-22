extends Node

@export var minigame: MinigameBase
@export var _lights_on_timers: Vector2
@export var _eyes_speeds: Vector2
@export var _watcher_stay_intervals: Vector2
@export var _banana_laser_prefab: PackedScene
@export var _explosion_prefab: PackedScene
@export var _lights_out_images: TextureRect
@export var _banana_origin: Node2D
@export var _press_buttons_container: Control
@export var _all_watchers: Array[Texture2D]
@export var _watcher: TextureRect
@export var _all_posters: Array[Texture2D]
@export var _poster: TextureRect
@export var _all_pictures: Array[Texture2D]
@export var _pic_frame: TextureRect
@export var _ambiance: Node2D
@export var _anim: AnimationPlayer

@export var _target_score: int 
@export var _target_distance: float

@export var _SFX_laser: AudioStream
@export var _SFX_slam: AudioStream
#@export var _SFX_warning: AudioStream
@export var _SFX_knock: AudioStream
@export var _SFX_stairstep: AudioStream
@export var _SFX_dooropen: AudioStream

var _lights_on: bool = false
var _finished: bool = false
var _first_time: bool = true

var _timer: Timer = Timer.new()	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	minigame.players_spawned.connect(_on_players_spawned)
	minigame.game_started.connect(init_lights_on)
	minigame.game_ended.connect(_on_game_ended)
	add_child(_timer)
	_timer.timeout.connect(timer_elapsed)

func _on_players_spawned() -> void:
	for player in minigame.players:
		var p:PlayerVoisin = player.get_node("%PlayerMgr") as PlayerVoisin
		p.target_score = _target_score
		p.step_distance = _target_distance / _target_score
		p.root_node.position = Vector2(-_target_distance, 0)
		p.mistake.connect(shoot_player)
		player.controls_enabled = false
		p.initialize_player()

func timer_elapsed() -> void:
	if _lights_on : lights_out()
	else: init_lights_on()


func lights_out() -> void:
	_lights_on = false
	_ambiance.visible = true
	SFXPlayer.play(_SFX_slam)
	MusicPlayer.resume()
	_lights_out_images.visible = true
	_timer.start(randf_range(_lights_on_timers.x, _lights_on_timers.y))
	_press_buttons_container.visible = true
	update_light_status()
	update_panels()

func knock() -> void:
	SFXPlayer.play(_SFX_knock)
	SFXPlayer.play(_SFX_stairstep)

func init_lights_on() -> void:
	# SFXPlayer.play(_SFX_warning)
	# _anim.speed_scale = 1
	# _anim.play("warning")
	# await get_tree().create_timer(1).timeout
	# TODO Rajouter le warning
	_anim.speed_scale = 1.0 if _first_time else randf_range(_eyes_speeds.x, _eyes_speeds.y)
	_anim.play("voisin")

func lights_on() -> void:
	_press_buttons_container.visible = false
	MusicPlayer.pause()
	SFXPlayer.play(_SFX_dooropen)
	_lights_out_images.visible = false
	_ambiance.visible = false
	_lights_on = true
	_anim.speed_scale = 1
	update_light_status()
	_timer.start(_watcher_stay_intervals.y * .75 if _first_time else randf_range(_watcher_stay_intervals.x, _watcher_stay_intervals.y))
	_first_time = false

func shoot_player(player: PlayerVoisin) -> void:
	SFXPlayer.play(_SFX_laser)

	var banana = _banana_laser_prefab.instantiate() as Node2D
	_banana_origin.add_child(banana)
	banana.global_position = _banana_origin.global_position
	var tween = create_tween()
	tween.tween_property(banana, "global_position", player.root_node.global_position, .25).set_delay(.2)
	tween.tween_callback(
		func ():
			banana.queue_free()
			var explosion:Node2D = _explosion_prefab.instantiate() as Node2D
			_banana_origin.add_child(explosion)
			explosion.global_position = player.root_node.global_position
			player.explode()
	)
	_anim.play("laser_eyes")
	_timer.start(2)

func update_light_status() -> void:
	for player in minigame.players:
		(player.get_node("%PlayerMgr") as PlayerVoisin).change_lights(_lights_on)

func update_panels() -> void:
	_pic_frame.self_modulate = Color.WHITE
	_poster.self_modulate = Color.WHITE
	_pic_frame.texture = _all_pictures[randi_range(0,_all_pictures.size()-1)]
	_poster.texture = _all_posters[randi_range(0,_all_posters.size()-1)]
	_watcher.texture = _all_watchers[randi_range(0,_all_watchers.size()-1)]

func _on_game_ended(_winners: Array[int]) -> void:
	if !_finished && !_lights_on:
		_finished = true
		_timer.timeout.disconnect(timer_elapsed)
		_timer.stop()
		_anim.play("RESET")
		await get_tree().create_timer(1).timeout
		lights_on()
		_timer.timeout.disconnect(timer_elapsed)
		_timer.stop()
		_anim.play("RESET")
		_press_buttons_container.visible = false
		SFXPlayer.play(_SFX_dooropen)
		# minigame.end_game([player_index])
