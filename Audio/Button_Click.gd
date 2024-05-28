extends Node2D

@onready var audio_stream_player_2d = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.update_sound_effects_volume.connect(sound_effects)
	sound_effects()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func play():
	audio_stream_player_2d.play()


func sound_effects():
	audio_stream_player_2d.volume_db = Global.sound_effects_volume + 15
