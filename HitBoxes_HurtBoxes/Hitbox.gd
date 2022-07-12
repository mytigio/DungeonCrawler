extends Area2D

export(int) var stamina_cost = 1
export(int) var damage = 1
export(Vector2) var knockback_vector = Vector2.ZERO
onready var current_damage = damage
