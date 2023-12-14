extends CharacterBody2D

@onready var GameScene = get_parent()
@onready var Ui = get_parent().get_node("UI")
var bulletScene = preload("res://Scenes/Bullets/Bullet.tscn")
var screen_size
var thrust = 50 # The force applied for thrust
var maxSpeed = 10
var rotateSpeed = 5
var slowDown = 1
var shootTimer = null
var immunity_timer = null
var d
var using_mouse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("GameScene: ", GameScene)
	#print("UI: ", Ui)
	screen_size = get_viewport_rect().size
	shootTimer = Timer.new()
	add_child(shootTimer)
	immunity_timer = Timer.new()
	add_child(immunity_timer)
	shootTimer.set_one_shot(true)
	immunity_timer.set_one_shot(true)
	immunity_timer.start(2)
	Ui.increase_score(0)
	Ui.update_health(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
		#rotation = get_angle_to(get_global_mouse_position())
	if Input.is_action_pressed("move_forward") || Input.is_action_pressed("M2"):
		velocity += ((Vector2(0, -10) * thrust * delta).rotated(rotation))
		velocity.limit_length(maxSpeed)
	else:
		# Slow Down
		velocity = lerp(velocity, Vector2.ZERO, slowDown * delta)
		# Stop
		if velocity.y >= -0.5 && velocity.y <= 0.5:
			velocity.y = 0
			
	move_and_collide(velocity * delta)
		
		
	# Shooting
	if (Input.is_action_pressed("shoot") || Input.is_action_pressed("M1")) && shootTimer.time_left == 0:  # Use action_just_pressed to prevent multiple bullets on a single press
		var bulletInstance = bulletScene.instantiate()  # Create a new instance of the Bullet scene
		get_parent().add_child(bulletInstance)  # Add it to the player node or a designated parent node for bullets
		bulletInstance.global_position = global_position  # Set the bullet's position
		bulletInstance.direction = Vector2.UP.rotated(rotation)  # Set the bullet's direction
		shootTimer.start(0.35)
		
	if Global.health <= 0:
		destroy()
		GameScene.player = true
		
	d = delta
	#print(d * 0.4)


func _on_area_2d_area_entered(area):
	if area.is_in_group("Big_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-50)
		area.damage_asteroid(Global.collision_damage)
		#call_deferred("destroy")
		#immunity_timer.start(1)
	if area.is_in_group("Medium_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-25)
		area.damage_asteroid(Global.collision_damage)
	if area.is_in_group("Small_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-10)
		area.damage_asteroid(Global.collision_damage)
	#if area.is_in_group("Exp"):   
		#area.following = true
	if area.is_in_group("Destroy_Ring"):
		Ui.update_exp(10)
		#print(Global.experience)
		area.get_parent().destroy()


func destroy():
	queue_free()
	GameScene.player = false
