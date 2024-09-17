extends CharacterBody2D

@onready var GameScene = get_parent()
@onready var Ui = get_parent().get_node("UI")
@onready var thrust_sprite_2d = $Thrust_Sprite2D
@onready var weapon_sound = $Weapon_Sound
@onready var hit_sound = $Hit_Sound
@onready var collection_range = $Collection_Range
@onready var hit_timer = $Hit_Timer
@onready var laser_charge_timer = $Laser_Charge_Timer
@onready var camera_2d = $Camera2D

const ASTEROID_DEATH_PARTICLES = preload("res://Particles/asteroid_death_particles.tscn")
const PLAYER_DEATH = preload("res://Particles/player_death.tscn")
var bulletScene = preload("res://Scenes/Bullets/Bullet.tscn")
var laserScene = preload("res://Scenes/Laser/laser.tscn")
const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
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
var thrusting = false
var lasers = []
var laser_scale_multiplied = 2
var current_lasers = 0
var items = []


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
	Global.player_rot = rotation
	thrust = Global.move_speed
	counter_thrust = Global.counter_thrust
	Ui.update_health(Global.health_regen * delta)
	# Screen Wrap
	if position.x < -5000:
		position.x = 5000
	if position.x > 5000:
		position.x = -5000
	if position.y < -5000:
		position.y = 5000
	if position.y > 5000:
		position.y = -5000
		
	if Input.is_action_just_released('M3_Down') && camera_2d.get_zoom() > Vector2(0.25, 0.25):
		camera_2d.set_zoom(camera_2d.get_zoom() - Vector2(0.1, 0.1))
	if Input.is_action_just_released('M3_Up') && camera_2d.get_zoom() < Vector2.ONE:
		camera_2d.set_zoom(camera_2d.get_zoom() + Vector2(0.1, 0.1))
	
	rs_look.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	rs_look.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle() + (0.5 * PI)
	
	#rotation -= (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")) * rotateSpeed * delta
	
	# Movement
	
	# Forward thrust movement
	#if Input.is_action_pressed("ui_left"):
		#using_mouse = false
	#if Input.is_action_pressed("ui_right"):
		#using_mouse = false
	#if Input.is_action_pressed("M1") || Input.is_action_pressed("M2"):
		#using_mouse = true
	#if using_mouse == true:
		#rotate(get_angle_to(get_global_mouse_position()) + (0.5 * PI))
	#if Input.is_action_pressed("move_forward") && can_move:
		#velocity += ((Vector2(0, -1) * thrust * delta).rotated(rotation))
	#elif Input.is_action_just_pressed("move_backward"):
		#velocity += ((Vector2(0, 10) * counter_thrust * delta).rotated(rotation))
	rotate(get_angle_to(get_global_mouse_position()) + (0.5 * PI))
	
	# Omni-directional movement
	if Input.is_action_pressed("move_forward") && can_move:
		velocity += ((Vector2(0, -1) * thrust * delta))
	if Input.is_action_pressed("move_backward") && can_move:
		velocity += ((Vector2(0, 1) * thrust * delta))
	if Input.is_action_pressed("rotate_left") && can_move:
		velocity += ((Vector2(-1, 0) * thrust * delta))
	if Input.is_action_pressed("rotate_right") && can_move:
		velocity += ((Vector2(1, 0) * thrust * delta))
	
	if (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward") or Input.is_action_pressed("rotate_left") or Input.is_action_pressed("rotate_right") and can_move):
		pass
	else:
		thrust_sprite_2d.hide()
		velocity = lerp(velocity, Vector2.ZERO, slowDown * delta)
		if velocity.length() >= -10 && velocity.length() <= 10:
			velocity = Vector2.ZERO
	#print(velocity)
		
	if velocity.length() > 500:
		velocity = lerp(velocity, Vector2.ZERO, slowDown * delta)
		
	move_and_collide(velocity * delta)
		
	if !Global.no_gun_all_collision:
		if (Ui.burn_out_bar.max_value - Ui.burn_out_bar.value)/Ui.burn_out_bar.max_value >= 0.7:
			Ui.burn_out_bar.tint_progress = Color8(221, 0, 19, 255)
		else:
			Ui.burn_out_bar.tint_progress = Color("ffffff")
		if Global.burn_out:
			Ui.burn_out_bar_bg.show()
			Ui.burn_out_bar_bg.max_value = burn_out_var
			Ui.burn_out_bar_bg.value = Ui.burn_out_bar_bg.max_value
			Ui.burn_out_bar.show()
			Ui.burn_out_bar.max_value = burn_out_var
			Ui.burn_out_bar.value = burn_out_time
		if !Global.can_shoot && burn_out_time < burn_out_var && Global.burn_out:
			Ui.burn_out_bar.tint_progress = Color(0.4, 0.4, 0.4)
			burn_out_time += 0.75
		if !Global.can_shoot && burn_out_time >= burn_out_var && Global.burn_out:
			Ui.burn_out_bar.tint_progress = Color(255, 255, 255)
			Global.can_shoot = true
		if Global.can_shoot && Global.burn_out && burn_out_time < burn_out_var:
			burn_out_time += 1.5
			
	# Shooting
	if Global.can_shoot:
		if weapon == "Laser":
			Global.burn_out = true
			if Global.paused:
				destroy_laser()
				Global.paused = false
			if Input.is_action_pressed("shoot"):
				if !Global.laser_made:
					make_more_lasers()
				for i in range(len(lasers)):
					var spread = ((Global.max_lasers + Global.bonus_lasers) * laser_scale_multiplied / 4)
					var offset = spread - ((Global.max_lasers + Global.bonus_lasers - i) * laser_scale_multiplied / 2) + (spread / (Global.max_lasers + Global.bonus_lasers))
					lasers[i].global_position = global_position + Vector2(offset, -15).rotated(rotation)
					lasers[i].damage_modifier = 1 + ($Burn_Out_Bar.max_value - $Burn_Out_Bar.value)/$Burn_Out_Bar.max_value
					
			if Input.is_action_just_released("shoot"):
				laser_charge_bool = false
				laser_done = false
				destroy_laser()
				return
		if weapon == "Gun":
			var angle = 0 - (Global.bullet_count * Global.spread)/2.0 + Global.spread/2.0
			if (Input.is_action_pressed("shoot") or Input.is_action_pressed("M2")) && shootTimer.time_left == 0:
				if Global.gatling_gun && Input.is_action_pressed("move_forward"):
					return
				for i in range(Global.bullet_count):
					var bulletInstance = bulletScene.instantiate()
					bulletInstance.scale += Global.weapon_scale
					get_parent().add_child(bulletInstance)
					bulletInstance.global_position = global_position
					var deviation = randf_range(-Global.deviation, Global.deviation)
					bulletInstance.direction = Vector2.UP.rotated(rotation + deviation + deg_to_rad(angle))
					weapon_sound.play()
					shootTimer.start(Global.attack_speed)
					if Global.heavy_weaponry:
						velocity = Vector2.DOWN.rotated(rotation) * 200
					angle += Global.spread
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


func make_more_lasers():
	for i in range(Global.max_lasers + Global.bonus_lasers):
		var laser_instance = laserScene.instantiate()
		var spread = (Global.max_lasers + Global.bonus_lasers) * laser_scale_multiplied / 4
		var offset = spread - ((Global.max_lasers + Global.bonus_lasers - i) * laser_scale_multiplied / 2) + (spread / (Global.max_lasers + Global.bonus_lasers))
		laser_instance.global_position = global_position + Vector2(offset, -15).rotated(rotation)
		lasers.append(laser_instance)
		add_child(laser_instance)
		
	Global.laser_made = true


func destroy_laser():
	for laser in lasers:
		laser.queue_free()
	lasers.clear()
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
			
		if area.is_in_group("Basic_Martian"):
			hit_sound.play()
			Ui.update_health(-area.damage + (area.damage * Global.damage_reduction))
			area.damage_asteroid(Global.collision_damage)
			velocity = (velocity * -0.5)
			
	if area.is_in_group("Destroy_Ring"):
		Ui.update_exp(10)
		var audio_player = AUDIO_CONTROL.instantiate()
		audio_player.stream = load("res://Audio/Sounds/mixkit-quick-lock-sound-2854.wav")
		audio_player.volume_db = Global.sound_effects_volume - 10
		get_parent().add_child(audio_player)
		area.get_parent().destroy()
				


func check_velocity(area):
	if area.health > 0:
		velocity = (velocity * -0.5) + (area.velocity * 2)
		var hit_tween = get_tree().create_tween()
		hit_tween.bind_node(self)
		hit_timer.start()
		hit_tween.tween_property(self, "modulate", Color8(255, 255, 255, 0), 0.19)
		hit_tween.tween_property(self, "modulate", Color8(255, 255, 255, 255), 0.01)


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
