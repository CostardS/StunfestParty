class_name CharacterInfo

var character_name: String = "" ## Nom du personnage
var idle_sprite: Texture2D ## Sprite d'idle
var action1_sprite: Texture2D ## Sprite 
var action2_sprite: Texture2D:
	get: return action2_sprites[randi_range(0, action2_sprites.size() - 1 )]
var action2_sprites: Array[Texture2D] = []
var portrait_offset: int

func _ready() -> void:
	randomize()

func is_dummy() -> bool:
	return character_name == ""

## permet de récupérer un sprite random en excluant d'autres sprite. Ex: récupérer un sprite différent du sprite courant
func get_random_sprite(exclusion :Array[Texture2D] = []) -> Texture2D :
	var texs: Array[Texture2D] = []
	texs.append(idle_sprite)
	texs.append(action1_sprite)
	texs.append_array(action2_sprites)
	for t in exclusion:
		var index = texs.find(t)
		if index >= 0: texs.remove_at(index)
	var r_index = randi_range(0,texs.size() - 1)
	return texs[r_index]
	
func build_select_offset():
	var columns:Vector2i = Vector2(idle_sprite.get_width() / 2 - 6, idle_sprite.get_width() / 2 + 6)
	var found: bool = false
	var img = idle_sprite.get_image()
	for y in idle_sprite.get_height():
		for x in range(columns.x, columns.y):
			if img.get_pixel(x, y).a > 0.5: 
				found = true
				portrait_offset = idle_sprite.get_height() / 4 - y + 5
				break
		if found: break

	pass