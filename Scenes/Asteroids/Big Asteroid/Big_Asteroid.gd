extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Sprite2D/Crack1
@onready var crack_2 = $Sprite2D/Crack2
@onready var crack_3 = $Sprite2D/Crack3
@onready var crack_4 = $Sprite2D/Crack4

const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
var medium_asteroid_scene = preload("res://Scenes/Asteroids/Medium Asteroid/Medium_asteroid.tscn")
var exp_Scene = preload("res://Scenes/Experience/Experience.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 50
var health = 50
var damage = 50
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var weighted = false
var counted = false
var weight = 4
var dead = false


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	add_to_group("Big_Asteroid")
	rotation_speed = randf_range(-1, 1)


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
	speed = randf_range(75, 200)  # Random speed between 5 and 10


func destroy(money_bool):
	call_deferred("create_and_add_asteroids", money_bool)


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
	if health <= 0 && !dead:
		dead = true
		destroy(true)


func create_and_add_asteroids(money_bool):
	#call_deferred("make_exp")
	if money_bool:
		Global.update_money.emit(randi_range(11,15))
	
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/8-bit-fireball-81148.mp3")
	audio_player.volume_db = Global.sound_effects_volume - 7
	get_parent().add_child(audio_player)
	
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	# Instantate two small asteroids
	var medium_asteroid1 = medium_asteroid_scene.instantiate()
	var medium_asteroid2 = medium_asteroid_scene.instantiate()

	# Set their positions to the position of the medium asteroid
	medium_asteroid1.position = self.position
	medium_asteroid2.position = self.position
	
	if weighted:
		Global.enemy_weight -= weight
		medium_asteroid1.weighted = true
		medium_asteroid2.weighted = true

	# Add them as children of the medium asteroid's parent
	self.get_parent().add_child(medium_asteroid1)
	self.get_parent().add_child(medium_asteroid2)
	
	# Increase Score 
	Ui.increase_score(200)

	# Queue the medium asteroid for deletion
	self.queue_free()


func make_exp():
	var exp_shard = exp_Scene.instantiate()
	exp_shard.position = self.position
	self.get_parent().add_child(exp_shard)
