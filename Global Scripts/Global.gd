extends Node

@onready var screen_size = get_viewport().get_visible_rect().size

var high_score
var health 
var max_health
var health_regen
var damage_reduction
var move_speed
var counter_thrust
var damage 
var attack_speed 
var bullet_velocity 
var collision_damage 
var exp 
var exp_threshold 
var weapon
var laser_made
var can_shoot
var burn_out

var start_upgrades = [
	preload("res://Upgrades/Solo_Upgrades/damage_up.tres"),
	preload("res://Upgrades/Solo_Upgrades/attack_speed_up.tres"),
	preload("res://Upgrades/Solo_Upgrades/collision_damage_up.tres"),
	preload("res://Upgrades/Solo_Upgrades/health_up.tres"),
	preload("res://Upgrades/Solo_Upgrades/move_speed.tres"),
	preload("res://Upgrades/Solo_Upgrades/counter_thrust.tres"),
	preload("res://Upgrades/Solo_Upgrades/health_regen.tres"),
	preload("res://Upgrades/Solo_Upgrades/bullet_velocity.tres"),
	preload("res://Upgrades/Solo_Upgrades/damage_reduction.tres"),
]
const REGEN_WITH_DEGEN = preload("res://Upgrades/Combo_Upgradess/regen_with_degen.tres")
const NO_GUN_ALL_COLLISION = preload("res://Upgrades/Combo_Upgradess/no_gun_all_collision.tres")
const BIG_RESIST = preload("res://Upgrades/Combo_Upgradess/big_resist.tres")
const BURN_OUT = preload("res://Upgrades/Combo_Upgradess/burn_out.tres")

signal update_max_health(value)
signal update_health(value)

var upgrades_test = start_upgrades.duplicate()

var key_upgrades = []


func _ready():
	Global.high_score = load_score()

func add_key_upgrades(key_upgrade):
	key_upgrades.append(str(key_upgrade))
	if key_upgrades.has("health_regen") and key_upgrades.has("health") and !key_upgrades.has("regen_with_degen"):
		upgrades_test.append(REGEN_WITH_DEGEN)
	if key_upgrades.has("collision_damage") and key_upgrades.has("move_speed") and !key_upgrades.has("no_gun_all_collision"):
		upgrades_test.append(NO_GUN_ALL_COLLISION)
	if key_upgrades.has("damage_reduction") and key_upgrades.has("health") and !key_upgrades.has("big_resist"):
		upgrades_test.append(BIG_RESIST)
	if key_upgrades.has("damage") and key_upgrades.has("attack_speed") and !key_upgrades.has("burn_out"):
		upgrades_test.append(BURN_OUT)


func refresh():
	upgrades_test = start_upgrades.duplicate()
	
	health = 300
	max_health = health
	health_regen = 0
	damage_reduction = 0
	
	move_speed = 500
	counter_thrust = 0
	
	can_shoot = true
	burn_out = false
	match weapon:
		"Gun":
			damage = 10
			attack_speed = 0.75
		"Laser":
			damage = 1
			attack_speed = 0.1
			laser_made = false
	
	bullet_velocity = 700
	collision_damage = 10
	
	exp = 0
	exp_threshold = 30
	key_upgrades.clear()
	


func save_score():
	var saved_score = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	var save_text = JSON.stringify({"High Score": Global.high_score})
	saved_score.store_line(save_text)


func load_score():
	if not FileAccess.file_exists("user://high_score.save"):
		print_debug("File does not exist")
		return 0
	var saved_score = FileAccess.open("user://high_score.save", FileAccess.READ)
	var json_string = saved_score.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print_debug("No JSON")
		return 0
	var data = json.get_data()
	return data["High Score"]


func get_score_text(value):
	var score_string = str(value)
	var score_text = ""
	for i in range(len(score_string)):
		score_text += score_string[i]
		var distance = len(score_string) - i
		if distance != 1 and distance % 3 == 1:
			score_text += ","
	return score_text
