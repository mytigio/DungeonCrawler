extends Area2D

var active = false
var body
export(int) var dungeonLevel = 1

func show_dialog(body):
	self.body = body
	$CanvasLayer/ConfirmationDialog.popup_centered()

signal enter_dungeon_confirmed

func _on_ConfirmationDialog_confirmed():
	print("start dungeon")
	GameManager.level = dungeonLevel
  var position_to_use = position
	GameManager.overworld_entrance_position = position_to_use
	GameManager.levelSeed = (str(GameManager.initial_seed)+"_"+str(position_to_use)+"_"+str(dungeonLevel)).hash()
	# load the new level
	GameManager.change_scene(GameManager.DUNGEON_SCENE)

	# set player position only the one that entered
	var exit = get_node("/root/world/YSort/Entrances/DungeonExit")
	var position = Vector2(exit.position.x + 10, exit.position.y + 10)
	body.position = position
