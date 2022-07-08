extends "res://Items/Treasure.gd"

export(int) var healthBonus = 5
var used = false

func _on_body_entered(body):
	if (!used):		
		PlayerStats.set_health(PlayerStats.health + healthBonus)
		used = true
	._on_body_entered(body)
