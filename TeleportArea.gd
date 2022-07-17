extends Area2D

func _on_TeleportArea_body_entered(body):
	GameManager.change_scene(GameManager.DUNGEON_SCENE)
