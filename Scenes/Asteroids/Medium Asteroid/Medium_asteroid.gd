extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Sprite2D/Crack1
@onready var crack_2 = $Sprite2D/Crack2

var small_asteroid_scene = preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 30
var health = 30


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	add_to_group("Medium_Asteroid")


func _process(delta):
	# Screen Wrap
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0
	
	# Moving 
	position += direction * speed * delta


func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(75, 200)  # Random speed between 5 and 10


func destroy():
	# Instantiate two small asteroids using call_deferred
	call_deferred("create_and_add_asteroids")	


func damage_asteroid(damage):
	if Global.weapon == "Laser":
		health -= (max_health * 0.01)
	health -= damage
	if health <= 20:
		crack_1.visible = true
	if health <= 10:
		crack_2.visible = true 
	if health <= 0:
		destroy()


func create_and_add_asteroids():
	# Instantate two small asteroids
	var small_asteroid1 = small_asteroid_scene.instantiate()
	var small_asteroid2 = small_asteroid_scene.instantiate()

	# Set their positions to the position of the medium asteroid
	small_asteroid1.position = self.position
	small_asteroid2.position = self.position

	# Add them as children of the medium asteroid's parent
	self.get_parent().add_child(small_asteroid1)
	self.get_parent().add_child(small_asteroid2)
	
	# Increase Score 
	Ui.increase_score(200)

	# Queue the medium asteroid for deletion
	self.queue_free()
