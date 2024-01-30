extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_text : String = ""
@export var next_upgrade : upgrade = null
@export var upgrade_value : float = 0

@export var upgrade_function : GDScript = null

func upgrade_player():
	match upgrade_name:
		"health":
			upgrade_health()
		"damage":
			upgrade_damage()
		"attack_speed":
			upgrade_attack_speed()
		"collision_damage":
			upgrade_collision_damage()
		"health_regen":
			upgrade_health_regen()
		"move_speed":
			upgrade_move_speed()
		"counter_thrust":
			upgrade_counter_thrust()

func upgrade_health():
	Global.update_max_health.emit(upgrade_value)
	Global.update_health.emit(upgrade_value)

func upgrade_damage():
	Global.damage += upgrade_value
	print(Global.damage)

func upgrade_attack_speed():
	Global.attack_speed -= (Global.attack_speed * upgrade_value)

func upgrade_collision_damage():
	Global.collision_damage += upgrade_value

func upgrade_health_regen():
	Global.health_regen += upgrade_value

func upgrade_move_speed():
	Global.move_speed += upgrade_value

func upgrade_counter_thrust():
	Global.counter_thrust += upgrade_value
