extends Node

@onready var screen_size = get_viewport().get_visible_rect().size

var health = 0
var max_health = 0
var high_score = 0
var damage = 0
var attack_speed = 1
var bullet_speed = 0
var collision_damage = 10
var exp = 0
var exp_threshold = 10
var exp_level = 0

var tier1_damage = {
	"damage_up": false, 
	"attack_speed_up": false,
	"bullet_speed_up": false,
}

var tier1_health = {
	"health_up": false, 
	"damage_resist_up": false,
}

func _ready():
	Global.high_score = load_score()


func _process(_delta):
	pass


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
