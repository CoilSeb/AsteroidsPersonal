extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer

var music_list = {
	0: load("res://Audio/Sounds/2018-08-02-17971.mp3"),
	1: load("res://Audio/Sounds/arguement-loop-27901.mp3"),
	2: load("res://Audio/Sounds/112bpm_catchy-reverb-synth-loop-30259-[AudioTrimmer.com].mp3"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	var i = randi_range(0, music_list.size() - 1)
	audio_stream_player.stream = music_list[i]
	audio_stream_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func volume(value):
	audio_stream_player.volume_db = 0 - (100 - value)/3
	if value == 0:
		audio_stream_player.volume_db = -100000


func _on_audio_stream_player_finished():
	var i = randi_range(0, music_list.size() - 1)
	audio_stream_player.stream = music_list[i]
	audio_stream_player.play()
