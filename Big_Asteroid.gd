extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Sprite2D/Crack1
@onready var crack_2 = $Sprite2D/Crack2
@onready var crack_3 = $Sprite2D/Crack3
@onready var crack_4 = $Sprite2D/Crack4

var medium_asteroid_scene = preload("res://Medium_asteroid.tscn")
var screen_size
var speed: float
var direction: Vector2
var health = 50


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	add_to_group("Big_Asteroid")

func _process(delta):
	# Screen Wrap
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0

	if position.y < 0:
		position.y = screen_size.y
	elif position.y > screen_size.y:
		position.y = 0
	
	# Moving 
	position += direction * speed * delta

func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(75, 200)  # Random speed between 50 and 100

func destroy():
	# Instantiate two medium asteroids using call_deferred
	call_deferred("create_and_add_asteroids")

func damage_asteroid(damage):
	health -= damage
	if health <= 40:
		crack_1.visible = true
	if health <= 30:
		crack_2.visible = true
	if health <= 20:
		crack_3.visible = true
	if health <= 10:
		crack_4.visible = true 
	if health <= 0:
		destroy()

func create_and_add_asteroids():
	var medium_asteroid1 = medium_asteroid_scene.instantiate()
	var medium_asteroid2 = medium_asteroid_scene.instantiate()

	# Set their positions to the position of the big asteroid
	medium_asteroid1.position = position
	medium_asteroid2.position = position

	# Add them as children of the big asteroid's parent
	get_parent().add_child(medium_asteroid1)
	get_parent().add_child(medium_asteroid2)
	
	# Increase Score 
	Ui.increase_score(100) 

	# Queue the big asteroid for deletion
	queue_free()
