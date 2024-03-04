extends Area2D

@onready var screen_size = get_viewport_rect().size

var speed: float
var direction: Vector2
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var damage = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 200 # Random speed between 5 and 10 
	rotation_speed = randf_range(-1, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0
		
	position += direction * speed * delta
	rotation += rotation_speed * delta

func damage_asteroid(_damage):
	queue_free()


func _on_timer_timeout():
	queue_free()
