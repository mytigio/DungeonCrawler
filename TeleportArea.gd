extends Area2D

func _on_TeleportArea_body_entered(body):
	get_tree().change_scene("res://World/Dungeon/Dungeon.tscn")
