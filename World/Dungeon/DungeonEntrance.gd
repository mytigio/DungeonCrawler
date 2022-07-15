extends Area2D

var active = true
export(int) var dungeonLevel = 1

func _on_DungeonEntrance_body_entered(body):
	if (active):
		GameManager.level += dungeonLevel
		GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(global_position)+"_"+str(dungeonLevel)).hash()


		var world = load("res://World/OverWorld.tscn").instance()
		get_node("/root").add_child(world)
		get_tree().change_scene("res://World/Dungeon/Dungeon.tscn")


func _on_DungeonEntrance_body_exited(body):
	active = true
