extends "res://World/Dungeon/DungeonEntrance.gd"

var body

func _on_ready():
	active = false

func show_dialog(body):
	self.body = body
	$CanvasLayer/ConfirmationDialog.popup_centered()

signal enter_dungeon_confirmed

func _on_ConfirmationDialog_confirmed():
	print("start dungeon")	
	var position_to_use = position
	GameManager.overworld_entrance_position = position_to_use
	var dungeon_info = "dungeon_" + str(GameManager.initial_seed)+"_"+str(position_to_use.x)+"_"+str(position_to_use.y)
	#set initial dungeon info
	baseDungeonInfo = dungeon_info
	
	var newScene = getNewDungeonLevel(Vector2.ZERO)
	
	# set player position only the one that entered
	var exit = (newScene.entranceContainer as YSort).get_child(0)
	var position = Vector2(exit.position.x + 10, exit.position.y + 10)
	body.position = position
