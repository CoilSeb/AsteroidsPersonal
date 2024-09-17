extends Area2D

@onready var Ui = get_parent().get_node("UI")
@onready var spawn_timer = $Spawn_Timer

const EXPERIENCE = preload("res://Scenes/Experience/Experience.tscn")
const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const BIG_ASTEROID = preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
const SMALL_ASTEROID = preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 750
var health = 750
var damage = 100
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var weighted = false
var counted = false
var weight = 40
var i = int(rotation) % 10;
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.moon_guy_health.emit(0)
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	rotation_speed = randf_range(-0.05, 0.05)
	call_deferred("create_surrounding_asteroids",25, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
# Screen Wrap
	if position.x < -5000:
		position.x = screen_size.x + 5000
	if position.x > screen_size.x + 5000:
		position.x = -5000
	if position.y < -5000:
		position.y = screen_size.y + 5000
	if position.y > screen_size.y + 5000:
		position.y = -5000
	
	# Moving 
	position += direction * speed * delta
	rotation += rotation_speed * delta
	
	var new_position = self.position 
	velocity = (new_position - old_position) / delta
	old_position = position
		
	if spawn_timer.time_left == 0:
		if Global.moon_guy_asteroid_count < 25:
			create_surrounding_asteroids(1, false)
			spawn_timer.start()


func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(50, 100)  # Random speed between 5 and 10


func destroy(money_bool):
	call_deferred("create_and_add_asteroids", money_bool)


func damage_asteroid(damage_taken):
	health -= float(damage_taken)
	Global.moon_guy_health.emit(float(damage_taken))
	#if health <= 200:
		##crack_1.visible = true
		#audio_stream_player_2d.play()
	#if health <= 30:
		##crack_2.visible = true
		#audio_stream_player_2d.play()
	#if health <= 20:
		##crack_3.visible = true
		#audio_stream_player_2d.play()
	#if health <= 10:
		##crack_4.visible = true 
		#audio_stream_player_2d.play()
	if health <= 0 && !dead:
		dead = true
		Global.moon_guy_dead.emit()
		Global.moon_guy_health.emit(750)
		destroy(true)


func create_and_add_asteroids(money_bool):
	#for i in range(16):
		#var exp_shard = EXPERIENCE.instantiate()
		#exp_shard.position = self.position + Vector2(randi_range(-20,20), randi_range(-20,20))
		#get_parent().add_child(exp_shard)
	if money_bool:
		Global.update_money.emit(randi_range(150,200))
	
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/8-bit-fireball-81148.mp3")
	audio_player.volume_db = Global.sound_effects_volume - 7
	get_parent().add_child(audio_player)
	
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	# Instantate two small asteroids
	for j in range(10):
		var big_asteroid1 = BIG_ASTEROID.instantiate()
		big_asteroid1.position = self.position
		big_asteroid1.weighted = true
		self.get_parent().add_child(big_asteroid1)
	
	if weighted:
		Global.enemy_weight -= weight

	# Increase Score 
	Ui.increase_score(200)

	# Queue the medium asteroid for deletion
	self.queue_free()


func create_surrounding_asteroids(num: float, initial: bool):
	for k in range(num):
		var small_asteroid = SMALL_ASTEROID.instantiate()
		Global.moon_guy_asteroid_count += 1
		small_asteroid.boss = true
		small_asteroid.speed = speed
		small_asteroid.direction = direction
		if initial:
			small_asteroid.initial = true
		var angle = i * PI
		#small_asteroid.direction = Vector2(cos(angle), sin(angle))
		small_asteroid.position = position + Vector2(cos(angle), sin(angle)) * 400
		i += 2.0/25
		get_parent().add_child(small_asteroid)
