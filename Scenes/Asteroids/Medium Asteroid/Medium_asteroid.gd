extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Sprite2D/Crack1
@onready var crack_2 = $Sprite2D/Crack2

const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const EXPLOSION_AREA = preload("res://Scenes/Asteroids/Explosion/explosion_area.tscn")
var small_asteroid_scene = preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn")
var exp_Scene = preload("res://Scenes/Experience/Experience.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 30
var health = 30
var damage = 25
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var weighted = false
var counted = false
var weight = 2
var dead = false


func _ready():
	#Global.asteroid_spawned.emit(self)
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	add_to_group("Medium_Asteroid")
	rotation_speed = randf_range(-1, 1)


func _process(delta):
	# Screen Wrap
	if position.x < -5000:
		position.x = 5000
	if position.x > 5000:
		position.x = -5000
	if position.y < -5000:
		position.y = 5000
	if position.y > 5000:
		position.y = -5000
	
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


func damage_asteroid(damage_taken):
	health -= damage_taken
	if health <= 20:
		crack_1.visible = true
	if health <= 10:
		crack_2.visible = true 
	if health <= 0 && !dead:
		dead = true
		destroy(true)


func create_and_add_asteroids(money_bool):
	#call_deferred("make_exp")
	
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/8-bit-fireball-81148.mp3")
	audio_player.volume_db = Global.sound_effects_volume - 7
	get_parent().add_child(audio_player)
	
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	# Instantate two small asteroids
	var small_asteroid1 = small_asteroid_scene.instantiate()
	var small_asteroid2 = small_asteroid_scene.instantiate()

	# Set their positions to the position of the medium asteroid
	small_asteroid1.position = self.position
	small_asteroid2.position = self.position
	
	if weighted:
		Global.enemy_weight -= weight
		small_asteroid1.weighted = true
		small_asteroid2.weighted = true

	# Add them as children of the medium asteroid's parent
	self.get_parent().add_child(small_asteroid1)
	self.get_parent().add_child(small_asteroid2)
	
	if money_bool:
		Global.update_money.emit(randi_range(10,20))
		if Global.explosive_asteroids:
			var explosion = EXPLOSION_AREA.instantiate()
			explosion.damage = 10
			explosion.size = 2
			explosion.child1 = small_asteroid1
			explosion.child2 = small_asteroid2
			explosion.position = position
			get_parent().call_deferred("add_child", explosion)
	
	# Increase Score 
	Ui.increase_score(200)

	# Queue the medium asteroid for deletion
	self.queue_free()


func make_exp():
	var exp_shard = exp_Scene.instantiate()
	exp_shard.position = self.position
	self.get_parent().add_child(exp_shard)
