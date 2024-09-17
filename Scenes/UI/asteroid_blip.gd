extends Node2D

@onready var sprite_2d = $Sprite2D

var asteroid

# Called when the node enters the scene tree for the first time.
func _ready():
	if asteroid.is_in_group("Shard Asteroid"):
		sprite_2d.texture = preload("res://Sprites/Asteroids/New Piskel-1.png (1).png")
		self.scale = Vector2(0.5, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if asteroid == null:
		queue_free()
	else:
		position = asteroid.position / 50 + Vector2(100, 100)
