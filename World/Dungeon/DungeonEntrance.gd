extends Area2D

var active = true
export(int) var dungeonLevel = 1
export(String) var baseDungeonInfo


func getNewDungeonLevel(position_to_use: Vector2) -> Node:
	print("start dungeon")
	GameManager.level = dungeonLevel
	#var position_to_use = position
	var dungeon_info = baseDungeonInfo + "_" + str(position_to_use.x)+"_"+str(position_to_use.y)+"_"+str(dungeonLevel)
	GameManager.levelSeed = (dungeon_info).hash()
	# load the new level
	var newScene = GameManager.change_scene(GameManager.DUNGEON_SCENE, dungeon_info)
	newScene.setBaseDungeonInfo(baseDungeonInfo)
	return newScene

func _on_DungeonEntrance_body_entered(body):
	if (active):		
		var newScene = getNewDungeonLevel(global_position)
		
		# set player position only the one that entered		
		var exit = get_node(str(newScene.get_path()) + "/YSort/Entrances/DungeonExit")
		var position = Vector2(exit.position.x + 10, exit.position.y + 10)
		body.position = position
		body.get_node("Light").enabled = true


func _on_DungeonEntrance_body_exited(body):
	active = true
