extends CharacterBody2D

@onready var GameScene = get_parent()
@onready var Ui = get_parent().get_node("UI")

var bulletScene = preload("res://Scenes/Bullets/Bullet.tscn")
var laserScene = preload("res://Scenes/Laser/laser.tscn")
var laserInstance
var screen_size
var rotateSpeed = 5
var thrust
var counter_thrust
var slowDown = 1
var shootTimer = null
var immunity_timer = null
var using_mouse = false
var weapon = Global.weapon
var laser_made = false


func _ready():
	screen_size = get_viewport_rect().size
	shootTimer = Timer.new()
	add_child(shootTimer)
	immunity_timer = Timer.new()
	add_child(immunity_timer)
	shootTimer.set_one_shot(true)
	immunity_timer.set_one_shot(true)
	immunity_timer.start(2)
	Ui.increase_score(0)


func _physics_process(delta):
	thrust = 500 + Global.move_speed
	counter_thrust = Global.counter_thrust
	Ui.update_health(Global.health_regen * delta)
	# Screen Wrap
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0
	
	# Movement
	if Input.is_action_pressed("rotate_left"):
		using_mouse = false
		rotation += -1 * rotateSpeed * delta
	if Input.is_action_pressed("rotate_right"):
		using_mouse = false
		rotation += 1 * rotateSpeed * delta
	if Input.is_action_pressed("M1") || Input.is_action_pressed("M2"):
		using_mouse = true
	if using_mouse == true:
		rotate(get_angle_to(get_global_mouse_position()) + (0.5 * PI))
	if Input.is_action_pressed("move_forward") || Input.is_action_pressed("M1"):
		velocity += ((Vector2(0, -1) * thrust * delta).rotated(rotation))
	elif Input.is_action_just_pressed("move_backward"):
		velocity += ((Vector2(0, 10) * counter_thrust * delta).rotated(rotation))
	else:
		velocity = lerp(velocity, Vector2.ZERO, slowDown * delta)
		if velocity.length() >= -10 && velocity.length() <= 10:
			velocity = Vector2.ZERO
			
		
	move_and_collide(velocity * delta)
		
	# Shooting
	if weapon == "Laser":
		if Input.is_action_pressed("shoot") || Input.is_action_pressed("M2"):
			if !laser_made:
				make_laser()
			laserInstance.global_position = global_position + Vector2(0, -15).rotated(rotation)
			laserInstance.direction = Vector2.UP.rotated(rotation) 
		if Input.is_action_just_released("shoot") || Input.is_action_just_released("M2"):
			laserInstance.queue_free()
			laser_made = false
	if weapon == "Gun":
		if (Input.is_action_pressed("shoot") || Input.is_action_pressed("M2")) && shootTimer.time_left == 0:  # Use action_just_pressed to prevent multiple bullets on a single press
			var bulletInstance = bulletScene.instantiate()  # Create a new instance of the Bullet scene
			get_parent().add_child(bulletInstance)  # Add it to the player node or a designated parent node for bullets
			bulletInstance.global_position = global_position  # Set the bullet's position
			bulletInstance.direction = Vector2.UP.rotated(rotation)  # Set the bullet's direction
			shootTimer.start(Global.attack_speed)
		
	if Global.health <= 0:
		destroy()
		GameScene.player = true


func make_laser():
	laserInstance = laserScene.instantiate()
	get_parent().add_child(laserInstance)
	laser_made = true


func _on_area_2d_area_entered(area):
	if area.is_in_group("Big_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-50)
		area.damage_asteroid(Global.collision_damage)
		if area.health > 0:
			velocity *= -0.5
		#call_deferred("destroy")
		#immunity_timer.start(1)
	if area.is_in_group("Medium_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-25)
		area.damage_asteroid(Global.collision_damage)
		if area.health > 0:
			velocity *= -0.5
	if area.is_in_group("Small_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-10)
		area.damage_asteroid(Global.collision_damage)
		if area.health > 0:
			velocity *= -0.5
	if area.is_in_group("Destroy_Ring"):
		Ui.update_exp(10)
		#print(Global.experience)
		area.get_parent().destroy()


func destroy():
	queue_free()
	GameScene.player = false
