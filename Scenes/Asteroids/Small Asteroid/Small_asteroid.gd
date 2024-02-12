extends Area2D

@onready var Ui = get_parent().get_node("UI")

var exp_Scene = preload("res://Scenes/Experience/Experience.tscn")
var screen_size
var speed: float
var direction: Vector2
var max_health = 10
var health = 10
var damage = 12.5


func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction_and_speed()
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


func set_random_direction_and_speed():
	var angle = randf_range(0, 2 * PI)  # Random angle in radians
	direction = Vector2(cos(angle), sin(angle))  # Convert angle to direction vector
	speed = randf_range(75, 200) # Random speed between 5 and 10 


func destroy():
	Ui.increase_score(300)
	self.queue_free()


func make_exp():
	var exp_shard = exp_Scene.instantiate()
	exp_shard.position = self.position
	self.get_parent().add_child(exp_shard)


func damage_asteroid(damage):
	if Global.weapon == "Laser":
		health -= (max_health * 0.01)
	health -= damage
	if health <= 0:
		call_deferred("make_exp")
		destroy()
