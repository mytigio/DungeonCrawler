extends Node

export(int) var initial_seed = 0
var level = 0 setget set_level
var levelSeed = 0
var overworld_entrance_position
var points = 0 setget set_points

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
	if (initial_seed == 0):
		randomize()
		initial_seed = randi()
	print("Initial Game Seed:"+str(initial_seed))
	seed(initial_seed)
