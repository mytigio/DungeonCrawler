extends Area2D

var active = false
var body

signal exit_dungeon(body)

func _on_DungeonExit_body_entered(body):
	self.body = body
	if active:
		print("exit dunegon?")
		emit_signal("exit_dungeon", body)

func _on_DungeonExit_body_exited(body):
	print("player walked off the exit steps")
	active = true
