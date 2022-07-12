extends Node

export(int) var level = 1 setget set_character_level

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

export(int) var max_stamina = 1 setget set_max_stamina
var stamina = max_stamina setget set_stamina

export(Texture) var weapon_texture: Texture = null
export(int) var weapon_stamina_cost = 0
export(int) var weapon_damage = 1

export(int) var point_value = 5

signal no_health
signal health_changed(new_value, old_value)
signal max_health_changed(new_value, old_value)
signal stamina_changed(new_value, old_value)
signal max_stamina_changed(new_value, old_value)

func set_character_level(value):
	level = value

func set_health(value):
	if (value != health):
		emit_signal("health_changed", value, health)
	health = clamp(value,0,max_health)
	if (health <= 0):
		emit_signal("no_health")
		
func set_max_health(value):
	if (value != max_health):
		emit_signal("max_health_changed", value, max_health)
	max_health = value
	if (max_health < health):
		self.health = max_health
		
func set_stamina(value):
	if (value != stamina):
		emit_signal("stamina_changed", value, health)
	stamina = clamp(value,0,max_stamina)
		
func set_max_stamina(value):
	if (value != max_stamina):
		emit_signal("max_stamina_changed", value, max_stamina)
	max_stamina = value
	if (max_stamina < health):
		self.stamina = max_stamina

func _ready():	
	self.health = max_health
	self.stamina = max_stamina
		
