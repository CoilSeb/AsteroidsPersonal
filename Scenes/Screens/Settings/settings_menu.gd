extends Control

@onready var crt_label = $CRT_Label
@onready var h_slider = $HSlider
@onready var exit_button = $ExitButton
@onready var settings_menu = $"."
@onready var check_button = $CheckButton


func _ready():
	h_slider.value = Global.grille_opacity * 200
	check_button.button_pressed = Global.fullscreen


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Escape"):
		_on_exit_button_pressed()


func _on_h_slider_value_changed(value):
	Global.shader_settings.emit()
	Global.aberration = value / 33333
	Global.grille_opacity = value / 200


func _on_exit_button_pressed():
	#settings menu exit button
	if settings_menu.visible:
		Global.save_score()
		settings_menu.hide()


func _on_check_button_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Global.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Global.fullscreen = false
