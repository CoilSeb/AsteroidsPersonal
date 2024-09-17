extends Node

@onready var Ui = get_node("UI")
@onready var ScoreLabel = Ui.get_node("Score_Label")
@onready var spawnTimer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var moon_guy_warning = $Moon_Guy_Warning
@onready var asteroid_timer = $AsteroidTimer

const CHEST = preload("res://Scenes/Items/chest.tscn")
var playerScene = preload("res://Scenes/Player/Player.tscn")
var player = true
var screen_size
var start_moon_guy_warning = false

var basic_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Medium Asteroid/Medium_asteroid.tscn"),
	1: preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn"),
	2: preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
}

var special_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Shard Asteroid/Shard_Asteroid.tscn"),
}

var moon_guy_scene = preload("res://Scenes/Asteroids/Moon_Guy/Moon_Guy.tscn")

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	if !find_child("Player"):
		player = false
		#print(player)
	for i in range(7):
		spawn_chest()


func _process(_delta):
	#print(Global.enemy_weight)
	Global.wave_time = wave_timer.time_left
	if !player:
		#print(player)
		var playerInstance = playerScene.instantiate()
		add_child(playerInstance)
		playerInstance.position = Vector2.ZERO
		#print(playerInstance.position)
		player = true
	#print(Global.enemy_weight)
	
	if start_moon_guy_warning:
		if moon_guy_warning.scale <= Vector2(16, 16):
			moon_guy_warning.scale += Vector2(0.05, 0.05)
		else:
			moon_guy_warning.hide()
			var moon_guy = moon_guy_scene.instantiate()
			add_child(moon_guy)
			moon_guy.global_position = screen_size/2
			moon_guy.weighted = true
			start_moon_guy_warning = false


func game_over():
	
	return
	##print ("game_over")
	##print (get_children())
	#for child in get_children():
		##print("Child: ", child.name)
		#if child.name != "UI": 
			##print("Deleting Child: ", child.name) 
			#child.queue_free()


#func spawn_basic_Asteroid():
	#var new_asteroid = basic_asteroid_scenes[randi_range(0,basic_asteroid_scenes.size() - 1)].instantiate()
	#add_child(new_asteroid)
	#new_asteroid.global_position = generate_spawn_point()
#
#
#func spawn_special_Asteroid():
	#var new_asteroid = special_asteroid_scenes[randi_range(0,special_asteroid_scenes.size() - 1)].instantiate()
	#add_child(new_asteroid)
	#new_asteroid.global_position = generate_spawn_point()


func spawn_basic_Asteroid_with_weight():
	var new_asteroid = basic_asteroid_scenes[randi_range(0,basic_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()
	new_asteroid.weighted = true


func spawn_special_Asteroid_with_weight():
	var new_asteroid = special_asteroid_scenes[randi_range(0,special_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()
	new_asteroid.weighted = true


func random_vector(left, right, bottom, top):
	return Vector2(randf_range(left, right), randf_range(bottom, top))


func generate_spawn_point():
	var locations = [
		# Upper Rectangle
		random_vector(0, Global.player_pos.x + 2560, screen_size.y + 1440, screen_size.y + 1440),
		# Lower Rectangle
		random_vector(0, Global.player_pos.x + 2560, -screen_size.y - 1440, -screen_size.y - 1440),
		# Right Rectangle
		random_vector(Global.player_pos.x + 2560, Global.player_pos.x + 2560, 0, screen_size.y + 1440),
		# Left Rectangle
		random_vector(-Global.player_pos.x - 2560, -Global.player_pos.x - 2560, 0, screen_size.y + 1440),
	]
	return locations[randi_range(0,3)]


func _on_spawn_timer_timeout():
	spawn_wave()


func spawn_wave():
	if Global.wave_num == 0 && Global.enemy_weight <= 0:
		#await get_tree().create_timer(0.5, false).timeout
		#Ui.level_up()
		wave_timer.start()
		asteroid_timer.start()
		Global.wave_num += 1
		Global.wave_num_update.emit(Global.wave_num)
		for i in range(25):
			spawn_basic_Asteroid_with_weight()
		return
	if Global.wave_num == 1 && Global.enemy_weight <= 0:
		_on_wave_timer_timeout()
		await get_tree().create_timer(0.5, false).timeout
		Global.inflation *= Global.inflation_rate
		Ui.level_up()
		wave_timer.start()
		Global.wave_num += 1
		Global.wave_num_update.emit(Global.wave_num)
		for i in range(24):
			spawn_basic_Asteroid_with_weight()
		for i in range(1):
			spawn_special_Asteroid_with_weight()
		return
	if Global.wave_num == 2 && Global.enemy_weight <= 0:
		_on_wave_timer_timeout()
		await get_tree().create_timer(0.5, false).timeout
		Global.inflation *= Global.inflation_rate
		Ui.level_up()
		wave_timer.start()
		Global.wave_num += 1
		Global.wave_num_update.emit(Global.wave_num)
		for i in range(21):
			spawn_basic_Asteroid_with_weight()
		for i in range(4):
			spawn_special_Asteroid_with_weight()
		return
	if Global.wave_num == 3 && Global.enemy_weight <= 0:
		_on_wave_timer_timeout()
		await get_tree().create_timer(0.5, false).timeout
		Global.inflation *= Global.inflation_rate
		Ui.level_up()
		wave_timer.start()
		Global.wave_num += 1
		Global.wave_num_update.emit(Global.wave_num)
		for i in range(21):
			spawn_basic_Asteroid_with_weight()
		for i in range(4):
			spawn_special_Asteroid_with_weight()
		return
	if Global.wave_num == 4 && Global.enemy_weight <= 0:
		_on_wave_timer_timeout()
		await get_tree().create_timer(0.5, false).timeout
		Global.inflation *= Global.inflation_rate
		wave_timer.stop()
		Ui.level_up()
		asteroid_timer.stop()
		Global.enemy_weight += 40
		Global.wave_num = 0
		Global.wave_num_update.emit("moon_guy")
		moon_guy_warning.show()
		start_moon_guy_warning = true
		return


func _on_wave_timer_timeout():
	asteroid_timer.start()
	var temp_vol = Global.sound_effects_volume
	Global.sound_effects_volume = -400
	for asteroid in get_tree().get_nodes_in_group("Big Asteroid"):
		asteroid.destroy(false)
	await get_tree().create_timer(0.01).timeout
	for asteroid in get_tree().get_nodes_in_group("Medium Asteroid"):
		asteroid.destroy(false)
	await get_tree().create_timer(0.01).timeout
	for asteroid in get_tree().get_nodes_in_group("Small Asteroid"):
		asteroid.destroy(false)
	for asteroid in get_tree().get_nodes_in_group("Enemy"):
		asteroid.destroy(false)
	await get_tree().create_timer(0.01).timeout
	for asteroid in get_tree().get_nodes_in_group("Shard"):
		asteroid.queue_free()
	for weapon in get_tree().get_nodes_in_group("weapon"):
		if Global.weapon == "Gun":
			weapon.queue_free()
	await get_tree().create_timer(0.02).timeout
	Global.enemy_weight = 0
	Global.sound_effects_volume = temp_vol


func _on_asteroid_timer_timeout():
	var i = randi_range(0,10)
	if i == 0:
		spawn_special_Asteroid_with_weight()
	spawn_basic_Asteroid_with_weight()


func spawn_chest():
	var rand_vec = random_vector(-5000, 5000, -5000, 5000)
	var new_chest = CHEST.instantiate()
	new_chest.global_position = rand_vec
	add_child(new_chest)
