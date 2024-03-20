extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const BIG_ASTEROID = preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
const SMALL_ASTEROID = preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 250
var health = 250
var damage = 250
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var weighted = false
var counted = false
var weight = 16


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	rotation_speed = randf_range(-0.05, 0.05)
	call_deferred("create_surrounding_asteroids",25)


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	rotation += rotation_speed * delta
	
	var new_position = self.position 
	velocity = (new_position - old_position) / delta
	old_position = position
	
	if weighted && !counted:
		Global.enemy_weight += weight
		counted = true


func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(50, 100)  # Random speed between 5 and 10


func destroy():
	call_deferred("create_and_add_asteroids")


func damage_asteroid(damage):
	health -= damage
	if health <= 40:
		#crack_1.visible = true
		audio_stream_player_2d.play()
	if health <= 30:
		#crack_2.visible = true
		audio_stream_player_2d.play()
	if health <= 20:
		#crack_3.visible = true
		audio_stream_player_2d.play()
	if health <= 10:
		#crack_4.visible = true 
		audio_stream_player_2d.play()
	if health <= 0:
		destroy()


func create_and_add_asteroids():
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/8-bit-fireball-81148.mp3")
	audio_player.volume_db -= 5
	get_parent().add_child(audio_player)
	
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	# Instantate two small asteroids
	var big_asteroid1 = BIG_ASTEROID.instantiate()
	var big_asteroid2 = BIG_ASTEROID.instantiate()
	var big_asteroid3 = BIG_ASTEROID.instantiate()
	var big_asteroid4 = BIG_ASTEROID.instantiate()

	# Set their positions to the position of the big asteroid
	big_asteroid1.position = self.position
	big_asteroid2.position = self.position
	big_asteroid3.position = self.position
	big_asteroid4.position = self.position
	
	if weighted:
		Global.enemy_weight -= weight
		big_asteroid1.weighted = true
		big_asteroid2.weighted = true
		big_asteroid3.weighted = true
		big_asteroid4.weighted = true

	# Add them as children of the big asteroid's parent
	self.get_parent().add_child(big_asteroid1)
	self.get_parent().add_child(big_asteroid2)
	self.get_parent().add_child(big_asteroid3)
	self.get_parent().add_child(big_asteroid4)
	
	# Increase Score 
	Ui.increase_score(200)

	# Queue the medium asteroid for deletion
	self.queue_free()


func create_surrounding_asteroids(num: float):
	var i = int(rotation) % 10;
	for k in range(num):
		var small_asteroid = SMALL_ASTEROID.instantiate()
		small_asteroid.boss = true
		small_asteroid.speed = speed
		small_asteroid.direction = direction
		var angle = i * PI
		#small_asteroid.direction = Vector2(cos(angle), sin(angle))
		small_asteroid.position = position + Vector2(cos(angle), sin(angle)) * 400
		i += 2.0/num
		get_parent().add_child(small_asteroid)
