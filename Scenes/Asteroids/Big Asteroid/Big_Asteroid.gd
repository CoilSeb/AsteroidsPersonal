extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Sprite2D/Crack1
@onready var crack_2 = $Sprite2D/Crack2
@onready var crack_3 = $Sprite2D/Crack3
@onready var crack_4 = $Sprite2D/Crack4

var shard_scene = preload("res://Scenes/Asteroids/Shard Asteroid/shard.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 50
var health = 50
var damage = 50
var old_position: Vector2
var velocity: Vector2


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	add_to_group("Shard_Asteroid")
	old_position = position


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
	
	var new_position = self.position 
	velocity = (new_position - old_position) / delta
	old_position = position
	


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
	var i = 0;
	for k in range(8):
		var shard = shard_scene.instantiate()
		shard.position = position
		var angle = i * PI
		shard.direction = Vector2(cos(angle), sin(angle))
		i += 0.25
		get_parent().add_child(shard)
	
	# Increase Score 
	Ui.increase_score(100) 

	# Queue the big asteroid for deletion
	queue_free()
