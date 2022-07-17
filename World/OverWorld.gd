extends Node2D

const OverworldDungeonEntrance = preload("OverworldDungeonEntrance.tscn")

onready var entrance = $OverworldDungeonEntrance


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.overworld_entrance_position != null:
		for player in LobbyManager.player_info:
			print("We have a player position already: " + str( GameManager.overworld_entrance_position))
			player.position = GameManager.overworld_entrance_position
	readyDungeonEntrances()

func readyDungeonEntrances():
	var overlapsPlayers = entrance.get_overlapping_areas()
	print("entrance position: " + str(entrance.position))
	print("entrance overlaps player:" + str(overlapsPlayers))
	if (overlapsPlayers.size() > 0):
		pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_OverworldDungeonEntrance_body_entered(body):
	print("show entrance dialog")
	entrance.show_dialog(body)

