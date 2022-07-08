extends Area2D

var Dungeon = load("res://World/Dungeon.tscn")
var active = false

signal exit_dungeon(body)

func _on_DungeonExit_body_entered(body):
	if (active):
		print("exit dunegon?")
		emit_signal("exit_dungeon", body)


func _on_DungeonExit_body_exited(body):
	print("leaving area, enable the area detection")
	active = true
