extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func volume(value):
	audio_stream_player.volume_db = 0 - (100 - value)/5
	if value == 0:
		audio_stream_player.volume_db = -100000
