extends "res://Items/Treasure.gd"

export(int) var staminaBonus = 5
var used = false

func _on_body_entered(body):
	if (!used):	
		PlayerStats.set_stamina(PlayerStats.stamina + staminaBonus)
		used = true
	._on_body_entered(body)
