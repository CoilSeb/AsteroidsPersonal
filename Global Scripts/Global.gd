extends Node

# Global Variables
var health = 100
var high_score = 0
var damage_multiplier = 1.0
var collision_damage = 10
var experience = 0
@onready var screen_size = get_viewport().get_visible_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(screen_size)
	Global.high_score = load_score()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
