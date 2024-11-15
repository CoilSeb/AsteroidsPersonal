extends Area2D

const EXPERIENCE = preload("res://Scenes/Experience/Experience.tscn")
@onready var Ui = get_parent().get_node("UI")
@onready var crack_1 = $Crack1
@onready var crack_2 = $Crack2
@onready var crack_3 = $Crack3
@onready var crack_4 = $Crack4

const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const EXPLOSION_AREA = preload("res://Scenes/Asteroids/Explosion/explosion_area.tscn")
var shard_scene = preload("res://Scenes/Asteroids/Shard Asteroid/shard.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 50
var health = 50
var damage = 50
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var first_spawn = false
var second_spawn = false
var third_spawn = false
var fourth_spawn = false
var weighted = false
var counted = false
var weight = 4
var dead = false


func _ready():
	#Global.asteroid_spawned.emit(self)
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	rotation_speed = randf_range(-1, 1)
	add_to_group("Shard_Asteroid")
	old_position = position


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
	speed = randf_range(75, 200)  # Random speed between 50 and 100


func destroy(money_bool):
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/8-bit-fireball-81148.mp3")
	audio_player.volume_db = Global.sound_effects_volume - 7
	get_parent().add_child(audio_player)
	
	if money_bool:
		Global.update_money.emit(randi_range(40,75))
		if Global.explosive_asteroids:
			var explosion = EXPLOSION_AREA.instantiate()
			explosion.damage = 20
			explosion.size = 3
			explosion.position = position
			get_parent().call_deferred("add_child", explosion)
	if weighted:
		Global.enemy_weight -= weight
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	Ui.increase_score(100) 
	call_deferred("create_shards", 8.0)
	queue_free()


func damage_asteroid(damage_taken):
	health -= damage_taken
	if health <= 40 && health > 30:
		$Sprite2D.hide()
		crack_1.show()
		if !first_spawn:
			call_deferred("create_shards", 3.0)
			first_spawn = true
	if health <= 30 && health > 20:
		crack_1.hide()
		crack_2.show()
		if !second_spawn:
			call_deferred("create_shards", 3.0)
			second_spawn = true
	if health <= 20 && health > 10:
		crack_2.hide()
		crack_3.show()
		if !third_spawn:
			call_deferred("create_shards", 1.0)
			third_spawn = true
	if health <= 10 && health > 0:
		crack_3.hide()
		crack_4.show()
		if !fourth_spawn:
			call_deferred("create_shards", 2.0)
			fourth_spawn = true
	if health <= 0 && !dead:
		dead = true
		#for i: int in range(2):
			#call_deferred("make_exp")
		destroy(true)


func create_shards(num: float):
	var i = int(rotation) % 10;
	for k in range(num):
		var shard = shard_scene.instantiate()
		shard.position = position
		var angle = i * PI
		shard.direction = Vector2(cos(angle), sin(angle))
		i += 2.0/num
		get_parent().add_child(shard)


func make_exp():
	var exp_shard = EXPERIENCE.instantiate()
	exp_shard.position = self.position + Vector2(randi_range(-10,10), randi_range(-10,10))
	get_parent().add_child(exp_shard)
