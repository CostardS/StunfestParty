extends CharacterBody2D
class_name SoapRace_Player

@export var _hub:PlayerHub
@export var _sprite:Sprite2D
@export var _car_sprite:Sprite2D
@export var crashSound:AudioStream
@export var hitSound:AudioStream
@export var animPlayer:AnimationPlayer

# starting lateral speed of the player
var start_player_speed:float = 100
# current lateral speed of the player
var player_speed:float = 0
# added lateral speed when accelerating
var player_speed_inc:float = 0.4
# forward speed of the player
var player_acceleration:float = 50

var previous_lateral_pos:float = 0
var lateral_delta:float =0
var pushed_force:float = 0
var force_multiplier:float =2
var recover:float = 10
var current_lateral_speed:float = 0
@export var crashing:bool = false

var min_x:int = 0
var max_x:int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_display()
	player_speed = start_player_speed
	_hub.score = 2.5


func initialize_display() -> void:
	_sprite.texture = _hub.get_character().action1_sprite
	animPlayer.stop(true)

func get_hit( lateral_force:float) -> float:
	if current_lateral_speed * lateral_force <= 0:
		pushed_force = lateral_force * force_multiplier
	return sign(current_lateral_speed) * player_speed 

func _physics_process(delta: float) -> void:
	if not _hub._global_controls_enabled:
		return
	var is_accelerating:bool = _hub.btn1_hold and global_position.y < 900 # and !crashing
	var movement:float = _hub.movement.x
	# if crashing : movement = 0

	_hub.score = global_position.y
	player_speed = start_player_speed + global_position.y  * player_speed_inc

	current_lateral_speed = (movement * player_speed) + pushed_force

	if global_position.x > max_x and current_lateral_speed > 0:
		current_lateral_speed = 0
	if global_position.x < min_x and current_lateral_speed < 0:
		current_lateral_speed = 0

	var player_movement:Vector2 = Vector2(current_lateral_speed, int(is_accelerating) * player_acceleration) * delta

	var collision = move_and_collide(player_movement, false, 0.08, true)
	if !crashing :
		if current_lateral_speed > 0  : _car_sprite.rotation_degrees = -7.5
		elif current_lateral_speed < 0 : _car_sprite.rotation_degrees = 7.5
		else: _car_sprite.rotation_degrees = 0
	if collision:
		var obj = collision.get_collider()
		if obj is SoapRace_Player:
			if hitSound:
				SFXPlayer.play(hitSound, -10)
			var hit_back:float = (obj as SoapRace_Player).get_hit(sign(current_lateral_speed) * player_speed)
			get_hit(hit_back)
		else:
			obj = collision.get_collider_shape()
			obj.free()
			var target_position = Vector2(global_position.x, max(global_position.y - 200, 10))
			get_tree().create_tween().tween_property(self, "global_position", target_position, 0.6)
			animPlayer.play('crash')
			if crashSound:
				SFXPlayer.play(crashSound, -10)

	if abs(pushed_force) > 0.1:
		pushed_force =  move_toward(pushed_force, 0, recover)

		
