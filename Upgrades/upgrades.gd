extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_title: String = ""
@export var upgrade_text : String = ""
@export var upgrade_value : float = 0
@export var upgrade_texture: Texture
@export var upgrade_cost: int = 0
@export var upgrade_rarity: String = "Common"
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
		"weapon_scale":
			weapon_scale()
		"exp_pull_range":
			exp_pull_range()
		"gatling_gun":
			gatling_gun()
		"smg":
			smg()
		"bulldozer":
			bulldozer()
		"heavy_weaponry":
			heavy_weaponry()
		"ghost_bullets":
			ghost_bullets()
		"concentrated_fire":
			concentrated_fire()
		"rapid_fire":
			rapid_fire()
		"muzzle_break":
			muzzle_break()
		"twin_barrels":
			twin_barrels()
		"explosive_rounds":
			explosive_rounds()
		"explosive_rounds_radius":
			explosive_rounds_radius()
		"explosions_radius_scale":
			explosions_radius_scale()
		"explosions_damage_scale":
			explosions_damage_scale()
		"asteroids_explode":
			asteroids_explode()
		"homing":
			homing()
		"bullet_count":
			bullet_count()
		"bullet_count_double":
			bullet_count_double()

func bullet_count_double():
	Global.bullet_count *= 2
	Global.spread *= 1
	Global.damage /= 1.5

func bullet_count():
	Global.bullet_count += upgrade_value
	Global.spread += upgrade_value * 0.5
	Global.damage /= upgrade_value

func homing():
	Global.homing_strength += upgrade_value

func asteroids_explode():
	Global.explosive_asteroids = true

func explosions_damage_scale():
	Global.explosion_scale_damage += upgrade_value

func explosions_radius_scale():
	Global.explosion_scale_radius += upgrade_value

func explosive_rounds_radius():
	Global.explosion_base_radius += upgrade_value

func explosive_rounds():
	Global.explosive_rounds = true
	Global.explosion_base_damage += upgrade_value

func twin_barrels():
	Global.attack_speed = 0.005
	Global.deviation = 0.6

func muzzle_break():
	Global.deviation = 0.15

func rapid_fire():
	Global.attack_speed -= 0.025

func concentrated_fire():
	Global.deviation = 0.05

func ghost_bullets():
	Global.ghost_bullets = true
	Global.bullet_time = 3
	Global.bulldozer_bullet_health += 200

func heavy_weaponry():
	Global.bulldozer_bullet_health += 50
	Global.weapon_scale += Vector2(2, 2)
	Global.heavy_weaponry = true

func bulldozer():
	Global.attack_speed *= 2
	Global.damage *= 1.5
	Global.bulldozer = true
	Global.bulldozer_bullet_health += 100
	Global.weapon_scale += Vector2(2, 2)
	var bulldozer_upgrades = [load("res://Upgrades/Gun_Upgrades/Evolutions/Bulldozer_Upgrades/Heavy_Weaponry.tres"), load("res://Upgrades/Gun_Upgrades/Evolutions/Bulldozer_Upgrades/Ghost_Bullets.tres")]
	Global.rare_upgrades += bulldozer_upgrades
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/SMG.tres"))
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/Gatling_Gun.tres"))

func smg():
	Global.attack_speed = 0.03
	Global.deviation = 0.3
	Global.bullet_time -= 0.5
	Global.weapon_scale -= Vector2(0.5,0.5)
	Global.damage /= 3
	Global.smg = true
	var smg_upgrades = [load("res://Upgrades/Gun_Upgrades/Evolutions/SMG_Upgrades/Muzzle_Brake.tres"), load("res://Upgrades/Gun_Upgrades/Evolutions/SMG_Upgrades/Twin_Barrels.tres")]
	Global.rare_upgrades += smg_upgrades
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/Gatling_Gun.tres"))
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/Bulldozer.tres"))

func gatling_gun():
	Global.attack_speed = 0.1                      
	Global.deviation = 0.25
	Global.bullet_time += 0.5
	Global.gatling_gun = true
	var gatling_upgrades = [load("res://Upgrades/Gun_Upgrades/Evolutions/Gatling_Gun_Upgrades/Concentrated_Fire.tres"), load("res://Upgrades/Gun_Upgrades/Evolutions/Gatling_Gun_Upgrades/Rapid_Fire.tres")]
	Global.rare_upgrades += gatling_upgrades
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/SMG.tres"))
	Global.legendary_test.erase(load("res://Upgrades/Gun_Upgrades/Evolutions/Bulldozer.tres"))

func exp_pull_range():
	Global.exp_pull_range += Vector2(upgrade_value,upgrade_value)
	Global.upgrade_pull_range.emit()

func weapon_scale():
	Global.weapon_scale += Vector2(upgrade_value,upgrade_value)
	Global.damage *= 1.25

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
	Global.no_gun_all_collision = true
	Global.can_shoot = false
	Global.collision_damage *= upgrade_value

func regen_with_degen():
	Global.max_health = Global.max_health/upgrade_value
	Global.health = Global.health/upgrade_value
	Global.update_max_health.emit(0)
	Global.health_regen = 75

func health():
	Global.update_max_health.emit(upgrade_value)
	Global.update_health.emit(upgrade_value)
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
