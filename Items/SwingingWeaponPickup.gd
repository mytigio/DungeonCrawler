extends Area2D

const Player = preload("res://Player/Player.gd")

export(int) var energy_cost = 0
export(int) var damage = 0
export(Shape2D) var weapon_collision

onready var Sprite = $Sprite
var stats = PlayerStats

var used = false


func _on_body_entered(body):
	print("pick up weapon")
	var player = body as Player
	if (player != null && !used):
		stats.weapon_texture = Sprite.texture
		stats.weapon_damage = damage
		stats.weapon_stamina_cost = energy_cost
		stats.weapon_collision = weapon_collision
		print("set weapon stats: dmg(" + str(damage) + ") and energy("+str(energy_cost)+")")
		player.set_weapon_info()
		used = true
		queue_free()
