extends Area2D

export(int) var point_value = 10

func _on_body_entered(body):
	GameManager.add_points(point_value)
	queue_free()
