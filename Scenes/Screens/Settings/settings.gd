extends CanvasLayer

@onready var color_rect = $ColorRect


func _ready():
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_h_slider_value_changed(value):
	Global.shader_settings.emit()
	Global.aberration = value / 20000
	Global.grille_opacity = value / 333
