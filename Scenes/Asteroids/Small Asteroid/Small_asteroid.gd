extends Area2D

@onready var Ui = get_parent().get_node("UI")

const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
var exp_Scene = preload("res://Scenes/Experience/Experience.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 10
var health = 10
var damage = 12.5
var old_position: Vector2
var velocity: Vector2
var rotation_speed
var weighted = false
var counted = false
var weight = 1


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
	rotation_speed = randf_range(-1, 1)
	add_to_group("Small_Asteroid")


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
		print("+", weight)
		Global.enemy_weight += weight
		counted = true


func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(75, 200) # Random speed between 5 and 10 


func destroy():
	if weighted:
		Global.enemy_weight -= weight
		print("-", weight)
	var particles = ASTEROID_DEATH_PARTICLES.instantiate()
	particles.position = self.position
	get_parent().add_child(particles)
	particles.one_shot = true
	
	Ui.increase_score(300)
	self.queue_free()


func make_exp():
	var exp_shard = exp_Scene.instantiate()
	exp_shard.position = self.position
	self.get_parent().add_child(exp_shard)


func damage_asteroid(damage):
	health -= damage
	if health <= 0:
		call_deferred("make_exp")
		destroy()
