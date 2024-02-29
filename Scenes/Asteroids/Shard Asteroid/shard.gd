extends Area2D

@onready var screen_size = get_viewport_rect().size

var speed: float
var direction: Vector2
var old_position: Vector2
var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = randf_range(75, 200) # Random speed between 5 and 10 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta
