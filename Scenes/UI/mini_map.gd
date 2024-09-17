extends Node2D

@onready var sprite_2d = $Sprite2D

const ASTEROID_BLIP = preload("res://Scenes/UI/asteroid_blip.tscn")
const MINI_MAP_CHUNK = preload("res://Scenes/UI/mini_map_chunk.tscn")

func _ready():
	Global.asteroid_spawned.connect(asteroid_blip)


func _process(delta):
	position = Global.player_pos / 50 + Vector2(100, 100)
	sprite_2d.rotation = Global.player_rot


func asteroid_blip(asteroid):
	var blip = ASTEROID_BLIP.instantiate()
	
	if asteroid.is_in_group("Big Asteroid"):
		blip.scale = Vector2(2, 2)
	elif asteroid.is_in_group("Medium Asteroid"):
		blip.scale = Vector2(1.5, 1.5)
	elif asteroid.is_in_group("Chest"):
		blip.scale = Vector2(3, 3)
		
	#blip.position = Vector2(100, 100)
	blip.asteroid = asteroid
	get_parent().add_child(blip)
