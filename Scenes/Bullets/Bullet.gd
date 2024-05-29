extends Area2D

@onready var timer = $Timer

const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const EXPLOSION_AREA = preload("res://Scenes/Bullets/Explosion/bullet_explosion_area.tscn")
var direction: Vector2
var bullet_speed = Global.bullet_velocity
var screen_size
var damage = Global.damage
var health = Global.bulldozer_bullet_health


func _ready():
	screen_size = get_viewport_rect().size
	if !Global.bulldozer:
		timer.start(Global.bullet_time)
	elif Global.ghost_bullets:
		timer.start(Global.bullet_time)


func _process(delta):
	position += (direction * bullet_speed * delta)
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0


func _on_area_entered(area):
	
	if Global.bulldozer:
		health -= area.damage
		area.damage_asteroid(damage)
		if area.health > 0 && !Global.ghost_bullets:
			direction *= -1
		if health <= 0:
			pass
		else:
			if Global.explosive_rounds:
				var explosion = EXPLOSION_AREA.instantiate()
				if damage > 10 && Global.explosion_scale_damage > 1:
					explosion.damage = Global.explosion_base_damage * ((log(damage)/log(10) * Global.explosion_scale_damage))
				else:
					explosion.damage = Global.explosion_base_damage + (Global.explosion_scale_damage - 1)
				if damage > 10 && Global.explosion_scale_radius > 1:
					explosion.size = Global.explosion_base_radius * ((log(damage) * Global.explosion_scale_radius)/2)
				else:
					explosion.size = Global.explosion_base_radius + (Global.explosion_scale_radius - 1)
				explosion.position = position
				get_parent().call_deferred("add_child", explosion)
			return
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/hurt_c_08-102842.mp3")
	audio_player.volume_db = Global.sound_effects_volume
	get_parent().add_child(audio_player)
	area.damage_asteroid(damage)
	destroy(area)


func destroy(_area):
	if Global.explosive_rounds:
		var explosion = EXPLOSION_AREA.instantiate()
		if damage > 10 && Global.explosion_scale_damage > 1:
			explosion.damage = Global.explosion_base_damage * ((log(damage)/log(10) * Global.explosion_scale_damage))
		else:
			explosion.damage = Global.explosion_base_damage + (Global.explosion_scale_damage - 1)
		if damage > 10 && Global.explosion_scale_radius > 1:
			explosion.size = Global.explosion_base_radius * ((log(damage) * Global.explosion_scale_radius)/2)
		else:
			explosion.size = Global.explosion_base_radius + (Global.explosion_scale_radius - 1)
		explosion.position = position
		get_parent().call_deferred("add_child", explosion)
	queue_free()


func _on_timer_timeout():
	destroy(self)
