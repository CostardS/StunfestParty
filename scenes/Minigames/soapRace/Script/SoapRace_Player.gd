extends CharacterBody2D
class_name SoapRace_Player

@export var _hub:PlayerHub
@export var _sprite:Sprite2D
@export var crashSound:AudioStream
@export var hitSound:AudioStream
@export var animPlayer:AnimationPlayer

var start_player_speed:float = 75
var player_speed:float = 0
var player_acceleration:float = 50
var player_speed_inc:int = 20
var base_speed:float = 10

var previous_lateral_pos:float = 0
var lateral_delta:float =0
var pushed_force:float = 0
var force_multiplier:float =2
var recover:float = 10
var current_lateral_speed:float = 0

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

func get_hit(contact:SoapRace_Player, lateral_force:float) -> float:
	if current_lateral_speed * lateral_force <= 0:
		pushed_force = lateral_force * force_multiplier
	return sign(current_lateral_speed) * player_speed 

func _physics_process(delta: float) -> void:
	if not _hub._global_controls_enabled:
		return
	var is_accelerating:bool = _hub.btn1_hold and global_position.y < 900
	var movement:float = _hub.movement.x
	_hub.score = global_position.y
	
	current_lateral_speed = (movement * player_speed) + pushed_force

	if global_position.x > max_x and current_lateral_speed > 0:
		current_lateral_speed = 0
	if global_position.x < min_x and current_lateral_speed < 0:
		current_lateral_speed = 0

	var player_movement:Vector2 = Vector2(current_lateral_speed, int(is_accelerating) * player_acceleration) * delta

	var collision = move_and_collide(player_movement, false, 0.08, true)
	if collision:
		var obj = collision.get_collider()
		if obj is SoapRace_Player:
			if hitSound:
				SFXPlayer.play(hitSound, -10)
			var hit_back:float = (obj as SoapRace_Player).get_hit(self,sign(current_lateral_speed) * player_speed)
			get_hit(obj, hit_back)
		else:
			obj = collision.get_collider_shape()
			obj.free()
			global_position.y = max(global_position.y - 200, 10)
			player_speed = start_player_speed
			animPlayer.play('crash')
			if crashSound:
				SFXPlayer.play(crashSound, -10)

	if abs(pushed_force) > 0.1:
		pushed_force =  move_toward(pushed_force, 0, recover)

	if is_accelerating: 
		player_speed += player_speed_inc * delta
		
