extends Area2D

var active = false
export(int) var dungeonLevel = 1

func show_dialog():
	$CanvasLayer/ConfirmationDialog.popup_centered()

signal enter_dungeon_confirmed

func _on_ConfirmationDialog_confirmed():
	print("start dungeon")
	GameManager.level = dungeonLevel
	GameManager.overworld_entrance_position = global_position
	GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(global_position)+"_"+str(dungeonLevel)).hash()
	var dungeon = load("res://World/Dungeon/Dungeon.tscn").instance()
	var root = get_node("/root")
	root.add_child(dungeon)
	root.move_child(get_node("/root/players"), root.get_child_count() -1)



	
