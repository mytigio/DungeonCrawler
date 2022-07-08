extends Control

export(int) var heart_width = 1
export(int) var stamina_width = 1

var stats = PlayerStats
var hearts = stats.health setget set_hearts
var max_hearts = stats.max_health setget set_max_hearts
var stamina = stats.stamina setget set_stamina
var max_stamina = stats.max_stamina setget set_max_stamina
var level = GameManager.level setget set_level
var points = GameManager.points setget set_points
onready var heartUIFull = $Health/HeartUIFull
onready var heartUIEmpty = $Health/HeartUIEmpty
onready var heartOutline = $Health/Outline
onready var staminaUIFull = $Stamina/StaminaUIFull
onready var staminaUIEmpty = $Stamina/StaminaUIEmpty
onready var staminaOutline = $Stamina/Outline
onready var levelLabel = $Points/LevelLabel
var baseLevelText = "Level: "
onready var pointsLabel = $Points/PointsLabel
var basePopintsText = "Points: "

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if (heartUIFull != null):
		heartUIFull.rect_size.x = hearts * heart_width
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	heartUIEmpty.rect_size.x = max_hearts * heart_width
	heartOutline.rect_size.x = (max_hearts * heart_width) + 2
	
func set_stamina(value):
	stamina = clamp(value, 0, max_stamina)
	if (staminaUIFull != null):
		staminaUIFull.rect_size.x = stamina * stamina_width

func set_max_stamina(value):
	max_stamina = max(value, 0)
	staminaUIEmpty.rect_size.x = max_stamina * stamina_width
	staminaOutline.rect_size.x = (max_stamina * stamina_width) + 2
	
func set_level(value):
	level = value
	levelLabel.text = baseLevelText + str(level)

func set_points(value):
	points = value
	pointsLabel.text = basePopintsText + str(points)
	
func _ready():
	self.max_hearts = stats.max_health
	self.hearts = stats.health
	self.max_stamina = stats.max_stamina
	self.stamina = stats.stamina
	self.level = GameManager.level
	self.points = GameManager.points
	stats.connect("health_changed", self, "update_health")
	stats.connect("max_health_changed", self, "update_max_hearts")
	stats.connect("stamina_changed", self, "update_stamina")
	stats.connect("max_stamina_changed", self, "update_max_stamina")
	GameManager.connect("level_changed", self, "level_changed")
	GameManager.connect("points_changed", self, "update_points")
	
func update_health(new_value, old_value):
	self.set_hearts(new_value)
	
func update_max_hearts(new_value, old_value):
	self.set_max_hearts(new_value)

func update_stamina(new_value, old_value):
	self.set_stamina(new_value)

func update_max_stamina(new_value, old_value):
	self.set_max_stamina(new_value)

func level_changed(new_level):
	self.set_level(new_level)

func update_points(points):
	self.set_points(points)
