extends Area2D
class_name DriftNPC

@export var _sprite: Sprite2D
@export var _anim: AnimationPlayer

var _character: CharacterInfo

var _car_count = 0
var _use_pose_2 = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)

func assign_character(character: CharacterInfo) -> void:
	_character = character
	_sprite.texture = _character.idle_sprite

func _on_body_entered(body: Node) -> void:
	if body is PlayerDrift :
		if _car_count == 0 : 
			_anim.play("hop")
			if _character != null:
				if _use_pose_2 : _sprite.texture = _character.action2_sprite
				else : _sprite.texture = _character.action1_sprite
			_use_pose_2 = !_use_pose_2
		_car_count = _car_count + 1


func _on_body_exit(body: Node) -> void:
	if body is PlayerDrift :
		_car_count = _car_count - 1
		if _car_count == 0:
			_anim.play("RESET")
			if _character != null: _sprite.texture = _character.idle_sprite
