extends RigidBody2D
class_name PlayerDrift

@export var _hub: PlayerHub
@export var _display: Node2D
@export var _sprite: Sprite2D
@export var _lap_label: Label
@export var _drift_particle: CPUParticles2D
@export var car_regions: Array[Rect2]

@export var _acceleration_max:float
@export var _acceleration_increment:float
@export var _acceleration_on_collision:float
@export var _speed_collision_mult_factor:float
@export var _deceleration_factor:float
@export var _move_speed_cap:float
@export var _rotate_speed: float

@export var _audio_drift: AudioStreamPlayer2D
@export var _audio_engine: AudioStreamPlayer2D
@export var _SFX_bonk: AudioStream
@export var _SFX_hit: AudioStream

signal lap_complete(player_index:int, max_current_lap: int)

var max_lap_count: int = 3
var _current_lap: int
var _max_current_lap: int

var _last_checkpoint: DriftCheckpoint

var _current_acceleration: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_hub.debug_init.connect(initialize_display)
	initialize_display()
	
func initialize_display() -> void:
	_sprite.self_modulate =_hub.get_player_color()
	_lap_label.self_modulate =_hub.get_player_color()
	_lap_label.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var speed_cap_multiplier = 1
	var drifting = linear_velocity.length_squared() > _move_speed_cap * _move_speed_cap * .64 && linear_velocity.normalized().dot(transform.x) < 0.4
	if drifting: speed_cap_multiplier = 1.2
	if _hub.btn1_hold:
		_current_acceleration = min( _acceleration_max * speed_cap_multiplier, _current_acceleration + _acceleration_increment * delta);
	else :
		_current_acceleration = max( 0, _current_acceleration - _acceleration_increment * delta);
	
	_audio_engine.pitch_scale = 1 + linear_velocity.length() * 2 / _move_speed_cap

func _physics_process(delta: float) -> void:
	var speed_cap_multiplier = 1
	var drifting = linear_velocity.length_squared() > _move_speed_cap * _move_speed_cap * .64 && linear_velocity.normalized().dot(transform.x) < 0.4
	if drifting: speed_cap_multiplier = 1.2
	if _hub.movement.abs().x > .1:
		angular_velocity = _rotate_speed * _hub.movement.x;
	else :
		angular_velocity = 0

	if _hub.btn1_hold:
		linear_velocity = linear_velocity + transform.x * delta * _current_acceleration;
		if linear_velocity.length_squared() > _move_speed_cap * _move_speed_cap * speed_cap_multiplier * speed_cap_multiplier: linear_velocity = linear_velocity.normalized() * _move_speed_cap * speed_cap_multiplier;
	else:
		linear_velocity = linear_velocity - linear_velocity * delta * _deceleration_factor;
		if linear_velocity.length() < .05 : linear_velocity = Vector2.ZERO;
	_drift_particle.emitting = drifting
	if drifting && !_audio_drift.playing: _audio_drift.play()
	if !drifting && _audio_drift.playing: _audio_drift.stop()


	_update_car_sprite()
	_display.global_rotation = 0;


func _update_car_sprite():
	var offset: int = round((rotation_degrees + 180) * 32 / 360)
	_sprite.region_rect = car_regions[ (24 + offset) % 32]
	

func _on_body_entered(body: Node)-> void:
	if body.get_meta("is_world", false):
		SFXPlayer.play(_SFX_bonk)
		if _current_acceleration > _acceleration_on_collision: _current_acceleration = _acceleration_on_collision
		linear_velocity = linear_velocity * _speed_collision_mult_factor
	else:
		SFXPlayer.play(_SFX_hit)

func checkpoint_entered(check: DriftCheckpoint) -> void :
	if _last_checkpoint != null:
		if check.starting_line && _last_checkpoint.last_checkpoint:
			_current_lap += 1;
			var showlap = false
			if _current_lap > _max_current_lap:
				lap_complete.emit(_hub.get_player_index(), _max_current_lap)
				showlap = true
			_max_current_lap = max(_max_current_lap, _current_lap);
			if showlap : show_lap_count()
		elif check.last_checkpoint && _last_checkpoint.starting_line:
			_current_lap = _current_lap - 1;
	_last_checkpoint = check;

func show_lap_count() -> void:
	_lap_label.text = str(min(_max_current_lap, max_lap_count)) + "/" + str(max_lap_count)
	if _max_current_lap > max_lap_count: _lap_label.text = "FINISH !";
	await get_tree().create_timer(2.5).timeout
	_lap_label.text = ""

func on_game_end() -> void:
	var fade_tween = create_tween().bind_node(_audio_engine)
	fade_tween.tween_property(_audio_engine, "volume_db", -80, 1.5)
