extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_text : String = ""
@export var next_upgrade : upgrade = null
@export var upgrade_value : float = 0

@export var upgrade_function : GDScript = null

func upgrade_player():
	if upgrade_name == "health":
		upgrade_health()
	if upgrade_name == "damage":
		upgrade_damage()

func upgrade_health():
	Global.update_max_health.emit(upgrade_value)
	Global.update_health.emit(upgrade_value)

func upgrade_damage():
	Global.damage += upgrade_value
	print(Global.damage)
