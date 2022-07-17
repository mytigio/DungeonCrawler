extends Node

export(int) var initial_seed = 0 setget set_seed
var level = 0 setget set_level
var levelSeed = 0
var overworld_entrance_position
var points = 0 setget set_points

var SERVER_PORT = 444
var MAX_PLAYERS = 4

const MULTIPLAYER_MENU = "res://UI/screens/MultiplayerSetup/MultiplayerSetup.tscn"
const LOBBY_SCENE = "res://UI/screens/Lobby/lobbyMenu.tscn"
const JOIN_SERVER_SCENE = "res://UI/screens/MultiplayerSetup/JoinServerMenu/JoinServerMenu.tscn"
const OVERWORLD_SCENE = "res://World/OverWorld.tscn"
const DUNGEON_SCENE = "res://World/Dungeon/Dungeon.tscn"
const GAME_OVER_SCENE = "res://UI/screens/GameOver/GameOver.tscn"

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

func reset():
	overworld_entrance_position = null
	level = 0
	points = 0
	
	if has_node("/root/world"): # Game is in progress.
		get_node("/root/world").queue_free()
	get_node("/root/players").queue_free()
	
func create_seed():
	if (initial_seed == 0):
		randomize()
		initial_seed = randi()
	print("Initial Game Seed:"+str(initial_seed))
	seed(initial_seed)
	
remote func get_seed():
	GameManager.initial_seed
	
remote func set_seed(new_seed):
	initial_seed = new_seed

func change_scene(scene_resource, nodeName: String = "world", player = null) -> Node:
	# load new scene
	var new_world = load(scene_resource).instance()
	new_world.name = nodeName
	var root = get_node("/root")
	var tree = get_tree()
	var current_scene = get_tree().current_scene
	var current_scene_filepath = current_scene.get_path()
	# clean up old one
	if (has_node(current_scene_filepath)):
		var prev_world = get_node(current_scene_filepath)
		prev_world.name = "previous_world"
		prev_world.queue_free()
	
	root.add_child(new_world)
	tree.current_scene = new_world
	
	# fix players index
	if (has_node("/root/players")):
		root.move_child(get_node("/root/players"), root.get_child_count() -1)
	
	return new_world
	
