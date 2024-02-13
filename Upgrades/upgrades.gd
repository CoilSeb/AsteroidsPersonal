extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_text : String = ""
@export var upgrade_value : float = 0
@export var upgrade_texture: Texture
@export var key_upgrade: bool
@export var next_upgrade : upgrade = null


func upgrade_player():
	if key_upgrade:
		Global.add_key_upgrades(upgrade_name)
	match upgrade_name:
		"health":
			health()
		"damage":
			damage()
		"attack_speed":
			attack_speed()
		"collision_damage":
			collision_damage()
		"health_regen":
			health_regen()
		"move_speed":
			move_speed()
		"counter_thrust":
			counter_thrust()
		"bullet_velocity":
			bullet_velocity()
		"damage_reduction":
			damage_reduction()
		"regen_with_degen":
			regen_with_degen()
		"no_gun_all_collision":
			no_gun_all_collision()
		"big_resist":
			big_resist()
		"burn_out":
			burn_out()

func burn_out():
	Global.burn_out = true
	match Global.weapon:
		"Gun":
			Global.attack_speed -= (Global.attack_speed * upgrade_value)
		"Laser":
			Global.damage += (Global.damage * upgrade_value)

func damage_reduction():
	Global.damage_reduction += upgrade_value

func big_resist():
	Global.damage_reduction *= 2
	Global.move_speed /= 2

func no_gun_all_collision():
	Global.can_shoot = false
	Global.collision_damage *= upgrade_value

func regen_with_degen():
	Global.max_health = Global.max_health/upgrade_value
	Global.health = Global.health/upgrade_value
	Global.update_max_health.emit(0)
	Global.health_regen = 75

func health():
	Global.update_health.emit(upgrade_value)
	Global.update_max_health.emit(upgrade_value)
	#print(Global.health)

func damage():
	Global.damage += (Global.damage * upgrade_value)

func attack_speed():
	match Global.weapon:
		"Gun":
			Global.attack_speed -= (Global.attack_speed * upgrade_value)
		"Laser":
			Global.damage += (Global.damage * upgrade_value)
			#print(Global.damage)
			#print(Global.attack_speed)

func collision_damage():
	Global.collision_damage += upgrade_value

func health_regen():
	Global.health_regen += upgrade_value

func move_speed():
	Global.move_speed += upgrade_value

func counter_thrust():
	Global.counter_thrust += upgrade_value

func bullet_velocity():
	match Global.weapon:
		"Gun":
			Global.bullet_velocity += (Global.bullet_velocity * upgrade_value)
		"Laser":
			Global.damage += (Global.damage * upgrade_value)
			#print(Global.damage)
			#print(Global.attack_speed)

func tank_mode():
	Global.tank_mode = true
