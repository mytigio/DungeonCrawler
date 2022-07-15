extends Area2D

var active = true
export(int) var dungeonLevel = 1

func _on_DungeonEntrance_body_entered(body):
	if (active):
		GameManager.level += dungeonLevel
		GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(global_position)+"_"+str(dungeonLevel)).hash()

		# remove old level
		get_node("/root/Dungeon").queue_free()
		
		# load the new level
		var dungeon = load("res://World/Dungeon/Dungeon.tscn").instance()
		var root = get_node("/root")

		root.add_child(dungeon)
		# fix players index
		root.move_child(get_node("/root/players"), root.get_child_count() -1)
		
		# set player position only the one that entered 
		var exit = get_node("/root/Dungeon/YSort/Entrances/DungeonExit")
		var position = Vector2(exit.position.x + 10, exit.position.y + 10)
		body.position = position


func _on_DungeonEntrance_body_exited(body):
	active = true
