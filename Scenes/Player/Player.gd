extends CharacterBody2D

@onready var GameScene = get_parent()
@onready var Ui = get_parent().get_node("UI")
@onready var thrust_sprite_2d = $Thrust_Sprite2D
@onready var weapon_sound = $Weapon_Sound
@onready var hit_sound = $Hit_Sound
@onready var collection_range = $Collection_Range
@onready var hit_timer = $Hit_Timer
@onready var laser_charge_timer = $Laser_Charge_Timer

const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const PLAYER_DEATH = preload("res://Particles/player_death.tscn")
var bulletScene = preload("res://Scenes/Bullets/Bullet.tscn")
var laserScene = preload("res://Scenes/Laser/laser.tscn")
const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
var laser1
var laser2
var laser3
var laser4
var laser5
var laser6
var laser7
var laser8
var laser9
var laser10
var laser11
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
var rs_look = Vector2(0,0)
var deadzone = 1
var laser_charge_bool = false
var laser_done = false


func _ready():
	Global.update_money.connect(update_money)
	Global.update_sound_effects_volume.connect(sound_effects)
	Global.upgrade_pull_range.connect(increase_exp_pull_range)
	sound_effects()
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
	Global.player_pos = position
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
				if laser_charge_timer.is_stopped() && !laser_done:
					laser_charge_timer.start()
				if laser_charge_bool:
					Global.damage *= 3
					laser1.scale *= 2
					laser2.scale *= 2
					laser3.scale *= 2
					laser4.scale *= 2
					laser5.scale *= 2
					laser6.scale *= 2
					laser7.scale *= 2
					laser8.scale *= 2
					laser9.scale *= 2
					laser10.scale *= 2
					laser11.scale *= 2
					laser_charge_bool = false
					
				if !Global.laser_made:
					make_laser()
				var offset = laser1.scale.x * 10.0
				laser1.global_position = global_position + Vector2(-offset * 5, -15).rotated(rotation)
				laser1.direction = Vector2.UP.rotated(rotation) 
				laser2.global_position = global_position + Vector2(-offset * 4, -15).rotated(rotation)
				laser2.direction = Vector2.UP.rotated(rotation) 
				laser3.global_position = global_position + Vector2(-offset * 3, -15).rotated(rotation)
				laser3.direction = Vector2.UP.rotated(rotation) 
				laser4.global_position = global_position + Vector2(-offset * 2, -15).rotated(rotation)
				laser4.direction = Vector2.UP.rotated(rotation) 
				laser5.global_position = global_position + Vector2(-offset * 1, -15).rotated(rotation)
				laser5.direction = Vector2.UP.rotated(rotation)
				laser6.global_position = global_position + Vector2(0, -15).rotated(rotation)
				laser6.direction = Vector2.UP.rotated(rotation)
				laser7.global_position = global_position + Vector2(offset * 1, -15).rotated(rotation)
				laser7.direction = Vector2.UP.rotated(rotation)
				laser8.global_position = global_position + Vector2(offset * 2, -15).rotated(rotation)
				laser8.direction = Vector2.UP.rotated(rotation)
				laser9.global_position = global_position + Vector2(offset * 3, -15).rotated(rotation)
				laser9.direction = Vector2.UP.rotated(rotation)
				laser10.global_position = global_position + Vector2(offset * 4, -15).rotated(rotation)
				laser10.direction = Vector2.UP.rotated(rotation)
				laser11.global_position = global_position + Vector2(offset * 5, -15).rotated(rotation)
				laser11.direction = Vector2.UP.rotated(rotation)
			if Input.is_action_just_released("shoot") || Input.is_action_pressed("move_forward") || Input.is_action_pressed("move_backward"):
				laser_charge_bool = false
				if laser_done:
					Global.damage /= 3
				laser_done = false
				destroy_laser()
				return
		if weapon == "Gun":
			if (Input.is_action_pressed("shoot") || Input.is_action_pressed("M2")) && shootTimer.time_left == 0:
				if Global.gatling_gun && Input.is_action_pressed("move_forward"):
					return
				var bulletInstance = bulletScene.instantiate()
				get_parent().add_child(bulletInstance)
				bulletInstance.global_position = global_position
				var i = randf_range(-Global.deviation, Global.deviation)
				bulletInstance.direction = Vector2.UP.rotated(rotation + i)
				bulletInstance.scale += Global.weapon_scale
				weapon_sound.play()
				shootTimer.start(Global.attack_speed)
				if Global.heavy_weaponry:
					velocity = Vector2.DOWN.rotated(rotation) * 200
		#Burn Out
		if Global.burn_out && Input.is_action_pressed("shoot") && Global.can_shoot:
			burn_out_time -= 2.5
			if burn_out_time <= 0:
				destroy_laser()
				Global.can_shoot = false
			
	if Global.health <= 0:
		destroy()
		GameScene.player = true


func _on_laser_charge_timer_timeout():
	if Input.is_action_pressed("shoot") && !Input.is_action_pressed("move_forward"):
		laser_charge_bool = true
		laser_done = true


func make_laser():
	laser1 = laserScene.instantiate()
	get_parent().add_child(laser1)
	Global.laser_made = true
	laser1.scale += Global.weapon_scale
	laser2 = laserScene.instantiate()
	get_parent().add_child(laser2)
	Global.laser_made = true
	laser2.scale += Global.weapon_scale
	laser3 = laserScene.instantiate()
	get_parent().add_child(laser3)
	Global.laser_made = true
	laser3.scale += Global.weapon_scale
	laser4 = laserScene.instantiate()
	get_parent().add_child(laser4)
	Global.laser_made = true
	laser4.scale += Global.weapon_scale
	laser5 = laserScene.instantiate()
	get_parent().add_child(laser5)
	Global.laser_made = true
	laser5.scale += Global.weapon_scale
	laser6 = laserScene.instantiate()
	get_parent().add_child(laser6)
	Global.laser_made = true
	laser6.scale += Global.weapon_scale
	laser7 = laserScene.instantiate()
	get_parent().add_child(laser7)
	Global.laser_made = true
	laser7.scale += Global.weapon_scale
	laser8 = laserScene.instantiate()
	get_parent().add_child(laser8)
	Global.laser_made = true
	laser8.scale += Global.weapon_scale
	laser9 = laserScene.instantiate()
	get_parent().add_child(laser9)
	Global.laser_made = true
	laser9.scale += Global.weapon_scale
	laser10 = laserScene.instantiate()
	get_parent().add_child(laser10)
	Global.laser_made = true
	laser10.scale += Global.weapon_scale
	laser11 = laserScene.instantiate()
	get_parent().add_child(laser11)
	Global.laser_made = true
	laser11.scale += Global.weapon_scale


func destroy_laser():
	if laser1 != null:
		laser1.queue_free()
		laser2.queue_free()
		laser3.queue_free()
		laser4.queue_free()
		laser5.queue_free()
		laser6.queue_free()
		laser7.queue_free()
		laser8.queue_free()
		laser9.queue_free()
		laser10.queue_free()
		laser11.queue_free()
		Global.laser_made = false


func _on_area_2d_area_entered(area):
	if hit_timer.time_left == 0:
		if area.is_in_group("Moon_Guy"):
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			check_velocity(area)
		if area.is_in_group("Big_Asteroid") || area.is_in_group("Shard_Asteroid"): #&& immunity_timer.get_time_left() == 0:
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			#print("player ", velocity.length())
			#print("area ", area.velocity.length())
			check_velocity(area)
				
		if area.is_in_group("Medium_Asteroid"): #&& immunity_timer.get_time_left() == 0:
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			check_velocity(area)
				
		if area.is_in_group("Small_Asteroid"): #&& immunity_timer.get_time_left() == 0:
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			check_velocity(area)
				
		if area.is_in_group("Shard"):
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			
	if area.is_in_group("Destroy_Ring"):
		Ui.update_exp(10)
		var audio_player = AUDIO_CONTROL.instantiate()
		audio_player.stream = load("res://Audio/Sounds/mixkit-quick-lock-sound-2854.wav")
		audio_player.volume_db = Global.sound_effects_volume - 10
		get_parent().add_child(audio_player)
		area.get_parent().destroy()
				


func check_velocity(area):
	if area.health > 0:
		hit_timer.start()
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
	audio_player.volume_db = Global.sound_effects_volume
	get_parent().add_child(audio_player)
	queue_free()
	GameScene.player = false


func sound_effects():
	weapon_sound.volume_db = Global.sound_effects_volume
	hit_sound.volume_db = Global.sound_effects_volume


func increase_exp_pull_range():
	collection_range.scale += Global.exp_pull_range


func update_money(amount):
	Global.money += amount
