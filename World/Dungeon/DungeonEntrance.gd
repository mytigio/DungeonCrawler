extends Area2D

var active = true
export(int) var dungeonLevel = 1

func _on_DungeonEntrance_body_entered(body):
	if (active):
		GameManager.level += dungeonLevel
		GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(global_position)+"_"+str(dungeonLevel)).hash()

		GameManager.change_scene(GameManager.DUNGEON_SCENE)

		# set player position only the one that entered
		var exit = get_node("/root/world/YSort/Entrances/DungeonExit")
		var position = Vector2(exit.position.x + 10, exit.position.y + 10)
		body.position = position
		body.get_node("Light").enabled = true


func _on_DungeonEntrance_body_exited(body):
	active = true
