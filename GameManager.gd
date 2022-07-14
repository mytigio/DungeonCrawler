extends Node

export(int) var initial_seed = 0
var level = 0 setget set_level
var levelSeed = 0
var overworld_entrance_position
var points = 0 setget set_points

var SERVER_PORT = 444
var MAX_PLAYERS = 4

var MULTIPLAYER_MENU = "res://UI/screens/MultiplayerSetup/MultiplayerSetup.tscn"
var LOBBY_SCENE = "res://UI/screens/Lobby/lobbyMenu.tscn"
var JOIN_SERVER_SCENE = "res://UI/screens/MultiplayerSetup/JoinServerMenu/JoinServerMenu.tscn"
var OVERWORLD_SCENE = "res://World/OverWorld.tscn"


signal level_changed(level)
signal points_changed(points)

func set_level(value):
	level = value
	emit_signal("level_changed",level)

func set_points(value):
	points = value
	emit_signal("points_changed", points)

func add_points(value):
	var totalPoints = (value * (floor(log(level+1))+1)) + points
	self.points = totalPoints
	
func _ready():
	print("game manage ready")
	if (initial_seed == 0):
		randomize()
		initial_seed = randi()
	print("Initial Game Seed:"+str(initial_seed))
	seed(initial_seed)

func reset():
	overworld_entrance_position = null
	level = 0
	points = 0
