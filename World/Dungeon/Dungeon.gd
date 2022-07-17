extends Node2D

const DungeonExit = preload("DungeonExit.gd")

onready var mapMaker = $YSort/ProceduralMazeLevel
#onready var camera = $PlayerCamera
onready var background = $Background
onready var generator = $YSort/ProceduralMazeLevel
onready var entranceContainer = $YSort/Entrances
onready var exitsContainer = $YSort/Exits
onready var treasuresContainer = $YSort/Treasures
onready var enemyContainer = $YSort/Enemies

export(int) var backgroundBuffer = 10

var textureScale = 0.7

func _ready():
	var mapHeight = generator.tile_size * generator.mapHeight
	var mapWidth = generator.tile_size * generator.mapWidth

	background.region_enabled = true
	background.centered = false
	print("Width:"+str(mapWidth))
	print("Height:"+str(mapHeight))
	background.region_rect = Rect2(-64, -64, mapWidth+64, mapHeight+64)

	#camera.limit_left = -backgroundBuffer
	#camera.limit_top = -backgroundBuffer
	#camera.limit_right = mapWidth + backgroundBuffer
	#camera.limit_bottom = mapHeight + backgroundBuffer

	mapMaker.make_maze()


	#place enemies, treasures and exits. This is handled here so that the dungeon
	#can determine the sprites for these things.

func _on_ProceduralMazeLevel_addEntrance(position: Vector2):
	var entrance = mapMaker.entranceScene.instance() as DungeonExit
	entrance.position = position
	var connectionResults = entrance.connect("exit_dungeon", self, "_on_exit_dungeon")
	entranceContainer.add_child(entrance)

func _on_exit_dungeon(body):
	print("popup exit confirmation")
	confirm_exit();

func confirm_exit():
	print("show exit dungeon confirmation")
	$CanvasLayer/ConfirmExit.popup_centered()  # FIXME doesn't pop up

func _on_ProceduralMazeLevel_addExits(positions):
	for position in positions:
		var exit = mapMaker.exitScene.instance()
		exit.position = position
		exitsContainer.add_child(exit)


func _on_ProceduralMazeLevel_addTreasure(positions):
	if (mapMaker.treasureOptions.size() > 0):
		var filteredOptions = getValidArrayIndexes(GameManager.level, mapMaker.treasureSpawnLevels)
		for position in positions:
			var type = mapMaker.treasureOptions[filteredOptions[randi() % filteredOptions.size()]]
			var treasure = type.instance()
			treasure.position = position
			treasuresContainer.add_child(treasure)

func _on_ProceduralMazeLevel_addEnemies(positions):
	if (mapMaker.enemyOptions.size() > 0):
		var filteredEnemyOptions = getValidArrayIndexes(GameManager.level, mapMaker.enemySpawnLevels)
		for position in positions:
			var enemyType = mapMaker.enemyOptions[filteredEnemyOptions[randi() % filteredEnemyOptions.size()]]
			var enemy = enemyType.instance()
			enemy.setLevel(GameManager.level)
			enemy.position = position
			enemyContainer.add_child(enemy)

func getValidArrayIndexes(var level: int, var levelList):
	var validIndex = []
	for n in range(0, levelList.size()):
		var itemLvl = levelList[n]
		print(str(itemLvl) +" <= "+str(level) +" = "+str(itemLvl <= level))
		if (itemLvl <= level):
			validIndex.push_back(n)
	return validIndex


func _on_ConfirmExit_confirmed():
	GameManager.change_scene(GameManager.OVERWORLD_SCENE)
	var player = $SpriteLayer/Player
	GameManager.level = 0

func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
