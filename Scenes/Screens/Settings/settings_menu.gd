extends Control

@onready var crt_label = $CRT_Label
@onready var crt_slider = $CRT_Slider
@onready var exit_button = $ExitButton
@onready var settings_menu = $"."
@onready var check_button = $CheckButton
@onready var crt_line_edit = $CRT_Line_Edit
@onready var audio_stream_player = $AudioStreamPlayer

@export var my_scenes_button: Button

var focused = false


func _ready():
	crt_slider.value = Global.crt_value
	crt_line_edit.text = str(Global.crt_value)
	check_button.button_pressed = Global.fullscreen
	check_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_exit_button_pressed()


func _on_h_slider_value_changed(value):
	Global.crt_value = value
	crt_line_edit.text = str(Global.crt_value)
	Global.aberration = value / 33333
	Global.grille_opacity = value / 200
	Global.shader_settings.emit()


func _on_exit_button_pressed():
	#settings menu exit button
	audio_stream_player.play()
	if settings_menu.visible:
		Global.save_score()
		settings_menu.hide()


func _on_check_button_toggled(toggled_on):
	audio_stream_player.play()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Global.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Global.fullscreen = false


func has_letters(your_string):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	if regex.search(str(your_string)):
		return true
	else:
		return false


func _on_crt_line_edit_text_submitted(new_text):
	if !has_letters(new_text) && float(new_text) <= 100:
		crt_slider.value = float(new_text)


func _on_visibility_changed():
	if settings_menu != null:
		if self.visible:
			check_button.grab_focus()
		else:
			my_scenes_button.grab_focus()
