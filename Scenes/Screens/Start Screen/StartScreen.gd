extends CanvasLayer

@onready var high_score_label = $Control/High_Score
@onready var color_rect = $ColorRect
@onready var settings_menu = $SettingsMenu
@onready var exit_button = $SettingsMenu/ExitButton
@onready var start = $Control/Start
@onready var settings_button = $Control/Settings
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var gpu_particles_2d = $Control/Start/GPUParticles2D

const ON_CLICK_PARTICLES = preload("res://Particles/on_click_particles.tscn")


func _ready():
	Global.shader_settings.connect(crt)
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	high_score_label.text = "High Score: " + Global.get_score_text(Global.high_score)
	start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("M1"):
		var mouse_pos = get_viewport().get_mouse_position()
		var particles = ON_CLICK_PARTICLES.instantiate()
		particles.position = mouse_pos
		add_child(particles)
		particles.one_shot = true



func _on_start_pressed():
	Global.weapon = "Gun"
	gpu_particles_2d.emitting = true
	gpu_particles_2d.one_shot = true
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")


func _on_exit_button_pressed():
	#settings menu exit button
	audio_stream_player_2d.play()
	settings_menu.hide()


func _on_settings_pressed():
	audio_stream_player_2d.play()
	settings_menu.show()


func _on_exit_pressed():
	audio_stream_player_2d.play()
	get_tree().quit()


func crt():
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
