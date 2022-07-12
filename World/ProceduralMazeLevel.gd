extends Node2D

const spacing = 3

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -spacing): N, Vector2(spacing, 0): E,
				 Vector2(0, spacing): S, Vector2(-spacing, 0): W}
var end_cells = [N|W|E, N|W|S, N|S|E, S|W|E]

var mapOffset = Vector2(10,10)

export(int) var tile_size = 16 #tile size (in pixels)
export(int) var height = 24 # width of map (in tiles)
export(int) var width = 24 # height of map (in tiles)
export(int) var level_generation_seed # the seed used for random generation.
export(int) var percent_walls_to_remove = 5 #a number between 0 and 100
export(int) var level = 1
export(int) var maxExits = 5
export(int) var maxTreasure = 10
export(int) var maxEnemies = 20
export(Resource) var entranceScene
export(Resource) var exitScene
export(Array, Resource) var treasureOptions
export(Array, Resource) var enemyOptions
var entrancePosition = Vector2.ZERO
var exitCount = 1
var exits = []
var treasureCount = 1
var treasures = []
var enemyCount = 1
var enemies = []

onready var Map = $TileMap
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	level = GameManager.level
	level_generation_seed = GameManager.levelSeed
	var logOfLevel = ceil(log(level))
	print("New level "+str(level)+" seed:"+str(level_generation_seed))
	rng = RandomNumberGenerator.new()
	if (level_generation_seed == 0):
		level_generation_seed = randi()
		level_generation_seed = level_generation_seed.hash()
	rng.seed = level_generation_seed
	Map.cell_size = Vector2(tile_size, tile_size)
	width += logOfLevel
	height += logOfLevel
	print("Map size: ("+str(width)+","+str(height)+")")
	exitCount = ceil((min(logOfLevel, maxExits) + 1))
	treasureCount = ceil((min(logOfLevel, maxTreasure)))
	enemyCount = ceil((min(log(level+1), maxEnemies) + 1))
	
func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_maze():
	var unvisited = []	
	var stack = []
	Map.clear()
	for x in range(0, width, spacing):
		for y in range(0, height, spacing):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x,y), N|E|S|W)
	var current = Vector2(0, 0)
	unvisited.erase(current)
	
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if (neighbors.size() > 0):
			var next = neighbors[rng.randi() % neighbors.size()]
			stack.append(current)
			#remove walls from both cells so there is an open path between us and the next cell.
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			Map.set_cellv(current, current_walls)
			Map.set_cellv(next, next_walls)
			var offset = dir/spacing
			for space in spacing:
				if (dir.x != 0):
					Map.set_cellv(current + (offset*space), 5) #add vertical connector
				else:
					Map.set_cellv(current + (offset*space), 10) #add horizontal conector
			
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
			
	#now that the map itself is built, lets find end-caps (any tile with 3 sides enclosed)
	var ends = []
	var passages = []
	for x in range(0, width, spacing):
		for y in range(0, height, spacing):
			current = Vector2(x,y)
			var cell = Map.get_cellv(current)
			if (end_cells.has(cell)):
				ends.append(current)
			else:
				passages.append(current)
	
	#first we'll place exits in some of the end spaces. Then place some treasure.
	predictable_shuffle(ends)
	predictable_shuffle(passages)
	
	setEntrancePosition(ends)
	setExitPositions(ends)
	setTreasurePositions(ends)
	setEnemyPositions(passages)	

func erase_walls():
	pass

func setEntrancePosition(availablePositions):
	var entrancePos = Vector2.ZERO
	availablePositions.erase(entrancePos)
	emit_signal("addEntrance",mapOffset+entrancePos)
	
func setExitPositions(availablePositions):
	print("Try to place "+str(exitCount)+" exits")
	if (availablePositions.size() < exitCount):		
		exitCount = availablePositions.size()
		print("truncate number of exits to "+str(exitCount))
	for exit in exitCount:
		var exitPos = availablePositions.pop_front()
		exitPos *= tile_size
		exits.append(mapOffset+exitPos)
	
	emit_signal("addExits", exits)

func setTreasurePositions(availablePositions):
	print("Try to place "+str(treasureCount)+" treasures")
	if (availablePositions.size() < treasureCount):
		treasureCount = availablePositions.size()
		print("truncate number of treasures to "+str(treasureCount))
	for treasure in treasureCount:
		var treasurePos = availablePositions.pop_front()
		treasurePos *= tile_size
		treasures.append(mapOffset+treasurePos)
	
	emit_signal("addTreasure", treasures)

func setEnemyPositions(availablePositions):
	print("Try to place "+str(enemyCount)+" enemies")
	if (availablePositions.size() < enemyCount):
		enemyCount = availablePositions.size()
		print("truncate number of enemies to "+str(enemyCount))
	for enemy in enemyCount:
		var enemyPos = availablePositions.pop_front()
		enemyPos *= tile_size
		enemies.append(mapOffset+enemyPos)
		
	emit_signal("addEnemies", enemies)

func predictable_shuffle(arrayToShuffle):
	for n in arrayToShuffle.size():
		var randomSpot = rng.randi_range(n, arrayToShuffle.size()-1)
		var temp = arrayToShuffle[n]
		arrayToShuffle[n] = arrayToShuffle[randomSpot]
		arrayToShuffle[randomSpot] = temp

signal addEntrance(position)
signal addExits(positions)
signal addTreasure(positions)
signal addEnemies(positions)
