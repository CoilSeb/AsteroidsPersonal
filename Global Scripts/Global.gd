extends Node

@onready var screen_size = get_viewport().get_visible_rect().size

# Player Variables
var player_pos: Vector2
var player_rot: float
var high_score = 0
var paused = false
# Health Variables
var health 
var max_health
var health_regen
# Hull Variables
var damage_reduction
var collision_damage 
# Movement Variables
var move_speed
var counter_thrust
# Weapon Variables
var weapon
var damage 
var attack_speed 
var bullet_velocity
var laser_made
var can_shoot
var burn_out
var gatling_gun
var smg
var bulldozer
var bulldozer_bullet_health
var heavy_weaponry
var ghost_bullets
var deviation
var bullet_time
var no_gun_all_collision
var homing_strength: float
var bullet_count
var spread
var max_lasers = 11
var bonus_lasers = 0
var multi_lasers = true
# Explosive Variables
var explosive_rounds: float
var explosion_base_damage: float
var explosion_scale_damage: float
var explosion_base_radius: float
var explosion_scale_radius: float
var explosive_asteroids: bool
# Money Variables
var money
var inflation
var inflation_rate
var reroll_cost
var dev_mode
# Unused
var exp_pull_range = Vector2(0,0)
var weapon_scale = Vector2(0,0)
var experience
var exp_threshold 

# Enemy Variables
var enemy_weight = 0
var moon_guy_asteroid_count = 0
var wave_num
var wave_time

# Upgrade Arrays
var base_upgrades = [
	preload("res://Upgrades/Base_Upgrades/collision_damage_up.tres"),
	preload("res://Upgrades/Base_Upgrades/health_up.tres"),
	preload("res://Upgrades/Base_Upgrades/move_speed.tres"),
	#preload("res://Upgrades/Base_Upgrades/counter_thrust.tres"),
	preload("res://Upgrades/Base_Upgrades/health_regen.tres"),
	preload("res://Upgrades/Base_Upgrades/damage_reduction.tres"),
	#preload("res://Upgrades/Base_Upgrades/exp_pull_range.tres"),
]

var gun_upgrades = [
	preload("res://Upgrades/Gun_Upgrades/attack_speed_up.tres"),
	preload("res://Upgrades/Gun_Upgrades/bullet_velocity.tres"),
	preload("res://Upgrades/Gun_Upgrades/damage_up.tres"),
	preload("res://Upgrades/Gun_Upgrades/explosive_rounds.tres"),
	preload("res://Upgrades/Gun_Upgrades/homing.tres"),
	preload("res://Upgrades/Gun_Upgrades/bullet_count.tres"),
]

var gun_evolutions = [
	preload("res://Upgrades/Gun_Upgrades/Evolutions/Gatling_Gun.tres"),
	preload("res://Upgrades/Gun_Upgrades/Evolutions/SMG.tres"),
	preload("res://Upgrades/Gun_Upgrades/Evolutions/Bulldozer.tres"),
]

var legendary_upgrades = [
	preload("res://Upgrades/Legendary_Upgrades/asteroids_explode.tres"),
]

var rare_upgrades = []

var laser_upgrades = [
	preload("res://Upgrades/Laser_Upgrades/damage_up.tres"),
	preload("res://Upgrades/Laser_Upgrades/laser_scale.tres"),
]

var upgrades_test
var evolutions_test
var legendary_test
var key_upgrades = []

# Preload Upgrades
const REGEN_WITH_DEGEN = preload("res://Upgrades/Combo_Upgradess/regen_with_degen.tres")
const NO_GUN_ALL_COLLISION = preload("res://Upgrades/Combo_Upgradess/no_gun_all_collision.tres")
const BIG_RESIST = preload("res://Upgrades/Combo_Upgradess/big_resist.tres")
const BURN_OUT = preload("res://Upgrades/Combo_Upgradess/burn_out.tres")
const EXPLOSIVE_ROUNDS_RADIUS = preload("res://Upgrades/Gun_Upgrades/explosive_rounds_radius.tres")

# Signals
signal update_max_health(value)
signal update_health(value)
signal shader_settings()
signal update_music_volume()
signal update_sound_effects_volume()
signal moon_guy_health(value)
signal moon_guy_dead()
signal upgrade_pull_range()
signal evo_upgrade()
signal update_money(amount)
signal wave_num_update(wave_num)
signal asteroid_spawned(asteroid)

# Settings Variables
var crt_value = 100.0
var aberration = 0.003
var grille_opacity = 0.5
var fullscreen = false
var music_slider_val = 100.0
var sound_effects_slider_val = 100.0
var sound_effects_volume = 0


func _ready():
	#save_score()
	load_score()
	update_music_volume.connect(volume)
	moon_guy_dead.connect(delete_moon_guy_small_asteroids)


func delete_moon_guy_small_asteroids():
	for asteroid in get_tree().get_nodes_in_group("Boss"):
		asteroid.fade_away()


func volume():
	Music.volume(music_slider_val)


func add_key_upgrades(key_upgrade):
	key_upgrades.append(key_upgrade)
	if key_upgrades.has("explosive_rounds") and !key_upgrades.has("explosive_rounds_radius"):
		key_upgrades.append("explosive_rounds_radius")
		upgrades_test.append(EXPLOSIVE_ROUNDS_RADIUS)
	if key_upgrades.has("health_regen") and key_upgrades.has("health") and !key_upgrades.has("regen_with_degen"):
		key_upgrades.append("regen_with_degen")
		upgrades_test.append(REGEN_WITH_DEGEN)
	if key_upgrades.has("collision_damage") and key_upgrades.has("move_speed") and !key_upgrades.has("no_gun_all_collision"):
		key_upgrades.append("no_gun_all_collision")
		upgrades_test.append(NO_GUN_ALL_COLLISION)
	if key_upgrades.has("damage_reduction") and key_upgrades.has("health") and !key_upgrades.has("big_resist"):
		key_upgrades.append("big_resist")
		upgrades_test.append(BIG_RESIST)
	if key_upgrades.has("damage") and key_upgrades.has("attack_speed") and !key_upgrades.has("burn_out"):
		key_upgrades.append("burn_out")
		upgrades_test.append(BURN_OUT)


func refresh():
	upgrades_test = base_upgrades.duplicate()
	wave_num = 0
	wave_time = 0
	no_gun_all_collision = false
	health = 300
	max_health = health
	health_regen = 0.1
	damage_reduction = 0
	weapon_scale = Vector2(0,0)
	exp_pull_range = Vector2(0,0)
	
	move_speed = 500
	counter_thrust = 0
	
	can_shoot = true
	burn_out = false
	match weapon:
		"Gun":
			damage = 10.0
			attack_speed = 0.5
			bullet_velocity = 700
			homing_strength = 0.0
			bullet_count = 1
			spread = 5
			gatling_gun = false
			smg = false
			bulldozer = false
			heavy_weaponry = false
			ghost_bullets = false
			explosive_rounds = false
			explosion_base_damage = 1.0
			explosion_scale_damage = 1.0
			explosion_base_radius = 1.0
			explosion_scale_radius = 1.0
			bulldozer_bullet_health = 0
			var gun_test = gun_upgrades.duplicate()
			evolutions_test = gun_evolutions.duplicate()
			legendary_test = evolutions_test + legendary_upgrades
			upgrades_test += gun_test
		"Laser":
			damage = 3.0
			attack_speed = 0.1
			bullet_velocity = 0
			max_lasers = 11
			bonus_lasers = 0
			laser_made = false
			var laser_test = laser_upgrades.duplicate()
			legendary_test = legendary_upgrades
			upgrades_test += laser_test
	
	explosive_asteroids = false
	deviation = 0
	bullet_time = 1
	collision_damage = 10
	
	reroll_cost = 25
	inflation = 1
	inflation_rate = 1.25
	money = 0
	experience = 0
	exp_threshold = 50
	key_upgrades.clear()
	enemy_weight = 0
	
	if dev_mode:
		health = 30000000
		max_health = health
		health_regen = 100
		damage_reduction = 100
		money = 10000000


func save_score():
	var save_file = FileAccess.open("user://save_file.save", FileAccess.WRITE)
	save_file.store_var(high_score)
	save_file.store_var(fullscreen)
	save_file.store_var(crt_value)
	save_file.store_var(music_slider_val)
	save_file.store_var(sound_effects_slider_val)


func load_score():
	if FileAccess.file_exists("user://save_file.save"):
		var save_file = FileAccess.open("user://save_file.save", FileAccess.READ)
		high_score = save_file.get_var(high_score)
		fullscreen = save_file.get_var(fullscreen)
		crt_value = save_file.get_var(crt_value)
		music_slider_val = save_file.get_var(music_slider_val)
		sound_effects_slider_val = save_file.get_var(sound_effects_slider_val)
		aberration = crt_value / 33333.0
		grille_opacity = crt_value / 200.0
		#print("loaded: ", crt_value)
	else:
		high_score = 0
		fullscreen = false
		crt_value = 100.0
		


func get_score_text(value):
	var score_string = str(value)
	var score_text = ""
	for i in range(len(score_string)):
		score_text += score_string[i]
		var distance = len(score_string) - i
		if distance != 1 and distance % 3 == 1:
			score_text += ","
	return score_text
