extends CharacterBody2D

@onready var GameScene = get_parent()
@onready var Ui = get_parent().get_node("UI")
@onready var thrust_sprite_2d = $Thrust_Sprite2D
@onready var death_sound = $Death_Sound
@onready var weapon_sound = $Weapon_Sound

const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const PLAYER_DEATH = preload("res://Particles/player_death.tscn")
var bulletScene = preload("res://Scenes/Bullets/Bullet.tscn")
var laserScene = preload("res://Scenes/Laser/laser.tscn")
const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
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
var can_move = true
var burn_out_var = 200
var burn_out_time = burn_out_var
var cheat_code = ""
var rs_look = Vector2(0,0)
var deadzone = 1


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
	match Global.weapon:
		"Gun":
			pass
			#weapon_sound.stream = load("res://Audio/Sounds/086409_retro-gun-shot-81545.mp3")
			#weapon_sound.pitch_scale = 1
			#weapon_sound.volume_db -= 10
		"Laser":
			pass


func _physics_process(delta):
	thrust = Global.move_speed
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
	
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle() + (0.5 * PI)
	
	rotation -= (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")) * rotateSpeed * delta
	
	# Movement
	if Input.is_action_pressed("ui_left"):
		using_mouse = false
	if Input.is_action_pressed("ui_right"):
		using_mouse = false
	if Input.is_action_pressed("M1") || Input.is_action_pressed("M2"):
		using_mouse = true
	if using_mouse == true:
		rotate(get_angle_to(get_global_mouse_position()) + (0.5 * PI))
	if Input.is_action_pressed("move_forward") && can_move:
		velocity += ((Vector2(0, -1) * thrust * delta).rotated(rotation))
		thrust_sprite_2d.show()
	elif Input.is_action_just_pressed("move_backward"):
		velocity += ((Vector2(0, 10) * counter_thrust * delta).rotated(rotation))
	else:
		thrust_sprite_2d.hide()
		velocity = lerp(velocity, Vector2.ZERO, slowDown * delta)
		if velocity.length() >= -10 && velocity.length() <= 10:
			velocity = Vector2.ZERO
		
	move_and_collide(velocity * delta)
		
	if !Global.no_gun_all_collision:
		if Global.burn_out:
			$Burn_Out_Bar_BG.show()
			$Burn_Out_Bar_BG.max_value = burn_out_var
			$Burn_Out_Bar_BG.value = $Burn_Out_Bar_BG.max_value
			$Burn_Out_Bar.show()
			$Burn_Out_Bar.max_value = burn_out_var
			$Burn_Out_Bar.value = burn_out_time
		if !Global.can_shoot && burn_out_time < burn_out_var && Global.burn_out:
			$Burn_Out_Bar.tint_progress = Color(0.576, 0.576, 0.576)
			burn_out_time += 0.75
		if !Global.can_shoot && burn_out_time >= burn_out_var && Global.burn_out:
			$Burn_Out_Bar.tint_progress = Color(255, 255, 255)
			Global.can_shoot = true
		if Global.can_shoot && Global.burn_out && burn_out_time < burn_out_var:
			burn_out_time += 1.5
		
	# Shooting
	if Global.can_shoot:
		if weapon == "Laser":
			if Input.is_action_pressed("shoot") && !Input.is_action_pressed("move_forward"):
				if !Global.laser_made:
					make_laser()
				laserInstance.global_position = global_position + Vector2(0, -15).rotated(rotation)
				laserInstance.direction = Vector2.UP.rotated(rotation) 
			if Input.is_action_just_released("shoot") || Input.is_action_pressed("move_forward") || Input.is_action_pressed("move_backward"):
				destroy_laser()
				return
		if weapon == "Gun":
			if (Input.is_action_pressed("shoot") || Input.is_action_pressed("M2")) && shootTimer.time_left == 0:
				var bulletInstance = bulletScene.instantiate()
				get_parent().add_child(bulletInstance)
				bulletInstance.global_position = global_position
				bulletInstance.direction = Vector2.UP.rotated(rotation)
				weapon_sound.play()
				shootTimer.start(Global.attack_speed)
		#Burn Out
		if Global.burn_out && Input.is_action_pressed("shoot") && Global.can_shoot:
			burn_out_time -= 2.5
			if burn_out_time <= 0:
				destroy_laser()
				Global.can_shoot = false
			
	if Global.health <= 0:
		destroy()
		GameScene.player = true
		
	if Input.is_action_just_pressed("ui_cancel"):
		cheat_code = ""
	if Input.is_action_just_pressed("H"):
		cheat_code = cheat_code + "H"
	if Input.is_action_just_pressed("E"):
		cheat_code = cheat_code + "E"
	if Input.is_action_just_pressed("L"):
		cheat_code = cheat_code + "L"
	if Input.is_action_just_pressed("O"):
		cheat_code = cheat_code + "O"
	if Input.is_action_just_pressed("shoot"):
		cheat_code = cheat_code + " "
	if Input.is_action_just_pressed("move_forward"):
		cheat_code = cheat_code + "W"
	if Input.is_action_just_pressed("reroll"):
		cheat_code = cheat_code + "R"
	if Input.is_action_just_pressed("ui_right"):
		cheat_code = cheat_code + "D"
	if cheat_code == "HELLO WORLD":
		god_mode()


func make_laser():
	laserInstance = laserScene.instantiate()
	get_parent().add_child(laserInstance)
	Global.laser_made = true


func destroy_laser():
	if laserInstance != null:
		laserInstance.queue_free()
		Global.laser_made = false


func _on_area_2d_area_entered(area):
	if area.is_in_group("Moon_Guy"):
		Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
		area.damage_asteroid(Global.collision_damage)
		check_velocity(area)
	if area.is_in_group("Big_Asteroid") || area.is_in_group("Shard_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
		area.damage_asteroid(Global.collision_damage)
		#print("player ", velocity.length())
		#print("area ", area.velocity.length())
		check_velocity(area)
			
	if area.is_in_group("Medium_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
		area.damage_asteroid(Global.collision_damage)
		check_velocity(area)
			
	if area.is_in_group("Small_Asteroid"): #&& immunity_timer.get_time_left() == 0:
		Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
		area.damage_asteroid(Global.collision_damage)
		check_velocity(area)
			
	if area.is_in_group("Shard"):
		Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
		area.queue_free()
			
	if area.is_in_group("Destroy_Ring"):
		Ui.update_exp(10)
		var audio_player = AUDIO_CONTROL.instantiate()
		audio_player.stream = load("res://Audio/Sounds/mixkit-quick-lock-sound-2854.wav")
		get_parent().add_child(audio_player)
		area.get_parent().destroy()


func check_velocity(area):
	if area.health > 0:
		velocity = (velocity * -0.5) + (area.velocity * 2)


func destroy():
	var asteroid_death = ASTEROID_DEATH_PARTICLES.instantiate()
	asteroid_death.position = self.position
	get_parent().add_child(asteroid_death)
	asteroid_death.one_shot = true
	
	var player_death = PLAYER_DEATH.instantiate()
	player_death.position = self.position
	get_parent().add_child(player_death)
	player_death.one_shot = true
	
	for weapons in get_tree().get_nodes_in_group("weapon"):
		weapons.queue_free()
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/retro-video-game-death-95730.mp3")
	get_parent().add_child(audio_player)
	queue_free()
	GameScene.player = false


func god_mode():
	Global.god_mode = true
	Global.max_health = 30000000
	Global.health = 30000000
	Ui.update_max_health(0)
	Ui.update_health(0)
	Global.damage_reduction = 30000000
