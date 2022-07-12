extends Area2D

var active = false
export(int) var dungeonLevel = 1

func show_dialog():
	$CanvasLayer/ConfirmationDialog.popup_centered()

signal enter_dungeon_confirmed

func _on_ConfirmationDialog_confirmed():
	print("start dungeon")
	GameManager.level = dungeonLevel
	var position_to_use = position
	GameManager.overworld_entrance_position = position_to_use
	GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(position_to_use)+"_"+str(dungeonLevel)).hash()
	print("Seed for entrance at " + str(position_to_use) + ", level "+ str(dungeonLevel)+": "+str(GameManager.levelSeed))
	get_tree().change_scene("res://World/Dungeon/Dungeon.tscn")


func _on_OverworldDungeonEntrance_body_entered(body):
	show_dialog()
