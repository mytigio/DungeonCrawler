extends Node2D

export(int) var spacing = 1

const N = 1
const E = 2
const S = 4
const W = 8

onready var cell_walls = {Vector2(0, -spacing): N, Vector2(spacing, 0): E,
				 Vector2(0, spacing): S, Vector2(-spacing, 0): W}

var cell_properties = {}

var end_cells = [N|W|E, N|W|S, N|S|E, S|W|E]

const northWallTile = 1
const eastWallTile = 5
const westWallTile = 3
const southWallTile = 7
const northEastOutsideCorner = 10
const northWestOutsideCorner = 9
const southEastOutsideCorner = 12
const southWestOutsideCorner = 11
const northEastInsideCorner = 2
const northWestInsideCorner = 0
const southEastInsideCorner = 8
const southWestInsidecorner = 6
const floorTile = 4

const decoratableWalls = [northWallTile, northWestOutsideCorner, northEastOutsideCorner]
const mutuallyExclusiveWallDecorations = [22, 27, 28]
var exclusiveWallDecoration = 22

const wallDecorations = [19, 20, 21, 22, 23, 25, 25, 26]

const floorDecorationRangeMin = 29
const floorDecorationRangeMax = 34

onready var entrance_cells = {"default": 17, N|W|E: 18, N|W: 18}
var exit_cells = {N|W|E: 16, N|W|S: 13, N|E|S: 14, E|W|S: 15}

var mapOffset = Vector2(16,16)

export(int) var tile_size = 16 #tile size (in pixels)
export(int) var height = 24 # width of map (in tiles)
export(int) var width = 24 # height of map (in tiles)
export(int) var level_generation_seed # the seed used for random generation.
export(int) var percent_walls_to_remove = 5 #a number between 0 and 100
export(int) var percent_wall_decoration = 50
export(int) var percent_floor_decoration = 75
export(int) var level = 1
export(int) var minExits = 1
export(int) var maxExits = 5
export(int) var minTreasure = 1
export(int) var maxTreasure = 20
export(int) var minEnemies = 1
export(int) var maxEnemies = 20
export(Resource) var entranceScene
export(Resource) var exitScene
export(Array, int) var treasureSpawnLevels
export(Array, Resource) var treasureOptions
export(Array, int) var enemySpawnLevels
export(Array, Resource) var enemyOptions
var entrancePosition = Vector2.ZERO
var mapWidth = width * spacing
var mapHeight = height * spacing
var exitCount = 1
var exits = []
var treasureCount = 1
var treasures = []
var enemyCount = 1
var enemies = []

onready var Map = $FloorMap
onready var WallsMap = $WallsMap
onready var DecorationsMap = $DecorationsMap
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
	mapWidth = (width * spacing)+1
	height += logOfLevel
	mapHeight = (height * spacing)+1
	print("Map size: ("+str(width)+","+str(height)+")")
	exitCount = ceil((min(logOfLevel, maxExits) + minExits))
	treasureCount = ceil((min(logOfLevel, maxTreasure) + minTreasure))
	enemyCount = ceil((min(log(level+1), maxEnemies) + minEnemies))
	predictable_shuffle(mutuallyExclusiveWallDecorations)
	exclusiveWallDecoration = mutuallyExclusiveWallDecorations[0]
	
func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_maze():
	var unvisited = []	
	var stack = []
	WallsMap.clear()
	Map.clear()
	DecorationsMap.clear()
	for x in range(0, mapWidth, spacing):
		for y in range(0, mapHeight, spacing):
			unvisited.append(Vector2(x, y))
			cell_properties[Vector2(x, y)] = N|E|S|W
	var current = Vector2(0, 0)
	unvisited.erase(current)
	
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if (neighbors.size() > 0):
			var next = neighbors[rng.randi() % neighbors.size()]
			stack.append(current)
			#remove walls from both cells so there is an open path between us and the next cell.
			var dir = next - current
			var current_walls = cell_properties[current] - cell_walls[dir]
			var next_walls = cell_properties[next] - cell_walls[-dir]
			placeFloorTile(current)
			cell_properties[current] = current_walls
			placeFloorTile(next)
			cell_properties[next] = next_walls
			var offset = dir/spacing
			for space in range(1, spacing):
				var connection = current + (offset*space)
				if (dir.x != 0):
					cell_properties[connection] = 5
				else:
					cell_properties[connection] = 10
				placeFloorTile(current + (offset*space))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
	
	erase_walls()
			
	#now that the map itself is built, lets find end-caps (any tile with 3 sides enclosed)
	var ends = []
	var passages = []
	for x in range(0, mapWidth, spacing):
		for y in range(0, mapHeight, spacing):
			current = Vector2(x,y)
			var cell = cell_properties[current]
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
	
	place_wall_tiles()

func placeFloorTile(cell):
	Map.set_cellv(cell, floorTile)
	var decoration = pickFloorDecoration()
	if (decoration >= 0):
		DecorationsMap.set_cellv(cell,decoration)

func erase_walls():
	var calculatedPercent = percent_walls_to_remove / 100.0
	var wallsToRemove = int(width * height * calculatedPercent)
	var cellsWithWallsRemoved = []
	for i in range(wallsToRemove):
		var xOptions = rng.randi_range(1,width-1)
		var x = xOptions*spacing
		var yOptions = rng.randi_range(1,height-1)
		var y = yOptions*spacing
		var wallToErase = Vector2(x, y)
		cellsWithWallsRemoved.append(wallToErase)
		var erasedCellWalls = cell_properties[wallToErase]
		#pick a neighbor
		var neighbor = cell_walls.keys()[rng.randi() % cell_walls.size()]
		#check if a wall between them exists.
		if (erasedCellWalls & cell_walls[neighbor]):
			var walls = cell_properties[wallToErase] - cell_walls[neighbor]
			var neighbor_cell = wallToErase+neighbor
			var neighbor_walls = cell_properties[neighbor_cell] - cell_walls[-neighbor]
			cell_properties[wallToErase] = walls
			cell_properties[neighbor_cell] = neighbor_walls
			
			var offset = neighbor/spacing
			for space in range(1, spacing):
				var connection = wallToErase + (offset*space)
				if (neighbor.x != 0):
					cell_properties[connection] = 5
				else:
					cell_properties[connection] = 10
				placeFloorTile(wallToErase + (offset*space))
func place_wall_tiles():
	#this goes through 2 phases, in phase 1 we loop through every tile on the map
	#and place basic top, left, right and bottom walls
	
	#second phase, we find specific junctions, and we set the appropriate corners
	#for that junction, this second phase can cause walls from phase 1 to disappear.
	#because of this phase, the maze must have a minimum spacing of 3.
	
	#we go through every tile, not just those based on spacing so we can place walls
	#around the connection pieces as well.
	var northCell = Vector2(0,-1)
	var eastCell = Vector2(1,0)
	var southCell = Vector2(0,1)
	var westCell = Vector2(-1,0)
	var northEastCell = Vector2(1,-1)
	var northWestCell = Vector2(-1,-1)
	var southEastCell = Vector2(1,1)
	var southWestCell = Vector2(-1,1)
	
	#place main walls.
	for x in range(0, mapWidth):
		for y in range(0, mapHeight):
			var current = Vector2(x, y)
			if (cell_properties.has(current)):
				var data = cell_properties[current]
				if ((data & N) == N):
					WallsMap.set_cellv(current+northCell, northWallTile)
				if ((data & E) == E):
					WallsMap.set_cellv(current+eastCell, eastWallTile)
				if ((data & S) == S):
					WallsMap.set_cellv(current+southCell, southWallTile)
				if ((data & W) == W):
					WallsMap.set_cellv(current+westCell, westWallTile)
	
	#place corners.
	for x in range(0, mapWidth):
		for y in range(0, mapHeight):
			var current = Vector2(x,y)
			if (cell_properties.has(current)):
				var data = cell_properties[current]
				match data:
					0:
						WallsMap.set_cellv(current+southEastCell, southEastOutsideCorner)
						WallsMap.set_cellv(current+southWestCell, southWestOutsideCorner)
						WallsMap.set_cellv(current+northEastCell, northWestOutsideCorner)
						WallsMap.set_cellv(current+northWestCell, northEastOutsideCorner)
					1:
						WallsMap.set_cellv(current+southWestCell, southWestOutsideCorner)
						WallsMap.set_cellv(current+southEastCell, southEastOutsideCorner)
					2:
						WallsMap.set_cellv(current+southWestCell, southWestOutsideCorner)
						WallsMap.set_cellv(current+northWestCell, northEastOutsideCorner)
					3:
						WallsMap.set_cellv(current+southWestCell, southWestOutsideCorner)
						WallsMap.set_cellv(current+northEastCell, northEastInsideCorner)
					4:
						WallsMap.set_cellv(current+northWestCell, northEastOutsideCorner)
						WallsMap.set_cellv(current+northEastCell, northWestOutsideCorner)
					6:
						WallsMap.set_cellv(current+southEastCell, southWestInsidecorner)
						WallsMap.set_cellv(current+northWestCell, northEastOutsideCorner)
					7:
						WallsMap.set_cellv(current+northEastCell, northEastInsideCorner)
						WallsMap.set_cellv(current+southEastCell, southWestInsidecorner)
					8:
						WallsMap.set_cellv(current+northEastCell, northWestOutsideCorner)
						WallsMap.set_cellv(current+southEastCell, southEastOutsideCorner)
					9:
						WallsMap.set_cellv(current+northWestCell, northWestInsideCorner)
						WallsMap.set_cellv(current+southEastCell, southEastOutsideCorner)
					11:
						WallsMap.set_cellv(current+northEastCell, northEastInsideCorner)
						WallsMap.set_cellv(current+northWestCell, northWestInsideCorner)
					12:
						WallsMap.set_cellv(current+northEastCell, northWestOutsideCorner)
						WallsMap.set_cellv(current+southWestCell, southEastInsideCorner)
					13:
						WallsMap.set_cellv(current+northWestCell, northWestInsideCorner)
						WallsMap.set_cellv(current+southWestCell, southEastInsideCorner)
					14:
						WallsMap.set_cellv(current+southEastCell, southWestInsidecorner)
						WallsMap.set_cellv(current+southWestCell, southEastInsideCorner)
					15:
						WallsMap.set_cellv(current+southEastCell, southWestInsidecorner)
						WallsMap.set_cellv(current+southWestCell, southEastInsideCorner)
						WallsMap.set_cellv(current+northEastCell, northEastInsideCorner)
						WallsMap.set_cellv(current+northWestCell, northWestInsideCorner)
	
	#place wall decorations.
	for x in range(0, mapWidth):
		for y in range(0, mapHeight):
			var current = Vector2(x,y)
			if (cell_properties.has(current)):
				#add wall decoration if needed.
				var northWall = current+northCell
				var northWallData = WallsMap.get_cellv(northWall)
				if (decoratableWalls.has(northWallData)):
					#wall above us is a basic wall, roll for a decoration.
					var decoration = pickWallDecoration()
					if (decoration >= 0):
						DecorationsMap.set_cellv(northWall,decoration)

func pickWallDecoration():
	var chanceRoll = rng.randi_range(1,101)
	if (chanceRoll <= percent_wall_decoration):
		var decorationNumber = rng.randi_range(0, wallDecorations.size()-1)
		var whichDecoration = wallDecorations[decorationNumber]
		if (mutuallyExclusiveWallDecorations.has(whichDecoration)):
			whichDecoration = exclusiveWallDecoration
		return whichDecoration
	else:
		return -1

func pickFloorDecoration():
	var chanceRoll = rng.randi_range(1,101)
	if (chanceRoll <= percent_floor_decoration):
		var whichDecoration = rng.randi_range(floorDecorationRangeMin, floorDecorationRangeMax)
		return whichDecoration
	else:
		return -1

func setEntrancePosition(availablePositions):
	var entrancePos = Vector2.ZERO
	availablePositions.erase(entrancePos)
	var positionData = cell_properties[entrancePos]
	#place either a stair opening to the right or down.
	var entranceScene = entrance_cells["default"]
	if (entrance_cells.has(positionData)):
		entranceScene = entrance_cells[positionData]	
		
	#placeholder for the moment
	Map.set_cellv(entrancePos, entranceScene)
	DecorationsMap.set_cellv(entrancePos, -1)
	emit_signal("addEntrance",entrancePos)
	
	
func setExitPositions(availablePositions):
	print("Try to place "+str(exitCount)+" exits")
	if (availablePositions.size() < exitCount):		
		exitCount = availablePositions.size()
		print("truncate number of exits to "+str(exitCount))
	
	for exit in exitCount:
		var exitPos = availablePositions.pop_front()
		var exitData = cell_properties[exitPos]
		var exitScene = exit_cells[exitData]
		#placeholder for a moment.
		Map.set_cellv(exitPos, exitScene)
		DecorationsMap.set_cellv(exitPos, -1)
		exitPos *= tile_size
		exitPos += mapOffset
		exits.append(exitPos)		
	print("Exits placed at: "+str(exits))	
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
	
	print("Treasure placed at: "+str(treasures))
	emit_signal("addTreasure", treasures, rng)

func setEnemyPositions(availablePositions):
	print("Try to place "+str(enemyCount)+" enemies")
	if (availablePositions.size() < enemyCount):
		enemyCount = availablePositions.size()
		print("truncate number of enemies to "+str(enemyCount))
	for enemy in enemyCount:
		var enemyPos = availablePositions.pop_front()
		enemyPos *= tile_size
		enemies.append(mapOffset+enemyPos)
		
	print("Enemies placed at: "+str(enemies))
	emit_signal("addEnemies", enemies, rng)

func predictable_shuffle(arrayToShuffle):
	for n in arrayToShuffle.size():
		var randomSpot = rng.randi_range(n, arrayToShuffle.size()-1)
		var temp = arrayToShuffle[n]
		arrayToShuffle[n] = arrayToShuffle[randomSpot]
		arrayToShuffle[randomSpot] = temp

signal addEntrance(position)
signal addExits(positions)
signal addTreasure(positions, rng)
signal addEnemies(positions, rng)
