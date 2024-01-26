extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_text : String = ""
@export var next_upgrade : upgrade = null
@export var upgrade_value : int = 0

@export var upgrade_function : GDScript = null

func upgrade_player():
	if "health" in upgrade_name:
		upgrade_health()

func upgrade_health():
	Global.update_max_health.emit(upgrade_value)
	Global.update_health.emit(upgrade_value)
