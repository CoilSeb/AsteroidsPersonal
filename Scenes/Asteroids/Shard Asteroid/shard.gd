extends Area2D

@onready var screen_size = get_viewport_rect().size
@onready var sprite_2d = $Sprite2D
@onready var animated_sprite_2d = $AnimatedSprite2D

var speed: float
var direction: Vector2
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var damage = 15
var health = 10
var max_health = 10
var num = 0

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

func damage_asteroid(damage):
	health -= damage
	if health <= 0:
		queue_free()


func _on_timer_timeout():
	animated_sprite_2d.show()
	animated_sprite_2d.play("default")
	await animated_sprite_2d.animation_finished
	queue_free()
